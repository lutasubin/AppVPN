import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/home_controller.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';

class VpnCart extends StatelessWidget {
  final Vpn vpn;
  const VpnCart({super.key, required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() => Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Color(0xFF172032),
            borderRadius: BorderRadius.circular(10),
            border: controller.vpn.value == vpn
                ? Border.all(color: const Color(0xFFF15E24), width: 2)
                : null,
          ),
          child: ListTile(
              onTap: () {
                controller.vpn.value = vpn;
                Pref.vpn = vpn;
                // controller.setVpn(vpn);
                Get.back();

                MyDialogs.success(msg: 'Connecting VPN Location 5s...');

                if (controller.vpnState.value == VpnEngine.vpnConnected) {
                  VpnEngine.stopVpn();
                  Future.delayed(Duration(seconds: 2), () {
                    controller.connectToVpn();
                  });
                } else {
                  controller.connectToVpn();
                }
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/flags/${vpn.CountryShort.toLowerCase()}.png',
                  height: 35,
                  width: 35,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                vpn.CountryLong,
                style: TextStyle(fontSize: 14, color: const Color(0xFFFFFFFF)),
              ),
              subtitle: Row(
                children: [
                  Text(
                    vpn.IP,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF767C8A),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.wifi, color: Color(0xFF03C343), size: 18),
                  SizedBox(width: 3),
                  Text(
                    "${vpn.Ping} m/s",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _getPingColor(vpn.Ping.toString()),
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                controller.vpn.value.IP == vpn.IP
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: controller.vpn.value.IP == vpn.IP
                    ? const Color(0xFFF15E24)
                    : Color(0xFF767C8A),
              )),
        ));
  }

  Color _getPingColor(String ping) {
    int? pingValue = int.tryParse(ping);
    if (pingValue == null) {
      return Color(0xFF767C8A); // Màu mặc định nếu ping không hợp lệ
    }

    if (pingValue <= 50) {
      return Color(0xFF03C343);
    } else if (pingValue <= 100) {
      return Color(0xFFEFA80E);
    } else {
      return Colors.red;
    }
  }
}
