import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/user_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

enum _Plan { monthly, annual }

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  _Plan _selected = _Plan.annual;
  bool _busy = false;
  bool _success = false;

  Future<void> _subscribe() async {
    if (_busy) return;
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    try {
      await ref.read(userRepositoryProvider).setPlan(
            user.uid,
            'pro',
            billing: _selected.name,
          );
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(child: _GlowHalos()),
          ),
          if (_success)
            const Positioned.fill(child: _SuccessOverlay())
          else
          SafeArea(
            child: Column(
              children: [
                _DismissBar(onClose: () => Navigator.of(context).pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        const _AppIconBadge(),
                        const SizedBox(height: 24),
                        const Text(
                          'Tidy Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unlimited photos · AI grouping · App tracker',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 36),
                        const _FeatureList(),
                        const SizedBox(height: 36),
                        _PlanToggle(
                          selected: _selected,
                          onChange: (p) => setState(() => _selected = p),
                        ),
                        const SizedBox(height: 20),
                        _SubscribeButton(
                          busy: _busy,
                          onTap: _subscribe,
                          plan: _selected,
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Restore Purchase',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
          left: -120,
          top: -120,
          width: 360,
          height: 360,
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
          right: -140,
          bottom: -140,
          width: 380,
          height: 380,
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

class _DismissBar extends StatelessWidget {
  const _DismissBar({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.30),
              ),
              child: const Icon(
                CupertinoIcons.xmark,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppIconBadge extends StatelessWidget {
  const _AppIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withValues(alpha: 0.40),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                CupertinoIcons.sparkles,
                color: Colors.white,
                size: 42,
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              height: 42,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0),
                    ],
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

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  static const _features = [
    (CupertinoIcons.photo_on_rectangle, 'Unlimited swipes, no daily cap'),
    (CupertinoIcons.sparkles, 'Full AI grouping — blur, duplicates, old'),
    (CupertinoIcons.app_badge, 'Complete app spend tracker'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.systemBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(f.$1, color: AppColors.systemBlue, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  f.$2,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PlanToggle extends StatelessWidget {
  const _PlanToggle({required this.selected, required this.onChange});
  final _Plan selected;
  final ValueChanged<_Plan> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PlanOption(
              selected: selected == _Plan.monthly,
              title: 'Monthly',
              price: '£3.99/mo',
              onTap: () => onChange(_Plan.monthly),
            ),
          ),
          Expanded(
            child: _PlanOption(
              selected: selected == _Plan.annual,
              title: 'Annual',
              price: '£23.99/yr',
              badge: 'SAVE 50%',
              onTap: () => onChange(_Plan.annual),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.selected,
    required this.title,
    required this.price,
    required this.onTap,
    this.badge,
  });

  final bool selected;
  final String title;
  final String price;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.55),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.systemGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
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

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({
    required this.busy,
    required this.onTap,
    required this.plan,
  });

  final bool busy;
  final VoidCallback onTap;
  final _Plan plan;

  @override
  Widget build(BuildContext context) {
    final price = plan == _Plan.annual ? '£23.99/yr' : '£3.99/mo';
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.40),
              offset: const Offset(0, 6),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Center(
                child: busy
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(
                        'Subscribe · $price',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
              Positioned(
                top: 0, left: 0, right: 0,
                height: 28,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatefulWidget {
  const _SuccessOverlay();

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    final fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    return Center(
      child: FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1).animate(scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34C759), Color(0xFF007AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.systemGreen.withValues(alpha: 0.4),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.checkmark_alt,
                  color: Colors.white,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "You're Pro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Unlimited swipes unlocked.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
