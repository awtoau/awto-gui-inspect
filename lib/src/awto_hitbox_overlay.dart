import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'awto_inspect_metadata.dart';
import 'awto_inspect_registry.dart';

class AwtoHitboxOverlay extends CustomPainter {
  final double alpha;
  final String? hoveredObjectId;
  final String? selectedObjectId;
  final TextPainter Function(String)? createTextPainter;

  AwtoHitboxOverlay({
    required this.alpha,
    this.hoveredObjectId,
    this.selectedObjectId,
    this.createTextPainter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final registry = AwtoInspectRegistry();
    final objects = registry.getAllObjects();

    final boundsPaint = Paint()
      ..color = Color.fromARGB((alpha * 255).toInt(), 100, 150, 200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final hoveredPaint = Paint()
      ..color = Color.fromARGB((alpha * 255 * 2).toInt(), 255, 200, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final selectedPaint = Paint()
      ..color = Color.fromARGB((alpha * 255 * 3).toInt(), 255, 100, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final markerPaint = Paint()
      ..color = const Color.fromARGB(200, 100, 150, 200)
      ..strokeWidth = 1.0;

    final selectedMarkerPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 100, 0)
      ..strokeWidth = 1.5;

    for (final object in objects) {
      final bounds = object.bounds;
      final center = bounds.center;
      final isHovered = hoveredObjectId == object.metadata.id;
      final isSelected = selectedObjectId == object.metadata.id;

      // Draw bounds rectangle
      if (isSelected) {
        canvas.drawRect(bounds, selectedPaint);
      } else if (isHovered) {
        canvas.drawRect(bounds, hoveredPaint);
      } else {
        canvas.drawRect(bounds, boundsPaint);
      }

      // Draw center marker
      _drawCrosshair(canvas, center, 8, isSelected ? selectedMarkerPaint : markerPaint);

      // Draw ID label
      if (createTextPainter != null) {
        final textPainter = createTextPainter!(object.metadata.id);
        final labelOffset = Offset(bounds.left + 4, bounds.top + 4);
        textPainter.paint(canvas, labelOffset);
      }
    }
  }

  void _drawCrosshair(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawLine(Offset(center.dx - size, center.dy), Offset(center.dx + size, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - size), Offset(center.dx, center.dy + size), paint);
  }

  @override
  bool shouldRepaint(AwtoHitboxOverlay oldDelegate) {
    return oldDelegate.alpha != alpha ||
        oldDelegate.hoveredObjectId != hoveredObjectId ||
        oldDelegate.selectedObjectId != selectedObjectId;
  }
}
