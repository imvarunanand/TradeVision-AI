// lib/features/market/services/candle_builder.dart

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import '../domain/entities/candle.dart';
import '../domain/entities/market_tick.dart';
import '../domain/tick_source.dart';
import '../domain/timeframe.dart';
import '../domain/history_provider.dart';

/// Event types emitted by [CandleBuilder].
enum CandleEventType { started, updated, completed, gapFilled, stopped, error }

/// Lightweight event wrapper for candle lifecycle and errors.
class CandleEvent {
  final CandleEventType type;
  final Candle? candle;
  final Object? error;

  CandleEvent._(this.type, {this.candle, this.error});

  factory CandleEvent.started(Candle? c) => CandleEvent._(CandleEventType.started, candle: c);
  factory CandleEvent.updated(Candle? c) => CandleEvent._(CandleEventType.updated, candle: c);
  factory CandleEvent.completed(Candle c) => CandleEvent._(CandleEventType.completed, candle: c);
  factory CandleEvent.gapFilled(Candle c) => CandleEvent._(CandleEventType.gapFilled, candle: c);
  factory CandleEvent.stopped() => CandleEvent._(CandleEventType.stopped);
  factory CandleEvent.error(Object e) => CandleEvent._(CandleEventType.error, error: e);
}

/// Configuration object for [CandleBuilder]. Use this single value-object when
/// creating builders (so providers can key by it).
class CandleBuilderConfig {
  final String symbol;
  final Timeframe timeframe;
  final int maxCandles;
  final TickSource tickSource;
  final CandleHistoryProvider? historyProvider;

  const CandleBuilderConfig({
    required this.symbol,
    required this.timeframe,
    required this.tickSource,
    this.historyProvider,
    this.maxCandles = 500,
  });

  @override
  bool operator ==(Object other) {
    return other is CandleBuilderConfig &&
        other.symbol == symbol &&
        other.timeframe == timeframe &&
        other.maxCandles == maxCandles;
  }

  @override
  int get hashCode => Object.hash(symbol, timeframe, maxCandles);
}

/// Builds timeframe-aligned candles from a generic [TickSource].
///
/// Responsibilities:
/// - Consume ticks from [TickSource.subscribe] for the configured symbol.
/// - Maintain a forming (current) candle and emit completed candles.
/// - Fill gaps using the previous close.
/// - Validate candles before accepting them.
/// - Keep up to [config.maxCandles] in memory.
///
/// Important: [start] must be called explicitly by the owner. The builder
/// will not auto-start when created so multiple parts of the app can coordinate
/// startup.
class CandleBuilder {
  final CandleBuilderConfig config;

  final ListQueue<Candle> _candles = ListQueue();
  Candle? _current;

  final _completedController = StreamController<Candle>.broadcast();
  final _currentController = StreamController<Candle?>.broadcast();
  final _eventController = StreamController<CandleEvent>.broadcast();

  StreamSubscription<MarketTick>? _sub;
  bool _running = false;

  CandleBuilder(this.config);

  /// Broadcast stream of completed, validated candles.
  Stream<Candle> get completedCandles => _completedController.stream;

  /// Broadcast stream of the currently forming candle. Emits null when no
  /// forming candle exists.
  Stream<Candle?> get currentCandle => _currentController.stream;

  /// Broadcast stream of lifecycle and error events.
  Stream<CandleEvent> get events => _eventController.stream;

  /// Iterable view of in-memory candles (newest at the end). This is an
  /// iterable to avoid allocations; convert to list in UI only when needed.
  Iterable<Candle> get candles sync* {
    for (final c in _candles) yield c;
  }

  /// True when the builder is currently subscribed and processing ticks.
  bool get isRunning => _running;

  /// Load history into in-memory buffer (chronological order expected).
  /// Call before [start] if you want the buffer populated first.
  Future<void> preloadHistory({int limit = 500}) async {
    final hp = config.historyProvider;
    if (hp == null) return;
    final list = await hp.loadHistory(config.symbol, config.timeframe, limit);
    if (list.isEmpty) return;
    for (final c in list) {
      if (_validateCandle(c)) _pushCandle(c);
    }
  }

  /// Start the builder. Calling start when already running is a no-op.
  Future<void> start({bool preload = true, int preloadLimit = 500}) async {
    if (_running) return; // prevent duplicate starts
    _running = true;
    _eventController.add(CandleEvent.started(null));

    if (preload && config.historyProvider != null) {
      try {
        await preloadHistory(limit: preloadLimit);
      } catch (e) {
        _eventController.add(CandleEvent.error(e));
        // continue to start live feed
      }
    }

    try {
      final stream = config.tickSource.subscribe(config.symbol);
      _sub = stream.listen(_onTick, onError: (e) {
        _eventController.add(CandleEvent.error(e));
      }, cancelOnError: false);
    } catch (e) {
      _eventController.add(CandleEvent.error(e));
      _running = false;
      rethrow;
    }
  }

