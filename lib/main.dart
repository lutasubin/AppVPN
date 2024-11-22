import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/splash_screen.dart';

// Global variables
late Size mq;
late SharedPreferences prefs;

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  // Initialize shared preferences
  prefs = await SharedPreferences.getInstance();

  // Enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  await Pref.initializeHive();

  await AdHelper.initAds();

  // Set orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OpenVpn Demo',
      home: const SplashScreen(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 3,
        ),
        // You might want to add more theme configurations here
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      themeMode: Pref.isDartMode ? ThemeMode.dark:ThemeMode.light,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 3,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightText => Pref.isDartMode ? Colors.white70 : Colors.black54;
  Color get bottomNav => Pref.isDartMode ? Colors.white12 : Colors.blue;

}
