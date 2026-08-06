import 'package:flutter/material.dart';

import 'api_config.dart';
import 'theme.dart';

/// Holds the current accent color and rebuilds the app when it changes.
///
/// The accent is loaded from [SharedPreferences] on startup via
/// [ThemeProvider.load] and persisted whenever [setAccent] is called.
/// The current [AppColors] extension is derived from the accent so
/// that any widget calling [AppColors.of] picks up the new color
/// immediately.
class ThemeProvider extends ChangeNotifier {
  int _accentHex;

  ThemeProvider._(this._accentHex);

  /// Create a provider with the default accent (Nothing Red).
  factory ThemeProvider() => ThemeProvider._(AppTheme.defaultAccent);

  /// Load the saved accent from SharedPreferences and return a
  /// ready-to-use provider.
  static Future<ThemeProvider> load() async {
    final hexStr = await ApiConfig.loadAccentColor();
    return ThemeProvider._(_parseHex(hexStr));
  }

  /// Current accent color.
  Color get accentColor => Color(_accentHex);

  /// Current accent as an int (ARGB).
  int get accentHex => _accentHex;

  /// The [AppColors] extension for the current accent.
  AppColors get appColors => AppColors.withAccent(_accentHex);

  /// The [ThemeData] built from the current accent.
  ThemeData get theme => AppTheme.darkTheme(accentHex: _accentHex);

  /// Change the accent color, persist it, and notify listeners.
  Future<void> setAccent(int hex) async {
    if (hex == _accentHex) return;
    _accentHex = hex;
    notifyListeners();
    await ApiConfig.saveAccentColor(_toHexStr(hex));
  }

  /// Parse a hex string like "FF2D2D" or "#FF2D2D" into an ARGB int
  /// (with full opacity alpha 0xFF).
  static int _parseHex(String input) {
    var s = input.trim();
    if (s.startsWith('#')) s = s.substring(1);
    if (s.startsWith('0x') || s.startsWith('0X')) s = s.substring(2);
    if (s.length == 6) {
      // RGB → prepend alpha
      s = 'FF$s';
    }
    return int.parse(s, radix: 16);
  }

  /// Convert an ARGB int to a 6-char hex string (RGB only, no alpha
  /// and no leading '#').
  static String _toHexStr(int hex) {
    return hex.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2);
  }
}