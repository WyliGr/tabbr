import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
///  Tabbr — "Paper & Ink" design system
///
///  A warm, editorial aesthetic. Think of a well-designed receipt
///  or ledger: cream paper (light) / warm charcoal (dark), ink text,
///  a single bold coral accent for money, forest green for settled
///  states. No gradients. No glassmorphism. Just clear, confident,
///  typographic hierarchy with architectural radii.
///
///  Both light and dark themes share the same DNA — same radii, same
///  typography, same border-first surfaces, same coral accent. The dark
///  palette is a warm near-black (not cold blue-black), with off-white
///  ink and subtly brightened coral/green for contrast.
/// ─────────────────────────────────────────────────────────────

/// ThemeExtension carrying the semantic palette for the current
/// brightness.  Use [AppColors.of] to get the instance from any
/// build context.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Page background — warm cream (light) / warm charcoal (dark).
  final Color background;

  /// Card / surface fill — white (light) / dark grey (dark).
  final Color surface;

  /// Dimmed surface (amount input, loading shimmers) — surfaceDim.
  final Color surfaceDim;

  /// Primary accent — coral. Slightly brighter in dark mode.
  final Color accent;

  /// Soft accent tint for icon backgrounds.
  final Color accentSoft;

  /// Positive / settled state — forest green. Brightened in dark.
  final Color positive;

  /// Soft positive tint for icon backgrounds.
  final Color positiveSoft;

  /// Primary text — ink black (light) / warm off-white (dark).
  final Color ink;

  /// Secondary text — mid grey.
  final Color inkSecondary;

  /// Muted text / captions — light grey.
  final Color inkMuted;

  /// Hairline border between cards/inputs.
  final Color border;

  /// Stronger border (drag handles, focused outlines).
  final Color borderStrong;

  /// Error / destructive — red.
  final Color negative;

  /// Background used on inverted surfaces (room code banner in light
  /// mode, or the "inverted" button in dark mode).  On light, the
  /// banner is dark-on-light so this is ink; on dark, the banner
  /// flips to light-on-dark so this is the off-white.
  final Color invertedBg;

  /// Text/foreground on the inverted surface.
  final Color invertedFg;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceDim,
    required this.accent,
    required this.accentSoft,
    required this.positive,
    required this.positiveSoft,
    required this.ink,
    required this.inkSecondary,
    required this.inkMuted,
    required this.border,
    required this.borderStrong,
    required this.negative,
    required this.invertedBg,
    required this.invertedFg,
  });

  /// Light-mode palette — "Paper & Ink" warm cream.
  static const AppColors light = AppColors(
    background: Color(0xFFF6F3EE),
    surface: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFFF0EDE6),
    accent: Color(0xFFE8553D),
    accentSoft: Color(0xFFFDE8E2),
    positive: Color(0xFF2D7D5E),
    positiveSoft: Color(0xFFDDF0E6),
    ink: Color(0xFF1A1A1A),
    inkSecondary: Color(0xFF6B6B6B),
    inkMuted: Color(0xFFA0A0A0),
    border: Color(0xFFE5E0D8),
    borderStrong: Color(0xFFD0C9BD),
    negative: Color(0xFFC93838),
    invertedBg: Color(0xFF1A1A1A),
    invertedFg: Color(0xFFF6F3EE),
  );

  /// Dark-mode palette — "Paper & Ink" at night.
  ///
  /// A warm near-black background with a faint brown undertone (not
  /// cold blue-black), dark stone cards with subtle warm borders,
  /// slightly brightened coral and green for contrast against the
  /// dark surface, and warm off-white ink instead of pure white.
  static const AppColors dark = AppColors(
    background: Color(0xFF1C1A17), // warm charcoal, slight brown
    surface: Color(0xFF272420), // dark warm stone
    surfaceDim: Color(0xFF322E29), // slightly raised for amount box
    accent: Color(0xFFEC6347), // coral, lifted ~5% lightness
    accentSoft: Color(0xFF3A241F), // dim coral-tinted dark
    positive: Color(0xFF4DA67E), // forest green, brightened
    positiveSoft: Color(0xFF1E3329), // dim green-tinted dark
    ink: Color(0xFFF0EDE7), // warm off-white
    inkSecondary: Color(0xFFAEAB9F), // warm grey
    inkMuted: Color(0xFF7A7670), // muted warm grey
    border: Color(0xFF38332E), // subtle warm hairline
    borderStrong: Color(0xFF4A433C), // stronger warm hairline
    negative: Color(0xFFE0584F), // red, brightened for dark
    invertedBg: Color(0xFFF0EDE7), // banner flips: light bg in dark mode
    invertedFg: Color(0xFF1C1A17), // dark text on light banner
  );

  /// Convenience accessor — never null because both themes register
  /// the extension.
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceDim,
    Color? accent,
    Color? accentSoft,
    Color? positive,
    Color? positiveSoft,
    Color? ink,
    Color? inkSecondary,
    Color? inkMuted,
    Color? border,
    Color? borderStrong,
    Color? negative,
    Color? invertedBg,
    Color? invertedFg,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      positive: positive ?? this.positive,
      positiveSoft: positiveSoft ?? this.positiveSoft,
      ink: ink ?? this.ink,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      inkMuted: inkMuted ?? this.inkMuted,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      negative: negative ?? this.negative,
      invertedBg: invertedBg ?? this.invertedBg,
      invertedFg: invertedFg ?? this.invertedFg,
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
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      positiveSoft: Color.lerp(positiveSoft, other.positiveSoft, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSecondary: Color.lerp(inkSecondary, other.inkSecondary, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      invertedBg: Color.lerp(invertedBg, other.invertedBg, t)!,
      invertedFg: Color.lerp(invertedFg, other.invertedFg, t)!,
    );
  }
}

class AppTheme {
  // ── Avatar palette (warm, muted, curated) ────────────────────
  // Same in light and dark — these are saturated brand colours
  // that read well against both warm cream and warm charcoal.
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

  // ── Shape (identical in both themes) ────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  // ── Light theme ──────────────────────────────────────────────
  static ThemeData lightTheme() => _buildTheme(
        AppColors.light,
        Brightness.light,
      );

  // ── Dark theme ───────────────────────────────────────────────
  static ThemeData darkTheme() => _buildTheme(
        AppColors.dark,
        Brightness.dark,
      );

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
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: c.ink,
        ),
        iconTheme: IconThemeData(color: c.ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.ink,
          foregroundColor: c.background,
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
          foregroundColor: c.ink,
          side: BorderSide(color: c.borderStrong, width: 1.2),
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
          foregroundColor: c.accent,
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
          borderSide: BorderSide(color: c.ink, width: 1.5),
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: c.inkSecondary, fontSize: 14),
        hintStyle: TextStyle(color: c.inkMuted, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: c.ink,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.accent,
        unselectedLabelColor: c.inkSecondary,
        indicatorColor: c.accent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.ink,
        foregroundColor: c.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: TextStyle(color: c.background, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
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
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}