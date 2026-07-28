import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'core/db/app_database.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

class TradeVisionApp extends StatefulWidget {
  const TradeVisionApp({super.key});

  @override
  State<TradeVisionApp> createState() => _TradeVisionAppState();
}

class _TradeVisionAppState extends State<TradeVisionApp> {
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    NotificationService().init();
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeVision AI',
      theme: AppTheme.dark(),
      home: const MainTabs(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;
  final _pages = const [
    DashboardScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
