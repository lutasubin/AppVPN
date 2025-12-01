import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

class ApplicationVpnScreen extends StatefulWidget {
  const ApplicationVpnScreen({super.key});

  @override
  _ApplicationVpnScreenState createState() => _ApplicationVpnScreenState();
}

class _ApplicationVpnScreenState extends State<ApplicationVpnScreen> {
  List<AppInfo> installedApps = [];
  Map<String, bool> appToggleStates = {};
  bool isLoading = true;
  static const String _vpnAppsKey = 'vpn_enabled_apps';

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  /// Lưu trạng thái toggle vào SharedPreferences
  Future<void> _saveToggleStates() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledApps = appToggleStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    await prefs.setStringList(_vpnAppsKey, enabledApps);
  }

  /// Load trạng thái toggle từ SharedPreferences
  Future<void> _loadToggleStates() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledApps = prefs.getStringList(_vpnAppsKey) ?? [];

    for (var app in installedApps) {
      appToggleStates[app.packageName] = false;
    }

    for (var packageName in enabledApps) {
      if (appToggleStates.containsKey(packageName)) {
        appToggleStates[packageName] = true;
      }
    }

    if (!mounted) return;
    setState(() {}); // cập nhật UI
  }

  /// Load danh sách app đã cài đặt
  Future<void> _loadInstalledApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(
        true, // excludeSystemApps
        true, // withIcon
        '',
      );

      if (!mounted) return;
      setState(() {
        installedApps = apps;
        isLoading = false;
      });

      await _loadToggleStates(); // load toggle sau khi load apps
    } catch (e) {
      print('Error loading apps: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Lưu cài đặt VPN khi nhấn nút SAVE
  void _saveVpnSettings() {
    _saveToggleStates();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('vpn_settings_saved'.tr),
        backgroundColor: const Color(0xFFF15E24),
      ),
    );
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
              AdHelper.showInterstitialAd(onComplete: () {
                if (!mounted) return;
                Get.back();
                _saveVpnSettings();
              });
            },
            child: Text(
              'save'.tr,
              style: const TextStyle(
                color: Color(0xFFF15E24),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const SafeArea(child: NativeAdWithLoadingWidget(adType: 'new2')),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF15E24),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: installedApps.length,
                    itemBuilder: (context, index) {
                      final app = installedApps[index];
                      return _buildAppItem(app);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppItem(AppInfo app) {
    final isToggled = appToggleStates[app.packageName] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF172032),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Icon ứng dụng
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: app.icon != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      app.icon!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultIcon();
                      },
                    ),
                  )
                : _buildDefaultIcon(),
          ),
          const SizedBox(width: 12),
          // Tên ứng dụng
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
          // Toggle switch
          Switch(
            value: isToggled,
            onChanged: (bool value) {
              if (!mounted) return;
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

  Widget _buildDefaultIcon() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF02091A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.android,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
