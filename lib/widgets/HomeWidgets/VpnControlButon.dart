import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/local_controller.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/count_down_time.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/disconnect_button.dart';
import 'package:vpn_basic_project/widgets/HomeWidgets/rotaltingcircle.dart';

class VpnControlButton extends StatefulWidget {
  final LocalController controller;
  final BoxConstraints constraints;

  const VpnControlButton({
    Key? key,
    required this.controller,
    required this.constraints,
  }) : super(key: key);

  @override
  State<VpnControlButton> createState() => _VpnControlButtonState();
}

class _VpnControlButtonState extends State<VpnControlButton> {
  // Biến trạng thái để bật/tắt hiệu ứng phát sáng
  bool _isGlowing = false;

  @override
  Widget build(BuildContext context) {
    // Tính kích thước nút, tối đa 220
    final buttonSize = widget.constraints.maxWidth * 0.5 > 220.0
        ? 220.0
        : widget.constraints.maxWidth * 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Nút kết nối VPN (ẩn nếu đã kết nối)
        Obx(() {
          final vpnState = widget.controller.vpnState.value;

          // Nếu đã kết nối VPN, nút kết nối ẩn đi
          if (vpnState == VpnEngine.vpnConnected) {
            return const SizedBox.shrink();
          }

          // Kiểm tra trạng thái đang kết nối để hiện hiệu ứng loading
          final isConnecting = vpnState == VpnEngine.vpnConnecting ||
              vpnState == VpnEngine.vpnWaitConnection ||
              vpnState == VpnEngine.vpnAuthenticating;

          return Center(
            child: GestureDetector(
              onTap: () {
                // Bật hiệu ứng phát sáng
                setState(() {
                  _isGlowing = true;
                });
                // Tắt hiệu ứng sau 400ms
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (mounted) {
                    setState(() {
                      _isGlowing = false;
                    });
                  }
                });

                // Gọi các hàm kết nối VPN từ controller
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
                    // Hiển thị vòng xoay nếu đang kết nối
                    isConnecting
                        ? RotatingGradientCircle(
                            size: buttonSize,
                            colors: const [
                              Color(0xFF4CAF50),
                              Color(0xFF1976D2),
                              Color(0xFF02091A),
                            ],
                          )
                        // Nếu không kết nối, hiện nút với hiệu ứng phát sáng
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.controller.getButtonGradient(),
                              // Hiệu ứng bóng phát sáng màu cyan
                              boxShadow: _isGlowing
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.cyanAccent.withOpacity(0.6),
                                        blurRadius: 20,
                                        spreadRadius: 8,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                    // Vòng tròn màu tối bên trong nút chứa icon/text
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

        /// Bộ đếm thời gian khi đã kết nối VPN
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

        /// Nút Disconnect khi đã kết nối VPN
        Obx(() {
          if (widget.controller.vpnState.value == VpnEngine.vpnConnected) {
            return DisconnectButton(
              onPressed: () {
                widget.controller.disconnectVpn();
              },
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
