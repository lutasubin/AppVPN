import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lớp hỗ trợ Firebase Analytics để theo dõi sự kiện trong ứng dụng.
class AnalyticsHelper {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Lấy instance của FirebaseAnalytics
  static FirebaseAnalytics get instance => _analytics;

  /// Ghi nhận sự kiện khi người dùng kết nối VPN
  static Future<void> logVpnConnect(
      String serverName, String serverCountry) async {
    await _analytics.logEvent(
      name: 'vpn_connect',
      parameters: {
        'server_name': serverName,
        'server_country': serverCountry,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Cập nhật thống kê kết nối trong SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = 'vpn_count_$serverName';
    int currentCount = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentCount + 1);
  }

  /// Ghi nhận sự kiện khi người dùng ngắt kết nối VPN
  static Future<void> logVpnDisconnect(
      String serverName, int connectionDuration) async {
    await _analytics.logEvent(
      name: 'vpn_disconnect',
      parameters: {
        'server_name': serverName,
        'duration_seconds': connectionDuration,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Ghi nhận sự kiện khi người dùng thay đổi cài đặt
  static Future<void> logSettingChange(String settingName, String value) async {
    await _analytics.logEvent(
      name: 'setting_change',
      parameters: {
        'setting_name': settingName,
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Ghi nhận sự kiện khi người dùng chọn máy chủ
  static Future<void> logServerSelection(
      String serverName, String serverCountry) async {
    await _analytics.logEvent(
      name: 'server_selection',
      parameters: {
        'server_name': serverName,
        'server_country': serverCountry,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Ghi nhận sự kiện khi người dùng mở ứng dụng
  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// Đặt ID người dùng để theo dõi
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Đặt thuộc tính người dùng
  static Future<void> setUserProperty(
      {required String name, required String value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }


  
   static Future<Map<String, dynamic>?> getMostConnectedVpn() async {
  final prefs = await SharedPreferences.getInstance();
  final allKeys = prefs.getKeys().where((k) => k.startsWith('vpn_count_'));

  if (allKeys.isEmpty) return null;

  String topServer = '';
  int topCount = 0;

  for (String key in allKeys) {
    int count = prefs.getInt(key) ?? 0;
    if (count > topCount) {
      topCount = count;
      topServer = key.replaceFirst('vpn_count_', '');
    }
  }

  return {
    'server_name': topServer, // String
    'count': topCount         // int
  };
}

}
