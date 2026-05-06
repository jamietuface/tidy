import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tidy_theme.dart';
import '../features/you/providers/theme_preference_notifier.dart';
import 'router.dart';

class TidyApp extends ConsumerWidget {
  const TidyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Tidy',
      debugShowCheckedModeBanner: false,
      theme: TidyTheme.light(),
      darkTheme: TidyTheme.dark(),
      themeMode: ref.watch(themePreferenceProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
