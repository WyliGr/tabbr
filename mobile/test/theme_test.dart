import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabbr/config/theme.dart';

void main() {
  group('AppTheme', () {
    test('default accent is Nothing Red', () {
      expect(AppTheme.defaultAccent, 0xFFFF2D2D);
    });

    test('has 8 accent presets', () {
      expect(AppTheme.accentPresets.length, 8);
    });

    test('preset names match presets', () {
      expect(AppTheme.accentPresetNames.length, 8);
    });

    test('radius constants are correct', () {
      expect(AppTheme.radiusSm, 8);
      expect(AppTheme.radiusMd, 12);
      expect(AppTheme.radiusLg, 16);
    });

    test('avatarColor returns a color from the palette', () {
      expect(AppTheme.avatarColors, contains(AppTheme.avatarColor(0)));
      expect(AppTheme.avatarColors, contains(AppTheme.avatarColor(42)));
    });
  });

  group('AppColors', () {
    test('withAccent uses Nothing OS dark palette', () {
      final c = AppColors.withAccent(0xFFFF2D2D);
      expect(c.background, const Color(0xFF000000));
      expect(c.surface, const Color(0xFF0A0A0A));
      expect(c.surfaceDim, const Color(0xFF111111));
      expect(c.ink, const Color(0xFFFFFFFF));
      expect(c.inkSecondary, const Color(0xFF888888));
      expect(c.inkMuted, const Color(0xFF555555));
      expect(c.border, const Color(0xFF1A1A1A));
      expect(c.borderStrong, const Color(0xFF2A2A2A));
      expect(c.positive, const Color(0xFF4ADE80));
      expect(c.negative, const Color(0xFFFF4444));
    });

    test('withAccent uses the provided accent color', () {
      final c = AppColors.withAccent(0xFF3B82F6);
      expect(c.accent, const Color(0xFF3B82F6));
    });

    test('accentSoft is 8% opacity of accent', () {
      final c = AppColors.withAccent(0xFFFF2D2D);
      // alpha channel: 0.08 * 255 ≈ 20
      expect((c.accentSoft.a * 255).round().clamp(0, 255), closeTo(20, 2));
    });

    test('accentHover is lighter than accent', () {
      final c = AppColors.withAccent(0xFFFF2D2D);
      expect(c.accentHover.computeLuminance(), greaterThan(c.accent.computeLuminance()));
    });

    test('darkTheme builds with custom accent', () {
      final theme = AppTheme.darkTheme(accentHex: 0xFF3B82F6);
      final appColors = theme.extension<AppColors>()!;
      expect(appColors.accent, const Color(0xFF3B82F6));
    });

    test('lightTheme returns dark theme (dark-only app)', () {
      final light = AppTheme.lightTheme(accentHex: 0xFFFF2D2D);
      final dark = AppTheme.darkTheme(accentHex: 0xFFFF2D2D);
      expect(light.brightness, dark.brightness);
    });

    test('copyWith preserves non-changed fields', () {
      final c = AppColors.withAccent(0xFFFF2D2D);
      final c2 = c.copyWith(accent: const Color(0xFF3B82F6));
      expect(c2.accent, const Color(0xFF3B82F6));
      expect(c2.background, c.background);
      expect(c2.surface, c.surface);
    });
  });
}