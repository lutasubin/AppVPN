import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/apis/vpn_gate.dart';
import 'package:vpn_basic_project/controllers/ads_controller/native_ad_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/view/screens/location/location_screen.dart';
import 'package:vpn_basic_project/view/screens/menu/menu_screen.dart';
import 'package:vpn_basic_project/view/screens/home/check_Ip/network_test_screen.dart';
import 'package:vpn_basic_project/view/screens/home/using_app/using_app.dart';
import 'package:vpn_basic_project/view/widgets/HomeWidgets/VpnControlButon.dart';
import 'package:vpn_basic_project/view/widgets/HomeWidgets/button_speed_map.dart';

/// Màn hình chính của ứng dụng VPN.
/// Hiển thị trạng thái VPN, nút kết nối, thông tin tải lên/tải xuống và quảng cáo.
class HomeScreen extends StatelessWidget {
  /// Constructor cho HomeScreen.
  HomeScreen({super.key});

  /// Dữ liệu chi tiết IP, được quản lý bằng Obx để theo dõi thay đổi.
  final ipData = IPDetails.fromJson({}).obs;

  /// Bộ điều khiển chính cho màn hình Home - SỬ DỤNG Get.find thay vì Get.put
  final _controller = Get.find<LocalController>();

  /// Bộ điều khiển quảng cáo tự nhiên.
  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin IP ban đầu
    Apis.getIPDetails(ipData: ipData);

    // Tải quảng cáo tự nhiên
    _adController.ad = AdHelper.loadNativeAdNew(adController: _adController);

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
                'assets/svg/Group 17.svg',
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xFF02091A), // Mã màu nền
                  BlendMode.dstATop,
                ),
              ),
              // Nội dung giao diện
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: _changeLocation(context),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: VpnControlButton(
                        controller: _controller,
                        constraints: constraints,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          // Hàng chứa 2 nút Check IP và Speed Test
                          Row(
                            children: [
                              Expanded(
                                child: IconTextButton(
                                    svgAsset: 'assets/svg/map.svg',
                                    label: 'ip'.tr,
                                    onTap: () {
                                      Get.to(() => NetworkTestScreen());
                                    }),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: IconTextButton(
                                    svgAsset: 'assets/svg/apps.svg',
                                    label: 'app'.tr,
                                    onTap: () {
                                      Get.to(() => ApplicationVpnScreen());
                                    }),
                              ),
                            ],
                          ),
                        ],
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
        leading: IconButton(
          onPressed: () {
            Get.to(() => MenuScreen());
          },
          icon: Icon(
            Icons.menu,
            size: 25.0,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        title: SvgPicture.asset(
          'assets/svg/logo.svg',
          width: 158.0,
          height: 35.0,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              print('vip');
            },
            child: SvgPicture.asset('assets/svg/vip.svg'),
          )
        ],
      ),
      bottomNavigationBar: Obx(() {
        final ad = _adController.ad;
        if (ad != null &&
            _adController.adLoaded.isTrue &&
            !_adController.isDisposed) {
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
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF172032),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF02091A),
                      radius: 18.0,
                      child: (countryShort.isEmpty)
                          ? SvgPicture.asset(
                              'assets/svg/earth.svg',
                              width: 30,
                              height: 30,
                            )
                          : null,
                      backgroundImage:
                          (countryShort.isEmpty) ? null : AssetImage(flagAsset),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        country,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CircleAvatar(
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
