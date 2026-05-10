import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/tidy_brand_palette.dart';
import '../core/theme/tidy_theme_mode_controller.dart';
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
    final themePref = ref.watch(tidyThemeModeControllerProvider);
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: brand.background,
      body: Stack(
        children: [
          // Halos only on dark — they vanish on light to keep the page clean.
          if (isDark)
            const Positioned.fill(
              child: IgnorePointer(child: _GlowHalos()),
            ),
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(
                  'Settings',
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
                leading: IconButton(
                  icon: Icon(
                    CupertinoIcons.chevron_back,
                    color: brand.textPrimary,
                  ),
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
                        const _Divider(),
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
                        const _Divider(),
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
                    const _SectionLabel('APPEARANCE'),
                    const SizedBox(height: 10),
                    _GlassCard(
                      children: [
                        _SettingRow(
                          label: 'Theme',
                          icon: CupertinoIcons.circle_lefthalf_fill,
                          color: AppColors.systemGray,
                          trailing: _ValueLabel(text: themePref.displayLabel),
                          onTap: () => _openThemeSheet(context, ref),
                        ),
                        const _Divider(),
                        _SettingRow(
                          label: 'Brand Preview',
                          icon: CupertinoIcons.sparkles,
                          color: AppColors.systemIndigo,
                          onTap: () => context.push('/brand-preview'),
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
                        const _Divider(),
                        _SettingRow(
                          label: 'Terms of Service',
                          icon: CupertinoIcons.doc_text_fill,
                          color: AppColors.systemTeal,
                          onTap: () => _open('https://tidy.app/terms'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _SectionLabel('DEV'),
                    const SizedBox(height: 10),
                    _GlassCard(
                      children: [
                        _SettingRow(
                          label: 'Brand Preview',
                          icon: CupertinoIcons.wand_stars,
                          color: AppColors.systemPurple,
                          onTap: () => context.push('/brand-preview'),
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

  Future<void> _openThemeSheet(BuildContext context, WidgetRef ref) async {
    final current = ref.read(tidyThemeModeControllerProvider);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: false,
      builder: (sheetCtx) {
        return _ThemeSheet(current: current);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Halos — only painted in dark mode.

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

// ---------------------------------------------------------------------------
// Section label.

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

// ---------------------------------------------------------------------------
// Card container — opaque white in light, translucent glass in dark
// (preserves the existing metallic-dark feel).

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : brand.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.10) : brand.cardBorder,
          width: 0.5,
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: const Color(0xFF1A2540).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Row divider.

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 60),
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : brand.cardBorderSubtle,
    );
  }
}

// ---------------------------------------------------------------------------
// Single settings row — icon badge + label + optional trailing.

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
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final badgeGradient = isDark
        ? [color.withValues(alpha: 0.30), color.withValues(alpha: 0.10)]
        : [color.withValues(alpha: 0.20), color.withValues(alpha: 0.08)];
    final badgeBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : color.withValues(alpha: 0.28);

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
                colors: badgeGradient,
              ),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: badgeBorder, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: destructive ? AppColors.systemRed : brand.textPrimary,
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
                color: brand.textMuted,
              ),
            ),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan badge / coming soon / value label.

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.isPro});
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
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
        color: brand.textSecondary,
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
    final brand = context.tidyBrand;
    return Text(
      'Coming soon',
      style: TextStyle(
        color: brand.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ValueLabel extends StatelessWidget {
  const _ValueLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return Text(
      text,
      style: TextStyle(
        color: brand.textSecondary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme picker bottom sheet — adapts to current theme.

class _ThemeSheet extends ConsumerWidget {
  const _ThemeSheet({required this.current});
  final TidyThemePreference current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.tidyBrand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF11151D) : brand.surface;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.10) : brand.cardBorder;
    final closeBg = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : brand.surfaceSoft;
    final closeIcon = isDark ? Colors.white : brand.textPrimary;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: isDark
              ? const []
              : [
                  BoxShadow(
                    color: const Color(0xFF1A2540).withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Appearance',
                        style: TextStyle(
                          color: brand.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: closeBg,
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: closeIcon,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (final pref in TidyThemePreference.values)
                _ThemeSheetRow(
                  pref: pref,
                  selected: pref == current,
                  onTap: () async {
                    await ref
                        .read(tidyThemeModeControllerProvider.notifier)
                        .set(pref);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSheetRow extends StatelessWidget {
  const _ThemeSheetRow({
    required this.pref,
    required this.selected,
    required this.onTap,
  });

  final TidyThemePreference pref;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.tidyBrand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                pref.displayLabel,
                style: TextStyle(
                  color: brand.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (selected)
              Icon(
                CupertinoIcons.checkmark_alt,
                color: brand.blue,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
