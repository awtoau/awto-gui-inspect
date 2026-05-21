import 'package:flutter/material.dart';
import 'package:awto_gui_inspect/awto_gui_inspect.dart';

/// Test mode utilities for injecting failures and bugs.
class TestMode {
  static bool enabled = false;
  static String? activeFailure;

  static const List<String> failures = [
    'none',
    'null-reference',
    'widget-overflow',
    'slow-render',
    'memory-leak-simulate',
    'async-error',
    'state-corruption',
    'missing-data',
    'infinite-loop',
    'render-error',
  ];

  static bool isEnabled(String failureMode) {
    return enabled && activeFailure == failureMode;
  }

  static void setFailure(String mode) {
    if (failures.contains(mode)) {
      activeFailure = mode;
      enabled = mode != 'none';
    }
  }
}

/// Widget that handles test mode failures.
class TestModeHandler extends StatefulWidget {
  final Widget child;
  final ValueChanged<String>? onFailureChange;

  const TestModeHandler({
    Key? key,
    required this.child,
    this.onFailureChange,
  }) : super(key: key);

  @override
  State<TestModeHandler> createState() => _TestModeHandlerState();
}

class _TestModeHandlerState extends State<TestModeHandler> {
  @override
  void initState() {
    super.initState();
    // Listen for test commands
    _setupTestListener();
  }

  void _setupTestListener() {
    // In a real app, this would listen to a service or command bus
    // For now, test mode is controlled via the UI
  }

  @override
  Widget build(BuildContext context) {
    if (TestMode.isEnabled('null-reference')) {
      return _NullReferenceTest();
    }

    if (TestMode.isEnabled('widget-overflow')) {
      return _OverflowTest();
    }

    if (TestMode.isEnabled('slow-render')) {
      return _SlowRenderTest(child: widget.child);
    }

    if (TestMode.isEnabled('memory-leak-simulate')) {
      return _MemoryLeakTest(child: widget.child);
    }

    if (TestMode.isEnabled('async-error')) {
      return _AsyncErrorTest(child: widget.child);
    }

    if (TestMode.isEnabled('state-corruption')) {
      return _StateCorruptionTest(child: widget.child);
    }

    if (TestMode.isEnabled('missing-data')) {
      return _MissingDataTest(child: widget.child);
    }

    if (TestMode.isEnabled('infinite-loop')) {
      return _InfiniteLoopTest(child: widget.child);
    }

    if (TestMode.isEnabled('render-error')) {
      return _RenderErrorTest();
    }

    return widget.child;
  }
}

