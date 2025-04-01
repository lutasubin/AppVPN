import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/my_dilogs.dart';
import 'package:vpn_basic_project/helpers/mydilog2.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool _wasDisconnected = false; // Theo dõi trạng thái trước đó

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResults) {
    bool isDisconnected = connectivityResults.contains(ConnectivityResult.none);
    if (isDisconnected && !_wasDisconnected) {
      MyDialogs2.error(msg: 'error_connect_server'.tr);
    } else if (!isDisconnected && _wasDisconnected) {
      MyDialogs.success(msg: 'connection_restored'.tr);
    }
    _wasDisconnected = isDisconnected;
  }

  Future<bool> checkConnection() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
