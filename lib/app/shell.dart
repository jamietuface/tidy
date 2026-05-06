import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/tidy_theme.dart';

/// Bottom-nav scaffold around the StatefulShellRoute branches.
class TidyShell extends StatelessWidget {
  const TidyShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = context.tidyColors;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.borderSubtle, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.cottage_outlined),
              selectedIcon: Icon(Icons.cottage),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'You',
            ),
          ],
        ),
      ),
    );
  }
}
