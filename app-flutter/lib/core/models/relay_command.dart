import 'package:autocore_app/core/models/mqtt_base_message.dart';

class RelayCommand extends MqttBaseMessage {
  final int channel;
  final bool state;
  final String functionType;
  final bool? momentary;
  final int? pulseMs;
  final String user;
  final String? deviceUuid;

  RelayCommand({
    required this.channel,
    required this.state,
    required this.functionType,
    this.momentary,
    this.pulseMs,
    required this.user,
    this.deviceUuid,
    super.timestamp,
  });

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'channel': channel,
      'state': state,
      'function_type': functionType,
      if (momentary != null) 'momentary': momentary,
      if (pulseMs != null) 'pulse_ms': pulseMs,
      'user': user,
      if (deviceUuid != null) 'device_uuid': deviceUuid,
    };
  }

  factory RelayCommand.momentary({
    required int channel,
    required bool state,
    String user = 'flutter_app',
    String? deviceUuid,
  }) {
    return RelayCommand(
      channel: channel,
      state: state,
      functionType: 'momentary',
      momentary: true,
      user: user,
      deviceUuid: deviceUuid,
    );
  }

  factory RelayCommand.toggle({
    required int channel,
    required bool state,
    String user = 'flutter_app',
    String? deviceUuid,
  }) {
    return RelayCommand(
      channel: channel,
      state: state,
      functionType: 'toggle',
      user: user,
      deviceUuid: deviceUuid,
    );
  }
}
