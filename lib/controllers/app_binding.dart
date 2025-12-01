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
    // Khởi tạo LocationController
    Get.put<LocationController>(LocationController(), permanent: true);

    // Khởi tạo LocalController
    Get.put<LocalController>(LocalController(), permanent: true);

    //  Khởi tạo NetworkController
    final networkController =
        Get.put<NetworkController>(NetworkController(), permanent: true);

    // Gọi kiểm tra mạng ban đầu
    networkController.checkInitialConnectivity();

     // Khởi tạo SpeedTestController
    Get.put<SpeedTestController>(SpeedTestController(), permanent: true);

    //  // Khởi tạo PurchaseController (VIP)
    // Get.put<PurchaseController>(PurchaseController(), permanent: true);

     Get.put<SplashController>(SplashController());


  }
}
