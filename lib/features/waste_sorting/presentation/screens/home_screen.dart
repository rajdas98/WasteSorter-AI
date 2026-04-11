import 'dart:ui';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/history/scan_history_item.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/history/user_stats.dart';
import 'package:wastesorter/features/waste_sorting/presentation/providers/waste_providers.dart';
import 'package:wastesorter/features/waste_sorting/presentation/screens/certificate_screen.dart';
import 'package:wastesorter/features/waste_sorting/presentation/screens/camera_screen.dart';
import 'package:wastesorter/features/waste_sorting/presentation/screens/history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const String _milestoneShownKey = 'milestone_50_shown';

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserStats>>(userStatsProvider, (
      AsyncValue<UserStats>? previous,
      AsyncValue<UserStats> next,
    ) {
      next.whenData((UserStats stats) {
        _maybeShowMilestoneDialog(stats);
      });
    });

    final statsAsync = ref.watch(userStatsProvider);
    final historyAsync = ref.watch(scanHistoryProvider);
    final authAsync = ref.watch(authStateChangesProvider);
    final String displayName = authAsync.maybeWhen(
      data: (user) => (user?.displayName == null || user!.displayName!.isEmpty)
          ? 'Eco Hero'
          : user.displayName!,
      orElse: () => 'Eco Hero',
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFD7FCEB), Color(0xFFB9F3D7), Color(0xFFEFFFF7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: statsAsync.when(
              data: (UserStats stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Namaste, $displayName 👋',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0E3D2F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Let us sort smarter today',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF225B48),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Logout',
                            icon: const Icon(Icons.logout, color: Color(0xFF0D3B2E)),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                          ),
                          GestureDetector(
                            onTap: () => _showLevelInfo(stats),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                stats.level,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0D3B2E),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(child: _WasteCounterCard(stats: stats)),
                      const SizedBox(width: 12),
                      Expanded(child: _ScoreCard(stats: stats)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _MilestoneCard(
                    stats: stats,
                    onCertificateTap: () {
                      if (stats.totalItems >= 50) {
                        _openCertificate(stats);
                        return;
                      }
                      final int remaining = 50 - stats.totalItems;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Keep sorting! You need $remaining more scans to unlock your certificate.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CameraScreen(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF169A6F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Start Scanning'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E3D2F),
                        ),
                      ),
                      TextButton(
                        onPressed: _openHistory,
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: historyAsync.when(
                      data: (List<ScanHistoryItem> scans) {
                        if (scans.isEmpty) {
                          return const Center(
                            child: Text('No activity yet. Start your first scan!'),
                          );
                        }
                        return ListView.separated(
                          itemCount: scans.length > 6 ? 6 : scans.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, int index) {
                            final item = scans[index];
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: item.imageBase64.isEmpty
                                        ? Container(
                                            width: 44,
                                            height: 44,
                                            color: const Color(0xFFE6F4ED),
                                            child: const Icon(Icons.image),
                                          )
                                        : Image.memory(
                                            base64Decode(item.imageBase64),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${item.result} Waste',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          item.timestamp
                                              .toLocal()
                                              .toString()
                                              .split('.')
                                              .first,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '+${item.pointsEarned}',
                                    style: const TextStyle(
                                      color: Color(0xFF169A6F),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const Center(child: Text('Failed to load history')),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(child: Text('Failed to load dashboard')),
            ),
          ),
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
    );
  }

  Future<void> _maybeShowMilestoneDialog(UserStats stats) async {
    if (!mounted || stats.totalItems < 50) {
      return;
    }
    final prefs = ref.read(sharedPreferencesProvider);
    final bool alreadyShown = prefs.getBool(_milestoneShownKey) ?? false;
    if (alreadyShown) {
      return;
    }
    await prefs.setBool(_milestoneShownKey, true);
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Milestone Reached!'),
            content: const Text(
              'Amazing work! You unlocked your Eco-Champion certificate.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openCertificate(stats);
                },
                child: const Text('View Certificate'),
              ),
            ],
          );
        },
      );
    });
  }

  void _openCertificate(UserStats stats) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CertificateScreen(
          userName: 'Eco Hero',
          totalKg: stats.wasteKg,
          completionDate: DateTime.now(),
        ),
      ),
    );
  }

  void _showLevelInfo(UserStats stats) {
    final int nextTargetItems = stats.totalItems < 20
        ? 20
        : stats.totalItems < 50
            ? 50
            : stats.totalItems;
    final int pointsForNextLevel = nextTargetItems * 10 - stats.totalPoints;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Current Level: ${stats.level}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pointsForNextLevel <= 0
                    ? 'You are at the top level!'
                    : 'Points needed for next level: $pointsForNextLevel',
              ),
              const SizedBox(height: 10),
              const Text('You are doing great for the planet! 🌍'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _WasteCounterCard extends StatelessWidget {
  const _WasteCounterCard({required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final double ratio = (stats.totalItems / 20).clamp(0, 1).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
          ),
          child: Column(
            children: <Widget>[
              const Text(
                "Today's Waste Counter",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 76,
                width: 76,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFCDE8DD),
                  color: const Color(0xFF169A6F),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${stats.wasteKg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0E3D2F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.workspace_premium, color: Color(0xFF186DF6)),
              SizedBox(width: 8),
              Text(
                'Your Score',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${stats.totalPoints}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E3D2F),
            ),
          ),
          Text(
            '${stats.totalItems} items sorted',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.stats,
    required this.onCertificateTap,
  });

  final UserStats stats;
  final VoidCallback onCertificateTap;

  @override
  Widget build(BuildContext context) {
    final double progress =
        (stats.currentMilestone / stats.nextMilestone).clamp(0, 1).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.verified_outlined, color: Color(0xFFCB8E00)),
              const SizedBox(width: 8),
              const Text(
                'Milestone',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                onPressed: onCertificateTap,
                icon: Icon(
                  stats.totalItems >= 50
                      ? Icons.workspace_premium
                      : Icons.lock_outline,
                  color: stats.totalItems >= 50
                      ? const Color(0xFF169A6F)
                      : Colors.black45,
                ),
                tooltip: 'Open certificate',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${stats.currentMilestone}/${stats.nextMilestone} scans',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: const Color(0xFFE4ECE8),
              color: const Color(0xFF169A6F),
            ),
          ),
        ],
      ),
    );
  }
}
