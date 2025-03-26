import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchAdDialog extends StatelessWidget {
  final VoidCallback onComplete;
  const WatchAdDialog({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        'Change Theme',
        style: TextStyle(color: Color(0xFFFFFFFF)),
      ),
      content: Text('Watch an Ad to Change App Theme.',
          style: TextStyle(color: Color(0xFFFFFFFF))),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          textStyle: TextStyle(color: Color(0xFF03C343)),
          child: Text('Watch Ad'),
          onPressed: () {
            Get.back();
            onComplete();
          },
        ),
      ],
    );
  }
}
