import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TidyCard extends StatelessWidget {
  const TidyCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<TidyThemeExtension>()!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ext.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}
