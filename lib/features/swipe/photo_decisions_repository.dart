import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';

enum SwipeDecision { kept, deleted }

class DecisionStats {
  const DecisionStats({
    required this.kept,
    required this.deleted,
    required this.bytesFreed,
  });

  final int kept;
  final int deleted;
  final int bytesFreed;

  static const empty = DecisionStats(kept: 0, deleted: 0, bytesFreed: 0);

  String get spaceFreedDisplay {
    if (bytesFreed < 1024 * 1024) {
      return '${(bytesFreed / 1024).toStringAsFixed(0)} KB';
    }
    final mb = bytesFreed / (1024 * 1024);
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }
}

class PhotoDecisionsRepository {
  PhotoDecisionsRepository(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? _collection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('photo_decisions');
  }

  Future<void> record({
    required String photoId,
    required SwipeDecision decision,
    DateTime? photoCreatedAt,
    String? groupType,
    int? sizeBytes,
  }) async {
    final col = _collection();
    if (col == null) return;
    try {
      await col.doc(photoId).set({
        'photoId': photoId,
        'decision': decision.name,
        'decidedAt': FieldValue.serverTimestamp(),
        if (photoCreatedAt != null)
          'photoCreatedAt': Timestamp.fromDate(photoCreatedAt),
        if (groupType != null) 'groupType': groupType,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
      });
    } catch (e) {
      dev.log('Failed to record decision $photoId: $e',
          name: 'photo_decisions');
    }
  }

  Stream<DecisionStats> watchStats() {
    final col = _collection();
    if (col == null) return Stream.value(DecisionStats.empty);
    return col.snapshots().map((snap) {
      var kept = 0;
      var deleted = 0;
      var bytesFreed = 0;
      for (final d in snap.docs) {
        final data = d.data();
        final dec = data['decision'] as String?;
        final size = (data['sizeBytes'] as num?)?.toInt() ?? 0;
        if (dec == 'kept') kept++;
        if (dec == 'deleted') {
          deleted++;
          bytesFreed += size;
        }
      }
      return DecisionStats(
          kept: kept, deleted: deleted, bytesFreed: bytesFreed);
    });
  }

  Future<void> undo(String photoId) async {
    final col = _collection();
    if (col == null) return;
    try {
      await col.doc(photoId).delete();
    } catch (e) {
      dev.log('Failed to undo decision $photoId: $e',
          name: 'photo_decisions');
    }
  }

  /// Returns the set of photoIds the user has already decided on.
  /// Empty set if not signed in or on read failure (fail-open: show photos).
  Future<Set<String>> decidedPhotoIds() async {
    final col = _collection();
    if (col == null) return {};
    try {
      final snap = await col.get();
      return snap.docs.map((d) => d.id).toSet();
    } catch (e) {
      dev.log('Failed to read decided ids: $e', name: 'photo_decisions');
      return {};
    }
  }
}

final photoDecisionsRepositoryProvider =
    Provider<PhotoDecisionsRepository>((ref) {
  return PhotoDecisionsRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final decisionStatsProvider = StreamProvider<DecisionStats>((ref) {
  return ref.watch(photoDecisionsRepositoryProvider).watchStats();
});
