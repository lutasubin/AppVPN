import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchAdDialogDisconnect extends StatelessWidget {
  final VoidCallback onComplete;

  const WatchAdDialogDisconnect({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        'disconnected_log'.tr,
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
      content: Text(
        'disconnected_log_message'.tr,
        style: TextStyle(color: Color(0xFF767C8A)),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          textStyle: TextStyle(color: Color(0xFF767C8A), fontSize: 14),
          child: Text('cancel'.tr),
          onPressed: () {
            Get.back();
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          textStyle: TextStyle(color: Color(0xFFF15E24), fontSize: 14),
          child: Text(
            'disconnect'.tr,
          ),
          onPressed: () {
            Get.back();
            onComplete();
          },
        ),
      ],
    );
  }
}
