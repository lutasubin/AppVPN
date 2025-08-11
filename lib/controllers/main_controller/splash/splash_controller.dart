import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/main_controller/network/network_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';
import 'package:vpn_basic_project/view/screens/home/home_screen.dart';
import 'package:vpn_basic_project/view/screens/network_help/internet.dart';
import 'package:vpn_basic_project/view/screens/menu/lang/langguage_2.dart';

class SplashController extends GetxController {
  // Navigation state
  bool _hasNavigated = false;
  final RxBool isOnNoInternetScreen = false.obs;
  
  // Network controller
  late NetworkController networkController;
  
  @override
  void onInit() {
    super.onInit();
    _resetState();
    _initializeApp();
    _setupNetworkListener();
  }

  void _resetState() {
    // Reset state khi controller được tái sử dụng
    _hasNavigated = false;
    isOnNoInternetScreen.value = false;
  }

  void _initializeApp() {
    // Preload ads sau 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      _precacheAds();
    });

    // Setup network controller
    networkController = Get.find<NetworkController>();
    
    // Check internet connection sau khi widget build xong
    Future.delayed(const Duration(milliseconds: 100), () {
      _checkInitialConnection();
    });
  }

  void _precacheAds() {
    AdHelper.precacheOpenAd();
    AdHelper.precacheInterstitialAd();
    AdHelper.precacheNativeAd();
    AdHelper.precacheNativeAdNew();
    AdHelper.precacheNativeAdNew2();
    AdHelper.precacheBannerAd();
  }

  void _setupNetworkListener() {
    ever(networkController.hasInternet, (hasInternet) {
      if (!hasInternet && !isOnNoInternetScreen.value) {
        _showNoInternetDialog();
      } else if (hasInternet && isOnNoInternetScreen.value) {
        _hideNoInternetDialog();
        _scheduleNavigation();
      }
    });
  }

  void _checkInitialConnection() {
    if (!networkController.hasInternet.value) {
      _showNoInternetDialog();
    } else {
      _scheduleNavigation();
    }
  }

  void _showNoInternetDialog() {
    isOnNoInternetScreen.value = true;
    Get.dialog(const NoInternetPopup(), barrierDismissible: false);
  }

  void _hideNoInternetDialog() {
    isOnNoInternetScreen.value = false;
    if (Get.isDialogOpen ?? false) Get.back();
  }

  Future<void> _scheduleNavigation() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    // Chờ 3s cho animation splash
    await Future.delayed(const Duration(seconds: 3));
    
    // Set system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Xác định trang tiếp theo
    final nextPage = Pref.hasSeenOnboarding ? HomeScreen() : LanguageScreen2();

    void navigate() {
      if (!_hasNavigated) return;
      Get.offAll(
        () => nextPage,
        transition: Transition.fade,
        duration: const Duration(milliseconds: 500),
      );
    }

    try {
      if (Pref.isFirstLaunch) {
        // Lần đầu mở app, không hiện ads
        Pref.isFirstLaunch = false;
        navigate();
      } else {
        // Chờ App Open Ad sẵn sàng (tối đa 3s)
        await _waitForAppOpenAd();
        
        if (AdHelper.isAppOpenAdAvailable) {
          AdHelper.showOpenAd(onComplete: navigate);
        } else {
          navigate();
        }
      }
    } catch (e) {
      print('Error in navigation: $e');
      // Fallback navigation
      Get.offAll(
        () => HomeScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  Future<void> _waitForAppOpenAd() async {
    int retry = 0;
    while (!AdHelper.isAppOpenAdAvailable && retry < 15) {
      await Future.delayed(const Duration(milliseconds: 200));
      retry++;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}