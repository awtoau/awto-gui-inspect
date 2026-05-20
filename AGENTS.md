# AI Agent Rules

These rules apply to AI agents working in this repository.

## Hardware access

Use one project CLI/API for all hardware actions.

Do not access `/dev/ttyACM*`, `/dev/ttyUSB*`, serial ports, baud rates, or raw device protocols directly from GUI code, tests, scripts, or ad-hoc shell commands unless explicitly requested by the project owner.

All hardware control must go through the project CLI/API.

Examples:

```bash
awto rabbit hop
awto lion roar
awto z status
awto mux status
```

If a needed hardware action does not exist, add or propose a project CLI/API command first. Do not bypass the CLI.

## Flutter GUI development

Follow `docs/AWTO_FLUTTER_GUI_INSPECT_LIBRARY.md`.

During development, Flutter GUIs must support Visual Debug / AI Inspect Mode.

Minimum requirements:

1. Every interactive object has a stable debug ID.
2. Debug mode shows object IDs and hit boxes.
3. Debug mode uses a full-window crosshair cursor.
4. Bottom status line shows mouse position and hovered object.
5. Right-click or long-press object provides copy/inspect actions.
6. Inspected object data can be copied as JSON.
7. Inspected object data can be logged for AI review, with an optional user comment.
8. GUI actions call the project CLI/API, not raw serial.

Use stable IDs such as:

```text
fl-bt
fr-bt
rl-bt
rr-bt
fl-ln:p1
rabbit-hop-bt
lion-roar-bt
z-st
pdm-out3-toggle
```

Avoid vague IDs such as:

```text
button1
panel2
thing
f-button
q
```

## AI behaviour

Before editing GUI code, inspect existing object IDs, command wiring, and debug overlay conventions.

Do not invent a new hardware-control path.

Do not wire GUI buttons directly to serial ports.

If a GUI object does not have a debug ID, add one before making further GUI changes.

When the user provides copied inspect data, treat it as the source of truth for object identity, geometry, state, and command wiring.

When implementing UI tests, select objects by stable debug ID rather than coordinates unless the test is specifically about layout geometry.
