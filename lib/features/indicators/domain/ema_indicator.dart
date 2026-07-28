// lib/features/indicators/domain/ema_indicator.dart

import '../../market/domain/entities/candle.dart';
import 'indicator.dart';

/// Exponential Moving Average (EMA) indicator.
///
/// - Uses SMA(period) as warm-up initial value.
/// - Provides incremental updates via [update] without recalculating history.
/// - Returns double.nan from [calculate] when there is insufficient history.
class EMAIndicator implements Indicator<double> {
  final int period;
  late final double _multiplier;

  double? _ema;
  bool _initialized = false;

  EMAIndicator({required this.period}) {
    if (period <= 0) throw ArgumentError('period must be > 0');
    _multiplier = 2.0 / (period + 1);
  }

  /// Current EMA value, or null if not initialized / insufficient data.
  double? get value => _ema;

  @override
  double calculate(Iterable<Candle> candles) {
    final closes = candles.map((c) => c.close).toList(growable: false);
    if (closes.length < period) {
      _initialized = false;
      _ema = double.nan;
      return double.nan;
    }

    // Compute SMA of first 'period' closes as seed
    double sum = 0.0;
    for (var i = 0; i < period; i++) {
      final v = closes[i];
      if (v.isNaN || v.isInfinite || v < 0) {
        _initialized = false;
        _ema = double.nan;
        return double.nan;
      }
      sum += v;
    }
    double ema = sum / period; // SMA seed

    // Apply EMA for remaining values
    for (var i = period; i < closes.length; i++) {
      final close = closes[i];
      if (close.isNaN || close.isInfinite || close < 0) {
        _initialized = false;
        _ema = double.nan;
        return double.nan;
      }
      ema = (close - ema) * _multiplier + ema;
    }

    _ema = ema;
    _initialized = true;
    return ema;
  }

  @override
  void update(Candle completedCandle) {
    if (!_initialized) return; // ignore until warmed up via calculate
    final close = completedCandle.close;
    if (close.isNaN || close.isInfinite || close < 0) return;
    // EMA formula: EMA_today = (Close_today - EMA_yesterday) * multiplier + EMA_yesterday
    _ema = (close - _ema!) * _multiplier + _ema!;
  }
}

/// Thin wrappers for common lengths
class EMA20Indicator extends EMAIndicator {
  EMA20Indicator() : super(period: 20);
}

class EMA50Indicator extends EMAIndicator {
  EMA50Indicator() : super(period: 50);
}
