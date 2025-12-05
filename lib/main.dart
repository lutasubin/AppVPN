import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:vpn_basic_project/appVpn.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/remote_config/config_firebase.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';

late Size mq;

Future<void> main() async {
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Không block UI
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive));
  unawaited(SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]));

  // Init Hive trước vì App cần đọc language/theme
  await Pref.initializeHive();

  // Run UI ngay lập tức
  runApp(const App());

  // Remove splash khi frame đầu render
  binding.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });

  // Khởi tạo các service nặng ở background, **theo thứ tự đúng**
  unawaited(_initBackgroundServices());
}

/// Init các service nặng, theo thứ tự:
/// 1. Firebase
/// 2. Analytics (phải sau Firebase)
/// 3. Remote Config (có thể song song)
Future<void> _initBackgroundServices() async {
  try {
    await _initFirebase();      // Firebase phải init trước
    await _initAnalytics();     // Analytics init sau Firebase
    unawaited(_initRemoteConfig()); // Remote Config có thể chạy song song
  } catch (e) {
    log('❌ Background services init error: $e');
  }
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    log('⚡ Firebase initialized');

    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    log('❌ Firebase init error: $e');
  }
}

Future<void> _initAnalytics() async {
  try {
    // Khởi tạo AnalyticsHelper sau khi Firebase init xong
    await AnalyticsHelper.init();

    // Log AppOpen
    await AnalyticsHelper.logAppOpen();
    log('⚡ Analytics AppOpen logged');
  } catch (e) {
    log('❌ Analytics init error: $e');
  }
}

Future<void> _initRemoteConfig() async {
  try {
    await Config.initConfig().timeout(
      const Duration(seconds: 2),
      onTimeout: () => log('⚠ Remote Config timeout — skipping'),
    );
    log('⚡ Remote Config loaded');
  } catch (e) {
    log('❌ Remote Config error: $e');
  }
}
