import 'dart:convert';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/models/vpn_config.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;

  final vpnState = VpnEngine.vpnDisconnected.obs;

  void connectToVpn() {
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      // log('\nBefore:${vpn.value.OpenVPNConfigDataBase64}');

      final data = Base64Decoder().convert(vpn.value.OpenVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);

      final vpnConfig = VpnConfig(
          country: vpn.value.CountryLong,
          username: 'vpn',
          password: 'vpn',
          config: config);

      // log('\nAfter:$config');

      ///Start if stage is disconnected
      AdHelper.showInterstitialAd(onComplete: () async {
        await VpnEngine.startVpn(vpnConfig);
      });
    } else {
      ///Stop if stage is "not" disconnected
      VpnEngine.stopVpn();
    }
  }

  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.orange;
      case VpnEngine.vpnConnected:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  /// Lấy biểu tượng hiển thị cho nút
  // IconData get getButtonIcon {
  //   switch (vpnState.value) {
  //     case VpnEngine.vpnDisconnected:
  //       return Icons.power_settings_new; // Biểu tượng bật
  //     case VpnEngine.vpnConnected:
  //       return Icons.stop_sharp; // Biểu tượng ngắt
  //     default:
  //       return Icons.hourglass_top; // Biểu tượng chờ
  //   }
  // }

  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'Tap to connect';
      case VpnEngine.vpnConnected:
        return 'Disconnect';
      default:
        return 'Connecting....';
    }
  }
}
