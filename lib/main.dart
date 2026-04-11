import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wastesorter/core/theme/app_theme.dart';
import 'package:wastesorter/core/theme/theme_mode_provider.dart';
import 'package:wastesorter/features/auth/presentation/screens/auth_gate.dart';
import 'package:wastesorter/features/waste_sorting/presentation/providers/waste_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await _initializeFirebase();
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBeY-CIYElJgLe0BnWOeVN_pATLsJa6-Vs',
          authDomain: 'wastesorterai-f579f.firebaseapp.com',
          projectId: 'wastesorterai-f579f',
          storageBucket: 'wastesorterai-f579f.firebasestorage.app',
          messagingSenderId: '414194014115',
          appId: '1:414194014115:web:1dd5372e0fc6f8ea162c16',
        ),
      );
      return;
    }

    // Android/iOS/macOS/Windows: use `google-services.json` / `GoogleService-Info.plist` / native options.
    await Firebase.initializeApp();
  } catch (e, st) {
    debugPrint('[Firebase] initializeApp failed: $e');
    debugPrint('$st');
    rethrow;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    return MaterialApp(
      title: 'WasteSorter AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}