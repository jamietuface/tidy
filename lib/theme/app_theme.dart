import 'package:flutter/material.dart';
import '../core/theme/tidy_colors.dart';
export '../core/theme/tidy_theme.dart';
export '../core/theme/tidy_colors.dart';

// iOS system color palette — static constants usable anywhere without context
class AppColors {
  static const systemBlue    = Color(0xFF007AFF);
  static const systemGreen   = Color(0xFF34C759);
  static const systemIndigo  = Color(0xFF5856D6);
  static const systemOrange  = Color(0xFFFF9500);
  static const systemPink    = Color(0xFFFF2D55);
  static const systemPurple  = Color(0xFFAF52DE);
  static const systemRed     = Color(0xFFFF3B30);
  static const systemTeal    = Color(0xFF5AC8FA);
  static const systemYellow  = Color(0xFFFFCC00);
  static const systemGray    = Color(0xFF8E8E93);
  static const systemGray2   = Color(0xFFAEAEB2);
  static const systemGray3   = Color(0xFFC7C7CC);
  static const systemGray4   = Color(0xFFD1D1D6);
  static const systemGray5   = Color(0xFFE5E5EA);
  static const systemGray6   = Color(0xFFF2F2F7);
  static const background    = Color(0xFFFFFFFF);
  static const primary       = systemBlue;
  static const accent        = systemIndigo;
}

// Compatibility shim — screens that watch TidyThemeExtension now get
// the same data via the richer TidyColors ThemeExtension from Vale.
@immutable
class TidyThemeExtension extends ThemeExtension<TidyThemeExtension> {
  const TidyThemeExtension({
    required this.cardBackground,
    required this.groupedBackground,
    required this.separator,
  });

  final Color cardBackground;
  final Color groupedBackground;
  final Color separator;

  // Build from TidyColors so the two systems stay in sync
  factory TidyThemeExtension.fromTidyColors(TidyColors c) =>
      TidyThemeExtension(
        cardBackground: c.surfaceCard,
        groupedBackground: c.backgroundSecondary,
        separator: c.borderSubtle,
      );

  static final light = TidyThemeExtension.fromTidyColors(TidyColors.light);
  static final dark  = TidyThemeExtension.fromTidyColors(TidyColors.dark);

  @override
  TidyThemeExtension copyWith({Color? cardBackground, Color? groupedBackground, Color? separator}) =>
      TidyThemeExtension(
        cardBackground:   cardBackground   ?? this.cardBackground,
        groupedBackground: groupedBackground ?? this.groupedBackground,
        separator:        separator        ?? this.separator,
      );

  @override
  TidyThemeExtension lerp(TidyThemeExtension? other, double t) {
    if (other is! TidyThemeExtension) return this;
    return TidyThemeExtension(
      cardBackground:    Color.lerp(cardBackground,    other.cardBackground,    t)!,
      groupedBackground: Color.lerp(groupedBackground, other.groupedBackground, t)!,
      separator:         Color.lerp(separator,         other.separator,         t)!,
    );
  }
}
