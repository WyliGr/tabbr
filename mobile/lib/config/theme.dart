import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
///  Tabbr — "Paper & Ink" design system
///
///  A warm, light, editorial aesthetic. Think of a well-designed
///  receipt or a ledger: cream paper, ink-black text, a single
///  bold coral accent for money, forest green for settled states.
///  No gradients. No glassmorphism. No dark mode. Just clear,
///  confident, typographic hierarchy with architectural radii.
/// ─────────────────────────────────────────────────────────────
class AppTheme {
  // ── Core palette ──────────────────────────────────────────────
  static const Color background = Color(0xFFF6F3EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF0EDE6);
  static const Color accent = Color(0xFFE8553D);
  static const Color accentSoft = Color(0xFFFDE8E2);
  static const Color positive = Color(0xFF2D7D5E);
  static const Color positiveSoft = Color(0xFFDDF0E6);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkSecondary = Color(0xFF6B6B6B);
  static const Color inkMuted = Color(0xFFA0A0A0);
  static const Color border = Color(0xFFE5E0D8);
  static const Color borderStrong = Color(0xFFD0C9BD);
  static const Color negative = Color(0xFFC93838);

  // ── Avatar palette (warm, muted, curated) ────────────────────
  static const List<Color> avatarColors = [
    Color(0xFFE8553D), // coral
    Color(0xFF2D7D5E), // forest
    Color(0xFF4A6FA5), // steel blue
    Color(0xFFD49A3F), // amber
    Color(0xFF7B5EA7), // muted purple
    Color(0xFFC2606B), // dusty rose
    Color(0xFF3D8B8B), // teal
    Color(0xFF8B6F47), // warm brown
  ];

  static Color avatarColor(int id) =>
      avatarColors[id.abs() % avatarColors.length];

  // ── Shape ───────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  // ── Text styles ──────────────────────────────────────────────
  static const TextStyle display = TextStyle(
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    color: ink,
  );

  static const TextStyle headline = TextStyle(
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: ink,
  );

  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: ink,
  );

  static const TextStyle body = TextStyle(
    fontWeight: FontWeight.w400,
    color: ink,
  );

  static const TextStyle secondary = TextStyle(
    fontWeight: FontWeight.w400,
    color: inkSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    fontSize: 11,
    color: inkMuted,
  );

  static const TextStyle amount = TextStyle(
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: accent,
  );

  static const TextStyle amountPositive = TextStyle(
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: positive,
  );

  // ── Theme ─────────────────────────────────────────────────────
  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      secondary: positive,
      surface: surface,
      error: negative,
      onSurface: ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      dividerColor: border,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: ink,
        ),
        iconTheme: IconThemeData(color: ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: borderStrong, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: negative, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: negative, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: inkSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: inkMuted, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: ink,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: inkSecondary,
        indicatorColor: accent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ink,
        foregroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(color: background, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: ink),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: inkSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}