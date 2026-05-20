import 'package:flutter/material.dart';
import 'awto_inspect_metadata.dart';
import 'awto_inspect_controller.dart';

class AwtoStatusLine extends StatelessWidget {
  final AwtoInspectController controller;

  const AwtoStatusLine({
    Key? key,
    required this.controller,
  }) : super(key: key);

  String _buildStatusText() {
    final buffer = StringBuffer();

    if (controller.currentPointerPosition != null) {
      final pos = controller.currentPointerPosition!;
      buffer.write('mouse x=${pos.dx.toInt()} y=${pos.dy.toInt()}');

      if (controller.hoveredObject != null) {
        buffer.write(' | over=${controller.hoveredObject!.metadata.id}');
        buffer.write(' | type=${controller.hoveredObject!.metadata.type.name}');

        if (controller.hoveredObject!.metadata.command != null) {
          buffer.write(' | action=${controller.hoveredObject!.metadata.command!.toString()}');
        }

        buffer.write(' | bounds=${controller.hoveredObject!.bounds.left.toInt()},'
            '${controller.hoveredObject!.bounds.top.toInt()} '
            '${controller.hoveredObject!.bounds.width.toInt()}x'
            '${controller.hoveredObject!.bounds.height.toInt()}');
      } else {
        buffer.write(' | over=none');
      }
    } else {
      buffer.write('mouse position: unknown');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color.fromARGB(200, 30, 30, 30),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return SelectableText(
            _buildStatusText(),
            style: const TextStyle(
              fontFamily: 'Courier New',
              fontSize: 12,
              color: Color.fromARGB(255, 100, 200, 100),
            ),
          );
        },
      ),
    );
  }
}
