import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AwtoGridOverlay extends CustomPainter {
  final double gridSize;
  final double alpha;
  final double majorGridMultiplier;

  AwtoGridOverlay({
    required this.gridSize,
    required this.alpha,
    this.majorGridMultiplier = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = Color.fromARGB((alpha * 255).toInt(), 100, 150, 200)
      ..strokeWidth = 0.5;

    final majorPaint = Paint()
      ..color = Color.fromARGB((alpha * 255 * 1.5).toInt(), 100, 150, 200)
      ..strokeWidth = 1.0;

    final majorGridSize = gridSize * majorGridMultiplier;

    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      final isMajor = (x % majorGridSize).abs() < 0.1;
      final paint = isMajor ? majorPaint : minorPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      final isMajor = (y % majorGridSize).abs() < 0.1;
      final paint = isMajor ? majorPaint : minorPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(AwtoGridOverlay oldDelegate) {
    return oldDelegate.gridSize != gridSize || oldDelegate.alpha != alpha;
  }
}
