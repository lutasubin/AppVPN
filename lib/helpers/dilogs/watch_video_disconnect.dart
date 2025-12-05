import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

class WatchAdDialogDisconnect extends StatelessWidget {
  final VoidCallback onComplete;

  const WatchAdDialogDisconnect({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ====== Icon đẹp ======
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAFBFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Icon(
                Icons.power_settings_new,
                size: 35,
                color: Color(0xFF3FD8EF),
              ),
            ),

            const SizedBox(height: 16),

            // ====== Native Ads ======
            const NativeAdWithLoadingWidget(adType: 'new2'),
            const SizedBox(height: 10),

            // ====== Text thông báo ======
            Text(
              "Are you sure you want to disconnect?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 22),

            // ====== Nút Disconnect (gradient) ======
            GestureDetector(
              onTap: () {
                onComplete();
                Get.back();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3FD8EF),
                      Color(0xFF40E2D4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "DISCONNECT",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ====== Nút Cancel ======
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "CANCEL",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
