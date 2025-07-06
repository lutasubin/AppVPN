import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/screens/home/home_screen.dart';

class AppModel {
  final String name;
  final String packageName;
  final String iconAsset;

  AppModel({
    required this.name,
    required this.packageName,
    required this.iconAsset,
  });
}

final List<AppModel> predefinedApps = [
  AppModel(
    name: 'Discord',
    packageName: 'com.discord',
    iconAsset: 'assets/icons/discord.png',
  ),
  AppModel(
    name: 'Instagram',
    packageName: 'com.instagram.android',
    iconAsset: 'assets/icons/instagram.png',
  ),
  AppModel(
    name: 'Telegram',
    packageName: 'org.telegram.messenger',
    iconAsset: 'assets/icons/telegram.png',
  ),
  AppModel(
    name: 'Facebook',
    packageName: 'com.facebook.katana',
    iconAsset: 'assets/icons/facebook.png',
  ),
  AppModel(
    name: 'Messenger',
    packageName: 'com.facebook.orca',
    iconAsset: 'assets/icons/messenger.png',
  ),
  AppModel(
    name: 'Dribble',
    packageName: 'com.dribble.app',
    iconAsset: 'assets/icons/dribble.png',
  ),
  AppModel(
    name: 'Pinterest',
    packageName: 'com.pinterest',
    iconAsset: 'assets/icons/pinterest.png',
  ),
];

class ApplicationVpnScreen extends StatefulWidget {
  @override
  _ApplicationVpnScreenState createState() => _ApplicationVpnScreenState();
}

class _ApplicationVpnScreenState extends State<ApplicationVpnScreen> {
  Map<String, bool> appToggleStates = {};
  static const String _vpnAppsKey = 'vpn_enabled_apps';
  final _adController7 = NativeAdController();

  @override
  void initState() {
    super.initState();
    _loadToggleStates();
    _adController7.ad = AdHelper.loadNativeAd2(adController: _adController7);
  }

  Future<void> _saveToggleStates() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledApps = appToggleStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    await prefs.setStringList(_vpnAppsKey, enabledApps);
  }

  Future<void> _loadToggleStates() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledApps = prefs.getStringList(_vpnAppsKey) ?? [];

    for (var app in predefinedApps) {
      appToggleStates[app.packageName] = enabledApps.contains(app.packageName);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF02091A),
        elevation: 0,
        title: Text(
          'app'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AdHelper.showInterstitialAd(onComplete: () async {
                _saveVpnSettings();
                Get.back();
              });
            },
            child: Text(
              'save'.tr,
              style: TextStyle(
                color: Color(0xFFF15E24),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (_adController7.ad != null && _adController7.adLoaded.isTrue) {
          return SafeArea(
            child:
                SizedBox(height: 120, child: AdWidget(ad: _adController7.ad!)),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: predefinedApps.length,
              itemBuilder: (context, index) {
                final app = predefinedApps[index];
                return _buildAppItem(app);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppItem(AppModel app) {
    final isToggled = appToggleStates[app.packageName] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF172032),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              app.iconAsset,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  app.packageName,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: isToggled,
            onChanged: (bool value) {
              setState(() {
                appToggleStates[app.packageName] = value;
              });
              _saveToggleStates();
            },
            activeColor: const Color(0xFFF15E24),
            activeTrackColor: Colors.white,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void _saveVpnSettings() {
    _saveToggleStates();
    // Show snackbar/toast if needed
  }
}
