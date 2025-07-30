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
import '../../../../apis/apis.dart';

class NetworkTestScreen extends StatelessWidget {
  final _adController4 = NativeAdController();
  final ipData = IPDetails.fromJson({}).obs;

  NetworkTestScreen({super.key}) {
    // ✅ Gọi API chỉ 1 lần khi khởi tạo
    Apis.getIPDetails(ipData: ipData);
    _adController4.ad = AdHelper.loadNativeAd2(adController: _adController4);
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
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final ad = _adController4.ad;
        if (ad != null &&
            _adController4.adLoaded.isTrue &&
            !_adController4.isDisposed) {
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
      body: Obx(() => ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: mq.width * 0.04,
              vertical: mq.height * 0.01,
            ),
            children: [
              _buildNetworkCard(
                title: 'IP Address'.tr,
                value: ipData.value.query,
                icon: const Icon(CupertinoIcons.location_solid, color: Colors.blue),
              ),
              _buildNetworkCard(
                title: 'Internet Provider'.tr,
                value: ipData.value.isp,
                icon: const Icon(Icons.business, color: Colors.orange),
              ),
              _buildNetworkCard(
                title: 'Location'.tr,
                value: ipData.value.country.isEmpty
                    ? 'Fetching...'.tr
                    : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                icon: const Icon(CupertinoIcons.location, color: Colors.pink),
              ),
              _buildNetworkCard(
                title: 'Pin-code'.tr,
                value: ipData.value.zip,
                icon: const Icon(CupertinoIcons.location_solid, color: Colors.cyan),
              ),
              _buildNetworkCard(
                title: 'Timezone'.tr,
                value: ipData.value.timezone,
                icon: const Icon(CupertinoIcons.time, color: Colors.green),
              ),
            ],
          )),
    );
  }

  // Widget tái sử dụng card hiển thị
  Widget _buildNetworkCard({required String title, required String? value, required Icon icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NetworkCard(
        data: NetworkData(
          title: title,
          subtitle: value ?? 'N/A',
          icon: icon,
        ),
      ),
    );
  }
}
