import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/pref.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pref.isDartMode ? null : Colors.orange,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'About us',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.vpn_key_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 12),
            // Version
            const Text(
              'Version: 1.0.1',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // Terms of Service
            ListTile(
              title: const Text('Term of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to Terms of Service
              },
            ),
            const Divider(),
            // Privacy Policy
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to Privacy Policy
              },
            ),
          ],
        ),
      ),
    );
  }
}
