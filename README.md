# awto_gui_inspect

A Flutter package for development-time GUI inspection, AI handoff, and hardware-safe command wiring.

## Features

- **Stable Debug IDs**: Unique, stable identifiers for every significant GUI object
- **Visual Overlay**: Alpha-blended grid, crosshair cursor, hit boxes, and object labels
- **Interactive Inspection**: Right-click (desktop) or long-press (touch) to inspect objects
- **Copy Data**: Export object data as JSON, plain text, or specific fields
- **AI Logging**: Send inspected objects to an AI agent with optional comments
- **Command Metadata**: Attach project CLI/API commands to UI objects
- **Safety Classes**: Declare safety requirements (motion, destructive, etc.) for hardware actions
- **Hit Box Testing**: Find objects at pointer position, nearby objects, full registry
- **No Hardware Access**: Commands are metadata only; hardware access goes through project CLI/API

## Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  awto_gui_inspect:
    path: ../awto_gui_inspect
```

### Basic Usage

Wrap your app with `AwtoInspectApp`:

```dart
import 'package:awto_gui_inspect/awto_gui_inspect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return AwtoInspectApp(
          enabled: true,
          aiLogSink: AwtoConsoleAiLogSink(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePage(),
    );
  }
}
```

Wrap interactive widgets with `AwtoInspectable`:

```dart
AwtoInspectable(
  id: 'rabbit-hop-bt',
  label: 'Rabbit Hop',
  type: AwtoInspectType.button,
  command: const AwtoCommandMetadata(
    command: 'awto rabbit hop',
    target: 'rabbit',
    action: 'hop',
  ),
  safetyClass: AwtoSafetyClass.motion,
  sourceHint: 'HardwareTestPanel.dart:112',
  child: ElevatedButton(
    onPressed: () => commandBus.run('awto rabbit hop'),
    child: const Text('Hop'),
  ),
)
```

## Debug ID Conventions

Use clear, concise IDs following this pattern:

```
<target>-<role>[:<subpart>]
```

Examples:

```
fl-bt              front-left button
fr-st              front-right status
rl-ln              rear-left line
z-home-bt          z-axis home button
pdm-out3-toggle    PDM output 3 toggle
mux-port-list      mux port list
```

Avoid vague IDs like `button1`, `panel2`, `f-button`, or `q`.

## Visual Debug Mode

When inspection is enabled, the GUI shows:

- **Alpha-blended grid**: Minor (8px) and major (64px) gridlines
- **Crosshair cursor**: Vertical and horizontal lines through pointer
- **Hit boxes**: Object bounds with center markers
- **Object labels**: Visible debug IDs next to objects
- **Status line**: Current pointer position and hovered object info
- **Hover highlight**: Bright outline when pointer is over an object

### Status Line Example

```
mouse x=428 y=312 | over=fl-bt | type=button | action=awto level front-left | bounds=390,288 76x48
```

## Inspection Menu

Right-click (desktop) or long-press (touch) an object to open the inspect menu:

- Copy ID
- Copy object data as JSON
- Copy object data as text
- Copy action command
- Log to AI agent
- Log to AI agent with comment...
- Open source definition

## Copy Formats

### JSON Format

```json
{
  "ui_id": "fl-bt",
  "type": "button",
  "label": "Front Left",
  "bounds": { "x": 390, "y": 288, "w": 76, "h": 48 },
  "state": { "hovered": false, "selected": false, "enabled": true },
  "action": "awto level front-left",
  "safety_class": "motion",
  "source": "LevelPanel.dart:83"
}
```

### Text Format

```
ui_id: fl-bt
type: button
label: Front Left
bounds: 390,288 76x48
action: awto level front-left
safety_class: motion
source: LevelPanel.dart:83
```

## AI Logging

Send inspected objects to an AI agent for analysis:

```dart
// Simple logging without comment
final event = AwtoInspectEvent(
  event: 'ui_inspect',
  object: objectMetadata,
  screen: 'level-panel',
);
await aiLogSink.logInspectEvent(event);

