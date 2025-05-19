import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/controllers/location_controller.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
// import 'package:vpn_basic_project/widgets/LocationWidgets/vpn_card.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/vpn_card_highspeed.dart';
import 'package:vpn_basic_project/widgets/LocationWidgets/vpn_card_pro.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final LocationController _controller = Get.put(LocationController());
  final _adController2 = NativeAdController();

  final controller = Get.put(LocalController()); // Đảm bảo không bị lỗi null

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();
    _adController2.ad = AdHelper.loadNativeAd2(adController: _adController2);

    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFF0D1424),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1424),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFFFFFFFF), size: 25),
          ),
          title: Text(
            'VPN sever',
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _controller.getVpnData(),
              icon:
                  const Icon(Icons.refresh, color: Color(0xFFFFFFFF), size: 25),
            ),
          ],
        ),
        bottomNavigationBar:
            _adController2.ad != null && _adController2.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 120, child: AdWidget(ad: _adController2.ad!)))
                : null,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                "select_vpn_servers".tr,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              child: _controller.isLoading.value
                  ? _loadingWidget(context)
                  : _controller.vpnList.isEmpty
                      ? _noVPNFound(context)
                      : Column(
                          children: [
                            Expanded(flex: 3, child: _highSpeedVpn()),
                            Expanded(flex: 1, child: _highSpeedVpnPro()),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // // Thanh chọn chế độ hiển thị VPN
  // Widget _buildModeSelector() {
  //   return Obx(() => Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             GestureDetector(
  //                 onTap: () => _controller.isShareFreeMode.value = false,
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text(
  //                       'Fast speed',
  //                       style: TextStyle(
  //                         color: !_controller.isShareFreeMode.value
  //                             ? Color(0xFFFFFFFF)
  //                             : Color(0xFF767C8A),
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ],
  //                 )),
  //             Text('|',
  //                 style: TextStyle(color: Color(0xFF03C343), fontSize: 18)),
  //             GestureDetector(
  //               onTap: () => _controller.isShareFreeMode.value = true,
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     'Share free',
  //                     style: TextStyle(
  //                       color: _controller.isShareFreeMode.value
  //                           ? Color(0xFFFFFFFF)
  //                           : Color(0xFF767C8A),
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ));
  // }

// Nội dung chế độ "high speed", hiển thị theo nhóm quốc gia
  Widget _highSpeedVpn() {
    final Map<String, List<dynamic>> groupedVpns = {};

    for (var server in controller.availableServers) {
      final countryName =
          server.countryName; // hoặc server.countryLong tuỳ cấu trúc
      final countryCode = server.countryCode.toLowerCase(); // ví dụ: "us", "vn"

      if (!groupedVpns.containsKey(countryName)) {
        groupedVpns[countryName] = [countryCode, <dynamic>[]];
      }

      groupedVpns[countryName]![1].add(server);
    }

    final countries = groupedVpns.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        final countryInfo = groupedVpns[country]!;
        final countryCode = countryInfo[0];
        final vpnList = countryInfo[1];

        return _buildHighSpeedCountrySection(country, countryCode, vpnList);
      },
    );
  }

  Widget _buildHighSpeedCountrySection(
      String country, String countryCode, List vpnList) {
    return Obx(() {
      final isExpanded = _controller.isCountryExpanded(country);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141C31),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => _controller.toggleCountryExpansion(country),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage(
                        'assets/flags/$countryCode.png',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      country,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              ...vpnList.map((vpn) => VpnCardLocal(server: vpn)).toList(),
          ],
        ),
      );
    });
  }

  Widget _highSpeedVpnPro() {
    final Map<String, List<dynamic>> groupedVpns = {};

    for (var server in controller.availableServersPro) {
      final countryName =
          server.countryName; // hoặc server.countryLong tuỳ cấu trúc
      final countryCode = server.countryCode.toLowerCase(); // ví dụ: "us", "vn"

      if (!groupedVpns.containsKey(countryName)) {
        groupedVpns[countryName] = [countryCode, <dynamic>[]];
      }

      groupedVpns[countryName]![1].add(server);
    }

    final countries = groupedVpns.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        final countryInfo = groupedVpns[country]!;
        final countryCode = countryInfo[0];
        final vpnList = countryInfo[1];

        return _buildHighSpeedCountrySectionPro(country, countryCode, vpnList);
      },
    );
  }

  Widget _buildHighSpeedCountrySectionPro(
      String country, String countryCode, List vpnList) {
    return Obx(() {
      final isExpanded = _controller.isCountryExpanded(country);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141C31),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => _controller.toggleCountryExpansion(country),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage(
                        'assets/flags/$countryCode.png',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      "$country 👑",
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              ...vpnList.map((vpn) => VpnCardLocalPro(server: vpn)).toList(),
          ],
        ),
      );
    });
  }

  // // Nội dung chế độ "Share free", hiển thị theo nhóm quốc gia
  // Widget _freeVpnList() {
  //   final Map<String, List<dynamic>> groupedVpns = {};

  //   for (var vpn in _controller.filteredVpnList) {
  //     if (!groupedVpns.containsKey(vpn.CountryLong)) {
  //       groupedVpns[vpn.CountryLong] = [vpn.CountryShort, <dynamic>[]];
  //     }
  //     groupedVpns[vpn.CountryLong]![1].add(vpn);
  //   }

  //   final countries = groupedVpns.keys.toList();

  //   return Column(
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         child: Text(
  //           "👉 \"Each time you access, please reload to use a new VPN server.\"",
  //           style: const TextStyle(
  //             color: Color(0xFFFFFFFF),
  //             fontSize: 15,
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         child: ListView.builder(
  //           padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
  //           itemCount: countries.length,
  //           itemBuilder: (context, index) {
  //             final country = countries[index];
  //             final countryInfo = groupedVpns[country]!;
  //             final countryCode = countryInfo[0].toString().toLowerCase();
  //             final vpnList = countryInfo[1] as List;

  //             return _buildCountrySection(country, countryCode, vpnList);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCountrySection(
  //     String country, String countryCode, List vpnList) {
  //   return Obx(() {
  //     final isExpanded = _controller.isCountryExpanded(country);

  //     return Container(
  //       margin: EdgeInsets.only(bottom: 8),
  //       decoration: BoxDecoration(
  //         color: Color(0xFF141C31),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Column(
  //         children: [
  //           InkWell(
  //             onTap: () => _controller.toggleCountryExpansion(country),
  //             child: Container(
  //               padding: EdgeInsets.all(16),
  //               child: Row(
  //                 children: [
  //                   CircleAvatar(
  //                     radius: 15,
  //                     backgroundImage: AssetImage(
  //                       'assets/flags/$countryCode.png',
  //                     ),
  //                   ),
  //                   SizedBox(width: 15),
  //                   Text(
  //                     country,
  //                     style: TextStyle(
  //                       color: Color(0xFFFFFFFF),
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                   Spacer(),
  //                   Icon(
  //                     isExpanded
  //                         ? Icons.keyboard_arrow_up
  //                         : Icons.keyboard_arrow_down,
  //                     color: Color(0xFFFFFFFF),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           if (isExpanded) ...vpnList.map((vpn) => VpnCart(vpn: vpn)).toList(),
  //         ],
  //       ),
  //     );
  //   });
  // }

  Widget _loadingWidget(BuildContext context) => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/lottie/loading.json',
              width: 200,
            ),
          ],
        ),
      );

  Widget _noVPNFound(BuildContext context) => Center(
        child: Text(
          'VPNs Not Found...😶'.tr,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
