import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/app_translations.dart';
import 'package:vpn_basic_project/helpers/config.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/splash_screen.dart';

// Biến toàn cục
late Size mq;
late SharedPreferences prefs;

/// Hàm khởi tạo chính của ứng dụng.
/// Thiết lập các dịch vụ cần thiết trước khi chạy ứng dụng.
Future<void> main() async {
  // debugPaintSizeEnabled = true; // Hiển thị viền widget để debug

  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo kích thước màn hình (mq)
  mq = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;

  // Tải biến môi trường từ file .env
  await dotenv.load();

  // Khởi tạo SharedPreferences
  prefs = await SharedPreferences.getInstance();
  // Đặt cờ lần đầu tiên nếu chưa có
  await prefs.setBool('isFirstLaunch', prefs.getBool('isFirstLaunch') ?? true);

  // Thiết lập chế độ giao diện người dùng (edge-to-edge)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Khởi tạo Firebase, Config, Hive, và quảng cáo
  try {
    await Firebase.initializeApp();
    await Config.initConfig();
    await Pref.initializeHive();
    await AdHelper.initAds();
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
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OpenVpn Demo',
      home: SplashScreen(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 3,
        ),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 3,
        ),
      ),
      // Thêm hỗ trợ đa ngôn ngữ
      locale: Locale(Pref.selectedLanguage.isEmpty
          ? Get.deviceLocale?.languageCode ?? 'en'
          : Pref.selectedLanguage),
      fallbackLocale: const Locale('en'), // Ngôn ngữ dự phòng
      translations: AppTranslations(), // Sử dụng AppTranslations từ file riêng
      debugShowCheckedModeBanner: false,
    );
  }
}