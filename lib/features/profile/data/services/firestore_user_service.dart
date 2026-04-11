import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wastesorter/features/profile/data/models/scan_record.dart';
import 'package:wastesorter/features/profile/data/models/user_model.dart';

class FirestoreUserService {
  FirestoreUserService(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> _userScans(String uid) {
    return _userDoc(uid).collection('scans');
  }

  String computeLevel(int totalPoints) {
    if (totalPoints >= 1000) {
      return 'Eco-Champion';
    }
    if (totalPoints >= 300) {
      return 'Eco-Warrior';
    }
    return 'Novice';
  }

  Future<void> ensureUserProfile({
    required String uid,
    required String displayName,
  }) async {
    try {
      final doc = _userDoc(uid);
      final snapshot = await doc.get();
      if (snapshot.exists) {
        return;
      }
      final profile = UserModel(
        uid: uid,
        displayName: displayName.isEmpty ? 'Eco Hero' : displayName,
        totalPoints: 0,
        level: computeLevel(0),
      );
      await doc.set(profile.toJson());
    } catch (e, st) {
      debugPrint('[FirestoreUserService] ensureUserProfile failed: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<void> addScanAndPoints({
    required String uid,
    required String displayName,
    required int points,
    required String category,
    required String binColor,
    String? imageUrl,
  }) async {
    final userDoc = _userDoc(uid);
    final scanDoc = _userScans(uid).doc();

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final currentPoints = snapshot.data()?['totalPoints'] is int
            ? snapshot.data()!['totalPoints'] as int
            : int.tryParse(snapshot.data()?['totalPoints']?.toString() ?? '') ?? 0;
        final updatedPoints = currentPoints + points;

        transaction.set(
          userDoc,
          <String, dynamic>{
            'uid': uid,
            'displayName': displayName.isEmpty ? 'Eco Hero' : displayName,
            'totalPoints': updatedPoints,
            'level': computeLevel(updatedPoints),
          },
          SetOptions(merge: true),
        );

        final scanRecord = ScanRecord(
          id: scanDoc.id,
          category: category,
          binColor: binColor,
          timestamp: DateTime.now(),
          imageUrl: imageUrl,
        );
        transaction.set(scanDoc, scanRecord.toJson());
      });
    } catch (e, st) {
      debugPrint('[FirestoreUserService] addScanAndPoints failed: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserModel.fromJson(snapshot.data()!);
    });
  }

  Stream<List<ScanRecord>> watchRecentScans(String uid, {int limit = 100}) {
    return _userScans(uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ScanRecord.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }
}
