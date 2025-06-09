import 'package:flutter/material.dart';

class SignalStrengthIcon extends StatelessWidget {
  final int level; // level từ 1 đến 4

  const SignalStrengthIcon({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    List<double> heights = [8, 14, 20, 26]; // Chiều cao 4 cột sóng

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 4,
            height: heights[index],
            decoration: BoxDecoration(
              color: const Color(0xFF03C343),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
