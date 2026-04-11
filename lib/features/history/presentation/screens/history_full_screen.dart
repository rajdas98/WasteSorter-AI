import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/history/scan_history_item.dart';
import 'package:wastesorter/features/waste_sorting/presentation/providers/waste_providers.dart';

class HistoryFullScreen extends ConsumerWidget {
  const HistoryFullScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('History Timeline')),
      body: historyAsync.when(
        data: (List<ScanHistoryItem> scans) {
          if (scans.isEmpty) {
            return const Center(child: Text('No scans yet'));
          }
          return ListView.builder(
            itemCount: scans.length,
            itemBuilder: (_, int i) {
              final s = scans[i];
              return ListTile(
                leading: s.imageBase64.isEmpty
                    ? const CircleAvatar(child: Icon(Icons.image))
                    : CircleAvatar(
                        backgroundImage: MemoryImage(base64Decode(s.imageBase64)),
                      ),
                title: Text('${s.result} waste'),
                subtitle: Text(s.timestamp.toLocal().toString().split('.').first),
                trailing: Text('+${s.pointsEarned}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Failed to load history')),
      ),
    );
  }
}
