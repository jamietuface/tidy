import 'package:flutter/material.dart';

import '../../core/theme/tidy_brand_palette.dart';

/// The Tidy mark — a layered photo-card "T" rendered in pearl/silver.
///
/// Stays light (pearl badge + pearl mark) in BOTH light and dark themes.
/// On dark surfaces an optional faint blue rim glow surrounds the badge.
///
/// Pure widgets + CustomPainter — no raster assets, no SVG dep. Scales
/// cleanly from 28 → 128.
class TidyLogoMark extends StatelessWidget {
  const TidyLogoMark({
    super.key,
    this.size = 64,
    this.showBadge = true,
    this.showGlow = true,
    this.monochrome = false,
    this.forceBrightness,
  });

  final double size;
  final bool showBadge;
  final bool showGlow;
  final bool monochrome;

  /// Override the surrounding theme brightness — used by surfaces locked
  /// to a single mode (e.g. the dark paywall hero).
  final Brightness? forceBrightness;

  @override
  Widget build(BuildContext context) {
    final brightness = forceBrightness ?? Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LogoMarkPainter(monochrome: monochrome),
      ),
    );

    if (!showBadge) return mark;

    // Apple app-icon corner radius proportion (~22.5% of side).
    final radius = size * 0.235;

    // Pearl badge in BOTH modes. Cooler tint sits a little brighter on
    // dark surfaces so the badge reads against pure black; on light
    // surfaces the gradient is very subtle so the mark doesn't pop too
    // hard against the page.
    final badgeGradient = LinearGradient(
      colors: isDark
          ? const [Color(0xFFF8FBFF), Color(0xFFDDE5F2)]
          : const [Color(0xFFFDFEFF), Color(0xFFE6EDF7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final borderColor = isDark
        ? const Color(0xFFC8D4E6).withValues(alpha: 0.75)
        : TidyBrand.hairlineLight;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: badgeGradient,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: [
            // Soft ambient shadow under the badge.
            BoxShadow(
              color: const Color(0xFF1A2540)
                  .withValues(alpha: isDark ? 0.30 : 0.06),
              blurRadius: size * 0.22,
              offset: Offset(0, size * 0.045),
            ),
            // Faint blue rim glow only on dark surfaces.
            if (showGlow && isDark)
              BoxShadow(
                color: const Color(0xFF007AFF).withValues(alpha: 0.16),
                blurRadius: size * 0.32,
                spreadRadius: size * 0.005,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              // Top sheen across badge surface.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size * 0.50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.65),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle inner vignette for depth.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF1A2540).withValues(alpha: 0.04),
                      ],
                      radius: 0.85,
                    ),
                  ),
                ),
              ),
              Center(child: mark),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the layered photo-card "T".
///
/// Composition (back to front):
///  1. Soft ground shadow under the whole mark
///  2. Two back peek cards rotated -20° / -10° behind the top slab
///  3. Top main card — wide, slightly tilted upward-right, pearl gradient
///     with a faint cool "horizon" hint on the lower half
///  4. Stem — three thin tapered cards stacked downward, slight horizontal
///     drift suggesting hand-stacked photos
class _LogoMarkPainter extends CustomPainter {
  _LogoMarkPainter({required this.monochrome});

  final bool monochrome;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    // Mark fills 68% of the canvas (16% inset on every side).
    final inset = s * 0.16;
    final lw = s - inset * 2;
    final lh = s - inset * 2;
    final cx = s / 2;
    final top = inset;

