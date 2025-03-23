import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vpn_basic_project/helpers/pref.dart'; // Bỏ comment để sử dụng Pref
import 'package:vpn_basic_project/screens/language_screen.dart';
import 'package:vpn_basic_project/screens/rate_screen.dart';
import 'share_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
  };

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Get.back(),
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
              onTap: () => Get.to(() => const LanguageScreen()),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.star,
              iconColor: Colors.yellow,
              title: 'Rate us'.tr,
              onTap: () => Get.to(() => const RateScreen(),
                  transition: Transition.upToDown),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.share,
              iconColor: Colors.blueAccent,
              title: 'Share with friend'.tr,
              onTap: () => ShareBottomSheet.show(),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
                context: context,
                icon: Icons.privacy_tip,
                iconColor: Colors.green,
                title: 'Privacy Policy'.tr,
                onTap: () async {
                  const url = 'https://your-privacy-policy-url.com';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
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
}
