import 'package:flutter/material.dart';

import '../../core/theme/tidy_brand_palette.dart';

/// The Tidy mark — a layered photo-card "T" rendered in pearl/silver.
///
/// Stays light in both themes; only the surrounding badge adapts:
///  • light: pearl gradient + hairline border + soft drop shadow
///  • dark : near-black glass + hairline + optional blue rim glow
///
/// Pure widgets + CustomPainter — no raster assets, no SVG dep.
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

  /// Override the surrounding theme brightness — useful for surfaces that
  /// are intentionally locked to one mode (e.g. the dark paywall in
  /// Stage 1A) where the logo needs to render its dark-themed badge
  /// regardless of the user's app theme.
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

    final badgeGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1B202B), Color(0xFF06080D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFDFEFF), Color(0xFFE8EFF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : TidyBrand.hairlineLight;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: badgeGradient,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: [
            if (showGlow && isDark)
              BoxShadow(
                color: const Color(0xFF007AFF).withValues(alpha: 0.18),
                blurRadius: size * 0.35,
                spreadRadius: size * 0.015,
              ),
            if (!isDark)
              BoxShadow(
                color: const Color(0xFF1A2540).withValues(alpha: 0.07),
                blurRadius: size * 0.18,
                offset: Offset(0, size * 0.04),
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
                height: size * 0.46,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.white.withValues(alpha: 0),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.55),
                              Colors.white.withValues(alpha: 0),
                            ],
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
///  1. Subtle ground shadow
///  2. Back "peek" card — small rotated card showing behind the top slab
///  3. Top slab (horizontal bar of the T) with pearl gradient + sheen
///  4. Stem (vertical body of the T) — slightly darker pearl
class _LogoMarkPainter extends CustomPainter {
  _LogoMarkPainter({required this.monochrome});

  final bool monochrome;

  // Tunable layout fractions, normalised to the painter's square size.
  static const _inset = 0.18;
  static const _slabTopFrac = 0.20;
  static const _slabHeightFrac = 0.32;
  static const _slabWidthFrac = 0.86;
  static const _stemWidthFrac = 0.22;
  static const _stemHeightFrac = 0.34;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final inset = s * _inset;
    final lw = s - inset * 2;
    final lh = s - inset * 2;
    final cx = s / 2;
    final left = inset;
    final top = inset;

    // ---- Colour ramps ----
    final slabColors = monochrome
        ? const [Color(0xFFFFFFFF), Color(0xFFCBD3E0)]
        : const [Color(0xFFF7FAFF), Color(0xFFB8C2D9)];
    final stemColors = monochrome
        ? const [Color(0xFFE5E9F0), Color(0xFF8C95A6)]
        : const [Color(0xFFD8E0EE), Color(0xFF6F7B8E)];
    final peekColors = monochrome
        ? const [Color(0xFFEEF1F6), Color(0xFFC4CCDA)]
        : const [Color(0xFFE6EEF8), Color(0xFFC0CADC)];

    // ---- 1. Ground shadow under entire mark ----
    final groundRect = Rect.fromLTWH(
      left + lw * 0.10,
      top + lh * 0.78,
      lw * 0.80,
      lh * 0.16,
    );
    canvas.drawOval(
      groundRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lh * 0.06),
    );

    // ---- 2. Back peek card ----
    canvas.save();
    canvas.translate(left + lw * 0.20, top + lh * 0.06);
    canvas.rotate(-0.18);
    final peekRect = Rect.fromLTWH(0, 0, lw * 0.50, lh * 0.18);
    final peekRRect = RRect.fromRectAndRadius(
      peekRect,
      Radius.circular(s * 0.018),
    );
    // Faint shadow behind peek
    canvas.drawRRect(
      peekRRect.shift(Offset(0, lh * 0.012)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lh * 0.025),
    );
    canvas.drawRRect(
      peekRRect,
      Paint()
        ..shader = LinearGradient(
          colors: peekColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(peekRect),
    );
    // Hairline edge on peek
    canvas.drawRRect(
      peekRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.restore();

    // ---- 3. Top slab (horizontal bar of the T) ----
    final slabLeft = cx - (lw * _slabWidthFrac) / 2;
    final slabTop = top + lh * _slabTopFrac;
    final slabRect = Rect.fromLTWH(
      slabLeft,
      slabTop,
      lw * _slabWidthFrac,
      lh * _slabHeightFrac,
    );
    final slabRRect =
        RRect.fromRectAndRadius(slabRect, Radius.circular(s * 0.025));

    // Slab drop shadow
    canvas.drawRRect(
      slabRRect.shift(Offset(0, lh * 0.035)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lh * 0.04),
    );

    // Slab base fill
    canvas.drawRRect(
      slabRRect,
      Paint()
        ..shader = LinearGradient(
          colors: slabColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(slabRect),
    );

    // Slab top sheen
    final sheenH = slabRect.height * 0.45;
    final sheenRect =
        Rect.fromLTWH(slabRect.left, slabRect.top, slabRect.width, sheenH);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        sheenRect,
        topLeft: Radius.circular(s * 0.025),
        topRight: Radius.circular(s * 0.025),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.75),
            Colors.white.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(sheenRect),
    );

    // Slab bottom edge — gives the 3D "front face" feel
    final edgeH = slabRect.height * 0.20;
    final edgeRect = Rect.fromLTWH(
      slabRect.left,
      slabRect.bottom - edgeH,
      slabRect.width,
      edgeH,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        edgeRect,
        bottomLeft: Radius.circular(s * 0.025),
        bottomRight: Radius.circular(s * 0.025),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.22),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(edgeRect),
    );

    // Slab hairline border
    canvas.drawRRect(
      slabRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    // ---- 4. Stem (vertical body of the T) ----
    final stemW = lw * _stemWidthFrac;
    final stemH = lh * _stemHeightFrac;
    final stemRect = Rect.fromLTWH(
      cx - stemW * 0.45,
      slabRect.bottom - stemH * 0.10,
      stemW,
      stemH,
    );
    final stemRRect =
        RRect.fromRectAndRadius(stemRect, Radius.circular(s * 0.018));

    // Stem shadow
    canvas.drawRRect(
      stemRRect.shift(Offset(0, lh * 0.025)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lh * 0.03),
    );

    // Stem fill
    canvas.drawRRect(
      stemRRect,
      Paint()
        ..shader = LinearGradient(
          colors: stemColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(stemRect),
    );

    // Stem inner sheen on left edge
    final stemSheenRect = Rect.fromLTWH(
      stemRect.left,
      stemRect.top,
      stemRect.width * 0.42,
      stemRect.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        stemSheenRect,
        topLeft: Radius.circular(s * 0.018),
        bottomLeft: Radius.circular(s * 0.018),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(stemSheenRect),
    );

    // Stem hairline
    canvas.drawRRect(
      stemRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.white.withValues(alpha: 0.40),
    );
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) {
    return oldDelegate.monochrome != monochrome;
  }
}
