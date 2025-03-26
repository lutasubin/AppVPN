import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:vpn_basic_project/controllers/location_controller.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
// import 'package:vpn_basic_project/helpers/pref.dart';
import 'package:vpn_basic_project/main.dart';
import 'package:vpn_basic_project/widgets/vpn_cart.dart';

/// Màn hình hiển thị danh sách các vị trí VPN.
/// Cho phép người dùng xem và chọn VPN từ danh sách.
class LocationScreen extends StatelessWidget {
  /// Constructor cho LocationScreen.
  LocationScreen({super.key});

  /// Bộ điều khiển danh sách VPN.
  final LocationController _controller = Get.put(LocationController());

  /// Bộ điều khiển quảng cáo tự nhiên.
  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    // Tải dữ liệu VPN nếu danh sách rỗng
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    // Tải quảng cáo tự nhiên
    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFF02091A), // Mã màu nền chính
        appBar: AppBar(
          backgroundColor: const Color(0xFF02091A), // Mã màu thanh tiêu đề
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: const Color(0xFFFFFFFF),
              size: 25,
            ),
          ),
          title: Text(
            'Ip'.tr, // Tiêu đề dịch được
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _controller.getVpnData(); // Làm mới danh sách VPN
              },
              icon: const Icon(
                Icons.refresh, // Biểu tượng làm mới
                color: Color(0xFFFFFFFF),
                size: 25,
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            _adController.ad != null && _adController.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 85, child: AdWidget(ad: _adController.ad!)))
                : null,
        body: _controller.isLoading.value
            ? _loadingWidget(context) // Hiển thị khi đang tải
            : _controller.vpnList.isEmpty
                ? _noVPNFound(context) // Hiển thị khi không có VPN
                : _vpnData(), // Hiển thị danh sách VPN
      ),
    );
  }

  /// Tạo danh sách VPN dưới dạng ListView.
  /// Hiển thị từng VPN bằng widget VpnCart.
  Widget _vpnData() => ListView.builder(
        itemCount: _controller.vpnList.length,
        physics: BouncingScrollPhysics(), // Hiệu ứng cuộn mượt
        padding: EdgeInsets.only(
            top: mq.height * .015,
            bottom: mq.height * .1,
            left: mq.width * .04,
            right: mq.width * .04),
        itemBuilder: (ctx, i) => VpnCart(
          vpn: _controller.vpnList[i], // Truyền dữ liệu VPN cho widget
        ),
      );

  /// Widget hiển thị trạng thái đang tải với animation Lottie.
  /// [context] dùng để lấy thông tin màn hình.
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

  /// Widget hiển thị thông báo khi không tìm thấy VPN.
  /// [context] dùng để căn giữa nội dung.
  Widget _noVPNFound(BuildContext context) => Center(
        child: Text(
          'VPNs Not Found...😶'.tr, // Thông báo dịch được
          style: TextStyle(
            fontSize: 18,
            backgroundColor: const Color(0xFF02091A), // Mã màu nền
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
