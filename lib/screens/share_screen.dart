import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel platform = const MethodChannel('app_channel');

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const ShareBottomSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF02091A), // Mã màu mới
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Share With',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 30,
                  color: Color(0xFFFFFFFF),
                ),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 280,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SocialMediaButton(
                        icon: 'assets/icons/facebook.png',
                        label: 'Facebook',
                        color: const Color.fromARGB(173, 255, 255, 255),
                        link: 'https://facebook.com/your_page',
                      ),
                      SocialMediaButton(
                        icon: 'assets/icons/instagram.png',
                        label: 'Instagram',
                        color: const Color.fromARGB(173, 255, 255, 255),
                        link: 'https://instagram.com/your_page',
                      ),
                      SocialMediaButton(
                        icon: 'assets/icons/twitter.png',
                        label: 'Twitter',
                        color: const Color.fromARGB(173, 255, 255, 255),
                        link: 'https://twitter.com/your_page',
                      ),
                      SocialMediaButton(
                        icon: 'assets/icons/messenger.png',
                        label: 'Messenger',
                        color: const Color.fromARGB(173, 255, 255, 255),
                        link: 'https://m.me/your_page',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SocialMediaButton(
                        icon: 'assets/icons/telegram.png',
                        label: 'Telegram',
                        color: const Color.fromARGB(173, 255, 255, 255),
                        link: 'https://t.me/your_channel',
                      ),
                      SocialMediaButton(
                        icon: 'assets/icons/discord.png',
                        label: 'Discord',
                        color: const Color.fromARGB(173, 255, 255, 255),
                        link: 'https://discord.gg/your_server',
                      ),
                      SocialMediaButton(
                        icon: 'assets/icons/dribble.png',
                        label: 'Dribbble',
                        color: const Color.fromARGB(173, 255, 255, 255),
                        link: 'https://dribbble.com/your_profile',
                      ),
                      SocialMediaButton(
                        icon: 'assets/icons/pinterest.png',
                        label: 'Pinterest',
                        color: const Color.fromARGB(173, 255, 255, 255),
                        link: 'https://pinterest.com/your_profile',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class SocialMediaButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final String link;

  const SocialMediaButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.link,
  });

  Future<void> _openSocialMedia() async {
    try {
      final Uri url = Uri.parse(link);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open $label',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _openSocialMedia,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(15),
            child: Image.asset(
              icon,
              width: 30,
              height: 30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ],
    );
  }
}
