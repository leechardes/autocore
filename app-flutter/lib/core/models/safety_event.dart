import 'package:autocore_app/core/models/mqtt_base_message.dart';

class SafetyEvent extends MqttBaseMessage {
  final String deviceUuid;
  final int channel;
  final String reason;
  final String eventType;
  final Map<String, dynamic>? details;

  SafetyEvent({
    required this.deviceUuid,
    required this.channel,
    required this.reason,
    required this.eventType,
    this.details,
    super.timestamp,
  });

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'device_uuid': deviceUuid,
      'channel': channel,
      'reason': reason,
      'event_type': eventType,
      if (details != null) 'details': details,
    };
  }

  factory SafetyEvent.fromJson(Map<String, dynamic> json) {
    return MqttBaseMessage.fromJson(
      json,
      (json) => SafetyEvent(
        deviceUuid: json['device_uuid'] as String,
        channel: json['channel'] as int,
        reason: json['reason'] as String,
        eventType: json['event_type'] as String,
        details: json['details'] as Map<String, dynamic>?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      ),
    )!;
  }
}
