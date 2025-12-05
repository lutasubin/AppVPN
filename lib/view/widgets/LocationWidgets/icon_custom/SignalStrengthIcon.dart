import 'package:flutter/material.dart';

class SignalStrengthIcon extends StatelessWidget {
  final int level; // level từ 1 đến 4

  const SignalStrengthIcon({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    List<double> heights = [4, 7, 10, 13]; // Chiều cao thu nhỏ

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 0.8), // giảm khoảng cách
          child: Container(
            width: 3,
            height: heights[index],
            decoration: BoxDecoration(
              color: const Color(0xFF3FD8EF),
              borderRadius: BorderRadius.circular(1.2), // làm mềm góc tương ứng
            ),
          ),
        );
      }),
    );
  }
}
