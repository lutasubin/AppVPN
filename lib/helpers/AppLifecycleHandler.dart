import 'package:flutter/widgets.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  bool _wasInBackground = false;
  DateTime? _lastAdTime;
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App vào background
        _wasInBackground = true;
        break;
      case AppLifecycleState.resumed:
        // Chỉ show open ad nếu thực sự từ background quay lại và đã 30s từ lần cuối
        if (_wasInBackground && _canShowAd()) {
          print('App resumed from background - showing open ad');
          AdHelper.showOpenAd(onComplete: () {
            print('Open ad completed');
            _lastAdTime = DateTime.now();
          });
          _wasInBackground = false;
        }
        break;
      case AppLifecycleState.detached:
        disconnectVPN();
        break;
      default:
        break;
    }
  }
  
  bool _canShowAd() {
    if (_lastAdTime == null) return true;
    return DateTime.now().difference(_lastAdTime!).inSeconds > 30; // 30s delay
  }

  void disconnectVPN() async {
    try {
      await VpnEngine.stopVpn(); // Hoặc phương thức tương ứng trong NizVPN
      print('VPN disconnected automatically.');
    } catch (e) {
      print('Error disconnecting VPN: $e');
    }
  }
}