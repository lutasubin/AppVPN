import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isChecked = false;

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        title: Text("Are you sure to quit?"),
        content: Text(
          "According to the Play Store Policy, we are not allowed to provide services if you don’t agree. If you leave this page, you will quit the app directly.",
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Color.fromARGB(255, 17, 105, 177)),
            ),
            onPressed: () {
              Get.off(() => HomeScreen());
            },
          ),
          TextButton(
            child: Text(
              "Quit",
              style: TextStyle(color: Color.fromARGB(255, 17, 105, 177)),
            ),
            onPressed: () {
              SystemNavigator.pop(); // Thoát ứng dụng
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/welcome.png', // Đảm bảo rằng bạn có hình ảnh này trong thư mục assets
              height: 200,
            ),
            SizedBox(height: 40),
            Text(
              "Welcome to\nVPN - Fast & Safe",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Checkbox(
                  activeColor: Color.fromARGB(255, 17, 105, 177),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                    print(
                        isChecked); // Debug: Kiểm tra trạng thái checkbox khi thay đổi
                  },
                ),
                Expanded(
                  child: Text(
                    "By using this application you agreed to Terms of Service & Privacy policy.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: isChecked
                  ? () {
                      print('Button pressed!'); // Debug: Kiểm tra khi bấm nút
                      _showExitDialog(); // Hiển thị dialog thay vì điều hướng
                    }
                  : null,
              child: Text("Agree & Continue",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isChecked
                    ? const Color.fromARGB(255, 17, 105, 177)
                    : Colors.grey,
                // Chọn màu khác khi chưa tích
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
