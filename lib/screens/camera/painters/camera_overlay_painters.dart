import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CameraOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final double cornerLength = 40;
    final double frameWidth = size.width * 0.8;
    final double frameHeight = size.height * 0.4;
    final double left = (size.width - frameWidth) / 2;
    final double top = (size.height - frameHeight) / 2;

    // Draw semi-transparent overlay
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRect(Rect.fromLTWH(left, top, frameWidth, frameHeight))
          ..close(),
      ),
      overlayPaint,
    );

    // Draw corners
    _drawCorner(canvas, Offset(left, top), cornerLength, paint, true, true);
    _drawCorner(canvas, Offset(left + frameWidth, top), cornerLength, paint, false, true);
    _drawCorner(canvas, Offset(left, top + frameHeight), cornerLength, paint, true, false);
    _drawCorner(canvas, Offset(left + frameWidth, top + frameHeight), cornerLength, paint, false, false);
  }

  void _drawCorner(Canvas canvas, Offset corner, double length, Paint paint,
      bool isLeft, bool isTop) {
    final Path path = Path();
    if (isLeft) {
      if (isTop) {
        path.moveTo(corner.dx, corner.dy + length);
        path.lineTo(corner.dx, corner.dy);
        path.lineTo(corner.dx + length, corner.dy);
      } else {
        path.moveTo(corner.dx, corner.dy - length);
        path.lineTo(corner.dx, corner.dy);
        path.lineTo(corner.dx + length, corner.dy);
      }
    } else {
      if (isTop) {
        path.moveTo(corner.dx - length, corner.dy);
        path.lineTo(corner.dx, corner.dy);
        path.lineTo(corner.dx, corner.dy + length);
      } else {
        path.moveTo(corner.dx - length, corner.dy);
        path.lineTo(corner.dx, corner.dy);
        path.lineTo(corner.dx, corner.dy - length);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CameraOverlayPainter oldDelegate) => false;
}

class CustomTextPainter extends CustomPainter {
  final String text;
  final double fontSize;

  CustomTextPainter({required this.text, this.fontSize = 16.0});

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final position = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(CustomTextPainter oldDelegate) =>
      text != oldDelegate.text || fontSize != oldDelegate.fontSize;
}
