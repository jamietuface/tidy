import 'package:flutter/material.dart';

/// Shadow / elevation tokens for Tidy.
///
/// Tidy uses minimal shadow. Most surfaces lift via subtle border, not shadow.
class TidyShadows {
  const TidyShadows._();

  static const List<BoxShadow> none = <BoxShadow>[];

  static const List<BoxShadow> subtle = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> modal = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
  ];
}
