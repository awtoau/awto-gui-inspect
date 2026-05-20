import 'package:flutter/material.dart';
import 'awto_inspect_metadata.dart';
import 'awto_clipboard_export.dart';
import 'awto_ai_log_sink.dart';

class AwtoInspectMenu {
  static void showObjectMenu({
    required BuildContext context,
    required AwtoInspectableObjectState object,
    required Offset position,
    required AwtoAiLogSink? aiLogSink,
    required Function(String)? onSourceOpen,
  }) {
    final menuItems = <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        enabled: false,
        child: Text('Inspect ${object.metadata.id}'),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'copy_id',
        child: const Text('Copy ID'),
        onTap: () async {
          await AwtoClipboardExport.copyObjectId(object.metadata.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID copied')),
            );
          }
        },
      ),
      PopupMenuItem<String>(
        value: 'copy_json',
        child: const Text('Copy object data as JSON'),
        onTap: () async {
          await AwtoClipboardExport.copyObjectAsJson(object);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Object data copied as JSON')),
            );
          }
        },
      ),
      PopupMenuItem<String>(
        value: 'copy_text',
        child: const Text('Copy object data as text'),
        onTap: () async {
          await AwtoClipboardExport.copyObjectAsText(object);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Object data copied as text')),
            );
          }
        },
      ),
      if (object.metadata.command != null)
        PopupMenuItem<String>(
          value: 'copy_command',
          child: const Text('Copy action command'),
          onTap: () async {
            await AwtoClipboardExport.copyCommandText(object.metadata.command!.toString());
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Command copied')),
              );
            }
          },
        ),
      if (aiLogSink != null) ...[
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'log_to_ai',
          child: const Text('Log to AI agent'),
          onTap: () async {
            final event = AwtoInspectEvent(
              event: 'ui_inspect',
              object: object.metadata,
              mousePosition: null,
            );
            await aiLogSink.logInspectEvent(event);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged to AI')),
              );
            }
          },
        ),
        PopupMenuItem<String>(
          value: 'log_with_comment',
          child: const Text('Log to AI agent with comment...'),
          onTap: () {
            _showCommentDialog(context, object, aiLogSink);
          },
        ),
      ],
      const PopupMenuDivider(),
      if (object.metadata.sourceHint != null)
        PopupMenuItem<String>(
          value: 'open_source',
          child: const Text('Open source definition'),
          onTap: () {
            if (onSourceOpen != null) {
              onSourceOpen(object.metadata.sourceHint!);
            }
          },
        ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: menuItems,
    );
  }

  static void _showCommentDialog(
    BuildContext context,
    AwtoInspectableObjectState object,
    AwtoAiLogSink aiLogSink,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log to AI agent with comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Object: ${object.metadata.id}'),
              Text('Type: ${object.metadata.type.name}'),
              const SizedBox(height: 16),
              const Text('Comment:'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add your comment here...',
                  contentPadding: const EdgeInsets.all(8),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final event = AwtoInspectEvent(
                  event: 'ui_inspect_comment',
                  object: object.metadata,
                  comment: controller.text.isEmpty ? null : controller.text,
                );
                await aiLogSink.logInspectEvent(event);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged to AI with comment')),
                  );
                }
              },
              child: const Text('Send to AI Log'),
            ),
          ],
        );
      },
    );
  }
}
