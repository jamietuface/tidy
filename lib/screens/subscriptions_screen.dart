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
    final theme = Theme.of(context);
    final ext = theme.extension<TidyThemeExtension>()!;

    return Scaffold(
      backgroundColor: ext.groupedBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Apps'),
            backgroundColor: ext.groupedBackground,
            surfaceTintColor: Colors.transparent,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Spending summary
                TidyCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Monthly Spend', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.systemGray)),
                    const SizedBox(height: 4),
                    Text('£40.96', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.68,
                        backgroundColor: AppColors.systemGray5,
                        valueColor: const AlwaysStoppedAnimation(AppColors.systemBlue),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('£27.84 used this month', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.systemGray)),
                  ]),
                ),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Recently Used'),
                const SizedBox(height: 8),
                TidyCard(
                  child: Column(
                    children: _mockApps.asMap().entries.map((e) {
                      final isLast = e.key == _mockApps.length - 1;
                      return Column(children: [
                        _AppRow(app: e.value),
                        if (!isLast) const Divider(height: 1, indent: 68),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Save money tip
                TidyCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.systemGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.lightbulb_fill, color: AppColors.systemGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Cancel Headspace?', style: theme.textTheme.titleSmall),
                      Text('Last used 3 weeks ago • saves £12.99/mo', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.systemGray)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: app.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(app.icon, color: app.color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(app.name, style: Theme.of(context).textTheme.titleSmall),
          Text('Last used ${app.lastUsed}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.systemGray)),
        ])),
        Text(app.price, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
