
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/vpn_card_highspeed.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/vpn_card_pro.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/vpn_card_speed.dart';

/// Màn hình hiển thị danh sách máy chủ VPN
class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _adController2 = NativeAdController();

  final controller = Get.find<LocalController>();

  @override
  Widget build(BuildContext context) {

    // Nạp quảng cáo native
    _adController2.ad = AdHelper.loadNativeAd2(adController: _adController2);
    // Sử dụng Obx để theo dõi thay đổi trạng thái
    return Obx(
      () => SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFF0D1424),
          // Thiết lập thanh app bar
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1424),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFFFFFFFF), size: 25),
            ),
            title: Text(
              'sever'.tr,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Thanh điều hướng dưới cùng hiển thị quảng cáo nếu có
          bottomNavigationBar:
              _adController2.ad != null && _adController2.adLoaded.isTrue
                  ? SafeArea(
                      child: SizedBox(
                          height: 120, child: AdWidget(ad: _adController2.ad!)))
                  : null,
          // Nội dung chính của màn hình
          body: SafeArea(
            child: Column(
              children: [
                // Hiển thị tiêu đề "Chọn máy chủ VPN"
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "select_vpn_servers".tr,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 15,
                    ),
                  ),
                ),
                // Phần nội dung chính, tùy thuộc vào trạng thái
                Expanded(
                  child: _buildFlatListView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Phương thức hiển thị danh sách VPN dạng phẳng (không nhóm theo quốc gia)
  Widget _buildFlatListView() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      children: [
         // Hiển thị tất cả VPN Fast
         ...controller.availableServersFast
            .map((server) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VpnCardLocalSpeed(server: server),
                ))
            .toList(),
        // Hiển thị tất cả VPN Pro
        ...controller.availableServersPro
            .map((server) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VpnCardLocalPro(server: server),
                ))
            .toList(),
        // Hiển thị tất cả VPN thường
        ...controller.availableServers
            .map((server) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VpnCardLocal(
                    server: server,
                  ),
                ))
            .toList(),
      ],
    );
  }
}