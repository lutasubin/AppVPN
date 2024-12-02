import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/guide_screen.dart';
import 'about_screen.dart';
import 'faq_screen.dart';
import 'rate_screen.dart';
import 'settings_screen.dart';
import 'share_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pref.isDartMode ? null : Colors.orange,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Text(
          "Menu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          // VPN Image and text
          const SizedBox(height: 40),
          Image.asset('assets/images/vpn_menu.png', height: 200),
          const Text('Fast & Safe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),

          // Menu Items
          const SizedBox(height: 40),
          _buildMenuItem(icon: Icons.book, title: 'Guide'),
          _buildMenuItem(icon: Icons.settings, title: 'Setting'),
          _buildMenuItem(icon: Icons.star, title: 'Rate us'),
          _buildMenuItem(icon: Icons.share, title: 'Share with friend'),
          _buildMenuItem(icon: Icons.info_outline, title: 'About us'),
          _buildMenuItem(icon: Icons.question_answer_outlined, title: 'FAQ'),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
      onTap: () {
        if (title == 'Guide') {
          Get.to(() => const GuideScreen());
        } else if (title == 'About us') {
          Get.to(() => const AboutScreen());
        } else if (title == 'FAQ') {
          Get.to(() => const FAQScreen());
        } else if (title == 'Rate us') {
          Get.to(() => const RateScreen());
        } else if (title == 'Setting') {
          Get.to(() => const SettingsScreen());
        } else if (title == 'Share with friend') {
          ShareBottomSheet.show();
        }
        // Handle other menu items...
      },
    );
  }
}
