import 'package:flutter/material.dart';
import 'awto_inspect_metadata.dart';
import 'awto_command_metadata.dart';
import 'awto_safety_class.dart';
import 'awto_inspect_registry.dart';

class AwtoInspectable extends StatefulWidget {
  final String id;
  final String label;
  final AwtoInspectType type;
  final Widget child;
  final String? description;
  final AwtoCommandMetadata? command;
  final AwtoSafetyClass safetyClass;
  final String? sourceHint;
  final Map<String, dynamic>? customData;

  const AwtoInspectable({
    Key? key,
    required this.id,
    required this.label,
    required this.type,
    required this.child,
    this.description,
    this.command,
    this.safetyClass = AwtoSafetyClass.viewOnly,
    this.sourceHint,
    this.customData,
  }) : super(key: key);

  @override
  State<AwtoInspectable> createState() => _AwtoInspectableState();
}

class _AwtoInspectableState extends State<AwtoInspectable> {
  late GlobalKey<State> _childKey;
  RenderBox? _renderBox;

  @override
  void initState() {
    super.initState();
    _childKey = GlobalKey();
    _updateBounds();
  }

  @override
  void didUpdateWidget(AwtoInspectable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.label != widget.label) {
      _updateBounds();
    }
  }

  void _updateBounds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _renderBox = context.findRenderObject() as RenderBox?;
        if (_renderBox != null) {
          final size = _renderBox!.size;
          final position = _renderBox!.localToGlobal(Offset.zero);

          final metadata = AwtoInspectableMetadata(
            id: widget.id,
            label: widget.label,
            type: widget.type,
            description: widget.description,
            command: widget.command,
            safetyClass: widget.safetyClass,
            sourceHint: widget.sourceHint,
            customData: widget.customData,
          );

          final bounds = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
          final state = AwtoInspectableObjectState(
            metadata: metadata,
            bounds: bounds,
          );

          AwtoInspectRegistry().register(widget.id, state);
        }
      } catch (e) {
        // Ignore errors during bounds capture
      }
    });
  }

  @override
  void dispose() {
    AwtoInspectRegistry().unregister(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AwtoInspectableLine extends StatefulWidget {
  final String id;
  final List<AwtoInspectablePoint> points;
  final Widget child;
  final String? description;
  final String? sourceHint;

  const AwtoInspectableLine({
    Key? key,
    required this.id,
    required this.points,
    required this.child,
    this.description,
    this.sourceHint,
  }) : super(key: key);

  @override
  State<AwtoInspectableLine> createState() => _AwtoInspectableLineState();
}

class _AwtoInspectableLineState extends State<AwtoInspectableLine> {
  @override
  void initState() {
    super.initState();
    _registerPoints();
  }

  void _registerPoints() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final registry = AwtoInspectRegistry();
      registry.clearPoints();

      for (final point in widget.points) {
        final pointMetadata = AwtoInspectablePointMetadata(
          id: point.id,
          label: point.label,
          parentId: widget.id,
          screenPoint: Offset(point.x, point.y),
        );
        registry.registerPoint(pointMetadata);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AwtoInspectablePoint {
  final String id;
  final double x;
  final double y;
  final String? label;

  const AwtoInspectablePoint({
    required this.id,
    required this.x,
    required this.y,
    this.label,
  });
}
