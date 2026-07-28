// lib/features/market/domain/history_provider.dart

import 'package:tradevision_ai/features/market/domain/entities/candle.dart';
import 'package:tradevision_ai/features/market/domain/timeframe.dart';

/// Abstraction for loading historical candles for a symbol and timeframe.
/// Implementations can fetch from a DB, file, or remote API.
abstract class CandleHistoryProvider {
  /// Load historical candles for [symbol] and [timeframe].
  /// Return candles in chronological order (oldest first). Limit controls the
  /// maximum number of candles returned.
  Future<List<Candle>> loadHistory(String symbol, Timeframe timeframe, int limit);
}
