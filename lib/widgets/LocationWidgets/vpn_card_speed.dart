import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/SignalStrengthIcon.dart';

class VpnCardLocalSpeed extends StatelessWidget {
  final LocalVpnServer server;
  VpnCardLocalSpeed({super.key, required this.server});
  final controller = Get.find<LocalController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ SỬ DỤNG LOGIC THỐNG NHẤT như VpnCardWireGuard
      final isSelected = controller.selectedServer.value?.ip == server.ip &&
          controller.selectedServer.value?.protocol == server.protocol;
      
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF172032),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF2F3A51),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: () async {
            await controller.setVpnFromLocalServer(server);
            Get.back();
          },
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF02091A),
            child: SvgPicture.asset(
              'assets/svg/earth.svg',
              width: 30,
              height: 30,
            ),
          ),
          title: Row(
            children: [
              Text(
                "Fast server",
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w500,
                ),
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
                    color: isSelected
                        ? const Color(0xFFF15E24)
                        : Color(0xFFFFFFFF),
                    width: 2,
                  ),
                  color: isSelected
                      ? const Color(0xFFF15E24)
                      : Colors.transparent,
                ),
                child: isSelected
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
      );
    });
  }
}