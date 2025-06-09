import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DisconnectButton extends StatefulWidget {
  final VoidCallback onPressed;
  const DisconnectButton({super.key, required this.onPressed});

  @override
  State<DisconnectButton> createState() => _DisconnectButtonState();
}

class _DisconnectButtonState extends State<DisconnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse(); // trở lại trạng thái ban đầu
      }
    });
  }

  void _handleTap() {
    HapticFeedback.lightImpact(); // rung nhẹ
    _controller.forward(from: 0.0); // bắt đầu hiệu ứng
    widget.onPressed(); // gọi hành động disconnect
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: _handleTap,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 180,
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Color.lerp(
                    const Color(0xFFF15E24),
                    Color(0xFF4CAF50),
                    _glowAnimation.value,
                  )!,
                  width: 2,
                ),
                boxShadow: [
                  if (_glowAnimation.value > 0)
                    BoxShadow(
                      color: Colors.cyanAccent
                          .withOpacity(_glowAnimation.value * 0.5),
                      blurRadius: 10,
                      spreadRadius: 1.5,
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  'disconnect'.tr,
                  style: const TextStyle(
                    color: Color(0xFFF15E24),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
