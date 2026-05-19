import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/active_tab_provider.dart';
import '../core/theme/tidy_brand_palette.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'subscriptions_screen.dart';
import 'swipe_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final tab = ref.watch(activeHomeTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Dashboard wants a soft surface, not pure black; mirror that on the
    // shell so there's no harsh edge behind any tab.
    final shellBg = isDark ? const Color(0xFF05070B) : brand.background;

    return Scaffold(
      backgroundColor: shellBg,
      body: IndexedStack(
        index: tab.index,
        children: const [
          DashboardScreen(),
          SwipeScreen(),
          SubscriptionsScreen(),
          SettingsScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: _HomeBottomNavBar(
        selected: tab,
        onTap: (t) =>
            ref.read(activeHomeTabProvider.notifier).state = t,
      ),
    );
  }
}

/// Bottom navigation bar — 4 tabs, theme-aware.
/// Selected: gradient blue→indigo icon with brand-blue label.
/// Unselected: muted text colour from the brand palette.
class _HomeBottomNavBar extends StatelessWidget {
  const _HomeBottomNavBar({required this.selected, required this.onTap});

  final HomeTab selected;
  final ValueChanged<HomeTab> onTap;

  // (outlined, filled, label, tab)
  static const _items = <(IconData, IconData, String, HomeTab)>[
    (CupertinoIcons.house, CupertinoIcons.house_fill, 'Home', HomeTab.home),
    (CupertinoIcons.photo, CupertinoIcons.photo_fill, 'Photos', HomeTab.photos),
    (CupertinoIcons.square_grid_2x2, CupertinoIcons.square_grid_2x2_fill,
        'Apps', HomeTab.apps),
    (CupertinoIcons.gear, CupertinoIcons.gear_solid, 'Settings',
        HomeTab.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : brand.surface;
    final topBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : brand.cardBorderSubtle;
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : brand.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: topBorderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: _items.map((item) {
              final (icon, iconFilled, label, tab) = item;
              final isSelected = tab == selected;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(tab),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Plain Icon — no AnimatedSwitcher / no ShaderMask.
                      // The earlier ShaderMask+AnimatedSwitcher combo was
                      // triggering '!semantics.parentDataDirty' asserts.
                      Icon(
                        isSelected ? iconFilled : icon,
                        size: 24,
                        color: isSelected
                            ? AppColors.systemBlue
                            : unselectedColor,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: -0.1,
                          color: isSelected
                              ? AppColors.systemBlue
                              : unselectedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
