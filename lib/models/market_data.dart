class MarketData {
  final String pair;
  final double price;
  final String trend; // e.g., "Up" / "Down" / "Sideways"
  final String signal; // e.g., "Buy" / "Sell" / "Hold"
  final double confidence; // 0-100
  final bool connected;
  final DateTime lastUpdate;

  MarketData({
    required this.pair,
    required this.price,
    required this.trend,
    required this.signal,
    required this.confidence,
    required this.connected,
    required this.lastUpdate,
  });

  MarketData copyWith({
    double? price,
    String? trend,
    String? signal,
    double? confidence,
    bool? connected,
    DateTime? lastUpdate,
  }) {
    return MarketData(
      pair: pair,
      price: price ?? this.price,
      trend: trend ?? this.trend,
      signal: signal ?? this.signal,
      confidence: confidence ?? this.confidence,
      connected: connected ?? this.connected,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
