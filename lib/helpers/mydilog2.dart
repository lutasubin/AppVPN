import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDialogs2 {
  //error
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

  //warning
  static void warning({required String msg}) {
    Get.snackbar('', '',
        backgroundColor: Color(0xFFFFFFFF), // Màu nền cam
        duration: Duration(seconds: 5),
        titleText: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFFFA726), // Biểu tượng màu trắng
              size: 30,
            ),
            const SizedBox(
                width: 10), // Khoảng cách 10px giữa biểu tượng và tiêu đề
            const Text(
              'Warning!',
              style: TextStyle(
                color: const Color(0xFFFFA726), // Chữ "Warning!" màu trắng
                fontWeight: FontWeight.bold, // Chữ in đậm
                fontSize: 20, // Kích thước chữ 20px
              ),
            ),
          ],
        ),
        messageText: Text(
          msg,
          style: const TextStyle(
            color: Colors.black, // Nội dung thông báo màu đen
            fontSize: 16, // Kích thước chữ 16px
          ),
        ));
  }
}
