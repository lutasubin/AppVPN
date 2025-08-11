import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/app_binding.dart';
import 'package:vpn_basic_project/helpers/AppLifecycleHandler.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/helpers/lang/app_translations.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';
import 'package:vpn_basic_project/view/screens/splash/splash_screen.dart';

/// Lớp chính của ứng dụng.
/// Cấu hình GetMaterialApp với theme, locale và màn hình khởi đầu.
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Chạy sau khi widget tree được render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(AppLifecycleHandler());
      AdHelper.initAds(); // ✅ Chỉ khởi tạo sau khi widget tree có mặt
    });

    return GetMaterialApp(
      initialBinding: AppBinding(),
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
