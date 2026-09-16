import 'package:flutter/material.dart';

/// Shadow presets ported from src/styles.css (--shadow-card, --shadow-brand, --shadow-app).
class AppShadows {
  AppShadows._();

  static const card = [
    BoxShadow(
      color: Color(0x260F1932),
      blurRadius: 24,
      offset: Offset(0, 6),
      spreadRadius: -10,
    ),
  ];

  static const brand = [
    BoxShadow(
      color: Color(0x73F51D31),
      blurRadius: 44,
      offset: Offset(0, 22),
      spreadRadius: -20,
    ),
  ];

  static const flat = [
    BoxShadow(
      color: Color(0x0F0F1932),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];
}
