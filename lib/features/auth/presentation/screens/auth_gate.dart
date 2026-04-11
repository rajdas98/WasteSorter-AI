import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wastesorter/features/auth/presentation/screens/login_screen.dart';
import 'package:wastesorter/features/tabs/presentation/screens/tab_container.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    return authState.when(
      data: (user) => user == null ? const LoginScreen() : const TabContainer(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Scaffold(
        body: Center(child: Text('Auth initialization failed')),
      ),
    );
  }
}
