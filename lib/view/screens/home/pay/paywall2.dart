// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:vpn_basic_project/screens/home_screen.dart';

// class PaywallPage2 extends StatefulWidget {
//   @override
//   _PaywallPageState createState() => _PaywallPageState();
// }

// class _PaywallPageState extends State<PaywallPage2> {
//   int selectedPlan = 0; // 0 = FREE, 1 = SUPER PRO

//   @override
//   Widget build(BuildContext context) {
//     final fakeProductPrice = '\$9.99';

//     return Scaffold(
//       backgroundColor: const Color(0xFF02091A),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF02091A),
//               Color(0xFF172032),
//               Color(0xFF02091A),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         // Title
//                         SvgPicture.asset('assets/svg/textpay.svg'),

//                         SizedBox(height: 30),

//                         // Benefits list
//                         Column(
//                           children: [
//                             _benefitTile("No Ads"),
//                             _benefitTile("Fast And Stable High Speed"),
//                             _benefitTile("Unlimited Traffic!"),
//                             _benefitTile("Money Back Guarantee!"),
//                             _benefitTile("No Time Limit"),
//                           ],
//                         ),

//                         SizedBox(height: 30),

//                         // FREE 3 Day plan
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               selectedPlan = 0;
//                             });
//                           },
//                           child: Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.all(20),
//                             margin: EdgeInsets.only(bottom: 12),
//                             decoration: BoxDecoration(
//                               color: selectedPlan == 0
//                                   ? Color(0xFF2A3B57)
//                                   : Color(0xFF1A2B47),
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: selectedPlan == 0
//                                     ? const Color(0xFFF15E24)
//                                     : const Color(0xFFF15E24).withOpacity(0.3),
//                                 width: selectedPlan == 0 ? 2 : 1,
//                               ),
//                             ),
//                             child: Stack(
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "FREE",
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFFFFFFFF),
//                                       ),
//                                     ),
//                                     Text(
//                                       "3 Day",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.white60,
//                                       ),
//                                     ),
//                                     SizedBox(height: 12),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           '5,99\$',
//                                           style: TextStyle(
//                                             color: Colors.white30,
//                                             decoration:
//                                                 TextDecoration.lineThrough,
//                                             decorationColor: Color(0xFFFFFFFF),
//                                             decorationThickness: 2,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                         Text(
//                                           '0,00\$',
//                                           style: TextStyle(
//                                             color: Color(0xFFFFFFFF),
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 // Selection indicator
//                                 if (selectedPlan == 0)
//                                   Positioned(
//                                     top: 0,
//                                     right: 0,
//                                     child: Container(
//                                       padding: EdgeInsets.all(4),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFFF15E24),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Icon(
//                                         Icons.check,
//                                         color: Color(0xFFFFFFFF),
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         // SUPER PRO plan
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               selectedPlan = 1;
//                             });
//                           },
//                           child: Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: selectedPlan == 1
//                                   ? Color(0xFF2A3B57)
//                                   : Color(0xFF1A2B47),
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: selectedPlan == 1
//                                     ? const Color(0xFFF15E24)
//                                     : Colors.transparent,
//                                 width: selectedPlan == 1 ? 2 : 1,
//                               ),
//                             ),
//                             child: Stack(
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "SUPER PRO",
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFFFFFFFF),
//                                       ),
//                                     ),
//                                     Text(
//                                       "3 Month",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.white60,
//                                       ),
//                                     ),
//                                     SizedBox(height: 12),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           '19,99\$',
//                                           style: TextStyle(
//                                             color: Colors.white30,
//                                             decoration:
//                                                 TextDecoration.lineThrough,
//                                             decorationColor: Color(0xFFFFFFFF),
//                                             decorationThickness: 2,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                         Text(
//                                           fakeProductPrice,
//                                           style: TextStyle(
//                                             color: Color(0xFFFFFFFF),
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 // Selection indicator
//                                 if (selectedPlan == 1)
//                                   Positioned(
//                                     top: 0,
//                                     right: 0,
//                                     child: Container(
//                                       padding: EdgeInsets.all(4),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFFF15E24),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Icon(
//                                         Icons.check,
//                                         color: Color(0xFFFFFFFF),
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         SizedBox(height: 20),

//                         // Subtitle text
//                         Text(
//                           "First 3-day free, then the plan auto-renews month.",
//                           style: TextStyle(
//                             color: Colors.white60,
//                             fontSize: 14,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),

//                         SizedBox(height: 30),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Bottom section with buttons
//                 Column(
//                   children: [
//                     // Continue button
//                     Container(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Get.offAll(() => HomeScreen());
//                         },
//                         child: Text(
//                           "CONTINUE",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFFFFFFFF),
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFF15E24),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 0,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 16),

//                     // Recurring billing text
//                     Text(
//                       "Recurring billing. Cancel anytime on Google Play Store.",
//                       style: TextStyle(
//                         color: Color(0xFFFFFFFF),
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _benefitTile(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Icon(
//             Icons.check_circle,
//             color: Colors.green,
//             size: 20,
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFFFFFFFF),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
