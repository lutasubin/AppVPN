import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';

class VpnCart extends StatelessWidget {
  final Vpn vpn;
  const VpnCart({super.key, required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocalController>();

    return Obx(() => Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0xFF2F3A51),
                width: 0.5,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              controller.vpn.value = vpn;
              Pref.vpn = vpn;
              Get.back();

              if (controller.vpnState.value == VpnEngine.vpnConnected) {
                VpnEngine.stopVpn();
                Future.delayed(Duration(seconds: 2), () {
                  controller.connectToVpnFree();
                });
              } else {
                controller.connectToVpnFree();
              }
            },
            title: Text(
              vpn.CountryLong,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFFFFFFF),
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              vpn.IP,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF767C8A),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed,
                      color: Color(0xFF03C343),
                      size: 16,
                    ),
                    SizedBox(width: 4),
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
                SizedBox(width: 12),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.vpn.value.IP == vpn.IP
                          ? const Color(0xFFF15E24)
                          : Color(0xFFFFFFFF),
                      width: 2,
                    ),
                    color: controller.vpn.value.IP == vpn.IP
                        ? const Color(0xFFF15E24)
                        : Colors.transparent,
                  ),
                  child: controller.vpn.value.IP == vpn.IP
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
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
