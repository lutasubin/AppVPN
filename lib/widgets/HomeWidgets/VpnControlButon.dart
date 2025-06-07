import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/controllers/network_controller.dart';
import 'package:vpn_basic_project/helpers/mydilog2.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/count_down_time.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/rotaltingcircle.dart';

class VpnControlButton extends StatefulWidget {
  final NetworkController networkController;
  final LocalController controller;
  final BoxConstraints constraints;

  const VpnControlButton({
    Key? key,
    required this.networkController,
    required this.controller,
    required this.constraints,
  }) : super(key: key);

  @override
  State<VpnControlButton> createState() => _VpnControlButtonState();
}

class _VpnControlButtonState extends State<VpnControlButton> {
  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.constraints.maxWidth * 0.5 > 220.0
        ? 220.0
        : widget.constraints.maxWidth * 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Nút kết nối VPN (ẩn nếu đã kết nối)
        Obx(() {
          final vpnState = widget.controller.vpnState.value;

          if (vpnState == VpnEngine.vpnConnected) {
            return const SizedBox.shrink();
          }

          final isConnecting = vpnState == VpnEngine.vpnConnecting ||
              vpnState == VpnEngine.vpnWaitConnection ||
              vpnState == VpnEngine.vpnAuthenticating;

          return Center(
            child: GestureDetector(
              onTap: () async {
                if (!await widget.networkController.checkConnection()) {
                  MyDialogs2.error(msg: 'error_connect_server'.tr);
                  return;
                }
                widget.controller.incrementConnectionAttempts(context);
                widget.controller.connectToVpn();
              },
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    isConnecting
                        ? RotatingGradientCircle(
                            size: buttonSize,
                            colors: const [
                              Color(0xFF4CAF50),
                              Color(0xFF1976D2)
                            ],
                          )
                        : Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.controller.getButtonGradient(),
                            ),
                          ),
                    Container(
                      margin: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF02091A),
                      ),
                      child: Center(
                        child: widget.controller.getButtonContent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        /// Bộ đếm thời gian khi đã kết nối
        Obx(() {
          if (widget.controller.vpnState.value == VpnEngine.vpnConnected) {
            return CountDownTimer(
              startTimer: true,
              onDurationChanged: (duration) {
                widget.controller.connectionDuration.value = duration;
              },
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 5),

        /// Nút Disconnect khi đã kết nối
        Obx(() {
          if (widget.controller.vpnState.value == VpnEngine.vpnConnected) {
            return Container(
              width: 140,
              height: 44,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF15E24), width: 1.5),
                color: Colors.transparent,
              ),
              child: MaterialButton(
                onPressed: () {
                  widget.controller.showDisconnectDialogWithAd();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'disconnect'.tr,
                  style: TextStyle(
                    color: const Color(0xFFF15E24),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
