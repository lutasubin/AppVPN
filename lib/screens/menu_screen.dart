import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vpn_basic_project/controllers/banner%20_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/Privacy_policy.dart';
import 'package:vpn_basic_project/screens/language_screen.dart';
import 'rate_screen.dart';

class MenuScreen extends StatelessWidget {
  final _baController = BannerAdController();

  MenuScreen({super.key});

  // Bản đồ ánh xạ mã ngôn ngữ sang tên đầy đủ
  final Map<String, String> languageMap = {
    'default': 'Default',
    'en': 'English',
    'hi': 'Hindi',
    'ko': 'Korean',
    'pt': 'Portuguese (Brazil)',
    'vi': 'Vietnamese',
    'ja': 'Japanese',
    'zh': 'Chinese',
    'fr': 'French',
    'es': 'Spanish',
    'de': 'German',
    'ru': 'Russian',
    'ar': 'Arabic',
    'tr': 'Turkish',
    'da': 'Danish',
    'th': 'Thailand',
    'id': 'Indonesian',
    'ss': 'Arabic'
  };

  @override
  Widget build(BuildContext context) {
    _baController.ba = AdHelper.loadBannerAd(baController: _baController);
    // Lấy ngôn ngữ hiện tại từ Pref hoặc Get.locale
    final currentLanguageCode = Pref.selectedLanguage.isNotEmpty
        ? Pref.selectedLanguage
        : Get.locale?.languageCode ?? 'default';
    final currentLanguage = languageMap[currentLanguageCode] ?? 'Default';

    return Scaffold(
      backgroundColor: const Color(0xFF02091A), // Mã màu mới
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A), // Mã màu mới
        leading: IconButton(
          onPressed: () {
            AdHelper.showInterstitialAd(onComplete: () => Get.back());
          },
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFFFFFFFF),
            size: 25,
          ),
        ),
        title: Text(
          'Setting'.tr,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        return _baController.ba != null && _baController.baLoaded.isTrue
            ? SafeArea(
                child: SizedBox(
                height: 120,
                child: AdWidget(ad: _baController.ba!),
              ))
            : SizedBox.shrink();
      }),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/svg/Frame 14.svg',
              height: 173,
              width: double.infinity,
            ),
            SizedBox(
              height: 20,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.language,
              iconColor: Colors.purpleAccent,
              title: 'Language'.tr,
              trailingText: currentLanguage,
              onTap: () {
                // Track language setting access
                AnalyticsHelper.logSettingChange(
                    'open_language_settings', 'clicked');
                Get.to(() => LanguageScreen());
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.star,
              iconColor: Colors.yellow,
              title: 'Rate us'.tr,
              onTap: () {
                // Track rating dialog open
                AnalyticsHelper.logSettingChange('open_rating', 'clicked');
                showRatingBottomSheet(context);
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.share,
              iconColor: Colors.blueAccent,
              title: 'Share with friend'.tr,
              onTap: () async {
                // Track app sharing
                AnalyticsHelper.logSettingChange('share_app', 'clicked');

                /// Share APP with other users

                /// Set the app link and the message to be shared
                final String appLink =
                    'https://play.google.com/store/apps/details?id=com.Lutasubin.freeVpn';
                final String message = 'Check out Our app: $appLink';

                /// Share the app link and message using the share dialog
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
                iconColor: Color(0xFF03C343),
                title: 'Privacy Policy'.tr,
                onTap: () {
                  // Track privacy policy access
                  AnalyticsHelper.logSettingChange(
                      'open_privacy_policy', 'clicked');
                  Get.to(() => PrivacyPolicy());
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
