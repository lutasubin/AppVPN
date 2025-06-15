import 'dart:io';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vpn_basic_project/helpers/config.dart';

class NetworkController extends GetxController {
  var hasInternet = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkInitialConnectivity();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) async {
    try {
      final lookupResult = await InternetAddress.lookup('example.com');
      final isConnected =
          lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;

      if (!hasInternet.value && isConnected) {
        // 🔁 Khi có mạng trở lại
        Config.initConfig(); // tự động fetch lại remote config
      }
      hasInternet.value = isConnected;
    } catch (_) {
      hasInternet.value = false;
    }
  }
}
