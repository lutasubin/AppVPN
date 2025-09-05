import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/ads_controller/banner%20_ad_controller.dart';
import 'package:vpn_basic_project/controllers/ads_controller/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/remote_config/config_firebase.dart';
import 'package:vpn_basic_project/helpers/dilogs/my_dilogs.dart';

/// Lớp hỗ trợ quản lý quảng cáo Google Mobile Ads trong ứng dụng Flutter.
/// Cung cấp các phương thức để khởi tạo, tải và hiển thị các loại quảng cáo khác nhau.
class AdHelper {
  /// Khởi tạo SDK Google Mobile Ads.
  /// Cần gọi hàm này trước khi sử dụng bất kỳ loại quảng cáo nào.
  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }

  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;

  static BannerAd? _bannerAd;
  static bool _bannerAdLoaded = false;

  // Xóa tất cả static native ad variables để tránh chia sẻ ad objects

  //*****************Interstitial Ad******************

  /// Tải trước quảng cáo toàn màn hình để sẵn sàng hiển thị khi cần.
  /// Quảng cáo sẽ tự động tải lại sau khi được hiển thị hoặc thất bại.
  static void precacheInterstitialAd() {
    log('Precache Interstitial Ad - Id: ${Config.interstitialAd}');

    if (Config.hideAds) return;

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // Lắng nghe sự kiện khi quảng cáo được hiển thị hoặc đóng
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            _resetInterstitialAd();
            precacheInterstitialAd();
          });
          _interstitialAd = ad;
          _interstitialAdLoaded = true;
        },
        onAdFailedToLoad: (err) {
          _resetInterstitialAd();
          log('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  /// Đặt lại trạng thái quảng cáo toàn màn hình về ban đầu.
  /// Xóa quảng cáo hiện tại và đánh dấu là chưa tải.
  static void _resetInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialAdLoaded = false;
  }

  /// Hiển thị quảng cáo toàn màn hình.
  /// Nếu quảng cáo chưa sẵn sàng, sẽ tải và hiển thị ngay khi hoàn tất.
  /// [onComplete] được gọi sau khi quảng cáo hiển thị hoặc thất bại.
  static void showInterstitialAd({required VoidCallback onComplete}) {
    log('Interstitial Ad Id: ${Config.interstitialAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    if (_interstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      onComplete();
      return;
    }

    MyDialogs.showProgress();

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            onComplete();
            _resetInterstitialAd();
            precacheInterstitialAd();
          });
          Get.back();
          ad.show();
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load an interstitial ad: ${err.message}');
          onComplete();
        },
      ),
    );
  }

  //*****************Native Ad******************

  // Xóa precacheNativeAd và _resetNativeAd - không cần thiết nữa

  /// Tải và trả về một quảng cáo tự nhiên.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAd({required NativeAdController adController}) {
    log('Native Ad Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    // Luôn tạo ad mới thay vì chia sẻ static ad
    return NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            log('$NativeAd failed to load: $error');
            adController.adLoaded.value = false;
          },
        ),
        request: const AdRequest(),
        factoryId: 'customNativeAd')
      ..load();
  }

  //*****************Rewarded Ad******************

  /// Hiển thị quảng cáo có thưởng.
  /// [onComplete] được gọi khi người dùng nhận được phần thưởng.
  static void showRewardedAd({required VoidCallback onComplete}) {
    log('Rewarded Ad Id: ${Config.rewardedAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    MyDialogs.showProgress();

    RewardedAd.load(
      adUnitId: Config.rewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Get.back();
          ad.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            onComplete();
          });
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load an interstitial ad: ${err.message}');
          // onComplete();
        },
      ),
    );
  }

  //*****************Native Ad1******************

  /// Tải và trả về một quảng cáo tự nhiên medium.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAd1({required NativeAdController adController}) {
    log('Native Ad Medium Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    // Luôn tạo ad mới thay vì chia sẻ static ad
    return NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd Medium loaded.');
            adController.adLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            log('$NativeAd Medium failed to load: $error');
            adController.adLoaded.value = false;
          },
        ),
        request: const AdRequest(),
        factoryId: 'customNativeAdMedium') // Sử dụng medium factory
      ..load();
  }

  //*****************Native Ad2******************

  /// Tải và trả về một quảng cáo tự nhiên.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAd2({required NativeAdController adController}) {
    log('Native Ad2 Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    // Luôn tạo ad mới thay vì chia sẻ static ad
    return NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('Native Ad2 loaded.');
            adController.adLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            log('Native Ad2 failed to load: $error');
            adController.adLoaded.value = false;
          },
        ),
        request: const AdRequest(),
        factoryId: 'customNativeAd')
      ..load();
  }

  //*****************Banner Ad******************
  /// Tải trước Banner Ad để sẵn sàng hiển thị.
  static void precacheBannerAd() {
    log('Precache Banner Ad - Id: ${Config.bannerAd}');

    if (Config.hideAds) return;

    _bannerAd = BannerAd(
      adUnitId: Config.bannerAd,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('$BannerAd loaded.');
          _bannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          disposeBannerAd();
          log('$BannerAd failed to load: $error');
        },
      ),
    )..load();
  }

  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerAdLoaded = false;
  }

  static BannerAd? loadBannerAd({required BannerAdController baController}) {
    log('Banner Ad Id : ${Config.bannerAd}');

    if (Config.hideAds) return null;

    if (_bannerAdLoaded && _bannerAd != null) {
      baController.baLoaded.value = true;
      return _bannerAd;
    }
    return BannerAd(
        size: AdSize.banner,
        adUnitId: Config.bannerAd,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            log('$BannerAd loaded.');
            baController.baLoaded.value = true;
            disposeBannerAd();
            precacheBannerAd();
          },
          onAdFailedToLoad: (ad, error) {
            disposeBannerAd();
            log('$BannerAd failed to load: $error');
          },
        ),
        request: const AdRequest())
      ..load();
  }
  //*****************App Open Ad******************

  static AppOpenAd? _appOpenAd;
  static bool _isOpenAdAvailable = false;
  // Thêm vào dưới phần AppOpenAd
  static bool get isAppOpenAdAvailable =>
      _isOpenAdAvailable && _appOpenAd != null;

  /// Tải quảng cáo App Open (quảng cáo khi mở app)
  static void precacheOpenAd() {
    if (Config.hideAds) {
      print('[AppOpenAd] Ads hidden by config. Skipping load.');
      return;
    }

    final openAdUnitId = Config.openAd;
    if (openAdUnitId.isEmpty) {
      print('[AppOpenAd] Error: openAd ID is empty!');
      return;
    }

    print('[AppOpenAd] Loading App Open Ad with ID: $openAdUnitId');

    AppOpenAd.load(
      adUnitId: openAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isOpenAdAvailable = true;
          print('[AppOpenAd] ✅ App Open Ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _isOpenAdAvailable = false;
          print('[AppOpenAd] ❌ Failed to load: ${error.message}');
        },
      ),
      // orientation: AppOpenAd.orientationPortrait, // ❌ This param was removed from newer SDK versions
    );
  }

  static void showOpenAd({required VoidCallback onComplete}) {
    if (Config.hideAds) {
      print('[AppOpenAd] Ads hidden. Skipping show.');
      onComplete();
      return;
    }

    if (_isOpenAdAvailable && _appOpenAd != null) {
      print('[AppOpenAd] ✅ Showing App Open Ad');
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('[AppOpenAd] Ad dismissed');
          _appOpenAd = null;
          _isOpenAdAvailable = false;
          precacheOpenAd();
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('[AppOpenAd] ❌ Failed to show: ${error.message}');
          _appOpenAd = null;
          _isOpenAdAvailable = false;
          precacheOpenAd();
          onComplete();
        },
      );
      _appOpenAd!.show();
    } else {
      print('[AppOpenAd] ❗ Ad not ready yet. Calling onComplete().');
      precacheOpenAd();
      onComplete();
    }
  }

  //*****************Native Ad New 1******************

  /// Tải và trả về một quảng cáo tự nhiên New 1.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAdNew({required NativeAdController adController}) {
    log('Native Ad New 1 Id: ${Config.native1Ad}');

    if (Config.hideAds) return null;

    // Luôn tạo ad mới thay vì chia sẻ static ad
    return NativeAd(
        adUnitId: Config.native1Ad,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('Native Ad New 1 loaded.');
            adController.adLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            log('Native Ad New 1 failed to load: $error');
            adController.adLoaded.value = false;
          },
        ),
        request: const AdRequest(),
        factoryId: 'customNativeAd')
      ..load();
  }

  //*****************Native Ad New 2******************

  /// Tải và trả về một quảng cáo tự nhiên New 2.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAdNew2(
      {required NativeAdController adController}) {
    log('Native Ad New 2 Id: ${Config.native2Ad}');

    if (Config.hideAds) return null;

    // Luôn tạo ad mới thay vì chia sẻ static ad
    return NativeAd(
        adUnitId: Config.native2Ad,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('Native Ad New 2 loaded.');
            adController.adLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            log('Native Ad New 2 failed to load: $error');
            adController.adLoaded.value = false;
          },
        ),
        request: const AdRequest(),
        factoryId: 'customNativeAd')
      ..load();
  }
}