/// Test 1: Null reference in widget tree
class _NullReferenceTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AwtoInspectable(
          id: 'test-null-ref',
          label: 'Null Reference Test',
          type: AwtoInspectType.custom,
          child: Container(
            color: Colors.red.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('🔴 Null Reference Error'),
                const SizedBox(height: 8),
                const Text('Trying to access null widget...'),
                const SizedBox(height: 16),
                // This would normally cause an error
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red,
                  child: const Text(
                    'Error accessing null reference',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Test 2: Widget overflow
class _OverflowTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          AwtoInspectable(
            id: 'test-overflow',
            label: 'Overflow Test',
            type: AwtoInspectType.custom,
            child: Container(
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('⚠️  Widget Overflow'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.orange,
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            'This row is forced to overflow by making text very long without wrapping',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Test 3: Slow rendering
class _SlowRenderTest extends StatefulWidget {
  final Widget child;

  const _SlowRenderTest({required this.child});

  @override
  State<_SlowRenderTest> createState() => _SlowRenderTestState();
}

class _SlowRenderTestState extends State<_SlowRenderTest>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AwtoInspectable(
          id: 'test-slow-render',
          label: 'Slow Render Test',
          type: AwtoInspectType.custom,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Container(
                color: Colors.yellow.shade100,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('⏱️  Slow Rendering'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _controller.value,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progress: ${(_controller.value * 100).toStringAsFixed(1)}%',
                    ),
                    const Text('(Heavy animation running)'),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Test 4: Memory leak simulation
class _MemoryLeakTest extends StatefulWidget {
  final Widget child;

  const _MemoryLeakTest({required this.child});

  @override
  State<_MemoryLeakTest> createState() => _MemoryLeakTestState();
}

class _MemoryLeakTestState extends State<_MemoryLeakTest> {
  List<List<int>> _memoryHog = [];

  void _allocateMemory() {
    setState(() {
      // Simulate memory allocation
      _memoryHog.add(List<int>.filled(1000000, 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AwtoInspectable(
          id: 'test-memory-leak',
          label: 'Memory Leak Test',
          type: AwtoInspectType.custom,
          child: Container(
            color: Colors.purple.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('💾 Memory Leak Simulation'),
                const SizedBox(height: 8),
                Text('Allocated: ${_memoryHog.length} blocks'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _allocateMemory,
                  child: const Text('Allocate Memory'),
                ),
                const Text('(Click to simulate memory leak)'),
              ],
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Test 5: Async error
class _AsyncErrorTest extends StatefulWidget {
  final Widget child;

  const _AsyncErrorTest({required this.child});

  @override
  State<_AsyncErrorTest> createState() => _AsyncErrorTestState();
}

class _AsyncErrorTestState extends State<_AsyncErrorTest> {
  String _status = 'Ready';

  void _triggerError() async {
    setState(() => _status = 'Loading...');
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _status = 'ERROR: Async operation failed!');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AwtoInspectable(
          id: 'test-async-error',
          label: 'Async Error Test',
          type: AwtoInspectType.custom,
          child: Container(
            color: Colors.red.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('⚡ Async Error'),
                const SizedBox(height: 8),
                Text(_status),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _triggerError,
                  child: const Text('Trigger Error'),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Test 6: State corruption
class _StateCorruptionTest extends StatefulWidget {
  final Widget child;

  const _StateCorruptionTest({required this.child});

  @override
  State<_StateCorruptionTest> createState() => _StateCorruptionTestState();
}

class _StateCorruptionTestState extends State<_StateCorruptionTest> {
  int _count = 0;
  String _corruptedState = '';

  void _corruptState() {
    setState(() {
      _count++;
      _corruptedState = 'State corrupted: count=$_count, hash=${_count.hashCode}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AwtoInspectable(
          id: 'test-state-corruption',
          label: 'State Corruption Test',
          type: AwtoInspectType.custom,
          child: Container(
            color: Colors.indigo.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('🔀 State Corruption'),
                const SizedBox(height: 8),
                Text(_corruptedState.isEmpty ? 'No corruption' : _corruptedState),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _corruptState,
                  child: const Text('Corrupt State'),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Test 7: Missing data
class _MissingDataTest extends StatelessWidget {
  final Widget child;

  const _MissingDataTest({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AwtoInspectable(
          id: 'test-missing-data',
          label: 'Missing Data Test',
          type: AwtoInspectType.custom,
          child: Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                Text('⚠️  Missing Data'),
                SizedBox(height: 8),
                Text('Status: UNKNOWN'),
                SizedBox(height: 8),
                Text('Value: null'),
                SizedBox(height: 8),
                Text('Timestamp: not available'),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Test 8: Infinite loop simulation
class _InfiniteLoopTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AwtoInspectable(
          id: 'test-infinite-loop',
          label: 'Infinite Loop Test',
          type: AwtoInspectType.custom,
          child: Container(
            color: Colors.cyan.shade100,
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                Text('🔁 Infinite Loop (Simulated)'),
                SizedBox(height: 8),
                Text('Loop counter: calculating...'),
                SizedBox(height: 8),
                Text('(Not actually infinite, just slow)'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Test 9: Render error
class _RenderErrorTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AwtoInspectable(
          id: 'test-render-error',
          label: 'Render Error Test',
          type: AwtoInspectType.custom,
          child: Container(
            color: Colors.red.shade100,
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                Text('🔴 Render Error'),
                SizedBox(height: 8),
                Text('Error rendering widget'),
                SizedBox(height: 8),
                Text('Exception: Invalid render state'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
