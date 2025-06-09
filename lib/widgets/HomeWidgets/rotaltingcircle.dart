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
      duration: const Duration(seconds: 1),
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
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - 4; // Padding cho nét viền

    final gradient = SweepGradient(
      colors: colors,
      stops: List.generate(colors.length, (i) => i / (colors.length - 1)),
      startAngle: 0,
      endAngle: 6.28319, // 2*PI
    );

    // Glow effect (outer light)
    final glowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, radius, glowPaint);

    // Main gradient circle
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientCirclePainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}
