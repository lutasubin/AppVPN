import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/controllers/location_controller.dart';

/// Class quản lý tất cả dependencies của ứng dụng
/// Đảm bảo các controller được khởi tạo trước khi app chạy
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Khởi tạo LocationController
    Get.put<LocationController>(LocationController(), permanent: true);

    // Khởi tạo LocalController
    Get.put<LocalController>(LocalController(), permanent: true);
  }
}
