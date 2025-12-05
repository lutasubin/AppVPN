import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';
import 'package:vpn_basic_project/helpers/lang/setting_languae.dart';
import 'package:vpn_basic_project/view/screens/menu/privacy_police/Privacy_policy.dart';
import 'package:vpn_basic_project/view/screens/menu/lang/language_screen.dart';
import 'package:vpn_basic_project/view/screens/menu/speed_test/speed_test.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';
import 'rate/rate_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final currentLanguageCode = Pref.selectedLanguage.isNotEmpty
        ? Pref.selectedLanguage
        : Get.locale?.languageCode ?? 'default';
    final currentLanguage = languageMap[currentLanguageCode] ?? 'Default';

    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFFFFFF),
            size: 25,
          ),
        ),
        title: Text(
          'Setting'.tr,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBar:
          const SafeArea(child: NativeAdWithLoadingWidget(adType: 'small')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/svg/image_setting.svg',
              height: 173,
              width: double.infinity,
            ),
            const SizedBox(height: 20),

            // Các mục menu cũ
            _buildMenuItem(
              context: context,
              icon: Icons.network_check,
              iconColor: const Color(0xFF3FD8EF),
              title: 'test1'.tr,
              onTap: () {
                AnalyticsHelper.logSettingChange('open_speedtest', 'clicked');
                Get.to(() => const SpeedTestScreen());
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.language,
              iconColor: const Color(0xFF3FD8EF),
              title: 'Language'.tr,
              trailingText: currentLanguage,
              onTap: () {
                AnalyticsHelper.logSettingChange(
                    'open_language_settings', 'clicked');
                Get.off(() => const LanguageScreen());
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.star,
              iconColor: const Color(0xFF3FD8EF),
              title: 'Rate us'.tr,
              onTap: () {
                AnalyticsHelper.logSettingChange('open_rating', 'clicked');
                showRatingBottomSheet(context);
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.share,
              iconColor: const Color(0xFF3FD8EF),
              title: 'Share with friend'.tr,
              onTap: () async {
                AnalyticsHelper.logSettingChange('share_app', 'clicked');
                const String appLink =
                    'https://play.google.com/store/apps/details?id=com.SpAiMobileToMobileTool.TurborVpn';
                const String message = 'Check out Our app: $appLink';
                await Share.share(
                  message,
                  subject: 'Share App',
                );
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
                context: context,
                icon: Icons.privacy_tip,
                iconColor: const Color(0xFF3FD8EF),
                title: 'Privacy Policy'.tr,
                onTap: () {
                  AnalyticsHelper.logSettingChange(
                      'open_privacy_policy', 'clicked');
                  Get.to(() => const PrivacyPolicy());
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF172032),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void showRatingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.transparent,
      builder: (_) => const RatingBottomSheet(),
    );
  }
}
