import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/location/location_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/network/network_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/speed/speed_test_controller.dart';
import 'package:vpn_basic_project/controllers/main_controller/splash/splash_controller.dart';
// import 'package:vpn_basic_project/controllers/purchase_controller.dart';

/// Class quản lý tất cả dependencies của ứng dụng
/// Đảm bảo các controller được khởi tạo trước khi app chạy
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily create heavy controllers để tránh block splash
    Get.lazyPut<LocationController>(() => LocationController(), fenix: true);
    Get.lazyPut<LocalController>(() => LocalController(), fenix: true);
    Get.lazyPut<SpeedTestController>(() => SpeedTestController(), fenix: true);
    // Get.lazyPut<PurchaseController>(() => PurchaseController(), fenix: true);

    // Network controller cần chạy sớm để lấy trạng thái, nhưng defer check sang microtask
    final networkController =
        Get.put<NetworkController>(NetworkController(), permanent: true);
    Future.microtask(networkController.checkInitialConnectivity);

    // Splash controller vẫn init ngay vì là entry flow
    Get.put<SplashController>(SplashController());
  }
}