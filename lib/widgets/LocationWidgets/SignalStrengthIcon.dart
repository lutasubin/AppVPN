import 'package:flutter/material.dart';

class SignalStrengthIcon extends StatelessWidget {
  final int level; // 1 đến 3

  const SignalStrengthIcon({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    List<double> heights = [8, 14, 20];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Container(
            width: 4,
            height: heights[index],
            decoration: BoxDecoration(
              color: index < level ? Colors.green : Colors.green.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
