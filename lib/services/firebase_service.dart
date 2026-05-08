import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';

/// Initialises Firebase. Catches both `FirebaseException` (native config
/// missing) and `UnimplementedError` (firebase_options stub still in place)
/// so the app still boots before `flutterfire configure` has been run.
/// Once the Firebase iOS app is created and `flutterfire configure` is run,
/// this initialises normally on the next launch.
Future<void> initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  } on FirebaseException catch (e) {
    dev.log(
      'Firebase init skipped: ${e.message ?? e.code}. '
      'Run `flutterfire configure` to enable Firebase locally.',
      name: 'firebase_service',
    );
  } on UnimplementedError catch (e) {
    dev.log(
      'Firebase options stub detected: ${e.message}',
      name: 'firebase_service',
    );
  }
}

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
