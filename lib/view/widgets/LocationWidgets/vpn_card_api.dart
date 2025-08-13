import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/helpers/dilogs/my_dilogs.dart';
import 'package:vpn_basic_project/models/vpn.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/SignalStrengthIcon.dart';

// VpnCardApi - Sử dụng dữ liệu từ API nhưng dùng chung LocalController
class VpnCardApi extends StatelessWidget {
  final Vpn server;
  VpnCardApi({super.key, required this.server});
  final controller = Get.find<LocalController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ SỬ DỤNG LOGIC THỐNG NHẤT như VpnCardLocal
      final isSelected = controller.vpn.IP == server.IP &&
          controller.vpn.CountryLong == server.CountryLong;

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
            await _setVpnFromApiServer(server);
            Get.back();
          },
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(
              'assets/flags/${server.CountryShort.toLowerCase()}.png',
            ),
          ),
          title: Row(
            children: [
              Text(
                server.CountryLong,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0CD09C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.bolt, size: 14, color: Color(0xFFFFFFFF)),
                    SizedBox(width: 2),
                    Text(
                      'Favor',
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
              SignalStrengthIcon(level: _getSignalLevel(server.Score)),
              SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Color(0xFF0CD09C)
                        : Color(0xFFFFFFFF),
                    width: 2,
                  ),
                  color:
                      isSelected ? Color(0xFF0CD09C) : Colors.transparent,
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

  /// ✅ Set VPN server from API using new method
  Future<void> _setVpnFromApiServer(Vpn server) async {
    try {
      // Nếu đang connected, tự động disconnect trước
      if (controller.vpnState == VpnEngine.vpnConnected) {
        MyDialogs.info(
          msg: 'Please disconnect VPN first before changing server!',
        );
        await Future.delayed(Duration(seconds: 3));
        return;
      }

      print('🌐 Setting API server: ${server.CountryLong}');
      
      // ✅ SỬ DỤNG METHOD MỚI từ LocalController
      await controller.setVpnFromApiServer(server);
      controller.update();
      
      print('✅ API server set successfully');
    } catch (e) {
      print('❌ Failed to set API server: $e');
    }
  }

  /// Get signal level based on server score
  int _getSignalLevel(int score) {
    if (score >= 800000) return 5; // Excellent
    if (score >= 600000) return 4; // Very Good
    if (score >= 400000) return 3; // Good
    if (score >= 200000) return 2; // Fair
    return 1; // Poor
  }
}