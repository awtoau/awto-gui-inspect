# AWTO Flutter GUI Inspect Library

Working name:

```text
awto_gui_inspect
```

This document defines a Flutter package/library for development-time GUI inspection, AI handoff, and hardware-safe command wiring.

The goal is not just ordinary Flutter UI debugging. The goal is to make the runtime GUI unambiguous to:

- the human developer
- the AI coding agent
- automated tests
- logs
- screenshots
- hardware-control code

Core rule:

```text
Point at anything. Inspect it. Copy it. Log it to AI. Reproduce it in tests. Trace it to source. Trace its action to the project CLI/API.
```

---

## 1. Does this already exist?

Partly, but not as a complete match.

Flutter already has the Flutter Inspector in DevTools. It is useful for exploring the widget tree, understanding layouts, diagnosing layout issues, selecting widgets on the device, showing guidelines, showing baselines, and viewing widget properties.

There are also Flutter packages that cover parts of the idea:

- `inspector`: runtime widget inspection, size inspection, padding inspection, colour picker, magnifier/zoom, and keyboard shortcuts.
- `flutter_debug_overlay`: app-level debug overlay with logs, HTTP request inspection, custom widgets, and global triggers.
- `flutter_ui_inspector`: debug-only UI state, rebuild frequency, rebuild heatmap, performance tracking, floating panel, and logging.
- Flutter framework debug tools: debug paint, performance overlay, widget inspector, source debugging, and DevTools.

However, the complete requirement here is different. This project needs a Flutter library that combines:

- stable project-specific debug IDs
- visible short IDs beside elements
- alpha-blended pixel/grid overlay
- full-window crosshair cursor
- line endpoint and control-point markers
- object hit-box display
- bottom status line showing what the pointer is over
- right-click or long-press inspect menu
- copy inspected object as JSON/text
- log inspected object to AI with optional comment
- object/action wiring metadata
- hardware safety metadata
- CLI/API command tracing
- test selectors based on debug IDs
- optional screenshot plus metadata export

Conclusion:

```text
Use existing Flutter tooling as inspiration and possibly as implementation references, but design awto_gui_inspect as a small project-specific library because the AI handoff, stable ID, and hardware command wiring requirements are not covered by one existing package.
```

---

## 2. Package scope

The package should provide development-time inspection wrappers and overlays.

It should not own the application state model.

It should not own the hardware command implementation.

It should not directly talk to serial devices.

It should expose metadata and route actions to the project command layer.

Recommended dependency direction:

```text
Flutter screen/widgets
    -> awto_gui_inspect metadata wrappers
    -> app state / command model
    -> project CLI/API adapter
    -> mux / serial / hardware layer
```

Forbidden dependency direction:

```text
Flutter button
    -> /dev/ttyACM1
    -> raw serial string
```

---

## 3. Minimum viable library

Start with a small, usable first version.

Required V1 features:

```text
1. AwtoInspectApp wrapper.
2. AwtoInspectable widget wrapper.
3. Stable debug ID registry.
4. Alpha-blended grid overlay.
5. Hit-box overlay for registered objects.
6. Full-window crosshair cursor in debug mode.
7. Bottom status line showing pointer position and hovered object.
8. Right-click / long-press inspect menu.
9. Copy object data as JSON.
10. Copy object data as plain text.
11. Log object to AI with optional comment callback.
12. Command/action metadata attached to widgets.
13. Safety metadata attached to command-capable widgets.
```

Do not overbuild V1.

The most important win is removing ambiguity.

---

## 4. Suggested package layout

```text
packages/
  awto_gui_inspect/
    pubspec.yaml
    README.md
    lib/
      awto_gui_inspect.dart
      src/
        awto_inspect_app.dart
        awto_inspectable.dart
        awto_inspect_controller.dart
        awto_inspect_registry.dart
        awto_inspect_metadata.dart
        awto_inspect_overlay.dart
        awto_grid_overlay.dart
        awto_crosshair_overlay.dart
        awto_hitbox_overlay.dart
        awto_status_line.dart
        awto_inspect_menu.dart
        awto_ai_log_sink.dart
        awto_clipboard_export.dart
        awto_safety_class.dart
        awto_command_metadata.dart
    example/
      lib/
        main.dart
```

