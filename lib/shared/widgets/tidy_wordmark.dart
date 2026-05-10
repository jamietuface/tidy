import 'package:flutter/material.dart';

import '../../core/theme/tidy_brand_palette.dart';
import '../../core/theme/tidy_typography.dart';

/// "TIDY" — thin, wide-tracked uppercase wordmark.
///
/// Pairs with [TidyLogoMark]. If [color] is omitted the wordmark adapts
/// to the surrounding theme brightness using brand wordmark constants
/// (`TidyBrand.wordmarkOnDark` / `TidyBrand.wordmarkOnLight`).
class TidyWordmark extends StatelessWidget {
  const TidyWordmark({
    super.key,
    this.fontSize = 28,
    this.letterSpacing,
    this.color,
    this.forceBrightness,
  });

  final double fontSize;
  final double? letterSpacing;
  final Color? color;
  final Brightness? forceBrightness;

  @override
  Widget build(BuildContext context) {
    final brightness = forceBrightness ?? Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
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
