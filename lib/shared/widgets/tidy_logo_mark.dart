import 'package:flutter/material.dart';

/// Which version of the Tidy mark to render.
///
///  • [auto]  — pick from `Theme.of(context).brightness`
///  • [light] — force the light reference variant
///  • [dark]  — force the dark reference variant
enum TidyLogoVariant { auto, light, dark }

/// The Tidy mark — layered photo-card "T" rendered to match the approved
/// cropped reference art at `docs/design_refs/stage_1A/`.
///
/// Two distinct variants:
///  • Light — pearl rounded-square badge with cool blue hairline; pearl-toned
///    inner cards.
///  • Dark — near-black glass badge with luminous bluish-white hairline plus
///    a subtle outer blue rim glow; charcoal inner cards.
///
/// Inner composition (both variants):
///  • Top "photo" card — slightly rotated rounded rectangle with a
///    mist/mountain gradient and silhouette peaks.
///  • A small back card peeking out behind the top card on the right.
///  • Stem — five thin tall cards depth-stacked (each offset a little
///    right + down) so the right side reads as a fan of card edges.
class TidyLogoMark extends StatelessWidget {
  const TidyLogoMark({
    super.key,
    this.size = 64,
    this.showBadge = true,
    this.showGlow = true,
    this.monochrome = false,
    this.variant = TidyLogoVariant.auto,
    this.forceBrightness,
  });

  final double size;
  final bool showBadge;
  final bool showGlow;
  final bool monochrome;

  /// Preferred way to lock the variant. Takes precedence over
  /// [forceBrightness] and the surrounding theme.
  final TidyLogoVariant variant;

  /// Legacy override — keep for callers that still pass a `Brightness`.
  /// Used only when [variant] is [TidyLogoVariant.auto].
  final Brightness? forceBrightness;

  Brightness _resolveBrightness(BuildContext context) {
    switch (variant) {
      case TidyLogoVariant.light:
        return Brightness.light;
      case TidyLogoVariant.dark:
        return Brightness.dark;
      case TidyLogoVariant.auto:
        return forceBrightness ?? Theme.of(context).brightness;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _resolveBrightness(context);
    final isDark = brightness == Brightness.dark;

    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LogoMarkPainter(
          brightness: brightness,
          monochrome: monochrome,
        ),
      ),
    );

    if (!showBadge) return mark;

    // Apple app-icon corner radius proportion (~22.5% of side).
    final radius = size * 0.235;

