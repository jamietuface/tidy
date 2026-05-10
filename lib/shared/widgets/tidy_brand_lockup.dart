import 'package:flutter/material.dart';

import 'tidy_logo_mark.dart';
import 'tidy_wordmark.dart';

enum TidyBrandLockupAxis { horizontal, vertical }

enum TidyBrandLockupSize { small, medium, large }

/// Logo + wordmark composition. Use this in onboarding, sign-in, paywall
/// headers, and any marketing-consistent surface.
class TidyBrandLockup extends StatelessWidget {
  const TidyBrandLockup({
    super.key,
    this.axis = TidyBrandLockupAxis.horizontal,
    this.size = TidyBrandLockupSize.medium,
    this.showGlow = true,
    this.monochrome = false,
    this.showBadge = true,
    this.forceBrightness,
  });

  final TidyBrandLockupAxis axis;
  final TidyBrandLockupSize size;
  final bool showGlow;
  final bool monochrome;
  final bool showBadge;
  final Brightness? forceBrightness;

  // ---- Size table -----------------------------------------------------
  // Tuned so the wordmark sits comfortably next to the logo at every size.
  double get _logoSize {
    switch (size) {
      case TidyBrandLockupSize.small:
        return 32;
      case TidyBrandLockupSize.medium:
        return 52;
      case TidyBrandLockupSize.large:
        return 112;
    }
  }

  double get _wordSize {
    switch (size) {
      case TidyBrandLockupSize.small:
        return 18;
      case TidyBrandLockupSize.medium:
        return 28;
      case TidyBrandLockupSize.large:
        return 48;
    }
  }

  double get _gap {
    switch (size) {
      case TidyBrandLockupSize.small:
        return 10;
      case TidyBrandLockupSize.medium:
        return 14;
      case TidyBrandLockupSize.large:
        return 22;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = TidyLogoMark(
      size: _logoSize,
      showGlow: showGlow,
      monochrome: monochrome,
      showBadge: showBadge,
      forceBrightness: forceBrightness,
    );
    final word = TidyWordmark(
      fontSize: _wordSize,
      forceBrightness: forceBrightness,
    );

    if (axis == TidyBrandLockupAxis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logo,
          SizedBox(width: _gap),
          word,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(height: _gap),
        word,
      ],
    );
  }
}
