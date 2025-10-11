import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/view/screens/home/check_Ip/network_test_screen.dart';
import 'package:vpn_basic_project/view/widgets/Ads/native_ads_widget.dart';

class NativeFullScreen1 extends StatefulWidget {
  const NativeFullScreen1({super.key});

  @override
  State<NativeFullScreen1> createState() => _NativeFullScreenState1();
}

class _NativeFullScreenState1 extends State<NativeFullScreen1> {
  bool _showClose = false;
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Đếm ngược 5s
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.1 / 5; // mỗi 100ms tăng thêm (0.1/5) = 0.02
        if (_progress >= 1.0) {
          _progress = 1.0;
          _showClose = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goHome() {
    Get.off(() =>  NetworkTestScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _showClose
                ? IconButton(
                    onPressed: _goHome,
                    icon: const Icon(Icons.close, color: Colors.white),
                  )
                : SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 3,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
          ),
        ],
      ),
      body: const Center(
        child: NativeAdWithLoadingWidget(adType: 'full'),
      ),
    );
  }
}
