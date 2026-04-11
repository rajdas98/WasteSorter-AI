import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/profile/presentation/providers/firestore_user_providers.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/history/scan_history_item.dart';
import 'package:wastesorter/features/waste_sorting/domain/entities/waste_result.dart';
import 'package:wastesorter/features/waste_sorting/presentation/providers/waste_providers.dart';
import 'package:wastesorter/features/waste_sorting/presentation/screens/home_screen.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
    required this.imageBase64,
    required this.imagePath,
  });

  final String imageBase64;
  final String imagePath;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late final ConfettiController _confettiController;
  bool _isSaving = false;
  bool _savedToHistory = false;
  static const int _pointsPerScan = 10;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<WasteResult> result = ref.watch(
      aiAnalysisProvider(widget.imageBase64),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sorting Result')),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    base64Decode(widget.imageBase64),
                    fit: BoxFit.cover,
                    height: 230,
                  ),
                ),
                const SizedBox(height: 20),
                result.when(
                  data: (WasteResult data) => _ResultCard(result: data),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (Object e, StackTrace _) => _ErrorCard(
                    message: e.toString(),
                    onRetry: () {
                      _savedToHistory = false;
                      ref.invalidate(aiAnalysisProvider(widget.imageBase64));
                    },
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final wasteResult = result.valueOrNull;
                          if (wasteResult == null) {
                            return;
                          }
                          await _collectPointsAndSave(wasteResult);
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Collect Points'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final wasteResult = result.valueOrNull;
                          if (wasteResult == null) {
                            return;
                          }
                          await _collectPointsAndSave(wasteResult);
                          if (!mounted) {
                            return;
                          }
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                  child: const Text('Done'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Back to Home (Skip)'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              gravity: 0.16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _collectPointsAndSave(WasteResult value) async {
    if (_savedToHistory || _isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ref.read(firestoreUserServiceProvider).addScanAndPoints(
              uid: user.uid,
              displayName: user.displayName ?? 'Eco Hero',
              points: _pointsPerScan,
              category: value.category,
              binColor: value.binColor,
              imageUrl: widget.imagePath.isEmpty ? null : widget.imagePath,
            );
        ref.invalidate(currentUserProfileProvider);
        ref.invalidate(currentUserScansProvider);
      }

      await ref.read(saveScanUseCaseProvider)(
            ScanHistoryItem(
              imagePath: widget.imagePath,
              imageBase64: widget.imageBase64,
              result: value.category,
              timestamp: DateTime.now(),
              pointsEarned: _pointsPerScan,
            ),
          );
      ref.invalidate(scanHistoryProvider);
      ref.invalidate(sortedCountProvider);
      ref.invalidate(userStatsProvider);
      _savedToHistory = true;
      _confettiController.play();
    } catch (e, st) {
      debugPrint('[ResultScreen] save failed: $e');
      debugPrint('$st');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save scan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final WasteResult result;

  @override
  Widget build(BuildContext context) {
    final String bin = result.binColor.toLowerCase();
    final Color cardColor;
    final Color textColor;
    if (bin.contains('green')) {
      cardColor = const Color(0xFFE9FFF0);
      textColor = const Color(0xFF0D6B33);
    } else if (bin.contains('blue')) {
      cardColor = const Color(0xFFEAF4FF);
      textColor = const Color(0xFF0E4D9B);
    } else if (bin.contains('yellow')) {
      cardColor = const Color(0xFFFFF8E1);
      textColor = const Color(0xFF8A6D00);
    } else if (bin.contains('red')) {
      cardColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFB71C1C);
    } else {
      cardColor = const Color(0xFFF1F8E9);
      textColor = const Color(0xFF33691E);
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${result.category} Waste',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bin: ${result.binColor}',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI Insight',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              result.explanation,
              style: const TextStyle(fontSize: 15, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0x66FFFFFF), Color(0x88FEEEEE)],
        ),
        border: Border.all(color: const Color(0xFFFFD6D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Could not get AI result',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF8E2E2E)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF169A6F),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
