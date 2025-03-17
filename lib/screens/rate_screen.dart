import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:vpn_basic_project/helpers/pref.dart';

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int selectedRating = 0;
  final int totalStars = 5;

  // Emoji mapping based on rating
  final Map<int, String> emojiMap = {
    0: '😐', // Default/No rating
    1: '😢', // Very dissatisfied
    2: '😥', // Dissatisfied
    3: '😐', // Neutral
    4: '😊', // Satisfied
    5: '😍', // Very satisfied
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02091A), // Mã màu mới
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A), // Mã màu mới
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: const Color(0xFFFFFFFF),
            size: 25,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Rate us'.tr,
          style: TextStyle(
              color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w500),
        ),
      ),
      body: Center(
        child: Card(
          color: const Color(0xFF172032),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Do you like our app ?'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 24),
                // Emoji display
                Text(
                  emojiMap[selectedRating] ?? '😐',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 24),
                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalStars, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Color(0xFFF15E24), // Màu cam
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        'Later'.tr,
                        style:
                            TextStyle(fontSize: 16, color: Color(0XFFFFFFFF)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle rating submission
                        if (selectedRating > 0) {
                          // Submit rating logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.blue,
                              content: Text(
                                'Thanks for rating!'.tr,
                                style: TextStyle(
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          );
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF15E24), // Màu cam
                        foregroundColor: Color(0xFFFFFFFF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Rate now'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
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
