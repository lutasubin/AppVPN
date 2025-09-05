import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

class DisconnectedScreen extends StatelessWidget {
  final String country;

  final String connectionTime;
  final String uploadSpeed;
  final String downloadSpeed;
  final String flagUrl;

  const DisconnectedScreen({
    super.key,
    required this.country,
    required this.connectionTime,
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.flagUrl,
  });

  @override
  Widget build(BuildContext context) {
    final LocalController controller = Get.find<LocalController>();

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
            AdHelper.showInterstitialAd(onComplete: () {
              Get.back();
            });
          },
        ),
        title: Text(
          'connection_report'.tr,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF02091A),
        elevation: 0,
      ),
      bottomNavigationBar: const NativeAdWithLoadingWidget(adType: 'medium'),

      body: SingleChildScrollView(
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
                    Row(
                      children: [
                        Image.asset(
                          flagUrl,
                          width: 50,
                          height: 30,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              SvgPicture.asset(
                            'assets/svg/earth.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          country,
                          style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'disconnect'.tr,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('time'.tr,
                            style: const TextStyle(
                                color: Color(0xFF767C8A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(
                          connectionTime,
                          style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('upload_speed'.tr,
                            style: const TextStyle(
                                color: Color(0xFF767C8A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(
                          uploadSpeed,
                          style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('download_speed'.tr,
                            style: const TextStyle(
                                color: Color(0xFF767C8A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(downloadSpeed,
                            style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF15E24),
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: () {
                        controller.connectToVpn();
                        Get.back();
                      },
                      child: Text('connection_again'.tr,
                          style: const TextStyle(
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
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'rate_message'.tr,
                      style: const TextStyle(
                          color: Color(0xFF767C8A), fontSize: 14),
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
