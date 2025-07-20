import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';

class ApplicationVpnScreen extends StatefulWidget {
  @override
  _ApplicationVpnScreenState createState() => _ApplicationVpnScreenState();
}

class _ApplicationVpnScreenState extends State<ApplicationVpnScreen> {
  List<AppInfo> installedApps = [];
  Map<String, bool> appToggleStates = {};
  bool isLoading = true;
  static const String _vpnAppsKey = 'vpn_enabled_apps';
  final _adController7 = NativeAdController();

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  // Lưu trạng thái vào SharedPreferences
  Future<void> _saveToggleStates() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledApps = appToggleStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    await prefs.setStringList(_vpnAppsKey, enabledApps);
  }

  // Tải trạng thái từ SharedPreferences
  Future<void> _loadToggleStates() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledApps = prefs.getStringList(_vpnAppsKey) ?? [];

    // Đặt tất cả về false trước
    for (var app in installedApps) {
      appToggleStates[app.packageName] = false;
    }

    // Sau đó set các app đã enable về true
    for (var packageName in enabledApps) {
      if (appToggleStates.containsKey(packageName)) {
        appToggleStates[packageName] = true;
      }
    }
  }

  Future<void> _loadInstalledApps() async {
    try {
      // Lấy danh sách ứng dụng đã cài đặt
      List<AppInfo> apps = await InstalledApps.getInstalledApps(
        true, // excludeSystemApps - Loại bỏ ứng dụng hệ thống
        true, // withIcon - Lấy icon của ứng dụng
        '', // packageNamePrefix - Lọc theo prefix (để trống để lấy tất cả)
      );

      setState(() {
        installedApps = apps;
        isLoading = false;
      });

      // Tải trạng thái đã lưu
      await _loadToggleStates();
      setState(() {}); // Cập nhật UI sau khi load trạng thái
    } catch (e) {
      print('Error loading apps: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _adController7.ad = AdHelper.loadNativeAd2(adController: _adController7);
    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF02091A),
        elevation: 0,
        title: Text(
          'app'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AdHelper.showInterstitialAd(onComplete: () async {
                Get.back();
                // Lưu cài đặt VPN cho các ứng dụng
                _saveVpnSettings();
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
          return SizedBox.shrink();
        }
      }),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF15E24),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),
                // Danh sách ứng dụng
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
          // ignore: deprecated_member_use
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
                      },
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF02091A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.android,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
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
              setState(() {
                appToggleStates[app.packageName] = value;
              });
              // Tự động lưu trạng thái khi thay đổi
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
    // Tự động lưu trạng thái khi bấm SAVE
    _saveToggleStates();

    // Hiển thị thông báo
  }
}