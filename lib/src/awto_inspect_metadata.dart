import 'dart:ui';
import 'awto_command_metadata.dart';
import 'awto_safety_class.dart';

enum AwtoInspectType {
  button,
  text,
  label,
  input,
  line,
  lineEndpoint,
  group,
  panel,
  dialog,
  list,
  table,
  custom,
}

class AwtoInspectableMetadata {
  final String id;
  final String label;
  final AwtoInspectType type;
  final String? description;
  final AwtoCommandMetadata? command;
  final AwtoSafetyClass safetyClass;
  final String? sourceHint;
  final Map<String, dynamic>? customData;

  AwtoInspectableMetadata({
    required this.id,
    required this.label,
    required this.type,
    this.description,
    this.command,
    this.safetyClass = AwtoSafetyClass.viewOnly,
    this.sourceHint,
    this.customData,
  });

  Map<String, dynamic> toJson() {
    return {
      'ui_id': id,
      'label': label,
      'type': type.name,
      if (description != null) 'description': description,
      if (command != null) 'action': command!.toString(),
      if (command != null) 'command': command!.toJson(),
      'safety_class': safetyClass.displayName,
      if (sourceHint != null) 'source': sourceHint,
      if (customData != null) ...customData!,
    };
  }

  String toDisplayString() {
    final lines = <String>[
      'ui_id: $id',
      'type: ${type.name}',
      'label: $label',
      if (description != null) 'description: $description',
      if (command != null) 'action: ${command!.toString()}',
      'safety_class: ${safetyClass.displayName}',
      if (sourceHint != null) 'source: $sourceHint',
    ];
    return lines.join('\n');
  }
}

class AwtoInspectablePointMetadata {
  final String id;
  final String? label;
  final String? parentId;
  final Offset? logicalPoint;
  final Offset? screenPoint;
  final Offset? snapPoint;

  AwtoInspectablePointMetadata({
    required this.id,
    this.label,
    this.parentId,
    this.logicalPoint,
    this.screenPoint,
    this.snapPoint,
  });

  Map<String, dynamic> toJson() {
    return {
      'ui_id': id,
      if (label != null) 'label': label,
      if (parentId != null) 'parent': parentId,
      if (logicalPoint != null)
        'logical_point': {'x': logicalPoint!.dx, 'y': logicalPoint!.dy},
      if (screenPoint != null)
        'screen_point': {'x': screenPoint!.dx, 'y': screenPoint!.dy},
      if (snapPoint != null)
        'snap_point': {'x': snapPoint!.dx, 'y': snapPoint!.dy},
    };
  }

  String toDisplayString() {
    final lines = <String>[
      'ui_id: $id',
      if (label != null) 'label: $label',
      if (parentId != null) 'parent: $parentId',
      'type: line_endpoint',
      if (screenPoint != null)
        'screen: ${screenPoint!.dx.toInt()},${screenPoint!.dy.toInt()}',
      if (logicalPoint != null)
        'logical: ${logicalPoint!.dx.toStringAsFixed(3)},${logicalPoint!.dy.toStringAsFixed(3)}',
      if (snapPoint != null)
        'snap: ${snapPoint!.dx.toInt()},${snapPoint!.dy.toInt()}',
    ];
    return lines.join('\n');
  }
}

class AwtoInspectableObjectState {
  final AwtoInspectableMetadata metadata;
  final Rect bounds;
  final bool isHovered;
  final bool isSelected;
  final String? currentValue;
  final bool? isEnabled;

  AwtoInspectableObjectState({
    required this.metadata,
    required this.bounds,
    this.isHovered = false,
    this.isSelected = false,
    this.currentValue,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      ...metadata.toJson(),
      'bounds': {
        'x': bounds.left.toInt(),
        'y': bounds.top.toInt(),
        'w': bounds.width.toInt(),
        'h': bounds.height.toInt(),
      },
      'state': {
        'hovered': isHovered,
        'selected': isSelected,
        if (currentValue != null) 'value': currentValue,
        if (isEnabled != null) 'enabled': isEnabled,
      },
    };
  }

  String toDisplayString() {
    final lines = <String>[
      metadata.toDisplayString(),
      'bounds: ${bounds.left.toInt()},${bounds.top.toInt()} '
          '${bounds.width.toInt()}x${bounds.height.toInt()}',
      if (isEnabled != null) 'enabled: $isEnabled',
      if (currentValue != null) 'value: $currentValue',
    ];
    return lines.join('\n');
  }
}
