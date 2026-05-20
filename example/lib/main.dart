import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awto_gui_inspect/awto_gui_inspect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWTO GUI Inspect Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      builder: (context, child) {
        return AwtoInspectApp(
          enabled: kDebugMode,
          aiLogSink: AwtoConsoleAiLogSink(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HardwareTestPanel(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HardwareTestPanel extends StatefulWidget {
  const HardwareTestPanel({Key? key}) : super(key: key);

  @override
  State<HardwareTestPanel> createState() => _HardwareTestPanelState();
}

class _HardwareTestPanelState extends State<HardwareTestPanel> {
  String _lastCommand = 'No command executed';

  void _executeCommand(String command) {
    setState(() {
      _lastCommand = command;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Would execute: $command')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware Test Panel'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AwtoInspectable(
              id: 'mux-st',
              label: 'Mux Status',
              type: AwtoInspectType.label,
              child: Center(
                child: Text(
                  'mux: OK',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rabbit section
              _buildMotorSection(
                id: 'rabbit',
                title: 'Rabbit',
                statusId: 'rabbit-st',
                statusText: 'OK',
                buttons: [
                  _buildMotorButton(
                    id: 'rabbit-hop-bt',
                    label: 'Hop',
                    command: 'awto rabbit hop',
                    safetyClass: AwtoSafetyClass.motion,
                    source: 'HardwareTestPanel.dart:85',
                  ),
                  _buildMotorButton(
                    id: 'rabbit-reset-bt',
                    label: 'Reset',
                    command: 'awto rabbit reset',
                    safetyClass: AwtoSafetyClass.reset,
                    source: 'HardwareTestPanel.dart:92',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lion section
              _buildMotorSection(
                id: 'lion',
                title: 'Lion',
                statusId: 'lion-st',
                statusText: 'OK',
                buttons: [
                  _buildMotorButton(
                    id: 'lion-roar-bt',
                    label: 'Roar',
                    command: 'awto lion roar',
                    safetyClass: AwtoSafetyClass.motion,
                    source: 'HardwareTestPanel.dart:107',
                  ),
                  _buildMotorButton(
                    id: 'lion-reset-bt',
                    label: 'Reset',
                    command: 'awto lion reset',
                    safetyClass: AwtoSafetyClass.reset,
                    source: 'HardwareTestPanel.dart:114',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Z-axis section
              _buildZAxisSection(),
              const SizedBox(height: 24),

              // Command log
              _buildCommandLog(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotorSection({
    required String id,
    required String title,
    required String statusId,
    required String statusText,
    required List<Widget> buttons,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AwtoInspectable(
                id: statusId,
                label: '$title Status',
                type: AwtoInspectType.label,
                child: Chip(
                  label: Text('Status: $statusText'),
                  backgroundColor: Colors.green.shade100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons,
          ),
        ],
      ),
    );
  }

  Widget _buildMotorButton({
    required String id,
    required String label,
    required String command,
    required AwtoSafetyClass safetyClass,
    required String source,
  }) {
    return AwtoInspectable(
      id: id,
      label: label,
      type: AwtoInspectType.button,
      command: AwtoCommandMetadata(
        command: command,
        target: command.split(' ')[1],
        action: command.split(' ')[2],
      ),
      safetyClass: safetyClass,
      sourceHint: source,
      child: ElevatedButton(
        onPressed: () => _executeCommand(command),
        child: Text(label),
      ),
    );
  }

  Widget _buildZAxisSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Z Control',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AwtoInspectable(
                id: 'z-st',
                label: 'Z Status',
                type: AwtoInspectType.label,
                child: Chip(
                  label: const Text('z: OK'),
                  backgroundColor: Colors.green.shade100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMotorButton(
                id: 'z-home-bt',
                label: 'Home',
                command: 'awto z home',
                safetyClass: AwtoSafetyClass.motion,
                source: 'HardwareTestPanel.dart:180',
              ),
              _buildMotorButton(
                id: 'z-stop-bt',
                label: 'Stop',
                command: 'awto z stop',
                safetyClass: AwtoSafetyClass.motion,
                source: 'HardwareTestPanel.dart:187',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommandLog() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: AwtoInspectable(
        id: 'hw-log',
        label: 'Hardware Command Log',
        type: AwtoInspectType.log,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Command',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(8),
              child: SelectableText(
                _lastCommand,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Courier New',
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
