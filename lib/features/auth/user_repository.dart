import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';

class UserRepository {
  UserRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Future<void> createOrUpdate(User user) async {
    await _firestore.doc('users/${user.uid}').set(
      {
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'plan': 'free',
        'isAnonymous': user.isAnonymous,
        'displayName': user.displayName,
        'email': user.email,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setPlan(String uid, String plan, {String? billing}) async {
    await _firestore.doc('users/$uid').set(
      {
        'plan': plan,
        if (billing != null) 'billing': billing,
        'planUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
);

/// Streams the signed-in user's `users/{uid}` document. Returns null while
/// not signed in. Used for plan-gating (free vs pro).
final userProfileProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
  final auth = ref.watch(authStateProvider);
  final user = auth.asData?.value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .doc('users/${user.uid}')
      .snapshots()
      .map((s) => s.data());
});

final isProProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).asData?.value;
  return profile?['plan'] == 'pro';
});
