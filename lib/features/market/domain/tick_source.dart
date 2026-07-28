/// lib/features/market/domain/tick_source.dart
///
/// Abstraction for any tick stream provider. CandleBuilder depends on this
/// interface instead of a concrete MarketRepository so that different sources
/// (HTTP poller, WebSocket, mocks) can be used interchangeably.
///
/// The returned stream MUST be a broadcast stream that is reusable by multiple
/// independent consumers.

import 'entities/market_tick.dart';

abstract class TickSource {
  /// Subscribe to ticks for the given symbol.
  ///
  /// The returned [Stream] should be a broadcast stream and be safe for
  /// multiple listeners. Implementations MUST not close the stream on the
  /// first subscriber's cancellation; the stream should remain available for
  /// future subscribers.
  Stream<MarketTick> subscribe(String symbol);
}
