// test/features/indicators/ema_indicator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:tradevision_ai/features/indicators/domain/ema_indicator.dart';
import 'package:tradevision_ai/features/market/domain/entities/candle.dart';
import '../test_utils/synthetic_candle_generator.dart';

Candle _c(double close, int idx) => Candle(
      symbol: 'SYM',
      timeframeMinutes: 1,
      start: DateTime.utc(2020, 1, 1, 0, idx),
      end: DateTime.utc(2020, 1, 1, 0, idx + 1),
      open: close,
      high: close,
      low: close,
      close: close,
      volume: 0,
    );

void main() {
  group('EMAIndicator', () {
    test('insufficient history returns NaN', () {
      final ema = EMAIndicator(period: 5);
      final hist = List.generate(3, (i) => _c(1.0 + i, i));
      final r = ema.calculate(hist);
      expect(r.isNaN, true);
    });

    test('SMA warm-up is correct', () {
      final period = 4;
      final ema = EMAIndicator(period: period);
      final series = [10.0, 11.0, 12.0, 13.0];
      final candles = List.generate(series.length, (i) => _c(series[i], i));
      final seed = ema.calculate(candles);
      // seed should equal SMA of the first `period` values because there are exactly 'period' elements
      final sma = series.reduce((a, b) => a + b) / series.length;
      expect(seed, closeTo(sma, 1e-12));
    });

    test('incremental update equals full recalculation', () {
      final period = 3;
      final series = [10.0, 11.0, 12.0, 13.0, 14.0];
      final candles = List.generate(series.length, (i) => _c(series[i], i));

      final full = EMAIndicator(period: period);
      final fullRes = full.calculate(candles);
      expect(fullRes.isFinite, true);

      final inc = EMAIndicator(period: period);
      final seedRes = inc.calculate(candles.sublist(0, period));
      expect(seedRes.isFinite, true);
      for (var i = period; i < candles.length; i++) {
        inc.update(candles[i]);
      }
      expect(inc.value, isNotNull);
      expect((inc.value! - fullRes).abs() < 1e-9, true);
    });

    test('EMA20 and EMA50 expected values on deterministic series', () {
      final gen = SyntheticCandleGenerator(seed: 123, startPrice: 100.0, trendSlope: 0.2, volatility: 0.3);
      final candles = gen.generate(200);

      final ema20 = EMA20Indicator();
      final ema50 = EMA50Indicator();

      final r20 = ema20.calculate(candles);
      final r50 = ema50.calculate(candles);

      expect(r20.isFinite, true);
      expect(r50.isFinite, true);

      // Also compute manual EMA for verification
      double manualEma(List<double> closes, int period) {
        if (closes.length < period) return double.nan;
        double sum = 0.0;
        for (var i = 0; i < period; i++) sum += closes[i];
        double ema = sum / period;
        final mult = 2.0 / (period + 1);
        for (var i = period; i < closes.length; i++) {
          ema = (closes[i] - ema) * mult + ema;
        }
        return ema;
      }

      final closes = candles.map((c) => c.close).toList(growable: false);
      final manual20 = manualEma(closes, 20);
      final manual50 = manualEma(closes, 50);

      expect((r20 - manual20).abs() < 1e-9, true);
      expect((r50 - manual50).abs() < 1e-9, true);
    });

    test('reset clears internal state', () {
      final ema = EMAIndicator(period: 3);
      final candles = List.generate(3, (i) => _c(10.0 + i, i));
      final r = ema.calculate(candles);
      expect(r.isFinite, true);
      ema.reset();
      expect(ema.value, null);
      // after reset, insufficient history should produce NaN
      final r2 = ema.calculate(candles.sublist(0, 2));
      expect(r2.isNaN, true);
    });
  });
}
