import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/home_screen.dart';

class LanguageScreen2 extends StatelessWidget {
  const LanguageScreen2({super.key});

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
      {
        'code': 'fr',
        'name': 'French',
        'flag': 'assets/flags/fr.png',
      },
      {
        'code': 'es',
        'name': 'Spanish',
        'flag': 'assets/flags/es.png',
      },
      {
        'code': 'de',
        'name': 'German',
        'flag': 'assets/flags/de.png',
      },
      {
        'code': 'ru',
        'name': 'Russian',
        'flag': 'assets/flags/ru.png',
      },
      {
        'code': 'ss',
        'name': 'Arabic',
        'flag':
            'assets/flags/ae.png', // Cờ UAE cho tiếng Ả Rập (có thể thay đổi nếu cần)
      },
      {
        'code': 'da',
        'name': 'Danish',
        'flag': 'assets/flags/dk.png', // Cờ Đan Mạch
      },
      {
        'code': 'th',
        'name': 'Thailand',
        'flag': 'assets/flags/th.png', // Cờ Thái Lan
      },
      {
        'code': 'id',
        'name': 'Indonesian',
        'flag': 'assets/flags/id.png', // Cờ Indonesia
      },
      {
        'code': 'tr',
        'name': 'Turkish',
        'flag': 'assets/flags/tr.png', // Cờ Thổ Nhĩ Kỳ
      },
    ];

    // Khởi tạo selectedLanguage rỗng ban đầu
    final RxString selectedLanguage = Pref.selectedLanguage.obs;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Tắt nút thoát mặc định
        backgroundColor: const Color(0xFF02091A),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Language'.tr,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Color(0xFFFFFFFF),
              size: 25,
            ),
            onPressed: () {
              if (selectedLanguage.value.isNotEmpty) {
                Get.updateLocale(selectedLanguage.value == 'default'
                    ? (Get.deviceLocale ?? const Locale('en'))
                    : Locale(selectedLanguage.value));
                Get.offAll(() => HomeScreen());
              } else {
                Get.snackbar(
                  'Warning'.tr,
                  'Please select a language'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF172032),
                  colorText: const Color(0xFFFFFFFF),
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF02091A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];

            return Obx(() {
              final isSelected = selectedLanguage.value == language['code'];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF15E24)
                        : const Color(0xFF172032),
                    width: 2.0,
                  ),
                  color: const Color(0xFF172032),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: RadioListTile<String>(
                  value: language['code'],
                  groupValue: selectedLanguage.value,
                  activeColor: const Color(0xFFF15E24),
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
                      selectedLanguage.value = value; // Cập nhật giá trị
                      Pref.selectedLanguage = value; // Lưu vào Pref

                      // Cập nhật locale ngay khi chọn
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
              );
            });
          },
        ),
      ),
    );
  }
}