    // ---- Pearl ramps ----
    final pearlBright = monochrome
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFFAFCFF);
    final pearlMid = monochrome
        ? const Color(0xFFE5E9F0)
        : const Color(0xFFE6EDF7);
    final pearlDeep = monochrome
        ? const Color(0xFFB8C2D0)
        : const Color(0xFFB8C2D9);
    final pearlShade = monochrome
        ? const Color(0xFF98A1B0)
        : const Color(0xFF98A4BC);

    // ---- 1. Soft ground shadow ----
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, top + lh * 0.93),
        width: lw * 0.70,
        height: lh * 0.10,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lh * 0.05),
    );

    // ---- 2. Back peek cards ----
    // Furthest back — mostly hidden, peeks lower-left.
    _drawCard(
      canvas,
      center: Offset(cx + lw * 0.06, top + lh * 0.22),
      width: lw * 0.74,
      height: lh * 0.22,
      rotation: -0.22,
      colors: [pearlMid, pearlShade],
      cornerRadius: s * 0.024,
      shadowOpacity: 0.10,
      shadowOffset: Offset(0, lh * 0.014),
      shadowBlur: lh * 0.030,
      sheenOpacity: 0.30,
      borderOpacity: 0.45,
    );

    // Nearer back card — peeks upper-right.
    _drawCard(
      canvas,
      center: Offset(cx - lw * 0.05, top + lh * 0.20),
      width: lw * 0.78,
      height: lh * 0.23,
      rotation: -0.11,
      colors: [pearlMid, pearlDeep],
      cornerRadius: s * 0.026,
      shadowOpacity: 0.12,
      shadowOffset: Offset(0, lh * 0.018),
      shadowBlur: lh * 0.036,
      sheenOpacity: 0.40,
      borderOpacity: 0.55,
    );

    // ---- 3. Top main card ----
    // Slight upward-right tilt (-0.04 rad ≈ -2.3°). Wider than the back
    // cards so it dominates. Includes a faint cool "horizon" hint on the
    // lower half to suggest a real photo without being literal.
    _drawCard(
      canvas,
      center: Offset(cx, top + lh * 0.18),
      width: lw * 0.86,
      height: lh * 0.25,
      rotation: -0.04,
      colors: [pearlBright, pearlDeep],
      cornerRadius: s * 0.030,
      shadowOpacity: 0.18,
      shadowOffset: Offset(0, lh * 0.024),
      shadowBlur: lh * 0.045,
      sheenOpacity: 0.55,
      borderOpacity: 0.65,
      withHorizonHint: !monochrome,
    );

    // ---- 4. Stem — 3 thin stacked cards ----
    // Stacked vertically with slight horizontal drift and progressive
    // taper. Each one casts a tiny shadow onto the next so they read as
    // separate photos.
    final stemCenters = [
      Offset(cx + lw * 0.000, top + lh * 0.45),
      Offset(cx + lw * 0.008, top + lh * 0.60),
      Offset(cx + lw * 0.016, top + lh * 0.74),
    ];
    final stemWidths = [lw * 0.27, lw * 0.25, lw * 0.23];
    final stemHeights = [lh * 0.13, lh * 0.13, lh * 0.13];
    final stemColorPairs = [
      [pearlBright, pearlDeep],
      [pearlMid, pearlDeep],
      [pearlMid, pearlShade],
    ];

    for (var i = 0; i < 3; i++) {
      _drawCard(
        canvas,
        center: stemCenters[i],
        width: stemWidths[i],
        height: stemHeights[i],
        rotation: 0.0,
        colors: stemColorPairs[i],
        cornerRadius: s * 0.020,
        shadowOpacity: 0.13,
        shadowOffset: Offset(0, lh * 0.011),
        shadowBlur: lh * 0.022,
        sheenOpacity: 0.40,
        borderOpacity: 0.50,
      );
    }
  }

  /// Draws a single rounded photo-card with shadow, gradient fill,
  /// optional horizon hint, top sheen, top edge highlight, and hairline
  /// border. All geometry is centered on `center` and rotated by
  /// `rotation` radians.
  void _drawCard(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required double rotation,
    required List<Color> colors,
    required double cornerRadius,
    required double shadowOpacity,
    required Offset shadowOffset,
    required double shadowBlur,
    required double sheenOpacity,
    required double borderOpacity,
    bool withHorizonHint = false,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    // Shadow.
    canvas.drawRRect(
      rrect.shift(shadowOffset),
      Paint()
        ..color = Colors.black.withValues(alpha: shadowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur),
    );

    // Card fill — pearl gradient.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    // Optional faint cool "horizon" hint on the lower half of the top
    // card — abstract enough to not look literal, just suggests a photo.
    if (withHorizonHint) {
      final hintRect = Rect.fromLTRB(
        rect.left,
        rect.center.dy + height * 0.05,
        rect.right,
        rect.bottom,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          hintRect,
          bottomLeft: Radius.circular(cornerRadius),
          bottomRight: Radius.circular(cornerRadius),
        ),
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFFC8D4E6).withValues(alpha: 0.0),
              const Color(0xFF8FA0BF).withValues(alpha: 0.28),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(hintRect),
      );
    }

    // Top sheen (downward fade from white).
    final sheenH = height * 0.50;
    final sheenRect = Rect.fromLTWH(rect.left, rect.top, rect.width, sheenH);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        sheenRect,
        topLeft: Radius.circular(cornerRadius),
        topRight: Radius.circular(cornerRadius),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: sheenOpacity),
            Colors.white.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(sheenRect),
    );

    // Bright 0.5px top edge highlight to emphasise the photo-card feel.
    canvas.drawLine(
      Offset(rect.left + cornerRadius * 0.6, rect.top + 0.4),
      Offset(rect.right - cornerRadius * 0.6, rect.top + 0.4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..strokeWidth = 0.5,
    );

    // Cool-gray hairline border.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4
        ..color = const Color(0xFFB8C2D9).withValues(alpha: borderOpacity),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) {
    return oldDelegate.monochrome != monochrome;
  }
}
