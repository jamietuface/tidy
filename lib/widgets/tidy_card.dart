import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/theme/tidy_radius.dart';
import '../core/theme/tidy_shadows.dart';

/// Glossy Apple-style card with a top-edge highlight sheen.
class TidyCard extends StatelessWidget {
  const TidyCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext = Theme.of(context).extension<TidyThemeExtension>()!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ext.cardBackground,
        borderRadius: BorderRadius.circular(TidyRadius.md),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
        boxShadow: isDark ? TidyShadows.none : TidyShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TidyRadius.md - 0.5),
        child: Stack(
          children: [
            padding != null
                ? Padding(padding: padding!, child: child)
                : child,
            // Glossy top-edge highlight — simulates reflected light
            Positioned(
              top: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.1 : 0.9),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
