import 'package:flutter/material.dart';

import '../../core/theme/tidy_theme.dart';
import '../../core/theme/tidy_typography.dart';

/// A bordered circular avatar with the user's initials. No fill colour
/// behind initials beyond the surface card token; no gradient; no shadow.
class TidyAvatar extends StatelessWidget {
  const TidyAvatar({
    required this.initials,
    this.size = 56,
    super.key,
  });

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.tidyColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TidyTypography.displayMedium.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
