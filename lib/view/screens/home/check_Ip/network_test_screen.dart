import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:vpn_basic_project/controllers/ads_controller/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import '../../../../main.dart';
import '../../../../models/ip_details.dart';
import '../../../../models/network_data.dart';
import '../../../widgets/NetworkWidgets/network_card.dart';
import '../../../../apis/vpn_gate.dart';

class NetworkTestScreen extends StatelessWidget {
  final _adController4 = NativeAdController();
  final ipData = IPDetails.fromJson({}).obs;

  NetworkTestScreen({super.key}) {
    // ✅ Gọi API chỉ 1 lần khi khởi tạo
    Apis.getIPDetails(ipData: ipData);
    _adController4.ad = AdHelper.loadNativeAd1(adController: _adController4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
        ),
        title: Text(
          'IP Information'.tr,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final ad = _adController4.ad;
        if (ad != null &&
            _adController4.adLoaded.isTrue &&
            !_adController4.isDisposed) {
          return SafeArea(
            child: SizedBox(
              height: 350,
              child: AdWidget(ad: ad),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: Obx(() => ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
                left: mq.width * .04,
                right: mq.width * .04,
                top: mq.height * .01,
                bottom: mq.height * .1),
            children: [
              //ip
              NetworkCard(
                  data: NetworkData(
                      title: 'IP Address',
                      subtitle: ipData.value.query,
                      icon: Icon(CupertinoIcons.location_solid,
                          color: Colors.blue))),

              //isp
              NetworkCard(
                  data: NetworkData(
                      title: 'Internet Provider',
                      subtitle: ipData.value.isp,
                      icon: Icon(Icons.business, color: Colors.orange))),

              //location
              NetworkCard(
                  data: NetworkData(
                      title: 'Location',
                      subtitle: ipData.value.country.isEmpty
                          ? 'Fetching ...'
                          : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                      icon: Icon(CupertinoIcons.location, color: Colors.pink))),

              //pin code
              NetworkCard(
                  data: NetworkData(
                      title: 'Pin-code',
                      subtitle: ipData.value.zip,
                      icon: Icon(CupertinoIcons.location_solid,
                          color: Colors.cyan))),

              //timezone
              NetworkCard(
                  data: NetworkData(
                      title: 'Timezone',
                      subtitle: ipData.value.timezone,
                      icon: Icon(CupertinoIcons.time, color: Colors.green))),
            ],
          )),
    );
  }

  // Widget tái sử dụng card hiển thị
}
