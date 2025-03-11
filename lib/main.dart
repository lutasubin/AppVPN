import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

// Global variables
late Size mq;
late SharedPreferences prefs;

Future<void> main() async {
  // debugPaintSizeEnabled = true; // Hiển thị viền widget

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize mq with the screen size
  mq = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;

  // Load environment variables
  await dotenv.load();

  // Initialize SharedPreferences
  prefs = await SharedPreferences.getInstance();
  // Kiểm tra và đặt cờ lần đầu tiên (nếu chưa có)
  await prefs.setBool('isFirstLaunch', prefs.getBool('isFirstLaunch') ?? true);
  // Get the user's agreement status

  // Set UI mode (no need for immersive mode)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Firebase, Config, Hive, and Ads
  try {
    await Firebase.initializeApp();
    await Config.initConfig();
    await Pref.initializeHive();
    await AdHelper.initAds();
  } catch (e) {
    debugPrint("Error during initialization: $e");
  }

  // Set device orientation
  await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());
  });
}

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
      // themeMode: Pref.isDartMode ? ThemeMode.dark : ThemeMode.light,
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

// extension AppTheme on ThemeData {
//   Color get lightText => Pref.isDartMode ? Colors.white70 : Colors.black54;
//   Color get bottomNav => Pref.isDartMode ? Colors.white12 : Colors.orange;
// }
