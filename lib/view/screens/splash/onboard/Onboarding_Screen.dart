// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';
// import 'package:vpn_basic_project/view/screens/splash/onboard/Onboarding_Screen2.dart';

// class OnboardingScreen extends StatelessWidget {
//   const OnboardingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.height < 600;

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFF02091A),
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: screenSize.height * 0.1),
//             Expanded(
//               flex: 3,
//               child: Padding(
//                 padding: EdgeInsets.all(screenSize.width * 0.05),
//                 child: Image.asset(
//                   'assets/images/image1.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             Padding(
//               padding:
//                   EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
//               child: Text(
//                 'Just One Touch To Connect.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: isSmallScreen ? 16 : 20,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFFFFFFF),
//                 ),
//               ),
//             ),
//             SizedBox(height: screenSize.height * 0.03),
//             Padding(
//               padding:
//                   EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
//               child: Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Get.off(() => const OnboardingScreen2(),
//                         transition: Transition.fade,
//                         duration: const Duration(milliseconds: 300));
//                   },
//                   child: Text(
//                     'next'.tr,
//                     style: TextStyle(
//                       fontSize: isSmallScreen ? 14 : 16,
//                       color: const Color(0xFFF15E24),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // Native full occupies big area like screenshot
//             const NativeAdWithLoadingWidget(adType: 'medium'),
//           ],
//         ),
//       ),
//     );
//   }
// }
