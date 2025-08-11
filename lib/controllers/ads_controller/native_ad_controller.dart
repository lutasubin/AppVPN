import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdController extends GetxController {
  NativeAd? ad;
  final adLoaded = false.obs;
  bool _daHuy = false; // Theo dõi trạng thái đã dispose

  // Getter để kiểm tra ad đã bị dispose chưa
  bool get isDisposed => _daHuy;

  /// Thiết lập ad mới
  void setAd(NativeAd newAd) {
    // Hủy ad cũ nếu có
    if (ad != null && !_daHuy) {
      ad!.dispose();
    }
    
    ad = newAd;
    adLoaded.value = true;
    _daHuy = false;
  }

  /// Hủy ad hiện tại
  void disposeAd() {
    if (ad != null && !_daHuy) {
      ad!.dispose();
    }
    ad = null;
    adLoaded.value = false;
    _daHuy = true;
  }

  /// Kiểm tra ad có sẵn sàng sử dụng không
  bool get isAdReady => ad != null && !_daHuy && adLoaded.value;

  /// Reset trạng thái controller
  void reset() {
    disposeAd();
    adLoaded.value = false;
    _daHuy = false;
  }

  @override
  void onClose() {
    disposeAd();
    super.onClose();
  }
}