import 'dart:developer';
import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static final _config = FirebaseRemoteConfig.instance;
  static SharedPreferences? _prefs;
  static Timer? _configFetchTimer;

  // Cache keys
  static const String _cachePrefix = 'ad_config_';
  static const String _lastFetchKey = 'last_config_fetch';
  static const Duration _cacheExpiry = Duration(hours: 2);

  static const _defaultValues = {
    "rewarded_ad": "",
    "interstitial_ad": "",
    "native_ad": "",
    "native1_ad": "",
    "native2_ad": "",
    "banner_ad": "",
    "open_ad": "",
    "show_ads": true,
    "ad_request_timeout": 10, // seconds
    "retry_delay": 30, // seconds
    "max_retries": 3,
    // ✅ NEW: API token for WireGuard service
    "api_token": "", // Default fallback value
    "nuoc_anh": "",
    "nuoc_my": "",
    "nuoc_phap": "",
    "nuoc_sin": "",
  };

  static Future<void> initConfig() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      await _config.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30), // Giảm timeout
        minimumFetchInterval:
            const Duration(minutes: 15), // Giảm interval để update nhanh hơn
      ));

      await _config.setDefaults(_defaultValues);

      // Thử load từ cache trước
      _loadFromCache();

      // Fetch mới từ remote
      await _fetchRemoteConfig();

      // Setup periodic fetch
      _setupPeriodicFetch();

      // Listen for updates
      _config.onConfigUpdated.listen(_handleConfigUpdate);
    } catch (e) {
      log('❌ Error initializing config: $e');
      _loadFromCache(); // Fallback to cache
    }
  }

  static Future<void> _fetchRemoteConfig() async {
    try {
      final stopwatch = Stopwatch()..start();

      final activated = await _config.fetchAndActivate();

      stopwatch.stop();
      log('✅ Remote config fetched in ${stopwatch.elapsedMilliseconds}ms: $activated');

      if (activated) {
        await _saveToCache();
        log('💾 Config saved to cache');
      }

      _logConfigValues();
    } catch (e) {
      log('⚠️ Failed to fetch remote config: $e');
      // Không throw error, sử dụng cache hoặc default values
    }
  }

  static void _loadFromCache() {
    if (_prefs == null) return;

    try {
      final lastFetch = _prefs!.getInt(_lastFetchKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - lastFetch < _cacheExpiry.inMilliseconds) {
        // Cache vẫn valid, load từ cache
        for (String key in _defaultValues.keys) {
          final cachedValue = _prefs!.get('$_cachePrefix$key');
          if (cachedValue != null) {
            // Set vào memory cho remote config
            log('📦 Loaded $key from cache: $cachedValue');
          }
        }
        log('✅ Config loaded from cache');
      } else {
        log('⏰ Cache expired, will fetch fresh config');
      }
    } catch (e) {
      log('❌ Error loading from cache: $e');
    }
  }

  static Future<void> _saveToCache() async {
    if (_prefs == null) return;

    try {
      for (String key in _defaultValues.keys) {
        final value = _getConfigValue(key);
        if (value is bool) {
          await _prefs!.setBool('$_cachePrefix$key', value);
        } else if (value is int) {
          await _prefs!.setInt('$_cachePrefix$key', value);
        } else if (value is String) {
          await _prefs!.setString('$_cachePrefix$key', value);
        }
      }

      await _prefs!
          .setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
      log('💾 Config cached successfully');
    } catch (e) {
      log('❌ Error saving to cache: $e');
    }
  }

  static dynamic _getConfigValue(String key) {
    try {
      final defaultValue = _defaultValues[key];
      if (defaultValue is bool) {
        return _config.getBool(key);
      } else if (defaultValue is int) {
        return _config.getInt(key);
      } else if (defaultValue is String) {
        return _config.getString(key);
      }
      return defaultValue;
    } catch (e) {
      log('⚠️ Error getting config value for $key: $e');
      return _defaultValues[key];
    }
  }

  static void _setupPeriodicFetch() {
    _configFetchTimer?.cancel();
    _configFetchTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _fetchRemoteConfig(),
    );
  }

  static Future<void> _handleConfigUpdate(RemoteConfigUpdate event) async {
    try {
      await _config.activate();
      await _saveToCache();
      log('🔄 Remote config updated and cached');
      _logConfigValues();
    } catch (e) {
      log('⚠️ Error handling config update: $e');
    }
  }

  static void _logConfigValues() {
    log('📋 Current config values:');
    log('  show_ads: $showAds');
    log('  interstitial_ad: ${interstitialAd.isNotEmpty ? "SET" : "EMPTY"}');
    log('  banner_ad: ${bannerAd.isNotEmpty ? "SET" : "EMPTY"}');
    log('  native_ad: ${nativeAd.isNotEmpty ? "SET" : "EMPTY"}');
    log('  native1_ad: ${native1Ad.isNotEmpty ? "SET" : "EMPTY"}');
    log('  native2_ad: ${native2Ad.isNotEmpty ? "SET" : "EMPTY"}');
    log('  rewarded_ad: ${rewardedAd.isNotEmpty ? "SET" : "EMPTY"}');
    log('  open_ad: ${openAd.isNotEmpty ? "SET" : "EMPTY"}');
    log('  ad_request_timeout: ${adRequestTimeout}s');
    log('  retry_delay: ${retryDelay}s');
    log('  max_retries: $maxRetries');
    log('  api_token: ${apiToken.isNotEmpty ? "SET" : "EMPTY"}'); // ✅ NEW
    log('  nuoc_anh: ${nuocAnh.isNotEmpty ? "SET" : "EMPTY"}'); // ✅ NEW
    log('  nuoc_my: ${nuocMy.isNotEmpty ? "SET" : "EMPTY"}'); // ✅ NEW
    log('  nuoc_phap: ${nuocPhap.isNotEmpty ? "SET" : "EMPTY"}'); // ✅ NEW
    log('  nuoc_sin: ${nuocSin.isNotEmpty ? "SET" : "EMPTY"}'); // ✅ NEW
  }

  // Public getters with fallback
  static bool get showAds {
    try {
      return _config.getBool('show_ads');
    } catch (e) {
      // Fallback to cache
      return _prefs?.getBool('${_cachePrefix}show_ads') ??
          _defaultValues['show_ads'] as bool;
    }
  }

  static String get nativeAd {
    try {
      return _config.getString('native_ad');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}native_ad') ??
          _defaultValues['native_ad'] as String;
    }
  }

  static String get native1Ad {
    try {
      return _config.getString('native1_ad');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}native1_ad') ??
          _defaultValues['native1_ad'] as String;
    }
  }

  static String get native2Ad {
    try {
      return _config.getString('native2_ad');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}native2_ad') ??
          _defaultValues['native2_ad'] as String;
    }
  }

  static String get rewardedAd {
    try {
      return _config.getString('rewarded_ad');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}rewarded_ad') ??
          _defaultValues['rewarded_ad'] as String;
    }
  }

  static String get interstitialAd {
    try {
      return _config.getString('interstitial_ad');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}interstitial_ad') ??
          _defaultValues['interstitial_ad'] as String;
    }
  }

  static String get bannerAd {
    try {
      return _config.getString('banner_ad');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}banner_ad') ??
          _defaultValues['banner_ad'] as String;
    }
  }

  static String get openAd {
    try {
      return _config.getString('open_ad');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}open_ad') ??
          _defaultValues['open_ad'] as String;
    }
  }

  // ✅ NEW: API Token getter with fallback
  static String get apiToken {
    try {
      return _config.getString('api_token');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}api_token') ??
          _defaultValues['api_token'] as String;
    }
  }

  static String get nuocAnh {
    try {
      return _config.getString('nuoc_anh');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}nuoc_anh') ??
          _defaultValues['nuoc_anh'] as String;
    }
  }

  static String get nuocMy {
    try {
      return _config.getString('nuoc_my');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}nuoc_my') ??
          _defaultValues['nuoc_my'] as String;
    }
  }

  static String get nuocPhap {
    try {
      return _config.getString('nuoc_phap');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}nuoc_phap') ??
          _defaultValues['nuoc_phap'] as String;
    }
  }

  static String get nuocSin {
    try {
      return _config.getString('nuoc_sin');
    } catch (e) {
      return _prefs?.getString('${_cachePrefix}nuoc_sin') ??
          _defaultValues['nuoc_sin'] as String;
    }
  }

  // New configuration options
  static int get adRequestTimeout {
    try {
      return _config.getInt('ad_request_timeout');
    } catch (e) {
      return _prefs?.getInt('${_cachePrefix}ad_request_timeout') ??
          _defaultValues['ad_request_timeout'] as int;
    }
  }

  static int get retryDelay {
    try {
      return _config.getInt('retry_delay');
    } catch (e) {
      return _prefs?.getInt('${_cachePrefix}retry_delay') ??
          _defaultValues['retry_delay'] as int;
    }
  }

  static int get maxRetries {
    try {
      return _config.getInt('max_retries');
    } catch (e) {
      return _prefs?.getInt('${_cachePrefix}max_retries') ??
          _defaultValues['max_retries'] as int;
    }
  }

  static bool get hideAds => !showAds;

  // Utility methods
  static Future<void> forceRefresh() async {
    log('🔄 Force refreshing config...');
    await _fetchRemoteConfig();
  }

  static void dispose() {
    _configFetchTimer?.cancel();
  }

  // Debug method
  static Map<String, dynamic> getAllValues() {
    return {
      'show_ads': showAds,
      'native_ad': nativeAd.isNotEmpty ? 'SET' : 'EMPTY',
      'native1_ad': native1Ad.isNotEmpty ? 'SET' : 'EMPTY',
      'native2_ad': native2Ad.isNotEmpty ? 'SET' : 'EMPTY',
      'rewarded_ad': rewardedAd.isNotEmpty ? 'SET' : 'EMPTY',
      'interstitial_ad': interstitialAd.isNotEmpty ? 'SET' : 'EMPTY',
      'banner_ad': bannerAd.isNotEmpty ? 'SET' : 'EMPTY',
      'open_ad': openAd.isNotEmpty ? 'SET' : 'EMPTY',
      'ad_request_timeout': adRequestTimeout,
      'retry_delay': retryDelay,
      'max_retries': maxRetries,
      'api_token': apiToken.isNotEmpty ? 'SET' : 'EMPTY', // ✅ NEW
      'nuoc_anh': nuocAnh.isNotEmpty ? 'SET' : 'EMPTY', // ✅ NEW
      'nuoc_my': nuocMy.isNotEmpty ? 'SET' : 'EMPTY', // ✅ NEW
      'nuoc_phap': nuocPhap.isNotEmpty ? 'SET' : 'EMPTY', // ✅ NEW
      'nuoc_sin': nuocSin.isNotEmpty ? 'SET' : 'EMPTY', // ✅ NEW
    };
  }
}
