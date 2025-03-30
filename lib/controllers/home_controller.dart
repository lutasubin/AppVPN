import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/models/vpn_config.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/widgets/cowndowncircle.dart'; // Import CountdownCircle

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;
  final isConnecting = false.obs;
  final vpnState = VpnEngine.vpnDisconnected.obs;
  Timer? _waitingTimer;
  final RxInt _remainingSeconds = 20.obs;

  void connectToVpn() async{
    if (vpn.value.OpenVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      final data = Base64Decoder().convert(vpn.value.OpenVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);

      final vpnConfig = VpnConfig(
          country: vpn.value.CountryLong,
          username: 'vpn',
          password: 'vpn',
          config: config);

      AdHelper.showInterstitialAd(onComplete: () async {
        _remainingSeconds.value = 20;
        _startWaitingTimer();
        update();

        await VpnEngine.startVpn(vpnConfig);
        vpnState.value = VpnEngine.vpnConnected;
        _cancelWaitingTimer();
        update();
      });
    } else {
      vpnState.value = VpnEngine.vpnDisconnected;
      _cancelWaitingTimer();
      update();
     await VpnEngine.stopVpn();
    }
  }

  void _startWaitingTimer() {
    _cancelWaitingTimer();
    _remainingSeconds.value = 20;
    _waitingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds.value > 0) {
        _remainingSeconds.value--;
        update();
      } else {
        if (vpnState.value != VpnEngine.vpnConnected) {
          // vpnState.value = VpnEngine.vpnDisconnected;
          VpnEngine.stopVpn(); // Ngắt kết nối khi hết thời gian chờ

          _cancelWaitingTimer();
          update();
        }
      }
    });
  }

  void _cancelWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = null;
  }

  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Color(0xFF343A4B);
      case VpnEngine.vpnConnected:
        return Color(0xFFF15E24);
      // case VpnEngine.vpnConnecting:
      //   return Color(0xFFF15E24);
      default:
        return Color(0xFF343A4B);
    }
  }

  // Thay đổi từ String thành Widget
  Widget get getButtonContent {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Text(
          'TAP TO CONNECT'.tr,
          style: TextStyle(
            color: Color(0xFF03C343),
            fontSize: 12.0,
          ),
        );
      case VpnEngine.vpnConnected:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.privacy_tip,
              color: Color(0xFF03C343),
              size: 12,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'CONNECTED'.tr,
              style: TextStyle(
                color: Color(0xFF03C343),
                fontSize: 12.0,
              ),
            ),
          ],
        );
      // case VpnEngine.vpnConnecting:
      //   return Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Icon(
      //         Icons.connect_without_contact_outlined,
      //         color: Color(0xFF03C343),
      //         size: 12,
      //       ),
      //       SizedBox(
      //         width: 5,
      //       ),
      //       Text(
      //         'Connecting....'.tr,
      //         style: TextStyle(
      //           color: Color(0xFF03C343),
      //           fontSize: 12.0,
      //         ),
      //       ),
      //     ],
      //   );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Connecting....'.tr,
              style: TextStyle(
                color: Color(0xFF03C343),
                fontSize: 12.0,
              ),
            ),
            SizedBox(width: 5),
            Obx(
              () => CountdownCircle(
                remainingSeconds: _remainingSeconds.value,
                totalSeconds: 20,
                size: 30,
                progressColor: Color(0xFF03C343),
                backgroundColor: Color(0xFF767C8A),
              ),
            ),
          ],
        );
    }
  }

  void setVpn(Vpn newVpn) {
    if (vpnState.value == VpnEngine.vpnConnected) {
      VpnEngine.stopVpn();
      vpnState.value = VpnEngine.vpnDisconnected;
    }

    vpn.value = newVpn;
    Pref.vpn = newVpn;
    _cancelWaitingTimer();
    update();
  }

  @override
  void onClose() {
    _cancelWaitingTimer();
    super.onClose();
  }
}
