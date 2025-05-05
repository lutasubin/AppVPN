import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF02091A), // Dark background color
        appBar: AppBar(
          backgroundColor: const Color(0xFF02091A), // AppBar background color
          // elevation: 0, // No shadow for AppBar
          leading: IconButton(
            onPressed: () => Get.back(), // Navigate back
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFFFFFF), // White color
              size: 25,
            ),
          ),
          title: Text(
            'Privacy Policy'.tr, // Title with localization support
            style: const TextStyle(
              color: Color(0xFFFFFFFF), // White text color
              fontSize: 20,
              fontWeight: FontWeight.w500, // Medium weight
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(26), // Padding for content
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the left
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: 'This Privacy Policy explains how '),
                    TextSpan(
                      text: 'AI VPN Fast & Safe',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const TextSpan(
                        text:
                            ' collects, uses, and protects your information, as well as your privacy rights when using the app.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: 'By using '),
                    TextSpan(
                      text: 'AI VPN Fast & Safe',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const TextSpan(
                        text:
                            ', you agree to the terms outlined in this Privacy Policy and our Terms of Use. This policy may be updated from time to time, and if significant changes occur, we will update the "last updated" date. Please check back regularly to stay informed about our latest policies.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Information We Collect',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'We are committed to protecting user privacy and '),
                    TextSpan(
                      text: 'DO NOT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const TextSpan(
                        text:
                            ' collect personally identifiable information or your browsing activity while using the VPN service. However, we may collect some non-personally identifiable data to improve our service, including:'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- Device type, operating system, and version.\n'
                '- Anonymous device identifiers.\n'
                '- Total amount of data transmitted through the VPN (without logging content).\n'
                '- VPN server IP address (not your real IP address).\n'
                '- App crash logs or error reports to enhance performance.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Information We DO NOT Collect:',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- Your real IP address.\n'
                '- Browsing history, accessed content, or search queries.\n'
                '- Personal data such as name, email address, or phone number.\n'
                '- Financial or payment data (except when purchasing a subscription through third-party payment platforms like Google Play or App Store).',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How We Collect Information',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(
                        text: 'Information may be collected in three ways:\n'),
                    TextSpan(
                      text: '1:Information You Provide',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const TextSpan(
                        text:
                            ': When you contact support or provide feedback about the app.\n'),
                    TextSpan(
                      text: '2:Automatically Collected Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const TextSpan(
                        text:
                            ': Technical data about your device and VPN performance.\n'),
                    TextSpan(
                      text: '3:Third-Party Sources',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const TextSpan(
                        text: ': Analytics providers or payment platforms.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sharing of Information',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: 'We '),
                    TextSpan(
                      text: 'DO NOT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const TextSpan(
                        text:
                            ' sell, trade, or share your personal data with any third parties for commercial purposes. However, we may share non-personally identifiable data with:\n'
                            '- Service providers for app performance analytics.\n'
                            '- Hosting and system maintenance partners.\n'
                            '- Law enforcement authorities if required by law.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Privacy Rights',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have the right to:\n'
                '- Request access, modification, or deletion of your personal data (if applicable).\n'
                '- Opt out of non-personal data collection.\n'
                '- Decline marketing emails or notifications.\n'
                '- Delete your account or related data if applicable.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Data Security',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We implement technical and organizational security measures to protect your data from unauthorized access, loss, or misuse. VPN-transmitted data is encrypted using high-security protocols.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Children’s Privacy',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This app is not intended for children under the age of 16. If you are under 16, please do not use our services.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Compliance with GDPR and International Laws',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: 'We comply with the '),
                    TextSpan(
                      text:
                          'General Data Protection Regulation (GDPR) of the EU',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const TextSpan(
                        text:
                            ', U.S. laws, and other international privacy regulations.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Contact Us',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'If you have any questions regarding privacy, please contact us via email: '),
                    TextSpan(
                      text: 'SpAiMobileTool@gmail.com',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
