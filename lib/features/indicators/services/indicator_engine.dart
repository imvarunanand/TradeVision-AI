// lib/features/indicators/services/indicator_engine.dart

import 'dart:async';

import '../../market/domain/entities/candle.dart';
import '../../market/services/candle_builder.dart';
import '../domain/indicator_snapshot.dart';
import '../domain/indicator.dart';
import '../domain/ema_indicator.dart';

/// Engine responsible for wiring indicators to CandleBuilder events.
///
/// Responsibilities:
/// - Subscribe to CandleEvent.stream (only react to completed events)
/// - Maintain incremental indicators and update only on new completed candles
/// - Cache the latest IndicatorSnapshot per symbol/timeframe
class IndicatorEngine {
  final CandleBuilder _builder;

  StreamSubscription<CandleEvent>? _sub;
  IndicatorSnapshot? _latest;
  final _snapshotController = StreamController<IndicatorSnapshot?>.broadcast();

  // registered indicators
  final List<Indicator<dynamic>> _indicators = [];

  // concrete EMA references for snapshot reads
  final EMA20Indicator _ema20 = EMA20Indicator();
  final EMA50Indicator _ema50 = EMA50Indicator();

  IndicatorEngine(this._builder) {
    // auto-register EMAs
    registerIndicator(_ema20);
    registerIndicator(_ema50);
  }

  /// Broadcast stream of latest snapshots. Emits whenever the latest snapshot updates.
  Stream<IndicatorSnapshot?> get snapshots => _snapshotController.stream;

  /// Latest cached snapshot (may be null until first completed candle is processed).
  IndicatorSnapshot? get latestSnapshot => _latest;

  /// Start listening to candle events. Calling start() multiple times is a no-op.
  /// Will reset indicators, warm them using existing builder.candles, and then
  /// subscribe to completed candle events to update incrementally.
  Future<void> start() async {
    if (_sub != null) return;

    // reset indicators
    for (final ind in _indicators) {
      try {
        ind.reset();
      } catch (_) {}
    }

    // Warm-up using history from CandleBuilder (chronological order).
    try {
      final history = _builder.candles;
      _ema20.calculate(history);
      _ema50.calculate(history);
    } catch (_) {
      // ignore warm-up failures
    }

    _sub = _builder.events.listen((ev) {
      if (ev.type != CandleEventType.completed) return;
      final c = ev.candle;
      if (c == null) return;

      for (final ind in _indicators) {
        try {
          ind.update(c);
        } catch (_) {}
      }

      final ema20v = _ema20.value ?? double.nan;
      final ema50v = _ema50.value ?? double.nan;

      _latest = IndicatorSnapshot(
        candleTime: c.start,
        ema20: ema20v,
        ema50: ema50v,
      );
      _snapshotController.add(_latest);
    }, onError: (e) {
      // swallow errors
    }, cancelOnError: false);
  }

  /// Stop listening and free resources. Reset indicators.
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;

    for (final ind in _indicators) {
      try {
        ind.reset();
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    await stop();
    await _snapshotController.close();
  }

  /// Register an indicator instance to be updated by the engine.
  void registerIndicator(Indicator<dynamic> indicator) {
    _indicators.add(indicator);
  }
}
