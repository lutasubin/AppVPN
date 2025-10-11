// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:vpn_basic_project/view/screens/welcome/welcome_screen.dart';
// import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

// class OnboardingScreen3 extends StatelessWidget {
//   const OnboardingScreen3({super.key});

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
//                   'assets/images/image3.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             Padding(
//               padding:
//                   EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
//               child: Text(
//                 'Protect Your Online Private',
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
//                     Get.offAll(() => const WelcomeScreen(),
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
//             const NativeAdWithLoadingWidget(adType: 'medium'),
//           ],
//         ),
//       ),
//     );
//   }
// }


