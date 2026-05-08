import 'package:flutter/material.dart';

/// Color tokens for Tidy — Apple iOS system palette.
///
/// Single source of truth for every color in the app.
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

  // iOS system grouped background (Settings-style)
  static const TidyColors light = TidyColors(
    backgroundPrimary:   Color(0xFFF2F2F7),   // systemGroupedBackground
    backgroundSecondary: Color(0xFFFFFFFF),   // systemBackground
    surfaceCard:         Color(0xFFFFFFFF),   // secondarySystemGroupedBackground
    surfaceOverlay:      Color(0xF0F9F9F9),
    accent:              Color(0xFF007AFF),   // systemBlue
    accentMuted:         Color(0xFFBFD7FF),
    textPrimary:         Color(0xFF000000),
    textSecondary:       Color(0x993C3C43),   // label @ 60%
    textTertiary:        Color(0x4D3C3C43),   // label @ 30%
    borderSubtle:        Color(0x29787880),   // separator
    borderActive:        Color(0xFFC6C6C8),   // opaqueSeparator
    tagTask:             Color(0xFF5856D6),   // systemIndigo
    tagIdea:             Color(0xFFFF9500),   // systemOrange
    tagNote:             Color(0xFFFF2D55),   // systemPink
    successQuiet:        Color(0xFF34C759),   // systemGreen
    errorQuiet:          Color(0xFFFF3B30),   // systemRed
  );

  // True black OLED — feels like it's from Apple
  static const TidyColors dark = TidyColors(
    backgroundPrimary:   Color(0xFF000000),   // true black (OLED savings)
    backgroundSecondary: Color(0xFF1C1C1E),   // systemBackground dark
    surfaceCard:         Color(0xFF1C1C1E),   // secondarySystemGroupedBackground dark
    surfaceOverlay:      Color(0xCC1C1C1E),
    accent:              Color(0xFF0A84FF),   // systemBlue dark
    accentMuted:         Color(0xFF0A3875),
    textPrimary:         Color(0xFFFFFFFF),
    textSecondary:       Color(0x99EBEBF5),   // label @ 60%
    textTertiary:        Color(0x4DEBEBF5),   // label @ 30%
    borderSubtle:        Color(0x29545458),   // separator dark
    borderActive:        Color(0xFF38383A),   // opaqueSeparator dark
    tagTask:             Color(0xFF5E5CE6),   // systemIndigo dark
    tagIdea:             Color(0xFFFF9F0A),   // systemOrange dark
    tagNote:             Color(0xFFFF375F),   // systemPink dark
    successQuiet:        Color(0xFF30D158),   // systemGreen dark
    errorQuiet:          Color(0xFFFF453A),   // systemRed dark
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
      backgroundPrimary:   backgroundPrimary   ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      surfaceCard:         surfaceCard         ?? this.surfaceCard,
      surfaceOverlay:      surfaceOverlay      ?? this.surfaceOverlay,
      accent:              accent              ?? this.accent,
      accentMuted:         accentMuted         ?? this.accentMuted,
      textPrimary:         textPrimary         ?? this.textPrimary,
      textSecondary:       textSecondary       ?? this.textSecondary,
      textTertiary:        textTertiary        ?? this.textTertiary,
      borderSubtle:        borderSubtle        ?? this.borderSubtle,
      borderActive:        borderActive        ?? this.borderActive,
      tagTask:             tagTask             ?? this.tagTask,
      tagIdea:             tagIdea             ?? this.tagIdea,
      tagNote:             tagNote             ?? this.tagNote,
      successQuiet:        successQuiet        ?? this.successQuiet,
      errorQuiet:          errorQuiet          ?? this.errorQuiet,
    );
  }

  @override
  TidyColors lerp(ThemeExtension<TidyColors>? other, double t) {
    if (other is! TidyColors) return this;
    return TidyColors(
      backgroundPrimary:   Color.lerp(backgroundPrimary,   other.backgroundPrimary,   t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      surfaceCard:         Color.lerp(surfaceCard,         other.surfaceCard,         t)!,
      surfaceOverlay:      Color.lerp(surfaceOverlay,      other.surfaceOverlay,      t)!,
      accent:              Color.lerp(accent,              other.accent,              t)!,
      accentMuted:         Color.lerp(accentMuted,         other.accentMuted,         t)!,
      textPrimary:         Color.lerp(textPrimary,         other.textPrimary,         t)!,
      textSecondary:       Color.lerp(textSecondary,       other.textSecondary,       t)!,
      textTertiary:        Color.lerp(textTertiary,        other.textTertiary,        t)!,
      borderSubtle:        Color.lerp(borderSubtle,        other.borderSubtle,        t)!,
      borderActive:        Color.lerp(borderActive,        other.borderActive,        t)!,
      tagTask:             Color.lerp(tagTask,             other.tagTask,             t)!,
      tagIdea:             Color.lerp(tagIdea,             other.tagIdea,             t)!,
      tagNote:             Color.lerp(tagNote,             other.tagNote,             t)!,
      successQuiet:        Color.lerp(successQuiet,        other.successQuiet,        t)!,
      errorQuiet:          Color.lerp(errorQuiet,          other.errorQuiet,          t)!,
    );
  }
}
