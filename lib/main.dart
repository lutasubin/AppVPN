import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // 🔥 Crashlytics
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/appVpn.dart';
import 'package:vpn_basic_project/helpers/AppLifecycleHandler.dart';
import 'package:vpn_basic_project/helpers/ads/init_ads.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/ads/config_ads_firebase.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';

late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Đăng ký observer sớm
  final AppLifecycleHandler lifecycleHandler = AppLifecycleHandler();
  WidgetsBinding.instance.addObserver(lifecycleHandler);

  try {
    // Tính toán kích thước màn hình
    mq = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size;

    // Khởi tạo dotenv
    await dotenv.load();
    log('✅ Dotenv initialized');

    // Khởi tạo Firebase
    await Firebase.initializeApp();
    log('✅ Firebase initialized');

    // 🔥 Thiết lập bắt lỗi Flutter sau khi Firebase đã được khởi tạo
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // 🔥 Thiết lập bắt lỗi isolate nền
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Khởi tạo cấu hình tùy chỉnh
    await Config.initConfig();
    log('✅ Config initialized');

    // Khởi tạo Hive (local storage)
    await Pref.initializeHive();
    log('✅ Hive initialized');

    // Khởi tạo quảng cáo với lifecycle
    await AdHelperLifecycle.init();
    log('✅ AdHelperLifecycle initialized');

    // Ghi log sự kiện mở ứng dụng lên Firebase Analytics
    await AnalyticsHelper.logAppOpen();
    log('✅ App open event logged');

    // Cấu hình Google Mobile Ads
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['EMULATOR']),
    );
    log('✅ Mobile Ads configured');

  } catch (e, stackTrace) {
    // 🔥 Ghi log lỗi khởi tạo bằng Crashlytics
    await FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
    log('❌ Error during initialization: $e', stackTrace: stackTrace);
  }

  // Thiết lập chỉ xoay màn hình dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Khởi chạy ứng dụng
  runApp(const App());
}
