import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/screens/home/home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final _adController5 = NativeAdController();

  @override
  Widget build(BuildContext context) {
    // Load Native Ad một lần duy nhất
    _adController5.ad = AdHelper.loadNativeAd2(adController: _adController5);

    return SafeArea(
      child: Scaffold(
        // Quảng cáo Native phía dưới
        bottomNavigationBar: Obx(() {
          if (_adController5.ad != null && _adController5.adLoaded.isTrue) {
            return SafeArea(
              child: SizedBox(
                height: 120,
                child: AdWidget(ad: _adController5.ad!),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),

        // Body
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Ảnh nền
                Image.asset(
                  'assets/images/BG (2).png',
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),

                // Nội dung giao diện
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.08),

                      // Tiêu đề SVG
                      SvgPicture.asset(
                        'assets/svg/Wellcome Free VPN Super.svg',
                        height: constraints.maxHeight * 0.1,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.04),

                      // Icon SVG trung tâm
                      SvgPicture.asset(
                        'assets/svg/lll.svg',
                        height: constraints.maxHeight * 0.18,
                      ),

                      const Spacer(),

                      // Nút START
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: _adController5.adLoaded.isTrue ? 160 : 40,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            AdHelper.showInterstitialAd(onComplete: () {
                              Get.offAll(() => HomeScreen(),
                                  transition: Transition.fade,
                                  duration: const Duration(milliseconds: 500));
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF15E24),
                            padding: EdgeInsets.symmetric(
                              horizontal: constraints.maxWidth * 0.4,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'START',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}