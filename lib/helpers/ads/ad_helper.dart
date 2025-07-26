import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/ads_controller/banner%20_ad_controller.dart';

import '../../controllers/ads_controller/native_ad_controller.dart';
import 'config_ads_firebase.dart';

/// Lớp hỗ trợ quản lý quảng cáo Google Mobile Ads tối ưu hóa
class AdHelper {
  // Queue system để tránh load quá nhiều ads cùng lúc
  static final List<Function> _loadQueue = [];
  static bool _isProcessingQueue = false;
  static Timer? _retryTimer;

  // Cache timing
  static const Duration _retryDelay = Duration(seconds: 30);
  static const Duration _maxLoadTimeout = Duration(seconds: 5);

  /// Khởi tạo SDK Google Mobile Ads với timeout
  static Future<void> initAds() async {
    try {
      await MobileAds.instance.initialize().timeout(_maxLoadTimeout);
      log('✅ Mobile Ads SDK initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize Mobile Ads SDK: $e');
    }
  }

  /// Xử lý queue loading ads
  static Future<void> _processLoadQueue() async {
    if (_isProcessingQueue || _loadQueue.isEmpty) return;

    _isProcessingQueue = true;

    while (_loadQueue.isNotEmpty) {
      final loadFunction = _loadQueue.removeAt(0);
      try {
        await loadFunction();
        // Delay giữa các lần load để tránh spam request
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        log('❌ Error in queue processing: $e');
      }
    }

    _isProcessingQueue = false;
  }

  /// Thêm vào queue thay vì load ngay lập tức
  static void _addToQueue(Function loadFunction) {
    _loadQueue.add(loadFunction);
    _processLoadQueue();
  }

  // Interstitial Ad
  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;
  static DateTime? _lastInterstitialFailTime;

  /// Precache Interstitial với retry logic
  static void precacheInterstitialAd() {
    if (Config.hideAds) return;

    // Tránh retry quá nhanh nếu vừa fail
    if (_lastInterstitialFailTime != null &&
        DateTime.now().difference(_lastInterstitialFailTime!) < _retryDelay) {
      log('⏳ Interstitial ad retry too soon, skipping...');
      return;
    }

    _addToQueue(() => _loadInterstitialAd());
  }

