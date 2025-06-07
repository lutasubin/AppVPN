import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchAdDialogDisconnect extends StatelessWidget {
  final VoidCallback onComplete;

  const WatchAdDialogDisconnect({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFFFFF), // nền trắng
      title: Text(
        'disconnected_log'.tr,
        style: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      content: Text(
        'disconnected_log_message'.tr,
        style: const TextStyle(
            color: Color(0xFF767C8A),
            fontSize: 16,
            fontWeight: FontWeight.w500),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'cancel'.tr,
            style: const TextStyle(
                color: Color(0xFF767C8A),
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () {
            onComplete();
          },
          child: Text(
            'disconnect'.tr,
            style: const TextStyle(
                color: Color(0xFFF15E24),
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
