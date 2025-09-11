import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/view/screens/home/home_screen.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

class NativeFullScreen extends StatelessWidget {
  const NativeFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        actions: [
          IconButton(
          onPressed: () {
            Get.off(() =>  HomeScreen(),
                transition: Transition.fade,
                duration: const Duration(milliseconds: 300));
          },
          icon: const Icon(Icons.close),
          color: Colors.white,
        ),
        ],
      ),
      body: const Center(child: NativeAdWithLoadingWidget(adType: 'full')),
    );
  }
}
