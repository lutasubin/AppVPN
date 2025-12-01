import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoInternetPopup extends StatelessWidget {
  const NoInternetPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'no_internet'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 214, 38, 25),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
