import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';

enum TestType { download, upload }

class SpeedTestController extends GetxController {
  var downloadRate = 0.0.obs;
  var uploadRate = 0.0.obs;
  var displayRate = 0.0.obs;
  var displayProcess = 0.0.obs;
  var isTestingStarted = false.obs;

  var currentTestType = Rxn<TestType>();

  
  var unitText = 'Mb/s'.obs;

  var isButtonVisible = true.obs;

  /// ✅ Bắt đầu test giả lập
  Future<void> startTesting() async {
    isTestingStarted.value = true;
    displayProcess.value = 0.0;
    unitText.value = 'Mb/s';

    currentTestType.value = TestType.download;
    await _simulateTest(isDownload: true);

    currentTestType.value = TestType.upload;
    await _simulateTest(isDownload: false);

    isTestingStarted.value = false;
  }

  Future<void> _simulateTest({required bool isDownload}) async {
    final completer = Completer<void>();
    final random = Random();

    // ⚙️ Sinh tốc độ tối đa 1 cách ngẫu nhiên
    final double maxRate = isDownload
        ? (20 + random.nextInt(51)).toDouble() // 20–70 Mbps
        : (10 + random.nextInt(21)).toDouble(); // 10–30 Mbps

    // 🕒 Thời gian test: ngẫu nhiên trong 6–12 giây
    final int durationSeconds = 6 + random.nextInt(7);
    final Duration tickInterval = const Duration(milliseconds: 100);
    final int tickCount =
        (durationSeconds * 1000) ~/ tickInterval.inMilliseconds;

    int currentTick = 0;

    Timer.periodic(tickInterval, (timer) {
      if (currentTick >= tickCount) {
        timer.cancel();
        if (isDownload) {
          downloadRate.value = displayRate.value;
        } else {
          uploadRate.value = displayRate.value;
        }
        completer.complete();
        return;
      }

      double t = currentTick / tickCount;

      // ✅ Curve tăng mượt dần (sigmoid-like)
      double baseRate = maxRate * (1 - exp(-4 * t)); // tăng mượt dần

      // 🔁 Dao động mượt: tổ hợp nhiều tần số
      double wave = sin(2 * pi * t * 1.5) * 0.5 +
          sin(2 * pi * t * 4.0) * 0.3 +
          sin(2 * pi * t * 7.0) * 0.2;

      // 📉 Nhiễu ngẫu nhiên nhẹ
      double noise = (random.nextDouble() - 0.5) * (maxRate * 0.03);

      // 💥 Kết hợp tất cả
      double rate =
          (baseRate + wave * maxRate * 0.1 + noise).clamp(0.0, maxRate);

      // 📊 Cập nhật hiển thị
      displayRate.value = rate;
      displayProcess.value = (currentTick / tickCount) * 100;

      currentTick++;
    });

    return completer.future;
  }

 

  /// ✅ Reset trạng thái
  void resetValues() {
    downloadRate.value = 0.0;
    uploadRate.value = 0.0;
    displayRate.value = 0.0;
    displayProcess.value = 0.0;
    unitText.value = 'Mb/s';
    isButtonVisible.value = true;
    currentTestType.value = null;
  }
}
