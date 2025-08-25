// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SystemConfig _$SystemConfigFromJson(Map<String, dynamic> json) {
  return _SystemConfig.fromJson(json);
}

/// @nodoc
mixin _$SystemConfig {
  @JsonKey(name: 'telemetry_enabled')
  bool get telemetryEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'telemetry_interval')
  int get telemetryInterval => throw _privateConstructorUsedError;
  @JsonKey(name: 'heartbeat_interval')
  int get heartbeatInterval => throw _privateConstructorUsedError;
  @JsonKey(name: 'auto_reconnect')
  bool get autoReconnect => throw _privateConstructorUsedError;
  @JsonKey(name: 'reconnect_delay')
  int get reconnectDelay => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_reconnect_attempts')
  int get maxReconnectAttempts => throw _privateConstructorUsedError;
  @JsonKey(name: 'debug_mode')
  bool get debugMode => throw _privateConstructorUsedError;
  @JsonKey(name: 'log_level')
  String get logLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'enable_offline_mode')
  bool get enableOfflineMode => throw _privateConstructorUsedError;
  @JsonKey(name: 'cache_duration')
  int get cacheDuration => throw _privateConstructorUsedError;
  @JsonKey(name: 'screen_timeout')
  int get screenTimeout => throw _privateConstructorUsedError;
  @JsonKey(name: 'language')
  String get language => throw _privateConstructorUsedError;

  /// Serializes this SystemConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemConfigCopyWith<SystemConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemConfigCopyWith<$Res> {
  factory $SystemConfigCopyWith(
    SystemConfig value,
    $Res Function(SystemConfig) then,
  ) = _$SystemConfigCopyWithImpl<$Res, SystemConfig>;
  @useResult
  $Res call({
    @JsonKey(name: 'telemetry_enabled') bool telemetryEnabled,
    @JsonKey(name: 'telemetry_interval') int telemetryInterval,
    @JsonKey(name: 'heartbeat_interval') int heartbeatInterval,
    @JsonKey(name: 'auto_reconnect') bool autoReconnect,
    @JsonKey(name: 'reconnect_delay') int reconnectDelay,
    @JsonKey(name: 'max_reconnect_attempts') int maxReconnectAttempts,
    @JsonKey(name: 'debug_mode') bool debugMode,
    @JsonKey(name: 'log_level') String logLevel,
    @JsonKey(name: 'enable_offline_mode') bool enableOfflineMode,
    @JsonKey(name: 'cache_duration') int cacheDuration,
    @JsonKey(name: 'screen_timeout') int screenTimeout,
    @JsonKey(name: 'language') String language,
  });
}

/// @nodoc
class _$SystemConfigCopyWithImpl<$Res, $Val extends SystemConfig>
    implements $SystemConfigCopyWith<$Res> {
  _$SystemConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? telemetryEnabled = null,
    Object? telemetryInterval = null,
    Object? heartbeatInterval = null,
    Object? autoReconnect = null,
    Object? reconnectDelay = null,
    Object? maxReconnectAttempts = null,
    Object? debugMode = null,
    Object? logLevel = null,
    Object? enableOfflineMode = null,
    Object? cacheDuration = null,
    Object? screenTimeout = null,
    Object? language = null,
  }) {
    return _then(
      _value.copyWith(
            telemetryEnabled: null == telemetryEnabled
                ? _value.telemetryEnabled
                : telemetryEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            telemetryInterval: null == telemetryInterval
                ? _value.telemetryInterval
                : telemetryInterval // ignore: cast_nullable_to_non_nullable
                      as int,
            heartbeatInterval: null == heartbeatInterval
                ? _value.heartbeatInterval
                : heartbeatInterval // ignore: cast_nullable_to_non_nullable
                      as int,
            autoReconnect: null == autoReconnect
                ? _value.autoReconnect
                : autoReconnect // ignore: cast_nullable_to_non_nullable
                      as bool,
            reconnectDelay: null == reconnectDelay
                ? _value.reconnectDelay
                : reconnectDelay // ignore: cast_nullable_to_non_nullable
                      as int,
            maxReconnectAttempts: null == maxReconnectAttempts
                ? _value.maxReconnectAttempts
                : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            debugMode: null == debugMode
                ? _value.debugMode
                : debugMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            logLevel: null == logLevel
                ? _value.logLevel
                : logLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            enableOfflineMode: null == enableOfflineMode
                ? _value.enableOfflineMode
                : enableOfflineMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            cacheDuration: null == cacheDuration
                ? _value.cacheDuration
                : cacheDuration // ignore: cast_nullable_to_non_nullable
                      as int,
            screenTimeout: null == screenTimeout
                ? _value.screenTimeout
                : screenTimeout // ignore: cast_nullable_to_non_nullable
                      as int,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SystemConfigImplCopyWith<$Res>
    implements $SystemConfigCopyWith<$Res> {
  factory _$$SystemConfigImplCopyWith(
    _$SystemConfigImpl value,
    $Res Function(_$SystemConfigImpl) then,
  ) = __$$SystemConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'telemetry_enabled') bool telemetryEnabled,
    @JsonKey(name: 'telemetry_interval') int telemetryInterval,
    @JsonKey(name: 'heartbeat_interval') int heartbeatInterval,
    @JsonKey(name: 'auto_reconnect') bool autoReconnect,
    @JsonKey(name: 'reconnect_delay') int reconnectDelay,
    @JsonKey(name: 'max_reconnect_attempts') int maxReconnectAttempts,
    @JsonKey(name: 'debug_mode') bool debugMode,
    @JsonKey(name: 'log_level') String logLevel,
    @JsonKey(name: 'enable_offline_mode') bool enableOfflineMode,
    @JsonKey(name: 'cache_duration') int cacheDuration,
    @JsonKey(name: 'screen_timeout') int screenTimeout,
    @JsonKey(name: 'language') String language,
  });
}

