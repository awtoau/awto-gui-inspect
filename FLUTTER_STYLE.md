# Flutter Coding Style Guide

This document defines the coding style and conventions for the awto_gui_inspect Flutter package and related projects.

## General Principles

- **Readability first**: Code should be self-documenting. Use clear, descriptive names for variables, functions, and classes.
- **Consistency**: Follow these conventions consistently across the entire codebase.
- **Minimize comments**: Write clear code; only add comments for non-obvious logic or important context.
- **Use modern Dart**: Leverage Dart 3+ features (records, switch expressions, sealed classes) where they improve clarity.

## File Organization

### File Names

- Use `snake_case` for file names: `awto_inspect_app.dart`, `awto_metadata.dart`
- One public class per file, unless closely related
- Keep related private classes in the same file

### Directory Structure

```
lib/
  awto_gui_inspect.dart          # Main library export
  src/
    awto_inspect_app.dart        # Public widgets
    awto_inspectable.dart
    awto_inspect_metadata.dart   # Data models
    awto_command_metadata.dart
    awto_safety_class.dart
    awto_ai_log_sink.dart        # Interfaces and services
    awto_inspect_controller.dart  # State management
    awto_inspect_registry.dart
    awto_grid_overlay.dart       # Overlays and painters
    awto_hitbox_overlay.dart
    awto_crosshair_overlay.dart
    awto_status_line.dart        # UI components
    awto_inspect_menu.dart
    awto_clipboard_export.dart   # Utilities
```

## Naming Conventions

### Classes and Enums

- Use `PascalCase` for class names: `AwtoInspectApp`, `AwtoCommandMetadata`
- Use `PascalCase` for enum names: `AwtoSafetyClass`, `AwtoInspectType`
- Prefix UI-related classes with `Awto` for clarity: `AwtoInspectable`, `AwtoStatusLine`

### Variables and Functions

- Use `camelCase` for variables and function names: `pointerPosition`, `updateBounds()`
- Use `lowerCamelCase` for private variables: `_controller`, `_gridSize`
- Use `UPPER_SNAKE_CASE` for constants: `const double DEFAULT_GRID_SIZE = 8.0`

### Methods

- Use verb-based names for methods: `updateBounds()`, `toggleEnabled()`, `registerObject()`
- Use `get`/`set` prefixes for getters/setters that are not properties: `getObject()`, `setGridSize()`
- Private methods start with underscore: `_updateBounds()`, `_drawCrosshair()`

### Booleans

- Prefix boolean variables/properties with `is`, `has`, `can`, or `should`:
  - `isEnabled`, `isHovered`, `isSelected`
  - `hasItems`, `hasComment`
  - `canExecute`, `canRegister`
  - `shouldUpdate`, `shouldRepaint`

## Code Style

### Formatting

- Use 2-space indentation (Dart convention)
- Line length: aim for 80 characters, but up to 100 is acceptable for clarity
- Use trailing commas in collections and function arguments (helps with diffs)

```dart
final list = <String>[
  'item1',
  'item2',
  'item3',
];

function(
  arg1,
  arg2,
  arg3,
);
```

### Imports

- Group imports in order:
  1. `dart:` imports
  2. `package:flutter/` imports
  3. Local imports (relative paths)
- Sort within each group alphabetically
- Use relative imports for local files within the package

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'awto_command_metadata.dart';
import 'awto_inspect_metadata.dart';
```

### Class Structure

Order class members as follows:
1. Static constants
2. Static fields
3. Instance fields (public, then private)
4. Constructors
5. Getters and setters
6. Public methods
7. Private methods
8. Overrides (build, paint, etc.)

```dart
class AwtoInspectController extends ChangeNotifier {
  static const double DEFAULT_GRID_SIZE = 8.0;
  static final AwtoInspectRegistry _instance = ...;

  bool _enabled = true;
  double _gridSize = DEFAULT_GRID_SIZE;

  AwtoInspectController();

  bool get enabled => _enabled;

  void toggleEnabled() {
    _enabled = !_enabled;
    notifyListeners();
  }

  void _updateState() { }

  @override
  void dispose() { }
}
```

### Strings

- Use single quotes for strings: `'Hello'` not `"Hello"`
- Use string interpolation for clarity: `'Hello $name'` instead of `'Hello ' + name`
- For long strings or multi-line content, use raw strings or string literals:

```dart
const text = '''
This is a multi-line
string in Dart.
''';

const regex = r'pattern\d+';
```

### Collections

- Use `<Type>` for explicit type annotations
- Prefer named constructors for clarity

```dart
final list = <String>[];
final map = <String, dynamic>{};
final set = <int>{};

// Not: final list = [];
```

### Null Safety

- Use non-nullable types by default
- Use `?` only when null is a valid state: `String?`, `Offset?`
- Use `late` for fields that are initialized after construction:

```dart
late final RenderBox _renderBox;

String? _optionalValue;
```

- Use `??` and `?.` operators appropriately:

```dart
final value = input ?? defaultValue;
final length = list?.length ?? 0;
```

## Type Hints and Generics

- Always provide explicit type hints for public APIs:

```dart
// Good
Future<void> logInspectEvent(AwtoInspectEvent event) async { }
Map<String, dynamic> toJson() => { };

// Avoid
logInspectEvent(event) async { }
toJson() => { };
```

- Use generic type parameters clearly:

```dart
List<String> getAllIds() { }
Map<String, AwtoInspectableObjectState> getObjects() { }
```

## Functions and Methods

### Single vs Multi-line

- Keep method signatures on one line when possible:

```dart
// Good
void updatePointerPosition(Offset position) { }

