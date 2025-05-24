import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';

class WatchAdDialogPro {
  static void show(
      BuildContext context, LocalVpnServer server, VoidCallback onComplete) {
    final countryCode = server.countryCode.toLowerCase(); // ví dụ: "us", "vn"

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          color: Color(0xFFFFFFFF),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "sever".tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage(
                      'assets/flags/$countryCode.png',
                    ),
                  ),
                  title: Text(
                    server.countryName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    server.ip,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF767C8A),
                    ),
                  ),
                  trailing: Text('👑', style: TextStyle(fontSize: 15)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back(); // Đóng bottom sheet
                    onComplete(); // Gọi callback
                  },
                  icon: const Icon(Icons.play_arrow, color:Color(0xFFFFFFFF),),
                  label: Text('watch_ads'.tr,
                      style: TextStyle(
                          color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF15E24),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
