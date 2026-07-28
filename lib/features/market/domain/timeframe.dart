// lib/features/market/domain/timeframe.dart

enum Timeframe {
  m1,
  m5,
  m15,
}

extension TimeframeExt on Timeframe {
  int get minutes {
    switch (this) {
      case Timeframe.m1:
        return 1;
      case Timeframe.m5:
        return 5;
      case Timeframe.m15:
        return 15;
    }
  }

  String get name {
    switch (this) {
      case Timeframe.m1:
        return '1m';
      case Timeframe.m5:
        return '5m';
      case Timeframe.m15:
        return '15m';
    }
  }
}
