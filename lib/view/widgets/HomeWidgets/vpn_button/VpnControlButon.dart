import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/main_controller/home/home_controller.dart';
import 'package:vpn_basic_project/services/vpn_engine.dart';
import 'package:vpn_basic_project/view/widgets/HomeWidgets/count_downt_time/count_down_time.dart';
import 'package:vpn_basic_project/view/widgets/HomeWidgets/vpn_button/disconnect_button.dart';
import 'package:vpn_basic_project/view/widgets/HomeWidgets/vpn_button/rotaltingcircle.dart';

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
          final vpnState = widget.controller.vpnState;

          // Nếu đã kết nối VPN, nút kết nối ẩn đi
          if (vpnState == VpnEngine.vpnConnected) {
            return const SizedBox.shrink();
          }

          // ✅ SỬA LẠI: Kiểm tra trạng thái đang kết nối cho cả OpenVPN và WireGuard
          final isConnecting = _isInConnectingState(vpnState);

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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: isConnecting
                              ? RotatingGradientCircle(
                                  key: const ValueKey('rotating'),
                                  size: buttonSize,
                                  colors: const [
                                    Color(0xFF02091A),
                                    Color(0xFF15EDB3),
                                    Color(0xFF2484F1),
                                  ],
                                )
                              : AnimatedScale(
                                  scale: _isGlowing ? 0.95 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: buttonSize,
                                    height: buttonSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient:
                                          widget.controller.getButtonGradient(),
                                      boxShadow: _isGlowing
                                          ? [
                                              BoxShadow(
                                                color: Colors.cyanAccent
                                                    // ignore: deprecated_member_use
                                                    .withOpacity(0.6),
                                                blurRadius: 20,
                                                spreadRadius: 8,
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),

                    // Vòng tròn màu tối bên trong nút chứa icon/text
                    Container(
                      margin: const EdgeInsets.all(15),
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
          if (widget.controller.vpnState == VpnEngine.vpnConnected) {
            return CountDownTimer(
              startTimer: true,
              onDurationChanged: (duration) {
                widget.controller.connectionDuration = duration;
              },
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 5),

        /// Nút Disconnect khi đã kết nối VPN
        Obx(() {
          if (widget.controller.vpnState == VpnEngine.vpnConnected) {
            return DisconnectButton(
              onPressed: () {
                widget.controller.showDisconnectDialogWithAd();
              },
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  /// ✅ THÊM MỚI: Kiểm tra trạng thái đang kết nối cho cả OpenVPN và WireGuard
  bool _isInConnectingState(String vpnState) {
    // Kiểm tra trạng thái OpenVPN
    final isOpenVpnConnecting = vpnState == VpnEngine.vpnConnecting ||
        vpnState == VpnEngine.vpnWaitConnection ||
        vpnState == VpnEngine.vpnAuthenticating;

    // Kiểm tra trạng thái WireGuard
    final isWireGuardConnecting = widget.controller.isUsingWireGuard &&
        widget.controller.isConnecting;

    // Kiểm tra trạng thái controller
    final isControllerConnecting = widget.controller.isConnecting;

    return isOpenVpnConnecting ||
        isWireGuardConnecting ||
        isControllerConnecting;
  }
}
