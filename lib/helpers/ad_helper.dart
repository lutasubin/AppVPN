import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/banner%20_ad_controller.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';

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

  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;

  static BannerAd? _bannerAd;
  static bool _bannerAdLoaded = false;

  static NativeAd? _nativeAd;
  static bool _nativeAdLoaded = false;

  static NativeAd? _nativeAd1;
  static bool _nativeAdLoaded1 = false;

  static NativeAd? _nativeAd2;
  static bool _nativeAdLoaded2 = false;

  static AppOpenAd? _appOpenAd;
  static bool _isAppOpenAdShowing = false;

  //*****************Interstitial Ad******************

  /// Tải trước quảng cáo toàn màn hình để sẵn sàng hiển thị khi cần.
  /// Quảng cáo sẽ tự động tải lại sau khi được hiển thị hoặc thất bại.
  static void precacheInterstitialAd() {
    log('Precache Interstitial Ad - Id: ${Config.interstitialAd}');

    if (Config.hideAds) return;

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: AdRequest(),
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
      request: AdRequest(),
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

  /// Tải trước quảng cáo tự nhiên để sử dụng sau này.
  /// Quảng cáo sẽ được định dạng theo kiểu mẫu nhỏ (small template).
  static void precacheNativeAd() {
    log('Precache Native Ad - Id: ${Config.nativeAd}');

    if (Config.hideAds) return;

    _nativeAd = NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            _nativeAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Color(0xFFFFFFFF),
              backgroundColor: Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.small))
      ..load();
  }

  /// Đặt lại trạng thái quảng cáo tự nhiên về ban đầu.
  /// Xóa quảng cáo hiện tại và đánh dấu là chưa tải.
  static void _resetNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _nativeAdLoaded = false;
  }

  /// Tải và trả về một quảng cáo tự nhiên.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAd({required NativeAdController adController}) {
    log('Native Ad Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    if (_nativeAdLoaded && _nativeAd != null) {
      adController.adLoaded.value = true;
      return _nativeAd;
    }

    return NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value = true;
            _resetNativeAd();
            precacheNativeAd();
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Color(0xFFFFFFFF),
              backgroundColor: Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.small))
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
      request: AdRequest(),
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

  /// Tải trước quảng cáo tự nhiên để sử dụng sau này.
  /// Quảng cáo sẽ được định dạng theo kiểu mẫu nhỏ (small template).
  static void precacheNativeAd1() {
    log('Precache Native Ad - Id: ${Config.nativeAd}');

    if (Config.hideAds) return;

    _nativeAd1 = NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            _nativeAdLoaded1 = true;
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd1();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Color(0xFFFFFFFF),
              backgroundColor: Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.medium))
      ..load();
  }

  /// Đặt lại trạng thái quảng cáo tự nhiên về ban đầu.
  /// Xóa quảng cáo hiện tại và đánh dấu là chưa tải.
  static void _resetNativeAd1() {
    _nativeAd1?.dispose();
    _nativeAd1 = null;
    _nativeAdLoaded1 = false;
  }

  /// Tải và trả về một quảng cáo tự nhiên.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAd1({required NativeAdController adController}) {
    log('Native Ad Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    if (_nativeAdLoaded1 && _nativeAd1 != null) {
      adController.adLoaded.value = true;
      return _nativeAd1;
    }

    return NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value = true;
            _resetNativeAd1();
            precacheNativeAd1();
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd1();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Color(0xFFFFFFFF),
              backgroundColor: Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.medium))
      ..load();
  }

  //*****************Native Ad2******************

  /// Tải trước quảng cáo tự nhiên để sử dụng sau này.
  /// Quảng cáo sẽ được định dạng theo kiểu mẫu nhỏ (small template).
  static void precacheNativeAd2() {
    log('Precache Native Ad - Id: ${Config.nativeAd}');

    if (Config.hideAds) return;

    _nativeAd2 = NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            _nativeAdLoaded2 = true;
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd2();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Color(0xFFFFFFFF),
              backgroundColor: Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.small))
      ..load();
  }

  /// Đặt lại trạng thái quảng cáo tự nhiên về ban đầu.
  /// Xóa quảng cáo hiện tại và đánh dấu là chưa tải.
  static void _resetNativeAd2() {
    _nativeAd2?.dispose();
    _nativeAd2 = null;
    _nativeAdLoaded2 = false;
  }

  /// Tải và trả về một quảng cáo tự nhiên.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAd2({required NativeAdController adController}) {
    log('Native Ad Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    if (_nativeAdLoaded2 && _nativeAd2 != null) {
      adController.adLoaded.value = true;
      return _nativeAd2;
    }

    return NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value = true;
            _resetNativeAd2();
            precacheNativeAd2();
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd2();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Color(0xFFFFFFFF),
              backgroundColor: Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.small))
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
      request: AdRequest(),
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
        request: AdRequest())
      ..load();
  }


  
   //***************** App Open Ad ******************
  /// Tải trước quảng cáo toàn màn hình để sẵn sàng hiển thị khi cần.
  /// Quảng cáo sẽ tự động tải lại sau khi được hiển thị hoặc thất bại.
  static void precacheOpenAd() {
    log('Precache Open Ad - Id: ${Config.openAd}');

    if (Config.hideAds) return;

    AppOpenAd.load(
      adUnitId: Config.openAd,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          // Lắng nghe sự kiện khi quảng cáo được hiển thị hoặc đóng
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            _resetOpenAd();
            precacheOpenAd();
          });
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

  /// Đặt lại trạng thái quảng cáo toàn màn hình về ban đầu.
  /// Xóa quảng cáo hiện tại và đánh dấu là chưa tải.
  static void _resetOpenAd() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAppOpenAdShowing = false;
  }

  /// Hiển thị quảng cáo toàn màn hình.
  /// Nếu quảng cáo chưa sẵn sàng, sẽ tải và hiển thị ngay khi hoàn tất.
  /// [onComplete] được gọi sau khi quảng cáo hiển thị hoặc thất bại.
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

    MyDialogs.showProgress();

    AppOpenAd.load(
      adUnitId: Config.openAd,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            onComplete();
            _resetOpenAd();
            precacheOpenAd();
          });
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
}