import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/apis/vpn_gate.dart';
import 'package:vpn_basic_project/controllers/ads_controller/banner%20_ad_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/view/screens/home/check_Ip/ip.dart';
import 'package:vpn_basic_project/view/screens/location/location_screen.dart';
import 'package:vpn_basic_project/view/screens/menu/menu_screen.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

import 'package:vpn_basic_project/view/widgets/HomeWidgets/vpn_button/VpnControlButon.dart';

/// Màn hình chính của ứng dụng VPN.
/// Hiển thị trạng thái VPN, nút kết nối, thông tin tải lên/tải xuống và quảng cáo.
class HomeScreen extends StatelessWidget {
  /// Constructor cho HomeScreen.
  HomeScreen({super.key});

  /// Dữ liệu chi tiết IP, được quản lý bằng Obx để theo dõi thay đổi.
  final ipData = IPDetails.fromJson({}).obs;

  /// Bộ điều khiển chính cho màn hình Home - SỬ DỤNG Get.find thay vì Get.put
  final _controller = Get.find<LocalController>();

  final _baController = BannerAdController();

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin IP ban đầu
    APIs.getIPDetails(ipData: ipData);

    _baController.ba = AdHelper.loadBannerAd(baController: _baController);

    // Tải trước quảng cáo toàn màn hình
    AdHelper.precacheInterstitialAd();

    return SafeArea(
        child: Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Hình nền SVG
              SvgPicture.asset(
                'assets/svg/bg_home.svg',
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF02091A), // Mã màu nền
                  BlendMode.dstATop,
                ),
              ),
              // Nội dung giao diện
              Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Column(
                        children: [
                          const NativeAdWithLoadingWidget(adType: 'new1'),
                          const SizedBox(
                            height: 10,
                          ),
                          _changeLocation(context),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: VpnControlButton(
                        controller: _controller,
                        constraints: constraints,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Center(
                        child: Column(
                          children: [Ip()],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        title: SvgPicture.asset(
          'assets/svg/title_home.svg',
          width: 158.0,
          height: 35.0,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  Get.to(() => const MenuScreen());
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                )),
          )
        ],
      ),
      // bottomNavigationBar: Obx(() {
      //   return _baController.baLoaded.isTrue && _baController.ba != null
      //       ? SafeArea(
      //           child: SizedBox(
      //             height: 120,
      //             child: AdWidget(ad: _baController.ba!),
      //           ),
      //         )
      //       : Container(
      //           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //           height: 60,
      //           decoration: BoxDecoration(
      //             color: const Color(0xFF172032),
      //             borderRadius: BorderRadius.circular(12),
      //             border: Border.all(
      //               // ignore: deprecated_member_use
      //               color:
      //                   // ignore: deprecated_member_use
      //                   const Color(0xFFFFFFFF).withOpacity(0.05), // viền nhẹ
      //             ),
      //           ),
      //           child: const Center(
      //             child: Text(
      //               'Ads loading...',
      //               style: TextStyle(color: Colors.white, fontSize: 15),
      //             ),
      //           ),
      //         );
      // }),
    ));
  }

  /// Tạo thanh chọn vị trí VPN với thông tin quốc gia và IP.
  /// [context] dùng để điều hướng khi nhấn vào.
  Widget _changeLocation(BuildContext context) => SafeArea(
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: () {
              Get.to(() => LocationScreen());
            },
            child: Obx(() {
              final country = _controller.currentCountry.isEmpty
                  ? 'Choose location'.tr
                  : _controller.currentCountry;
              final countryShort = _controller.currentCountryShort;
              final flagAsset = _controller.currentFlagAsset;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                ),
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF172032),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF02091A),
                      radius: 18.0,
                      backgroundImage:
                          (countryShort.isEmpty) ? null : AssetImage(flagAsset),
                      child: (countryShort.isEmpty)
                          ? SvgPicture.asset(
                              'assets/svg/earth.svg',
                              width: 30,
                              height: 30,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        country,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Color(0xFF172032),
                      radius: 16.0,
                      child: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: Color(0xFFFFFFFF),
                        size: 25.0,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      );
}
