// lib/features/market/data/in_memory_history_provider.dart

import '../../domain/history_provider.dart';
import '../../domain/entities/candle.dart';
import '../../domain/timeframe.dart';

/// Simple in-memory history provider useful for testing and seeding.
class InMemoryHistoryProvider implements CandleHistoryProvider {
  final Map<String, List<Candle>> _store = {};

  @override
  Future<List<Candle>> loadHistory(String symbol, Timeframe timeframe, int limit) async {
    final key = '$symbol-${timeframe.name}';
    final list = _store[key] ?? [];
    final start = (list.length - limit).clamp(0, list.length);
    return List<Candle>.from(list.sublist(start));
  }

  void seedHistory(String symbol, Timeframe timeframe, List<Candle> candles) {
    final key = '$symbol-${timeframe.name}';
    _store[key] = List<Candle>.from(candles);
  }
}
