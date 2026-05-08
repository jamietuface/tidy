import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tidy_colors.dart';
import 'tidy_radius.dart';
import 'tidy_size.dart';
import 'tidy_spacing.dart';
import 'tidy_typography.dart';
import '../../theme/app_theme.dart' show TidyThemeExtension;

/// Assembles ThemeData for light + dark modes from Tidy's design tokens.
class TidyTheme {
  const TidyTheme._();

  static ThemeData light() => _build(TidyColors.light, Brightness.light);
  static ThemeData dark() => _build(TidyColors.dark, Brightness.dark);

  static ThemeData _build(TidyColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.backgroundPrimary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: Colors.white,
        secondary: colors.accentMuted,
        onSecondary: isDark ? Colors.white : colors.textPrimary,
        surface: colors.surfaceCard,
        onSurface: colors.textPrimary,
        error: colors.errorQuiet,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge:  TidyTypography.displayLarge.copyWith(color: colors.textPrimary),
        displayMedium: TidyTypography.displayMedium.copyWith(color: colors.textPrimary),
        displaySmall:  TidyTypography.headingMedium.copyWith(color: colors.textPrimary),
        headlineMedium: TidyTypography.headingMedium.copyWith(color: colors.textPrimary),
        headlineSmall:  TidyTypography.headingSmall.copyWith(color: colors.textPrimary),
        titleLarge:    TidyTypography.headingSmall.copyWith(color: colors.textPrimary),
        titleMedium:   TidyTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        titleSmall:    TidyTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        bodyLarge:   TidyTypography.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium:  TidyTypography.bodyMedium.copyWith(color: colors.textPrimary),
        bodySmall:   TidyTypography.bodySmall.copyWith(color: colors.textSecondary),
        labelMedium: TidyTypography.caption.copyWith(color: colors.textSecondary),
        labelSmall:  TidyTypography.labelSmall.copyWith(color: colors.textTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.backgroundPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TidyTypography.headingSmall.copyWith(color: colors.textPrimary),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.borderSubtle, width: 0.5),
          borderRadius: BorderRadius.circular(TidyRadius.md),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 0.5,
        space: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.all(TidySpacing.lg),
        hintStyle: TidyTypography.bodyLarge.copyWith(color: colors.textTertiary),
      ),
      iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? colors.backgroundPrimary.withValues(alpha: 0.85)
            : colors.backgroundSecondary.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: colors.accent.withValues(alpha: 0.15),
        elevation: 0,
        height: TidySize.navBarHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TidyTypography.labelSmall.copyWith(
            fontSize: 10,
            color: selected ? colors.accent : colors.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.accent : colors.textTertiary,
            size: 24,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        contentTextStyle: TidyTypography.bodyMedium.copyWith(color: colors.textPrimary),
        actionTextColor: colors.accent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.borderSubtle, width: 0.5),
          borderRadius: BorderRadius.circular(TidyRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TidyRadius.xl),
        ),
        titleTextStyle: TidyTypography.headingSmall.copyWith(color: colors.textPrimary),
        contentTextStyle: TidyTypography.bodyMedium.copyWith(color: colors.textPrimary),
      ),
      extensions: <ThemeExtension<dynamic>>[
        colors,
        TidyThemeExtension.fromTidyColors(colors),
      ],
    );
  }
}

/// Convenient context extension for reading Tidy colors.
extension TidyThemeContext on BuildContext {
  TidyColors get tidyColors => Theme.of(this).extension<TidyColors>()!;
}
