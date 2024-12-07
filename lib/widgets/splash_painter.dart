import 'package:flutter/material.dart';
import 'dart:math' as math;

enum SplashPattern {
  waves,
  circles,
  curves,
  dots,
  lines
}

class SplashPainter extends CustomPainter {
  final Color color;
  final SplashPattern pattern;
  final bool isDarkMode;

  SplashPainter({
    required this.color,
    required this.pattern,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(isDarkMode ? 0.1 : 0.15)
      ..style = PaintingStyle.fill;

    switch (pattern) {
      case SplashPattern.waves:
        _drawWaves(canvas, size, paint);
        break;
      case SplashPattern.circles:
        _drawCircles(canvas, size, paint);
        break;
      case SplashPattern.curves:
        _drawCurves(canvas, size, paint);
        break;
      case SplashPattern.dots:
        _drawDots(canvas, size, paint);
        break;
      case SplashPattern.lines:
        _drawLines(canvas, size, paint);
        break;
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.45,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    final path2 = Path();
    path2.moveTo(size.width, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.65,
    );
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.55,
      0,
      size.height * 0.6,
    );
    path2.lineTo(0, size.height);
    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
  }

  void _drawCircles(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < 5; i++) {
      final radius = size.width * (0.1 + i * 0.05);
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint,
      );
    }
    for (var i = 0; i < 5; i++) {
      final radius = size.width * (0.1 + i * 0.05);
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.8),
        radius,
        paint,
      );
    }
  }

  void _drawCurves(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 3; i++) {
      path.moveTo(0, size.height * (0.2 + i * 0.3));
      path.cubicTo(
        size.width * 0.3,
        size.height * (0.1 + i * 0.3),
        size.width * 0.7,
        size.height * (0.3 + i * 0.3),
        size.width,
        size.height * (0.2 + i * 0.3),
      );
    }
    canvas.drawPath(path, paint);
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // Fixed seed for consistent pattern
    for (var i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 10 + 5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawLines(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < 8; i++) {
      final path = Path();
      path.moveTo(0, size.height * (i / 8));
      path.lineTo(size.width, size.height * ((i + 1) / 8));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
