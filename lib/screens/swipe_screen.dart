import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ai/group_counts_provider.dart';
import '../features/auth/user_repository.dart';
import '../features/swipe/group_type.dart';
import '../features/swipe/photo_decisions_repository.dart';
import '../features/swipe/swipe_card_screen.dart';
import '../theme/app_theme.dart';

/// Metallic-dark home dashboard. Tidy Pro aesthetic: black bg, radial halos,
/// glass cards, glossy gradient CTA. Always dark — independent of system theme.
class SwipeScreen extends ConsumerWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(child: _GlowHalos()),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text(
                  'Tidy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                foregroundColor: Colors.white,
                actions: [
                  if (!isPro)
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.lock_fill,
                        color: AppColors.systemBlue,
                      ),
                      tooltip: 'Unlock Pro',
                      onPressed: () => context.push('/paywall'),
                    )
                  else
                    const _ProPill(),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.slider_horizontal_3,
                      color: Colors.white,
                    ),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _DarkSectionHeader('AI GROUPS'),
                    const SizedBox(height: 14),
                    const _AIGroupsRow(),
                    const SizedBox(height: 32),
                    const _DarkSectionHeader('THIS WEEK'),
                    const SizedBox(height: 14),
                    const _ThisWeekCard(),
                    const SizedBox(height: 32),
                    const _SwipeCTA(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                  AppColors.systemBlue.withValues(alpha: 0.30),
                  AppColors.systemBlue.withValues(alpha: 0),
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
                  AppColors.systemIndigo.withValues(alpha: 0.20),
                  AppColors.systemIndigo.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DarkSectionHeader extends StatelessWidget {
  const _DarkSectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.50),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ProPill extends StatelessWidget {
  const _ProPill();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _AIGroupsRow extends ConsumerWidget {
  const _AIGroupsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(groupCountsProvider);

    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: GroupType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final group = GroupType.values[i];
          final loading = countsAsync.isLoading;
          final count = countsAsync.asData?.value.scaledFor(group) ?? 0;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(
              '/swipe/group',
              extra: {'type': group, 'count': count},
            ),
            child: Column(
              children: [
                _MetallicTile(
                  color: group.color,
                  icon: group.icon,
                  loading: loading,
                  count: count,
                ),
                const SizedBox(height: 10),
                Text(
                  group.shortLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetallicTile extends StatelessWidget {
  const _MetallicTile({
    required this.color,
    required this.icon,
    required this.loading,
    required this.count,
  });

  final Color color;
  final IconData icon;
  final bool loading;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Top sheen
            Positioned(
              top: 0, left: 0, right: 0, height: 24,
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
            Center(child: Icon(icon, color: color, size: 30)),
            if (loading)
              Positioned(
                right: 6,
                top: 6,
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CupertinoActivityIndicator(radius: 6, color: color),
                ),
              ),
            if (!loading && count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.50),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThisWeekCard extends ConsumerWidget {
  const _ThisWeekCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(decisionStatsProvider).asData?.value
        ?? DecisionStats.empty;
    final divider = Colors.white.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Top sheen
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
              children: [
                _StatRow(
                  icon: CupertinoIcons.checkmark_circle_fill,
                  color: AppColors.systemGreen,
                  label: 'Kept',
                  value: '${stats.kept}',
                ),
                Container(height: 0.5, margin: const EdgeInsets.only(left: 60), color: divider),
                _StatRow(
                  icon: CupertinoIcons.trash_fill,
                  color: AppColors.systemRed,
                  label: 'Deleted',
                  value: '${stats.deleted}',
                ),
                Container(height: 0.5, margin: const EdgeInsets.only(left: 60), color: divider),
                _StatRow(
                  icon: CupertinoIcons.cloud_fill,
                  color: AppColors.systemBlue,
                  label: 'Space Freed',
                  value: stats.spaceFreedDisplay,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.30),
                  color.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.50),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeCTA extends StatelessWidget {
  const _SwipeCTA();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (_, __, ___) => const SwipeCardScreen(),
          transitionsBuilder: (_, anim, __, child) {
            final curved =
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                child: child,
              ),
            );
          },
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.45),
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
                top: 0, left: 0, right: 0, height: 60,
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
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          CupertinoIcons.sparkles,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Tidying',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Swipe through your camera roll',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Swipe Photos',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.arrow_right,
                          color: Color(0xFF007AFF),
                          size: 16,
                        ),
                      ],
                    ),
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
