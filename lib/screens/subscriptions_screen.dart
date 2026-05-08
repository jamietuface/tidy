import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/subscriptions/add_subscription_sheet.dart';
import '../features/subscriptions/subscription.dart';
import '../features/subscriptions/subscriptions_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/tidy_card.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : AppColors.systemGray6;
    final subs = ref.watch(subscriptionsProvider);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Apps'),
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  CupertinoIcons.add,
                  color: isDark ? Colors.white : Colors.black,
                ),
                tooltip: 'Add subscription',
                onPressed: () => showAddSubscriptionSheet(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: subs.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CupertinoActivityIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: Text(
                      'Could not load subscriptions',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              data: (items) => SliverList(
                delegate: SliverChildListDelegate([
                  _SpendSummaryCard(isDark: isDark, subs: items),
                  const SizedBox(height: 24),
                  if (items.isEmpty)
                    _EmptyState(isDark: isDark)
                  else ...[
                    const SectionHeader(title: 'Recently Used'),
                    const SizedBox(height: 10),
                    TidyCard(
                      child: Column(
                        children: items.asMap().entries.map((e) {
                          final isLast = e.key == items.length - 1;
                          return Column(children: [
                            _AppRow(sub: e.value),
                            if (!isLast)
                              Divider(
                                height: 0.5,
                                indent: 68,
                                color: isDark
                                    ? const Color(0xFF38383A)
                                    : const Color(0xFFE5E5EA),
                              ),
                          ]);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_cancelCandidate(items) != null)
                      _CancelTipCard(
                        isDark: isDark,
                        candidate: _cancelCandidate(items)!,
                      ),
                  ],
                  const SizedBox(height: 32),
                ]),
              ),
            ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.app_badge,
            size: 48,
            color: fg.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 14),
          Text(
            'No subscriptions yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: fg.withValues(alpha: 0.55),
                ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => showAddSubscriptionSheet(context),
            icon: const Icon(CupertinoIcons.add, size: 18),
            label: const Text('Add subscription'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.systemBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendSummaryCard extends StatelessWidget {
  const _SpendSummaryCard({required this.isDark, required this.subs});
  final bool isDark;
  final List<Subscription> subs;

  @override
  Widget build(BuildContext context) {
    final total = subs
        .where((s) => s.status == 'active')
        .fold<double>(0, (sum, s) => sum + s.price);
    final currency = subs.isNotEmpty ? subs.first.currency : 'GBP';
    final symbol = _symbol(currency);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E)]
              : [Colors.white, const Color(0xFFF8F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 0, spreadRadius: 0.5),
                BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 8),
              ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Monthly Spend',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.4),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '$symbol${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subs.isEmpty
              ? 'No active subscriptions'
              : '${subs.where((s) => s.status == 'active').length} active subscription${subs.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.35),
              ),
        ),
      ]),
    );
  }

  static String _symbol(String code) {
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
}

class _CancelTipCard extends StatelessWidget {
  const _CancelTipCard({required this.isDark, required this.candidate});
  final bool isDark;
  final Subscription candidate;

  @override
  Widget build(BuildContext context) {
    final daysAgo = DateTime.now().difference(candidate.lastUsed!).inDays;
    final saving = '${_SpendSummaryCard._symbol(candidate.currency)}'
        '${candidate.price.toStringAsFixed(2)}';
    return TidyCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.systemOrange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            CupertinoIcons.lightbulb_fill,
            color: AppColors.systemOrange,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Cancel ${candidate.name}?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'Last used $daysAgo days ago · saves $saving/mo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.4),
                  ),
            ),
          ]),
        ),
        Icon(
          CupertinoIcons.chevron_right,
          size: 14,
          color: isDark
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.2),
        ),
      ]),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.sub});
  final Subscription sub;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _color(sub.colorHex) ?? AppColors.systemBlue;
    final icon = _icon(sub.iconName);
    final lastUsed = _formatLastUsed(sub.lastUsed);
    final symbol = _SpendSummaryCard._symbol(sub.currency);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sub.name, style: Theme.of(context).textTheme.titleSmall),
            Text(
              lastUsed,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.4),
                  ),
            ),
          ]),
        ),
        Text(
          '$symbol${sub.price.toStringAsFixed(2)}/mo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ]),
    );
  }

  static Color? _color(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.replaceAll('#', '');
    final value = int.tryParse(clean, radix: 16);
    if (value == null) return null;
    return Color(clean.length == 6 ? 0xFF000000 | value : value);
  }

  static IconData _icon(String? key) {
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
      default:
        return CupertinoIcons.app_fill;
    }
  }

  static String _formatLastUsed(DateTime? lastUsed) {
    if (lastUsed == null) return 'Never used';
    final diff = DateTime.now().difference(lastUsed);
    if (diff.inDays == 0) return 'Last used today';
    if (diff.inDays == 1) return 'Last used yesterday';
    if (diff.inDays < 7) return 'Last used ${diff.inDays} days ago';
    if (diff.inDays < 30) return 'Last used ${(diff.inDays / 7).floor()} weeks ago';
    return 'Last used ${(diff.inDays / 30).floor()} months ago';
  }
}
