import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_config.freezed.dart';
part 'system_config.g.dart';

@freezed
class SystemConfig with _$SystemConfig {
  const factory SystemConfig({
    @JsonKey(name: 'telemetry_enabled') @Default(true) bool telemetryEnabled,
    @JsonKey(name: 'telemetry_interval') @Default(1000) int telemetryInterval,
    @JsonKey(name: 'heartbeat_interval') @Default(5000) int heartbeatInterval,
    @JsonKey(name: 'auto_reconnect') @Default(true) bool autoReconnect,
    @JsonKey(name: 'reconnect_delay') @Default(5000) int reconnectDelay,
    @JsonKey(name: 'max_reconnect_attempts')
    @Default(10)
    int maxReconnectAttempts,
    @JsonKey(name: 'debug_mode') @Default(false) bool debugMode,
    @JsonKey(name: 'log_level') @Default('info') String logLevel,
    @JsonKey(name: 'enable_offline_mode') @Default(true) bool enableOfflineMode,
    @JsonKey(name: 'cache_duration') @Default(300000) int cacheDuration,
    @JsonKey(name: 'screen_timeout') @Default(30000) int screenTimeout,
    @JsonKey(name: 'language') @Default('pt') String language,
  }) = _SystemConfig;

  factory SystemConfig.fromJson(Map<String, dynamic> json) =>
      _$SystemConfigFromJson(json);
}
