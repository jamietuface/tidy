import 'package:flutter/material.dart';

/// Color tokens for Tidy.
///
/// Single source of truth for every color in the app. Reference these tokens
/// via [Theme.of(context).extension<TidyColors>()] — never reference the raw
/// values in widgets.
class TidyColors extends ThemeExtension<TidyColors> {
  const TidyColors({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.surfaceCard,
    required this.surfaceOverlay,
    required this.accent,
    required this.accentMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderActive,
    required this.tagTask,
    required this.tagIdea,
    required this.tagNote,
    required this.successQuiet,
    required this.errorQuiet,
  });

  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color surfaceCard;
  final Color surfaceOverlay;
  final Color accent;
  final Color accentMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderSubtle;
  final Color borderActive;
  final Color tagTask;
  final Color tagIdea;
  final Color tagNote;
  final Color successQuiet;
  final Color errorQuiet;

  static const TidyColors light = TidyColors(
    backgroundPrimary: Color(0xFFFAF9F7),
    backgroundSecondary: Color(0xFFF2F1EF),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceOverlay: Color(0xEEFFFFFF),
    accent: Color(0xFF8C8C8C),
    accentMuted: Color(0xFFB8B8B8),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF6B6B6B),
    textTertiary: Color(0xFF9E9E9E),
    borderSubtle: Color(0xFFE8E6E3),
    borderActive: Color(0xFFC4C2BE),
    tagTask: Color(0xFFB0A898),
    tagIdea: Color(0xFFA8B0A8),
    tagNote: Color(0xFFB0A8B0),
    successQuiet: Color(0xFF7A8C7A),
    errorQuiet: Color(0xFFA88080),
  );

  static const TidyColors dark = TidyColors(
    backgroundPrimary: Color(0xFF0F0F0E),
    backgroundSecondary: Color(0xFF1A1A18),
    surfaceCard: Color(0xFF242422),
    surfaceOverlay: Color(0xEE2C2C2A),
    accent: Color(0xFFA0A0A0),
    accentMuted: Color(0xFF707070),
    textPrimary: Color(0xFFF0EFED),
    textSecondary: Color(0xFF9E9E9A),
    textTertiary: Color(0xFF6B6B68),
    borderSubtle: Color(0xFF2E2E2C),
    borderActive: Color(0xFF454542),
    tagTask: Color(0xFF6B6258),
    tagIdea: Color(0xFF586258),
    tagNote: Color(0xFF625862),
    successQuiet: Color(0xFF8FA08F),
    errorQuiet: Color(0xFF9A7878),
  );

  @override
  TidyColors copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? surfaceCard,
    Color? surfaceOverlay,
    Color? accent,
    Color? accentMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? borderSubtle,
    Color? borderActive,
    Color? tagTask,
    Color? tagIdea,
    Color? tagNote,
    Color? successQuiet,
    Color? errorQuiet,
  }) {
    return TidyColors(
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderActive: borderActive ?? this.borderActive,
      tagTask: tagTask ?? this.tagTask,
      tagIdea: tagIdea ?? this.tagIdea,
      tagNote: tagNote ?? this.tagNote,
      successQuiet: successQuiet ?? this.successQuiet,
      errorQuiet: errorQuiet ?? this.errorQuiet,
    );
  }

  @override
  TidyColors lerp(ThemeExtension<TidyColors>? other, double t) {
    if (other is! TidyColors) return this;
    return TidyColors(
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderActive: Color.lerp(borderActive, other.borderActive, t)!,
      tagTask: Color.lerp(tagTask, other.tagTask, t)!,
      tagIdea: Color.lerp(tagIdea, other.tagIdea, t)!,
      tagNote: Color.lerp(tagNote, other.tagNote, t)!,
      successQuiet: Color.lerp(successQuiet, other.successQuiet, t)!,
      errorQuiet: Color.lerp(errorQuiet, other.errorQuiet, t)!,
    );
  }
}
