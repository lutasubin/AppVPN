import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDialogs {
  static success({required String msg}) {
    Get.snackbar(
      'Success',
      msg,
      colorText: Color(0xFFFFFFFF),
      // ignore: deprecated_member_use
      backgroundColor: Colors.green.withOpacity(.9),
      duration: Duration(seconds: 5),
    );
  }

  static error({required String msg}) {
    Get.snackbar(
      'Error',
      msg,
      colorText: Color(0xFFFFFFFF),
      // ignore: deprecated_member_use
      backgroundColor: Colors.redAccent.withOpacity(.9),
      duration: Duration(seconds: 3),
    );
  }

  static info({required String msg}) {
    Get.snackbar(
      'Info',
      msg,
      colorText: Color(0xFFFFFFFF),
      // ignore: deprecated_member_use
      backgroundColor: Colors.blue.withOpacity(.9), // Thêm background
      duration: Duration(seconds: 3), // Thêm duration
    );
  }
}
