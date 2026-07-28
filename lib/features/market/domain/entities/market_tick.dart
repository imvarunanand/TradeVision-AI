// lib/features/market/domain/entities/market_tick.dart

import 'package:flutter/foundation.dart';

enum ConnectionStatus { connected, disconnected }

@immutable
class MarketTick {
  final String symbol; // e.g. "EUR/USD"
  final double bid;
  final double ask;
  double get spread => (ask - bid);
  final DateTime timestamp;
  final ConnectionStatus status;

  const MarketTick({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.timestamp,
    required this.status,
  });

  // Convenience factory: build from a mid rate and an optional spread
  factory MarketTick.fromMidRate({
    required String symbol,
    required double mid,
    double spread = 0.0001,
    required DateTime timestamp,
    required ConnectionStatus status,
  }) {
    final half = spread / 2;
    return MarketTick(
      symbol: symbol,
      bid: (mid - half),
      ask: (mid + half),
      timestamp: timestamp,
      status: status,
    );
  }

  MarketTick copyWith({
    String? symbol,
    double? bid,
    double? ask,
    DateTime? timestamp,
    ConnectionStatus? status,
  }) {
    return MarketTick(
      symbol: symbol ?? this.symbol,
      bid: bid ?? this.bid,
      ask: ask ?? this.ask,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
