import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tidy_card.dart';
import '../widgets/section_header.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> with SingleTickerProviderStateMixin {
  double _dragX = 0;
  late AnimationController _snapController;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TidyThemeExtension>()!;

    return Scaffold(
      backgroundColor: ext.groupedBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Tidy'),
            backgroundColor: ext.groupedBackground,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.slider_horizontal_3),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // AI Groups
                const SectionHeader(title: 'AI Groups'),
                const SizedBox(height: 8),
                _AIGroupsRow(),
                const SizedBox(height: 24),

                // Stats
                const SectionHeader(title: 'This Week'),
                const SizedBox(height: 8),
                TidyCard(
                  child: Column(children: [
                    _StatRow(CupertinoIcons.checkmark_circle_fill, AppColors.systemGreen, 'Kept', '0'),
                    const Divider(height: 1, indent: 44),
                    _StatRow(CupertinoIcons.trash, AppColors.systemRed, 'Deleted', '0'),
                    const Divider(height: 1, indent: 44),
                    _StatRow(CupertinoIcons.cloud, AppColors.systemBlue, 'Space Freed', '0 MB'),
                  ]),
                ),
                const SizedBox(height: 24),

                // Start swiping CTA
                _SwipeCTA(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIGroupsRow extends StatelessWidget {
  final groups = const [
    ('Blurry', CupertinoIcons.rays, AppColors.systemOrange),
    ('Screenshots', CupertinoIcons.device_phone_portrait, AppColors.systemBlue),
    ('Duplicates', CupertinoIcons.square_on_square, AppColors.systemPurple),
    ('Old', CupertinoIcons.clock, AppColors.systemGray),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final (label, icon, color) = groups[i];
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          );
        },
      ),
    );
  }
}

class _SwipeCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.systemBlue, AppColors.systemIndigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Start Tidying', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('0 photos ready to review', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15)),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.systemBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Swipe Photos', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.icon, this.color, this.label, this.value);
  final IconData icon;
  final Color color;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
        Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.systemGray)),
      ]),
    );
  }
}
