/// lib/features/market/domain/tick_source.dart
///
/// Abstraction for any tick stream provider. CandleBuilder depends on this
/// interface instead of a concrete MarketRepository so that different sources
/// (HTTP poller, WebSocket, mocks) can be used interchangeably.

import 'package:tradevision_ai/features/market/domain/entities/market_tick.dart';

abstract class TickSource {
  /// Returns a broadcastable stream of MarketTick for the given symbol.
  Stream<MarketTick> stream(String symbol);
}
