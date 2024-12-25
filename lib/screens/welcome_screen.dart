import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isChecked = false;
  bool isAgreed = false;  // Trạng thái đồng ý của người dùng

  // Đọc trạng thái đồng ý từ SharedPreferences khi màn hình được tạo
  @override
  void initState() {
    super.initState();
    _checkAgreementStatus();
  }

  // Kiểm tra trạng thái đồng ý của người dùng
  Future<void> _checkAgreementStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAgreed = prefs.getBool('isAgreed') ?? false;
    });
  }

  // Lưu trạng thái đồng ý và điều hướng đến HomeScreen
  Future<void> _agreeAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAgreed', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  HomeScreen()),
    );
  }

  // Hiển thị Dialog thoát ứng dụng
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Exit"),
          ),
        ],
      ),
    ).then((value) {
      if (value == true) {
        // Thoát ứng dụng
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hình ảnh chào mừng
            Image.asset(
              'assets/images/welcome.png',
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 300);
              },
            ),
            const SizedBox(height: 40),

            // Tiêu đề ứng dụng
            const Text(
              "Welcome to\nVPN - Fast & Safe",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 30, 141, 232),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Điều khoản sử dụng
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  activeColor: const Color.fromARGB(255, 17, 105, 177),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: const Text(
                    "By using this application you agreed to Terms of Service & Privacy policy.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Nút đồng ý
            ElevatedButton(
              onPressed: isChecked ? _agreeAndContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isChecked
                    ? const Color.fromARGB(255, 17, 105, 177)
                    : Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                "Agree & Continue",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
