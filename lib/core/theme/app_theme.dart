import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radii.dart';

/// Builds the app's light/dark ThemeData from tokens ported from the web
/// app's design system (Poppins for display text, Inter for body text).
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(brightness: Brightness.light);
  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.brandOnDark,
            onPrimary: Colors.white,
            secondary: AppColors.secondaryDark,
            onSecondary: Colors.white,
            surface: AppColors.cardDark,
            onSurface: AppColors.foregroundDark,
            error: AppColors.destructive,
            onError: Colors.white,
            outline: AppColors.borderDark,
          )
        : const ColorScheme.light(
            primary: AppColors.brand,
            onPrimary: Colors.white,
            secondary: AppColors.navy,
            onSecondary: Colors.white,
            surface: AppColors.card,
            onSurface: AppColors.foreground,
            error: AppColors.destructive,
            onError: Colors.white,
            outline: AppColors.border,
          );

    final background = isDark ? AppColors.backgroundDark : AppColors.background;
    final mutedForeground = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;

    final baseTextTheme = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;

    final bodyTextTheme = GoogleFonts.interTextTheme(baseTextTheme);
    final displayTextTheme = GoogleFonts.poppinsTextTheme(baseTextTheme);

    final textTheme = bodyTextTheme.copyWith(
      displayLarge: displayTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800),
      displayMedium: displayTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
      displaySmall: displayTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge: displayTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: displayTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: displayTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: displayTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: displayTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: displayTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: isDark ? 0.4 : 1)),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
          textStyle: textTheme.titleSmall,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size.fromHeight(44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.secondaryDark : AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: mutedForeground),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outline, space: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: mutedForeground,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.secondaryDark : AppColors.muted,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
        side: BorderSide.none,
      ),
    );
  }
}
