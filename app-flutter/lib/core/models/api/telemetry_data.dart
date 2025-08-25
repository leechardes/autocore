import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_data.freezed.dart';
part 'telemetry_data.g.dart';

@freezed
class TelemetryData with _$TelemetryData {
  const factory TelemetryData({
    @JsonKey(name: 'timestamp') required DateTime timestamp,
    @JsonKey(name: 'device_uuid') required String deviceUuid,
    @JsonKey(name: 'sequence') required int sequence,
    @JsonKey(name: 'data') required Map<String, dynamic> data,
    @JsonKey(name: 'signal_strength') int? signalStrength,
    @JsonKey(name: 'battery_level') double? batteryLevel,
    @JsonKey(name: 'temperature') double? temperature,
    @JsonKey(name: 'humidity') double? humidity,
    @JsonKey(name: 'pressure') double? pressure,
    @JsonKey(name: 'relay_states') Map<String, bool>? relayStates,
    @JsonKey(name: 'sensor_values') Map<String, double>? sensorValues,
    @JsonKey(name: 'system_status') String? systemStatus,
    @JsonKey(name: 'error_codes') List<String>? errorCodes,
    @JsonKey(name: 'uptime') int? uptime, // Em segundos
    @JsonKey(name: 'memory_usage') double? memoryUsage, // Percentual
    @JsonKey(name: 'cpu_usage') double? cpuUsage, // Percentual
    @JsonKey(name: 'network_status') String? networkStatus,
    @JsonKey(name: 'wifi_strength') int? wifiStrength,
    @JsonKey(name: 'gps_coordinates') Map<String, double>? gpsCoordinates,
    @JsonKey(name: 'raw_payload') String? rawPayload,
  }) = _TelemetryData;

  factory TelemetryData.fromJson(Map<String, dynamic> json) =>
      _$TelemetryDataFromJson(json);
}
