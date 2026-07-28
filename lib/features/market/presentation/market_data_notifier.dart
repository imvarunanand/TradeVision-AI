// lib/features/market/presentation/market_data_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/market_tick.dart';
import '../../domain/repositories/market_repository.dart';
import '../data/market_providers.dart';

class MarketState {
  final MarketTick? tick;
  final bool isConnected;
  final String? error;

  MarketState({this.tick, this.isConnected = false, this.error});

  MarketState copyWith({MarketTick? tick, bool? isConnected, String? error}) {
    return MarketState(
      tick: tick ?? this.tick,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
    );
  }
}

class MarketDataNotifier extends StateNotifier<AsyncValue<MarketState>> {
  final MarketRepository _repo;
  StreamSubscription<MarketTick>? _sub;

  MarketDataNotifier(this._repo) : super(const AsyncValue.loading()) {
    _start('EUR/USD');
  }

  void _start(String symbol) {
    try {
      _sub = _repo.ticks(symbol).listen((tick) {
        state = AsyncValue.data(MarketState(tick: tick, isConnected: tick.status == ConnectionStatus.connected));
      }, onError: (err, st) {
        state = AsyncValue.error(err, st);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _sub?.cancel();
    state = const AsyncValue.loading();
    _start('EUR/USD');
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final marketDataProvider = StateNotifierProvider<MarketDataNotifier, AsyncValue<MarketState>>((ref) {
  final repo = ref.read(marketRepositoryProvider);
  final notifier = MarketDataNotifier(repo);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
