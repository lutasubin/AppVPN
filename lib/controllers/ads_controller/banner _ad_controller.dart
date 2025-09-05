import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdController extends GetxController {
  BannerAd? ba;
  final baLoaded = false.obs;

  /// Gán BannerAd từ AdHelper
  void setBannerAd(BannerAd ad) {
    ba = ad;
    baLoaded.value = true;
  }

  /// Hủy banner khi controller bị dispose
  @override
  void onClose() {
    ba?.dispose();
    super.onClose();
  }
}
