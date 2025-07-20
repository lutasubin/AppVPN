import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/banner%20_ad_controller.dart';

import '../controllers/native_ad_controller.dart';
import 'config.dart';

/// Lớp hỗ trợ quản lý quảng cáo Google Mobile Ads trong ứng dụng Flutter.
/// Cung cấp các phương thức để khởi tạo, tải và hiển thị các loại quảng cáo khác nhau.
class AdHelper {
  /// Khởi tạo SDK Google Mobile Ads.
  /// Cần gọi hàm này trước khi sử dụng bất kỳ loại quảng cáo nào.
  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }

  // Interstitial Ad
  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;

  // Banner Ad
  static BannerAd? _bannerAd;
  static bool _bannerAdLoaded = false;

  // Native Ads
  static final Map<String, NativeAd?> _nativeAds = {
    'native': null,
    'native1': null,
    'native2': null,
  };
  static final Map<String, bool> _nativeAdLoaded = {
    'native': false,
    'native1': false,
    'native2': false,
  };

  // App Open Ad
  static AppOpenAd? _appOpenAd;
  static bool _isAppOpenAdShowing = false;

  // Common native ad template style
  static NativeTemplateStyle _getNativeTemplateStyle(TemplateType templateType) {
    return NativeTemplateStyle(
      mainBackgroundColor: const Color(0xFFFFFFFF),
      primaryTextStyle:  NativeTemplateTextStyle(
        textColor: Colors.black,
        style: NativeTemplateFontStyle.normal,
      ),
      secondaryTextStyle:  NativeTemplateTextStyle(
        textColor: Colors.grey,
        style: NativeTemplateFontStyle.normal,
      ),
      callToActionTextStyle:  NativeTemplateTextStyle(
        textColor: Color(0xFFFFFFFF),
        backgroundColor: Color(0xFFF15E24),
        style: NativeTemplateFontStyle.bold,
        size: 15,
      ),
      templateType: templateType,
    );
  }

  //*****************Interstitial Ad******************

  /// Tải trước quảng cáo toàn màn hình để sẵn sàng hiển thị khi cần.
  static void precacheInterstitialAd() {
    log('Precache Interstitial Ad - Id: ${Config.interstitialAd}');

    if (Config.hideAds) return;

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _resetInterstitialAd();
              precacheInterstitialAd();
            },
          );
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
  static void _resetInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialAdLoaded = false;
  }

  /// Hiển thị quảng cáo toàn màn hình.
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

    _loadAndShowInterstitialAd(onComplete);
  }

  /// Tải và hiển thị quảng cáo toàn màn hình ngay lập tức.
  static void _loadAndShowInterstitialAd(VoidCallback onComplete) {
    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              onComplete();
              _resetInterstitialAd();
              precacheInterstitialAd();
            },
          );
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

  /// Tải trước quảng cáo tự nhiên với key và template type chỉ định.
  static void _precacheNativeAd(String key, TemplateType templateType) {
    log('Precache Native Ad - Key: $key, Id: ${Config.nativeAd}');

    if (Config.hideAds) return;

    _nativeAds[key] = NativeAd(
      adUnitId: Config.nativeAd,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          log('$NativeAd loaded for key: $key');
          _nativeAdLoaded[key] = true;
        },
        onAdFailedToLoad: (ad, error) {
          _resetNativeAd(key);
          log('$NativeAd failed to load for key $key: $error');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: _getNativeTemplateStyle(templateType),
    )..load();
  }

  /// Đặt lại trạng thái quảng cáo tự nhiên về ban đầu.
  static void _resetNativeAd(String key) {
    _nativeAds[key]?.dispose();
    _nativeAds[key] = null;
    _nativeAdLoaded[key] = false;
  }

  /// Tải và trả về một quảng cáo tự nhiên.
  static NativeAd? _loadNativeAd(String key, TemplateType templateType, NativeAdController adController) {
    log('Native Ad Id: ${Config.nativeAd}, Key: $key');

    if (Config.hideAds) return null;

    if (_nativeAdLoaded[key] == true && _nativeAds[key] != null) {
      adController.adLoaded.value = true;
      return _nativeAds[key];
    }

    return NativeAd(
      adUnitId: Config.nativeAd,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          log('$NativeAd loaded for key: $key');
          adController.adLoaded.value = true;
          _resetNativeAd(key);
          _precacheNativeAd(key, templateType);
        },
        onAdFailedToLoad: (ad, error) {
          _resetNativeAd(key);
          log('$NativeAd failed to load for key $key: $error');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: _getNativeTemplateStyle(templateType),
    )..load();
  }

  // Public methods for Native Ads
  static void precacheNativeAd() => _precacheNativeAd('native', TemplateType.small);
  static void precacheNativeAd1() => _precacheNativeAd('native1', TemplateType.medium);
  static void precacheNativeAd2() => _precacheNativeAd('native2', TemplateType.small);

  static NativeAd? loadNativeAd({required NativeAdController adController}) =>
      _loadNativeAd('native', TemplateType.small, adController);

  static NativeAd? loadNativeAd1({required NativeAdController adController}) =>
      _loadNativeAd('native1', TemplateType.medium, adController);

  static NativeAd? loadNativeAd2({required NativeAdController adController}) =>
      _loadNativeAd('native2', TemplateType.small, adController);

  //*****************Rewarded Ad******************

  /// Hiển thị quảng cáo có thưởng.
  static void showRewardedAd({required VoidCallback onComplete}) {
    log('Rewarded Ad Id: ${Config.rewardedAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    RewardedAd.load(
      adUnitId: Config.rewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Get.back();
          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
              onComplete();
            },
          );
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
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
    log('Banner Ad Id: ${Config.bannerAd}');

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
      request: const AdRequest(),
    )..load();
  }

  //***************** App Open Ad ******************

  /// Tải trước App Open Ad để sẵn sàng hiển thị khi cần.
  static void precacheOpenAd() {
    log('Precache Open Ad - Id: ${Config.openAd}');

    if (Config.hideAds) return;

    AppOpenAd.load(
      adUnitId: Config.openAd,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _resetOpenAd();
              precacheOpenAd();
            },
          );
          _appOpenAd = ad;
          _isAppOpenAdShowing = true;
        },
        onAdFailedToLoad: (err) {
          _resetOpenAd();
          log('Failed to load an open ad: ${err.message}');
        },
      ),
    );
  }

  /// Đặt lại trạng thái App Open Ad về ban đầu.
  static void _resetOpenAd() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAppOpenAdShowing = false;
  }

  /// Hiển thị App Open Ad.
  static void showOpenAd({required VoidCallback onComplete}) {
    log('Open Ad Id: ${Config.openAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    if (_isAppOpenAdShowing && _appOpenAd != null) {
      _appOpenAd?.show();
      onComplete();
      return;
    }

    _loadAndShowOpenAd(onComplete);
  }

  /// Tải và hiển thị App Open Ad ngay lập tức.
  static void _loadAndShowOpenAd(VoidCallback onComplete) {
    AppOpenAd.load(
      adUnitId: Config.openAd,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              onComplete();
              _resetOpenAd();
              precacheOpenAd();
            },
          );
          Get.back();
          ad.show();
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load an open ad: ${err.message}');
          onComplete();
        },
      ),
    );
  }

  /// Dispose tất cả các quảng cáo khi không còn sử dụng.
  static void disposeAllAds() {
    _resetInterstitialAd();
    disposeBannerAd();
    _resetOpenAd();
    
    for (String key in _nativeAds.keys) {
      _resetNativeAd(key);
    }
  }
}