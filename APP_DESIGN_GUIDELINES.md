# Application Design Guidelines

Design standards and principles for AWTO Flutter applications.

## 1. Inspection & Debug Mode

All AWTO Flutter applications must support the inspection system.

### Requirements

```dart
// Wrap the app with AwtoInspectApp
MaterialApp(
  builder: (context, child) {
    return AwtoInspectApp(
      enabled: kDebugMode,
      aiLogSink: AwtoConsoleAiLogSink(),
      child: child ?? const SizedBox.shrink(),
    );
  },
  home: YourScreen(),
);
```

### Debug ID Conventions

Every interactive element must have a stable debug ID:

```dart
AwtoInspectable(
  id: 'target-role',              // e.g., 'rabbit-hop-bt'
  label: 'Display Name',
  type: AwtoInspectType.button,
  command: AwtoCommandMetadata(...),
  safetyClass: AwtoSafetyClass.motion,
  sourceHint: 'MyScreen.dart:123',
  child: YourWidget(),
);
```

Good IDs: `fl-bt`, `rabbit-hop-bt`, `z-status-st`, `pdm-out3-toggle`

Bad IDs: `button1`, `panel2`, `q`, `f-button`

## 2. Test Mode & Failure Injection

Applications should support test mode for simulating failures and edge cases.

### Implementation

```dart
import 'test_mode.dart';

// Use TestMode to conditionally render failure states
if (TestMode.isEnabled('null-reference')) {
  return ErrorWidget();
}

// Or wrap the app
if (TestMode.enabled) {
  return TestModeHandler(child: _buildApp());
}
return _buildApp();
```

### Supported Failure Modes

Test mode provides tools to inject and test:

1. **null-reference** - Null pointer exceptions
2. **widget-overflow** - Layout overflows and sizing issues
3. **slow-render** - Slow rendering and animations
4. **memory-leak-simulate** - Memory allocation issues
5. **async-error** - Async operation failures
6. **state-corruption** - Invalid widget state
7. **missing-data** - Null or missing data
8. **infinite-loop** - Slow or infinite loops
9. **render-error** - Rendering target errors

### Usage

```dart
// In code
TestMode.setFailure('memory-leak-simulate');
TestMode.enabled  // true if failure is active
TestMode.activeFailure  // current failure mode

// In UI - drawer with mode selector
Drawer(
  child: ListView(
    children: [
      for (final mode in TestMode.failures)
        RadioListTile(
          title: Text(mode),
          value: mode,
          groupValue: _selectedMode,
          onChanged: (v) => setState(() => _selectedMode = v),
        ),
    ],
  ),
)
```

## 3. Hardware Safety

Command-based actions must declare safety requirements.

### Safety Classes

```dart
enum AwtoSafetyClass {
  viewOnly,          // No hardware action
  normal,            // Safe operation
  motion,            // Causes movement (requires confirmation)
  outputEnable,      // Energises output (requires confirmation)
  calibration,       // Changes calibration (requires confirmation)
  reset,             // Resets device (requires confirmation)
  firmware,          // Flashes firmware (requires confirmation)
  destructive,       // Erases data (requires confirmation)
  raw,               // Raw/manual mode (requires confirmation)
}
```

### Attaching Safety Metadata

```dart
AwtoInspectable(
  id: 'z-home-bt',
  label: 'Z Home',
  type: AwtoInspectType.button,
  command: const AwtoCommandMetadata(
    command: 'awto z home',
    target: 'z',
    action: 'home',
  ),
  safetyClass: AwtoSafetyClass.motion,  // High-risk action
  child: ElevatedButton(...),
);
```

High-safety actions (motion, reset, etc.) should trigger confirmation dialogs.

## 4. Command Wiring

All hardware actions must go through the project CLI/API, never direct serial access.

### ✅ Correct Pattern

```dart
// Command is metadata, not execution
final command = AwtoCommandMetadata(
  command: 'awto rabbit hop',
  target: 'rabbit',
  action: 'hop',
);

// Execution happens elsewhere (command bus, CLI adapter)
AwtoInspectable(
  id: 'rabbit-hop-bt',
  command: command,
  child: ElevatedButton(
    onPressed: () => commandBus.execute(command),
    child: Text('Hop'),
  ),
);
```

### ❌ Wrong Pattern

```dart
// Never do this:
ElevatedButton(
  onPressed: () {
    serialPort.write('AT+HOP\r\n');  // ❌ WRONG
  },
  child: Text('Hop'),
);
```

## 5. Status & State Management

