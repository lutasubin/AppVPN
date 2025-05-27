import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/dependency_injection.dart';
import 'package:vpn_basic_project/helpers/AppLifecycleHandler.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/app_translations.dart';
import 'package:vpn_basic_project/helpers/config.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/splash_screen.dart';

// Biến toàn cục
late Size mq;

/// Hàm khởi tạo chính của ứng dụng.
/// Thiết lập các dịch vụ cần thiết trước khi chạy ứng dụng.
Future<void> main() async {
  // debugPaintSizeEnabled = true; // Hiển thị viền widget để debug

  // Khởi tạo Dependency Injection
  await DependencyInjection.init();

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
    runApp(const MyApp());
  });
}

/// Lớp chính của ứng dụng.
/// Cấu hình GetMaterialApp với theme, locale và màn hình khởi đầu.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI VPN Fast Safe',
      home: const SplashScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF02091A),
      ),
      themeMode: ThemeMode.dark,
      locale: Locale(Pref.selectedLanguage.isEmpty
          ? Get.deviceLocale?.languageCode ?? 'en'
          : Pref.selectedLanguage),
      fallbackLocale: const Locale('en'),
      translations: AppTranslations(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
      navigatorObservers: [AnalyticsHelper.observer],
    );
  }
}
