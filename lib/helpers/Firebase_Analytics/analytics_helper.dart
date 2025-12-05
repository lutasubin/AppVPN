import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lớp hỗ trợ Firebase Analytics để theo dõi sự kiện trong ứng dụng.
class AnalyticsHelper {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? observer;

  /// Lấy instance của FirebaseAnalytics (sẽ throw nếu chưa init)
  static FirebaseAnalytics get instance {
    if (_analytics == null) {
      throw Exception(
        'FirebaseAnalytics chưa được khởi tạo! Hãy gọi AnalyticsHelper.init() sau khi Firebase.initializeApp()',
      );
    }
    return _analytics!;
  }

  /// Khởi tạo Analytics sau khi Firebase init xong
  static Future<void> init() async {
    _analytics = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: _analytics!);
  }

  static Future<void> logVpnConnect(
      String serverName, String serverCountry) async {
    await _analytics?.logEvent(
      name: 'vpn_connect',
      parameters: {
        'server_name': serverName,
        'server_country': serverCountry,
        'value': 0.00258,
        'currency': 'USD',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final prefs = await SharedPreferences.getInstance();
    final key = 'vpn_count_$serverName';
    int currentCount = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentCount + 1);
  }

  static Future<void> logVpnDisconnect(
      String serverName, int connectionDuration) async {
    await _analytics?.logEvent(
      name: 'vpn_disconnect',
      parameters: {
        'server_name': serverName,
        'duration_seconds': connectionDuration,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logSettingChange(String settingName, String value) async {
    await _analytics?.logEvent(
      name: 'setting_change',
      parameters: {
        'setting_name': settingName,
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logServerSelection(
      String serverName, String serverCountry) async {
    await _analytics?.logEvent(
      name: 'server_selection',
      parameters: {
        'server_name': serverName,
        'server_country': serverCountry,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logAppOpen() async {
    await _analytics?.logAppOpen();
  }

  static Future<void> setUserId(String userId) async {
    await _analytics?.setUserId(id: userId);
  }

  static Future<void> setUserProperty(
      {required String name, required String value}) async {
    await _analytics?.setUserProperty(name: name, value: value);
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

    return {'server_name': topServer, 'count': topCount};
  }
}
