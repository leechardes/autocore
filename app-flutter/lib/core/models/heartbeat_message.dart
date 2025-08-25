import 'package:autocore_app/core/models/mqtt_base_message.dart';

class HeartbeatMessage extends MqttBaseMessage {
  final int channel;
  final int sequence;
  final String sourceUuid;
  final String targetUuid;

  HeartbeatMessage({
    required this.channel,
    required this.sequence,
    required this.sourceUuid,
    required this.targetUuid,
    super.timestamp,
  });

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'channel': channel,
      'sequence': sequence,
      'source_uuid': sourceUuid,
      'target_uuid': targetUuid,
    };
  }

  factory HeartbeatMessage.fromJson(Map<String, dynamic> json) {
    return MqttBaseMessage.fromJson(
      json,
      (json) => HeartbeatMessage(
        channel: json['channel'] as int,
        sequence: json['sequence'] as int,
        sourceUuid: json['source_uuid'] as String,
        targetUuid: json['target_uuid'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      ),
    )!;
  }
}
