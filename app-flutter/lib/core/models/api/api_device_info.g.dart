// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiDeviceInfoImpl _$$ApiDeviceInfoImplFromJson(Map<String, dynamic> json) =>
    _$ApiDeviceInfoImpl(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      firmwareVersion: json['firmware_version'] as String,
      hardwareVersion: json['hardware_version'] as String,
      ipAddress: json['ip_address'] as String,
      macAddress: json['mac_address'] as String,
      mqttBroker: json['mqtt_broker'] as String,
      mqttPort: (json['mqtt_port'] as num).toInt(),
      mqttClientId: json['mqtt_client_id'] as String,
      apiBaseUrl: json['api_base_url'] as String,
      deviceType: json['device_type'] as String,
      timezone: json['timezone'] as String?,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$$ApiDeviceInfoImplToJson(_$ApiDeviceInfoImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'firmware_version': instance.firmwareVersion,
      'hardware_version': instance.hardwareVersion,
      'ip_address': instance.ipAddress,
      'mac_address': instance.macAddress,
      'mqtt_broker': instance.mqttBroker,
      'mqtt_port': instance.mqttPort,
      'mqtt_client_id': instance.mqttClientId,
      'api_base_url': instance.apiBaseUrl,
      'device_type': instance.deviceType,
      'timezone': instance.timezone,
      'location': instance.location,
    };
