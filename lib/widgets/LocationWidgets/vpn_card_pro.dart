import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/SignalStrengthIcon.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/watch_video_pro.dart';

class VpnCardLocalPro extends StatelessWidget {
  final LocalVpnServer server;
  const VpnCardLocalPro({super.key, required this.server});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocalController>();

    return Obx(() => Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color:
                const Color(0xFF172032), // Background màu tối giống trong hình
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFF2F3A51),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () async {
              WatchAdDialogPro.show(context, server, () async {
                AdHelper.showRewardedAd(onComplete: () async {
                  await Future.delayed(Duration(milliseconds: 300));
                  await controller.setVpnFromLocalServer(server);
                  Get.back();
                  if (controller.vpnState.value == VpnEngine.vpnConnected) {
                    VpnEngine.stopVpn();
                    Future.delayed(Duration(seconds: 2), () {
                      controller.connectToVpn();
                    });
                  } else {
                    controller.connectToVpn();
                  }
                });
              });
            },

            // Thêm cờ quốc gia làm leading widget
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(
                'assets/flags/${server.countryCode.toLowerCase()}.png',
              ),
            ),
            title: Row(
              children: [
                Row(
                  children: [
                    Text(
                      server.countryName,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.play_arrow,
                      color: Color(0xFFF15E24),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SignalStrengthIcon(level: 3),
                SizedBox(width: 12),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.vpn.value.IP == server.ip
                          ? const Color(0xFFF15E24)
                          : Color(0xFFFFFFFF),
                      width: 2,
                    ),
                    color: controller.vpn.value.IP == server.ip
                        ? const Color(0xFFF15E24)
                        : Colors.transparent,
                  ),
                  child: controller.vpn.value.IP == server.ip
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
}
