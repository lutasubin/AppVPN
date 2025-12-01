import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/controllers/ads_controller/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ads/ad_helper.dart';

/// Widget hiển thị Native Ad với loading state
class NativeAdWithLoadingWidget extends StatefulWidget {
  final String adType; // 'small', 'medium', 'new1', 'new2', 'full'

  const NativeAdWithLoadingWidget({
    super.key,
    this.adType = 'small',
  });

  @override
  State<NativeAdWithLoadingWidget> createState() =>
      _NativeAdWithLoadingWidgetState();
}

class _NativeAdWithLoadingWidgetState extends State<NativeAdWithLoadingWidget> {
  final NativeAdController _adController = NativeAdController();
  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    switch (widget.adType) {
      case 'medium':
        _nativeAd = AdHelper.loadNativeAd1(adController: _adController);
        break;
      case 'full':
        _nativeAd = AdHelper.loadNativeAdFull(adController: _adController);
        break;
      case 'new1':
        _nativeAd = AdHelper.loadNativeAdNew(adController: _adController);
        break;
      case 'new2':
        _nativeAd = AdHelper.loadNativeAdNew2(adController: _adController);
        break;
      default:
        _nativeAd = AdHelper.loadNativeAd(adController: _adController);
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _adController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_adController.adLoaded.value) {
        // Loading state
        return Container(
          margin: widget.adType == 'full'
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: widget.adType == 'full'
              ? MediaQuery.of(context).size.height * 0.7
              : (widget.adType == 'medium' ? 350 : 120),
          decoration: BoxDecoration(
            color: const Color(0xFF172032),
            borderRadius:
                widget.adType == 'full' ? BorderRadius.zero : BorderRadius.circular(12),
             border: Border.all(
            // ignore: deprecated_member_use
            color: const Color(0xFFFFFFFF).withOpacity(0.05), // viền nhẹ
          ),
          ),
          child: const Center(
            child: Text(
              'Ads loading...',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        );
      }

      if (_nativeAd == null) {
        return const SizedBox.shrink();
      }

      final double height = widget.adType == 'full'
          ? MediaQuery.of(context).size.height * 0.7
          : (widget.adType == 'medium' ? 350 : 120);

      if (widget.adType == 'full') {
        return SizedBox(height: height, child: AdWidget(ad: _nativeAd!));
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(height: height, child: AdWidget(ad: _nativeAd!)),
        ),
      );
    });
  }
} 