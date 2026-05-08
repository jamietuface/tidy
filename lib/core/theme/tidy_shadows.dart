import 'package:flutter/material.dart';

/// Shadow tokens for Tidy — Apple-style layered soft shadows.
class TidyShadows {
  const TidyShadows._();

  static const List<BoxShadow> none = <BoxShadow>[];

  // Thin border-like shadow for cards on white backgrounds
  static const List<BoxShadow> subtle = <BoxShadow>[
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0.5),
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  // Apple card shadow — ambient + directional
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0.5),
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 8),
    BoxShadow(color: Color(0x08000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  // Elevated panel — sheet or modal
  static const List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 16),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 4),
  ];

  // Full-screen modal / bottom sheet
  static const List<BoxShadow> modal = <BoxShadow>[
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 16), blurRadius: 48),
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  // Glossy top-edge highlight (white sheen on glass surfaces, dark mode)
  static const List<BoxShadow> glossDark = <BoxShadow>[
    BoxShadow(color: Color(0x1FFFFFFF), offset: Offset(0, 1), blurRadius: 0, spreadRadius: 0),
  ];
}
