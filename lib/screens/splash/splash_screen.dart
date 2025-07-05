import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/network_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/home/home_screen.dart';
import 'package:vpn_basic_project/screens/network_help/internet.dart';
import 'package:vpn_basic_project/screens/menu/lang/langguage_2.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOnNoInternetScreen = false; // thêm vào class để theo dõi trạng thái

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();

    final networkController = Get.find<NetworkController>();

    ever(networkController.hasInternet, (hasInternet) {
      if (!hasInternet) {
        if (!_isOnNoInternetScreen) {
          _isOnNoInternetScreen = true;
          Get.dialog(const NoInternetPopup(), barrierDismissible: false);
        }
      } else {
        if (_isOnNoInternetScreen) {
          _isOnNoInternetScreen = false;
          if (Get.isDialogOpen ?? false) {
            Get.back(); // Đóng popup
          }
          // ✅ Gọi lại hàm điều hướng sau khi có mạng
          _navigateAfterDelay();
        }
      }
    });

    // 👇 Kiểm tra lúc vừa mở app
    if (!networkController.hasInternet.value) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _isOnNoInternetScreen = true;
        Get.offAll(() => const NoInternetPopup());
      });
    } else {
      _navigateAfterDelay();
    }
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final networkController = Get.find<NetworkController>();
    if (!networkController.hasInternet.value) {
      // Nếu vẫn không có mạng, không điều hướng
      return;
    }

    try {
      AdHelper.precacheInterstitialAd();
      AdHelper.precacheNativeAd();
      AdHelper.precacheOpenAd();
      AdHelper.precacheBannerAd();

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      bool navigated = false;

      void navigate() {
        if (navigated) return;
        navigated = true;
        final nextPage =
            Pref.hasSeenOnboarding ? HomeScreen() : LanguageScreen2();
        Get.offAll(() => nextPage,
            transition: Transition.fade,
            duration: const Duration(milliseconds: 500));
      }

      if (Pref.isFirstLaunch) {
        Pref.isFirstLaunch = false;
        navigate();
      } else {
        AdHelper.showOpenAd(onComplete: navigate);
        await Future.delayed(const Duration(seconds: 4));
        navigate();
      }
    } catch (e) {
      print('Error in navigation: $e');
      Get.offAll(() => HomeScreen(),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500));
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
      backgroundColor: const Color(0xFF02091A),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo VPN.png',
                  width: 86,
                  height: 86,
                ),
                const SizedBox(height: 20),
                const Text(
                  'VPN Fast & Safe',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
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
                color: const Color(0xFF02091A),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      value: _animation.value,
                      backgroundColor: const Color(0xFF767C8A),
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
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
