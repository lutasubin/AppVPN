import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/app_translations.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/splash_screen.dart';

/// Lớp chính của ứng dụng.
/// Cấu hình GetMaterialApp với theme, locale và màn hình khởi đầu.
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

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