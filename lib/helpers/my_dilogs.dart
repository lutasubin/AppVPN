import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDialogs {
  static success({required String msg}) {
    Get.snackbar('Success', msg,
        colorText:  Color(0xFFFFFFFF), backgroundColor: Colors.green.withOpacity(.9));
  }

  static error({required String msg}) {
    Get.snackbar('Error', msg,
        colorText:  Color(0xFFFFFFFF),
        backgroundColor: Colors.redAccent.withOpacity(.9));
  }

  static info({required String msg}) {
    Get.snackbar('Info', msg, colorText:  Color(0xFFFFFFFF),);
  }

  static showProgress() {
    Get.dialog(Center(child: CircularProgressIndicator(strokeWidth: 2)));
  }
}
