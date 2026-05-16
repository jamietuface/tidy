import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeTab { home, photos, apps, settings }

/// Lets any descendant of [HomeScreen] (e.g. dashboard CTAs) switch the
/// active bottom-nav tab without prop-drilling a callback through widgets.
final activeHomeTabProvider =
    StateProvider<HomeTab>((ref) => HomeTab.home);
