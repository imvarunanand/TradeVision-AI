// lib/features/indicators/providers/indicator_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../market/services/candle_builder.dart';
import '../services/indicator_engine.dart';
import '../domain/indicator_snapshot.dart';

/// Provider.family that creates an IndicatorEngine for a given CandleBuilderConfig.
/// The engine is constructed and can be started explicitly via engine.start().
final indicatorEngineProvider = Provider.family<IndicatorEngine, CandleBuilderConfig>((ref, cfg) {
  final builder = ref.read(candleBuilderProvider(cfg));
  // IndicatorEngine expects the CandleBuilder instance
  final engine = IndicatorEngine(builder);
  ref.onDispose(() => engine.dispose());
  return engine;
});

/// StreamProvider.family to observe latest snapshots from an engine.
final indicatorSnapshotProvider = StreamProvider.family<IndicatorSnapshot?, CandleBuilderConfig>((ref, cfg) {
  final engine = ref.read(indicatorEngineProvider(cfg));
  engine.start(); // auto-start engine listening; does NOT start CandleBuilder
  return engine.snapshots;
});

/// Synchronous provider to get the latest cached snapshot (may be null)
final latestIndicatorSnapshotProvider = Provider.family<IndicatorSnapshot?, CandleBuilderConfig>((ref, cfg) {
  final engine = ref.read(indicatorEngineProvider(cfg));
  return engine.latestSnapshot;
});
