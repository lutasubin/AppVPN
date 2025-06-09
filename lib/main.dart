import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/appVpn.dart';
import 'package:vpn_basic_project/helpers/AppLifecycleHandler.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/config.dart';
import 'package:vpn_basic_project/helpers/pref.dart';

// Biến toàn cục
late Size mq;

/// Hàm khởi tạo chính của ứng dụng.
/// Thiết lập các dịch vụ cần thiết trước khi chạy ứng dụng.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  WidgetsBinding.instance.addObserver(AppLifecycleHandler());

  // Khởi tạo kích thước màn hình (mq)
  mq = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;

  // Tải biến môi trường từ file .env
  await dotenv.load();

  // ✅ Khai báo thiết bị test
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['EMULATOR']),
  );

  // Thiết lập chế độ giao diện người dùng (edge-to-edge)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Khởi tạo Firebase, Config, Hive, và quảng cáo
  try {
    await Firebase.initializeApp();
    await Config.initConfig();
    await Pref.initializeHive();
    await AdHelper.initAds();
    // Ghi nhận sự kiện mở ứng dụng
    await AnalyticsHelper.logAppOpen();
  } catch (e) {
    debugPrint("Lỗi trong quá trình khởi tạo: $e");
  }
  // Thiết lập hướng thiết bị (chỉ hỗ trợ dọc)
  await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const App());
  });
}


