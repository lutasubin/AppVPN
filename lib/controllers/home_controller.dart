import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/mydilog2.dart';
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

  bool _manuallyDisconnected = false;

  void connectToVpn() async {

     print("Đang cố gắng kết nối với VPN...");

    if (vpn.value.OpenVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {

          print("VPN hiện tại đang ngắt kết nối. Đang tiếp tục kết nối...");

      final data = Base64Decoder().convert(vpn.value.OpenVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);

      final vpnConfig = VpnConfig(
          country: vpn.value.CountryLong,
          username: 'vpn',
          password: 'vpn',
          config: config);

              print("Bắt đầu kết nối VPN...");


      AdHelper.showInterstitialAd(onComplete: () async {
        _startWaitingTimer();

        await VpnEngine.startVpn(vpnConfig);
        vpnState.value = VpnEngine.vpnConnected;

         print("Kết nối VPN thành công!");

        _cancelWaitingTimer();
        update();
      });
    } else {
       print("VPN đã kết nối. Đang ngắt kết nối...");
      _disconnectVpn(showWarning: false);
    }
  }

  void _disconnectVpn({bool showWarning = false}) async {

    print("Đang ngắt kết nối VPN...");
    _manuallyDisconnected = true; // ✅ Đánh dấu người dùng tự bấm

    await VpnEngine.stopVpn();
    vpnState.value = VpnEngine.vpnDisconnected;
    print("VPN đã ngắt kết nối.");
    _cancelWaitingTimer(showWarning: showWarning);
    update();
  }

  void _startWaitingTimer() {
      print("Bắt đầu hẹn giờ chờ...");

    _cancelWaitingTimer();
    _manuallyDisconnected = false; // ✅ Reset lại trước mỗi lần kết nối

    _remainingSeconds.value = 20;
    _waitingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds.value > 0) {
        _remainingSeconds.value--;
         print("Đang chờ... Còn ${_remainingSeconds.value} giây.");
        update();
      } else {
        if (vpnState.value != VpnEngine.vpnConnected &&
            !_manuallyDisconnected) {
                      print("Hết thời gian chờ. Đang ngắt kết nối VPN...");

          VpnEngine.stopVpn(); // Ngắt kết nối khi hết thời gian chờ
          _cancelWaitingTimer(
              showWarning: true); // ⚠️ Chỉ hiển thị warning nếu thất bại
          update();
        }
      }
    });
  }

  void _cancelWaitingTimer({bool showWarning = false}) {
    _waitingTimer?.cancel();
    _waitingTimer = null;
    if (showWarning) {
       print("Cảnh báo: Kết nối VPN thất bại.");
      MyDialogs2.warning(
        msg: 'warning'.tr,
      );
    }
  }

  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Color(0xFF343A4B);
      case VpnEngine.vpnConnected:
        return Color(0xFFF15E24);

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
