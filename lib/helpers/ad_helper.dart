import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';

class AdHelper {
  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }

  // static InterstitialAd? _interstitialAd;
  // static bool _interstitialAdLoaded = false;

  // static NativeAd? _nativeAd;
  // static bool _nativeAdLoaded = false;
  
  static void showInterstitialAd({required VoidCallback onComplete}) {
    MyDialogs.showProgress();

    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              onComplete();
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

  /// Loads a native ad.
  static NativeAd loadNativeAd({required NativeAdController adController}) {
    return NativeAd(
        adUnitId: 'ca-app-pub-3940256099942544/2247696110',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            log('$NativeAd failed to load: $error');
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
          // Required: Choose a template.
          templateType: TemplateType.small,
        ))
      ..load();
  }
}
