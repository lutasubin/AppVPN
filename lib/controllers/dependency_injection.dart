import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/network_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}