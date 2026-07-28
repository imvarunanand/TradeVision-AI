// lib/features/market/data/models/market_tick_dto.dart

import '../../domain/entities/market_tick.dart';

class MarketTickDto {
  final double mid;
  final DateTime timestamp;

  MarketTickDto({required this.mid, required this.timestamp});

  factory MarketTickDto.fromExchangerateHost(Map<String, dynamic> json, String quote) {
    // Example response:
    // { "base":"EUR", "date":"2026-07-28", "rates": { "USD": 1.0845 } }
    final rates = json['rates'] as Map<String, dynamic>? ?? {};
    final usd = (rates[quote] as num?)?.toDouble() ?? 0.0;
    return MarketTickDto(mid: usd, timestamp: DateTime.now());
  }

  MarketTick toDomain(String symbol, {double spread = 0.0002}) {
    return MarketTick.fromMidRate(
      symbol: symbol,
      mid: mid,
      spread: spread,
      timestamp: timestamp,
      status: ConnectionStatus.connected,
    );
  }
}
