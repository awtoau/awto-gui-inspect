import 'package:flutter/services.dart';
import 'dart:convert';
import 'awto_inspect_metadata.dart';

class AwtoClipboardExport {
  static Future<void> copyObjectAsJson(AwtoInspectableObjectState object) async {
    final json = jsonEncode(object.toJson());
    await Clipboard.setData(ClipboardData(text: json));
  }

  static Future<void> copyObjectAsText(AwtoInspectableObjectState object) async {
    final text = object.toDisplayString();
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> copyPointAsJson(AwtoInspectablePointMetadata point) async {
    final json = jsonEncode(point.toJson());
    await Clipboard.setData(ClipboardData(text: json));
  }

  static Future<void> copyPointAsText(AwtoInspectablePointMetadata point) async {
    final text = point.toDisplayString();
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> copyObjectId(String id) async {
    await Clipboard.setData(ClipboardData(text: id));
  }

  static Future<void> copyCommandText(String command) async {
    await Clipboard.setData(ClipboardData(text: command));
  }
}
