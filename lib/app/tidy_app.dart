import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tidy_theme.dart';
import '../core/theme/tidy_theme_mode_controller.dart';
import '../features/auth/user_repository.dart';
import '../services/auth_service.dart';
import 'router.dart';

class TidyApp extends ConsumerWidget {
  const TidyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create/update Firestore user doc whenever the signed-in user changes.
    ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
      final user = next.asData?.value;
      if (user != null) {
        ref.read(userRepositoryProvider).createOrUpdate(user);
      }
    });

    final themePref = ref.watch(tidyThemeModeControllerProvider);

    return MaterialApp.router(
      title: 'Tidy',
      debugShowCheckedModeBanner: false,
      theme: TidyTheme.light(),
      darkTheme: TidyTheme.dark(),
      themeMode: themePref.materialMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
