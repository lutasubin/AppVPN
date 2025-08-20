import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/icon_custom/SignalStrengthIcon.dart';

// VpnCardLocal - CẬP NHẬT để sử dụng logic thống nhất
class VpnCardLocal extends StatelessWidget {
  final LocalVpnServer server;
  VpnCardLocal({super.key, required this.server});
  final controller = Get.find<LocalController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ SỬ DỤNG LOGIC THỐNG NHẤT như VpnCardWireGuard
      final isSelected = controller.selectedServer?.ip == server.ip &&
          controller.selectedServer?.protocol == server.protocol;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF172032),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2F3A51),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: () async {
            await controller.setVpnFromLocalServer(server);
            Get.back();
          },
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(
              'assets/flags/${server.countryCode.toLowerCase()}.png',
            ),
          ),
          title: Row(
            children: [
              Text(
                server.countryName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2484F1), // cam đậm
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, size: 14, color: Color(0xFFFFFFFF)),
                    SizedBox(width: 2),
                    Text(
                      'Social',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SignalStrengthIcon(level: 3),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2484F1)
                        : const Color(0xFFFFFFFF),
                    width: 2,
                  ),
                  color:
                      isSelected ? const Color(0xFF2484F1) : Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
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
