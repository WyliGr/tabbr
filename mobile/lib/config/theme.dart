import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────
///  Tabbr — Nothing OS design system
///
///  A pure dark aesthetic inspired by Nothing's industrial design
///  language. Pure black background, hairline borders, monospace
///  numerics, and a single user-customizable accent color. No
///  gradients, no glassmorphism. Just confident, minimal,
///  typographic hierarchy with architectural radii.
///
///  Dark-only: the app no longer has a light theme.
/// ─────────────────────────────────────────────────────────────

/// ThemeExtension carrying the semantic palette.  The accent color
/// is dynamic — it is supplied at construction time so the user can
/// customize it at runtime via [ThemeProvider].
///
/// Use [AppColors.of] to get the instance from any build context.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Page background — pure black.
  final Color background;

  /// Card / surface fill — near-black elevated.
  final Color surface;

  /// Dimmed surface (amount input, loading shimmers) — slightly raised.
  final Color surfaceDim;

  /// Primary accent — user-customizable (default Nothing red).
  final Color accent;

  /// Slightly lighter version of accent for hover/pressed states.
  final Color accentHover;

  /// Soft accent tint (8% opacity) for icon backgrounds.
  final Color accentSoft;

  /// Accent at 5% opacity — used for the room-code banner background.
  final Color accentSurface;

  /// Accent at 30% opacity — used for the room-code banner border.
  final Color accentBorder;

  /// Positive / settled state — green.
  final Color positive;

  /// Soft positive tint for icon backgrounds.
  final Color positiveSoft;

  /// Primary text — pure white.
  final Color ink;

  /// Secondary text — mid grey.
  final Color inkSecondary;

  /// Muted text / captions — dark grey.
  final Color inkMuted;

  /// Hairline border between cards/inputs.
  final Color border;

  /// Stronger border (drag handles, focused outlines).
  final Color borderStrong;

  /// Error / destructive — red.
  final Color negative;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceDim,
    required this.accent,
    required this.accentHover,
    required this.accentSoft,
    required this.accentSurface,
    required this.accentBorder,
    required this.positive,
    required this.positiveSoft,
    required this.ink,
    required this.inkSecondary,
    required this.inkMuted,
    required this.border,
    required this.borderStrong,
    required this.negative,
  });

  /// Build an [AppColors] instance with the given accent color.
  ///
  /// All non-accent colors use the fixed Nothing OS dark palette.
  /// [accentHex] is an ARGB int (e.g. `0xFFFF2D2D`).
  factory AppColors.withAccent(int accentHex) {
    final accent = Color(accentHex);
    return AppColors(
      background: const Color(0xFF000000),
      surface: const Color(0xFF0A0A0A),
      surfaceDim: const Color(0xFF111111),
      accent: accent,
      accentHover: _lighten(accent, 0.12),
      accentSoft: accent.withValues(alpha: 0.08),
      accentSurface: accent.withValues(alpha: 0.05),
      accentBorder: accent.withValues(alpha: 0.30),
      positive: const Color(0xFF4ADE80),
      positiveSoft: const Color(0xFF4ADE80).withValues(alpha: 0.08),
      ink: const Color(0xFFFFFFFF),
      inkSecondary: const Color(0xFF888888),
      inkMuted: const Color(0xFF555555),
      border: const Color(0xFF1A1A1A),
      borderStrong: const Color(0xFF2A2A2A),
      negative: const Color(0xFFFF4444),
    );
  }

  /// Lighten a color by mixing it with white by [amount] (0.0–1.0).
  static Color _lighten(Color c, double amount) {
    return Color.lerp(c, Colors.white, amount)!;
  }

  /// Convenience accessor — never null because the theme always
  /// registers the extension.
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceDim,
    Color? accent,
    Color? accentHover,
    Color? accentSoft,
    Color? accentSurface,
    Color? accentBorder,
    Color? positive,
    Color? positiveSoft,
    Color? ink,
    Color? inkSecondary,
    Color? inkMuted,
    Color? border,
    Color? borderStrong,
    Color? negative,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentSoft: accentSoft ?? this.accentSoft,
      accentSurface: accentSurface ?? this.accentSurface,
      accentBorder: accentBorder ?? this.accentBorder,
      positive: positive ?? this.positive,
      positiveSoft: positiveSoft ?? this.positiveSoft,
      ink: ink ?? this.ink,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      inkMuted: inkMuted ?? this.inkMuted,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      negative: negative ?? this.negative,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentSurface: Color.lerp(accentSurface, other.accentSurface, t)!,
      accentBorder: Color.lerp(accentBorder, other.accentBorder, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      positiveSoft: Color.lerp(positiveSoft, other.positiveSoft, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSecondary: Color.lerp(inkSecondary, other.inkSecondary, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
    );
  }
}

