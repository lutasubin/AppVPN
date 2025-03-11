import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/pref.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> languages = [
      {
        'code': 'default',
        'name': 'Default',
        'flag': 'assets/flags/default.png',
      },
      {
        'code': 'en',
        'name': 'English',
        'flag': 'assets/flags/UK.png',
      },
      {
        'code': 'hi',
        'name': 'Hindi',
        'flag': 'assets/flags/in.png',
      },
      {
        'code': 'ko',
        'name': 'Korean',
        'flag': 'assets/flags/kr.png',
      },
      {
        'code': 'pt',
        'name': 'Portuguese (Brazil)',
        'flag': 'assets/flags/br.png',
      },
      {
        'code': 'vi',
        'name': 'Vietnamese',
        'flag': 'assets/flags/vn.png',
      },
      {
        'code': 'ja',
        'name': 'Japanese',
        'flag': 'assets/flags/jp.png',
      },
      {
        'code': 'zh',
        'name': 'Chinese',
        'flag': 'assets/flags/cn.png',
      },
    ];

    final RxString selectedLanguage = Pref.selectedLanguage.obs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        title: Text(
          'Language'.tr,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: const Color(0xFF212121),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            final isSelected = selectedLanguage.value == language['code'] ||
                (language['code'] == 'default' &&
                    selectedLanguage.value.isEmpty);

            return Obx(() => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isSelected ? const Color(0xFFF15E24) : Colors.black12,
                      width: 2.0, // Tăng độ rộng viền để nổi bật hơn
                    ),
                    color: const Color(0xFF172032),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: RadioListTile<String>(
                    value: language['code'],
                    groupValue: selectedLanguage.value.isEmpty
                        ? 'default'
                        : selectedLanguage.value,
                    activeColor: const Color(
                        0xFFF15E24), // Thay đổi radio button thành màu vàng
                    title: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(language['flag']),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          language['name'],
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        selectedLanguage.value = value;
                        Pref.selectedLanguage = value;

                        if (value == 'default') {
                          Get.updateLocale(
                              Get.deviceLocale ?? const Locale('en'));
                        } else {
                          Get.updateLocale(Locale(value));
                        }
                        Get.snackbar(
                          'Success'.tr,
                          'Changed to'.tr + ' ${language['name']}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF172032),
                          colorText: const Color(0xFFFFFFFF),
                        );
                      }
                    },
                  ),
                ));
          },
        ),
      ),
    );
  }
}
