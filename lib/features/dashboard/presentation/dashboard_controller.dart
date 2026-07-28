import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/market_data.dart';
import '../../services/market_service.dart';

final marketServiceProvider = Provider((ref) => MarketService());

final eurusdProvider = StateNotifierProvider<EurUsdController, MarketData>((ref) {
  final service = ref.read(marketServiceProvider);
  return EurUsdController(service);
});

class EurUsdController extends StateNotifier<MarketData> {
  final MarketService _service;

  EurUsdController(this._service)
      : super(MarketData(pair: 'EUR/USD', price: 1.0000, trend: 'Sideways', signal: 'Hold', confidence: 50.0, connected: false, lastUpdate: DateTime.now()));

  Future<void> refresh() async {
    final data = await _service.fetchMarket('EUR/USD');
    state = data;
  }
}
