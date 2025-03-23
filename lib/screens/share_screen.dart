import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareBottomSheet extends StatelessWidget {
  final String? shareText;
  final String? shareUrl;

  const ShareBottomSheet({super.key, this.shareText, this.shareUrl});

  static void show({String? shareText, String? shareUrl}) {
    Get.bottomSheet(
      ShareBottomSheet(shareText: shareText, shareUrl: shareUrl),
      backgroundColor: Color(0xFF172032),
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
    final List<SocialPlatform> platforms = [
      SocialPlatform('Facebook', 'assets/icons/facebook.png', Color(0xFF3B5998),
          'https://www.facebook.com/sharer/sharer.php?u={url}&t={text}'),
      SocialPlatform('Instagram', 'assets/icons/instagram.png',
          Color(0xFFE4405F), 'https://www.instagram.com/'),
      SocialPlatform(
          'Twitter',
          'assets/icons/twitter.png',
          Color.fromARGB(255, 156, 200, 227),
          'https://twitter.com/intent/tweet?text={text}&url={url}'),
      SocialPlatform('Messenger', 'assets/icons/messenger.png',
          Color(0xFF0084FF), 'fb-messenger://share?link={url}'),
      SocialPlatform('Telegram', 'assets/icons/telegram.png', Color(0xFF0088CC),
          'https://t.me/share/url?url={url}&text={text}'),
      SocialPlatform(
          'Discord',
          'assets/icons/discord.png',
          Color.fromARGB(255, 195, 203, 233),
          'https://discord.com/channels/@me?text={text} {url}'),
      SocialPlatform('Dribbble', 'assets/icons/dribble.png', Color(0xFFEA4C89),
          'https://dribbble.com/shots/new?url={url}'),
      SocialPlatform(
          'Pinterest',
          'assets/icons/pinterest.png',
          Color(0xFFBD081C),
          'https://pinterest.com/pin/create/button/?url={url}&description={text}'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF02091A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            itemCount: platforms.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final platform = platforms[index];
              return SocialMediaButton(
                platform: platform,
                shareText: shareText,
                shareUrl: shareUrl,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Share with friend'.tr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 30, color: Color(0xFFFFFFFF)),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }
}

class SocialMediaButton extends StatefulWidget {
  final SocialPlatform platform;
  final String? shareText;
  final String? shareUrl;

  const SocialMediaButton({
    super.key,
    required this.platform,
    this.shareText,
    this.shareUrl,
  });

  @override
  _SocialMediaButtonState createState() => _SocialMediaButtonState();
}

class _SocialMediaButtonState extends State<SocialMediaButton> {
  bool isLoading = false;

  Future<void> _openSocialMedia() async {
    setState(() => isLoading = true);
    try {
      final text = Uri.encodeComponent(widget.shareText ?? 'Check this out!');
      final url = Uri.encodeComponent(widget.shareUrl ?? 'https://yourapp.com');
      final formattedUrl = widget.platform.baseLink
          .replaceAll('{text}', text)
          .replaceAll('{url}', url);

      final Uri uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Không thể mở ${widget.platform.name}';
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể mở ${widget.platform.name}: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : _openSocialMedia,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: widget.platform.color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: widget.platform.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(15),
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  )
                : Image.asset(widget.platform.icon, width: 30, height: 30),
          ),
          const SizedBox(height: 8),
          Text(
            widget.platform.name,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class SocialPlatform {
  final String name;
  final String icon;
  final Color color;
  final String baseLink;

  SocialPlatform(this.name, this.icon, this.color, this.baseLink);
}
