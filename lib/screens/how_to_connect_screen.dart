import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/screens/home_screen.dart';

class HowToConnectScreen extends StatelessWidget {
  const HowToConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>  Get.to(() => HomeScreen()),
        ),
        title: const Text('How to connect'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildGuideItem(
              '1. Choose Server',
              'Select a VPN server from the available locations list at the bottom of the screen',
              'assets/images/server_selection.png',
            ),
            _buildGuideItem(
              '2. Connect VPN',
              'Tap the power button in the center of the screen to start VPN connection',
              'assets/images/connect_button.png',
            ),
            _buildGuideItem(
              '3. Confirm Connection',
              'When connected, you\'ll see the timer running and connection speed indicators',
              'assets/images/connected_status.png',
            ),
            _buildGuideItem(
              '4. Disconnect',
              'To disconnect, tap the square button in the center or use the disconnect dialog',
              'assets/images/disconnect_dialog.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String title, String description, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          // Nếu bạn muốn thêm hình ảnh hướng dẫn:
          // Image.asset(
          //   imagePath,
          //   width: double.infinity,
          //   height: 200,
          //   fit: BoxFit.cover,
          // ),
        ],
      ),
    );
  }
}