---

## 5. Public API sketch

### 5.1 App wrapper

```dart
MaterialApp(
  builder: (context, child) {
    return AwtoInspectApp(
      enabled: kDebugMode,
      aiLogSink: MyAiLogSink(),
      child: child ?? const SizedBox.shrink(),
    );
  },
  home: const LevelPanel(),
);
```

### 5.2 Inspectable widget wrapper

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
);
```

### 5.3 Line or point metadata

```dart
AwtoInspectableLine(
  id: 'fl-ln',
  points: const [
    AwtoInspectablePoint(id: 'fl-ln:p1', x: 212, y: 477),
    AwtoInspectablePoint(id: 'fl-ln:p2', x: 280, y: 530),
  ],
  child: CustomPaint(
    painter: FrontLeftLinePainter(),
  ),
);
```

### 5.4 AI log sink

```dart
abstract class AwtoAiLogSink {
  Future<void> logInspectEvent(AwtoInspectEvent event);
}
```

Example implementation options:

```text
console logger
local file logger
HTTP POST to local development service
copy-to-clipboard only
VS Code task/extension bridge later
```

---

## 6. Stable debug ID rules

Every significant GUI object must have a stable debug ID.

The debug ID must be:

- unique within the screen or module
- stable across builds unless the object is intentionally renamed
- short
- easy to type
- visible in debug mode
- used in code, logs, tests, screenshots, and AI prompts

Good examples:

```text
fl-bt       front-left button
fr-bt       front-right button
rl-bt       rear-left button
rr-bt       rear-right button
fl-ln       front-left line
fl-ln:p1    front-left line endpoint 1
fl-ln:p2    front-left line endpoint 2
z-st        z status label
pdm-out3    PDM output 3 control
mux-st      mux status label
hw-log      hardware log panel
```

Bad examples:

```text
button1
button2
f-button
q
thing
panel2
rect_17
unnamed
```

Rule:

```text
If a user cannot easily type the ID into an AI prompt, the ID is not good enough.
```

---

## 7. ID naming convention

Use this general format:

```text
<target>-<role>[:subpart]
```

Examples:

```text
fl-bt
fl-st
fl-ln:p1
rabbit-hop-bt
lion-roar-bt
z-home-bt
pdm-out3-toggle
mux-port-list
```

Recommended role suffixes:

```text
bt       button
st       status text / status label
ln       line
pt       point
grp      group
pan      panel
dlg      dialog
lst      list
tbl      table
inp      input
out      output
led      indicator
log      log view
ctx      context menu
```

For hardware-related UI, prefer logical names, not serial-port names.

Good:

```text
rabbit-hop-bt
z-status-st
pdm-out3-toggle
```

Bad:

```text
ttyacm1-button
dev2-status
serial-panel-3
```

---

## 8. Visual overlay requirements

In Visual Debug / AI Inspect Mode, the GUI shall show a non-intrusive alpha-blended overlay.

Required overlay features:

- pixel/grid overlay
- optional major/minor grid spacing
- full-window crosshair cursor
- visible object hit boxes
- visible layout bounds
- visible line endpoints
- visible control points
- visible anchor points
- visible object debug IDs
- hover highlight for the object under the pointer
- selection highlight for selected objects
- bottom status line showing pointer target

Recommended defaults:

```text
minor grid: 8 px
major grid: 64 px
minor alpha: low
major alpha: medium-low
object bounds alpha: medium
selected object alpha: high
```

---

## 9. Cursor and pointer behaviour

In Visual Debug / AI Inspect Mode, the mouse cursor should become a full-window crosshair.

Behaviour:

- vertical line through the pointer
- horizontal line through the pointer
- pointer coordinate shown in status line
- optional snap coordinate shown separately
- object under pointer shown in status line

The GUI must distinguish between:

```text
mouse position
snap position
selected object origin
object bounds
object anchor/control points
```

This avoids ambiguity when snapping, hit testing, scaling, or transforms are active.

---

## 10. Object markers

Every important object shall show a small crosshair marker in debug mode.

For rectangular controls:

- marker at centre
- optional markers at corners
- ID label near centre or top-left
- hit bounds outlined

For lines:

- marker at each endpoint
- marker at each control point
- ID label near midpoint
- endpoint IDs visible when hovered or selected

For paths/polylines:

- marker for every vertex
- marker for every control point
- segment index visible on hover

For groups/panels:

- outer bounds shown
- group ID visible
- child count optionally visible

---

## 11. Bottom status line

Visual Debug / AI Inspect Mode must show a persistent status line at the bottom of the window.

The status line should constantly show what the pointer is over.

Example for a button:

```text
mouse x=428 y=312 | over=fl-bt | type=button | state=enabled | bounds=390,288 76x48 | action=awto level front-left
```

Example for a line endpoint:

```text
mouse x=212 y=477 | over=fl-ln:p1 | type=line_endpoint | parent=fl-ln | logical=0.125,0.842 | snap=208,480
```

Example for empty space:

```text
mouse x=822 y=119 | over=none | screen=level-panel | snap=824,120 | grid=8px
```

---

## 12. Right-click / long-press inspect menu

Desktop:

```text
right-click object -> inspect menu
```

Touch/mobile:

```text
long-press object -> inspect menu
```

Example menu for a button:

```text
Inspect rabbit-hop-bt
Copy ID
Copy object data as JSON
Copy object data as text
Copy action command
Log to AI agent
Log to AI agent with comment...
Open source definition
Highlight related objects
Show event wiring
```

Example menu for a line endpoint:

```text
Inspect fl-ln:p1
Copy point data as JSON
Copy point data as text
Copy parent line data
Log point to AI agent
Log point to AI agent with comment...
Highlight parent line
Show constraints
```

Example menu for empty space:

```text
Inspect point 822,119
Copy point data
Copy screen data
Log point to AI agent
Log point to AI agent with comment...
```

---

## 13. Copy formats

The library should support at least two copy formats:

1. Human-readable text
2. Machine-readable JSON

### Human-readable copy example

```text
ui_id: fl-bt
type: button
label: Front Left
screen: level-panel
mouse: 428,312
bounds: 390,288 76x48
state: enabled
action: awto level front-left
source: LevelPanel.dart:83
```

### JSON copy example

```json
{
  "ui_id": "fl-bt",
  "type": "button",
  "label": "Front Left",
  "screen": "level-panel",
  "mouse": { "x": 428, "y": 312 },
  "bounds": { "x": 390, "y": 288, "w": 76, "h": 48 },
  "state": "enabled",
  "action": "awto level front-left",
  "source": "LevelPanel.dart:83",
  "nearby_objects": ["fl-st", "fl-ln"]
}
```

### Point copy example

```json
{
  "ui_id": "fl-ln:p1",
  "type": "line_endpoint",
  "parent": "fl-ln",
  "screen": "level-panel",
  "mouse": { "x": 212, "y": 477 },
  "screen_point": { "x": 212, "y": 477 },
  "snap_point": { "x": 208, "y": 480 },
  "logical_point": { "x": 0.125, "y": 0.842 }
}
```

---

## 14. AI log behaviour

The library should let the user send inspected context directly to an AI agent.

Required commands:

```text
Log object to AI
Log object to AI with comment
Log point to AI
Log point to AI with comment
Log selected objects to AI
Log current screen to AI
```

The log entry must include:

- timestamp
- screen/view name
- selected object ID
- object type
- bounds
- pointer location
- object state
- related command/action
- optional user comment
- optional screenshot reference

Example AI log payload:

```json
{
  "event": "ui_inspect_comment",
  "timestamp": "2026-05-21T14:32:18+10:00",
  "screen": "level-panel",
  "comment": "this button is too close to the status text",
  "object": {
    "ui_id": "fl-bt",
    "type": "button",
    "label": "Front Left",
    "bounds": { "x": 390, "y": 288, "w": 76, "h": 48 },
    "state": "enabled",
    "action": "awto level front-left"
  },
  "mouse": { "x": 428, "y": 312 },
  "nearby_objects": ["fl-st", "fl-ln"]
}
```

---

## 15. Object hierarchy inspector

V2 should provide an optional inspector panel similar to Qt Designer, browser DevTools, or Flutter DevTools.

Recommended layout:

```text
+----------------------+--------------------------------+----------------------+
| Object Tree          | Runtime GUI                    | Property Inspector   |
|                      |                                |                      |
| level-panel          |   +------------------------+   | ui_id: fl-bt         |
|  fl-grp              |   | grid overlay           |   | type: button         |
|   fl-bt              |   | crosshair cursor       |   | label: Front Left    |
|   fl-st              |   | visible hit boxes      |   | action: awto ...     |
|   fl-ln              |   +------------------------+   | bounds: ...          |
|  fr-grp              |                                | state: enabled       |
|                      |                                | source: ...          |
+----------------------+--------------------------------+----------------------+
| mouse x=428 y=312 | over=fl-bt | snap=424,312 | screen=level-panel       |
+-----------------------------------------------------------------------------+
```

The Object Tree should show hierarchy, not just drawing order.

Example:

```text
level-panel
  header-grp
    title-st
    mux-st
  body-grp
    fl-grp
      fl-bt
      fl-st
      fl-ln
        fl-ln:p1
        fl-ln:p2
    fr-grp
      fr-bt
      fr-st
      fr-ln
  footer-grp
    hw-log
    status-line
