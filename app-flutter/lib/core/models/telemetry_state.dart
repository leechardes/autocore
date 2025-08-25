import 'package:autocore_app/core/models/mqtt_base_message.dart';

class TelemetryState extends MqttBaseMessage {
  final String deviceUuid;
  final Map<int, bool> relayStates;
  final Map<int, double>? inputVoltages;
  final double? temperature;
  final bool? isOnline;
  final int? signalStrength;

  TelemetryState({
    required this.deviceUuid,
    required this.relayStates,
    this.inputVoltages,
    this.temperature,
    this.isOnline,
    this.signalStrength,
    super.timestamp,
  });

  @override
  Map<String, dynamic> buildPayload() {
    return {
      'device_uuid': deviceUuid,
      'relay_states': relayStates.map((k, v) => MapEntry(k.toString(), v)),
      if (inputVoltages != null)
        'input_voltages': inputVoltages!.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
      if (temperature != null) 'temperature': temperature,
      if (isOnline != null) 'is_online': isOnline,
      if (signalStrength != null) 'signal_strength': signalStrength,
    };
  }

  factory TelemetryState.fromJson(Map<String, dynamic> json) {
    return MqttBaseMessage.fromJson(
      json,
      (json) => TelemetryState(
        deviceUuid: json['device_uuid'] as String,
        relayStates: (json['relay_states'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(int.parse(k), v as bool),
        ),
        inputVoltages: json['input_voltages'] != null
            ? (json['input_voltages'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(int.parse(k), (v as num).toDouble()),
              )
            : null,
        temperature: (json['temperature'] as num?)?.toDouble(),
        isOnline: json['is_online'] as bool?,
        signalStrength: json['signal_strength'] as int?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      ),
    )!;
  }
}
