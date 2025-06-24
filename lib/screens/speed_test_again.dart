import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/controllers/speed_test_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';

class SpeedTestAgain extends StatelessWidget {
  SpeedTestAgain({super.key});

  final _adController5 = NativeAdController();

  @override
  Widget build(BuildContext context) {
    _adController5.ad = AdHelper.loadNativeAd1(adController: _adController5);
    final SpeedTestController controller = Get.find();
    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        automaticallyImplyLeading: false,
        title: const Text(
          'Speed Test Info',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            controller.resetValues();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (_adController5.ad != null && _adController5.adLoaded.isTrue) {
          return SafeArea(
            child:
                SizedBox(height: 350, child: AdWidget(ad: _adController5.ad!)),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(controller),
          ],
        ),
      ),
    );
  }

  // Info Card Widget
  Widget _buildInfoCard(SpeedTestController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoColum('assets/svg/ip.svg', 'IP Address'.tr,
              controller.ip.value ?? '__'),
          const SizedBox(height: 15),
          _buildInfoColum('assets/svg/net.svg', 'Internet Provider'.tr,
              controller.isp.value ?? '__'),
          const SizedBox(height: 15),
          _buildInfoColum('assets/svg/location.svg', 'Location'.tr,
              controller.country.value ?? '__'),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSpeedColumn(Icons.arrow_downward_rounded, 'Download'.tr,
                  controller.downloadRate.value.toStringAsFixed(2)),
              _buildSpeedColumn(Icons.arrow_upward_rounded, 'Uploads'.tr,
                  controller.uploadRate.value.toStringAsFixed(2)),
            ],
          )
        ],
      ),
    );
  }

  // Info Colum
  Widget _buildInfoColum(String svgAsset, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                svgAsset,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value.isEmpty ? '__' : value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  // Download/Upload Column
  Widget _buildSpeedColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon,
                color: icon == Icons.arrow_downward_rounded
                    ? const Color(0xFF03C343)
                    : const Color(0xFF4684F6)),
            const SizedBox(width: 6),
            Text(
              '$label Mbps',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