    // ---- Badge styling per variant ----
    final badgeGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF14181F), Color(0xFF06080C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFAFCFF), Color(0xFFDFE6F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    // Border: cool blue hairline on light; luminous bluish-white on dark.
    final borderColor = isDark
        ? const Color(0xFFCBDDF7).withValues(alpha: 0.55)
        : const Color(0xFFC8D4E6).withValues(alpha: 0.85);

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: badgeGradient,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: 0.6),
          boxShadow: [
            // Ambient drop shadow under the badge.
            BoxShadow(
              color: const Color(0xFF000714)
                  .withValues(alpha: isDark ? 0.45 : 0.08),
              blurRadius: size * 0.22,
              offset: Offset(0, size * 0.045),
            ),
            // Outer blue rim glow only on the dark variant.
            if (showGlow && isDark)
              BoxShadow(
                color: const Color(0xFF5AB8FF).withValues(alpha: 0.25),
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
                        Colors.white
                            .withValues(alpha: isDark ? 0.08 : 0.55),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle inner vignette.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black
                            .withValues(alpha: isDark ? 0.30 : 0.05),
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

/// Paints the inner T composition. All geometry is normalised to the
/// painter's square `size`, so the same code scales 28 → 128.
class _LogoMarkPainter extends CustomPainter {
  _LogoMarkPainter({required this.brightness, required this.monochrome});

  final Brightness brightness;
  final bool monochrome;

  bool get _isDark => brightness == Brightness.dark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    // ---- Layout ----
    final inset = s * 0.10;
    final lw = s - inset * 2;
    final lh = s - inset * 2;
    final cx = s / 2;
    final top = inset;

    // ---- Per-variant ramps ----
    // Stem cards — pearl gradient on light, charcoal on dark.
    final stemColors = monochrome
        ? const [Color(0xFFFFFFFF), Color(0xFFCBD3E0)]
        : (_isDark
            ? const [Color(0xFF1F242F), Color(0xFF0A0D14)]
            : const [Color(0xFFFCFDFF), Color(0xFFD9E0EC)]);

    // Peek/back card — slightly muted version of the stem palette.
    final peekColors = monochrome
        ? const [Color(0xFFE8EBF1), Color(0xFFB8C2D0)]
        : (_isDark
            ? const [Color(0xFF1A1F28), Color(0xFF06080D)]
            : const [Color(0xFFF1F5FB), Color(0xFFC8D2E2)]);

    // Edge highlight on top of every card.
    final edgeHighlight = _isDark
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.70);

    // Hairline border colour.
    final hairline = _isDark
        ? Colors.white.withValues(alpha: 0.16)
        : const Color(0xFFB8C2D9).withValues(alpha: 0.55);

    // Mountain photo gradient on the top card. Same shape both modes —
    // the peaks are slightly darker on dark to keep contrast.
    const mountainStops = [0.0, 0.30, 0.55, 1.0];
    final mountainColors = monochrome
        ? const [
            Color(0xFFCDD5E2),
            Color(0xFFE6EBF4),
            Color(0xFF8E97AC),
            Color(0xFF42495A),
          ]
        : (_isDark
            ? const [
                Color(0xFF747F95),
                Color(0xFFA9B5CD),
                Color(0xFF353D4D),
                Color(0xFF13171F),
              ]
            : const [
                Color(0xFFB8C2D8),
                Color(0xFFD8DFEC),
                Color(0xFF7A839A),
                Color(0xFF424A5F),
              ]);

    // ---- 1. Stem stack — 5 cards, drawn back-to-front ----
    // Slightly right of centre, depth-stacked so each successive card
    // peeks a little to the right and down. Combined with hairline
    // borders, the right side reads as a fan of card edges.
    final stemCenterX = cx + lw * 0.04;
    final stemTopY = top + lh * 0.43;
    final stemBottomY = top + lh * 0.97;
    final stemH = stemBottomY - stemTopY;
    final stemW = lw * 0.32;

    // Draw the deepest card's drop shadow once.
    final deepestRect = Rect.fromCenter(
      center: Offset(stemCenterX + 4 * 1.4, stemTopY + stemH / 2 + 4 * 0.8),
      width: stemW,
      height: stemH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(deepestRect, Radius.circular(s * 0.06))
          .shift(Offset(0, lh * 0.018)),
      Paint()
        ..color = Colors.black.withValues(alpha: _isDark ? 0.55 : 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lh * 0.030),
    );

    for (var i = 4; i >= 0; i--) {
      final ox = i * 1.4;
      final oy = i * 0.8;
      _drawStemCard(
        canvas,
        center: Offset(stemCenterX + ox, stemTopY + stemH / 2 + oy),
        width: stemW,
        height: stemH,
        cornerRadius: s * 0.06,
        colors: stemColors,
        edgeHighlight: edgeHighlight,
        border: hairline,
        sheenAlpha: _isDark ? 0.10 : 0.45,
      );
    }

    // ---- 2. Back peek card behind the top card ----
    // Small slab visible behind the top card, peeking lower-right.
    canvas.save();
    canvas.translate(cx + lw * 0.10, top + lh * 0.28);
    canvas.rotate(-0.06);
    final peekRect = Rect.fromCenter(
      center: Offset.zero,
      width: lw * 0.55,
      height: lh * 0.22,
    );
    final peekRRect =
        RRect.fromRectAndRadius(peekRect, Radius.circular(s * 0.04));
    canvas.drawRRect(
      peekRRect.shift(Offset(0, lh * 0.014)),
      Paint()
        ..color = Colors.black.withValues(alpha: _isDark ? 0.45 : 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lh * 0.022),
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
    canvas.drawRRect(
      peekRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = hairline,
    );
    canvas.restore();

    // ---- 3. Top main card (photo card with mountains) ----
    canvas.save();
    canvas.translate(cx, top + lh * 0.22);
    canvas.rotate(-0.05); // slight upward-right tilt
    final topRect = Rect.fromCenter(
      center: Offset.zero,
      width: lw * 0.86,
      height: lh * 0.27,
    );
    final topRRect =
        RRect.fromRectAndRadius(topRect, Radius.circular(s * 0.045));

    // Drop shadow.
    canvas.drawRRect(
      topRRect.shift(Offset(0, lh * 0.025)),
      Paint()
        ..color = Colors.black.withValues(alpha: _isDark ? 0.55 : 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lh * 0.040),
    );

    // Mountain photo gradient.
    canvas.drawRRect(
      topRRect,
      Paint()
        ..shader = LinearGradient(
          colors: mountainColors,
          stops: mountainStops,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(topRect),
    );

    // Mountain silhouettes — clipped to the card.
    canvas.save();
    canvas.clipRRect(topRRect);
    _drawMountainPeaks(canvas, topRect, isDark: _isDark, monochrome: monochrome);
    canvas.restore();

    // Top sheen.
    final topSheenH = topRect.height * 0.40;
    final topSheenRect = Rect.fromLTWH(
      topRect.left,
      topRect.top,
      topRect.width,
      topSheenH,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        topSheenRect,
        topLeft: Radius.circular(s * 0.045),
        topRight: Radius.circular(s * 0.045),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: _isDark ? 0.18 : 0.45),
            Colors.white.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(topSheenRect),
    );

    // Hairline border.
    canvas.drawRRect(
      topRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = hairline,
    );

    // Bright top edge highlight.
    canvas.drawLine(
      Offset(topRect.left + s * 0.05, topRect.top + 0.5),
      Offset(topRect.right - s * 0.05, topRect.top + 0.5),
      Paint()
        ..color = edgeHighlight
        ..strokeWidth = 0.6,
    );

    canvas.restore();
  }

  /// One stem card — drop shadow handled separately for the deepest card,
  /// the rest only need fill + sheen + edges so they read as a stack.
  void _drawStemCard(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required double cornerRadius,
    required List<Color> colors,
    required Color edgeHighlight,
    required Color border,
    required double sheenAlpha,
  }) {
    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    // Card fill.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    // Top sheen (just the upper portion).
    final sheenH = height * 0.30;
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
            Colors.white.withValues(alpha: sheenAlpha),
            Colors.white.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(sheenRect),
    );

    // Hairline border.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = border,
    );

    // Bright top edge highlight.
    canvas.drawLine(
      Offset(rect.left + cornerRadius * 0.6, rect.top + 0.4),
      Offset(rect.right - cornerRadius * 0.6, rect.top + 0.4),
      Paint()
        ..color = edgeHighlight
        ..strokeWidth = 0.5,
    );
  }

  /// Suggests mountain peaks within the top card without being literal.
  void _drawMountainPeaks(
    Canvas canvas,
    Rect rect, {
    required bool isDark,
    required bool monochrome,
  }) {
    final farPeakColor = monochrome
        ? const Color(0xFF8B95AB).withValues(alpha: 0.45)
        : (isDark
            ? const Color(0xFF252B38).withValues(alpha: 0.65)
            : const Color(0xFF6E768D).withValues(alpha: 0.45));

    final nearPeakColor = monochrome
        ? const Color(0xFF52596C).withValues(alpha: 0.85)
        : (isDark
            ? const Color(0xFF0B0E16).withValues(alpha: 0.85)
            : const Color(0xFF424A5F).withValues(alpha: 0.85));

    // Far range — soft hazy peaks, lower contrast.
    final farPath = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.center.dy + rect.height * 0.18)
      ..lineTo(rect.left + rect.width * 0.22, rect.center.dy - rect.height * 0.05)
      ..lineTo(rect.left + rect.width * 0.40, rect.center.dy + rect.height * 0.10)
      ..lineTo(rect.left + rect.width * 0.55, rect.center.dy - rect.height * 0.02)
      ..lineTo(rect.left + rect.width * 0.72, rect.center.dy + rect.height * 0.12)
      ..lineTo(rect.left + rect.width * 0.88, rect.center.dy + rect.height * 0.02)
      ..lineTo(rect.right, rect.center.dy + rect.height * 0.20)
      ..lineTo(rect.right, rect.bottom)
      ..close();
    canvas.drawPath(farPath, Paint()..color = farPeakColor);

    // Near range — darker, sharper, foreground.
    final nearPath = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.center.dy + rect.height * 0.32)
      ..lineTo(rect.left + rect.width * 0.18, rect.center.dy + rect.height * 0.18)
      ..lineTo(rect.left + rect.width * 0.32, rect.center.dy + rect.height * 0.30)
      ..lineTo(rect.left + rect.width * 0.50, rect.center.dy + rect.height * 0.16)
      ..lineTo(rect.left + rect.width * 0.68, rect.center.dy + rect.height * 0.28)
      ..lineTo(rect.left + rect.width * 0.84, rect.center.dy + rect.height * 0.20)
      ..lineTo(rect.right, rect.center.dy + rect.height * 0.34)
      ..lineTo(rect.right, rect.bottom)
      ..close();
    canvas.drawPath(nearPath, Paint()..color = nearPeakColor);
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) {
    return oldDelegate.brightness != brightness ||
        oldDelegate.monochrome != monochrome;
  }
}