/// @nodoc
class __$$SystemConfigImplCopyWithImpl<$Res>
    extends _$SystemConfigCopyWithImpl<$Res, _$SystemConfigImpl>
    implements _$$SystemConfigImplCopyWith<$Res> {
  __$$SystemConfigImplCopyWithImpl(
    _$SystemConfigImpl _value,
    $Res Function(_$SystemConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? telemetryEnabled = null,
    Object? telemetryInterval = null,
    Object? heartbeatInterval = null,
    Object? autoReconnect = null,
    Object? reconnectDelay = null,
    Object? maxReconnectAttempts = null,
    Object? debugMode = null,
    Object? logLevel = null,
    Object? enableOfflineMode = null,
    Object? cacheDuration = null,
    Object? screenTimeout = null,
    Object? language = null,
  }) {
    return _then(
      _$SystemConfigImpl(
        telemetryEnabled: null == telemetryEnabled
            ? _value.telemetryEnabled
            : telemetryEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        telemetryInterval: null == telemetryInterval
            ? _value.telemetryInterval
            : telemetryInterval // ignore: cast_nullable_to_non_nullable
                  as int,
        heartbeatInterval: null == heartbeatInterval
            ? _value.heartbeatInterval
            : heartbeatInterval // ignore: cast_nullable_to_non_nullable
                  as int,
        autoReconnect: null == autoReconnect
            ? _value.autoReconnect
            : autoReconnect // ignore: cast_nullable_to_non_nullable
                  as bool,
        reconnectDelay: null == reconnectDelay
            ? _value.reconnectDelay
            : reconnectDelay // ignore: cast_nullable_to_non_nullable
                  as int,
        maxReconnectAttempts: null == maxReconnectAttempts
            ? _value.maxReconnectAttempts
            : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        debugMode: null == debugMode
            ? _value.debugMode
            : debugMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        logLevel: null == logLevel
            ? _value.logLevel
            : logLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        enableOfflineMode: null == enableOfflineMode
            ? _value.enableOfflineMode
            : enableOfflineMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        cacheDuration: null == cacheDuration
            ? _value.cacheDuration
            : cacheDuration // ignore: cast_nullable_to_non_nullable
                  as int,
        screenTimeout: null == screenTimeout
            ? _value.screenTimeout
            : screenTimeout // ignore: cast_nullable_to_non_nullable
                  as int,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemConfigImpl implements _SystemConfig {
  const _$SystemConfigImpl({
    @JsonKey(name: 'telemetry_enabled') this.telemetryEnabled = true,
    @JsonKey(name: 'telemetry_interval') this.telemetryInterval = 1000,
    @JsonKey(name: 'heartbeat_interval') this.heartbeatInterval = 5000,
    @JsonKey(name: 'auto_reconnect') this.autoReconnect = true,
    @JsonKey(name: 'reconnect_delay') this.reconnectDelay = 5000,
    @JsonKey(name: 'max_reconnect_attempts') this.maxReconnectAttempts = 10,
    @JsonKey(name: 'debug_mode') this.debugMode = false,
    @JsonKey(name: 'log_level') this.logLevel = 'info',
    @JsonKey(name: 'enable_offline_mode') this.enableOfflineMode = true,
    @JsonKey(name: 'cache_duration') this.cacheDuration = 300000,
    @JsonKey(name: 'screen_timeout') this.screenTimeout = 30000,
    @JsonKey(name: 'language') this.language = 'pt',
  });

  factory _$SystemConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemConfigImplFromJson(json);

  @override
  @JsonKey(name: 'telemetry_enabled')
  final bool telemetryEnabled;
  @override
  @JsonKey(name: 'telemetry_interval')
  final int telemetryInterval;
  @override
  @JsonKey(name: 'heartbeat_interval')
  final int heartbeatInterval;
  @override
  @JsonKey(name: 'auto_reconnect')
  final bool autoReconnect;
  @override
  @JsonKey(name: 'reconnect_delay')
  final int reconnectDelay;
  @override
  @JsonKey(name: 'max_reconnect_attempts')
  final int maxReconnectAttempts;
  @override
  @JsonKey(name: 'debug_mode')
  final bool debugMode;
  @override
  @JsonKey(name: 'log_level')
  final String logLevel;
  @override
  @JsonKey(name: 'enable_offline_mode')
  final bool enableOfflineMode;
  @override
  @JsonKey(name: 'cache_duration')
  final int cacheDuration;
  @override
  @JsonKey(name: 'screen_timeout')
  final int screenTimeout;
  @override
  @JsonKey(name: 'language')
  final String language;

  @override
  String toString() {
    return 'SystemConfig(telemetryEnabled: $telemetryEnabled, telemetryInterval: $telemetryInterval, heartbeatInterval: $heartbeatInterval, autoReconnect: $autoReconnect, reconnectDelay: $reconnectDelay, maxReconnectAttempts: $maxReconnectAttempts, debugMode: $debugMode, logLevel: $logLevel, enableOfflineMode: $enableOfflineMode, cacheDuration: $cacheDuration, screenTimeout: $screenTimeout, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemConfigImpl &&
            (identical(other.telemetryEnabled, telemetryEnabled) ||
                other.telemetryEnabled == telemetryEnabled) &&
            (identical(other.telemetryInterval, telemetryInterval) ||
                other.telemetryInterval == telemetryInterval) &&
            (identical(other.heartbeatInterval, heartbeatInterval) ||
                other.heartbeatInterval == heartbeatInterval) &&
            (identical(other.autoReconnect, autoReconnect) ||
                other.autoReconnect == autoReconnect) &&
            (identical(other.reconnectDelay, reconnectDelay) ||
                other.reconnectDelay == reconnectDelay) &&
            (identical(other.maxReconnectAttempts, maxReconnectAttempts) ||
                other.maxReconnectAttempts == maxReconnectAttempts) &&
            (identical(other.debugMode, debugMode) ||
                other.debugMode == debugMode) &&
            (identical(other.logLevel, logLevel) ||
                other.logLevel == logLevel) &&
            (identical(other.enableOfflineMode, enableOfflineMode) ||
                other.enableOfflineMode == enableOfflineMode) &&
            (identical(other.cacheDuration, cacheDuration) ||
                other.cacheDuration == cacheDuration) &&
            (identical(other.screenTimeout, screenTimeout) ||
                other.screenTimeout == screenTimeout) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    telemetryEnabled,
    telemetryInterval,
    heartbeatInterval,
    autoReconnect,
    reconnectDelay,
    maxReconnectAttempts,
    debugMode,
    logLevel,
    enableOfflineMode,
    cacheDuration,
    screenTimeout,
    language,
  );

  /// Create a copy of SystemConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemConfigImplCopyWith<_$SystemConfigImpl> get copyWith =>
      __$$SystemConfigImplCopyWithImpl<_$SystemConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemConfigImplToJson(this);
  }
}

abstract class _SystemConfig implements SystemConfig {
  const factory _SystemConfig({
    @JsonKey(name: 'telemetry_enabled') final bool telemetryEnabled,
    @JsonKey(name: 'telemetry_interval') final int telemetryInterval,
    @JsonKey(name: 'heartbeat_interval') final int heartbeatInterval,
    @JsonKey(name: 'auto_reconnect') final bool autoReconnect,
    @JsonKey(name: 'reconnect_delay') final int reconnectDelay,
    @JsonKey(name: 'max_reconnect_attempts') final int maxReconnectAttempts,
    @JsonKey(name: 'debug_mode') final bool debugMode,
    @JsonKey(name: 'log_level') final String logLevel,
    @JsonKey(name: 'enable_offline_mode') final bool enableOfflineMode,
    @JsonKey(name: 'cache_duration') final int cacheDuration,
    @JsonKey(name: 'screen_timeout') final int screenTimeout,
    @JsonKey(name: 'language') final String language,
  }) = _$SystemConfigImpl;

  factory _SystemConfig.fromJson(Map<String, dynamic> json) =
      _$SystemConfigImpl.fromJson;

  @override
  @JsonKey(name: 'telemetry_enabled')
  bool get telemetryEnabled;
  @override
  @JsonKey(name: 'telemetry_interval')
  int get telemetryInterval;
  @override
  @JsonKey(name: 'heartbeat_interval')
  int get heartbeatInterval;
  @override
  @JsonKey(name: 'auto_reconnect')
  bool get autoReconnect;
  @override
  @JsonKey(name: 'reconnect_delay')
  int get reconnectDelay;
  @override
  @JsonKey(name: 'max_reconnect_attempts')
  int get maxReconnectAttempts;
  @override
  @JsonKey(name: 'debug_mode')
  bool get debugMode;
  @override
  @JsonKey(name: 'log_level')
  String get logLevel;
  @override
  @JsonKey(name: 'enable_offline_mode')
  bool get enableOfflineMode;
  @override
  @JsonKey(name: 'cache_duration')
  int get cacheDuration;
  @override
  @JsonKey(name: 'screen_timeout')
  int get screenTimeout;
  @override
  @JsonKey(name: 'language')
  String get language;

  /// Create a copy of SystemConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemConfigImplCopyWith<_$SystemConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
