import 'package:flutter/material.dart';

/// Colors ported from the web app's design tokens (src/styles.css, OKLCH),
/// converted to sRGB hex. Keep in sync if the web palette changes.
class AppColors {
  AppColors._();

  // Light theme
  static const brand = Color(0xFFF51D31); // oklch(0.62 0.24 25)
  static const brandDark = Color(0xFFC90019); // oklch(0.52 0.22 25)
  static const navy = Color(0xFF0F1932); // oklch(0.22 0.05 265)
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF0B111F); // oklch(0.18 0.03 265)
  static const muted = Color(0xFFF3F5F9); // oklch(0.97 0.005 265)
  static const mutedForeground = Color(0xFF5B6375); // oklch(0.5 0.03 265)
  static const accent = Color(0xFFFFEBE8); // oklch(0.96 0.03 25)
  static const accentForeground = Color(0xFF760009); // oklch(0.35 0.15 25)
  static const destructive = Color(0xFFDB0017); // oklch(0.55 0.24 25)
  static const border = Color(0xFFE1E5EB); // oklch(0.92 0.01 265)
  static const card = Color(0xFFFFFFFF);

  // Dark theme
  static const brandOnDark = Color(0xFFFF3D44); // oklch(0.68 0.24 25)
  static const backgroundDark = Color(0xFF060B18); // oklch(0.15 0.03 265)
  static const cardDark = Color(0xFF0D1528); // oklch(0.2 0.04 265)
  static const secondaryDark = Color(0xFF1D2842); // oklch(0.28 0.05 265)
  static const foregroundDark = Color(0xFFF3F5F9);
  static const mutedForegroundDark = Color(0xFF959FB2); // oklch(0.7 0.03 265)
  static const borderDark = Color(0x1AFFFFFF); // oklch(1 0 0 / 10%)

  // Cameroon flag accents (decorative)
  static const cmGreen = navy;
  static const cmRed = brand;
  static const cmYellow = Color(0xFFFFF7EB);
}
