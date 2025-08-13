import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/ads_controller/native_ad_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/vpn_card_highspeed.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/vpn_card_pro.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/vpn_card_api.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/vpn_card_wireguard.dart';

/// Màn hình hiển thị danh sách máy chủ VPN
class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _adController2 = NativeAdController();
  final _adController3 = NativeAdController();

  final controller = Get.find<LocalController>();

  @override
  Widget build(BuildContext context) {
    // Nạp quảng cáo native
    _adController2.ad = AdHelper.loadNativeAdNew2(adController: _adController2);
    _adController3.ad = AdHelper.loadNativeAd(adController: _adController3);

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
          // Nội dung chính của màn hình
          body: SafeArea(
            child: Column(
              children: [
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
        Text(
          'Super VPN',
          style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 17,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 10,
        ),
        ...controller.availableServersPro
            .map((server) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VpnCardLocalPro(server: server),
                ))
            .toList(),
        Container(
          child: Obx(() {
            final ad = _adController2.ad;
            if (ad != null &&
                _adController2.adLoaded.isTrue &&
                !_adController2.isDisposed) {
              return SafeArea(
                child: SizedBox(
                  height: 120,
                  child: AdWidget(ad: ad),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Social VPN',
          style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 17,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 10,
        ),
        ...controller.availableServers
            .map((server) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VpnCardLocal(
                    server: server,
                  ),
                ))
            .toList(),
        Container(
          child: Obx(() {
            final ad = _adController3.ad;
            if (ad != null &&
                _adController3.adLoaded.isTrue &&
                !_adController3.isDisposed) {
              return SafeArea(
                child: SizedBox(
                  height: 120,
                  child: AdWidget(ad: ad),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Public VPN',
          style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 17,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 10,
        ),
        ...controller.availableApiServers
            .map((server) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VpnCardApi(
                    server: server,
                  ),
                ))
            .toList(),
        SizedBox(
          height: 5,
        ),
        Text(
          'Media VPN',
          style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 17,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 10,
        ),
        ...controller.availableWireGuardServers
            .map((server) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VpnCardWireGuard(
                    server: server,
                  ),
                ))
            .toList(),
      ],
    );
  }
}
