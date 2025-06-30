import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

class SpeedTestController extends GetxController {
  final FlutterInternetSpeedTest speedTest = FlutterInternetSpeedTest();

  var downloadRate = 0.0.obs;
  var uploadRate = 0.0.obs;
  var displayRate = 0.0.obs;
  var displayProcess = 0.0.obs;
  var isTestingStarted = false.obs;

  /// ✅ Theo dõi giai đoạn hiện tại: download hoặc upload
  var currentTestType = Rxn<TestType>();

  var ip = RxnString();
  var isp = RxnString();
  var asn = RxnString();
  var country = RxnString();
  var unitText = 'Mb/s'.obs;

  var isButtonVisible = true.obs;

  /// ✅ Hàm bắt đầu đo tốc độ
  Future<void> startTesting() async {
    isTestingStarted.value = true;

    final completer = Completer<void>();

    try {
      speedTest.startTesting(
        useFastApi: true,
        onStarted: () {
          print('🚀 Speed test started');
          displayProcess.value = 0.0;
          currentTestType.value = TestType.download; // ✅ Bắt đầu với download
        },
        onProgress: (double percent, TestResult data) {
          displayProcess.value = percent;
          displayRate.value = data.transferRate;
          unitText.value = data.unit.name;
        },
        onDownloadComplete: (TestResult data) {
          print('✅ Download complete');
          downloadRate.value = data.transferRate;
          displayRate.value = data.transferRate;
          unitText.value = data.unit.name;

          /// ✅ Chuyển sang upload
          currentTestType.value = TestType.upload;
        },
        onUploadComplete: (TestResult data) {
          print('✅ Upload complete');
          uploadRate.value = data.transferRate;
          displayRate.value = data.transferRate;
          unitText.value = data.unit.name;
        },
        onCompleted: (TestResult download, TestResult upload) {
          print('🎉 Test completed');
          downloadRate.value = download.transferRate;
          uploadRate.value = upload.transferRate;
          displayRate.value = upload.transferRate;
          unitText.value = upload.unit.name;
          displayProcess.value = 100.0;
          isTestingStarted.value = false;

          completer.complete();
        },
        onError: (String errorMessage, String speedTestError) {
          print('❌ Speed test error: $errorMessage - $speedTestError');
          isTestingStarted.value = false;
          if (!completer.isCompleted) completer.complete();
        },
        onCancel: () {
          print('⚠️ Speed test cancelled');
          isTestingStarted.value = false;
          if (!completer.isCompleted) completer.complete();
        },
        onDefaultServerSelectionInProgress: () {
          print('🌐 Selecting default server...');
        },
        onDefaultServerSelectionDone: (Client? client) {
          print('🌐 Selected server: ${client?.ip}');
          if (client?.ip != null) {
            fetchIpDetails(client!.ip!);
          }
        },
      );
    } catch (e) {
      print('❗ Exception during speed test: $e');
      isTestingStarted.value = false;
      if (!completer.isCompleted) completer.complete();
    }

    return completer.future;
  }

  /// ✅ Gọi API ip-api.com để lấy thông tin IP, ISP, quốc gia...
  Future<void> fetchIpDetails(String ipAddr) async {
    try {
      final response = await Dio().get('http://ip-api.com/json/$ipAddr');
      if (response.statusCode == 200) {
        final data = response.data;
        ip.value = data['query'];
        isp.value = data['isp'];
        asn.value = data['as'];
        country.value = "${data['city']}, ${data['country']}";
      }
    } catch (e) {
      print('❗ Error fetching IP info: $e');
    }
  }

  /// ✅ Reset trạng thái trước khi test mới
  void resetValues() {
    downloadRate.value = 0.0;
    uploadRate.value = 0.0;
    displayRate.value = 0.0;
    displayProcess.value = 0.0;
    ip.value = null;
    isp.value = null;
    asn.value = null;
    country.value = null;
    unitText.value = 'Mb/s';
    isButtonVisible.value = true;
    currentTestType.value = null; // Hoặc TestType.download nếu muốn mặc định
  }
}
