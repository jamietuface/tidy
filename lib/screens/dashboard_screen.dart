import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/active_tab_provider.dart';
import '../features/subscriptions/subscription.dart';
import '../features/subscriptions/subscriptions_repository.dart';
import '../features/swipe/photo_decisions_repository.dart';

/// Home dashboard — data pass 1.
///
/// Layout is intentionally identical to the post-stabilisation minimal
/// version. Only text values are now driven by existing providers via the
/// safe `.asData?.value ?? fallback` pattern, which never throws on
/// loading/error and never blanks the screen.
///
/// Banned widgets still banned: AnimatedSwitcher, AnimatedContainer,
/// ShaderMask, Slivers, IntrinsicHeight, MergeSemantics, etc.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF05070B) : const Color(0xFFF7F9FC);
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1D2430);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.62)
        : const Color(0xFF667085);
    final textMuted = isDark
        ? Colors.white.withValues(alpha: 0.42)
        : const Color(0xFF98A2B3);
    final cardColor = isDark
        ? const Color(0xFF11151D)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFDCE3ED);

    // ── Data: safe fallbacks. Loading/error → null → defaults. ───────────
    // existing DecisionStats already provides what we need:
    //   .deleted     → markedCount
    //   .bytesFreed  → sum of sizeBytes for deleted decisions (this is
    //                  semantically "ready to delete", not actually freed)
    final stats = ref.watch(decisionStatsProvider).asData?.value ??
        DecisionStats.empty;
    final markedCount = stats.deleted;
    final readyBytes = stats.bytesFreed;
    // TODO(tidy): track permanentlyFreedBytes after
    // PhotoDeletionService.deleteFromLibrary returns the iOS-confirmed
    // delete list. Until then, Freed stays honestly at 0.
    const freedBytes = 0;

    final subs = ref.watch(subscriptionsProvider).asData?.value ??
        const <Subscription>[];
    final active = subs.where((s) => s.status == 'active').toList();
    // TODO(tidy): convert annual prices to monthly equivalent once the
    // Subscription model stores a billing period.
    final monthlyTotal = active.fold<double>(0, (sum, s) => sum + s.price);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Welcome back',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Hero card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's cleanup",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '$markedCount marked',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatBytes(readyBytes)} ready',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatBytes(freedBytes)} freed',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(activeHomeTabProvider.notifier)
                              .state = HomeTab.photos;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start tidying',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Review selected — only when there is something to review.
                    // Never permanently deletes from Home; switches to Photos
                    // tab and surfaces a SnackBar pointing at the review flow.
                    // TODO(tidy): replace with a dedicated review/delete-queue
                    // screen that ends in the iOS native confirmation.
                    if (markedCount > 0) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            ref
                                .read(activeHomeTabProvider.notifier)
                                .state = HomeTab.photos;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Review selected photos from Photos'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF007AFF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Review selected ($markedCount)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Ready to delete row
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to delete',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      markedCount == 0
                          ? 'No photos waiting'
                          : '$markedCount · ${_formatBytes(readyBytes)}',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // App spend row
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'App spend',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '£${monthlyTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _activeAppsLabel(active.length),
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(activeHomeTabProvider.notifier)
                            .state = HomeTab.apps;
                      },
                      child: const Text(
                        'Open',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tidy Assist line — intentionally static this pass.
              Text(
                'Tidy Assist: Start with grouped photos to clean faster.',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Local helpers ──────────────────────────────────────────────────────────

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 MB';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  final mb = bytes / (1024 * 1024);
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  return '${(mb / 1024).toStringAsFixed(1)} GB';
}

String _activeAppsLabel(int count) {
  if (count == 0) return '0 active apps';
  if (count == 1) return '1 active app';
  return '$count active apps';
}
