import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

class WatchAdDialogDisconnect extends StatelessWidget {
  final VoidCallback onComplete;

  const WatchAdDialogDisconnect({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const NativeAdWithLoadingWidget(
              adType: 'new2',
            ),

            const SizedBox(height: 8),

            // --- Nút DISCONNECT ---
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  onComplete();
                  Get.back();
                },
                child: const Text(
                  "DISCONNECT",
                  style: TextStyle(
                      color: Color(0xFF4A9EFF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // --- Nút CANCEL ---
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  "CANCEL",
                  style: TextStyle(
                      color: Color(0xFF767C8A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
