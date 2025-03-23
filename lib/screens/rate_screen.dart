import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Để mở link đánh giá

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int selectedRating = 0;
  final int totalStars = 5;

  final List<String> emojiList = ['😐', '😢', '😥', '😐', '😊', '😍'];
  final List<String> feedbackList = [
    'Not good 😢'.tr,
    'Could be better 😥'.tr,
    'It’s okay 😐'.tr,
    'I like it 😊'.tr,
    'I love it! 😍'.tr
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedRating();
  }

  // Load đánh giá đã lưu
  Future<void> _loadSavedRating() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRating = prefs.getInt('user_rating') ?? 0;
    });
  }

  // Lưu đánh giá
  Future<void> _saveRating(int rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_rating', rating);
  }

  // Gợi ý đánh giá trên Google Play / App Store
  void _redirectToStore() async {
    final Uri url = Uri.parse(
        'https://play.google.com/store/apps/details?com.Lutasubin.freeVpn'); // Thay ID app của bạn
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF), size: 25),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Rate us'.tr,
          style: const TextStyle(
              color: Color(0xFFFFFFFF), fontWeight: FontWeight.w500),
        ),
      ),
      body: Center(
        child: Card(
          color: const Color(0xFF172032),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Do you like our app?'.tr,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 24),

                // Hiển thị emoji với hiệu ứng mượt mà
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    emojiList[selectedRating],
                    key: ValueKey<int>(selectedRating),
                    style: const TextStyle(fontSize: 48),
                  ),
                ),

                const SizedBox(height: 12),

                // Hiển thị phản hồi
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    selectedRating > 0 ? feedbackList[selectedRating - 1] : '',
                    key: ValueKey<int>(selectedRating),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 24),

                // Chọn số sao với hiệu ứng màu sắc
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalStars, (index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                          _saveRating(selectedRating);
                        },
                        child: TweenAnimationBuilder<Color?>(
                          tween: ColorTween(
                            begin: Color(0xFF767C8A),
                            end: index < selectedRating
                                ? const Color(0xFFF15E24)
                                : Color(0xFF767C8A),
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, color, child) {
                            return Icon(Icons.star, color: color, size: 36);
                          },
                        ));
                  }),
                ),

                const SizedBox(height: 24),

                // Nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Later'.tr,
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFFFFFFFF))),
                    ),
                    ElevatedButton(
                      onPressed: selectedRating > 0
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Color(0xFFF15E24),
                                  content: Text(
                                    'Thanks for rating!'.tr,
                                    style: const TextStyle(
                                        color: Color(0xFFFFFFFF)),
                                  ),
                                ),
                              );
                              Get.back();
                              if (selectedRating >= 4) {
                                _redirectToStore(); // Gợi ý đánh giá trên Store
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedRating > 0
                            ? const Color(0xFFF15E24)
                            : Colors.grey,
                        foregroundColor: Color(0xFFFFFFFF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child:
                          Text('Rate now'.tr, style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
