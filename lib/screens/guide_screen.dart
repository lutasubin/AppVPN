import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/pref.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

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
          'Guide',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep(
              stepNumber: 1,
              title: 'Nơi danh sách VPN mà ứng dụng có thể kết nối',
              child: _buildLocationItem(
                flag: '🌐',
                name: 'Fastest Location',
                subtitle: 'IP address',
              ),
            ),
            const SizedBox(height: 24),
            _buildStep(
              stepNumber: 2,
              title: 'Chọn vị trí mà bạn cần kết nối',
              child: Column(
                children: [
                  _buildLocationItem(
                    flag: '🇨🇱',
                    name: 'Chile',
                    showSignal: true,
                  ),
                  _buildLocationItem(
                    flag: '🇦🇷',
                    name: 'Argentina',
                    showSignal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildStep(
              stepNumber: 3,
              title: 'Đang thiết lập kết nối',
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildConnectingCircle(),
                  const Text('Connecting...', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildStep(
              stepNumber: 4,
              title: 'Kết nối thành công',
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildConnectedCircle(),
                  const Text('Connected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required int stepNumber,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Step $stepNumber',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildLocationItem({
    required String flag,
    required String name,
    String? subtitle,
    bool showSignal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (showSignal)
            Icon(Icons.signal_cellular_alt, color: Colors.green[300]),
          const Icon(Icons.touch_app_outlined),
        ],
      ),
    );
  }

  Widget _buildConnectingCircle() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 15),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            '00:00:00',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          CircularProgressIndicator(
            value: 0.7,
            strokeWidth: 15,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[300]!),
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedCircle() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 15),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            '00:02:36',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange[300],
            ),
            child: const Icon(
              Icons.stop,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
