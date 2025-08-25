import 'package:autocore_app/core/constants/mqtt_errors.dart';
import 'package:autocore_app/core/models/mqtt_base_message.dart';

class MqttErrorMessage extends MqttBaseMessage {
  final MqttErrorCode errorCode;
  final String message;
  final Map<String, dynamic>? details;
  final String? deviceUuid;

  MqttErrorMessage({
    required this.errorCode,
    required this.message,
    this.details,
    this.deviceUuid,
    super.timestamp,
  });

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'error_code': errorCode.code,
      'error_message': message,
      'error_description': errorCode.description,
      if (details != null) 'details': details,
      if (deviceUuid != null) 'device_uuid': deviceUuid,
    };
  }

  factory MqttErrorMessage.fromJson(Map<String, dynamic> json) {
    return MqttBaseMessage.fromJson(
      json,
      (json) => MqttErrorMessage(
        errorCode: MqttErrorCode.values.firstWhere(
          (e) => e.code == json['error_code'],
        ),
        message: json['error_message'] as String,
        details: json['details'] as Map<String, dynamic>?,
        deviceUuid: json['device_uuid'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      ),
    )!;
  }
}
