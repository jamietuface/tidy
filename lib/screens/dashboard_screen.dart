import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/active_tab_provider.dart';
import '../core/theme/tidy_brand_palette.dart';
import '../features/ai/group_counts_provider.dart';
import '../features/subscriptions/subscription.dart';
import '../features/subscriptions/subscriptions_repository.dart';
import '../features/swipe/group_type.dart';
import '../features/swipe/photo_decisions_repository.dart';
import '../services/auth_service.dart';
import '../shared/widgets/tidy_logo_mark.dart';

/// Home tab — the Tidy command centre. Calm, premium, real data.
///
/// Reads existing providers (no new repositories). Anywhere a data source
/// isn't yet available, falls back to a sensible empty state with a TODO.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // brand.background is pure black on dark — swap to soft navy so the
    // pearl/glass cards have something to lift off of.
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
              padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(),
                  SizedBox(height: 24),
                  _TodayCleanupCard(),
                  SizedBox(height: 14),
                  _TidyAssistStrip(),
                  SizedBox(height: 14),
                  _AppSpendCard(),
                  SizedBox(height: 14),
                  _AiGroupsCard(),
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
// Background halos (dark mode only) — restrained, never neon.

class _DashboardHalos extends StatelessWidget {
  const _DashboardHalos();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: -120,
          left: -80,
          child: _Halo(color: Color(0xFF007AFF), alpha: 0.12, size: 380),
        ),
        Positioned(
          bottom: -140,
          right: -100,
          child: _Halo(color: Color(0xFF5856D6), alpha: 0.10, size: 420),
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
// Header — contextual greeting + small logo mark.

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _firstName(WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final name = user?.displayName?.trim();
    if (name == null || name.isEmpty) return 'there';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
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
              const SizedBox(height: 2),
              Text(
                _firstName(ref),
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
// Hero card — Today's cleanup.

class _TodayCleanupCard extends ConsumerWidget {
  const _TodayCleanupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // TODO(tidy): scope stats to today once photo_decisions exposes a
    // day-filtered query. For now we show lifetime decision counts.
    final stats =
        ref.watch(decisionStatsProvider).asData?.value ?? DecisionStats.empty;

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
              'Keep your library light',
              style: TextStyle(
                color: brand.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    icon: CupertinoIcons.checkmark_circle,
                    label: 'Photos reviewed',
                    value: '${stats.kept + stats.deleted}',
                    tint: brand.blue,
                  ),
                ),
                _StatDivider(isDark: isDark, brand: brand),
                Expanded(
                  child: _StatColumn(
                    icon: CupertinoIcons.trash,
                    label: 'Marked to delete',
                    value: '${stats.deleted}',
                    tint: brand.danger,
                  ),
                ),
                _StatDivider(isDark: isDark, brand: brand),
                Expanded(
                  child: _StatColumn(
                    icon: CupertinoIcons.arrow_down_circle,
                    label: 'Storage to free',
                    value: stats.bytesFreed == 0
                        ? '0 KB'
                        : stats.spaceFreedDisplay,
                    tint: brand.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _PrimaryCta(
              label: 'Start tidying',
              icon: CupertinoIcons.arrow_right,
              onTap: () => ref
                  .read(activeHomeTabProvider.notifier)
                  .state = HomeTab.photos,
            ),
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
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
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

// ───────────────────────────────────────────────────────────────────────────
// Tidy Assist — compact teaser strip. Tap shows a coming-soon snackbar.

class _TidyAssistStrip extends StatelessWidget {
  const _TidyAssistStrip();

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // TODO(tidy): rotate suggestion copy from actual library/group data
    // once the assistant feature ships.
    const headline = 'Find the best photo from my beach trip';
    const suggestion = '48 blurry photos are likely safe to delete';

    return _CardSurface(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidy Assist is coming soon'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: brand.blue.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.search,
                  size: 20,
                  color: brand.blue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tidy Assist',
                          style: TextStyle(
                            color: brand.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                brand.blue.withValues(alpha: isDark ? 0.18 : 0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Soon',
                            style: TextStyle(
                              color: brand.blue,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: brand.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      suggestion,
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
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: brand.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// App spend — live subscriptions total + free plan caption.

class _AppSpendCard extends ConsumerWidget {
  const _AppSpendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subsAsync = ref.watch(subscriptionsProvider);
    final subs = subsAsync.asData?.value ?? const <Subscription>[];

    // TODO(tidy): convert annual prices to a monthly equivalent once the
    // subscription model stores a billing period. For now we sum prices as
    // declared (treated as monthly by the existing add-subscription sheet).
    final active = subs.where((s) => s.status == 'active').toList();
    final monthlyTotal = active.fold<double>(0, (sum, s) => sum + s.price);
    final caption = active.isEmpty
        ? 'Free plan: 3 tracked apps'
        : '${active.length} of 3 tracked';

    return _CardSurface(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            ref.read(activeHomeTabProvider.notifier).state = HomeTab.apps,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'App spend',
                      style: TextStyle(
                        color: brand.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'This month',
                      style: TextStyle(
                        color: brand.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (active.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _SubChips(subs: active.take(3).toList()),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '£${monthlyTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: brand.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    style: TextStyle(
                      color: brand.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.35)
                        : brand.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubChips extends StatelessWidget {
  const _SubChips({required this.subs});
  final List<Subscription> subs;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: subs.map((s) {
        final color = _parseHex(s.colorHex) ?? brand.blue;
        final initial = s.name.isEmpty ? '?' : s.name.characters.first.toUpperCase();
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.20 : 0.14),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: color.withValues(alpha: 0.32),
              width: 0.5,
            ),
          ),
          child: Text(
            initial,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        );
      }).toList(),
    );
  }

  static Color? _parseHex(String? hex) {
    if (hex == null) return null;
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    final v = int.tryParse(h, radix: 16);
    return v == null ? null : Color(v);
  }
}

// ───────────────────────────────────────────────────────────────────────────
// AI groups — list view, taps the existing /swipe/group route.

class _AiGroupsCard extends ConsumerWidget {
  const _AiGroupsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countsAsync = ref.watch(groupCountsProvider);
    final loading = countsAsync.isLoading;

    return _CardSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 8),
              child: Row(
                children: [
                  Text(
                    'AI groups',
                    style: TextStyle(
                      color: brand.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Review and clean',
                    style: TextStyle(
                      color: brand.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < GroupType.values.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 50,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : brand.cardBorderSubtle,
                ),
              _GroupRow(
                group: GroupType.values[i],
                loading: loading,
                count: countsAsync.asData?.value.scaledFor(GroupType.values[i]) ?? 0,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.group,
    required this.loading,
    required this.count,
  });
  final GroupType group;
  final bool loading;
  final int count;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(
        '/swipe/group',
        extra: {'type': group, 'count': count},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: group.color.withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(group.icon, size: 18, color: group.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                group.shortLabel,
                style: TextStyle(
                  color: brand.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CupertinoActivityIndicator(
                  color: brand.textMuted,
                  radius: 7,
                ),
              )
            else
              Text(
                '$count',
                style: TextStyle(
                  color: brand.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: brand.textMuted,
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(22),
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
