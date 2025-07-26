import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';

class AdHelperLifecycle {
  static final _AdHelperObserver _observer = _AdHelperObserver();

  static Future<void> init() async {
    try {
      // Đăng ký observer
      WidgetsBinding.instance.addObserver(_observer);
      log('✅ AdHelperLifecycle observer registered');

      // Khởi tạo quảng cáo với timeout
      await AdHelper.initAds().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          log('⏰ Timeout initializing Mobile Ads SDK');
        },
      );
      await AdHelper.initAllAds().timeout(
        const Duration(seconds: 30), // Timeout dài hơn vì initAllAds tải nhiều quảng cáo
        onTimeout: () {
          log('⏰ Timeout initializing all ads');
        },
      );
      log('✅ AdHelperLifecycle initialized');
    } catch (e, stackTrace) {
      log('❌ Error initializing AdHelperLifecycle: $e', stackTrace: stackTrace);
    }
  }

  static void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    AdHelper.disposeAllAds();
    log('🧹 AdHelperLifecycle disposed');
  }
}

class _AdHelperObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        log('🧹 App paused or detached, disposing all ads');
        AdHelper.disposeAllAds();
        break;
      case AppLifecycleState.resumed:
        log('🚀 App resumed, reinitializing ads');
        AdHelper.initAllAds();
        break;
      default:
        break;
    }
  }
}