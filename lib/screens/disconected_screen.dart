import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import '../controllers/local_controller.dart';

class DisconnectedScreen extends StatelessWidget {
  final String country;
  final String ip;
  final String connectionTime;
  final String uploadSpeed;
  final String downloadSpeed;
  final String flagUrl;
  final _adController5 = NativeAdController();

  DisconnectedScreen({
    super.key,
    required this.country,
    required this.ip,
    required this.connectionTime,
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.flagUrl,
  });

  @override
  Widget build(BuildContext context) {
    _adController5.ad = AdHelper.loadNativeAd1(adController: _adController5);
    final LocalController controller = Get.find<LocalController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFFFFFF),
            size: 25,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          "Connection report",
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF0F111A),
        elevation: 0,
      ),
      bottomNavigationBar: Obx(() {
        //! boc lai obx
        return _adController5.ad != null && _adController5.adLoaded.isTrue
            ? SafeArea(
                child: SizedBox(
                  height: 350,
                  child: AdWidget(ad: _adController5.ad!),
                ),
              )
            : const SizedBox.shrink(); // Hoặc `null`, tùy vào bạn
      }),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ thông tin kết nối
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B1E2E),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        flagUrl,
                        width: 40,
                        height: 30,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, color: Colors.red),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        country,
                        style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ip,
                    style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time',
                          style: TextStyle(
                              color: Color(0xFF767C8A), fontSize: 16)),
                      Text(
                        connectionTime,
                        style: const TextStyle(
                            color: Color(0xFFFFFFFF), fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Upload',
                          style: TextStyle(
                              color: Color(0xFF767C8A), fontSize: 16)),
                      Text(
                        uploadSpeed,
                        style: const TextStyle(
                            color: Color(0xFFFFFFFF), fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Download',
                          style: TextStyle(
                              color: Color(0xFF767C8A), fontSize: 16)),
                      Text(downloadSpeed,
                          style: const TextStyle(
                              color: Color(0xFFFFFFFF), fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF15E24),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () {
                      controller.connectToVpn();
                      Get.back();
                    },
                    child: const Text('Connection again',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Đánh giá ứng dụng
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B1E2E),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Rate us',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'If you feel satisfied,please rate 5 stars so we can continue to strive to bring you the best experience',
                    style: TextStyle(color: Color(0xFF767C8A), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: const Icon(
                          Icons.star_border,
                          color: Color(0xFFF15E24),
                        ),
                        onPressed: () {
                          _launchPlayStore();
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPlayStore() async {
    final Uri uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.Lutasubin.freeVpn'); // thay bằng package ID của bạn

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Không thể mở đường dẫn đánh giá');
    }
  }
}
