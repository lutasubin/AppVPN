import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class WatchAdDialog extends StatelessWidget {
  final VoidCallback onComplete;
  const WatchAdDialog({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        'change_theme'.tr,
        style: TextStyle(color: Color(0xFFFFFFFF)),
      ),
      content: Text('watch_ad_message'.tr,
          style: TextStyle(color: Color(0xFFFFFFFF))),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          textStyle: TextStyle(color: Color(0xFF03C343)),
          child: Text('watch_ad'.tr),
          onPressed: () {
            Get.back();
            onComplete();
          },
        ),
      ],
    );
  }
}
