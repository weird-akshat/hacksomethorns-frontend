import 'package:flutter/material.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/goal_tracking/configuration.dart';

//takes offset from and to to draw the lines
class EdgeWidget extends StatelessWidget {
  final Offset from;
  final Offset to;

  const EdgeWidget({super.key, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return CustomPaint(
            painter: LinePainter(
              p1: from,
              p2: to,
              isDarkMode: themeProvider.isDarkMode,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  Offset p1, p2;
  bool isDarkMode;
  LinePainter({required this.p1, required this.p2, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    // Simple black/white colors based on theme
    Paint paint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.8)
      ..strokeWidth = edgeStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(p1.dx, p1.dy);

    // Simple curve
    Offset controlPoint = Offset(
      (p1.dx + p2.dx) / 2,
      (p1.dy + p2.dy) / 2 + 60,
    );

    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return p1 != oldDelegate.p1 ||
        p2 != oldDelegate.p2 ||
        isDarkMode != oldDelegate.isDarkMode;
  }
}
