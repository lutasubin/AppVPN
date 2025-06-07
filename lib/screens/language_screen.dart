import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/helpers/setting_languae.dart';

class LanguageScreen extends StatelessWidget {
  final _adController1 = NativeAdController();

  LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _adController1.ad = AdHelper.loadNativeAd1(adController: _adController1);
    final RxString selectedLanguage = Pref.selectedLanguage.obs;

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
                Get.back();
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF02091A),
        bottomNavigationBar: Obx(() {
          return _adController1.ad != null && _adController1.adLoaded.isTrue
              ? SafeArea(
                  child: SizedBox(
                    height: 350,
                    child: AdWidget(ad: _adController1.ad!),
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
                final isSelected = selectedLanguage.value == language['code'] ||
                    (language['code'] == 'default' &&
                        selectedLanguage.value.isEmpty);

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

                      // Track language change event
                      AnalyticsHelper.logSettingChange('language_change',
                          language['code'] == 'default' ? 'default' : language['code']);

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