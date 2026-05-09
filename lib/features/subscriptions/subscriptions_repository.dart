import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import 'subscription.dart';

class SubscriptionsRepository {
  SubscriptionsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<List<Subscription>> watch(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .snapshots()
        .map((s) => s.docs.map(Subscription.fromFirestore).toList());
  }

  Future<void> add({
    required String uid,
    required String name,
    required double price,
    required String currency,
    DateTime? lastUsed,
    String? iconName,
    String? colorHex,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .add({
      'name': name,
      'price': price,
      'currency': currency,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      if (lastUsed != null) 'lastUsed': Timestamp.fromDate(lastUsed),
      if (iconName != null) 'iconName': iconName,
      if (colorHex != null) 'colorHex': colorHex,
    });
  }

  Future<void> delete({required String uid, required String id}) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .doc(id)
        .delete();
  }

  Future<void> update({
    required String uid,
    required String id,
    required String name,
    required double price,
    required String currency,
    DateTime? lastUsed,
    String? iconName,
    String? colorHex,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .doc(id)
        .set({
      'name': name,
      'price': price,
      'currency': currency,
      'updatedAt': FieldValue.serverTimestamp(),
      if (lastUsed != null) 'lastUsed': Timestamp.fromDate(lastUsed),
      if (iconName != null) 'iconName': iconName,
      if (colorHex != null) 'colorHex': colorHex,
    }, SetOptions(merge: true));
  }
}

final subscriptionsRepositoryProvider = Provider<SubscriptionsRepository>(
  (ref) => SubscriptionsRepository(ref.watch(firestoreProvider)),
);

/// Stream of the signed-in user's subscriptions. Emits an empty list while
/// not signed in (so UI shows the empty state cleanly).
final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  final auth = ref.watch(authStateProvider);
  final user = auth.asData?.value;
  if (user == null) return Stream.value(<Subscription>[]);
  return ref.watch(subscriptionsRepositoryProvider).watch(user.uid);
});
