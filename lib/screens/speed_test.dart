import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/controllers/speed_test_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/screens/speed_test_again.dart';

class SpeedTestScreen extends StatelessWidget {
  SpeedTestScreen({super.key});

  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    _adController.ad = AdHelper.loadNativeAd2(adController: _adController);

    final SpeedTestController controller = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02091A),
        title: const Text(
          'Speed Test',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            controller.resetValues();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (_adController.ad != null && _adController.adLoaded.isTrue) {
          return SafeArea(
            child:
                SizedBox(height: 120, child: AdWidget(ad: _adController.ad!)),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            Obx(() => LinearPercentIndicator(
                  backgroundColor: Color(0xFF172032),
                  percent: controller.displayProcess.value / 100.0,
                  lineHeight: 18,
                  center: Text(
                    "${controller.displayProcess.value.toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  barRadius: const Radius.circular(10),
                  linearGradient: const LinearGradient(
                    colors: [
                      Color(0xFF2484F1),
                      Color(0xFF00E5FF),
                      Color(0xFF15EDB3),
                    ],
                  ),
                )),
            const SizedBox(height: 10),

            // Gauge
            Obx(() => _buildGauge(controller)),

            const SizedBox(height: 20),

            // Info Card
            Obx(() => _buildInfoCard(controller)),

            const SizedBox(height: 30),

            // Start Button
            _buildButtons(controller),
          ],
        ),
      ),
    );
  }

//button
  Widget _buildButtons(SpeedTestController controller) {
    return Obx(() {
      return controller.isButtonVisible.value
          ? GestureDetector(
              onTap: () async {
                controller.isButtonVisible.value = false; // Ẩn nút
                await controller.startTesting();
                Get.off(() => SpeedTestAgain());
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF15EDB3),
                      Color(0xFF2484F1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'START SPEED TEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            )
          : const SizedBox(); // Trả về widget rỗng khi nút ẩn
    });
  }

  // Gauge Widget
  Widget _buildGauge(SpeedTestController controller) {
    final isDownload = controller.currentTestType.value == 'download';

    return SfRadialGauge(
      axes: [
        RadialAxis(
          startAngle: 135,
          endAngle: 45,
          radiusFactor: 0.9,
          minimum: 0,
          maximum: 100,
          interval: 15, // hiển thị số cách nhau 10 đơn vị
          showTicks: true, // hiện vạch nhỏ
          showLabels: true, // hiện số
          majorTickStyle: const MajorTickStyle(
            length: 8,
            thickness: 2,
            color: Colors.white,
          ),
          minorTicksPerInterval: 0,
          axisLabelStyle: const GaugeTextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          axisLineStyle: const AxisLineStyle(
            thickness: 15,
            cornerStyle: CornerStyle.bothCurve,
            color: Color(0xFF172032), // phần chưa chạy
          ),
          pointers: [
            RangePointer(
              value: controller.displayRate.value.clamp(0, 100),
              width: 15,
              cornerStyle: CornerStyle.bothCurve,
              gradient: const SweepGradient(
                colors: [
                  Color(0xFF2484F1),
                  Color(0xFF00E5FF),
                  Color(0xFF15EDB3),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            NeedlePointer(
              value: controller.displayRate.value.clamp(0, 100),
              enableAnimation: true,
              needleLength: 0.6, // dài hơn 1 chút
              needleStartWidth: 4, // đầu gốc to
              needleEndWidth: 9, // đầu kim nhỏ lại
              needleColor: Colors.white, // Màu trắng làm base
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white54,
                  Colors.white,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              knobStyle: const KnobStyle(
                color: Colors.transparent, // làm trong suốt
                borderWidth: 0,
                knobRadius: 0.06,
              ),
            )
          ],
          annotations: [
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.8,
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isDownload ? 'Download speed' : 'Upload speed',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${controller.displayRate.value.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Mbps",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Info Card Widget
  Widget _buildInfoCard(SpeedTestController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSpeedColumn(Icons.arrow_downward_rounded, 'Download'.tr,
                  controller.downloadRate.value.toStringAsFixed(2)),
              _buildSpeedColumn(Icons.arrow_upward_rounded, 'Uploads'.tr,
                  controller.uploadRate.value.toStringAsFixed(2)),
            ],
          )
        ],
      ),
    );
  }

  // Download/Upload Column
  Widget _buildSpeedColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon,
                color: icon == Icons.arrow_downward_rounded
                    ? const Color(0xFF03C343)
                    : const Color(0xFF4684F6)),
            const SizedBox(width: 5),
            Text(
              '$label Mbps',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
