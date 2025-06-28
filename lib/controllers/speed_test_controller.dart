import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:get/get.dart';

class SpeedTestController extends GetxController {
  final FlutterInternetSpeedTest speedTest = FlutterInternetSpeedTest();

  var downloadRate = 0.0.obs;
  var uploadRate = 0.0.obs;
  var displayRate = 0.0.obs;
  var displayProcess = 0.0.obs;
  var isTestingStarted = false.obs;
  var isSeverSelectionInProgress = false.obs;
  var currentTestType = Rxn<TestType>();

  var ip = RxnString();
  var isp = RxnString();
  var asn = RxnString();
  var country = RxnString();
  var unitText = ''.obs;

  var isButtonVisible = true.obs;

  Future<void> startTesting() async {
    isTestingStarted.value = true;

    final completer = Completer<void>();

    speedTest.startTesting(
      onStarted: () {
        isTestingStarted.value = true;
        displayProcess.value = 0.0;
      },
      onCompleted: (download, upload) {
        unitText.value = download.unit == SpeedUnit.kbps ? 'Kb/s' : 'Mb/s';
        downloadRate.value = download.transferRate;
        uploadRate.value = upload.transferRate;
        displayProcess.value = 100.0;
        displayRate.value = uploadRate.value;
        isTestingStarted.value = false;

        completer.complete(); // 👈 báo cho Future biết là xong
      },
      onProgress: (percent, data) {
        unitText.value = data.unit == SpeedUnit.kbps ? 'Kb/s' : 'Mb/s';
        currentTestType.value = data.type;

        if (data.type == TestType.download) {
          downloadRate.value = data.transferRate;
          displayRate.value = downloadRate.value;
          displayProcess.value = percent;
        } else {
          uploadRate.value = data.transferRate;
          displayRate.value = uploadRate.value;
          displayProcess.value = percent;
        }
      },
      onError: (errorMessage, speedTestError) {
        print('Error: $errorMessage - $speedTestError');
        isTestingStarted.value = false;
        if (!completer.isCompleted) {
          completer.complete(); // cũng báo xong (để không bị treo app)
        }
      },
      onDefaultServerSelectionInProgress: () {
        isSeverSelectionInProgress.value = true;
      },
      onDefaultServerSelectionDone: (client) {
        isSeverSelectionInProgress.value = false;
        ip.value = client?.ip;
        asn.value = client?.asn;
        if (client?.ip != null && client!.ip!.isNotEmpty) {
          fetchIpDetails(client.ip!);
        }
      },
      onDownloadComplete: (data) {
        downloadRate.value = data.transferRate;
        displayRate.value = downloadRate.value;
      },
      onUploadComplete: (data) {
        uploadRate.value = data.transferRate;
        displayRate.value = uploadRate.value;
      },
    );

    return completer.future; // 👈 chờ tới khi onCompleted gọi complete()
  }

  Future<void> fetchIpDetails(String ipAddr) async {
    try {
      final response = await Dio().get('http://ip-api.com/json/$ipAddr');
      if (response.statusCode == 200) {
        final data = response.data;
        isp.value = data['isp'] ?? '';
        country.value = "${data['city']}, ${data['country']}";
      }
    } catch (e) {
      print('Error fetching IP details for $ipAddr: $e');
    }
  }

  void resetValues() {
    downloadRate.value = 0.0;
    uploadRate.value = 0.0;
    displayRate.value = 0.0;
    displayProcess.value = 0.0;
    ip.value = null;
    isp.value = null;
    asn.value = null;
    country.value = null;
    isButtonVisible.value = true;
    currentTestType.value = TestType.download;
  }
}
