import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/view/screens/home/home_screen.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double verticalGap =
        screenSize.height * 0.14; // khoảng cách linh hoạt giữa 2 hình
    final double buttonHeight =
        screenSize.height * 0.06; // chiều cao nút theo màn hình

    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BG (2).png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/lll.svg',
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: verticalGap),
                              SvgPicture.asset(
                                'assets/svg/Wellcome Free VPN Super.svg',
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF15E24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        AdHelper.showInterstitialAd(onComplete: (){
                          Get.off(() =>  HomeScreen(),
                            transition: Transition.fade,
                            duration: const Duration(milliseconds: 300));
                        });
                      },
                      child: const Text(
                        'START',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: // Native card like mock (medium layout)
          const NativeAdWithLoadingWidget(adType: 'medium'),
    );
  }
}
