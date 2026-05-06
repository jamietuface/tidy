/// Centralised constants for Tidy.
///
/// Firestore collection paths and other constants live here. Never hardcode
/// these values in feature code.
class AppConstants {
  const AppConstants._();

  // Firestore collections
  static const String usersCollection = 'users';
  static const String entriesSubcollection = 'entries';
  static const String settingsSubcollection = 'settings';
  static const String devicesSubcollection = 'devices';

  // Settings document
  static const String prefsDocId = 'prefs';

  // User tier values
  static const String tierFree = 'free';
  static const String tierPlus = 'plus';

  // Auth methods
  static const String authAnonymous = 'anon';
  static const String authEmail = 'email';
  static const String authApple = 'apple';
  static const String authGoogle = 'google';

  // Tags
  static const String tagTask = 'task';
  static const String tagIdea = 'idea';
  static const String tagNote = 'note';

  // Default reminder window
  static const Duration defaultReminderWindow = Duration(hours: 48);
}
