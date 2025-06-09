import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/apis/apis.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/models/vpn_status.dart';
import 'package:vpn_basic_project/screens/location_screen.dart';
import 'package:vpn_basic_project/screens/menu_screen.dart';
import 'package:vpn_basic_project/screens/network_test_screen.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/VpnControlButon.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/change_location.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/home_card.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/home_card2.dart';
import '../services/vpn_engine.dart';

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

  // Biến để theo dõi trạng thái hiển thị quảng cáo cho kết nối hiện tại
  final _adShownForCurrentConnection = false.obs;

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin IP ban đầu
    Apis.getIPDetails(ipData: ipData);

    // Tải quảng cáo tự nhiên
    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    // Tải trước quảng cáo toàn màn hình
    AdHelper.precacheInterstitialAd();

    // Biến để ngăn chặn nhiều lần xử lý trạng thái VPN
    Timer? debounceTimer;

    /// Lắng nghe trạng thái VPN và cập nhật thông tin IP khi kết nối thành công.
    VpnEngine.vpnStageSnapshot().listen((event) {
      // Debounce để tránh xử lý nhiều sự kiện liên tiếp
      debounceTimer?.cancel();
      debounceTimer = Timer(Duration(milliseconds: 500), () {
        _controller.vpnState.value = event;
        if (event == VpnEngine.vpnConnected) {
          Apis.getIPDetails(ipData: ipData).then((_) {
            ipData.refresh();
            // Hiển thị quảng cáo toàn màn hình khi VPN kết nối thành công
            if (!_adShownForCurrentConnection.value) {
              print('Attempting to show interstitial ad');
              AdHelper.showInterstitialAd(onComplete: () {
                print('Interstitial ad shown or failed');
                _adShownForCurrentConnection.value = true;
              });
            }
          }).catchError((e) {
            print('Lỗi khi lấy IP: $e');
          });
        } else if (event == VpnEngine.vpnDisconnected) {
          // Reset connection duration and ad shown status
          _controller.connectionDuration.value = Duration();
          _adShownForCurrentConnection.value =
              false; // Đặt lại trạng thái khi ngắt kết nối
        }
      });
    });

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
                          flex: 3,
                          child: Center(
                            child: VpnControlButton(
                              controller: _controller,
                              constraints: constraints,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: StreamBuilder<VpnStatus?>(
                            initialData:
                                VpnStatus(byteIn: '---', byteOut: '---'),
                            stream: VpnEngine.vpnStatusSnapshot(),
                            builder: (context, snapshot) {
                              print(
                                  'Snapshot data: ${snapshot.data?.byteIn}, ${snapshot.data?.byteOut}');
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: HomeCard2(
                                      title: snapshot.data?.byteOut ?? '---',
                                      icon: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFF4684F6),
                                        radius:
                                            constraints.maxWidth * 0.08 > 25.0
                                                ? 25.0
                                                : constraints.maxWidth * 0.08,
                                        child: Icon(
                                          Icons.arrow_upward_rounded,
                                          size:
                                              constraints.maxWidth * 0.06 > 18.0
                                                  ? 18.0
                                                  : constraints.maxWidth * 0.06,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                      subtitle: 'Uploads'.tr,
                                    ),
                                  ),
                                  Flexible(
                                    child: HomeCard(
                                      title: snapshot.data?.byteIn ?? '---',
                                      icon: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFF03C343),
                                        radius:
                                            constraints.maxWidth * 0.08 > 25.0
                                                ? 25.0
                                                : constraints.maxWidth * 0.08,
                                        child: Icon(
                                          Icons.arrow_downward_rounded,
                                          size:
                                              constraints.maxWidth * 0.06 > 18.0
                                                  ? 18.0
                                                  : constraints.maxWidth * 0.06,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                      subtitle: 'Download'.tr,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
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
                IconButton(
                  padding: EdgeInsets.only(right: 8.0),
                  onPressed: () {
                    Get.to(() => NetworkTestScreen());
                  },
                  icon: Icon(
                    CupertinoIcons.info,
                    size: 25.0,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Obx(() {
              if (_adController.ad != null && _adController.adLoaded.isTrue) {
                return SafeArea(
                  child: SizedBox(
                      height: 120, child: AdWidget(ad: _adController.ad!)),
                );
              } else {
                return SizedBox.shrink();
              }
            })));
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
            child: Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF172032), // Move color here
                    borderRadius: BorderRadius.circular(32.0), // Bo góc
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChangeLocation(
                          title: _controller.vpn.value.CountryLong.isEmpty
                              ? 'Choose location'.tr
                              : _controller.vpn.value.CountryLong,
                          icon: CircleAvatar(
                            backgroundColor: Color(0xFF02091A),
                            radius: 18.0,
                            child: _controller.vpn.value.CountryShort.isEmpty
                                ? Icon(
                                    Icons.public, // icon quả cầu thế giới
                                    color: Color(0xFF1976D2),
                                    size: 30,
                                  )
                                : null,
                            backgroundImage: _controller
                                    .vpn.value.CountryShort.isEmpty
                                ? null
                                : AssetImage(
                                    'assets/flags/${_controller.vpn.value.CountryShort.toLowerCase()}.png'),
                          ),
                          ip: _controller.vpn.value.IP.isEmpty
                              ? 'loading...'
                              : _controller.vpn.value.IP,
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
                )),
          ),
        ),
      );
}
