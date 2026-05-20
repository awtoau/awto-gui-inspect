import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AwtoCrosshairOverlay extends CustomPainter {
  final Offset? pointerPosition;
  final double alpha;

  AwtoCrosshairOverlay({
    required this.pointerPosition,
    required this.alpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pointerPosition == null) return;

    final paint = Paint()
      ..color = Color.fromARGB((alpha * 255).toInt(), 255, 100, 100)
      ..strokeWidth = 1.0;

    final x = pointerPosition!.dx;
    final y = pointerPosition!.dy;

    // Draw vertical line
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

    // Draw horizontal line
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = Color.fromARGB((alpha * 255).toInt(), 255, 100, 100)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pointerPosition!, 3, dotPaint);
  }

  @override
  bool shouldRepaint(AwtoCrosshairOverlay oldDelegate) {
    return oldDelegate.pointerPosition != pointerPosition || oldDelegate.alpha != alpha;
  }
}
