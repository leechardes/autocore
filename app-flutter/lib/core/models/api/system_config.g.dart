// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SystemConfigImpl _$$SystemConfigImplFromJson(Map<String, dynamic> json) =>
    _$SystemConfigImpl(
      telemetryEnabled: json['telemetry_enabled'] as bool? ?? true,
      telemetryInterval: (json['telemetry_interval'] as num?)?.toInt() ?? 1000,
      heartbeatInterval: (json['heartbeat_interval'] as num?)?.toInt() ?? 5000,
      autoReconnect: json['auto_reconnect'] as bool? ?? true,
      reconnectDelay: (json['reconnect_delay'] as num?)?.toInt() ?? 5000,
      maxReconnectAttempts:
          (json['max_reconnect_attempts'] as num?)?.toInt() ?? 10,
      debugMode: json['debug_mode'] as bool? ?? false,
      logLevel: json['log_level'] as String? ?? 'info',
      enableOfflineMode: json['enable_offline_mode'] as bool? ?? true,
      cacheDuration: (json['cache_duration'] as num?)?.toInt() ?? 300000,
      screenTimeout: (json['screen_timeout'] as num?)?.toInt() ?? 30000,
      language: json['language'] as String? ?? 'pt',
    );

Map<String, dynamic> _$$SystemConfigImplToJson(_$SystemConfigImpl instance) =>
    <String, dynamic>{
      'telemetry_enabled': instance.telemetryEnabled,
      'telemetry_interval': instance.telemetryInterval,
      'heartbeat_interval': instance.heartbeatInterval,
      'auto_reconnect': instance.autoReconnect,
      'reconnect_delay': instance.reconnectDelay,
      'max_reconnect_attempts': instance.maxReconnectAttempts,
      'debug_mode': instance.debugMode,
      'log_level': instance.logLevel,
      'enable_offline_mode': instance.enableOfflineMode,
      'cache_duration': instance.cacheDuration,
      'screen_timeout': instance.screenTimeout,
      'language': instance.language,
    };
