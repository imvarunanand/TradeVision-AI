import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/market_data.dart';
import '../presentation/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final market = ref.watch(eurusdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(eurusdProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(market.pair, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current Price', style: Theme.of(context).textTheme.bodyLarge),
                  Text(market.price.toStringAsFixed(5), style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 1.09),
                          FlSpot(1, 1.091),
                          FlSpot(2, 1.089),
                          FlSpot(3, 1.092),
                          FlSpot(4, 1.0945),
                        ],
                        isCurved: true,
                        color: Colors.tealAccent,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _row('Trend', market.trend),
                      const Divider(color: Colors.white12),
                      _row('Signal', market.signal),
                      const Divider(color: Colors.white12),
                      _row('Confidence %', '${market.confidence.toStringAsFixed(1)}%'),
                      const Divider(color: Colors.white12),
                      _row('Connection Status', market.connected ? 'Connected' : 'Disconnected'),
                      const Divider(color: Colors.white12),
                      _row('Last Update', market.lastUpdate.toLocal().toString()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(eurusdProvider.notifier).refresh(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(value, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
}
