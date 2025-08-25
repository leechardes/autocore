// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TelemetryDataImpl _$$TelemetryDataImplFromJson(Map<String, dynamic> json) =>
    _$TelemetryDataImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceUuid: json['device_uuid'] as String,
      sequence: (json['sequence'] as num).toInt(),
      data: json['data'] as Map<String, dynamic>,
      signalStrength: (json['signal_strength'] as num?)?.toInt(),
      batteryLevel: (json['battery_level'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble(),
      relayStates: (json['relay_states'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
      sensorValues: (json['sensor_values'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      systemStatus: json['system_status'] as String?,
      errorCodes: (json['error_codes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      uptime: (json['uptime'] as num?)?.toInt(),
      memoryUsage: (json['memory_usage'] as num?)?.toDouble(),
      cpuUsage: (json['cpu_usage'] as num?)?.toDouble(),
      networkStatus: json['network_status'] as String?,
      wifiStrength: (json['wifi_strength'] as num?)?.toInt(),
      gpsCoordinates: (json['gps_coordinates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      rawPayload: json['raw_payload'] as String?,
    );

Map<String, dynamic> _$$TelemetryDataImplToJson(_$TelemetryDataImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'device_uuid': instance.deviceUuid,
      'sequence': instance.sequence,
      'data': instance.data,
      'signal_strength': instance.signalStrength,
      'battery_level': instance.batteryLevel,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'pressure': instance.pressure,
      'relay_states': instance.relayStates,
      'sensor_values': instance.sensorValues,
      'system_status': instance.systemStatus,
      'error_codes': instance.errorCodes,
      'uptime': instance.uptime,
      'memory_usage': instance.memoryUsage,
      'cpu_usage': instance.cpuUsage,
      'network_status': instance.networkStatus,
      'wifi_strength': instance.wifiStrength,
      'gps_coordinates': instance.gpsCoordinates,
      'raw_payload': instance.rawPayload,
    };
