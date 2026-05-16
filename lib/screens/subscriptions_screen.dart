import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tidy_brand_palette.dart';
import '../features/subscriptions/add_subscription_sheet.dart';
import '../features/subscriptions/subscription.dart';
import '../features/subscriptions/subscriptions_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Apps tab — adapts to the active theme. Metallic dark in dark mode,
/// airy pearl in light mode. Brand-coloured spend summary card and add
/// CTA read well on either background.
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(subscriptionsProvider);
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: brand.background,
      body: Stack(
        children: [
          // Halos only in dark — pearl page should stay clean.
          if (isDark)
            const Positioned.fill(
              child: IgnorePointer(child: _GlowHalos()),
            ),
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(
                  'Apps',
                  style: TextStyle(
                    color: brand.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                foregroundColor: brand.textPrimary,
                actions: [
                  IconButton(
                    icon: Icon(CupertinoIcons.add, color: brand.textPrimary),
                    tooltip: 'Add subscription',
                    onPressed: () => showAddSubscriptionSheet(context),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: subs.when(
                  loading: () => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: CupertinoActivityIndicator(
                          color: brand.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: Text(
                          'Could not load subscriptions',
                          style: TextStyle(
                            color: brand.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  data: (items) => SliverList(
                    delegate: SliverChildListDelegate([
                      _SpendSummaryCard(subs: items),
                      const SizedBox(height: 28),
                      if (items.isEmpty)
                        const _EmptyState()
                      else ...[
                        const _SectionHeader('RECENTLY USED'),
                        const SizedBox(height: 14),
                        _AppsList(items: items),
                        const SizedBox(height: 24),
                        if (_cancelCandidate(items) != null)
                          _CancelTipCard(candidate: _cancelCandidate(items)!),
                      ],
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Subscription? _cancelCandidate(List<Subscription> items) {
    final stale = items.where((s) {
      if (s.lastUsed == null) return false;
      return DateTime.now().difference(s.lastUsed!).inDays >= 14;
    }).toList()
      ..sort((a, b) => a.lastUsed!.compareTo(b.lastUsed!));
    return stale.isEmpty ? null : stale.first;
  }
}

class _GlowHalos extends StatelessWidget {
  const _GlowHalos();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -140,
          top: -160,
          width: 380,
          height: 380,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.systemIndigo.withValues(alpha: 0.25),
                  AppColors.systemIndigo.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: -160,
          bottom: -160,
          width: 420,
          height: 420,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.systemBlue.withValues(alpha: 0.20),
                  AppColors.systemBlue.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
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

class _SpendSummaryCard extends StatelessWidget {
  const _SpendSummaryCard({required this.subs});
  final List<Subscription> subs;

  @override
  Widget build(BuildContext context) {
    final total = subs
        .where((s) => s.status == 'active')
        .fold<double>(0, (sum, s) => sum + s.price);
    final currency = subs.isNotEmpty ? subs.first.currency : 'GBP';
    final symbol = symbolFor(currency);
    final activeCount = subs.where((s) => s.status == 'active').length;

    // Brand-coloured gradient — reads well on both light and dark pages.
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withValues(alpha: 0.40),
            offset: const Offset(0, 10),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Top sheen
            Positioned(
              top: 0, left: 0, right: 0, height: 50,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Spend',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$symbol${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activeCount == 0
                      ? '0 active apps'
                      : '$activeCount active app${activeCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppsList extends StatelessWidget {
  const _AppsList({required this.items});
  final List<Subscription> items;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fill = isDark ? Colors.white.withValues(alpha: 0.06) : brand.surface;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.10) : brand.cardBorder;
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : brand.cardBorderSubtle;

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: const Color(0xFF1A2540).withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            if (isDark)
              Positioned(
                top: 0, left: 0, right: 0, height: 30,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(children: [
                  _AppRow(sub: e.value),
                  if (!isLast)
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(left: 72),
                      color: divider,
                    ),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppRow extends ConsumerWidget {
  const _AppRow({required this.sub});
  final Subscription sub;

  void _showActions(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(sub.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              showAddSubscriptionSheet(context, editing: sub);
            },
            child: const Text('Edit'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final confirmed = await showCupertinoDialog<bool>(
                context: context,
                builder: (dctx) => CupertinoAlertDialog(
                  title: Text('Delete ${sub.name}?'),
                  content: const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('This removes the subscription from Tidy. '
                        'It does not cancel the subscription with the provider.'),
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(dctx, false),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.pop(dctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final user = ref.read(authStateProvider).asData?.value;
                if (user != null) {
                  await ref
                      .read(subscriptionsRepositoryProvider)
                      .delete(uid: user.uid, id: sub.id);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = colorFromHex(sub.colorHex) ?? AppColors.systemBlue;
    final icon = iconFromName(sub.iconName);
    final lastUsed = formatLastUsed(sub.lastUsed);
    final symbol = symbolFor(sub.currency);

    final badgeGradient = isDark
        ? [color.withValues(alpha: 0.30), color.withValues(alpha: 0.10)]
        : [color.withValues(alpha: 0.20), color.withValues(alpha: 0.08)];
    final badgeBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : color.withValues(alpha: 0.28);

    return GestureDetector(
      onLongPress: () => _showActions(context, ref),
      onTap: () => _showActions(context, ref),
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: badgeGradient,
            ),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: badgeBorder, width: 0.5),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              sub.name,
              style: TextStyle(
                color: brand.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              lastUsed,
              style: TextStyle(
                color: brand.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ]),
        ),
        Text(
          '$symbol${sub.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: brand.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ]),
      ),
    );
  }
}

class _CancelTipCard extends StatelessWidget {
  const _CancelTipCard({required this.candidate});
  final Subscription candidate;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fill = isDark ? Colors.white.withValues(alpha: 0.06) : brand.surface;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.10) : brand.cardBorder;
    final badgeBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.systemOrange.withValues(alpha: 0.28);

    final daysAgo = DateTime.now().difference(candidate.lastUsed!).inDays;
    final saving = '${symbolFor(candidate.currency)}'
        '${candidate.price.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: const Color(0xFF1A2540).withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.systemOrange.withValues(alpha: 0.30),
                      AppColors.systemOrange.withValues(alpha: 0.10),
                    ]
                  : [
                      AppColors.systemOrange.withValues(alpha: 0.20),
                      AppColors.systemOrange.withValues(alpha: 0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: badgeBorder, width: 0.5),
          ),
          child: const Icon(
            CupertinoIcons.lightbulb_fill,
            color: AppColors.systemOrange,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Cancel ${candidate.name}?',
              style: TextStyle(
                color: brand.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Last used $daysAgo days ago · saves $saving/mo',
              style: TextStyle(
                color: brand.textSecondary,
                fontSize: 13,
              ),
            ),
          ]),
        ),
        Icon(
          CupertinoIcons.chevron_right,
          size: 14,
          color: brand.textMuted,
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.app_badge,
            size: 48,
            color: brand.textMuted,
          ),
          const SizedBox(height: 14),
          Text(
            'No subscriptions yet',
            style: TextStyle(
              color: brand.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () => showAddSubscriptionSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.40),
                    offset: const Offset(0, 6),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.add, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Add subscription',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helpers — exported for reuse from other subscription views.
String symbolFor(String code) {
  switch (code) {
    case 'GBP':
      return '£';
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    default:
      return '$code ';
  }
}

Color? colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final clean = hex.replaceAll('#', '');
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return null;
  return Color(clean.length == 6 ? 0xFF000000 | value : value);
}

IconData iconFromName(String? key) {
  switch (key) {
    case 'play':
      return CupertinoIcons.play_rectangle_fill;
    case 'music':
      return CupertinoIcons.music_note;
    case 'heart':
      return CupertinoIcons.heart_fill;
    case 'book':
      return CupertinoIcons.book_fill;
    case 'cloud':
      return CupertinoIcons.cloud_fill;
    case 'game':
      return CupertinoIcons.gamecontroller_fill;
    case 'tv':
      return CupertinoIcons.tv_fill;
    default:
      return CupertinoIcons.app_fill;
  }
}

String formatLastUsed(DateTime? lastUsed) {
  if (lastUsed == null) return 'Never used';
  final diff = DateTime.now().difference(lastUsed);
  if (diff.inDays == 0) return 'Last used today';
  if (diff.inDays == 1) return 'Last used yesterday';
  if (diff.inDays < 7) return 'Last used ${diff.inDays} days ago';
  if (diff.inDays < 30) return 'Last used ${(diff.inDays / 7).floor()} weeks ago';
  return 'Last used ${(diff.inDays / 30).floor()} months ago';
}
