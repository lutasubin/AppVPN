import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/widgets/watcch_video.dart';

class VpnCardLocal extends StatelessWidget {
  final LocalVpnServer server;
  const VpnCardLocal({super.key, required this.server});

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
              WatchAdDialog.show(context, server, () async {
                AdHelper.showRewardedAd(onComplete: () async {
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

            // Add country flag as leading widget

            title: Row(
              children: [
                Text(
                  server.countryName,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.play_circle_fill,
                  color: Color(0xFFF15E24),
                  size: 15,
                ),
              ],
            ),
            subtitle: Text(
              server.ip,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF767C8A),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon(
                //   Icons.workspace_premium,
                //   color: Color(0xFFF15E24),
                //   size: 16,
                // ),
                // SizedBox(width: 12),
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
