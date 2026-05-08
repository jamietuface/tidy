import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tidy_card.dart';
import '../widgets/section_header.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  static const _mockApps = [
    _AppItem('Netflix', '£10.99/mo', CupertinoIcons.play_rectangle_fill, AppColors.systemRed, '2 days ago'),
    _AppItem('Spotify', '£9.99/mo', CupertinoIcons.music_note, AppColors.systemGreen, '1 day ago'),
    _AppItem('Headspace', '£12.99/mo', CupertinoIcons.heart_fill, AppColors.systemOrange, '3 weeks ago'),
    _AppItem('Duolingo', '£6.99/mo', CupertinoIcons.book_fill, AppColors.systemYellow, '2 months ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : AppColors.systemGray6;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Apps'),
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Spend summary — gradient card
                _SpendSummaryCard(isDark: isDark),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Recently Used'),
                const SizedBox(height: 10),
                TidyCard(
                  child: Column(
                    children: _mockApps.asMap().entries.map((e) {
                      final isLast = e.key == _mockApps.length - 1;
                      return Column(children: [
                        _AppRow(app: e.value),
                        if (!isLast) Divider(
                          height: 0.5,
                          indent: 68,
                          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Cancel tip
                _CancelTipCard(isDark: isDark),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendSummaryCard extends StatelessWidget {
  const _SpendSummaryCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
        boxShadow: isDark ? [] : [
          const BoxShadow(color: Color(0x0A000000), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0.5),
          const BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 8),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Monthly Spend',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '£40.96',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
              FractionallySizedBox(
                widthFactor: 0.68,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '£27.84 used this month',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.35),
          ),
        ),
      ]),
    );
  }
}

class _CancelTipCard extends StatelessWidget {
  const _CancelTipCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
              'Cancel Headspace?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'Last used 3 weeks ago · saves £12.99/mo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ]),
        ),
        Icon(
          CupertinoIcons.chevron_right,
          size: 14,
          color: isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.2),
        ),
      ]),
    );
  }
}

class _AppItem {
  const _AppItem(this.name, this.price, this.icon, this.color, this.lastUsed);
  final String name, price, lastUsed;
  final IconData icon;
  final Color color;
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app});
  final _AppItem app;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: app.color.withValues(alpha: isDark ? 0.18 : 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(app.icon, color: app.color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.name, style: Theme.of(context).textTheme.titleSmall),
            Text(
              'Last used ${app.lastUsed}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ]),
        ),
        Text(
          app.price,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ]),
    );
  }
}
