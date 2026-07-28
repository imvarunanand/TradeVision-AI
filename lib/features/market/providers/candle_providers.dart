// lib/features/market/providers/candle_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/candle_builder.dart';
import '../domain/entities/candle.dart';

/// Provider.family that creates a [CandleBuilder] for a given [CandleBuilderConfig].
/// The provider constructs the builder but does NOT call start(); callers must
/// call builder.start() explicitly to begin processing.
final candleBuilderProvider = Provider.family<CandleBuilder, CandleBuilderConfig>((ref, cfg) {
  final builder = CandleBuilder(cfg);
  ref.onDispose(() => builder.dispose());
  return builder;
});

final completedCandlesProvider = StreamProvider.family<Candle, CandleBuilderConfig>((ref, cfg) {
  final builder = ref.read(candleBuilderProvider(cfg));
  return builder.completedCandles;
});

final currentCandleProvider = StreamProvider.family<Candle?, CandleBuilderConfig>((ref, cfg) {
  final builder = ref.read(candleBuilderProvider(cfg));
  return builder.currentCandle;
});

/// Event stream provider to react to lifecycle events (started/updated/completed/gapFilled).
final candleEventsProvider = StreamProvider.family<CandleEvent, CandleBuilderConfig>((ref, cfg) {
  final builder = ref.read(candleBuilderProvider(cfg));
  return builder.events;
});

/// Snapshot provider returning an Iterable<Candle> to avoid allocations; UI can
/// convert to List when absolutely necessary.
final latestCandlesSnapshotProvider = Provider.family<Iterable<Candle>, CandleBuilderConfig>((ref, cfg) {
  final builder = ref.read(candleBuilderProvider(cfg));
  return builder.candles;
});
