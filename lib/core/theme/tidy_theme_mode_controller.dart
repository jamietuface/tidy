import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-selectable theme preference. `system` defers to the OS.
enum TidyThemePreference { system, light, dark }

extension TidyThemePreferenceX on TidyThemePreference {
  ThemeMode get materialMode {
    switch (this) {
      case TidyThemePreference.system:
        return ThemeMode.system;
      case TidyThemePreference.light:
        return ThemeMode.light;
      case TidyThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  String get storageValue {
    switch (this) {
      case TidyThemePreference.system:
        return 'system';
      case TidyThemePreference.light:
        return 'light';
      case TidyThemePreference.dark:
        return 'dark';
    }
  }

  String get displayLabel {
    switch (this) {
      case TidyThemePreference.system:
        return 'Use System';
      case TidyThemePreference.light:
        return 'Light';
      case TidyThemePreference.dark:
        return 'Dark';
    }
  }

  static TidyThemePreference fromStorage(String? raw) {
    switch (raw) {
      case 'light':
        return TidyThemePreference.light;
      case 'dark':
        return TidyThemePreference.dark;
      case 'system':
      default:
        return TidyThemePreference.system;
    }
  }
}

const _kThemePrefKey = 'tidy.themeMode';

/// Persists the user's theme choice via SharedPreferences. Defaults to
/// system. Writes happen synchronously after the in-memory value updates
/// so the UI feels instant; failures are swallowed (theme still applies
/// for the session).
class TidyThemeModeController extends StateNotifier<TidyThemePreference> {
  TidyThemeModeController() : super(TidyThemePreference.system) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = TidyThemePreferenceX.fromStorage(prefs.getString(_kThemePrefKey));
    } catch (_) {
      // First launch / unavailable storage — keep default.
    }
  }

  Future<void> set(TidyThemePreference pref) async {
    if (pref == state) return;
    state = pref;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemePrefKey, pref.storageValue);
    } catch (_) {
      // Persistence failure shouldn't undo the in-memory choice.
    }
  }
}

final tidyThemeModeControllerProvider =
    StateNotifierProvider<TidyThemeModeController, TidyThemePreference>(
  (ref) => TidyThemeModeController(),
);
