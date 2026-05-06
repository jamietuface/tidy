import 'package:flutter/material.dart';
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
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.backgroundPrimary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.backgroundPrimary,
        secondary: colors.accentMuted,
        onSecondary: colors.backgroundPrimary,
        surface: colors.surfaceCard,
        onSurface: colors.textPrimary,
        error: colors.errorQuiet,
        onError: colors.backgroundPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: TidyTypography.displayLarge.copyWith(color: colors.textPrimary),
        displayMedium: TidyTypography.displayMedium.copyWith(color: colors.textPrimary),
        headlineMedium: TidyTypography.headingMedium.copyWith(color: colors.textPrimary),
        headlineSmall: TidyTypography.headingSmall.copyWith(color: colors.textPrimary),
        bodyLarge: TidyTypography.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium: TidyTypography.bodyMedium.copyWith(color: colors.textPrimary),
        bodySmall: TidyTypography.bodySmall.copyWith(color: colors.textSecondary),
        labelMedium: TidyTypography.caption.copyWith(color: colors.textSecondary),
        labelSmall: TidyTypography.labelSmall.copyWith(color: colors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(TidyRadius.md),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.all(TidySpacing.lg),
        hintStyle: TidyTypography.bodyLarge.copyWith(color: colors.textTertiary),
      ),
      iconTheme: IconThemeData(color: colors.textPrimary, size: 20),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.backgroundPrimary,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.accentMuted.withValues(alpha: 0.18),
        elevation: 0,
        height: TidySize.navBarHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TidyTypography.caption.copyWith(
            color: selected ? colors.textPrimary : colors.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.textPrimary : colors.textTertiary,
            size: 22,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceCard,
        contentTextStyle: TidyTypography.bodyMedium.copyWith(color: colors.textPrimary),
        // Action label colour is forced via actionTextColor; the action's
        // typography (size/weight) inherits Flutter's TextButton default
        // because SnackBarThemeData doesn't expose an actionTextStyle field
        // in this Flutter version. Acceptable trade-off — the action stays
        // readable and the colour matches the accent token.
        actionTextColor: colors.accent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(TidyRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(TidyRadius.lg),
        ),
        titleTextStyle: TidyTypography.headingMedium.copyWith(color: colors.textPrimary),
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
