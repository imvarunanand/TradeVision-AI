// lib/features/market/domain/repositories/market_repository.dart

import '../entities/market_tick.dart';

abstract class MarketRepository {
  /// Stream of market ticks for the given symbol (e.g. "EUR/USD").
  Stream<MarketTick> ticks(String symbol);

  /// Dispose any internal resources.
  Future<void> dispose();
}
