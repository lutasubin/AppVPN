import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/ads_controller/native_ad_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/location/location_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/open_vpn_sever/vpn_card_highspeed.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/open_vpn_sever/vpn_card_pro.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/open_vpn_sever/vpn_card_api.dart';
import 'package:vpn_basic_project/view/widgets/LocationWidgets/wiregruard_vpn_sever/vpn_card_wireguard.dart';

/// Màn hình hiển thị danh sách máy chủ VPN
class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _adController2 = NativeAdController();
  final _adController3 = NativeAdController();

  final controller = Get.find<LocalController>();
  final locationController = Get.find<LocationController>();

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
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Nội dung chính của màn hình
          body: SafeArea(
            child: Column(
              children: [
                _buildModeSelector(),
                Expanded(
                  child: locationController.isShareFreeMode.value
                      ? _buildFlatListViewPublic()
                      : _buildFlatListViewFast(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Thanh chọn chế độ hiển thị VPN
  Widget _buildModeSelector() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () => locationController.isShareFreeMode.value = false,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Social Media',
                        style: TextStyle(
                          color: !locationController.isShareFreeMode.value
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF767C8A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )),
              const Text('|',
                  style: TextStyle(color: Color(0xFF03C343), fontSize: 18)),
              GestureDetector(
                onTap: () => locationController.isShareFreeMode.value = true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Streaming',
                      style: TextStyle(
                        color: locationController.isShareFreeMode.value
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF767C8A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  /// Phương thức hiển thị danh sách VPN dạng phẳng (không nhóm theo quốc gia)
  Widget _buildFlatListViewFast() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      children: [
        const SizedBox(
          height: 10,
        ),
        ...controller.availableServersPro.map((server) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: VpnCardLocalPro(server: server),
            )),
        Obx(() {
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
        const SizedBox(
          height: 10,
        ),
        ...controller.availableServers.map((server) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: VpnCardLocal(
                server: server,
              ),
            )),
      ],
    );
  }

  /// Phương thức hiển thị danh sách VPN dạng phẳng (không nhóm theo quốc gia)
  Widget _buildFlatListViewPublic() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      children: [
        const SizedBox(
          height: 10,
        ),
        ...controller.availableWireGuardApiServers.map((server) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: VpnCardWireGuard(
                server: server,
              ),
            )),
        Obx(() {
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
        const SizedBox(
          height: 10,
        ),
        ...controller.availableApiServers.map((server) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: VpnCardApi(
                server: server,
              ),
            )),
      ],
    );
  }
}
