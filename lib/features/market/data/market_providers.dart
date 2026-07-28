// lib/features/market/data/market_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_provider.dart';
import 'market_repository_impl.dart';
import '../../domain/repositories/market_repository.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final dio = ref.read(dioProvider);
  final impl = MarketRepositoryImpl(dio);
  ref.onDispose(() {
    impl.dispose();
  });
  return impl;
});
