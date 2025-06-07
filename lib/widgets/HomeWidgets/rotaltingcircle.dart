import 'package:flutter/material.dart';

class RotatingGradientCircle extends StatefulWidget {
  final double size;
  final List<Color> colors;

  const RotatingGradientCircle({
    Key? key,
    required this.size,
    required this.colors,
  }) : super(key: key);

  @override
  _RotatingGradientCircleState createState() => _RotatingGradientCircleState();
}

class _RotatingGradientCircleState extends State<RotatingGradientCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Lặp vô tận
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _GradientCirclePainter(colors: widget.colors),
      ),
    );
  }
}

class _GradientCirclePainter extends CustomPainter {
  final List<Color> colors;

  _GradientCirclePainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = SweepGradient(
      colors: colors,
      startAngle: 0,
      endAngle: 6.28319, // 2*PI
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;

    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - 4; // Padding cho nét viền

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientCirclePainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}
