import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _kServerUrlKey = 'server_url';
  static const String _kCurrentRoomKey = 'current_room_code';
  static const String _kAccentColorKey = 'accent_color';
  static const String defaultServerUrl = 'http://localhost:8000';

  /// Default accent color stored as a hex string without the leading '#'
  /// or '0x' (e.g. "FF2D2D"). Matches [AppTheme.defaultAccent].
  static const String defaultAccentHex = 'FF2D2D';

  String _serverUrl;
  String? _currentRoomCode;

  ApiConfig._(this._serverUrl, this._currentRoomCode);

  static Future<ApiConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ApiConfig._(
      prefs.getString(_kServerUrlKey) ?? defaultServerUrl,
      prefs.getString(_kCurrentRoomKey),
    );
  }

  String get serverUrl => _serverUrl;
  String? get currentRoomCode => _currentRoomCode;
  bool get hasServerUrl => _serverUrl.isNotEmpty;

  Future<void> setServerUrl(String url) async {
    final cleaned = url.trim().replaceAll(RegExp(r'/+$'), '');
    _serverUrl = cleaned;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kServerUrlKey, cleaned);
  }

  Future<void> setCurrentRoomCode(String? code) async {
    _currentRoomCode = code;
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_kCurrentRoomKey);
    } else {
      await prefs.setString(_kCurrentRoomKey, code);
    }
  }

  /// Load the saved accent color hex string (e.g. "FF2D2D").
  /// Returns [defaultAccentHex] if none is saved.
  static Future<String> loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccentColorKey) ?? defaultAccentHex;
  }

  /// Persist the accent color hex string (without leading '#' or '0x').
  static Future<void> saveAccentColor(String hex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccentColorKey, hex);
  }
}
