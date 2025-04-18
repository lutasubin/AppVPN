import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
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
              "We are working hard for a better user experience.\nWe’d greatly appreciate it if you can rate us.",
        };

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content["emoji"]!, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                content["title"]!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      onPressed: () => setState(() => _rating = starIndex),
                      icon: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          _rating >= starIndex ? Icons.star : Icons.star_border,
                          key: ValueKey(_rating >= starIndex),
                          color: Colors.orange,
                          size: 32,
                        ),
                      ));
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
                          return Colors.deepOrange
                              .withOpacity(0.4); // màu mờ khi disabled
                        }
                        return Colors.deepOrange; // màu thường khi enabled
                      },
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: _rating == 0
                      ? null // Vô hiệu hóa nếu chưa chọn sao
                      : () {
                          if (_rating >= 4) {
                            // Gửi tới Google Play
                            _launchInAppReviewOrStore();
                          } else {
                            // Hiển thị phản hồi
                            Get.back();
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
      ),
    );
  }

Future<void> _launchInAppReviewOrStore() async {
  final InAppReview inAppReview = InAppReview.instance;

  try {
    // Kiểm tra nếu review trong app khả dụng
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview(); // Ưu tiên dùng popup trong app
    } else {
      await inAppReview.openStoreListing(); // Fallback: mở trang app trên CH Play
    }
  } catch (e) {
    throw Exception('Không thể mở đánh giá: $e');
  }
}
}
