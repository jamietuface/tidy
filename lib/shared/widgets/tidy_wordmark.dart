import 'package:flutter/material.dart';

import '../../core/theme/tidy_brand_palette.dart';
import '../../core/theme/tidy_typography.dart';
import 'tidy_logo_mark.dart';

/// "TIDY" — thin, wide-tracked uppercase wordmark.
///
/// Pairs with [TidyLogoMark]. Pass a [variant] to lock the wordmark
/// colour to a specific theme; the default `auto` follows the surrounding
/// theme's brightness.
class TidyWordmark extends StatelessWidget {
  const TidyWordmark({
    super.key,
    this.fontSize = 28,
    this.letterSpacing,
    this.color,
    this.variant = TidyLogoVariant.auto,
    this.forceBrightness,
  });

  final double fontSize;
  final double? letterSpacing;
  final Color? color;
  final TidyLogoVariant variant;
  final Brightness? forceBrightness;

  Brightness _resolveBrightness(BuildContext context) {
    switch (variant) {
      case TidyLogoVariant.light:
        return Brightness.light;
      case TidyLogoVariant.dark:
        return Brightness.dark;
      case TidyLogoVariant.auto:
        return forceBrightness ?? Theme.of(context).brightness;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _resolveBrightness(context) == Brightness.dark;
    final resolved = color ??
        (isDark
            ? TidyBrand.wordmarkOnDark.withValues(alpha: 0.88)
            : TidyBrand.wordmarkOnLight.withValues(alpha: 0.88));

    return Text(
      'TIDY',
      style: TidyTypography.wordmark(
        fontSize: fontSize,
        color: resolved,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
