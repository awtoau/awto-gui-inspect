import 'dart:ui';
import 'awto_inspect_metadata.dart';

class AwtoInspectRegistry {
  static final AwtoInspectRegistry _instance = AwtoInspectRegistry._internal();

  factory AwtoInspectRegistry() {
    return _instance;
  }

  AwtoInspectRegistry._internal();

  final Map<String, AwtoInspectableObjectState> _objects = {};
  final List<AwtoInspectablePointMetadata> _points = [];

  void register(String id, AwtoInspectableObjectState state) {
    _objects[id] = state;
  }

  void unregister(String id) {
    _objects.remove(id);
  }

  void registerPoint(AwtoInspectablePointMetadata point) {
    _points.add(point);
  }

  void clearPoints() {
    _points.clear();
  }

  AwtoInspectableObjectState? getObject(String id) {
    return _objects[id];
  }

  List<AwtoInspectableObjectState> getAllObjects() {
    return _objects.values.toList();
  }

  AwtoInspectableObjectState? findObjectAt(Offset position) {
    for (final entry in _objects.entries) {
      if (entry.value.bounds.contains(position)) {
        return entry.value;
      }
    }
    return null;
  }

  List<String> findObjectsNear(Offset position, {double radius = 50}) {
    final nearby = <String>[];
    for (final entry in _objects.entries) {
      final bounds = entry.value.bounds;
      if (bounds.center.distance(position) <= radius) {
        nearby.add(entry.key);
      }
    }
    return nearby;
  }

  void clear() {
    _objects.clear();
    _points.clear();
  }

  Map<String, dynamic> getDebugInfo() {
    return {
      'registered_objects': _objects.length,
      'registered_points': _points.length,
      'objects': _objects.keys.toList(),
    };
  }
}

extension on Offset {
  double distance(Offset other) {
    final dx = this.dx - other.dx;
    final dy = this.dy - other.dy;
    return (dx * dx + dy * dy).sqrt();
  }
}
