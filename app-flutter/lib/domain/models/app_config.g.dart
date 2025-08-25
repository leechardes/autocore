// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppConfigImpl _$$AppConfigImplFromJson(Map<String, dynamic> json) =>
    _$AppConfigImpl(
      apiHost: json['apiHost'] as String? ?? '10.0.10.100',
      apiPort: (json['apiPort'] as num?)?.toInt() ?? 8081,
      apiUseHttps: json['apiUseHttps'] as bool? ?? false,
      autoConnect: json['autoConnect'] as bool? ?? true,
      connectionTimeout: (json['connectionTimeout'] as num?)?.toInt() ?? 5000,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
      enableHeartbeat: json['enableHeartbeat'] as bool? ?? true,
      heartbeatInterval: (json['heartbeatInterval'] as num?)?.toInt() ?? 500,
      heartbeatTimeout: (json['heartbeatTimeout'] as num?)?.toInt() ?? 1000,
      lastSuccessfulConnection: json['lastSuccessfulConnection'] == null
          ? null
          : DateTime.parse(json['lastSuccessfulConnection'] as String),
    );

Map<String, dynamic> _$$AppConfigImplToJson(_$AppConfigImpl instance) =>
    <String, dynamic>{
      'apiHost': instance.apiHost,
      'apiPort': instance.apiPort,
      'apiUseHttps': instance.apiUseHttps,
      'autoConnect': instance.autoConnect,
      'connectionTimeout': instance.connectionTimeout,
      'maxRetries': instance.maxRetries,
      'enableHeartbeat': instance.enableHeartbeat,
      'heartbeatInterval': instance.heartbeatInterval,
      'heartbeatTimeout': instance.heartbeatTimeout,
      'lastSuccessfulConnection': instance.lastSuccessfulConnection
          ?.toIso8601String(),
    };