  static Future<void> _loadInterstitialAd() async {
    log('🔄 Loading Interstitial Ad - Id: ${Config.interstitialAd}');

    final completer = Completer<void>();

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _resetInterstitialAd();
              // Precache lại sau khi dismiss
              Future.delayed(
                  const Duration(seconds: 2), precacheInterstitialAd);
            },
            onAdShowedFullScreenContent: (ad) {
              log('✅ Interstitial ad showed');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('❌ Interstitial ad failed to show: $error');
              _resetInterstitialAd();
            },
          );
          _interstitialAd = ad;
          _interstitialAdLoaded = true;
          _lastInterstitialFailTime = null;
          log('✅ Interstitial ad loaded successfully');
          completer.complete();
        },
        onAdFailedToLoad: (err) {
          _resetInterstitialAd();
          _lastInterstitialFailTime = DateTime.now();
          log('❌ Failed to load interstitial ad: ${err.message}');

          // Retry sau một khoảng thời gian
          _scheduleRetryInterstitial();
          completer.complete();
        },
      ),
    );

    // Timeout protection
    Timer(_maxLoadTimeout, () {
      if (!completer.isCompleted) {
        log('⏰ Interstitial ad loading timeout');
        completer.complete();
      }
    });

    return completer.future;
  }

  static void _scheduleRetryInterstitial() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      if (!_interstitialAdLoaded) {
        log('🔄 Retrying interstitial ad load...');
        precacheInterstitialAd();
      }
    });
  }

  static void _resetInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialAdLoaded = false;
  }

  /// Show Interstitial với fallback
  static void showInterstitialAd({required VoidCallback onComplete}) {
    log('📱 Showing Interstitial Ad - Id: ${Config.interstitialAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    if (_interstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      onComplete();
      return;
    }

    // Nếu không có ad sẵn sàng, load và show ngay
    _loadAndShowInterstitialAd(onComplete);
  }

  static void _loadAndShowInterstitialAd(VoidCallback onComplete) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
    });

    final completer = Completer<void>();

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _resetInterstitialAd();
              onComplete();
              precacheInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('❌ Interstitial failed to show: $error');
              _resetInterstitialAd();
              onComplete();
            },
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.isDialogOpen ?? false) Get.back();
            ad.show();
          });

          completer.complete();
        },
        onAdFailedToLoad: (err) {
          log('❌ Interstitial failed to load: ${err.message}');
          if (Get.isDialogOpen ?? false) Get.back();
          _resetInterstitialAd();
          onComplete();
          completer.complete();
        },
      ),
    );

    Timer(_maxLoadTimeout, () {
      if (!completer.isCompleted) {
        if (Get.isDialogOpen ?? false) Get.back();
        log('⏰ Interstitial ad loading timeout');
        onComplete();
        completer.complete();
      }
    });
  }

  // Banner Ad với cải thiện
  static BannerAd? _bannerAd;
  static bool _bannerAdLoaded = false;
  static DateTime? _lastBannerFailTime;

  static void precacheBannerAd() {
    if (Config.hideAds) return;

    if (_lastBannerFailTime != null &&
        DateTime.now().difference(_lastBannerFailTime!) < _retryDelay) {
      return;
    }

    _addToQueue(() => _loadBannerAd());
  }

  static Future<void> _loadBannerAd() async {
    log('🔄 Loading Banner Ad - Id: ${Config.bannerAd}');

    _bannerAd = BannerAd(
      adUnitId: Config.bannerAd,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('✅ Banner ad loaded successfully');
          _bannerAdLoaded = true;
          _lastBannerFailTime = null;
        },
        onAdFailedToLoad: (ad, error) {
          disposeBannerAd();
          _lastBannerFailTime = DateTime.now();
          log('❌ Banner ad failed to load: $error');

          // Schedule retry
          Timer(_retryDelay, () {
            if (!_bannerAdLoaded) {
              precacheBannerAd();
            }
          });
        },
        onAdOpened: (ad) => log('Banner ad opened'),
        onAdClosed: (ad) => log('Banner ad closed'),
      ),
    );

    await _bannerAd?.load();
  }

  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerAdLoaded = false;
  }

  static BannerAd? loadBannerAd({required BannerAdController baController}) {
    log('📱 Loading Banner Ad for display - Id: ${Config.bannerAd}');

    if (Config.hideAds) return null;

    if (_bannerAdLoaded && _bannerAd != null) {
      baController.baLoaded.value = true;
      return _bannerAd;
    }

    // Fallback: tạo banner mới nếu chưa có
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Config.bannerAd,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('✅ Fallback banner ad loaded');
          baController.baLoaded.value = true;
          disposeBannerAd();
          precacheBannerAd();
        },
        onAdFailedToLoad: (ad, error) {
          disposeBannerAd();
          log('❌ Fallback banner ad failed to load: $error');
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();
    return bannerAd;
  }

  // Native Ad với Map quản lý tốt hơn
  static final Map<String, NativeAd?> _nativeAds = {};
  static final Map<String, bool> _nativeAdLoaded = {};
  static final Map<String, DateTime?> _lastNativeFailTime = {};

  static NativeTemplateStyle _getNativeTemplateStyle(
      TemplateType templateType) {
    return NativeTemplateStyle(
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
      templateType: templateType,
    );
  }

  static void _precacheNativeAd(String key, TemplateType templateType) {
    if (Config.hideAds) return;

    final lastFailTime = _lastNativeFailTime[key];
    if (lastFailTime != null &&
        DateTime.now().difference(lastFailTime) < _retryDelay) {
      return;
    }

    _addToQueue(() => _loadNativeAdInternal(key, templateType));
  }

  static Future<void> _loadNativeAdInternal(
      String key, TemplateType templateType) async {
    log('🔄 Loading Native Ad - Key: $key, Id: ${Config.nativeAd}');

    _nativeAds[key] = NativeAd(
      adUnitId: Config.nativeAd,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          log('✅ Native ad loaded for key: $key');
          _nativeAdLoaded[key] = true;
          _lastNativeFailTime[key] = null;
        },
        onAdFailedToLoad: (ad, error) {
          _resetNativeAd(key);
          _lastNativeFailTime[key] = DateTime.now();
          log('❌ Native ad failed to load for key $key: $error');

          // Schedule retry
          Timer(_retryDelay, () {
            if (_nativeAdLoaded[key] != true) {
              _precacheNativeAd(key, templateType);
            }
          });
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: _getNativeTemplateStyle(templateType),
    );

    await _nativeAds[key]?.load();
  }

  static void _resetNativeAd(String key) {
    _nativeAds[key]?.dispose();
    _nativeAds[key] = null;
    _nativeAdLoaded[key] = false;
  }

  // Public methods for Native Ads
  static void precacheNativeAd() =>
      _precacheNativeAd('native', TemplateType.small);
  static void precacheNativeAd1() =>
      _precacheNativeAd('native1', TemplateType.medium);
  static void precacheNativeAd2() =>
      _precacheNativeAd('native2', TemplateType.small);

  static NativeAd? loadNativeAd({required NativeAdController adController}) =>
      _loadNativeAdForDisplay('native', TemplateType.small, adController);

  static NativeAd? loadNativeAd1({required NativeAdController adController}) =>
      _loadNativeAdForDisplay('native1', TemplateType.medium, adController);

  static NativeAd? loadNativeAd2({required NativeAdController adController}) =>
      _loadNativeAdForDisplay('native2', TemplateType.small, adController);

  static NativeAd? _loadNativeAdForDisplay(
      String key, TemplateType templateType, NativeAdController adController) {
    log('📱 Loading Native Ad for display - Key: $key, Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    if (_nativeAdLoaded[key] == true && _nativeAds[key] != null) {
      adController.adLoaded.value = true;
      return _nativeAds[key];
    }

    // Fallback: tạo native ad mới nếu chưa có
    return NativeAd(
      adUnitId: Config.nativeAd,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          log('✅ Fallback native ad loaded for key: $key');
          adController.adLoaded.value = true;
          _resetNativeAd(key);
          _precacheNativeAd(key, templateType);
        },
        onAdFailedToLoad: (ad, error) {
          _resetNativeAd(key);
          log('❌ Fallback native ad failed to load for key $key: $error');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: _getNativeTemplateStyle(templateType),
    )..load();
  }

  // Rewarded Ad với timeout
  static void showRewardedAd({required VoidCallback onComplete}) {
    if (Config.hideAds) {
      onComplete();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
    });

    final completer = Completer<void>();

    RewardedAd.load(
      adUnitId: Config.rewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.isDialogOpen ?? false) Get.back();
            ad.show(
              onUserEarnedReward: (ad, rewardItem) {
                log('✅ User earned reward');
                onComplete();
              },
            );
          });
          completer.complete();
        },
        onAdFailedToLoad: (err) {
          if (Get.isDialogOpen ?? false) Get.back();
          log('❌ Failed to load rewarded ad: ${err.message}');
          onComplete();
          completer.complete();
        },
      ),
    );

    Timer(_maxLoadTimeout, () {
      if (!completer.isCompleted) {
        if (Get.isDialogOpen ?? false) Get.back();
        onComplete();
        completer.complete();
      }
    });
  }

  // App Open Ad
  static AppOpenAd? _appOpenAd;
  static bool _appOpenAdLoaded = false;
  static bool _isAppOpenAdShowing = false;
  static DateTime? _lastOpenAdFailTime;
  static DateTime? _lastOpenAdShowTime;

  // Tránh spam show open ad
  static const Duration _openAdCooldown = Duration(minutes: 5);

  /// Precache App Open Ad với retry logic
  static void precacheOpenAd() {
    if (Config.hideAds) return;

    // Tránh retry quá nhanh nếu vừa fail
    if (_lastOpenAdFailTime != null &&
        DateTime.now().difference(_lastOpenAdFailTime!) < _retryDelay) {
      log('⏳ Open ad retry too soon, skipping...');
      return;
    }

    _addToQueue(() => _loadOpenAd());
  }

  static Future<void> _loadOpenAd() async {
    log('🔄 Loading App Open Ad - Id: ${Config.openAd}');

    final completer = Completer<void>();

    AppOpenAd.load(
      adUnitId: Config.openAd,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _resetOpenAd();
              _lastOpenAdShowTime = DateTime.now();
              // Precache lại sau khi dismiss
              Future.delayed(const Duration(seconds: 2), precacheOpenAd);
            },
            onAdShowedFullScreenContent: (ad) {
              log('✅ Open ad showed');
              _isAppOpenAdShowing = true;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('❌ Open ad failed to show: $error');
              _resetOpenAd();
            },
          );
          _appOpenAd = ad;
          _appOpenAdLoaded = true;
          _lastOpenAdFailTime = null;
          log('✅ App Open ad loaded successfully');
          completer.complete();
        },
        onAdFailedToLoad: (err) {
          _resetOpenAd();
          _lastOpenAdFailTime = DateTime.now();
          log('❌ Failed to load open ad: ${err.message}');

          // Retry sau một khoảng thời gian
          _scheduleRetryOpenAd();
          completer.complete();
        },
      ),
    );

    // Timeout protection
    Timer(_maxLoadTimeout, () {
      if (!completer.isCompleted) {
        log('⏰ Open ad loading timeout');
        completer.complete();
      }
    });

    return completer.future;
  }

  static void _scheduleRetryOpenAd() {
    Timer(_retryDelay, () {
      if (!_appOpenAdLoaded) {
        log('🔄 Retrying open ad load...');
        precacheOpenAd();
      }
    });
  }

  static void _resetOpenAd() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _appOpenAdLoaded = false;
    _isAppOpenAdShowing = false;
  }

  /// Show App Open Ad với cooldown để tránh spam
  static void showOpenAd({required VoidCallback onComplete}) {
    log('📱 Showing App Open Ad - Id: ${Config.openAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    // Kiểm tra cooldown (tránh show quá thường xuyên)
    if (_lastOpenAdShowTime != null &&
        DateTime.now().difference(_lastOpenAdShowTime!) < _openAdCooldown) {
      log('⏳ Open ad cooldown active, skipping...');
      onComplete();
      return;
    }

    if (_appOpenAdLoaded && _appOpenAd != null && !_isAppOpenAdShowing) {
      _appOpenAd?.show();
      onComplete();
      return;
    }

    // Nếu không có ad sẵn sàng, load và show ngay
    _loadAndShowOpenAd(onComplete);
  }

  static void _loadAndShowOpenAd(VoidCallback onComplete) {
    // Show loading indicator
    if (!(Get.isDialogOpen ?? false)) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
    }

    final completer = Completer<void>();

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
            onAdShowedFullScreenContent: (ad) {
              _isAppOpenAdShowing = true;
              _lastOpenAdShowTime = DateTime.now();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('❌ Open ad failed to show: $error');
              _resetOpenAd();
            },
          );

          _appOpenAd = ad;
          _appOpenAdLoaded = true;

          if (Get.isDialogOpen ?? false) Get.back(); // Hide loading

          // ✅ Tránh ANR bằng cách gọi sau một frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              ad.show();
            } catch (e) {
              log('❌ Error showing open ad: $e');
              _resetOpenAd();
              onComplete();
            }
          });

          completer.complete();
        },
        onAdFailedToLoad: (err) {
          if (Get.isDialogOpen ?? false) Get.back(); // Hide loading
          log('❌ Failed to load open ad immediately: ${err.message}');
          onComplete();
          completer.complete();
        },
      ),
    );

    // Timeout protection
    Timer(_maxLoadTimeout, () {
      if (!completer.isCompleted) {
        if (Get.isDialogOpen ?? false) Get.back();
        onComplete();
        completer.complete();
      }
    });
  }

  /// Khởi tạo tất cả ads với thứ tự ưu tiên
  static Future<void> initAllAds() async {
    log('🚀 Initializing all ads with priority queue...');

    // Priority order: Open Ad -> Interstitial -> Banner -> Native ads
    Future.delayed(const Duration(seconds: 1), precacheOpenAd);
    Future.delayed(const Duration(seconds: 2), precacheInterstitialAd);
    Future.delayed(const Duration(seconds: 3), precacheBannerAd);
    Future.delayed(const Duration(seconds: 4), precacheNativeAd);
    Future.delayed(const Duration(seconds: 5), precacheNativeAd1);
    Future.delayed(const Duration(seconds: 6), precacheNativeAd2);
  }

  /// Dispose tất cả ads
  static void disposeAllAds() {
    log('🧹 Disposing all ads...');

    _retryTimer?.cancel();
    _resetInterstitialAd();
    _resetOpenAd();
    disposeBannerAd();

    for (String key in _nativeAds.keys.toList()) {
      _resetNativeAd(key);
    }

    _loadQueue.clear();
    _isProcessingQueue = false;
  }

  /// Kiểm tra trạng thái ads
  static Map<String, bool> getAdStatus() {
    return {
      'open': _appOpenAdLoaded,
      'interstitial': _interstitialAdLoaded,
      'banner': _bannerAdLoaded,
      'native': _nativeAdLoaded['native'] ?? false,
      'native1': _nativeAdLoaded['native1'] ?? false,
      'native2': _nativeAdLoaded['native2'] ?? false,
    };
  }

  /// Utility methods for App Open Ad
  static bool get isAppOpenAdReady => _appOpenAdLoaded && _appOpenAd != null;
  static bool get isAppOpenAdShowing => _isAppOpenAdShowing;

  /// Check if can show open ad (considering cooldown)
  static bool canShowOpenAd() {
    if (Config.hideAds ||
        !_appOpenAdLoaded ||
        _appOpenAd == null ||
        _isAppOpenAdShowing) {
      return false;
    }

    if (_lastOpenAdShowTime != null &&
        DateTime.now().difference(_lastOpenAdShowTime!) < _openAdCooldown) {
      return false;
    }

    return true;
  }
}
