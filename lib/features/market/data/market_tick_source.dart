// lib/features/market/data/market_tick_source.dart

import '../../domain/entities/market_tick.dart';
import '../../domain/tick_source.dart';
import '../../domain/repositories/market_repository.dart';

/// Adapter that allows using an existing [MarketRepository] as a [TickSource].
/// The adapter simply delegates to [MarketRepository.ticks] and returns its
/// broadcast stream.
class MarketRepositoryTickSource implements TickSource {
  final MarketRepository _repo;
  MarketRepositoryTickSource(this._repo);

  @override
  Stream<MarketTick> subscribe(String symbol) => _repo.ticks(symbol);
}
