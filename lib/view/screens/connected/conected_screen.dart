import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vpn_basic_project/controllers/ads_controller/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/models/local_vpn.dart';

class ConnectedScreen extends StatelessWidget {
  final LocalVpnServer server;
  final _adController7 = NativeAdController();

  ConnectedScreen({
    super.key,
    required this.server,
  });

  @override
  Widget build(BuildContext context) {
    _adController7.ad = AdHelper.loadNativeAd1(adController: _adController7);

    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
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
        title: Text(
          'connection_report'.tr,
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF02091A),
        elevation: 0,
      ),
      bottomNavigationBar: Obx(() {
        final ad = _adController7.ad;
        if (ad != null &&
            _adController7.adLoaded.isTrue &&
            !_adController7.isDisposed) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thẻ thông tin kết nối
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.1),
                        width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/flags/${server.countryCode.toLowerCase()}.png',
                        width: 50,
                        height: 30,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            SvgPicture.asset(
                          'assets/svg/earth.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        server.countryName,
                        style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        server.ip,
                        style: TextStyle(
                            color: Color(0xFF767C8A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'CONNECTED'.tr,
                        style: TextStyle(
                            color: const Color(0xFF0CD09C),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Đánh giá ứng dụng
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.1),
                        width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Rate us'.tr,
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'rate_message'.tr,
                        style:
                            TextStyle(color: Color(0xFF767C8A), fontSize: 14),
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