// Only if too long
void registerObjectWithMetadataAndBounds(
  String id,
  AwtoInspectableMetadata metadata,
  Rect bounds,
) { }
```

### Arrow Functions

- Use arrow functions for simple one-line methods:

```dart
bool get isEnabled => _enabled;
String toString() => 'AwtoSafetyClass($_name)';
```

- Use full method bodies for anything more complex:

```dart
void updatePosition() {
  final bounds = calculateBounds();
  _position = bounds.center;
}
```

## Widget Building

### Build Methods

- Keep build methods clean and concise
- Extract complex widget trees to separate methods or widgets:

```dart
// Good
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),
      _buildContent(),
      _buildFooter(),
    ],
  );
}

Widget _buildHeader() { }
```

- Use `const` widgets and constructors where possible:

```dart
const SizedBox(height: 16),
ElevatedButton(
  onPressed: () => _handlePress(),
  child: const Text('Click me'),
)
```

### Listeners and State Management

- Use `ListenableBuilder` for listening to `ChangeNotifier`:

```dart
ListenableBuilder(
  listenable: controller,
  builder: (context, _) {
    return Text(controller.status);
  },
)
```

- Use `ValueListenableBuilder` for `ValueNotifier`:

```dart
ValueListenableBuilder<String>(
  valueListenable: statusNotifier,
  builder: (context, status, _) {
    return Text(status);
  },
)
```

## Comments

### When to Add Comments

- Explain **why**, not what. The code already says what it does.
- Document non-obvious algorithms or workarounds
- Mark platform-specific or workaround code

```dart
// Bad: The code already says this
// Increment the counter
count++;

// Good: Explains why, not what
// This threshold is based on empirical testing with flutter_test
const double pointerHitThreshold = 8.0;

// Platform-specific workaround for iOS rendering
if (Platform.isIOS) {
  _adjustForSafeArea();
}
```

### Documentation Comments

- Use `///` for public API documentation
- Include examples for complex APIs

```dart
/// Registers an inspectable object with the given [metadata].
///
/// The [id] must be unique within the current screen or module.
/// Returns the registered [AwtoInspectableObjectState].
///
/// Example:
/// ```dart
/// registry.register('fl-bt', state);
/// ```
void register(String id, AwtoInspectableObjectState state) { }
```

## Error Handling

- Use specific exception types
- Avoid bare `catch` blocks; catch specific exceptions:

```dart
try {
  _renderBox = context.findRenderObject() as RenderBox?;
} catch (e) {
  // Ignore errors during bounds capture
}

// Better: be specific
try {
  _renderBox = context.findRenderObject() as RenderBox?;
} on NoSuchMethodError {
  // RenderBox not available yet
}
```

## Enums and Sealed Classes

- Use enums for fixed sets of values:

```dart
enum AwtoInspectType {
  button,
  text,
  label,
  line,
  custom,
}

// Add helper extensions
extension AwtoInspectTypeExt on AwtoInspectType {
  String get displayName => name;
}
```

- Use switch expressions for exhaustive pattern matching:

```dart
bool get requiresConfirmation {
  return switch (this) {
    AwtoSafetyClass.viewOnly => false,
    AwtoSafetyClass.normal => false,
    AwtoSafetyClass.motion => true,
    AwtoSafetyClass.outputEnable => true,
    AwtoSafetyClass.calibration => true,
    _ => true,
  };
}
```

## Constants and Configuration

- Define constants at the top of files or in separate const files
- Use `const` constructors for immutable classes:

```dart
const AwtoCommandMetadata(
  command: 'awto rabbit hop',
  target: 'rabbit',
  action: 'hop',
);
```

- Group related configuration constants:

```dart
class AwtoInspectDefaults {
  static const double gridSize = 8.0;
  static const double gridAlpha = 0.2;
  static const double objectAlpha = 0.5;
}
```

## Testing

- Use descriptive test names that explain what is being tested:

```dart
test('updatePointerPosition updates hoveredObject when pointer is over object', () {
  // test body
});

test('register throws ArgumentError when id is empty', () {
  // test body
});
```

- Group related tests with `group()`:

```dart
group('AwtoInspectController', () {
  group('toggleEnabled', () {
    test('toggles enabled state', () { });
    test('notifies listeners', () { });
  });
});
```

## Performance

- Avoid rebuilds in custom painters; use `shouldRepaint()` effectively:

```dart
@override
bool shouldRepaint(AwtoGridOverlay oldDelegate) {
  return oldDelegate.gridSize != gridSize || oldDelegate.alpha != alpha;
}
```

- Cache expensive computations:

```dart
late final List<Offset> _cachedPoints;

void _computePoints() {
  _cachedPoints = _computeExpensivePoints();
}
```

- Use `const` widgets to prevent unnecessary rebuilds

## Accessibility

- Provide semantic labels for interactive elements:

```dart
Semantics(
  button: true,
  label: 'Rabbit Hop Button',
  child: ElevatedButton(
    onPressed: () { },
    child: const Text('Hop'),
  ),
)
```

- Use sufficient contrast for text and UI elements
- Test with screen readers and keyboard navigation

## Final Notes

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `dart format` to auto-format code
- Run `dart analyze` to check for issues
- This style guide is the authoritative source for this project; use it to make consistent decisions
