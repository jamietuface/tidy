import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  // Apple system colors
  static const systemBlue = Color(0xFF007AFF);
  static const systemGreen = Color(0xFF34C759);
  static const systemIndigo = Color(0xFF5856D6);
  static const systemOrange = Color(0xFFFF9500);
  static const systemPink = Color(0xFFFF2D55);
  static const systemPurple = Color(0xFFAF52DE);
  static const systemRed = Color(0xFFFF3B30);
  static const systemTeal = Color(0xFF5AC8FA);
  static const systemYellow = Color(0xFFFFCC00);

  // System grays
  static const systemGray = Color(0xFF8E8E93);
  static const systemGray2 = Color(0xFFAEAEB2);
  static const systemGray3 = Color(0xFFC7C7CC);
  static const systemGray4 = Color(0xFFD1D1D6);
  static const systemGray5 = Color(0xFFE5E5EA);
  static const systemGray6 = Color(0xFFF2F2F7);

  // Background
  static const background = Color(0xFFFFFFFF);
  static const secondaryBackground = Color(0xFFF2F2F7);
  static const tertiaryBackground = Color(0xFFFFFFFF);

  // Dark mode
  static const darkBackground = Color(0xFF000000);
  static const darkSecondaryBackground = Color(0xFF1C1C1E);
  static const darkTertiaryBackground = Color(0xFF2C2C2E);

  // Label
  static const label = Color(0xFF000000);
  static const secondaryLabel = Color(0x993C3C43);
  static const tertiaryLabel = Color(0x4D3C3C43);

  // Brand
  static const primary = systemBlue;
  static const accent = systemIndigo;
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.secondaryBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.label,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.label,
            letterSpacing: -0.4,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
        ),
        textTheme: _textTheme,
        extensions: const [TidyThemeExtension.light],
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.darkSecondaryBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
        ),
        textTheme: _textTheme,
        extensions: const [TidyThemeExtension.dark],
      );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2),
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.1),
    headlineSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.1),
    titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
}

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

  static const light = TidyThemeExtension(
    cardBackground: AppColors.background,
    groupedBackground: AppColors.secondaryBackground,
    separator: AppColors.systemGray4,
  );

  static const dark = TidyThemeExtension(
    cardBackground: AppColors.darkSecondaryBackground,
    groupedBackground: AppColors.darkBackground,
    separator: Color(0xFF38383A),
  );

  @override
  TidyThemeExtension copyWith({Color? cardBackground, Color? groupedBackground, Color? separator}) {
    return TidyThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      groupedBackground: groupedBackground ?? this.groupedBackground,
      separator: separator ?? this.separator,
    );
  }

  @override
  TidyThemeExtension lerp(TidyThemeExtension? other, double t) {
    if (other is! TidyThemeExtension) return this;
    return TidyThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      groupedBackground: Color.lerp(groupedBackground, other.groupedBackground, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
    );
  }
}
