import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/images/image1.png',
      title: 'Just One Touch To Connect.',
    ),
    OnboardingData(
      image: 'assets/images/Frame 634360.png',
      title: 'Diverse VPNs In Many Different Countries.',
    ),
    OnboardingData(
      image: 'assets/images/image3.png',
      title: 'Protect Your Online Private',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAll(
        () => const  NativeFullScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return SafeArea(
      child: Scaffold(
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
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenSize.height * 0.1),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.all(screenSize.width * 0.05),
                          child: Image.asset(
                            _pages[index].image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.05),
                        child: Text(
                          _pages[index].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),
                      // Page indicators và Next button trên cùng 1 hàng
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Page indicators bên trái
                            Row(
                              children: List.generate(
                                _pages.length,
                                (dotIndex) => Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: _currentPage == dotIndex ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == dotIndex
                                        ? const Color(0xFFF15E24)
                                        : const Color(0xFFFFFFFF)
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            // Next button bên phải
                            TextButton(
                              onPressed: _nextPage,
                              child: Text(
                                'next'.tr,
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
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
            const NativeAdWithLoadingWidget(adType: 'medium'),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;

  OnboardingData({
    required this.image,
    required this.title,
  });
}