import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import 'group_type.dart';
import 'photo_library_provider.dart';
import 'widgets/photo_swipe_card.dart';

class GroupSwipeScreen extends StatefulWidget {
  const GroupSwipeScreen({
    super.key,
    required this.type,
    required this.photoCount,
  });

  final GroupType type;
  final int photoCount;

  @override
  State<GroupSwipeScreen> createState() => _GroupSwipeScreenState();
}

class _GroupSwipeScreenState extends State<GroupSwipeScreen>
    with TickerProviderStateMixin {
  static const _commitThreshold = 100.0;
  static const _overlayDivisor = 150.0;
  static const _rotationDivisor = 800.0;

  late final List<PhotoItem> _photos;
  int _index = 0;
  int _kept = 0;
  int _deleted = 0;

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
    _photos = _mockGroupPhotos(widget.type, widget.photoCount);

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

  bool get _isDone => _index >= _photos.length;

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
      _flyOff(keep: true);
    } else if (_dragX < -_commitThreshold) {
      _flyOff(keep: false);
    } else {
      _resetCard();
    }
  }

  void _resetCard() {
    _flyFrom = Offset(_dragX, _dragY);
    _resetController.forward(from: 0);
  }

  void _flyOff({required bool keep}) {
    _animating = true;
    HapticFeedback.mediumImpact();
    final width = MediaQuery.of(context).size.width;
    final targetX = keep ? width * 1.4 : -width * 1.4;
    _flyFrom = Offset(_dragX, _dragY);
    _flyTo = Offset(targetX, _dragY + 80);
    _flyController.forward(from: 0).then((_) {
      setState(() {
        if (keep) {
          _kept++;
        } else {
          _deleted++;
        }
        _index++;
        _dragX = 0;
        _dragY = 0;
        _animating = false;
      });
    });
  }

  Future<void> _confirmDeleteAll() async {
    final remaining = _photos.length - _index;
    if (remaining == 0) return;

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Delete all $remaining ${widget.type.shortLabel.toLowerCase()} photos?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('This will mark every remaining photo for deletion. You can review before confirming on your device.'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _deleted += remaining;
        _index = _photos.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.62;
    final cardWidth = size.width - 32;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.systemGray6,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              type: widget.type,
              total: widget.photoCount,
              isDark: isDark,
              onBack: () => context.pop(),
              onDeleteAll: _isDone ? null : _confirmDeleteAll,
            ),
            const SizedBox(height: 12),
            _GroupChip(type: widget.type),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: _isDone
                    ? _Completion(
                        kept: _kept,
                        deleted: _deleted,
                        isDark: isDark,
                        onBack: () => context.pop(),
                      )
                    : SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _CardStack(
                          photos: _photos,
                          index: _index,
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
            if (!_isDone)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: _ActionRow(
                  canUndo: _index > 0,
                  onUndo: _onUndo,
                  onDelete: () {
                    if (_animating) return;
                    HapticFeedback.lightImpact();
                    _flyOff(keep: false);
                  },
                  onKeep: () {
                    if (_animating) return;
                    HapticFeedback.lightImpact();
                    _flyOff(keep: true);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onUndo() {
    if (_animating || _index == 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _index--;
      // We don't track which decision was last; decrement the larger bucket
      // as a conservative undo. Real photo_manager wiring will track this properly.
      if (_kept >= _deleted && _kept > 0) {
        _kept--;
      } else if (_deleted > 0) {
        _deleted--;
      }
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.type,
    required this.total,
    required this.isDark,
    required this.onBack,
    required this.onDeleteAll,
  });

  final GroupType type;
  final int total;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback? onDeleteAll;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: onBack,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.chevron_back, color: AppColors.systemBlue, size: 22),
                    SizedBox(width: 2),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: AppColors.systemBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: onDeleteAll,
                child: Text(
                  'Delete All',
                  style: TextStyle(
                    color: onDeleteAll == null
                        ? AppColors.systemRed.withValues(alpha: 0.4)
                        : AppColors.systemRed,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.title,
                  style: TextStyle(
                    color: fg,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total photos to review',
                  style: TextStyle(
                    color: fg.withValues(alpha: 0.55),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
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

class _GroupChip extends StatelessWidget {
  const _GroupChip({required this.type});
  final GroupType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, color: type.color, size: 14),
          const SizedBox(width: 6),
          Text(
            type.shortLabel,
            style: TextStyle(
              color: type.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.photos,
    required this.index,
    required this.dragX,
    required this.dragY,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.overlayDivisor,
    required this.rotationDivisor,
  });

  final List<PhotoItem> photos;
  final int index;
  final double dragX;
  final double dragY;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final double overlayDivisor;
  final double rotationDivisor;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (index + 2 < photos.length) {
      children.add(
        Transform.translate(
          offset: const Offset(0, 12),
          child: Transform.scale(
            scale: 0.90,
            child: PhotoSwipeCard(item: photos[index + 2]),
          ),
        ),
      );
    }
    if (index + 1 < photos.length) {
      children.add(
        Transform.translate(
          offset: const Offset(0, 6),
          child: Transform.scale(
            scale: 0.95,
            child: PhotoSwipeCard(item: photos[index + 1]),
          ),
        ),
      );
    }

    final top = photos[index];
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
                    child: Stack(
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Stack(alignment: Alignment.center, children: children);
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.canUndo,
    required this.onUndo,
    required this.onDelete,
    required this.onKeep,
  });

  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onDelete;
  final VoidCallback onKeep;

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

class _Completion extends StatelessWidget {
  const _Completion({
    required this.kept,
    required this.deleted,
    required this.isDark,
    required this.onBack,
  });

  final int kept;
  final int deleted;
  final bool isDark;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.systemGreen,
            ),
            child: const Icon(
              CupertinoIcons.checkmark_alt,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All done!',
            style: TextStyle(
              color: fg,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$kept photos kept · $deleted deleted',
            style: TextStyle(
              color: fg.withValues(alpha: 0.55),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.systemBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Back to home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<PhotoItem> _mockGroupPhotos(GroupType type, int count) {
  final now = DateTime.now();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final sizes = [3.2, 1.1, 4.6, 2.8, 5.1, 3.7, 2.0, 0.8, 4.2, 6.5, 3.0, 1.9];
  final seedPrefix = type.name;
  return List.generate(count, (i) {
    final d = now.subtract(Duration(days: i + 1));
    return PhotoItem(
      id: '${seedPrefix}_$i',
      imageUrl: 'https://picsum.photos/seed/${seedPrefix}_$i/600/800',
      label: '${months[d.month - 1]} ${d.day}, ${d.year}',
      size: '${sizes[i % sizes.length].toStringAsFixed(1)} MB',
    );
  });
}
