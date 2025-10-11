import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/apis/vpn_gate.dart';
import 'package:vpn_basic_project/controllers/main_controller/speed/speed_test_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

class SpeedTestAgain extends StatelessWidget {
  SpeedTestAgain({super.key});

  final ipData = IPDetails.fromJson({}).obs; // ✅ Đặt bên ngoài build()

  @override
  Widget build(BuildContext context) {
    final SpeedTestController controller = Get.find();

    // ✅ Lấy IP khi build lần đầu
    APIs.getIPDetails(ipData: ipData);

    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        automaticallyImplyLeading: false,
        title: Text(
          'test3'.tr, // "Speed Test Information"
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            AdHelper.showInterstitialAd(onComplete: () async {
              controller.resetValues();
              Get.back();
            });
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
        ),
      ),
      bottomNavigationBar:
          const SafeArea(child: NativeAdWithLoadingWidget(adType: 'medium')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => _buildInfoCard(controller)), // ✅ Obx tự cập nhật IP
          ],
        ),
      ),
    );
  }

  // ✅ Info Card Widget
  Widget _buildInfoCard(SpeedTestController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoColum(
              'assets/svg/ip.svg', 'IP Address'.tr, ipData.value.query),
          const SizedBox(height: 15),
          _buildInfoColum(
              'assets/svg/net.svg', 'Internet Provider'.tr, ipData.value.isp),
          const SizedBox(height: 15),
          _buildInfoColum(
            'assets/svg/location.svg',
            'Location'.tr,
            '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
          ),
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

  // ✅ Info Column
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
            value,
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

  // ✅ Download/Upload Column
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
