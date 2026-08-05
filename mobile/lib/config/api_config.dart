import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _kServerUrlKey = 'server_url';
  static const String _kCurrentRoomKey = 'current_room_code';
  static const String defaultServerUrl = 'http://localhost:8000';

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
}
