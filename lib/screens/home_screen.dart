import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tidy_brand_palette.dart';
import '../theme/app_theme.dart';
import 'subscriptions_screen.dart';
import 'swipe_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Scaffold(
      backgroundColor: brand.background,
      body: IndexedStack(
        index: _tab,
        children: const [SwipeScreen(), SubscriptionsScreen()],
      ),
      bottomNavigationBar: _MetallicNavBar(
        selectedIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

/// Bottom navigation bar — adapts to theme.
/// Selected: gradient blue→indigo with brand-blue label.
/// Unselected: muted text colour from the brand palette.
class _MetallicNavBar extends StatelessWidget {
  const _MetallicNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (CupertinoIcons.photo, CupertinoIcons.photo_fill, 'Photos'),
    (CupertinoIcons.app, CupertinoIcons.app_fill, 'Apps'),
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
            children: _items.asMap().entries.map((e) {
              final index = e.key;
              final (icon, iconFilled, label) = e.value;
              final selected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => selected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF007AFF),
                                  Color(0xFF5856D6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds)
                            : LinearGradient(
                                colors: [unselectedColor, unselectedColor],
                              ).createShader(bounds),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            selected ? iconFilled : icon,
                            key: ValueKey(selected),
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: -0.1,
                          color: selected ? AppColors.systemBlue : unselectedColor,
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
