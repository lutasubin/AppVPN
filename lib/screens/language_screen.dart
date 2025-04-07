import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/screens/watch_ad_dialog.dart';

class LanguageScreen extends StatelessWidget {
  final _adController1 = NativeAdController();

  LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _adController1.ad = AdHelper.loadNativeAd1(adController: _adController1);

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
      {
        'code': 'ss',
        'name': 'Arabic',
        'flag':
            'assets/flags/ae.png', // Cờ UAE cho tiếng Ả Rập (có thể thay đổi nếu cần)
      },
    ];

    final RxString selectedLanguage = Pref.selectedLanguage.obs;

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Tắt nút thoát mặc định
          backgroundColor: const Color(0xFF02091A), // Mã màu mới
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
                // Get.dialog(WatchAdDialog(onComplete: () {
                //   AdHelper.showRewardedAd(onComplete: () {
                //     // Get.back();
                //   });
                // }));
                Get.back();
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF02091A),
        bottomNavigationBar:
            // Config.hideAds ? null:
            _adController1.ad != null && _adController1.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 350, child: AdWidget(ad: _adController1.ad!)))
                : null,
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
                        color: isSelected
                            ? const Color(0xFFF15E24)
                            : const Color(0xFF172032),
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
                          // Get.snackbar(
                          //   'Success'.tr,
                          //   'Changed to'.tr + ' ${language['name']}',
                          //   snackPosition: SnackPosition.BOTTOM,
                          //   backgroundColor: const Color(0xFF172032),
                          //   colorText: const Color(0xFFFFFFFF),
                          // );
                        }
                      },
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }
}
