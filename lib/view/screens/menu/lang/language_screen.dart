import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';
import 'package:vpn_basic_project/helpers/Firebase_Analytics/analytics_helper.dart';
import 'package:vpn_basic_project/helpers/Hive/pref.dart';
import 'package:vpn_basic_project/helpers/lang/setting_languae.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart'
    show NativeAdWithLoadingWidget;

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                color: Color(0xFF3FD8EF),
                size: 25,
              ),
              onPressed: () {
                AdHelper.showInterstitialAd(onComplete: () {
                  Get.back();
                });
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF02091A),
        bottomNavigationBar:
            const SafeArea(child: NativeAdWithLoadingWidget(adType: 'medium')),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];

              return Obx(() {
                final isSelected = selectedLanguage.value == language['code'] ||
                    (language['code'] == 'default' &&
                        selectedLanguage.value.isEmpty);

                return InkWell(
                  onTap: () {
                    selectedLanguage.value = language['code'];
                    Pref.selectedLanguage = language['code'];

                    // Track language change event
                    AnalyticsHelper.logSettingChange(
                        'language_change',
                        language['code'] == 'default'
                            ? 'default'
                            : language['code']);

                    if (language['code'] == 'default') {
                      Get.updateLocale(
                          Get.deviceLocale ?? const Locale('en'));
                    } else {
                      Get.updateLocale(Locale(language['code']));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3FD8EF)
                            : const Color(0xFF172032),
                        width: 2.0,
                      ),
                      color: const Color(0xFF172032),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage(language['flag']),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            language['name'],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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