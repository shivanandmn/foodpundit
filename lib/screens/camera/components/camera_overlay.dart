import 'package:flutter/material.dart';
import '../painters/camera_overlay_painters.dart';

class CameraOverlay extends StatelessWidget {
  final Widget? child;

  const CameraOverlay({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CameraOverlayPainter(),
      child: child,
    );
  }
}
