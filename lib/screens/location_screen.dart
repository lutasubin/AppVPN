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

/// Màn hình hiển thị danh sách máy chủ VPN
class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  // Khởi tạo controller cho màn hình Location
  final LocationController _controller = Get.put(LocationController());

  // Khởi tạo controller cho quảng cáo native
  final _adController2 = NativeAdController();

  // Khởi tạo controller local để quản lý dữ liệu máy chủ
  final controller = Get.put(LocalController()); // Đảm bảo không bị lỗi null

  @override
  Widget build(BuildContext context) {
    // Nếu danh sách VPN trống, lấy dữ liệu VPN từ API
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    // Nạp quảng cáo native
    _adController2.ad = AdHelper.loadNativeAd2(adController: _adController2);

    // Sử dụng Obx để theo dõi thay đổi trạng thái
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFF0D1424),
        // Thiết lập thanh app bar
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1424),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFFFFFFFF), size: 25),
          ),
          title: Text(
            'sever'.tr,
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            // Nút làm mới dữ liệu VPN
            IconButton(
              onPressed: () => _controller.getVpnData(),
              icon:
                  const Icon(Icons.refresh, color: Color(0xFFFFFFFF), size: 25),
            ),
          ],
        ),
        // Thanh điều hướng dưới cùng hiển thị quảng cáo nếu có
        bottomNavigationBar:
            _adController2.ad != null && _adController2.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 120, child: AdWidget(ad: _adController2.ad!)))
                : null,
        // Nội dung chính của màn hình
        body: SafeArea(
          child: Column(
            children: [
              // Hiển thị tiêu đề "Chọn máy chủ VPN"
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
              // Phần nội dung chính, tùy thuộc vào trạng thái
              Expanded(
                child: _controller.isLoading.value
                    ? _loadingWidget(context) // Hiển thị hoạt ảnh đang tải
                    : _controller.vpnList.isEmpty
                        ? _noVPNFound(
                            context) // Hiển thị thông báo không tìm thấy VPN
                        : _buildCombinedListView(), // Hiển thị danh sách VPN
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Phương thức kết hợp cả hai danh sách VPN thành một ListView duy nhất
  Widget _buildCombinedListView() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      children: [
        // Phần VPN tốc độ cao
        _buildHighSpeedVpnContent(),
        // Phần VPN cao cấp
        _buildHighSpeedVpnProContent(),
      ],
    );
  }

  /// Phương thức trả về nội dung VPN tốc độ cao mà không sử dụng ListView.builder
  Widget _buildHighSpeedVpnContent() {
    // Nhóm các máy chủ VPN theo quốc gia
    final Map<String, List<dynamic>> groupedVpns = {};

    // Lặp qua danh sách máy chủ có sẵn và nhóm chúng theo quốc gia
    for (var server in controller.availableServers) {
      final countryName = server.countryName;
      final countryCode = server.countryCode.toLowerCase();

      // Nếu quốc gia chưa có trong map, thêm vào với mảng trống
      if (!groupedVpns.containsKey(countryName)) {
        groupedVpns[countryName] = [countryCode, <dynamic>[]];
      }

      // Thêm máy chủ vào mảng của quốc gia tương ứng
      groupedVpns[countryName]![1].add(server);
    }

    // Lấy danh sách tên quốc gia
    final countries = groupedVpns.keys.toList();

    // Trả về các phần tử được nhóm theo quốc gia trong một Column
    return Column(
      children: countries.map((country) {
        final countryInfo = groupedVpns[country]!;
        final countryCode = countryInfo[0];
        final vpnList = countryInfo[1];

        return _buildHighSpeedCountrySection(country, countryCode, vpnList);
      }).toList(),
    );
  }

  /// Phương thức trả về nội dung VPN cao cấp mà không sử dụng ListView.builder
  Widget _buildHighSpeedVpnProContent() {
    // Nhóm các máy chủ VPN Pro theo quốc gia
    final Map<String, List<dynamic>> groupedVpns = {};

    // Lặp qua danh sách máy chủ Pro có sẵn và nhóm chúng theo quốc gia
    for (var server in controller.availableServersPro) {
      final countryName = server.countryName;
      final countryCode = server.countryCode.toLowerCase();

      // Nếu quốc gia chưa có trong map, thêm vào với mảng trống
      if (!groupedVpns.containsKey(countryName)) {
        groupedVpns[countryName] = [countryCode, <dynamic>[]];
      }

      // Thêm máy chủ pro vào mảng của quốc gia tương ứng
      groupedVpns[countryName]![1].add(server);
    }

    // Lấy danh sách tên quốc gia
    final countries = groupedVpns.keys.toList();

    // Trả về các phần tử được nhóm theo quốc gia trong một Column
    return Column(
      children: countries.map((country) {
        final countryInfo = groupedVpns[country]!;
        final countryCode = countryInfo[0];
        final vpnList = countryInfo[1];

        return _buildHighSpeedCountrySectionPro(country, countryCode, vpnList);
      }).toList(),
    );
  }

  /// Tạo phần hiển thị cho một quốc gia trong danh sách VPN tốc độ cao
  Widget _buildHighSpeedCountrySection(
      String country, String countryCode, List vpnList) {
    return Obx(() {
      // Kiểm tra xem phần của quốc gia này có đang mở rộng không
      final isExpanded = _controller.isCountryExpanded(country);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141C31),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Phần header có thể nhấn để mở rộng/thu gọn
            InkWell(
              onTap: () => _controller.toggleCountryExpansion(country),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Hiển thị cờ quốc gia
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage(
                        'assets/flags/$countryCode.png',
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Hiển thị tên quốc gia
                    Text(
                      country,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Icon mũi tên chỉ trạng thái mở rộng/thu gọn
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
            // Nếu đang mở rộng, hiển thị danh sách máy chủ VPN của quốc gia đó
            if (isExpanded)
              ...vpnList.map((vpn) => VpnCardLocal(server: vpn)).toList(),
          ],
        ),
      );
    });
  }

  /// Tạo phần hiển thị cho một quốc gia trong danh sách VPN cao cấp
  Widget _buildHighSpeedCountrySectionPro(
      String country, String countryCode, List vpnList) {
    return Obx(() {
      // Kiểm tra xem phần của quốc gia này có đang mở rộng không
      final isExpanded = _controller.isCountryExpanded(country);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141C31),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Phần header có thể nhấn để mở rộng/thu gọn
            InkWell(
              onTap: () => _controller.toggleCountryExpansion(country),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Hiển thị cờ quốc gia
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage(
                        'assets/flags/$countryCode.png',
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Hiển thị tên quốc gia với biểu tượng vương miện
                    Text(
                      country,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Icon mũi tên chỉ trạng thái mở rộng/thu gọn
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
            // Nếu đang mở rộng, hiển thị danh sách máy chủ VPN Pro của quốc gia đó
            if (isExpanded)
              ...vpnList.map((vpn) => VpnCardLocalPro(server: vpn)).toList(),
          ],
        ),
      );
    });
  }

  /// Widget hiển thị khi đang tải dữ liệu
  Widget _loadingWidget(BuildContext context) => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị hoạt ảnh loading từ tệp Lottie
            LottieBuilder.asset(
              'assets/lottie/loading.json',
              width: 200,
            ),
          ],
        ),
      );

  /// Widget hiển thị khi không tìm thấy máy chủ VPN nào
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