class AppTheme {
  // ── Avatar palette (muted, curated for dark UI) ─────────────
  static const List<Color> avatarColors = [
    Color(0xFFFF2D2D), // red
    Color(0xFF3B82F6), // blue
    Color(0xFF4ADE80), // green
    Color(0xFFF59E0B), // amber
    Color(0xFFA855F7), // purple
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFF8B6F47), // warm brown
  ];

  static Color avatarColor(int id) =>
      avatarColors[id.abs() % avatarColors.length];

  // ── Shape ────────────────────────────────────────────────────
  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 14;

  // ── Mono font helpers ────────────────────────────────────────
  /// Monospace text style for codes, amounts, labels.
  /// Mirrors the landing page mockup's use of a mono font for
  /// numeric and code content.
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0,
    double? height,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Uppercase mono label — tracking-widest style from the mockup.
  static TextStyle monoLabel({
    double fontSize = 10,
    Color? color,
    double letterSpacing = 1.4,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: letterSpacing,
      );

  // ── Preset accent colors ────────────────────────────────────
  static const List<int> accentPresets = [
    0xFFFF2D2D, // Nothing Red — default
    0xFF3B82F6, // Blue
    0xFF4ADE80, // Green
    0xFFF59E0B, // Amber
    0xFFA855F7, // Purple
    0xFFEC4899, // Pink
    0xFF06B6D4, // Cyan
    0xFFFFFFFF, // Pure White
  ];

  static const List<String> accentPresetNames = [
    'Nothing Red',
    'Blue',
    'Green',
    'Amber',
    'Purple',
    'Pink',
    'Cyan',
    'Pure White',
  ];

  /// Default accent color (Nothing Red).
  static const int defaultAccent = 0xFFFF2D2D;

  // ── Dark theme (the only theme) ──────────────────────────────
  /// Builds the dark theme with the given accent color hex value.
  static ThemeData darkTheme({int accentHex = defaultAccent}) =>
      _buildTheme(AppColors.withAccent(accentHex), Brightness.dark);

  /// Light theme — returns the same dark theme (app is dark-only).
  static ThemeData lightTheme({int accentHex = defaultAccent}) =>
      _buildTheme(AppColors.withAccent(accentHex), Brightness.dark);

  static ThemeData _buildTheme(AppColors c, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: brightness,
    ).copyWith(
      primary: c.accent,
      secondary: c.positive,
      surface: c.surface,
      error: c.negative,
      onSurface: c.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.surface,
      dividerColor: c.border,
      extensions: [c],
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: c.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: c.ink,
        ),
        iconTheme: IconThemeData(color: c.ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          side: BorderSide(color: c.borderStrong, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: c.negative, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: c.negative, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        labelStyle: TextStyle(color: c.inkSecondary, fontSize: 13),
        hintStyle: TextStyle(color: c.inkMuted, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: c.ink,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.accent,
        unselectedLabelColor: c.inkSecondary,
        indicatorColor: c.accent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.background,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
        contentTextStyle: TextStyle(color: c.ink, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: c.ink),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: c.border, width: 1),
        ),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: c.ink,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: c.inkSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }
}