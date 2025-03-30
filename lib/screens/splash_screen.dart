import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/home_screen.dart';
import 'package:vpn_basic_project/screens/langguage_2.dart'; // Thêm import này

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

      AdHelper.precacheInterstitialAd();
      AdHelper.precacheNativeAd();

      final savedLanguage = Pref.selectedLanguage;
      if (savedLanguage.isNotEmpty) {
        Get.updateLocale(Locale(savedLanguage));
      }

      if (isFirstLaunch) {
        await prefs.setBool('isFirstLaunch', false);
        AdHelper.showInterstitialAd(onComplete: () {
          Get.offAll(() => LanguageScreen2(),
              transition: Transition.fade,
              duration: Duration(milliseconds: 500));
        });
      } else {
        AdHelper.showInterstitialAd(onComplete: () {
          Get.offAll(() => HomeScreen(),
              transition: Transition.fade,
              duration: Duration(milliseconds: 500));
        });
      }
    } catch (e) {
      print('Error in navigation: $e');
      Get.offAll(() => HomeScreen(),
          transition: Transition.fade, duration: Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF02091A), // Mã màu mới,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo VPN.png', // Thay đổi đường dẫn tới file SVG của bạn
                  width: 86,
                  height: 86,
                ),
                const SizedBox(height: 20),
                const Text(
                  'VPN Fast & Safe',
                  style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Color(0xFF02091A), // Mã màu mới
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      value: _animation.value,
                      backgroundColor: Color(0xFF767C8A),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFF15E24),
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This action can contain ads',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