// With comment
final eventWithComment = AwtoInspectEvent(
  event: 'ui_inspect_comment',
  object: objectMetadata,
  comment: 'This button is too close to the status text',
  screen: 'level-panel',
);
await aiLogSink.logInspectEvent(eventWithComment);
```

## Custom AI Log Sinks

Implement the `AwtoAiLogSink` interface for custom logging:

```dart
class MyCustomLogSink extends AwtoAiLogSink {
  @override
  Future<void> logInspectEvent(AwtoInspectEvent event) async {
    // Send to HTTP endpoint, local file, or other backend
    final json = event.toJsonString();
    await http.post(
      Uri.parse('http://localhost:8000/log'),
      body: json,
    );
  }
}
```

## Safety Classes

Declare the safety level of commands:

```dart
enum AwtoSafetyClass {
  viewOnly,          // No hardware action
  normal,            // Harmless query or display
  motion,            // Causes physical movement
  outputEnable,      // Energises an output
  calibration,       // Changes calibration
  reset,             // Resets a device
  firmware,          // Flashes firmware
  destructive,       // Erases data
  raw,               // Raw/manual command
}
```

High-safety commands (motion, output, etc.) can be marked to require confirmation.

## Command Metadata

Attach CLI/API commands to widgets without directly calling them:

```dart
const command = AwtoCommandMetadata(
  command: 'awto rabbit hop',
  target: 'rabbit',
  action: 'hop',
  description: 'Make the rabbit hop once',
);
```

The actual command execution happens through your app's command bus or API layer—never directly via serial port.

## Building and Testing

Use the included `cli.py` script:

```bash
python cli.py --help
python cli.py clean        # Clean artifacts
python cli.py get          # Get dependencies
python cli.py analyze      # Static analysis
python cli.py test         # Run tests
python cli.py verify       # Full verification
python cli.py all          # Complete build
python cli.py docs         # Generate documentation
```

## Coding Style

Follow [FLUTTER_STYLE.md](FLUTTER_STYLE.md) for consistent code style, naming conventions, and best practices.

## Documentation

- [AGENTS.md](AGENTS.md) - Rules for AI agents working with this library
- [docs/AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md](docs/AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md) - Complete specification
- [FLUTTER_STYLE.md](FLUTTER_STYLE.md) - Coding style guide

## Project Structure

```
lib/
  awto_gui_inspect.dart           # Main library export
  src/
    awto_inspect_app.dart         # Main app wrapper
    awto_inspectable.dart         # Widget wrapper and registry
    awto_inspect_metadata.dart    # Data models
    awto_command_metadata.dart    # Command metadata
    awto_safety_class.dart        # Safety enum
    awto_ai_log_sink.dart         # AI logging interface
    awto_inspect_controller.dart  # State management
    awto_inspect_registry.dart    # Object registry
    awto_grid_overlay.dart        # Grid painter
    awto_hitbox_overlay.dart      # Hit box painter
    awto_crosshair_overlay.dart   # Crosshair painter
    awto_status_line.dart         # Status line widget
    awto_inspect_menu.dart        # Context menu
    awto_clipboard_export.dart    # Copy utilities
```

## Version History

### v0.1.0 (Current)

Initial release with core features:
- AwtoInspectApp wrapper
- AwtoInspectable widget wrapper
- Debug ID registry
- Grid overlay
- Crosshair cursor
- Status line
- Right-click/long-press menu
- Copy as JSON and text
- AI log sink interface
- Console implementation

## Future Enhancements

- Object tree inspector panel
- Property inspector panel
- Event wiring inspector
- State machine viewer
- Layout constraint viewer
- Measurement tool
- Accessibility checker
- Screenshot + metadata export
- Source code jump
- Command replay
- AI log history viewer

## License

This package is part of the AWTO project and follows the project's license.

## Contributing

When contributing, follow [FLUTTER_STYLE.md](FLUTTER_STYLE.md) and [AGENTS.md](AGENTS.md).

Before submitting a PR:

```bash
python cli.py verify    # Run verification suite
python cli.py format    # Format code
python cli.py all       # Full build
```
