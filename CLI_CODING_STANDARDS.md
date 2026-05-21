# CLI Coding Standards & Application Design

## Core Principles

### 1. AI-Agent Friendly
- **JSON Output**: All output must support `--json` flag for machine parsing
- **Silent on Failure**: Don't show verbose output if operations fail (quiet by default on errors)
- **Log Tailing**: Support `--tail N` to show last N lines on failure for debugging
- **Structured Errors**: Return structured error data, not free-form text

### 2. Minimal Output
- **Don't Show Stuff That Fails**: If an operation fails, suppress verbose output
- **Status Only**: Show status indicators (✅/❌) only when needed
- **Let Logs Speak**: On error, only show relevant error logs via `--tail`

### 3. Machine-First Design
- CLI must be designed for both human and AI agent use
- JSON as first-class output format
- Predictable exit codes (0 = success, 1 = error, 2 = skipped)
- Structured logging for AI consumption

## Implementation Pattern

```python
class CLIRunner:
    def __init__(self, json_output=False, tail_lines=0, quiet=False):
        self.json_output = json_output
        self.tail_lines = tail_lines  # 0 = don't tail logs
        self.quiet = quiet
```

## Command Signatures

### Standard Arguments (All Commands)

```
--json                Output as JSON for AI agents
--tail N              Show last N lines of logs on failure (default: 0)
--quiet               Suppress output on success
--verbose             Show detailed output (overrides quiet)
--log-file FILE       Write logs to file
```

### Example Usage

```bash
# For Humans
python awto.py build linux

# For AI Agents
python awto.py build linux --json --tail 50

# Quiet Mode (no output on success, show errors)
python awto.py test verify --quiet --tail 20

# Full Debug
python awto.py deploy linux --verbose --json --tail 100
```

## JSON Output Format

All commands with `--json` return structured JSON:

```json
{
  "command": "build",
  "target": "linux",
  "status": "success|error|skipped",
  "exit_code": 0,
  "timestamp": "2026-05-21T10:30:00+10:00",
  "duration_ms": 5432,
  "output": {
    "message": "Linux app built successfully",
    "details": {
      "binary": "/path/to/app",
      "size_mb": 20.5
    }
  },
  "errors": null
}
```

## Error Handling

### On Failure with `--tail`

**Silent by default:**
```bash
$ python awto.py build linux
# (No output on error)
$ echo $?
1
```

**With tail for debugging:**
```bash
$ python awto.py build linux --tail 20
# (Shows last 20 lines of error)
```

**JSON format:**
```bash
$ python awto.py build linux --json --tail 50
{
  "status": "error",
  "exit_code": 1,
  "errors": [
    "Compilation failed",
    "Missing dependency: gtk3"
  ],
  "log_tail": [
    "line 1 of last 50...",
    "line 50: FINAL ERROR MESSAGE"
  ]
}
```

## Rules

### ✅ DO:
- Return JSON when `--json` is requested
- Show only errors when operations fail
- Use `--tail` for log inspection
- Keep default output minimal
- Exit with proper codes (0/1/2)
- Structure all output (no free-form text)
- Support piping and automation

### ❌ DON'T:
- Print verbose success messages by default
- Show spinner/progress bars (use `--verbose` for those)
- Mix human and JSON output
- Use ANSI colors in JSON mode
- Print empty lines or decorative output
- Assume human reading

## Examples

### Build Command

**JSON output (AI agents):**
```bash
python awto.py build linux --json
```

**Response on success:**
```json
{
  "command": "build",
  "status": "success",
  "exit_code": 0,
  "output": {
    "message": "Built successfully",
    "binary": "/path/to/bundle/awto_gui_inspect_example",
    "size_mb": 20.5
  }
}
```

**Response on error with tail:**
```bash
python awto.py build linux --json --tail 30
```

```json
{
  "command": "build",
  "status": "error",
  "exit_code": 1,
  "errors": [
    "Flutter build failed"
  ],
  "log_tail": [
    "Error: Package gtk3 not found",
    "See: sudo apt-get install libgtk-3-0"
  ]
}
```

### Test Command

**For AI agents (no output on success):**
```bash
python awto.py test verify --json --quiet
# On success: (silent, exit 0)
# On failure: (JSON with error logs)
```

**For debugging:**
```bash
python awto.py test verify --json --tail 100 --verbose
# Always shows structured output + last 100 log lines
```

## Design Patterns

### Pattern 1: AI-Safe Wrapper

```python
def run_with_logging(cmd, tail_lines=0):
    """Run command, return structured result."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0 and tail_lines > 0:
            # On error, show last N lines
            lines = result.stderr.split('\n')[-tail_lines:]
            return {"status": "error", "log_tail": lines}
        return {"status": "success" if result.returncode == 0 else "error"}
    except Exception as e:
        return {"status": "error", "error": str(e)}
```

### Pattern 2: JSON-First Output

```python
def output_result(result, json_output=False):
    """Output result as JSON or human-readable."""
    if json_output:
        print(json.dumps(result, indent=2))
    elif result["status"] != "success":
        # Errors always shown
        for error in result.get("errors", []):
            print(f"Error: {error}")
    # Success: silent by default
```

### Pattern 3: Quiet Mode

```python
def log_message(message, quiet=False, level="info"):
    """Log with quiet mode support."""
    if quiet and level == "info":
        return  # Suppress info messages in quiet mode
    if level in ["error", "warning"]:
        print(message)  # Always show errors/warnings
```

## AI Agent Integration

When AI agents invoke CLI commands:

```bash
# Standard: no output on success, errors on failure
python awto.py build linux

# For logging: get full result as JSON
python awto.py build linux --json

# For debugging: add tail to see error context
python awto.py build linux --json --tail 30

# For autonomous testing: pipe JSON to tools
python awto.py test verify --json | jq '.status'
```

## Summary

- **Default**: Silent on success, show errors on failure
- **JSON**: Machine-readable output for AI agents
- **Tail**: Last N log lines for debugging without verbosity
- **Exit codes**: 0 (success), 1 (error), 2 (skipped)
- **No fluff**: Only show what's necessary
- **Automation-first**: Design for scripts and agents

This is the **coding standard and app design standard** for all CLI tools in AWTO.
