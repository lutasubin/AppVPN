import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'PrivacyPolicy'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          // 📜 Nội dung chính
          SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Giới thiệu chính sách
              const Text(
                'This Privacy Policy explains how TurboFree VPN - Fast & Secure collects, uses, and protects your information, '
                'as well as your privacy rights when using the app.\n\n'
                'By using TurboFree VPN - Fast & Secure, you agree to the terms outlined in this Privacy Policy and our Terms of Use. '
                'This policy may be updated from time to time, and if significant changes occur, we will update the "last updated" date. '
                'Please check back regularly to stay informed about our latest policies.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6, // Giãn dòng dễ đọc hơn
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),
              _buildTitle('Information We Collect'),
              _buildParagraph(
                'We are committed to protecting user privacy and DO NOT collect personally identifiable information '
                'or your browsing activity while using the VPN service. However, we may collect some non-personally identifiable data to improve our service, including:\n\n'
                '- Device type, operating system, and version.\n'
                '- Anonymous device identifiers.\n'
                '- Total amount of data transmitted through the VPN (without logging content).\n'
                '- VPN server IP address (not your real IP address).\n'
                '- App crash logs or error reports to enhance performance.',
              ),

              const SizedBox(height: 24),
              _buildTitle('Information We DO NOT Collect'),
              _buildParagraph(
                '- Your real IP address.\n'
                '- Browsing history, accessed content, or search queries.\n'
                '- Personal data such as name, email address, or phone number.\n'
                '- Financial or payment data (except when purchasing a subscription through third-party payment platforms like Google Play or App Store).',
              ),

              const SizedBox(height: 24),
              _buildTitle('How We Collect Information'),
              _buildParagraph(
                'Information may be collected in three ways:\n\n'
                '1. Information You Provide: When you contact support or provide feedback about the app.\n'
                '2. Automatically Collected Information: Technical data about your device and VPN performance.\n'
                '3. Third-Party Sources: Analytics providers or payment platforms.',
              ),

              const SizedBox(height: 24),
              _buildTitle('Sharing of Information'),
              _buildParagraph(
                'We DO NOT sell, trade, or share your personal data with any third parties for commercial purposes. '
                'However, we may share non-personally identifiable data with:\n\n'
                '- Service providers for app performance analytics.\n'
                '- Hosting and system maintenance partners.\n'
                '- Law enforcement authorities if required by law.',
              ),

              const SizedBox(height: 24),
              _buildTitle('Your Privacy Rights'),
              _buildParagraph(
                'You have the right to:\n\n'
                '- Request access, modification, or deletion of your personal data (if applicable).\n'
                '- Opt out of non-personal data collection.\n'
                '- Decline marketing emails or notifications.\n'
                '- Delete your account or related data if applicable.',
              ),

              const SizedBox(height: 24),
              _buildTitle('Data Security'),
              _buildParagraph(
                'We implement technical and organizational security measures to protect your data from unauthorized access, loss, or misuse. '
                'VPN-transmitted data is encrypted using high-security protocols.',
              ),

              const SizedBox(height: 24),
              _buildTitle('Children’s Privacy'),
              _buildParagraph(
                'This app is not intended for children under the age of 16. If you are under 16, please do not use our services.',
              ),

              const SizedBox(height: 24),
              _buildTitle('Compliance with GDPR and International Laws'),
              _buildParagraph(
                'We comply with the General Data Protection Regulation (GDPR) of the EU, U.S. laws, and other international privacy regulations.',
              ),

              const SizedBox(height: 24),
              _buildTitle('Contact Us'),
              _buildParagraph(
                'If you have any questions regarding privacy, please contact us via email:\n\n'
                '📧 SpAiMobileTool@gmail.com',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 📌 Hàm hiển thị tiêu đề mục lớn
  Widget _buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// 📌 Hàm hiển thị đoạn văn nội dung
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.white70,
        ),
      ),
    );
  }
}