```

---

## 16. Property inspector fields

Minimum fields:

```text
ui_id
object type
label/text
state
bounds
visibility
enabled/disabled
hovered/selected/focused
associated action
source location, if available
parent object
children
accessibility label
```

For hardware action buttons, include:

```text
command
command target
safety class
requires confirmation
last command timestamp
last result
```

Example:

```text
ui_id: rabbit-hop-bt
type: button
label: Rabbit Hop
screen: hardware-test-panel
action: awto rabbit hop
safety_class: motion
requires_confirmation: true
state: enabled
last_result: ok
source: HardwareTestPanel.dart:112
```

---

## 17. Event wiring inspector

The library should let developers inspect what an object is wired to.

For a button, show:

```text
ui_id: rabbit-hop-bt
signal: pressed
handler: HardwareActions.rabbitHop()
command: awto rabbit hop
permission: dev_only
safety_class: motion
confirmation: required
```

For a status label, show:

```text
ui_id: rabbit-status-st
source: HardwareState.rabbit.status
data age: 183 ms
last update: 2026-05-21T14:34:01+10:00
stale threshold: 1000 ms
```

---

## 18. Hardware command safety classes

Every command-capable UI object should declare a safety class.

Recommended safety classes:

```text
view_only       no hardware action
normal          harmless query or display action
motion          causes physical movement
output_enable   energises an output
calibration     changes calibration or reference values
reset           resets a controller/device
firmware        flashes or updates firmware
destructive     erases settings or persistent data
raw             raw/manual command mode
```

Debug inspector should show the safety class.

Example:

```text
ui_id: z-home-bt
action: awto z home
safety_class: motion
requires_confirmation: true
```

Rules:

```text
Motion, output-enable, calibration, reset, firmware, destructive, and raw actions require special handling.
AI agents must prefer named safe commands over raw/manual command mode.
```

---

## 19. State-machine design

For complex screens, use explicit states.

Example states:

```text
disconnected
connecting
connected_idle
command_running
faulted
manual_override
calibration_mode
firmware_update_mode
```

Example transition table:

```text
state              event                 next state
-------------------------------------------------------------
disconnected       connect_clicked        connecting
connecting         connect_ok             connected_idle
connecting         connect_failed         faulted
connected_idle     command_started        command_running
command_running    command_ok             connected_idle
command_running    command_failed         faulted
faulted            reset_clicked          connecting
connected_idle     manual_unlock          manual_override
manual_override    manual_lock            connected_idle
```

The inspector should expose current screen state.

Example status line:

```text
screen=hardware-test-panel | state=command_running | over=rabbit-hop-bt | command=awto rabbit hop
```

---

## 20. Wireframe: basic runtime screen with debug overlay

```text
+--------------------------------------------------------------------------------+
| Level Control                                                         mux: OK   |
+--------------------------------------------------------------------------------+
|                                                                                |
|   . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .            |
|                                                                                |
|        +----------------+                         +----------------+            |
|        |  Front Left    |                         |  Front Right   |            |
|        |   [fl-bt]+     |                         |   [fr-bt]+     |            |
|        +----------------+                         +----------------+            |
|              + fl-ln:p1                               + fr-ln:p1                |
|              |                                         |                        |
|              |                                         |                        |
|              + fl-ln:p2                               + fr-ln:p2                |
|                                                                                |
|        +----------------+                         +----------------+            |
|        |   Rear Left    |                         |   Rear Right   |            |
|        |   [rl-bt]+     |                         |   [rr-bt]+     |            |
|        +----------------+                         +----------------+            |
|                                                                                |
| ------------------------------------------------------------------------------ |
| mouse x=428 y=312 | over=fl-bt | type=button | action=awto level front-left    |
+--------------------------------------------------------------------------------+
```

Legend:

```text
+ beside label = debug crosshair marker
[fl-bt]        = visible debug ID
. . .          = alpha-blended grid
status line    = live pointer/object data
```

---

## 21. Wireframe: right-click inspect menu

```text
+--------------------------------------------------------------------------------+
|                                                                                |
|        +----------------+                                                       |
|        |  Front Left    |                                                       |
|        |   [fl-bt]+     |                                                       |
|        +----------------+                                                       |
|               |                                                                |
|               |  +--------------------------------------+                      |
|               |  | Inspect fl-bt                        |                      |
|               |  |--------------------------------------|                      |
|               |  | Copy ID                              |                      |
|               |  | Copy object data as JSON             |                      |
|               |  | Copy object data as text             |                      |
|               |  | Copy action command                  |                      |
|               |  | Log to AI agent                      |                      |
|               |  | Log to AI agent with comment...      |                      |
|               |  | Open source definition               |                      |
|               |  | Show event wiring                    |                      |
|               |  +--------------------------------------+                      |
|                                                                                |
+--------------------------------------------------------------------------------+
```

---

## 22. Wireframe: hardware control screen

```text
+--------------------------------------------------------------------------------+
| Hardware Test Panel                                                   DEV MODE  |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Rabbit                              Lion                         Z Control     |
|  +--------------------------+        +-------------------+        +-----------+ |
|  | Status: OK [rabbit-st]+  |        | Status: OK        |        | z-st: OK  | |
|  |                          |        |                   |        |           | |
|  | [rabbit-hop-bt]+ Hop     |        | [lion-roar-bt]+   |        | [z-home]  | |
|  | [rabbit-reset-bt]+ Reset |        | Roar              |        | [z-stop]  | |
|  +--------------------------+        +-------------------+        +-----------+ |
|                                                                                |
|  Command log [hw-log]                                                          |
|  ---------------------------------------------------------------------------   |
|  14:30:12 awto rabbit hop -> OK                                                |
|  14:31:05 awto z status -> OK                                                  |
|                                                                                |
| mouse x=188 y=241 | over=rabbit-hop-bt | action=awto rabbit hop | safety=motion |
+--------------------------------------------------------------------------------+
```

---

## 23. Wireframe: AI comment flow

```text
+--------------------------------------------------------------------------------+
| Log to AI agent with comment                                                   |
+--------------------------------------------------------------------------------+
| Object: fl-bt                                                                  |
| Type: button                                                                   |
| Bounds: 390,288 76x48                                                          |
| Action: awto level front-left                                                  |
|                                                                                |
| Comment:                                                                       |
| +----------------------------------------------------------------------------+ |
| | This button is too close to the status text. Move it down about 12 px.      | |
| +----------------------------------------------------------------------------+ |
|                                                                                |
| [Copy JSON]                                      [Cancel] [Send to AI Log]      |
+--------------------------------------------------------------------------------+
```

---

## 24. Debug overlay controls

Add a small overlay control panel or hotkey menu.

Example:

```text
+------------------------------+
| Debug Overlay                |
|------------------------------|
| [x] Grid                     |
| [x] Hit boxes                |
| [x] Object IDs               |
| [x] Crosshair cursor         |
| [x] Line points              |
| [x] Status line              |
| [ ] Accessibility labels     |
| [ ] Command wiring           |
| [ ] Data age/staleness       |
|                              |
| Grid: 8 px                   |
| Snap: on                     |
| Alpha: 30%                   |
+------------------------------+
```

Recommended hotkeys:

```text
F9      toggle Visual Debug / AI Inspect Mode
F10     toggle grid
F11     toggle object IDs
F12     toggle property inspector
Ctrl+I  inspect object under pointer
Ctrl+L  log object under pointer to AI
Ctrl+C  copy inspected object data
```

Avoid stealing standard OS shortcuts unless there is a strong reason.

---

## 25. Accessibility checks

The inspector should help find accessibility problems early.

Minimum checks:

```text
missing accessible name
ambiguous label
button without text or tooltip
touch target too small
low contrast warning
status colour without text label
keyboard focus missing
keyboard order unclear
```

For hardware control GUIs, do not rely on colour alone.

Bad:

```text
red = fault
green = OK
```

Good:

```text
FAULT - red indicator
OK - green indicator
DISCONNECTED - grey indicator
```

---

## 26. Testing requirements

The GUI must be testable using stable debug IDs.

Tests should select objects by debug ID, not by screen coordinate unless testing layout specifically.

Good:

```text
click("rabbit-hop-bt")
expect_status("rabbit-st", "OK")
expect_command_logged("awto rabbit hop")
```

Bad:

```text
click(184, 242)
expect_text_near(300, 200, "OK")
```

Coordinate-based tests are allowed only for overlay/layout/snap testing.

---

## 27. Screenshot and AI handoff requirements

When capturing a screenshot for the AI, include optional sidecar metadata.

Recommended files:

```text
screenshot.png
screenshot.ui.json
screenshot.ai.txt
```

The JSON should include:

```text
screen name
window size
device pixel ratio
grid settings
visible object list
selected object
hovered object
pointer position
current app state
recent command log
```

This lets the AI reason from both image and data.

---

## 28. Implementation notes for Flutter

Potential Flutter implementation pieces:

```text
OverlayEntry or Stack for drawing the overlay
Listener / MouseRegion for pointer tracking
GestureDetector for long-press on touch devices
ContextMenuRegion or platform menu equivalent for desktop context menus
CustomPainter for grid, crosshair, hit boxes, and markers
InheritedWidget or Provider-style controller for registry access
GlobalKey or RenderObject inspection for bounds capture
Clipboard API for copy-to-clipboard
kDebugMode gating for debug-only behaviour
```

Possible object registration model:

```text
AwtoInspectable widget registers metadata with AwtoInspectRegistry.
Registry maps debug ID -> metadata + current bounds.
Overlay reads registry and paints hit boxes, IDs, markers, and selected/hovered state.
Pointer tracker asks registry which object is under the pointer.
Context menu uses registry metadata to export/log/copy exact object data.
```

---

## 29. Later enhancements

Useful future additions:

```text
object tree panel
property inspector panel
event wiring inspector
state-machine viewer
layout constraint viewer
measurement tool
alignment guides
overlap detection
touch target checker
accessibility checker
stale-data highlighting
command replay
AI log history viewer
screenshot + metadata export
source jump from object to code
```

---

## 30. Codex prompt to start implementation

Use this prompt when asking Codex to implement the first version:

```text
Read AGENTS.md and docs/AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md.

Design and implement the first version of the awto_gui_inspect Flutter package.

Start with:
- AwtoInspectApp wrapper
- AwtoInspectable wrapper
- debug ID registry
- alpha-blended grid overlay
- object ID labels
- hit box overlay
- full-window crosshair cursor
- bottom status line showing mouse position and hovered object
- right-click / long-press inspect menu
- copy object data as JSON and text
- AI log sink interface with a console implementation

Do not wire GUI code directly to serial ports.
Do not add raw hardware access.
If an action needs hardware, represent it as command metadata only.
All real hardware actions must go through the project CLI/API.
```

---

## 31. Final design rule

The development GUI should be self-describing.

A screenshot alone is not enough.

A vague human description is not enough.

The GUI must expose enough metadata that the human, the AI agent, tests, logs, and source code all refer to the same object in the same way.
