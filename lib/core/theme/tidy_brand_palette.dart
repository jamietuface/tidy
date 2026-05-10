import 'package:flutter/material.dart';

/// Stage 1A brand foundation tokens.
///
/// Lives alongside the legacy [TidyColors] extension so existing
/// metallic-dark screens keep working; new brand widgets, the brand
/// preview screen, and Stage 1B redesigns consume these instead.
@immutable
class TidyBrandPalette extends ThemeExtension<TidyBrandPalette> {
  const TidyBrandPalette({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceSoft,
    required this.surfaceElevated,
    required this.cardBorder,
    required this.cardBorderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.hairline,
    required this.blue,
    required this.indigo,
    required this.danger,
    required this.success,
  });

  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceSoft;
  final Color surfaceElevated;
  final Color cardBorder;
  final Color cardBorderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color hairline;
  final Color blue;
  final Color indigo;
  final Color danger;
  final Color success;

  static final TidyBrandPalette dark = TidyBrandPalette(
    background: const Color(0xFF000000),
    backgroundAlt: const Color(0xFF05070B),
    surface: const Color(0xFF05070B),
    surfaceSoft: const Color(0xFF0B0E14),
    surfaceElevated: const Color(0xFF11151D),
    cardBorder: Colors.white.withValues(alpha: 0.10),
    cardBorderSubtle: Colors.white.withValues(alpha: 0.06),
    textPrimary: Colors.white.withValues(alpha: 0.92),
    textSecondary: Colors.white.withValues(alpha: 0.62),
    textMuted: Colors.white.withValues(alpha: 0.42),
    hairline: Colors.white.withValues(alpha: 0.16),
    blue: const Color(0xFF007AFF),
    indigo: const Color(0xFF5856D6),
    danger: const Color(0xFFFF3B30),
    success: const Color(0xFF34C759),
  );

  static const TidyBrandPalette light = TidyBrandPalette(
    background: Color(0xFFF7F9FC),
    backgroundAlt: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF1F5FA),
    surfaceElevated: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFDCE3ED),
    cardBorderSubtle: Color(0xFFE7ECF3),
    textPrimary: Color(0xFF1D2430),
    textSecondary: Color(0xFF667085),
    textMuted: Color(0xFF98A2B3),
    hairline: Color(0xFFDCE7F5),
    blue: Color(0xFF007AFF),
    indigo: Color(0xFF5856D6),
    danger: Color(0xFFFF3B30),
    success: Color(0xFF34C759),
  );

  @override
  TidyBrandPalette copyWith({
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceSoft,
    Color? surfaceElevated,
    Color? cardBorder,
    Color? cardBorderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? hairline,
    Color? blue,
    Color? indigo,
    Color? danger,
    Color? success,
  }) {
    return TidyBrandPalette(
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      cardBorder: cardBorder ?? this.cardBorder,
      cardBorderSubtle: cardBorderSubtle ?? this.cardBorderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      hairline: hairline ?? this.hairline,
      blue: blue ?? this.blue,
      indigo: indigo ?? this.indigo,
      danger: danger ?? this.danger,
      success: success ?? this.success,
    );
  }

  @override
  TidyBrandPalette lerp(ThemeExtension<TidyBrandPalette>? other, double t) {
    if (other is! TidyBrandPalette) return this;
    return TidyBrandPalette(
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardBorderSubtle:
          Color.lerp(cardBorderSubtle, other.cardBorderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      indigo: Color.lerp(indigo, other.indigo, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// Theme-independent brand constants. The Tidy logo always uses these
/// regardless of light/dark mode — it stays "light" in both.
class TidyBrand {
  const TidyBrand._();

  static const Color pearl = Color(0xFFF7FAFF);
  static const Color ice = Color(0xFFEAF2FF);
  static const Color silver = Color(0xFFB8C2D9);
  static const Color graphite = Color(0xFF3B4454);

  static const Color hairlineLight = Color(0xFFDCE7F5);
  static final Color hairlineDark = Colors.white.withValues(alpha: 0.16);

  // Wordmark colours by surface brightness.
  static const Color wordmarkOnDark = Color(0xFFEAF2FF);
  static const Color wordmarkOnLight = Color(0xFF303846);
}

extension TidyBrandPaletteContext on BuildContext {
  TidyBrandPalette get tidyBrand =>
      Theme.of(this).extension<TidyBrandPalette>()!;
}
