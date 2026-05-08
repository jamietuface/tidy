import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/swipe/group_swipe_screen.dart';
import '../features/swipe/group_type.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/paywall_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
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
