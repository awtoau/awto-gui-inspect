import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'awto_inspect_metadata.dart';
import 'awto_inspect_registry.dart';

class AwtoInspectController extends ChangeNotifier {
  bool _enabled = kDebugMode;
  bool _gridEnabled = true;
  bool _hitboxesEnabled = true;
  bool _labelsEnabled = true;
  bool _crosshairEnabled = true;
  bool _statusLineEnabled = true;
  double _gridSize = 8;
  double _gridAlpha = 0.2;
  double _objectAlpha = 0.5;

  Offset? _currentPointerPosition;
  AwtoInspectableObjectState? _hoveredObject;
  AwtoInspectableObjectState? _selectedObject;

  bool get enabled => _enabled;
  bool get gridEnabled => _gridEnabled;
  bool get hitboxesEnabled => _hitboxesEnabled;
  bool get labelsEnabled => _labelsEnabled;
  bool get crosshairEnabled => _crosshairEnabled;
  bool get statusLineEnabled => _statusLineEnabled;
  double get gridSize => _gridSize;
  double get gridAlpha => _gridAlpha;
  double get objectAlpha => _objectAlpha;

  Offset? get currentPointerPosition => _currentPointerPosition;
  AwtoInspectableObjectState? get hoveredObject => _hoveredObject;
  AwtoInspectableObjectState? get selectedObject => _selectedObject;

  void toggleEnabled() {
    _enabled = !_enabled;
    notifyListeners();
  }

  void setEnabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      notifyListeners();
    }
  }

  void toggleGrid() {
    _gridEnabled = !_gridEnabled;
    notifyListeners();
  }

  void toggleHitboxes() {
    _hitboxesEnabled = !_hitboxesEnabled;
    notifyListeners();
  }

  void toggleLabels() {
    _labelsEnabled = !_labelsEnabled;
    notifyListeners();
  }

  void toggleCrosshair() {
    _crosshairEnabled = !_crosshairEnabled;
    notifyListeners();
  }

  void toggleStatusLine() {
    _statusLineEnabled = !_statusLineEnabled;
    notifyListeners();
  }

  void setGridSize(double size) {
    if (_gridSize != size) {
      _gridSize = size;
      notifyListeners();
    }
  }

  void setGridAlpha(double alpha) {
    if (_gridAlpha != alpha) {
      _gridAlpha = alpha.clamp(0, 1);
      notifyListeners();
    }
  }

  void setObjectAlpha(double alpha) {
    if (_objectAlpha != alpha) {
      _objectAlpha = alpha.clamp(0, 1);
      notifyListeners();
    }
  }

  void updatePointerPosition(Offset position) {
    if (_currentPointerPosition != position) {
      _currentPointerPosition = position;

      final registry = AwtoInspectRegistry();
      _hoveredObject = registry.findObjectAt(position);

      notifyListeners();
    }
  }

  void selectObject(AwtoInspectableObjectState? object) {
    if (_selectedObject != object) {
      _selectedObject = object;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedObject = null;
    notifyListeners();
  }

  void reset() {
    _enabled = kDebugMode;
    _gridEnabled = true;
    _hitboxesEnabled = true;
    _labelsEnabled = true;
    _crosshairEnabled = true;
    _statusLineEnabled = true;
    _gridSize = 8;
    _gridAlpha = 0.2;
    _objectAlpha = 0.5;
    _currentPointerPosition = null;
    _hoveredObject = null;
    _selectedObject = null;
    notifyListeners();
  }
}
