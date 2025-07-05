import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/SignalStrengthIcon.dart';

class VpnCardWireGuard extends StatelessWidget {
  final LocalVpnServer server;
  VpnCardWireGuard({super.key, required this.server});
  final controller = Get.find<LocalController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedServer.value?.ip == server.ip &&
          controller.selectedServer.value?.protocol == server.protocol;

      // 🔍 Debug logs
      print("🔍 WireGuard Card - ${server.countryName}:");
      print("   Server IP: ${server.ip}, Protocol: ${server.protocol}");
      print(
          "   Selected IP: ${controller.selectedServer.value?.ip}, Protocol: ${controller.selectedServer.value?.protocol}");
      print("   IsSelected: $isSelected");

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
            print("🔥 Tapping WireGuard server: ${server.countryName}");
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
                style: TextStyle(
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
                child: Row(
                  children: const [
                    Icon(Icons.bolt, size: 14, color: Color(0xFFFFFFFF)),
                    SizedBox(width: 2),
                    Text(
                      'Social media',
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
                  color:
                      isSelected ? const Color(0xFFF15E24) : Colors.transparent,
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
