import 'package:flutter/material.dart';
import 'package:frontend/goal_tracking/configuration.dart';

//takes offset from and to to draw the lines
class EdgeWidget extends StatelessWidget {
  final Offset from;
  final Offset to;

  const EdgeWidget({super.key, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: LinePainter(p1: from, p2: to),
        size: Size.infinite,
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  Offset p1, p2;
  LinePainter({required this.p1, required this.p2});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = edgeStrokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(p1.dx, p1.dy);

    // Midpoint with a slight curve (adjust the +/- to change curvature)
    Offset controlPoint = Offset(
      (p1.dx + p2.dx) / 2,
      (p1.dy + p2.dy) / 2 + 160, // Curve upward; use +40 to curve downward
    );

    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return p1 != oldDelegate.p1 || p2 != oldDelegate.p2;
  }
}
