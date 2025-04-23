import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _adController1 = NativeAdController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Danh sách các màn hình onboarding sử dụng hình ảnh có sẵn
  List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: "Just One Touch To Connect.",
      assetImage: "assets/images/image3.png", // Đường dẫn đến hình ảnh 1
      buttonText: "Next",
    ),
    OnboardingItem(
      title: "Diverse VPNs In Many Different Countries.",
      assetImage: "assets/images/image2.png", // Đường dẫn đến hình ảnh 2
      buttonText: "Next",
    ),
    OnboardingItem(
      title: "Protect Your Online Private",
      assetImage: "assets/images/image1.png", // Đường dẫn đến hình ảnh 3
      buttonText: "Get Start",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _adController1.ad = AdHelper.loadNativeAd1(adController: _adController1);

    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingItems.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    Container(
                      height: 400,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                onboardingItems[index].assetImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Text(
                            onboardingItems[index].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFFFFF)),
                          ),
                          SizedBox(height: 20),
                          // Đặt nút điều hướng và chấm trang thành hàng ngang
                          Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Chấm trang bên trái
                                Row(
                                  children: List.generate(
                                    onboardingItems.length,
                                    (i) => buildDot(i),
                                  ),
                                ),
                                // Nút Next bên phải
                                TextButton(
                                  onPressed: () {
                                    if (index == onboardingItems.length - 1) {
                                      Get.offAll(() => HomeScreen(),
                                          transition: Transition.fade,
                                          duration:
                                              Duration(milliseconds: 500));
                                      print("Bắt đầu ứng dụng");
                                    } else {
                                      _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeIn,
                                      );
                                    }
                                  },
                                  child: Text(
                                    onboardingItems[index].buttonText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF15E24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        //! boc lai obx
        return _adController1.ad != null && _adController1.adLoaded.isTrue
            ? SafeArea(
                child: SizedBox(
                  height: 350,
                  child: AdWidget(ad: _adController1.ad!),
                ),
              )
            : const SizedBox.shrink(); // Hoặc `null`, tùy vào bạn
      }),
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? const Color(0xFFF15E24) : Colors.grey,
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String assetImage; // Đường dẫn đến hình ảnh
  final String buttonText;

  OnboardingItem({
    required this.title,
    required this.assetImage,
    required this.buttonText,
  });
}