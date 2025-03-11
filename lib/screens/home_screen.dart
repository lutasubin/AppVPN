// import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/apis/apis.dart';
import 'package:vpn_basic_project/controllers/home_controller.dart';
// import 'package:vpn_basic_project/helpers/ad_helper.dart';
// import 'package:vpn_basic_project/helpers/config.dart';
// import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/main.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/models/vpn_status.dart';
import 'package:vpn_basic_project/screens/location_screen.dart';
import 'package:vpn_basic_project/screens/menu_screen.dart';
import 'package:vpn_basic_project/screens/network_test_screen.dart';
// import 'package:vpn_basic_project/screens/watch_ad_dialog.dart';
import 'package:vpn_basic_project/widgets/change_location.dart';
import 'package:vpn_basic_project/widgets/count_down_time%20.dart';
import 'package:vpn_basic_project/widgets/home_card.dart';
import '../services/vpn_engine.dart';

class HomeScreen extends StatelessWidget {
  final ipData = IPDetails.fromJson({}).obs;
  final _controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Apis.getIPDetails(ipData: ipData);

    /// Add listener to update vpn state
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

    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        leading: IconButton(
          onPressed: () => Get.to(() => MenuScreen()),
          icon: Icon(
            Icons.menu,
            size: 25,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        title: SvgPicture.asset(
          'assets/svg/logo.svg',
          width: 158,
          height: 35,
        ),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     if (Config.hideAds) {
          //       Get.changeThemeMode(
          //           Pref.isDartMode ? ThemeMode.light : ThemeMode.dark);
          //       Pref.isDarkMode = !Pref.isDartMode;
          //       return;
          //     }
          //     Get.dialog(WatchAdDialog(
          //       onComplete: () {
          //         AdHelper.showRewardedAd(onComplete: () {
          //           Get.changeThemeMode(
          //               Pref.isDartMode ? ThemeMode.light : ThemeMode.dark);
          //           Pref.isDarkMode = !Pref.isDartMode;
          //         });
          //       },
          //     ));
          //   },
          //   icon: Icon(Icons.brightness_medium, size: 25, color: Colors.orange),
          // ),
          IconButton(
              padding: EdgeInsets.only(right: 8),
              onPressed: () => Get.to(() => NetworkTestScreen()),
              icon: Icon(
                CupertinoIcons.info,
                size: 25,
                color: const Color(0xFFFFFFFF),
              )),
        ],
      ),
      bottomNavigationBar: _changeLocation(context),
      body: Column(
        children: [
          Expanded(
            flex: 3, // 60% chiều cao cho nút VPN
            child: Center(child: Obx(() => _vpnButton(context))),
          ),
          Expanded(
            flex: 2, // 40% chiều cao cho HomeCard
            child: StreamBuilder<VpnStatus?>(
              initialData: VpnStatus(),
              stream: VpnEngine.vpnStatusSnapshot(),
              builder: (context, snapshot) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HomeCard(
                      title: '${snapshot.data?.byteIn ?? '---'}',
                      icon: CircleAvatar(
                        backgroundColor: Color(0xFF03C343),
                        radius: mq.width * 0.08, // Responsive radius
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          size: mq.width * 0.06,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                      subtitle: 'Download'.tr),
                  HomeCard(
                      title: '${snapshot.data?.byteOut ?? '---'}',
                      icon: CircleAvatar(
                        backgroundColor: Color(0xFF4684F6), // Màu xanh dương
                        radius: mq.width * 0.08,
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          size: mq.width * 0.06,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                      subtitle: 'Uploads'.tr),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nút VPN
  Widget _vpnButton(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final isRunning =
                _controller.vpnState.value == VpnEngine.vpnConnected ||
                    _controller.vpnState.value == VpnEngine.vpnConnecting;
            return Column(
              children: [
                if (_controller.vpnState.value == VpnEngine.vpnDisconnected)
                  Text(
                    'Disconnected'.tr,
                    style: TextStyle(
                      fontSize: mq.width * 0.08,
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (isRunning) CountDownTimer(startTimer: true),
              ],
            );
          }),
          SizedBox(height: mq.height * 0.01),
          Text(
            _controller.getButtonText,
            style: TextStyle(
                color: Color(0xFF03C343),
                fontSize:
                    12 // Màu nền xanh lá              fontSize: mq.width * 0.04,
                ),
          ),
          SizedBox(height: mq.height * 0.06),
          Center(
            child: GestureDetector(
              onTap: _controller.connectToVpn,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: mq.width < 160
                    ? mq.width * 0.9
                    : 148, // Giới hạn nếu màn hình nhỏ hơn 160
                height: mq.height < 100
                    ? mq.height * 0.8
                    : 80, // Giới hạn nếu màn hình thấp hơn 100
                decoration: BoxDecoration(
                  color: _controller.getButtonColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Align(
                  alignment: _controller.vpnState.value ==
                              VpnEngine.vpnConnected ||
                          _controller.vpnState.value == VpnEngine.vpnConnecting
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(mq.width * 0.015),
                    width: (mq.width < 160 ? mq.width * 0.9 : 148) *
                        0.46, // Tỷ lệ với width
                    height: (mq.width < 160 ? mq.width * 0.9 : 148) *
                        0.46, // Giữ hình tròn
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

  // Thanh chọn vị trí
  Widget _changeLocation(BuildContext context) => SafeArea(
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: () => Get.to(() => LocationScreen()),
            child: Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
                  color: Color(0xFF172032),
                  height: mq.height * 0.08, // 8% chiều cao màn hình
                  child: Row(
                    children: [
                      Expanded(
                        child: ChangeLocation(
                          title: _controller.vpn.value.CountryLong.isEmpty
                              ? 'Choose location'.tr
                              : _controller.vpn.value.CountryLong,
                          icon: CircleAvatar(
                            backgroundColor: Color(0xFF172032),
                            radius: mq.width * 0.06,
                            child: _controller.vpn.value.CountryLong.isEmpty
                                ? Icon(
                                    CupertinoIcons.globe,
                                    size: mq.width * 0.06,
                                    color: const Color(0xFFFFFFFF),
                                  )
                                : null,
                            backgroundImage: _controller
                                    .vpn.value.CountryLong.isEmpty
                                ? null
                                : AssetImage(
                                    'assets/flags/${_controller.vpn.value.CountryShort.toLowerCase()}.png'),
                          ),
                          ip: ipData.value.query,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Color(0xFF172032),
                        radius: mq.width * 0.05,
                        child: Icon(Icons.keyboard_arrow_right_rounded,
                            color: const Color(0xFFFFFFFF),
                            size: mq.width * 0.06),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      );
}
