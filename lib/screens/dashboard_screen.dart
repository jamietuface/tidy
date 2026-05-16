import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/active_tab_provider.dart';
import '../core/theme/tidy_brand_palette.dart';
import '../features/ai/group_counts_provider.dart';
import '../features/subscriptions/subscription.dart';
import '../features/subscriptions/subscriptions_repository.dart';
import '../features/swipe/group_type.dart';
import '../features/swipe/photo_decisions_repository.dart';
import '../services/auth_service.dart';
import '../shared/widgets/tidy_logo_mark.dart';

/// Home tab — calm product dashboard. Intentionally NOT a duplicate of the
/// Photos tab: shows status + entry points only.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // brand.background is pure black on dark — swap to soft navy.
    final bg = isDark ? const Color(0xFF05070B) : brand.background;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          if (isDark)
            const Positioned.fill(
              child: IgnorePointer(child: _DashboardHalos()),
            ),
          const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(),
                  SizedBox(height: 28),
                  _CleanupHeroCard(),
                  SizedBox(height: 18),
                  _MiniCardsRow(),
                  SizedBox(height: 18),
                  _PhotosToReviewStrip(),
                  SizedBox(height: 18),
                  _TidyAssistLine(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Background halos (dark mode only).

class _DashboardHalos extends StatelessWidget {
  const _DashboardHalos();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: -120, left: -80,
          child: _Halo(color: Color(0xFF007AFF), alpha: 0.10, size: 380),
        ),
        Positioned(
          bottom: -140, right: -100,
          child: _Halo(color: Color(0xFF5856D6), alpha: 0.08, size: 420),
        ),
      ],
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.color, required this.alpha, required this.size});
  final Color color;
  final double alpha;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ]),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Header — greeting + (first name | "Welcome back") + small logo.

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  /// First name from displayName, or null when nothing usable is set.
  String? _firstName(WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final name = user?.displayName?.trim();
    if (name == null || name.isEmpty) return null;
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final name = _firstName(ref);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: TextStyle(
                  color: brand.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name ?? 'Welcome back',
                style: TextStyle(
                  color: brand.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
        const TidyLogoMark(size: 38),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Hero — Today's cleanup status: 3 stats + Start tidying + (Review selected).

class _CleanupHeroCard extends ConsumerWidget {
  const _CleanupHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // TODO(tidy): scope to today once photo_decisions exposes a day filter.
    final stats =
        ref.watch(decisionStatsProvider).asData?.value ?? DecisionStats.empty;
    // Existing repo: `bytesFreed` is sum of sizeBytes for decision==deleted.
    // That is "ready to delete" semantically — permanent freeing isn't
    // tracked yet, so Freed stays at 0 with a TODO below.
    final markedCount = stats.deleted;
    final readyBytes = stats.bytesFreed;
    // TODO(tidy): track permanentlyFreedBytes after PhotoDeletionService
    // confirms a successful Apple Photos writeback per asset id.
    const freedBytes = 0;

    return _CardSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's cleanup",
              style: TextStyle(
                color: brand.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your photo cleanup status',
              style: TextStyle(
                color: brand.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    icon: CupertinoIcons.checkmark_alt_circle,
                    label: 'Marked',
                    value: '$markedCount',
                    tint: brand.blue,
                  ),
                ),
                _StatDivider(isDark: isDark, brand: brand),
                Expanded(
                  child: _StatColumn(
                    icon: CupertinoIcons.tray_arrow_down,
                    label: 'Ready to delete',
                    value: _formatBytes(readyBytes),
                    tint: brand.danger,
                  ),
                ),
                _StatDivider(isDark: isDark, brand: brand),
                Expanded(
                  child: _StatColumn(
                    icon: CupertinoIcons.check_mark_circled,
                    label: 'Freed',
                    value: _formatBytes(freedBytes),
                    tint: brand.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _PrimaryCta(
              label: 'Start tidying',
              icon: CupertinoIcons.arrow_right,
              onTap: () => ref
                  .read(activeHomeTabProvider.notifier)
                  .state = HomeTab.photos,
            ),
            if (markedCount > 0) ...[
              const SizedBox(height: 10),
              _SecondaryCta(
                label: 'Review selected ($markedCount)',
                onTap: () {
                  ref.read(activeHomeTabProvider.notifier).state =
                      HomeTab.photos;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review selected photos from Photos'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // TODO(tidy): replace with a dedicated "Ready to delete"
                  // review screen that ends in PhotoDeletionService.deleteFromLibrary
                  // with iOS's native confirmation.
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: tint),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: brand.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: brand.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.05,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.isDark, required this.brand});
  final bool isDark;
  final TidyBrandPalette brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 44,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : brand.cardBorderSubtle,
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [brand.blue, brand.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: brand.blue.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SecondaryCta extends StatelessWidget {
  const _SecondaryCta({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : brand.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : brand.cardBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: brand.blue,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Two mini cards — Ready to delete + App spend.

class _MiniCardsRow extends ConsumerWidget {
  const _MiniCardsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats =
        ref.watch(decisionStatsProvider).asData?.value ?? DecisionStats.empty;
    final subs = ref.watch(subscriptionsProvider).asData?.value ??
        const <Subscription>[];
    final active = subs.where((s) => s.status == 'active').toList();
    // TODO(tidy): convert annual prices to monthly equivalent once the
    // subscription model stores a billing period.
    final monthlyTotal = active.fold<double>(0, (sum, s) => sum + s.price);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _MiniCard(
            label: 'Ready to delete',
            primary: '${stats.deleted}',
            secondary: stats.deleted == 0
                ? 'No photos waiting'
                : _formatBytes(stats.bytesFreed),
            icon: CupertinoIcons.tray_arrow_down,
            tint: const Color(0xFFFF3B30),
            onTap: () {
              ref.read(activeHomeTabProvider.notifier).state =
                  HomeTab.photos;
              if (stats.deleted > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review selected photos from Photos'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniCard(
            label: 'App spend',
            primary: '£${monthlyTotal.toStringAsFixed(2)}',
            secondary: _activeAppsLabel(active.length),
            icon: CupertinoIcons.square_grid_2x2,
            tint: const Color(0xFF5856D6),
            onTap: () => ref
                .read(activeHomeTabProvider.notifier)
                .state = HomeTab.apps,
          ),
        ),
      ],
    );
  }

  static String _activeAppsLabel(int count) {
    if (count == 0) return '0 active apps';
    if (count == 1) return '1 active app';
    return '$count active apps';
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.label,
    required this.primary,
    required this.secondary,
    required this.icon,
    required this.tint,
    required this.onTap,
  });
  final String label;
  final String primary;
  final String secondary;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _CardSurface(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, size: 16, color: tint),
                  ),
                  const Spacer(),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 13,
                    color: brand.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                primary,
                style: TextStyle(
                  color: brand.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: brand.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.05,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                secondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: brand.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Compact "Photos to review" strip — summary + View groups action.

class _PhotosToReviewStrip extends ConsumerWidget {
  const _PhotosToReviewStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counts = ref.watch(groupCountsProvider).asData?.value;
    final total = counts == null
        ? null
        : GroupType.values
            .fold<int>(0, (sum, g) => sum + counts.scaledFor(g));

    final caption = total == null
        ? 'Blurry, duplicates, screenshots, and old photos'
        : total == 0
            ? 'No grouped photos right now'
            : '$total grouped photos ready';

    return _CardSurface(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref
            .read(activeHomeTabProvider.notifier)
            .state = HomeTab.photos,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: brand.blue.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.square_stack_3d_up_fill,
                  size: 17,
                  color: brand.blue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Photos to review',
                      style: TextStyle(
                        color: brand.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: brand.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'View groups',
                style: TextStyle(
                  color: brand.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: brand.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Tidy Assist — single-line suggestion. No card chrome.

class _TidyAssistLine extends ConsumerWidget {
  const _TidyAssistLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final counts = ref.watch(groupCountsProvider).asData?.value;
    final blurry = counts?.scaledFor(GroupType.blurry) ?? 0;

    // TODO(tidy): rotate suggestions based on real library state.
    final suggestion = blurry > 0
        ? '$blurry blurry photos may be safe to delete.'
        : 'Start with grouped photos to clean faster.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.lightbulb,
            size: 14,
            color: brand.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: brand.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.05,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Tidy Assist: ',
                    style: TextStyle(
                      color: brand.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: suggestion),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Shared card surface — pearl in light, soft glass in dark.

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : brand.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : brand.cardBorder,
          width: 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF1A2540).withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Local byte formatter — < 1 MB → KB, < 1 GB → MB (1 dp), else GB (1 dp).

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 MB';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).round()} KB';
  }
  final mb = bytes / (1024 * 1024);
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  return '${(mb / 1024).toStringAsFixed(1)} GB';
}
