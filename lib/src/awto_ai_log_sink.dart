import 'dart:convert';
import 'dart:ui';
import 'awto_inspect_metadata.dart';

abstract class AwtoAiLogSink {
  Future<void> logInspectEvent(AwtoInspectEvent event);
}

class AwtoInspectEvent {
  final String event;
  final DateTime timestamp;
  final String? screen;
  final String? comment;
  final AwtoInspectableMetadata? object;
  final Offset? mousePosition;
  final List<String>? nearbyObjects;

  AwtoInspectEvent({
    required this.event,
    DateTime? timestamp,
    this.screen,
    this.comment,
    this.object,
    this.mousePosition,
    this.nearbyObjects,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'timestamp': timestamp.toIso8601String(),
      if (screen != null) 'screen': screen,
      if (comment != null) 'comment': comment,
      if (object != null) 'object': object!.toJson(),
      if (mousePosition != null)
        'mouse': {'x': mousePosition!.dx.toInt(), 'y': mousePosition!.dy.toInt()},
      if (nearbyObjects != null) 'nearby_objects': nearbyObjects,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

class AwtoConsoleAiLogSink extends AwtoAiLogSink {
  @override
  Future<void> logInspectEvent(AwtoInspectEvent event) async {
    print('[AWTO:AI_LOG] ${event.toJsonString()}');
  }
}
