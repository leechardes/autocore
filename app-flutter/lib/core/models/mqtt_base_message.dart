import 'dart:convert';
import 'package:autocore_app/core/constants/mqtt_protocol.dart';

abstract class MqttBaseMessage {
  final DateTime timestamp;

  MqttBaseMessage({DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    final json = buildPayload();
    json['protocol_version'] = MqttProtocol.version;
    json['timestamp'] = timestamp.toIso8601String();
    return json;
  }

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> buildPayload();

  static T? fromJson<T extends MqttBaseMessage>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) builder,
  ) {
    // Validate protocol version
    if (json['protocol_version'] != MqttProtocol.version) {
      throw MqttProtocolException(
        'Invalid protocol version: ${json['protocol_version']}',
      );
    }
    return builder(json);
  }
}
