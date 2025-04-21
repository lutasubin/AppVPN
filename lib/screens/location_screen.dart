import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:vpn_basic_project/controllers/location_controller.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/widgets/vpn_cart.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final LocationController _controller = Get.put(LocationController());
  final _adController2 = NativeAdController();

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
        body: _controller.isLoading.value
            ? _loadingWidget(context)
            : _controller.vpnList.isEmpty
                ? _noVPNFound(context)
                : _groupedVpnList(),
      ),
    );
  }

  Widget _groupedVpnList() {
    // Nhóm VPN theo quốc gia
    final Map<String, List<dynamic>> groupedVpns = {};

    for (var vpn in _controller.filteredVpnList) {
      if (!groupedVpns.containsKey(vpn.CountryLong)) {
        groupedVpns[vpn.CountryLong] = [vpn.CountryShort, <dynamic>[]];
      }
      groupedVpns[vpn.CountryLong]![1].add(vpn);
    }

    // Lấy danh sách các quốc gia với VPN của họ
    final countries = groupedVpns.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "👉 \"Each time you access, please reload to use a new VPN server.\"",
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              final countryInfo = groupedVpns[country]!;
              final countryCode = countryInfo[0].toString().toLowerCase();
              final vpnList = countryInfo[1] as List;

              return _buildCountrySection(country, countryCode, vpnList);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySection(
      String country, String countryCode, List vpnList) {
    return Obx(() {
      final isExpanded = _controller.isCountryExpanded(country);

      return Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Color(0xFF141C31),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header quốc gia có thể nhấp
            InkWell(
              onTap: () => _controller.toggleCountryExpansion(country),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage(
                        'assets/flags/$countryCode.png',
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      country,
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Color(0xFFFFFFFF),
                    ),
                  ],
                ),
              ),
            ),

            // Danh sách VPN của quốc gia - sử dụng VpnCart widget
            if (isExpanded) ...vpnList.map((vpn) => VpnCart(vpn: vpn)).toList(),
          ],
        ),
      );
    });
  }

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
