import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() => ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent,
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Colors.tealAccent,
              secondary: Colors.tealAccent,
            ),
        scaffoldBackgroundColor: const Color(0xFF0B0F12),
        useMaterial3: true,
      );
}
