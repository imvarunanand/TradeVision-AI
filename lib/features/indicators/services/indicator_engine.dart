// lib/features/indicators/services/indicator_engine.dart

import 'dart:async';

import '../../market/domain/entities/candle.dart';
import '../../market/services/candle_builder.dart';
import '../../market/services/candle_builder.dart' as cbshow; // for types
import '../domain/indicator_snapshot.dart';
import '../domain/indicator.dart';

/// Engine responsible for wiring indicators to CandleBuilder events.
///
/// Responsibilities:
/// - Subscribe to CandleEvent.stream (only react to completed events)
/// - Maintain incremental indicators and update only on new completed candles
/// - Cache the latest IndicatorSnapshot per symbol/timeframe
class IndicatorEngine {
  final CandleBuilderConfig config;
  final Stream<CandleEvent> _events;

  StreamSubscription<CandleEvent>? _sub;
  IndicatorSnapshot? _latest;
  final _snapshotController = StreamController<IndicatorSnapshot?>.broadcast();

  // indicator instances will be added later; for now we keep placeholders
  final List<Indicator<dynamic>> _indicators = [];

  IndicatorEngine(this.config, this._events);

  /// Broadcast stream of latest snapshots. Emits whenever the latest snapshot updates.
  Stream<IndicatorSnapshot?> get snapshots => _snapshotController.stream;

  /// Latest cached snapshot (may be null until first completed candle is processed).
  IndicatorSnapshot? get latestSnapshot => _latest;

  /// Start listening to candle events. Calling start() multiple times is a no-op.
  void start() {
    if (_sub != null) return;
    _sub = _events.listen(_onEvent, onError: (e) {
      // emit error snapshot? currently notify via controller with null or keep last
    });
  }

  /// Stop listening and free resources.
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> dispose() async {
    await stop();
    await _snapshotController.close();
  }

  void _onEvent(CandleEvent ev) {
    if (ev.type != CandleEventType.completed) return; // only completed
    final c = ev.candle;
    if (c == null) return;

    // For now we do not perform calculations; we only update the candleTime
    // and push an empty snapshot. Indicator implementations will update
    // incremental values via update().
    _latest = IndicatorSnapshot(candleTime: c.start);
    _snapshotController.add(_latest);

    // Call update on indicators with the completed candle (incremental updates)
    for (final ind in _indicators) {
      try {
        ind.update(c);
      } catch (_) {
        // swallow for now; individual indicators should handle their own errors
      }
    }
  }

  /// Register an indicator instance to be updated by the engine. Indicators
  /// should be created elsewhere and passed in. Order of registration matters
  /// if indicators depend on each other.
  void registerIndicator(Indicator<dynamic> indicator) {
    _indicators.add(indicator);
  }
}
