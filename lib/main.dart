import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/appVpn.dart';
import 'package:vpn_basic_project/helpers/ads/init_ads.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/ads/config_ads_firebase.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';

// Biến toàn cục
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Tính toán kích thước màn hình
  mq = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size;

  try {
    // Khởi tạo dotenv
    await dotenv.load();
    log('✅ Dotenv initialized');

    // Khởi tạo Firebase
    await Firebase.initializeApp();
    log('✅ Firebase initialized');

    // Khởi tạo cấu hình
    await Config.initConfig();
    log('✅ Config initialized');

    // Khởi tạo Hive
    await Pref.initializeHive();
    log('✅ Hive initialized');

    // Khởi tạo quảng cáo với lifecycle
    await AdHelperLifecycle.init();
    log('✅ AdHelperLifecycle initialized');

    // Ghi log sự kiện mở ứng dụng
    await AnalyticsHelper.logAppOpen();
    log('✅ App open event logged');

    // Cấu hình Google Mobile Ads
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['EMULATOR']),
    );
    log('✅ Mobile Ads configured');
  } catch (e, stackTrace) {
    log('❌ Error during initialization: $e', stackTrace: stackTrace);
  }

  // Thiết lập orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const App());
}

