import 'package:flutter/material.dart';

class CountdownCircle extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double size;
  final Color progressColor;
  final Color backgroundColor;

  const CountdownCircle({
    Key? key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.size,
    required this.progressColor,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: remainingSeconds / totalSeconds,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            backgroundColor: backgroundColor,
          ),
        ),
        Text(
          '$remainingSeconds',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ],
    );
  }
}
