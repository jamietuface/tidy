import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/tidy_brand_palette.dart';
import '../core/theme/tidy_theme.dart';
import '../core/theme/tidy_theme_mode_controller.dart';
import '../shared/widgets/tidy_brand_lockup.dart';
import '../shared/widgets/tidy_logo_mark.dart';
import '../shared/widgets/tidy_wordmark.dart';

class BrandPreviewScreen extends ConsumerWidget {
  const BrandPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: brand.background,
      appBar: AppBar(
        backgroundColor: brand.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_back, color: brand.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Brand Preview',
          style: TextStyle(
            color: brand.textPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Light logo. System-aware theme.',
              style: TextStyle(
                color: brand.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 28),
            const _ThemeModePicker(),
            const SizedBox(height: 36),
            _Hero(isDark: isDark),
            const SizedBox(height: 36),
            const _SectionLabel('HORIZONTAL LOCKUP'),
            const SizedBox(height: 14),
            const Center(
              child: TidyBrandLockup(
                axis: TidyBrandLockupAxis.horizontal,
                size: TidyBrandLockupSize.large,
              ),
            ),
            const SizedBox(height: 36),
            const _SectionLabel('LOGO MARK SIZES'),
            const SizedBox(height: 14),
            const _LogoSizesRow(sizes: [32, 64, 96, 128]),
            const SizedBox(height: 36),
            const _SectionLabel('WORDMARK SIZES'),
            const SizedBox(height: 14),
            const _WordmarkSizes(),
            const SizedBox(height: 36),
            const _SectionLabel('SURFACES'),
            const SizedBox(height: 14),
            const _SurfacePreview(forceBrightness: Brightness.light),
            const SizedBox(height: 14),
            const _SurfacePreview(forceBrightness: Brightness.dark),
            const SizedBox(height: 36),
            const _SectionLabel('COMPONENT TOKENS'),
            const SizedBox(height: 14),
            const _ComponentPreview(),
            const SizedBox(height: 36),
            _CopyBlock(brand: brand),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero card — large vertical lockup centered on a brand surface card.

class _Hero extends StatelessWidget {
  const _Hero({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: brand.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.cardBorderSubtle, width: 0.5),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: const Color(0xFF1A2540).withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: const Center(
        child: TidyBrandLockup(
          axis: TidyBrandLockupAxis.vertical,
          size: TidyBrandLockupSize.large,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme mode picker — calls the real controller.

class _ThemeModePicker extends ConsumerWidget {
  const _ThemeModePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final current = ref.watch(tidyThemeModeControllerProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: brand.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brand.cardBorderSubtle, width: 0.5),
      ),
      child: Row(
        children: TidyThemePreference.values.map((p) {
          final selected = p == current;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  ref.read(tidyThemeModeControllerProvider.notifier).set(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? brand.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  border: selected
                      ? Border.all(color: brand.cardBorder, width: 0.5)
                      : null,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1A2540)
                                .withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  p.displayLabel,
                  style: TextStyle(
                    color: selected ? brand.textPrimary : brand.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo mark sizes row.

class _LogoSizesRow extends StatelessWidget {
  const _LogoSizesRow({required this.sizes});
  final List<double> sizes;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.cardBorder, width: 0.5),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 16,
        runSpacing: 16,
        children: sizes.map((s) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TidyLogoMark(size: s),
              const SizedBox(height: 8),
              Text(
                '${s.toInt()}',
                style: TextStyle(
                  color: brand.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wordmark sizes.

class _WordmarkSizes extends StatelessWidget {
  const _WordmarkSizes();

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.cardBorder, width: 0.5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WordmarkRow(label: 'small', size: 18),
          SizedBox(height: 18),
          _WordmarkRow(label: 'medium', size: 28),
          SizedBox(height: 18),
          _WordmarkRow(label: 'large', size: 48),
        ],
      ),
    );
  }
}

class _WordmarkRow extends StatelessWidget {
  const _WordmarkRow({required this.label, required this.size});
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: brand.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ),
        TidyWordmark(fontSize: size),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Surface preview — embeds a forced-brightness Theme so we can show the
// logo on both light and dark surfaces regardless of current app theme.

class _SurfacePreview extends StatelessWidget {
  const _SurfacePreview({required this.forceBrightness});
  final Brightness forceBrightness;

  @override
  Widget build(BuildContext context) {
    final isDark = forceBrightness == Brightness.dark;
    final innerTheme = isDark ? TidyTheme.dark() : TidyTheme.light();
    final innerBrand = isDark ? TidyBrandPalette.dark : TidyBrandPalette.light;

    return Theme(
      data: innerTheme,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: innerBrand.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: innerBrand.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const TidyLogoMark(size: 64),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TidyWordmark(fontSize: 24),
                  const SizedBox(height: 6),
                  Text(
                    isDark ? 'On dark surface' : 'On light surface',
                    style: TextStyle(
                      color: innerBrand.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Component tokens preview.

class _ComponentPreview extends StatelessWidget {
  const _ComponentPreview();

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrimaryButton(label: 'Continue', brand: brand),
          const SizedBox(height: 12),
          _SecondaryButton(label: 'Maybe later', brand: brand),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: 'Selected', selected: true, brand: brand),
              _Chip(label: 'Unselected', selected: false, brand: brand),
              _Chip(label: 'Photos', selected: false, brand: brand),
              _Chip(label: 'Apps', selected: true, brand: brand),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.brand});
  final String label;
  final TidyBrandPalette brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [brand.blue, brand.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: brand.blue.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.brand});
  final String label;
  final TidyBrandPalette brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: brand.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brand.cardBorder, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: brand.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.brand,
  });
  final String label;
  final bool selected;
  final TidyBrandPalette brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? brand.blue.withValues(alpha: 0.14) : brand.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? brand.blue.withValues(alpha: 0.50) : brand.cardBorder,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? brand.blue : brand.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label + closing copy.

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: brand.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _CopyBlock extends StatelessWidget {
  const _CopyBlock({required this.brand});
  final TidyBrandPalette brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brand.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brand.cardBorderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tidy follows your phone’s appearance by default.',
            style: TextStyle(
              color: brand.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You can override this in Settings.',
            style: TextStyle(
              color: brand.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
