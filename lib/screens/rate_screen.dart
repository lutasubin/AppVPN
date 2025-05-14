import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';

class RatingBottomSheet extends StatefulWidget {
  const RatingBottomSheet({super.key});

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _rating = 0;

  final Map<int, Map<String, String>> ratingContent = {
    1: {
      "emoji": "😢",
      "title": "Oh No!",
      "message":
          "We're sorry you had a bad experience.\nPlease leave us some feedback.",
    },
    2: {
      "emoji": "😕",
      "title": "Oh No!",
      "message":
          "We understand you are not happy with the service.\nPlease leave us some feedback.",
    },
    3: {
      "emoji": "😐",
      "title": "Oh No!",
      "message":
          "We would like the opportunity to investigate your feedback further.",
    },
    4: {
      "emoji": "😊",
      "title": "So Amazing!",
      "message": "Thank you so much for the wonderful review.",
    },
    5: {
      "emoji": "😘",
      "title": "We like you too!",
      "message":
          "Thank you so much for taking the time to leave us your review.",
    },
  };

  @override
  Widget build(BuildContext context) {
    final content = ratingContent[_rating] ??
        {
          "emoji": "😊",
          "title": "Rate Us",
          "message":
              "We are working hard for a better user experience.\nWe'd greatly appreciate it if you can rate us.",
        };

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content["emoji"]!, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              content["title"]!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              content["message"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() {
                    _rating = starIndex;
                    // Track selected rating value
                    AnalyticsHelper.logSettingChange(
                        'rate_stars_selected', starIndex.toString());
                  }),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _rating >= starIndex ? Icons.star : Icons.star_border,
                      key: ValueKey(_rating >= starIndex),
                      color: Colors.orange,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.deepOrange.withOpacity(0.4);
                      }
                      return Colors.deepOrange;
                    },
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                onPressed: _rating == 0
                    ? null
                    : () {
                        if (_rating >= 4) {
                          // Track high rating with Google Play redirection
                          AnalyticsHelper.logSettingChange(
                              'rate_on_play_store', _rating.toString());
                          _launchPlayStore();
                        } else {
                          // Track low rating without redirection
                          AnalyticsHelper.logSettingChange(
                              'rate_feedback_only', _rating.toString());
                          Get.back(); // Close bottom sheet
                        }
                      },
                child: Text(
                  _rating >= 4 ? 'Rate On Google Play' : 'Rate Us',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPlayStore() async {
    final Uri uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.Lutasubin.freeVpn'); // thay bằng package ID của bạn

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Không thể mở đường dẫn đánh giá');
    }
  }
}
