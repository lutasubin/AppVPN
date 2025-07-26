import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/main_controller/network_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';
import 'package:vpn_basic_project/view/screens/home/home_screen.dart';
import 'package:vpn_basic_project/view/screens/network_help/internet.dart';
import 'package:vpn_basic_project/view/screens/menu/lang/langguage_2.dart';
import 'package:vpn_basic_project/view/screens/splash/welcome/welcome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _textFade;
  late final Animation<double> _textScale;

  bool _hasNavigated = false;
  bool _isOnNoInternetScreen = false;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoController.forward();

    // Text animation: fade + scale
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _textController.forward();
    });

    final networkController = Get.find<NetworkController>();

    ever(networkController.hasInternet, (hasInternet) {
      if (!hasInternet && !_isOnNoInternetScreen) {
        _isOnNoInternetScreen = true;
        Get.dialog(const NoInternetPopup(), barrierDismissible: false);
      } else if (hasInternet && _isOnNoInternetScreen) {
        _isOnNoInternetScreen = false;
        if (Get.isDialogOpen ?? false) Get.back();
        _scheduleNavigation();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!networkController.hasInternet.value) {
        _isOnNoInternetScreen = true;
        Get.dialog(const NoInternetPopup(), barrierDismissible: false);
      } else {
        _scheduleNavigation();
      }
    });
  }

  void _scheduleNavigation() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    await Future.delayed(const Duration(seconds: 3));

    try {
      AdHelper.precacheOpenAd();
      AdHelper.precacheInterstitialAd();
      AdHelper.precacheNativeAd();
      AdHelper.precacheBannerAd();

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      final nextPage =
          Pref.hasSeenOnboarding ? WelcomeScreen() : LanguageScreen2();

      void navigate() {
        if (!_hasNavigated) return;
        Get.offAll(() => nextPage,
            transition: Transition.fade,
            duration: const Duration(milliseconds: 500));
      }

      if (Pref.isFirstLaunch) {
        Pref.isFirstLaunch = false;
        navigate();
      } else {
        Future.delayed(const Duration(seconds: 3), () {
          if (Get.currentRoute == '/') navigate();
        });

        AdHelper.showOpenAd(onComplete: navigate);
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
    _logoController.dispose();
    _textController.dispose();
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
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Image.asset(
                    'assets/images/Logo VPN.png',
                    width: 86,
                    height: 86,
                  ),
                ),
                const SizedBox(height: 20),
                ScaleTransition(
                  scale: _textScale,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: const Text(
                      'VPN Fast & Safe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  children: [
                    const LinearProgressIndicator(
                      backgroundColor: Color(0xFF767C8A),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFF15E24),
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This action can contain ads',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
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
