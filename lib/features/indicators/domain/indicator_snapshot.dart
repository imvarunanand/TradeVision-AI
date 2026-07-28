// lib/features/indicators/domain/indicator_snapshot.dart

import '../../market/domain/entities/candle.dart';

/// Snapshot of the latest indicator values for a candle.
class IndicatorSnapshot {
  /// The candle start time (UTC) that these indicators correspond to.
  final DateTime candleTime;

  final double? ema20;
  final double? ema50;

  final double? bollingerUpper;
  final double? bollingerMiddle;
  final double? bollingerLower;

  final double? rsi;

  final double? stochasticK;
  final double? stochasticD;

  final double? atr;

  const IndicatorSnapshot({
    required this.candleTime,
    this.ema20,
    this.ema50,
    this.bollingerUpper,
    this.bollingerMiddle,
    this.bollingerLower,
    this.rsi,
    this.stochasticK,
    this.stochasticD,
    this.atr,
  });

  IndicatorSnapshot copyWith({
    DateTime? candleTime,
    double? ema20,
    double? ema50,
    double? bollingerUpper,
    double? bollingerMiddle,
    double? bollingerLower,
    double? rsi,
    double? stochasticK,
    double? stochasticD,
    double? atr,
  }) {
    return IndicatorSnapshot(
      candleTime: candleTime ?? this.candleTime,
      ema20: ema20 ?? this.ema20,
      ema50: ema50 ?? this.ema50,
      bollingerUpper: bollingerUpper ?? this.bollingerUpper,
      bollingerMiddle: bollingerMiddle ?? this.bollingerMiddle,
      bollingerLower: bollingerLower ?? this.bollingerLower,
      rsi: rsi ?? this.rsi,
      stochasticK: stochasticK ?? this.stochasticK,
      stochasticD: stochasticD ?? this.stochasticD,
      atr: atr ?? this.atr,
    );
  }

  @override
  String toString() {
    return 'IndicatorSnapshot(candleTime: $candleTime, ema20: $ema20, ema50: $ema50, bollU: $bollingerUpper, bollM: $bollingerMiddle, bollL: $bollingerLower, rsi: $rsi, stoK: $stochasticK, stoD: $stochasticD, atr: $atr)';
  }
}
