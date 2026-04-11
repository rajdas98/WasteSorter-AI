import 'package:flutter/material.dart';

class BadgesAllScreen extends StatelessWidget {
  const BadgesAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: const <Widget>[
          _BadgeTile(title: 'First Scan', unlocked: true),
          _BadgeTile(title: '20 Scans', unlocked: true),
          _BadgeTile(title: '50 Scans', unlocked: false),
          _BadgeTile(title: '100 Scans', unlocked: false),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.title, required this.unlocked});

  final String title;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFE7FFF3) : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            unlocked ? Icons.emoji_events : Icons.lock_outline,
            size: 34,
            color: unlocked ? const Color(0xFF169A6F) : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}
