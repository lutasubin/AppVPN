import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class Config {
  static final _config = FirebaseRemoteConfig.instance;
  static const _defaultValues = {
    // "rewarded_ad": "ca-app-pub-3940256099942544/5224354917",
    "interstitial_ad": "ca-app-pub-3940256099942544/1033173712",
    "native_ad": "ca-app-pub-3940256099942544/2247696110",
    "show_ads": true
  };
  static Future<void> initConfig() async {
    await _config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(minutes: 30),
    ));

    await _config.setDefaults(_defaultValues);
    await _config.fetchAndActivate();
    log('Remote config data:${_config.getBool('show_ads')}');

    _config.onConfigUpdated.listen((event) async {
      await _config.activate();
      log('updated:${_config.getBool('show_ads')}');
    });
  }

  static bool get _showAd => _config.getBool('show_ads');
  //ad ids
  static String get nativeAd => _config.getString('native_ad');
  // static String get rewardedAd => _config.getString('rewarded_ad');
  static String get interstitialAd => _config.getString('interstitial_ad');

  static bool get hideAds => !_showAd;
}
