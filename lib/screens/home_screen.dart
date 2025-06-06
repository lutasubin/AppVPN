import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/apis/apis.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/controllers/network_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/mydilog2.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/models/vpn_status.dart';
import 'package:vpn_basic_project/screens/location_screen.dart';
import 'package:vpn_basic_project/screens/menu_screen.dart';
import 'package:vpn_basic_project/screens/network_test_screen.dart';
import 'package:vpn_basic_project/widgets/change_location.dart';
import 'package:vpn_basic_project/widgets/count_down_time.dart';
import 'package:vpn_basic_project/widgets/home_card.dart';
import 'package:vpn_basic_project/widgets/home_card2.dart';
import '../services/vpn_engine.dart';

/// Màn hình chính của ứng dụng VPN.
/// Hiển thị trạng thái VPN, nút kết nối, thông tin tải lên/tải xuống và quảng cáo.
class HomeScreen extends StatelessWidget {
  /// Constructor cho HomeScreen.
  HomeScreen({super.key});

  /// Dữ liệu chi tiết IP, được quản lý bằng Obx để theo dõi thay đổi.
  final ipData = IPDetails.fromJson({}).obs;

  /// Bộ điều khiển chính cho màn hình Home.
  final _controller = Get.put(LocalController());

  /// Bộ điều khiển quảng cáo tự nhiên.
  final _adController = NativeAdController();

  // Lấy NetworkController
  final _networkController = Get.find<NetworkController>();

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin IP ban đầu
    Apis.getIPDetails(ipData: ipData);

    // Tải quảng cáo tự nhiên
    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    /// Lắng nghe trạng thái VPN và cập nhật thông tin IP khi kết nối thành công.
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
      if (event == VpnEngine.vpnConnected) {
        Apis.getIPDetails(ipData: ipData).then((_) {
          ipData.refresh();
        }).catchError((e) {
          print('Lỗi khi lấy IP: $e');
        });
      }
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
                        flex: 3,
                        child: Center(
                            child: Obx(() => _vpnButton(context, constraints))),
                      ),
                      Expanded(
                        flex: 2,
                        child: StreamBuilder<VpnStatus?>(
                          initialData: VpnStatus(byteIn: '---', byteOut: '---'),
                          stream: VpnEngine.vpnStatusSnapshot(),
                          builder: (context, snapshot) {
                            print(
                                'Snapshot data: ${snapshot.data?.byteIn}, ${snapshot.data?.byteOut}');
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: HomeCard2(
                                    title: snapshot.data?.byteOut ?? '---',
                                    icon: CircleAvatar(
                                      backgroundColor: const Color(0xFF4684F6),
                                      radius: constraints.maxWidth * 0.08 > 30.0
                                          ? 30.0
                                          : constraints.maxWidth * 0.08,
                                      child: Icon(
                                        Icons.arrow_upward_rounded,
                                        size: constraints.maxWidth * 0.06 > 24.0
                                            ? 24.0
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
                                      backgroundColor: const Color(0xFF03C343),
                                      radius: constraints.maxWidth * 0.08 > 30.0
                                          ? 30.0
                                          : constraints.maxWidth * 0.08,
                                      child: Icon(
                                        Icons.arrow_downward_rounded,
                                        size: constraints.maxWidth * 0.06 > 24.0
                                            ? 24.0
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
              onPressed: () async {
                if (!await _networkController.checkConnection()) {
                  MyDialogs2.error(msg: 'error_connect_server'.tr);
                  return;
                }
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
                onPressed: () async {
                  if (!await _networkController.checkConnection()) {
                    MyDialogs2.error(msg: 'error_connect_server'.tr);
                    return;
                  }
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
          bottomNavigationBar: Container(
            color: const Color(0xFF02091A),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _changeLocation(context),
                SizedBox(
                  height: 5,
                ),
                Obx(() {
                  //!boc obx thang vao ads luon
                  if (_adController.ad != null &&
                      _adController.adLoaded.isTrue) {
                    return SafeArea(
                      child: SizedBox(
                          height: 120, child: AdWidget(ad: _adController.ad!)),
                    );
                  } else {
                    return SizedBox.shrink(); // không hiển thị gì
                  }
                })
              ],
            ),
          )),
    );
  }

  /// Tạo nút điều khiển VPN với trạng thái động.
  /// [context] và [constraints] dùng để điều chỉnh kích thước responsive.
  Widget _vpnButton(BuildContext context, BoxConstraints constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            print('VPN State: ${_controller.vpnState.value}');
            final isRunning =
                _controller.vpnState.value == VpnEngine.vpnConnected;
            return Column(
              children: [
                if (_controller.vpnState.value == VpnEngine.vpnDisconnected)
                  Text(
                    'Disconnected'.tr,
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.08 > 40.0
                          ? 40.0
                          : constraints.maxWidth * 0.08,
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (isRunning) CountDownTimer(startTimer: true),
              ],
            );
          }),
          SizedBox(height: 8),
          // update lai trang thai ket noi
          _controller.getButtonContent,

          SizedBox(height: 80),
          Center(
            child: GestureDetector(
              onTap: () async {
                // Kiểm tra kết nối mạng trước khi kết nối VPN
                if (!await _networkController.checkConnection()) {
                  MyDialogs2.error(msg: 'error_connect_server'.tr);
                  return;
                }
                // Đếm số lần người dùng nhấn nút kết nối
                _controller.incrementConnectionAttempts(context);

                AdHelper.showInterstitialAd(onComplete: () async {
                  _controller.connectToVpn();
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: constraints.maxWidth * 0.4 > 148.0
                    ? 148.0
                    : constraints.maxWidth * 0.4,
                height: (constraints.maxWidth * 0.4 > 148.0
                        ? 148.0
                        : constraints.maxWidth * 0.4) *
                    0.54,
                decoration: BoxDecoration(
                  color: _controller.getButtonColor,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Align(
                  alignment: _controller.vpnState.value ==
                          VpnEngine.vpnConnected
                      //|| _controller.vpnState.value == VpnEngine.vpnConnecting
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(6.0),
                    width: (constraints.maxWidth * 0.4 > 148.0
                            ? 148.0
                            : constraints.maxWidth * 0.4) *
                        0.46,
                    height: (constraints.maxWidth * 0.4 > 148.0
                            ? 148.0
                            : constraints.maxWidth * 0.4) *
                        0.46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  /// Tạo thanh chọn vị trí VPN với thông tin quốc gia và IP.
  /// [context] dùng để điều hướng khi nhấn vào.
  Widget _changeLocation(BuildContext context) => SafeArea(
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: () async {
              if (!await _networkController.checkConnection()) {
                MyDialogs2.error(msg: 'error_connect_server'.tr);
                return;
              }
              Get.to(() => LocationScreen());
            },
            child: Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  color: Color(0xFF172032),
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: ChangeLocation(
                          title: _controller.vpn.value.CountryLong.isEmpty
                              ? 'Choose location'.tr
                              : _controller.vpn.value.CountryLong,
                          icon: CircleAvatar(
                            backgroundColor: Color(0xFF172032),
                            radius: 24.0,
                            child: _controller.vpn.value.CountryLong.isEmpty
                                ? Icon(
                                    CupertinoIcons.globe,
                                    size: 25.0,
                                    color: const Color(0xFFFFFFFF),
                                  )
                                : null,
                            backgroundImage: _controller
                                    .vpn.value.CountryLong.isEmpty
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
                          color: const Color(0xFFFFFFFF),
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