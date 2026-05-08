import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'photo_library_provider.dart';
import 'widgets/photo_swipe_card.dart';

class SwipeCardScreen extends ConsumerStatefulWidget {
  const SwipeCardScreen({super.key});

  @override
  ConsumerState<SwipeCardScreen> createState() => _SwipeCardScreenState();
}

class _SwipeCardScreenState extends ConsumerState<SwipeCardScreen>
    with TickerProviderStateMixin {
  static const _commitThreshold = 100.0;
  static const _overlayDivisor = 150.0;
  static const _rotationDivisor = 800.0;

  double _dragX = 0;
  double _dragY = 0;
  bool _animating = false;

  late final AnimationController _flyController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final AnimationController _resetController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  Offset _flyFrom = Offset.zero;
  Offset _flyTo = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Load real photos from the device library.
    Future.microtask(() => ref.read(photoLibraryProvider.notifier).load());

    final flyCurve = CurvedAnimation(parent: _flyController, curve: Curves.easeOut);
    flyCurve.addListener(() {
      final p = flyCurve.value;
      setState(() {
        _dragX = _flyFrom.dx + (_flyTo.dx - _flyFrom.dx) * p;
        _dragY = _flyFrom.dy + (_flyTo.dy - _flyFrom.dy) * p;
      });
    });
    final resetCurve = CurvedAnimation(parent: _resetController, curve: Curves.easeOut);
    resetCurve.addListener(() {
      final p = resetCurve.value;
      setState(() {
        _dragX = _flyFrom.dx * (1 - p);
        _dragY = _flyFrom.dy * (1 - p);
      });
    });
  }

  @override
  void dispose() {
    _flyController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_animating) return;
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_animating) return;
    if (_dragX > _commitThreshold) {
      _flyOff(decision: _Decision.keep);
    } else if (_dragX < -_commitThreshold) {
      _flyOff(decision: _Decision.delete);
    } else {
      _resetCard();
    }
  }

  void _resetCard() {
    _flyFrom = Offset(_dragX, _dragY);
    _resetController.forward(from: 0);
  }

  void _flyOff({required _Decision decision}) {
    _animating = true;
    HapticFeedback.mediumImpact();
    final width = MediaQuery.of(context).size.width;
    final targetX = decision == _Decision.keep ? width * 1.4 : -width * 1.4;
    _flyFrom = Offset(_dragX, _dragY);
    _flyTo = Offset(targetX, _dragY + 80);
    _flyController.forward(from: 0).then((_) {
      final notifier = ref.read(photoLibraryProvider.notifier);
      if (decision == _Decision.keep) {
        notifier.keep();
      } else {
        notifier.delete();
      }
      setState(() {
        _dragX = 0;
        _dragY = 0;
        _animating = false;
      });
    });
  }

  void _triggerKeep() {
    if (_animating) return;
    HapticFeedback.lightImpact();
    _flyOff(decision: _Decision.keep);
  }

  void _triggerDelete() {
    if (_animating) return;
    HapticFeedback.lightImpact();
    _flyOff(decision: _Decision.delete);
  }

  void _triggerUndo() {
    if (_animating) return;
    HapticFeedback.selectionClick();
    ref.read(photoLibraryProvider.notifier).undo();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(photoLibraryProvider);
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.7;
    final cardWidth = size.width - 32;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.systemGray6,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              isDark: isDark,
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            _Counter(
              index: state.index,
              total: state.photos.length,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: state.loading
                    ? const CupertinoActivityIndicator()
                    : state.permission == PhotoPermission.denied
                        ? _PermissionDenied(
                            isDark: isDark,
                            onSettings: () => ref
                                .read(photoLibraryProvider.notifier)
                                .openSettings(),
                          )
                        : state.isDone
                            ? _DoneState(
                                kept: state.kept.length,
                                deleted: state.deleted.length,
                                isDark: isDark,
                              )
                            : SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                child: _CardStack(
                                  state: state,
                                  dragX: _dragX,
                                  dragY: _dragY,
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  overlayDivisor: _overlayDivisor,
                                  rotationDivisor: _rotationDivisor,
                                ),
                              ),
              ),
            ),
            if (!state.isDone && !state.loading &&
                state.permission != PhotoPermission.denied)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: _ActionRow(
                  onDelete: _triggerDelete,
                  onKeep: _triggerKeep,
                  onUndo: _triggerUndo,
                  canUndo: state.index > 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _Decision { keep, delete }

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isDark, required this.onClose});
  final bool isDark;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              child: Icon(CupertinoIcons.xmark, size: 17, color: fg),
            ),
          ),
          const Spacer(),
          Text(
            'Tidy',
            style: TextStyle(
              color: fg,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.index, required this.total, required this.isDark});
  final int index;
  final int total;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Text(
      'Photo ${index + 1} of $total',
      style: TextStyle(
        color: fg.withValues(alpha: 0.55),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.state,
    required this.dragX,
    required this.dragY,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.overlayDivisor,
    required this.rotationDivisor,
  });

  final PhotoLibraryState state;
  final double dragX;
  final double dragY;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final double overlayDivisor;
  final double rotationDivisor;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    // Card 3 (back-most) — offset 12px, scale 0.90
    final third = state.index + 2 < state.photos.length
        ? state.photos[state.index + 2]
        : null;
    if (third != null) {
      children.add(
        Transform.translate(
          offset: const Offset(0, 12),
          child: Transform.scale(
            scale: 0.90,
            child: PhotoSwipeCard(item: third),
          ),
        ),
      );
    }

    // Card 2 (middle) — offset 6px, scale 0.95
    final second = state.index + 1 < state.photos.length
        ? state.photos[state.index + 1]
        : null;
    if (second != null) {
      children.add(
        Transform.translate(
          offset: const Offset(0, 6),
          child: Transform.scale(
            scale: 0.95,
            child: PhotoSwipeCard(item: second),
          ),
        ),
      );
    }

    // Top draggable card
    final top = state.current;
    if (top != null) {
      final overlayOpacity = (dragX.abs() / overlayDivisor).clamp(0.0, 1.0);
      final keepOpacity = dragX > 0 ? overlayOpacity : 0.0;
      final deleteOpacity = dragX < 0 ? overlayOpacity : 0.0;
      children.add(
        GestureDetector(
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: Transform.translate(
            offset: Offset(dragX, dragY),
            child: Transform.rotate(
              angle: dragX / rotationDivisor,
              child: Stack(
                children: [
                  PhotoSwipeCard(item: top),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _DragOverlay(
                        keepOpacity: keepOpacity,
                        deleteOpacity: deleteOpacity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Stack(alignment: Alignment.center, children: children);
  }
}

class _DragOverlay extends StatelessWidget {
  const _DragOverlay({required this.keepOpacity, required this.deleteOpacity});
  final double keepOpacity;
  final double deleteOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: keepOpacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.systemGreen.withValues(alpha: 0.32),
              border: Border.all(color: AppColors.systemGreen, width: 4),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.checkmark_alt,
              size: 96,
              color: Colors.white,
            ),
          ),
        ),
        Opacity(
          opacity: deleteOpacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.systemRed.withValues(alpha: 0.32),
              border: Border.all(color: AppColors.systemRed, width: 4),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.trash_fill,
              size: 88,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onDelete,
    required this.onKeep,
    required this.onUndo,
    required this.canUndo,
  });

  final VoidCallback onDelete;
  final VoidCallback onKeep;
  final VoidCallback onUndo;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CircleAction(
          icon: CupertinoIcons.arrow_counterclockwise,
          color: AppColors.systemGray,
          size: 44,
          iconSize: 18,
          onTap: canUndo ? onUndo : null,
        ),
        _CircleAction(
          icon: CupertinoIcons.xmark,
          color: AppColors.systemRed,
          size: 52,
          iconSize: 22,
          onTap: onDelete,
        ),
        _CircleAction(
          icon: CupertinoIcons.checkmark_alt,
          color: AppColors.systemGreen,
          size: 64,
          iconSize: 28,
          onTap: onKeep,
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }
}

class _DoneState extends StatelessWidget {
  const _DoneState({required this.kept, required this.deleted, required this.isDark});
  final int kept;
  final int deleted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.checkmark_seal_fill,
            color: AppColors.systemGreen,
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            "You're all caught up",
            style: TextStyle(
              color: fg,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '$kept kept · $deleted deleted',
            style: TextStyle(
              color: fg.withValues(alpha: 0.55),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.systemBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied({required this.isDark, required this.onSettings});
  final bool isDark;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.photo, size: 56,
              color: fg.withValues(alpha: 0.25)),
          const SizedBox(height: 20),
          Text(
            'Photo access needed',
            style: TextStyle(
              color: fg,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Allow Tidy to access your photos in Settings.',
            style: TextStyle(
              color: fg.withValues(alpha: 0.55),
              fontSize: 15,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onSettings,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.systemBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
