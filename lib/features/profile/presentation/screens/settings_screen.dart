import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/core/theme/theme_mode_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.updateDisplayName(_nameController.text.trim());
    if (_emailController.text.trim().isNotEmpty &&
        _emailController.text.trim() != user.email) {
      await user.verifyBeforeUpdateEmail(_emailController.text.trim());
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _saveProfile,
            child: const Text('Save Profile'),
          ),
          const Divider(height: 30),
          SwitchListTile(
            title: const Text('App Theme'),
            subtitle: const Text('Toggle Light/Dark mode'),
            value: themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              ref.read(appThemeModeProvider.notifier).state =
                  value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(height: 30),
          const Text(
            'Privacy Policy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'WasteSorter AI respects your data. Scans are stored locally for activity and gamification.',
          ),
          const SizedBox(height: 14),
          const Text(
            'FAQs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const ExpansionTile(
            title: Text('How to earn points?'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12),
                child: Text('You earn 10 points for each successful waste scan.'),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('What can I scan?'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'You can scan common waste like plastic, paper, metal, glass, and organic items.',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('How is waste KG calculated?'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12),
                child: Text('Each item contributes 0.1kg to your impact counter.'),
              ),
            ],
          ),
          const Divider(height: 30),
          const Text(
            'Terms of Service',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'By using WasteSorter AI, you agree to responsible usage of AI-based sorting suggestions.',
          ),
          const SizedBox(height: 14),
          const Text(
            'About the App',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'WasteSorter AI helps households classify waste and build sustainable habits with gamification.',
          ),
        ],
      ),
    );
  }
}
