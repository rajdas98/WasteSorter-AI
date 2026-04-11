import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wastesorter/features/profile/data/models/scan_record.dart';
import 'package:wastesorter/features/profile/data/models/user_model.dart';
import 'package:wastesorter/features/profile/data/services/firestore_user_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((Ref ref) {
  return FirebaseFirestore.instance;
});

final firestoreUserServiceProvider = Provider<FirestoreUserService>((Ref ref) {
  return FirestoreUserService(ref.read(firestoreProvider));
});

final currentUserProfileProvider = StreamProvider<UserModel?>((Ref ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  return authAsync.when(
    data: (user) {
      if (user == null) {
        return Stream<UserModel?>.value(null);
      }
      return ref.read(firestoreUserServiceProvider).watchUserProfile(user.uid);
    },
    loading: () => Stream<UserModel?>.value(null),
    error: (_, _) => Stream<UserModel?>.value(null),
  );
});

final currentUserScansProvider = StreamProvider<List<ScanRecord>>((Ref ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  return authAsync.when(
    data: (user) {
      if (user == null) {
        return Stream<List<ScanRecord>>.value(const <ScanRecord>[]);
      }
      return ref.read(firestoreUserServiceProvider).watchRecentScans(user.uid);
    },
    loading: () => Stream<List<ScanRecord>>.value(const <ScanRecord>[]),
    error: (_, _) => Stream<List<ScanRecord>>.value(const <ScanRecord>[]),
  );
});
