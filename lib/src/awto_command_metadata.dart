import 'dart:convert';

class AwtoCommandMetadata {
  final String command;
  final String? target;
  final String? action;
  final String? description;

  const AwtoCommandMetadata({
    required this.command,
    this.target,
    this.action,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      if (target != null) 'target': target,
      if (action != null) 'action': action,
      if (description != null) 'description': description,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  String toString() {
    if (target != null && action != null) {
      return 'awto $target $action';
    }
    return command;
  }
}
