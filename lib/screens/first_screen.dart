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

  List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: "Just One Touch To Connect.",
      assetImage: "assets/images/Frame 634360.png",
      buttonText: 'next'.tr,
    ),
    OnboardingItem(
      title: "Diverse VPNs In Many Different Countries.",
      assetImage: "assets/images/Frame 634360 (1).png",
      buttonText: "next".tr,
    ),
    OnboardingItem(
      title: "Protect Your Online Private",
      assetImage: "assets/images/Frame 634360 (2).png",
      buttonText: 'get_started'.tr,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _adController1.ad = AdHelper.loadNativeAd1(adController: _adController1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _adController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF02091A),
        body: Stack(
          children: [
            Column(
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
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: screenSize.height * 0.1),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(screenSize.width * 0.05),
                                  child: Image.asset(
                                    onboardingItems[index].assetImage,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenSize.width * 0.05),
                                child: Text(
                                  onboardingItems[index].title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.03),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                // Chấm điều hướng và nút
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          onboardingItems.length,
                          (i) => GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                i,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            child: buildDot(i, screenSize),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_currentPage == onboardingItems.length - 1) {
                            Get.offAll(() => HomeScreen(),
                                transition: Transition.fade,
                                duration: Duration(milliseconds: 500));
                          } else {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        child: Text(
                          onboardingItems[_currentPage].buttonText,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: const Color(0xFFF15E24),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar:
            //ads native
            Obx(() {
          return _adController1.ad != null && _adController1.adLoaded.isTrue
              ? SafeArea(
                  child: SizedBox(
                    height: 350,
                    child: AdWidget(ad: _adController1.ad!),
                  ),
                )
              : const SizedBox.shrink(); // Hoặc `null`, tùy vào bạn
        }),
      ),
    );
  }

  Widget buildDot(int index, Size screenSize) {
    final isSmallScreen = screenSize.height < 600;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
      height: isSmallScreen ? 6 : 8,
      width: isSmallScreen ? 6 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? const Color(0xFFF15E24) : Colors.grey,
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String assetImage;
  final String buttonText;

  OnboardingItem({
    required this.title,
    required this.assetImage,
    required this.buttonText,
  });
}
