import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/profile/data/models/user_model.dart';
import 'package:wastesorter/features/profile/presentation/providers/firestore_user_providers.dart';
import 'package:wastesorter/features/waste_sorting/presentation/providers/waste_providers.dart';
import 'package:wastesorter/features/waste_sorting/presentation/screens/camera_screen.dart';
import 'package:wastesorter/features/waste_sorting/presentation/screens/result_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final fallbackName = FirebaseAuth.instance.currentUser?.displayName ?? 'Eco Hero';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1B5E20), Color(0xFFA5D6A7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: statsAsync.when(
              data: (stats) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Namaste, ${_nameFromProfile(profileAsync, fallbackName)}! 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your eco dashboard',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _StatCard(
                            title: 'Points',
                            value: '${_pointsFromProfile(profileAsync, stats.totalPoints)}',
                            icon: Icons.workspace_premium,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            title: 'Waste Diverted',
                            value: '${stats.wasteKg.toStringAsFixed(1)} kg',
                            icon: Icons.eco_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _GradientActionButton(
                      label: 'Take a Photo',
                      icon: Icons.camera_alt_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CameraScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _GradientActionButton(
                      label: 'Upload From Gallery',
                      icon: Icons.image_outlined,
                      onTap: () => _pickFromGallery(context),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(child: Text('Failed to load dashboard')),
            ),
          ),
        ),
      ),
    );
  }

  int _pointsFromProfile(AsyncValue<UserModel?> profileAsync, int fallbackPoints) {
    return profileAsync.maybeWhen(
      data: (user) => user?.totalPoints ?? fallbackPoints,
      orElse: () => fallbackPoints,
    );
  }

  String _nameFromProfile(AsyncValue<UserModel?> profileAsync, String fallbackName) {
    return profileAsync.maybeWhen(
      data: (user) => (user?.displayName.isNotEmpty ?? false)
          ? user!.displayName
          : fallbackName,
      orElse: () => fallbackName,
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null || !context.mounted) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (!context.mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            imageBase64: base64Encode(bytes),
            imagePath: file.path,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload image right now.')),
      );
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: const Color(0xFF1B5E20)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(title, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF1B5E20), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
