import 'package:flutter/material.dart';

/// Typography tokens for Tidy — mirrors Apple's iOS type scale.
///
/// Uses SF Pro on iOS (system default). Negative tracking on large sizes
/// matches Apple's optical spacing exactly.
class TidyTypography {
  const TidyTypography._();

  // Large Title — 34 Bold
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
  );

  // Title 1 — 28 Bold
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  // Title 2 — 22 Bold
  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // Title 3 — 20 Semibold
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.15,
  );

  // Body — 17 Regular
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.47,
  );

  // Callout — 16 Regular
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // Subhead — 15 Regular
  static const TextStyle bodySmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Footnote — 13 Regular
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
  );

  // Caption 2 — 11 Medium
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.27,
    letterSpacing: 0.07,
  );

  /// Brand wordmark "TIDY" — thin, wide-tracked, premium.
  /// Letter-spacing scales with size so it reads correctly at any scale.
  static TextStyle wordmark({
    required double fontSize,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      height: 1.0,
      letterSpacing: letterSpacing ?? (fontSize * 0.34),
      color: color,
    );
  }
}
