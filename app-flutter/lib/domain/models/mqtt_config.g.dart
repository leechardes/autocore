// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MqttConfigImpl _$$MqttConfigImplFromJson(Map<String, dynamic> json) =>
    _$MqttConfigImpl(
      broker: json['broker'] as String? ?? '10.0.10.100',
      port: (json['port'] as num?)?.toInt() ?? 1883,
      username: json['username'] as String?,
      password: json['password'] as String?,
      topicPrefix: json['topicPrefix'] as String? ?? 'autocore',
      keepalive: (json['keepalive'] as num?)?.toInt() ?? 60,
      qos: (json['qos'] as num?)?.toInt() ?? 1,
      retain: json['retain'] as bool? ?? false,
      clientIdPattern:
          json['clientIdPattern'] as String? ?? 'autocore-{device_uuid}',
      autoReconnect: json['autoReconnect'] as bool? ?? true,
      maxReconnectAttempts:
          (json['maxReconnectAttempts'] as num?)?.toInt() ?? 5,
      reconnectInterval: (json['reconnectInterval'] as num?)?.toInt() ?? 5000,
      connectionTimeout: (json['connectionTimeout'] as num?)?.toInt() ?? 30000,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$MqttConfigImplToJson(_$MqttConfigImpl instance) =>
    <String, dynamic>{
      'broker': instance.broker,
      'port': instance.port,
      'username': instance.username,
      'password': instance.password,
      'topicPrefix': instance.topicPrefix,
      'keepalive': instance.keepalive,
      'qos': instance.qos,
      'retain': instance.retain,
      'clientIdPattern': instance.clientIdPattern,
      'autoReconnect': instance.autoReconnect,
      'maxReconnectAttempts': instance.maxReconnectAttempts,
      'reconnectInterval': instance.reconnectInterval,
      'connectionTimeout': instance.connectionTimeout,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
