import 'dart:io';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vpn_basic_project/helpers/config.dart';

class NetworkController extends GetxController {
  var hasInternet = true.obs;
  final Connectivity _connectivity = Connectivity();
  late final Stream<ConnectivityResult> _connectivityStream;

  @override
  void onInit() {
    super.onInit();
    checkInitialConnectivity();

    // ✅ map từ List<ConnectivityResult> -> ConnectivityResult
    _connectivityStream = _connectivity.onConnectivityChanged.map((list) => list.first);
    _connectivityStream.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> checkInitialConnectivity() async {
    final resultList = await _connectivity.checkConnectivity();
    final result = resultList.first; // ✅ dùng phần tử đầu tiên
    await _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    try {
      final lookupResult = await InternetAddress.lookup('example.com');
      final isConnected =
          lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;

      if (!hasInternet.value && isConnected) {
        await Config.initConfig(); // Fetch lại config khi có mạng
      }

      hasInternet.value = isConnected;
    } catch (_) {
      hasInternet.value = false;
    }
  }
}
