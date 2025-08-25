import 'package:autocore_app/core/constants/mqtt_protocol.dart';

class MqttPayloadValidator {
  static bool validateProtocolVersion(Map<String, dynamic> payload) {
    final version = payload['protocol_version'];
    if (version == null) {
      throw ValidationException('Missing protocol_version');
    }
    if (version != MqttProtocol.version) {
      throw ValidationException(
        'Invalid protocol version: $version (expected ${MqttProtocol.version})',
      );
    }
    return true;
  }

  static bool validateRelayCommand(Map<String, dynamic> payload) {
    validateProtocolVersion(payload);

    if (!payload.containsKey('channel')) {
      throw ValidationException('Missing channel');
    }
    if (!payload.containsKey('state')) {
      throw ValidationException('Missing state');
    }
    if (!payload.containsKey('function_type')) {
      throw ValidationException('Missing function_type');
    }

    final channel = payload['channel'];
    if (channel is! int || channel < 1 || channel > 32) {
      throw ValidationException('Invalid channel: $channel');
    }

    return true;
  }

  static bool validateHeartbeat(Map<String, dynamic> payload) {
    validateProtocolVersion(payload);

    if (!payload.containsKey('sequence')) {
      throw ValidationException('Missing sequence');
    }
    if (!payload.containsKey('channel')) {
      throw ValidationException('Missing channel');
    }

    return true;
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
