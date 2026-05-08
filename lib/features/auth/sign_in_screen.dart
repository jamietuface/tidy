import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signInWithApple() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithApple();
    } catch (e) {
      dev.log('Apple sign-in failed: $e', name: 'sign_in_screen');
      if (mounted) setState(() => _error = 'Sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueWithoutAccount() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInAnonymously();
    } catch (e) {
      dev.log('Anonymous sign-in failed: $e', name: 'sign_in_screen');
      if (mounted) setState(() => _error = 'Could not continue. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final secondary = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.systemBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.sparkles,
                  size: 44,
                  color: AppColors.systemBlue,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome to Tidy',
                style: TextStyle(
                  color: fg,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Sign in to sync your decisions across devices and back up your subscription tracker.',
                style: TextStyle(
                  color: secondary,
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.systemRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              _AppleSignInButton(
                busy: _busy,
                isDark: isDark,
                onTap: _busy ? null : _signInWithApple,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : _continueWithoutAccount,
                child: const Text(
                  'Continue without an account',
                  style: TextStyle(
                    color: AppColors.systemBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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

class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({
    required this.busy,
    required this.isDark,
    required this.onTap,
  });

  final bool busy;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? Colors.white : Colors.black;
    final fg = isDark ? Colors.black : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: busy
            ? const CupertinoActivityIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_appleLogo, color: fg, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Sign in with Apple',
                    style: TextStyle(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static const _appleLogo = IconData(0xF8FF, fontFamily: 'CupertinoIcons');
}
