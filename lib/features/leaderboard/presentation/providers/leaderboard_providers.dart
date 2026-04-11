import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/profile/data/models/user_model.dart';
import 'package:wastesorter/features/profile/presentation/providers/firestore_user_providers.dart';

/// Real-time list of users ordered by [totalPoints] descending (Eco-Warriors first).
final leaderboardUsersProvider = StreamProvider<List<UserModel>>((Ref ref) {
  final FirebaseFirestore db = ref.watch(firestoreProvider);
  return db
      .collection('users')
      .orderBy('totalPoints', descending: true)
      .limit(100)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> d) {
              final Map<String, dynamic> data = d.data();
              final String uidFromData = data['uid']?.toString() ?? '';
              return UserModel.fromJson(<String, dynamic>{
                ...data,
                'uid': uidFromData.isNotEmpty ? uidFromData : d.id,
              });
            })
            .toList(),
      );
});
