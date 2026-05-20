# awto_gui_inspect Documentation

This directory contains comprehensive documentation for the awto_gui_inspect Flutter package.

## Documents

### [AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md](AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md)

Complete technical specification for the GUI inspection library, including:

- Package scope and design goals
- Minimum viable library (V1) requirements
- Visual overlay specifications
- Cursor and pointer behavior
- Object hierarchy and markers
- Status line format
- Inspect menu structure
- Copy format examples (JSON and text)
- AI log behavior and payloads
- Hardware command safety classes
- State machine design
- Visual wireframes
- Implementation notes for Flutter
- Future enhancements

This document is the authoritative specification for the library.

## Reading Guide

1. **New to the project?** Start with the main [README.md](../README.md)
2. **Implementing features?** Read [AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md](AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md)
3. **Contributing code?** Check [FLUTTER_STYLE.md](../FLUTTER_STYLE.md)
4. **Working with AI agents?** See [AGENTS.md](../AGENTS.md)

## Key Concepts

### Debug IDs

Every significant GUI object has a stable, unique debug ID used throughout the system:

- Tests select by ID, not coordinates
- AI agents reference objects by ID
- Logs include the ID for traceability
- Inspect menu and overlays display the ID

Examples: `fl-bt`, `rabbit-hop-bt`, `z-status-st`

### Safety Classes

Commands are classified by safety level:

- `viewOnly`: No hardware action
- `normal`: Safe query/display action
- `motion`: Causes physical movement
- `outputEnable`: Energises an output
- `calibration`: Changes calibration
- `reset`: Resets a device
- `firmware`: Flashes firmware
- `destructive`: Erases data
- `raw`: Raw/manual command mode

### Command Metadata

Commands are stored as metadata, not executed directly. The actual command execution goes through the project CLI/API:

```dart
const command = AwtoCommandMetadata(
  command: 'awto rabbit hop',
  target: 'rabbit',
  action: 'hop',
);
```

### Visual Overlay

In debug mode, the GUI shows:

- **Grid**: Alpha-blended major and minor gridlines
- **Crosshair**: Lines through pointer with center dot
- **Hit boxes**: Object bounds with markers and labels
- **Status line**: Real-time pointer position and object info

## Architecture

```
Flutter widgets
    ↓
AwtoInspectable wrappers (metadata + bounds)
    ↓
AwtoInspectRegistry (tracks all objects)
    ↓
AwtoInspectController (state management)
    ↓
Overlays (grid, hit boxes, crosshair)
    ↓
Status line + Inspect menu (UI)
    ↓
AwtoAiLogSink (logging to AI)
```

## Version Information

**Current Version**: v0.1.0

This is the initial release with core inspection functionality. See the spec document for planned v2 features.

## Questions?

- Refer to [AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md](AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md) for detailed specifications
- Check [AGENTS.md](../AGENTS.md) for AI agent rules
- Review [FLUTTER_STYLE.md](../FLUTTER_STYLE.md) for code style
