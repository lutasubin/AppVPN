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
  final isConnecting =
      false.obs; // Thêm thuộc tính để theo dõi trạng thái kết nối
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
        return Color(0xFF343A4B); // Màu xanh đậm xám;
      case VpnEngine.vpnConnected:
        return Color(0xFFF15E24); // Màu cam nổi bật
      case VpnEngine.vpnConnecting:
        return Color(0xFFF15E24);
      default:
        return Color(0xFF343A4B); // Màu xanh đậm xám
    }
  }

  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'TAP TO CONNECT'.tr;
      case VpnEngine.vpnConnected:
        return 'CONNECTED'.tr;
      case VpnEngine.vpnConnecting:
        return 'Connecting....'.tr;
      default:
        return 'Waiting....'.tr;
    }
  }
  void setVpn(Vpn newVpn) {
  vpn.value = newVpn;
  Pref.vpn = newVpn;
  update(); // Đảm bảo UI nhận thay đổi
}

}
