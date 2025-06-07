import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/helpers/setting_languae.dart';
import 'package:vpn_basic_project/screens/first_screen.dart';

class LanguageScreen2 extends StatefulWidget {
  LanguageScreen2({super.key});

  @override
  State<LanguageScreen2> createState() => _LanguageScreen2State();
}

class _LanguageScreen2State extends State<LanguageScreen2> {
  final _adController4 = NativeAdController();
  final RxString selectedLanguage = Pref.selectedLanguage.obs;

  @override
  void initState() {
    super.initState();
    _adController4.ad = AdHelper.loadNativeAd2(adController: _adController4);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF02091A),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Language'.tr,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
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
                  // Đánh dấu đã xem onboarding
                  Pref.hasSeenOnboarding = true;
                  Get.offAll(() => OnboardingScreen());
                }
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF02091A),
        bottomNavigationBar: Obx(() {
          return _adController4.ad != null && _adController4.adLoaded.isTrue
              ? SafeArea(
                  child: SizedBox(
                    height: 120,
                    child: AdWidget(ad: _adController4.ad!),
                  ),
                )
              : const SizedBox.shrink();
        }),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
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
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    onTap: () {
                      selectedLanguage.value = language['code'];
                      Pref.selectedLanguage = language['code'];

                      // Cập nhật locale ngay khi chọn
                      if (language['code'] == 'default') {
                        Get.updateLocale(
                            Get.deviceLocale ?? const Locale('en'));
                      } else {
                        Get.updateLocale(Locale(language['code']));
                      }
                    },
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(language['flag']),
                    ),
                    title: Row(
                      children: [
                        Text(
                          language['name'],
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF15E24)
                              : Color(0xFFFFFFFF),
                          width: 2,
                        ),
                        color: isSelected
                            ? const Color(0xFFF15E24)
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}