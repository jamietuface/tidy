import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/sign_in_screen.dart';
import '../features/swipe/group_swipe_screen.dart';
import '../features/swipe/group_type.dart';
import '../screens/brand_preview_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/settings_screen.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      // Onboarding always takes precedence — don't gate it on auth.
      if (state.matchedLocation == '/onboarding') return null;

      final authState = ref.read(authStateProvider);
      final user = authState.asData?.value;
      // While auth state is loading or errored (e.g. Firebase not configured
      // yet), let the user through — gating would lock them out forever.
      final loadingOrError = authState.isLoading || authState.hasError;
      final atSignIn = state.matchedLocation == '/sign-in';

      if (user == null && !atSignIn && !loadingOrError) {
        return '/sign-in';
      }
      if (user != null && atSignIn) {
        return '/';
      }
      return null;
    },
    refreshListenable: _AuthListenable(ref),
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/brand-preview',
        name: 'brandPreview',
        builder: (context, state) => const BrandPreviewScreen(),
      ),
      GoRoute(
        path: '/swipe/group',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return GroupSwipeScreen(
            type: extra['type'] as GroupType,
            photoCount: extra['count'] as int,
          );
        },
      ),
    ],
  );
});

/// Bridges Riverpod's auth stream into go_router's refresh listenable so
/// the redirect re-runs whenever the user signs in or out.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _sub = _ref.listen<AsyncValue>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