  /// Stop processing ticks. This is safe to call multiple times.
  Future<void> stop() async {
    if (!_running) return;
    await _sub?.cancel();
    _sub = null;
    _running = false;
    _eventController.add(CandleEvent.stopped());
  }

  /// Dispose resources. After disposal the builder cannot be restarted.
  Future<void> dispose() async {
    await stop();
    await _completedController.close();
    await _currentController.close();
    await _eventController.close();
  }

  void _onTick(MarketTick tick) {
    try {
      if (tick.status == ConnectionStatus.disconnected) return; // ignore

      final ts = tick.timestamp.toUtc();
      final frameMinutes = config.timeframe.minutes;
      final frameStart = _alignToTimeframe(ts, frameMinutes);
      final frameEnd = frameStart.add(Duration(minutes: frameMinutes));
      final mid = (tick.bid + tick.ask) / 2.0;

      if (_current == null || !_isSameInterval(_current!, frameStart, frameEnd)) {
        if (_current != null) _closeCurrent();

        // fill gaps if needed
        _fillGapsIfNeeded(frameStart);

        final candidate = Candle(
          symbol: config.symbol,
          timeframeMinutes: frameMinutes,
          start: frameStart,
          end: frameEnd,
          open: mid,
          high: mid,
          low: mid,
          close: mid,
          volume: 0,
        );

        if (_validateCandle(candidate)) {
          _current = candidate;
          _currentController.add(_current);
          _eventController.add(CandleEvent.updated(_current));
        }
        return;
      }

      // update existing
      final high = max(_current!.high, mid);
      final low = min(_current!.low, mid);
      final updated = _current!.copyWith(high: high, low: low, close: mid);

      if (_validateCandle(updated)) {
        _current = updated;
        _currentController.add(_current);
        _eventController.add(CandleEvent.updated(_current));
      }

      // edge: tick timestamp beyond end
      if (!ts.isBefore(_current!.end)) {
        _closeCurrent();
      }
    } catch (e) {
      _eventController.add(CandleEvent.error(e));
    }
  }

  bool _isSameInterval(Candle c, DateTime start, DateTime end) => c.start == start && c.end == end;

  void _closeCurrent() {
    final closing = _current!;
    if (_validateCandle(closing)) {
      _pushCandle(closing);
      _completedController.add(closing);
      _eventController.add(CandleEvent.completed(closing));
    }
    _current = null;
    _currentController.add(null);
  }

  void _pushCandle(Candle c) {
    _candles.add(c);
    while (_candles.length > config.maxCandles) _candles.removeFirst();
  }

  void _fillGapsIfNeeded(DateTime newStart) {
    if (_candles.isEmpty) return;
    final last = _candles.last;
    DateTime expected = last.end.toUtc();
    while (expected.isBefore(newStart)) {
      final filler = Candle(
        symbol: config.symbol,
        timeframeMinutes: config.timeframe.minutes,
        start: expected,
        end: expected.add(Duration(minutes: config.timeframe.minutes)),
        open: last.close,
        high: last.close,
        low: last.close,
        close: last.close,
        volume: 0,
      );
      if (_validateCandle(filler)) {
        _pushCandle(filler);
        _completedController.add(filler);
        _eventController.add(CandleEvent.gapFilled(filler));
      }
      expected = expected.add(Duration(minutes: config.timeframe.minutes));
    }
  }

  DateTime _alignToTimeframe(DateTime tsUtc, int tfMinutes) {
    final year = tsUtc.year;
    final month = tsUtc.month;
    final day = tsUtc.day;
    final hour = tsUtc.hour;
    final minute = tsUtc.minute;
    final floorMinute = (minute ~/ tfMinutes) * tfMinutes;
    return DateTime.utc(year, month, day, hour, floorMinute);
  }

  /// Validation rules:
  /// - high >= low
  /// - open and close within [low, high]
  /// - prices non-negative
  /// - start < end
  bool _validateCandle(Candle c) {
    if (!c.start.isBefore(c.end)) return false;
    if (c.low.isNaN || c.high.isNaN || c.open.isNaN || c.close.isNaN) return false;
    if (c.low < 0 || c.high < 0 || c.open < 0 || c.close < 0) return false;
    if (c.high < c.low) return false;
    if (c.open < c.low || c.open > c.high) return false;
    if (c.close < c.low || c.close > c.high) return false;
    return true;
  }
}
