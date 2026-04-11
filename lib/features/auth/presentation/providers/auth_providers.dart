import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/auth/data/services/auth_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((Ref ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((Ref ref) {
  return AuthService(ref.read(firebaseAuthProvider));
});

final authStateChangesProvider = StreamProvider<User?>((Ref ref) {
  return ref.read(authServiceProvider).authStateChanges();
});
