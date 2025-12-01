import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:vpn_basic_project/appVpn.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/remote_config/config_firebase.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';

late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  await _initializeCoreServices();

  // Khóa màn hình theo chiều dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Chạy ứng dụng
  runApp(const App());
}

/// Khởi tạo tất cả dịch vụ cốt lõi (không bao gồm PlatformView như Ads)
Future<void> _initializeCoreServices() async {
  try {
    
    await Firebase.initializeApp();
    log('✅ Firebase initialized');

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await Config.initConfig();
    log('✅ Config initialized');

    await Pref.initializeHive();
    log('✅ Hive initialized');

    await AnalyticsHelper.logAppOpen();
    log('✅ App open event logged');

    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['EMULATOR']),
    );
    log('✅ Mobile Ads configured');
  } catch (e, stackTrace) {
    await FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
    log('❌ Error during initialization: $e', stackTrace: stackTrace);
  }
}
