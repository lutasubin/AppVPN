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

  static NativeAd? _nativeAd;
  static bool _nativeAdLoaded = false;

  static NativeAd? _nativeAd1;
  static bool _nativeAdLoaded1 = false;

  static NativeAd? _nativeAd2;
  static bool _nativeAdLoaded2 = false;

  static NativeAd? _native1Ad;
  static bool _native1AdLoaded = false;

  static NativeAd? _native2Ad;
  static bool _native2AdLoaded = false;

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
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
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
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
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
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
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
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
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
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
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
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
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

  /// Tải trước quảng cáo tự nhiên để sử dụng sau này.
  /// Quảng cáo sẽ được định dạng theo kiểu mẫu nhỏ (small template).
  static void precacheNativeAdNew() {
    log('Precache Native Ad 1- Id: ${Config.native1Ad}');

    if (Config.hideAds) return;

    _native1Ad = NativeAd(
        adUnitId: Config.native1Ad,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            _native1AdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAdNew();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.small))
      ..load();
  }

  /// Đặt lại trạng thái quảng cáo tự nhiên về ban đầu.
  /// Xóa quảng cáo hiện tại và đánh dấu là chưa tải.
  static void _resetNativeAdNew() {
    _native1Ad?.dispose();
    _native1Ad = null;
    _native1AdLoaded = false;
  }

  /// Tải và trả về một quảng cáo tự nhiên.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAdNew({required NativeAdController adController}) {
    log('Native Ad Id 2: ${Config.native1Ad}');

    if (Config.hideAds) return null;

    if (_native1AdLoaded && _native1Ad != null) {
      adController.adLoaded.value = true;
      return _native1Ad;
    }

    return NativeAd(
        adUnitId: Config.native1Ad,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value = true;
            _resetNativeAdNew();
            precacheNativeAdNew();
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAdNew();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.small))
      ..load();
  }

  //*****************Native Ad New 2******************

  /// Tải trước quảng cáo tự nhiên để sử dụng sau này.
  /// Quảng cáo sẽ được định dạng theo kiểu mẫu nhỏ (small template).
  static void precacheNativeAdNew2() {
    log('Precache Native Ad 2 - Id: ${Config.native2Ad}');

    if (Config.hideAds) return;

    _native2Ad = NativeAd(
        adUnitId: Config.native2Ad,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            _native2AdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAdNew2();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.small))
      ..load();
  }

  /// Đặt lại trạng thái quảng cáo tự nhiên về ban đầu.
  /// Xóa quảng cáo hiện tại và đánh dấu là chưa tải.
  static void _resetNativeAdNew2() {
    _native2Ad?.dispose();
    _native2Ad = null;
    _native2AdLoaded = false;
  }

  /// Tải và trả về một quảng cáo tự nhiên.
  /// [adController] dùng để theo dõi trạng thái tải quảng cáo.
  /// Trả về null nếu quảng cáo bị ẩn hoặc tải thất bại.
  static NativeAd? loadNativeAdNew2(
      {required NativeAdController adController}) {
    log('Native Ad Id: ${Config.native1Ad}');

    if (Config.hideAds) return null;

    if (_native2AdLoaded && _native2Ad != null) {
      adController.adLoaded.value = true;
      return _native2Ad;
    }

    return NativeAd(
        adUnitId: Config.native1Ad,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value = true;
            _resetNativeAdNew2();
            precacheNativeAdNew2();
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAdNew2();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            mainBackgroundColor: const Color(0xFFFFFFFF),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
            ),
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFFF15E24),
              style: NativeTemplateFontStyle.bold,
              size: 15,
            ),
            templateType: TemplateType.small))
      ..load();
  }
}
