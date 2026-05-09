import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'subscription.dart';
import 'subscriptions_repository.dart';

const _iconChoices = <String, IconData>{
  'play': CupertinoIcons.play_rectangle_fill,
  'music': CupertinoIcons.music_note,
  'heart': CupertinoIcons.heart_fill,
  'book': CupertinoIcons.book_fill,
  'cloud': CupertinoIcons.cloud_fill,
  'game': CupertinoIcons.gamecontroller_fill,
  'app': CupertinoIcons.app_fill,
  'tv': CupertinoIcons.tv_fill,
};

const _colorChoices = <String>[
  '#FF3B30', // red
  '#FF9500', // orange
  '#FFCC00', // yellow
  '#34C759', // green
  '#007AFF', // blue
  '#5856D6', // indigo
  '#AF52DE', // purple
  '#FF2D55', // pink
];

const _currencies = ['GBP', 'USD', 'EUR'];

Future<void> showAddSubscriptionSheet(BuildContext context, {Subscription? editing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddSubscriptionSheet(editing: editing),
  );
}

class AddSubscriptionSheet extends ConsumerStatefulWidget {
  const AddSubscriptionSheet({super.key, this.editing});
  final Subscription? editing;

  @override
  ConsumerState<AddSubscriptionSheet> createState() =>
      _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends ConsumerState<AddSubscriptionSheet> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late String _currency;
  late DateTime _lastUsed;
  late String _iconName;
  late String _colorHex;
  bool _busy = false;
  String? _error;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(
        text: e?.price != null ? e!.price.toStringAsFixed(2) : '');
    _currency = e?.currency ?? 'GBP';
    _lastUsed = e?.lastUsed ?? DateTime.now();
    _iconName = e?.iconName ?? 'app';
    _colorHex = e?.colorHex ?? '#007AFF';
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _name.text.trim().isNotEmpty &&
      double.tryParse(_price.text.trim()) != null &&
      double.parse(_price.text.trim()) > 0;

  Future<void> _save() async {
    if (!_canSave || _busy) return;
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) {
      setState(() => _error = 'Sign in first.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(subscriptionsRepositoryProvider);
      if (_isEditing) {
        await repo.update(
          uid: user.uid,
          id: widget.editing!.id,
          name: _name.text.trim(),
          price: double.parse(_price.text.trim()),
          currency: _currency,
          lastUsed: _lastUsed,
          iconName: _iconName,
          colorHex: _colorHex,
        );
      } else {
        await repo.add(
          uid: user.uid,
          name: _name.text.trim(),
          price: double.parse(_price.text.trim()),
          currency: _currency,
          lastUsed: _lastUsed,
          iconName: _iconName,
          colorHex: _colorHex,
        );
      }
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not save. Try again.';
          _busy = false;
        });
      }
    }
  }

  void _pickDate() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _lastUsed,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (d) => setState(() => _lastUsed = d),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final fg = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final pageBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        decoration: BoxDecoration(
          color: pageBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    Text(
                      _isEditing ? 'Edit Subscription' : 'Add Subscription',
                      style: TextStyle(
                        color: fg,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _canSave && !_busy ? _save : null,
                      child: _busy
                          ? const CupertinoActivityIndicator()
                          : const Text(
                              'Save',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionLabel('Details', isDark: isDark),
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _Field(
                        label: 'Name',
                        controller: _name,
                        hint: 'Netflix',
                        onChanged: (_) => setState(() {}),
                      ),
                      _Divider(isDark: isDark),
                      _Field(
                        label: 'Price',
                        controller: _price,
                        hint: '0.00',
                        keyboard: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => setState(() {}),
                        trailing: _CurrencyPicker(
                          value: _currency,
                          onChange: (v) => setState(() => _currency = v),
                        ),
                      ),
                      _Divider(isDark: isDark),
                      _Tappable(
                        label: 'Last used',
                        value: _formatDate(_lastUsed),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel('Icon', isDark: isDark),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _iconChoices.entries.map((e) {
                      final selected = e.key == _iconName;
                      final color = _hexToColor(_colorHex);
                      return GestureDetector(
                        onTap: () => setState(() => _iconName = e.key),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withValues(alpha: 0.18)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? color
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            e.value,
                            size: 22,
                            color: selected ? color : fg.withValues(alpha: 0.55),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel('Color', isDark: isDark),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colorChoices.map((hex) {
                      final selected = hex == _colorHex;
                      final color = _hexToColor(hex);
                      return GestureDetector(
                        onTap: () => setState(() => _colorHex = hex),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.systemRed,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    final value = int.parse(clean, radix: 16);
    return Color(0xFF000000 | value);
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.45),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 16),
      color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard,
    this.trailing,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              keyboardType: keyboard,
              placeholder: hint,
              decoration: const BoxDecoration(),
              style: TextStyle(color: fg, fontSize: 16),
              onChanged: onChanged,
              textInputAction: TextInputAction.next,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Tappable extends StatelessWidget {
  const _Tappable({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.systemBlue,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: fg.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({required this.value, required this.onChange});
  final String value;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      onPressed: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (_) => Container(
            height: 220,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: FixedExtentScrollController(
                      initialItem: _currencies.indexOf(value),
                    ),
                    onSelectedItemChanged: (i) => onChange(_currencies[i]),
                    children: _currencies
                        .map((c) => Center(child: Text(c)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.systemBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
