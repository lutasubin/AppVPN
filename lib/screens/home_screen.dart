// import 'dart:developer';

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/home_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/config.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/main.dart';

import 'package:vpn_basic_project/models/vpn_status.dart';

import 'package:vpn_basic_project/screens/location_screen.dart';
import 'package:vpn_basic_project/screens/menu_screen.dart';
import 'package:vpn_basic_project/screens/network_test_screen.dart';
import 'package:vpn_basic_project/screens/watch_ad_dialog.dart';
import 'package:vpn_basic_project/widgets/count_down_time%20.dart';
import 'package:vpn_basic_project/widgets/home_card.dart';

// import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';

class HomeScreen extends StatelessWidget {
  // final Vpn selectedVpn;
  HomeScreen({
    super.key,
  });
  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pref.isDartMode ? null : Colors.orange,
        leading: IconButton(
          onPressed: () {
            Get.to(() => MenuScreen());
          },
          icon: Icon(
            Icons.menu,
            size: 25,
            color: Colors.white,
          ),
        ),
        title: Text(
          'OpenVPN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (Config.hideAds) {
                Get.changeThemeMode(
                    Pref.isDartMode ? ThemeMode.light : ThemeMode.dark);
                Pref.isDarkMode = !Pref.isDartMode;
                return;
              }
              Get.dialog(WatchAdDialog(
                onComplete: () {
                  AdHelper.showRewardedAd(onComplete: () {
                    Get.changeThemeMode(
                        Pref.isDartMode ? ThemeMode.light : ThemeMode.dark);
                    Pref.isDarkMode = !Pref.isDartMode;
                  });
                },
              ));
            },
            icon: Icon(
              Icons.brightness_medium,
              size: 25,
              color: Colors.white,
            ),
          ),
          IconButton(
              padding: EdgeInsets.only(right: 8),
              onPressed: () {
                Get.to(() => NetworkTestScreen());
              },
              icon: Icon(
                CupertinoIcons.info,
                size: 25,
                color: Colors.white,
              ))
        ],
      ),
      bottomNavigationBar: _changeLocation(context),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        //vpn button
        Obx(() => _vpnButton()),

        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //country flag
              HomeCard(
                  title: _controller.vpn.value.CountryLong.isEmpty
                      ? 'Country'
                      : _controller.vpn.value.CountryLong,
                  icon: CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 30,
                    child: _controller.vpn.value.CountryLong.isEmpty
                        ? Icon(
                            Icons.vpn_lock_rounded,
                            size: 25,
                            color: Colors.white,
                          )
                        : null,
                    backgroundImage: _controller.vpn.value.CountryLong.isEmpty
                        ? null
                        : AssetImage(
                            'assets/flags/${_controller.vpn.value.CountryShort.toLowerCase()}.png'),
                  ),
                  subtitle: 'Free'),
              //ping time
              HomeCard(
                  title: _controller.vpn.value.Ping.isEmpty
                      ? '100 ms'
                      : '${_controller.vpn.value.Ping} ms',
                  icon: CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    radius: 30,
                    child: Icon(
                      Icons.equalizer_rounded,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: 'Ping'),
            ],
          ),
        ),

        StreamBuilder<VpnStatus?>(
            initialData: VpnStatus(),
            stream: VpnEngine.vpnStatusSnapshot(),
            builder: (context, snapshot) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //download
                    HomeCard(
                        title: '${snapshot.data?.byteIn ?? '0 kbps'}',
                        icon: CircleAvatar(
                          backgroundColor: Colors.lightGreen,
                          radius: 30,
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: 'Download'),
                    //upload
                    HomeCard(
                        title: '${snapshot.data?.byteOut ?? '0 kbps'}',
                        icon: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 15, 128, 220),
                          radius: 30,
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: 'Uploads'),
                  ],
                ))
      ]),
    );
  }

  Widget _vpnButton() => Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Hình nền Trái Đất
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/earth.png'), // Đường dẫn đến hình ảnh Trái Đất
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Nút
              Semantics(
                button: true,
                child: InkWell(
                  onTap: () {
                    _controller.connectToVpn();
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.1),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor.withOpacity(.3),
                      ),
                      child: Container(
                        width: mq.height * .14,
                        height: mq.height * .14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _controller.getButtonColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.power_settings_new,
                              size: 28,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              _controller.getButtonText,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Trạng thái kết nối
          Container(
            margin:
                EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .02),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(15)),
            child: Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', '').toLowerCase(),
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
          // Đếm ngược
          Obx(() => CountDownTimer(
              startTimer:
                  _controller.vpnState.value == VpnEngine.vpnConnected)),
        ],
      );

  Widget _changeLocation(BuildContext context) => SafeArea(
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: () {
              Get.to(() => LocationScreen());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
              color: Theme.of(context).bottomNav,
              height: 60,
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.globe,
                    color: Colors.white,
                    size: 25,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    'Change Location',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.orange,
                      size: 25,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
