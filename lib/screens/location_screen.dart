import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:vpn_basic_project/controllers/location_controller.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/main.dart';
import 'package:vpn_basic_project/screens/search_screen.dart';
import 'package:vpn_basic_project/widgets/vpn_cart.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final LocationController _controller = Get.put(LocationController());

  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: Pref.isDartMode ? null : Colors.orange,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            'VPN Locations(${_controller.vpnList.length})',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => SearchScreen());
              },
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
        bottomNavigationBar:

            // Config.hideAds ? null:
            _adController.ad != null && _adController.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 85, child: AdWidget(ad: _adController.ad!)))
                : null,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () {
              _controller.getVpnData();
            },
            child: Icon(
              CupertinoIcons.refresh,
              color: Colors.white,
            ),
          ),
        ),
        body: _controller.isLoading.value
            ? _loadingWidget(context)
            : _controller.vpnList.isEmpty
                ? _noVPNFound(context)
                : _vpnData(),
      ),
    );
  }

  _vpnData() => ListView.builder(
        itemCount: _controller.vpnList.length,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
            top: mq.height * .015,
            bottom: mq.height * .1,
            left: mq.width * .04,
            right: mq.width * .04),
        itemBuilder: (ctx, i) => VpnCart(
          vpn: _controller.vpnList[i],
        ),
      );

  Widget _loadingWidget(BuildContext context) => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/lottie/loading.json',
              // 'assets/lottie/loadingVPN.json',
              width: 200,
            ),
            Text(
              'Loading VPNs...😄',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).lightText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget _noVPNFound(BuildContext context) => Center(
        child: Text(
          'VPNs Not Found...😶',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
