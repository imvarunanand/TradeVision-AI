// lib/core/network/dio_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // Optional: add simple logging interceptor in debug builds
  // ignore: unnecessary_statements
  dio.interceptors; // placeholder if you want to add interceptors later

  return dio;
});
