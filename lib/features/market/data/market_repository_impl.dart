// lib/features/market/data/market_repository_impl.dart

import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../domain/entities/market_tick.dart';
import '../../domain/repositories/market_repository.dart';
import 'models/market_tick_dto.dart';

class MarketRepositoryImpl implements MarketRepository {
  final Dio _dio;
  Timer? _timer;
  final _controller = StreamController<MarketTick>.broadcast();
  bool _running = false;

  MarketRepositoryImpl(this._dio);

  @override
  Stream<MarketTick> ticks(String symbol) {
    // If already running, just return the existing stream
    if (!_running) {
      _running = true;
      _startPolling(symbol);
    }
    return _controller.stream;
  }

  void _startPolling(String symbol) {
    final parts = symbol.split('/');
    final base = parts.first;
    final quote = parts.length > 1 ? parts[1] : 'USD';
    final rng = Random();

    // Immediately fetch once, then every second
    Future<void> doFetch() async {
      try {
        final url = 'https://api.exchangerate.host/latest';
        final resp = await _dio.get(url, queryParameters: {'base': base, 'symbols': quote});
        if (resp.statusCode == 200 && resp.data != null) {
          final dto = MarketTickDto.fromExchangerateHost(resp.data as Map<String, dynamic>, quote);
          // dynamic tiny spread so bid != ask and values vary a bit
          final spread = 0.0001 + rng.nextDouble() * 0.0001; // 0.0001 - 0.0002
          final tick = dto.toDomain(symbol, spread: spread);
          _controller.add(tick.copyWith(status: ConnectionStatus.connected));
        } else {
          _controller.add(MarketTick(
            symbol: symbol,
            bid: 0.0,
            ask: 0.0,
            timestamp: DateTime.now(),
            status: ConnectionStatus.disconnected,
          ));
        }
      } catch (e) {
        // Emit a disconnected tick and continue polling
        _controller.add(MarketTick(
          symbol: symbol,
          bid: 0.0,
          ask: 0.0,
          timestamp: DateTime.now(),
          status: ConnectionStatus.disconnected,
        ));
      }
    }

    // Start immediate fetch
    doFetch();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await doFetch();
    });
  }

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    if (!_controller.isClosed) await _controller.close();
    _running = false;
  }
}
