// test/test_utils/synthetic_candle_generator.dart

import 'dart:math';

import 'package:tradevision_ai/features/market/domain/entities/candle.dart';

/// Generates deterministic synthetic candle series for tests.
///
/// Modes:
/// - uptrend: positive slope
/// - downtrend: negative slope
/// - sideways: zero slope
/// - high volatility: larger random variation
class SyntheticCandleGenerator {
  final int seed;
  final double startPrice;
  final int timeframeMinutes;
  final double volatility; // standard deviation-like scale
  final double trendSlope; // additive per candle

  SyntheticCandleGenerator({
    this.seed = 42,
    this.startPrice = 100.0,
    this.timeframeMinutes = 1,
    this.volatility = 0.5,
    this.trendSlope = 0.0,
  });

  /// Generate [count] candles deterministically.
  List<Candle> generate(int count) {
    final rng = Random(seed);
    final List<Candle> out = [];
    double lastClose = startPrice;

    DateTime t = DateTime.utc(2020, 1, 1, 0, 0);

    for (int i = 0; i < count; i++) {
      // Gaussian noise via Box-Muller
      final u1 = rng.nextDouble();
      final u2 = rng.nextDouble();
      final z0 = sqrt(-2.0 * log(u1 + 1e-12)) * cos(2 * pi * u2);
      final noise = z0 * volatility;

      final close = (lastClose + trendSlope + noise).clamp(0.0001, double.infinity);
      // simulate intrabar range
      final wiggle = (rng.nextDouble() - 0.5) * volatility * 2.0;
      final open = lastClose;
      final high = (max(open, close) + wiggle.abs()).clamp(0.0001, double.infinity);
      final low = (min(open, close) - wiggle.abs()).clamp(0.0001, double.infinity);

      final candle = Candle(
        symbol: 'SYN',
        timeframeMinutes: timeframeMinutes,
        start: t,
        end: t.add(Duration(minutes: timeframeMinutes)),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: 0,
      );

      out.add(candle);
      lastClose = close;
      t = t.add(Duration(minutes: timeframeMinutes));
    }

    return out;
  }
}
