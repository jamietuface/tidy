import 'package:flutter/material.dart';

/// Which version of the Tidy mark to render.
///
///  • [auto]  — pick from `Theme.of(context).brightness`
///  • [light] — force the light raster asset
///  • [dark]  — force the dark raster asset
enum TidyLogoVariant { auto, light, dark }

/// The Tidy mark — renders the approved raster asset.
///
/// Backed by `assets/brand/tidy_logo_mark_light.png` and
/// `assets/brand/tidy_logo_mark_dark.png` (the badge + inner T composition
/// is baked into the PNGs, so no wrapping `BoxDecoration` is needed).
class TidyLogoMark extends StatelessWidget {
  const TidyLogoMark({
    super.key,
    this.size = 64,
    this.variant = TidyLogoVariant.auto,
    this.showGlow = true,
    this.monochrome = false,
  });

  final double size;
  final TidyLogoVariant variant;

  /// Reserved for future glow treatment around the badge. The current
  /// raster assets already include the dark-variant rim glow, so this is
  /// a no-op today; kept for backwards-compat with existing callers.
  final bool showGlow;

  /// Reserved — would render a single-tone version. Not supported by the
  /// raster pipeline; kept as a no-op so existing callers don't break.
  final bool monochrome;

  TidyLogoVariant _resolveVariant(BuildContext context) {
    switch (variant) {
      case TidyLogoVariant.light:
        return TidyLogoVariant.light;
      case TidyLogoVariant.dark:
        return TidyLogoVariant.dark;
      case TidyLogoVariant.auto:
        return Theme.of(context).brightness == Brightness.dark
            ? TidyLogoVariant.dark
            : TidyLogoVariant.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveVariant(context);
    final assetPath = resolved == TidyLogoVariant.dark
        ? 'assets/brand/tidy_logo_mark_dark.png'
        : 'assets/brand/tidy_logo_mark_light.png';

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
