// lib/features/market/domain/entities/candle.dart

import 'package:flutter/foundation.dart';

@immutable
class Candle {
  final String symbol;
  final int timeframeMinutes;
  final DateTime start; // UTC-aligned start time
  final DateTime end; // exclusive end time
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume; // optional, here always 0 (ticks have no volume)

  const Candle({
    required this.symbol,
    required this.timeframeMinutes,
    required this.start,
    required this.end,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  Candle copyWith({
    String? symbol,
    int? timeframeMinutes,
    DateTime? start,
    DateTime? end,
    double? open,
    double? high,
    double? low,
    double? close,
    int? volume,
  }) {
    return Candle(
      symbol: symbol ?? this.symbol,
      timeframeMinutes: timeframeMinutes ?? this.timeframeMinutes,
      start: start ?? this.start,
      end: end ?? this.end,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  @override
  String toString() {
    return 'Candle($symbol ${timeframeMinutes}m ${start.toIso8601String()} O:$open H:$high L:$low C:$close)';
  }
}
