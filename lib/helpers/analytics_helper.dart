import 'package:firebase_analytics/firebase_analytics.dart';

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
}
