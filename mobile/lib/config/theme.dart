import 'package:flutter/material.dart';

class AppTheme {
  // ── Core palette ──────────────────────────────────────────────
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF1A1D24);
  static const Color surfaceElevated = Color(0xFF22262E);
  static const Color primaryAccent = Color(0xFF7C5CFC);
  static const Color primaryBlue = Color(0xFF5B8DEF);
  static const Color positive = Color(0xFF2DD4A7);
  static const Color negative = Color(0xFFFF6B6B);
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF8B92A5);
  static const Color textMuted = Color(0xFF5C6378);
  static const Color border = Color(0xFF2A2E38);

  // ── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CFC), Color(0xFF5B8DEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0x227C5CFC), Color(0x225B8DEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Box shadows ──────────────────────────────────────────────
  static List<BoxShadow> cardShadow() => const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> fabShadow() => const [
        BoxShadow(
          color: Color(0x557C5CFC),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ];

  // ── Text styles ──────────────────────────────────────────────
  static const TextStyle headline = TextStyle(
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textSecondary,
  );

  static TextStyle labelUpper({Color color = textSecondary}) => TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        fontSize: 11,
        color: color,
      );

  static const TextStyle amount = TextStyle(
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  // ── Theme ─────────────────────────────────────────────────────
  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryAccent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryAccent,
      secondary: primaryBlue,
      surface: surface,
      surfaceContainerHighest: surfaceElevated,
      error: negative,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
          foregroundColor: primaryAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: negative),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: negative, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryAccent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: textSecondary),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}