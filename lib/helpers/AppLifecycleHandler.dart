import 'package:flutter/widgets.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ( state == AppLifecycleState.detached) {
      disconnectVPN();
    }
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
