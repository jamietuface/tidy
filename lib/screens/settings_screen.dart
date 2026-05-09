import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/auth/user_repository.dart';
import '../services/auth_service.dart';
import '../shared/widgets/tidy_confirm_dialog.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final isPro = ref.watch(isProProvider);
    final email = user?.email;
    final isAnon = user?.isAnonymous ?? true;

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
                  'Settings',
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
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _SectionLabel('ACCOUNT'),
                    const SizedBox(height: 10),
                    _GlassCard(
                      children: [
                        _SettingRow(
                          label: isAnon ? 'Guest' : (email ?? 'Signed in'),
                          icon: CupertinoIcons.person_fill,
                          color: AppColors.systemBlue,
                        ),
                        _Divider(),
                        _SettingRow(
                          label: 'Plan',
                          icon: isPro
                              ? CupertinoIcons.sparkles
                              : CupertinoIcons.lock_fill,
                          color: isPro
                              ? AppColors.systemIndigo
                              : AppColors.systemGray,
                          trailing: _PlanBadge(isPro: isPro),
                          onTap: isPro ? null : () => context.push('/paywall'),
                        ),
                        _Divider(),
                        _SettingRow(
                          label: 'Sign out',
                          icon: CupertinoIcons.square_arrow_right,
                          color: AppColors.systemRed,
                          destructive: true,
                          onTap: () async {
                            final confirmed = await showTidyConfirmDialog(
                              context: context,
                              title: 'Sign out?',
                              message:
                                  'You will be signed out of this device. Your data stays in the cloud.',
                              confirmLabel: 'Sign out',
                            );
                            if (confirmed == true) {
                              await ref.read(authServiceProvider).signOut();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _SectionLabel('NOTIFICATIONS'),
                    const SizedBox(height: 10),
                    const _GlassCard(
                      children: [
                        _SettingRow(
                          label: 'Renewal reminders',
                          icon: CupertinoIcons.bell_fill,
                          color: AppColors.systemOrange,
                          trailing: _ComingSoon(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _SectionLabel('LEGAL'),
                    const SizedBox(height: 10),
                    _GlassCard(
                      children: [
                        _SettingRow(
                          label: 'Privacy Policy',
                          icon: CupertinoIcons.lock_shield_fill,
                          color: AppColors.systemTeal,
                          onTap: () => _open('https://tidy.app/privacy'),
                        ),
                        _Divider(),
                        _SettingRow(
                          label: 'Terms of Service',
                          icon: CupertinoIcons.doc_text_fill,
                          color: AppColors.systemTeal,
                          onTap: () => _open('https://tidy.app/terms'),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
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
              gradient: RadialGradient(colors: [
                AppColors.systemBlue.withValues(alpha: 0.25),
                AppColors.systemBlue.withValues(alpha: 0),
              ]),
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
              gradient: RadialGradient(colors: [
                AppColors.systemIndigo.withValues(alpha: 0.18),
                AppColors.systemIndigo.withValues(alpha: 0),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
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

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 60),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.icon,
    required this.color,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
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
              style: TextStyle(
                color: destructive ? AppColors.systemRed : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && !destructive)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: Colors.white.withValues(alpha: 0.30),
              ),
            ),
        ]),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.isPro});
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    if (isPro) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
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
      );
    }
    return Text(
      'Free',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.50),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Coming soon',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.40),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
