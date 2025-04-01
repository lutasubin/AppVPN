import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDialogs2 {
  static void error({required String msg, String? title}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: title != null
            ? Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
            : null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Biểu tượng Wi-Fi bị gạch chéo nếu là lỗi "No Internet!"
            if (msg == 'error_connect_server'.tr)
              const Icon(
                Icons.wifi_off,
                color: Color(0xFFF15E24),
                size: 50,
              ),
            const SizedBox(height: 10),
            Text(
              msg,
              style: const TextStyle(
                color: Color(0xFFF15E24),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (msg == 'no_internet'.tr) ...[
              const SizedBox(height: 10),
              const Text(
                'Please check your wifi or mobile network connection',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFF15E24),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
