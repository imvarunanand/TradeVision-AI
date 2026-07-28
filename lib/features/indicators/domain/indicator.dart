// lib/features/indicators/domain/indicator.dart

import '../../market/domain/entities/candle.dart';

/// Generic indicator interface.
///
/// - [calculate] is intended for a full-history calculation (e.g., on first
///   load) and may be used in tests.
/// - [update] is called when a new completed candle arrives and must update
///   internal incremental state without recalculating the entire history.
abstract class Indicator<T> {
  /// Calculate the indicator value from an iterable of candles (chronological order).
  T calculate(Iterable<Candle> candles);

  /// Incrementally update internal state using only the newly completed candle.
  /// Implementations MUST NOT recalculate the entire history.
  void update(Candle completedCandle);
}
