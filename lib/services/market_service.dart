import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../models/market_data.dart';

class MarketService {
  final Dio _dio = DioClient.instance;

  // For now return dummy data. Replace with real endpoints later.
  Future<MarketData> fetchMarket(String pair) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Dummy fluctuating data
    final now = DateTime.now();
    return MarketData(
      pair: pair,
      price: 1.0945,
      trend: 'Up',
      signal: 'Buy',
      confidence: 78.4,
      connected: true,
      lastUpdate: now,
    );
  }
}
