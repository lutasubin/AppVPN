// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:vpn_basic_project/controllers/location_controller.dart';
// // import 'package:vpn_basic_project/helpers/pref.dart';
// import 'package:vpn_basic_project/screens/home_screen.dart';
// import 'package:vpn_basic_project/widgets/vpn_cart.dart';

// class SearchScreen extends StatelessWidget {
//   final LocationController _controller = Get.find<LocationController>();
//   final TextEditingController _searchController = TextEditingController();

//   Widget _noResultsFound() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset('assets/svg/webpage-not-found 1.svg'),
//           SizedBox(height: 20),
//           Text(
//             'No results found for'.tr + '${_searchController.text}',
//             style: TextStyle(
//               fontSize: 18,
//               color: const Color(0xFFFFFFFF),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF02091A), // Mã màu mới
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF02091A), // Mã màu mới
//         title: Text(
//           'Search VPN',
//           style: TextStyle(
//             color: const Color(0xFFFFFFFF),
//           ),
//         ),
//         leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back,
//               color: const Color(0xFFFFFFFF),
//               size: 25,
//             ),
//             onPressed: () => Get.offAll(() => HomeScreen())),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 style: TextStyle(color: Color(0XFFFFFFFF)),
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                     hintText: 'Enter location...',
//                     border: OutlineInputBorder(),
//                     hintStyle: TextStyle(
//                       color: Color(0xFF767C8A),
//                     )),
//                 onChanged: (value) {
//                   _controller.filterVpnList(value);
//                 },
//               ),
//             ),
//             Obx(() {
//               final filteredList = _controller.filteredVpnList;
//               return filteredList.isNotEmpty
//                   ? ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: filteredList.length,
//                       itemBuilder: (ctx, i) => GestureDetector(
//                         onTap: () {
//                           Get.off(() => HomeScreen());
//                         },
//                         child: VpnCart(
//                           vpn: filteredList[i],
//                         ),
//                       ),
//                     )
//                   : _noResultsFound();
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }
