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
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Gắn observer để xử lý lifecycle nếu cần
  WidgetsBinding.instance.addObserver(AppLifecycleHandler());

  // ignore: deprecated_member_use
  mq = WidgetsBinding.instance.window.physicalSize /
      // ignore: deprecated_member_use
      WidgetsBinding.instance.window.devicePixelRatio;

  await dotenv.load();
  await Firebase.initializeApp();
  await Config.initConfig();
  await Pref.initializeHive();
  await AdHelper.initAds();
  await AnalyticsHelper.logAppOpen();

  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['EMULATOR']),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const App());
}
