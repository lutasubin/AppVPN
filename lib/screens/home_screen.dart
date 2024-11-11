import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:vpn_basic_project/main.dart';
import 'package:vpn_basic_project/screens/how_to_connect_screen.dart';
import 'package:vpn_basic_project/screens/menu_screen.dart';
import 'package:vpn_basic_project/widgets/home_card.dart';

import '../models/vpn_config.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _vpnState = VpnEngine.vpnDisconnected;
  List<VpnConfig> _listVpn = [];
  VpnConfig? _selectedVpn;

  @override
  void initState() {
    super.initState();

    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      setState(() => _vpnState = event);
    });

    initVpn();
  }

  void initVpn() async {
    //sample vpn config file (you can get more from https://www.vpngate.net/)
    _listVpn.add(VpnConfig(
        config: await rootBundle.loadString('assets/vpn/japan.ovpn'),
        country: 'Japan',
        username: 'vpn',
        password: 'vpn'));

    _listVpn.add(VpnConfig(
        config: await rootBundle.loadString('assets/vpn/thailand.ovpn'),
        country: 'Thailand',
        username: 'vpn',
        password: 'vpn'));

    SchedulerBinding.instance.addPostFrameCallback(
        (t) => setState(() => _selectedVpn = _listVpn.first));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
          'FreeVpnVietNam',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.brightness_medium,
              size: 26,
              color: Colors.white,
            ),
          ),
          IconButton(
              padding: EdgeInsets.only(right: 8),
              onPressed: () {
                Get.off(() => HowToConnectScreen());
              },
              icon: Icon(
                CupertinoIcons.info,
                size: 27,
                color: Colors.white,
              ))
        ],
      ),
      bottomNavigationBar: _changeLocation(),
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: mq.height * .02,
          width: double.maxFinite,
        ),
        _vpnButton(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //country flag
            HomeCard(
                title: 'Country',
                icon: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 30,
                  child: Icon(
                    Icons.vpn_lock_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                subtitle: 'Free'),
            //ping time
            HomeCard(
                title: '100 ms',
                icon: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  radius: 30,
                  child: Icon(
                    Icons.equalizer_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                subtitle: 'Ping'),
          ],
        ),
        SizedBox(
          height: mq.height * .02,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //download
            HomeCard(
                title: '0 kbps',
                icon: CircleAvatar(
                  backgroundColor: Colors.lightGreen,
                  radius: 30,
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                subtitle: 'Download'),
            //upload
            HomeCard(
                title: '0 kbps',
                icon: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 15, 128, 220),
                  radius: 30,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                subtitle: 'Uploads'),
          ],
        )
      ]),
    );
  }

  void _connectClick() {
    ///Stop right here if user not select a vpn
    if (_selectedVpn == null) return;

    if (_vpnState == VpnEngine.vpnDisconnected) {
      ///Start if stage is disconnected
      VpnEngine.startVpn(_selectedVpn!);
    } else {
      ///Stop if stage is "not" disconnected
      VpnEngine.stopVpn();
    }
  }

  //vpn button
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(.1),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(.3),
                  ),
                  child: Container(
                      width: mq.height * .14,
                      height: mq.height * .14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
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
                            'Tap to Connect',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      )),
                ),
              ),
            ),
          ),
          //connection status label
          Container(
            margin:
                EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .05),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(15)),
            child: Text(
              'Not connected',
              style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          )
        ],
      );

  Widget _changeLocation() => SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
          color: Colors.blue,
          height: 60,
          child: Row(
            children: [
              Icon(
                CupertinoIcons.globe,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Change Location',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              Spacer(),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: Colors.blue,
                  size: 28,
                ),
              )
            ],
          ),
        ),
      );
}
