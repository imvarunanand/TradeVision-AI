import 'package:flutter/material.dart';

class MarketTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const MarketTile({super.key, required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: trailing,
    );
  }
}