Use explicit states and status labels.

### State Labels

```dart
AwtoInspectable(
  id: 'rabbit-st',
  label: 'Rabbit Status',
  type: AwtoInspectType.label,
  child: Chip(
    label: Text(
      status.toUpperCase(),  // 'OK', 'ERROR', 'DISCONNECTED'
    ),
    backgroundColor: _statusColor(status),
  ),
);
```

### Avoid Color-Only Status

```dart
// ❌ Bad - relies on colour alone
Container(
  color: isOk ? Colors.green : Colors.red,
  // No text label
);

// ✅ Good - text + colour
Row(
  children: [
    Container(
      width: 12,
      height: 12,
      color: isOk ? Colors.green : Colors.red,
    ),
    SizedBox(width: 8),
    Text(isOk ? 'OK' : 'FAULT'),  // Always text
  ],
);
```

## 6. Accessibility

Design for accessibility from the start.

### Requirements

- Every button must have text or tooltip
- Status indicators must include text labels
- Colour alone must not convey information
- Touch targets should be ≥ 48dp
- Keyboard navigation must work
- Labels must be meaningful

### Implementation

```dart
AwtoInspectable(
  id: 'my-button',
  label: 'Action Button',
  type: AwtoInspectType.button,
  child: Semantics(
    button: true,
    label: 'Do something important',
    enabled: true,
    child: ElevatedButton(
      onPressed: () => doSomething(),
      child: const Text('Do It'),
    ),
  ),
);
```

## 7. Logging & Debugging

All significant actions should be loggable via the inspection system.

### AI Logging

```dart
// Log to AI agent with context
final event = AwtoInspectEvent(
  event: 'ui_inspect_comment',
  object: objectMetadata,
  comment: 'This button is in the wrong location',
  screen: 'hardware-test-panel',
);
await aiLogSink.logInspectEvent(event);
```

### Command Logging

Log command execution:

```dart
void _executeCommand(String command) {
  // Log the action
  print('[COMMAND] $command');
  
  // Execute through CLI/API
  commandBus.execute(command);
  
  // Update UI with result
  setState(() => _lastCommand = command);
}
```

## 8. Testing with Debug IDs

Tests should select objects by debug ID, not coordinates.

### ✅ Correct Testing

```dart
// Find by debug ID
final button = find.byWidgetPredicate(
  (widget) => widget is AwtoInspectable && widget.id == 'rabbit-hop-bt',
);

await tester.tap(button);
expect(find.text('Command executed'), findsOneWidget);
```

### ❌ Wrong Testing

```dart
// Don't use coordinates (fragile)
await tester.tapAt(Offset(100, 200));
```

## 9. Source Hints

Provide source code hints for navigation.

```dart
AwtoInspectable(
  id: 'fl-bt',
  label: 'Front Left',
  type: AwtoInspectType.button,
  sourceHint: 'LevelPanel.dart:83',  // For code navigation
  child: ElevatedButton(...),
);
```

Format: `Filename.dart:LineNumber`

## 10. Error Handling

Errors should be visible, logged, and recoverable.

### Error Display

```dart
// Show errors in UI
if (error != null) {
  return Container(
    color: Colors.red.shade100,
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const Text('❌ Error'),
        Text(error),
        ElevatedButton(
          onPressed: _retry,
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

### Error Logging

```dart
try {
  await commandBus.execute(command);
} catch (e) {
  // Log error for debugging
  await aiLogSink.logInspectEvent(
    AwtoInspectEvent(
      event: 'error',
      comment: 'Command failed: $e',
    ),
  );
  
  // Show to user
  _showError(e.toString());
}
```

## Summary

| Aspect | Standard |
|--------|----------|
| **Inspection** | All apps must wrap with AwtoInspectApp |
| **Debug IDs** | Every interactive element has stable ID |
| **Commands** | All actions through CLI/API, never direct serial |
| **Safety** | High-risk actions declare safety class |
| **State** | Use text labels, not colours alone |
| **Accessibility** | Full keyboard/screen reader support |
| **Testing** | Select by debug ID, not coordinates |
| **Logging** | All actions loggable to AI system |
| **Errors** | Visible, logged, recoverable |
| **Test Mode** | Support failure injection for testing |

## References

- [CLI_CODING_STANDARDS.md](CLI_CODING_STANDARDS.md) - CLI design
- [AGENTS.md](AGENTS.md) - AI agent rules
- [FLUTTER_STYLE.md](FLUTTER_STYLE.md) - Code style
- [docs/AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md](docs/AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md) - Spec
