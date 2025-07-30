import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdController extends GetxController {
  NativeAd? ad;
  final adLoaded = false.obs;
  bool isDisposed = false;

  void setAd(NativeAd newAd) {
    ad = newAd;
    adLoaded.value = true;
    isDisposed = false;
  }

  void disposeAd() {
    ad?.dispose();
    ad = null;
    adLoaded.value = false;
    isDisposed = true;
  }
}
