// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return _AppConfig.fromJson(json);
}

/// @nodoc
mixin _$AppConfig {
  // Backend API (Gateway)
  String get apiHost => throw _privateConstructorUsedError;
  int get apiPort => throw _privateConstructorUsedError;
  bool get apiUseHttps =>
      throw _privateConstructorUsedError; // Configurações gerais
  bool get autoConnect => throw _privateConstructorUsedError;
  int get connectionTimeout => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;
  bool get enableHeartbeat => throw _privateConstructorUsedError;
  int get heartbeatInterval => throw _privateConstructorUsedError;
  int get heartbeatTimeout =>
      throw _privateConstructorUsedError; // Última conexão bem sucedida
  DateTime? get lastSuccessfulConnection => throw _privateConstructorUsedError;

  /// Serializes this AppConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppConfigCopyWith<AppConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppConfigCopyWith<$Res> {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) then) =
      _$AppConfigCopyWithImpl<$Res, AppConfig>;
  @useResult
  $Res call({
    String apiHost,
    int apiPort,
    bool apiUseHttps,
    bool autoConnect,
    int connectionTimeout,
    int maxRetries,
    bool enableHeartbeat,
    int heartbeatInterval,
    int heartbeatTimeout,
    DateTime? lastSuccessfulConnection,
  });
}

/// @nodoc
class _$AppConfigCopyWithImpl<$Res, $Val extends AppConfig>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiHost = null,
    Object? apiPort = null,
    Object? apiUseHttps = null,
    Object? autoConnect = null,
    Object? connectionTimeout = null,
    Object? maxRetries = null,
    Object? enableHeartbeat = null,
    Object? heartbeatInterval = null,
    Object? heartbeatTimeout = null,
    Object? lastSuccessfulConnection = freezed,
  }) {
    return _then(
      _value.copyWith(
            apiHost: null == apiHost
                ? _value.apiHost
                : apiHost // ignore: cast_nullable_to_non_nullable
                      as String,
            apiPort: null == apiPort
                ? _value.apiPort
                : apiPort // ignore: cast_nullable_to_non_nullable
                      as int,
            apiUseHttps: null == apiUseHttps
                ? _value.apiUseHttps
                : apiUseHttps // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoConnect: null == autoConnect
                ? _value.autoConnect
                : autoConnect // ignore: cast_nullable_to_non_nullable
                      as bool,
            connectionTimeout: null == connectionTimeout
                ? _value.connectionTimeout
                : connectionTimeout // ignore: cast_nullable_to_non_nullable
                      as int,
            maxRetries: null == maxRetries
                ? _value.maxRetries
                : maxRetries // ignore: cast_nullable_to_non_nullable
                      as int,
            enableHeartbeat: null == enableHeartbeat
                ? _value.enableHeartbeat
                : enableHeartbeat // ignore: cast_nullable_to_non_nullable
                      as bool,
            heartbeatInterval: null == heartbeatInterval
                ? _value.heartbeatInterval
                : heartbeatInterval // ignore: cast_nullable_to_non_nullable
                      as int,
            heartbeatTimeout: null == heartbeatTimeout
                ? _value.heartbeatTimeout
                : heartbeatTimeout // ignore: cast_nullable_to_non_nullable
                      as int,
            lastSuccessfulConnection: freezed == lastSuccessfulConnection
                ? _value.lastSuccessfulConnection
                : lastSuccessfulConnection // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppConfigImplCopyWith<$Res>
    implements $AppConfigCopyWith<$Res> {
  factory _$$AppConfigImplCopyWith(
    _$AppConfigImpl value,
    $Res Function(_$AppConfigImpl) then,
  ) = __$$AppConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String apiHost,
    int apiPort,
    bool apiUseHttps,
    bool autoConnect,
    int connectionTimeout,
    int maxRetries,
    bool enableHeartbeat,
    int heartbeatInterval,
    int heartbeatTimeout,
    DateTime? lastSuccessfulConnection,
  });
}

/// @nodoc
class __$$AppConfigImplCopyWithImpl<$Res>
    extends _$AppConfigCopyWithImpl<$Res, _$AppConfigImpl>
    implements _$$AppConfigImplCopyWith<$Res> {
  __$$AppConfigImplCopyWithImpl(
    _$AppConfigImpl _value,
    $Res Function(_$AppConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiHost = null,
    Object? apiPort = null,
    Object? apiUseHttps = null,
    Object? autoConnect = null,
    Object? connectionTimeout = null,
    Object? maxRetries = null,
    Object? enableHeartbeat = null,
    Object? heartbeatInterval = null,
    Object? heartbeatTimeout = null,
    Object? lastSuccessfulConnection = freezed,
  }) {
    return _then(
      _$AppConfigImpl(
        apiHost: null == apiHost
            ? _value.apiHost
            : apiHost // ignore: cast_nullable_to_non_nullable
                  as String,
        apiPort: null == apiPort
            ? _value.apiPort
            : apiPort // ignore: cast_nullable_to_non_nullable
                  as int,
        apiUseHttps: null == apiUseHttps
            ? _value.apiUseHttps
            : apiUseHttps // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoConnect: null == autoConnect
            ? _value.autoConnect
            : autoConnect // ignore: cast_nullable_to_non_nullable
                  as bool,
        connectionTimeout: null == connectionTimeout
            ? _value.connectionTimeout
            : connectionTimeout // ignore: cast_nullable_to_non_nullable
                  as int,
        maxRetries: null == maxRetries
            ? _value.maxRetries
            : maxRetries // ignore: cast_nullable_to_non_nullable
                  as int,
        enableHeartbeat: null == enableHeartbeat
            ? _value.enableHeartbeat
            : enableHeartbeat // ignore: cast_nullable_to_non_nullable
                  as bool,
        heartbeatInterval: null == heartbeatInterval
            ? _value.heartbeatInterval
            : heartbeatInterval // ignore: cast_nullable_to_non_nullable
                  as int,
        heartbeatTimeout: null == heartbeatTimeout
            ? _value.heartbeatTimeout
            : heartbeatTimeout // ignore: cast_nullable_to_non_nullable
                  as int,
        lastSuccessfulConnection: freezed == lastSuccessfulConnection
            ? _value.lastSuccessfulConnection
            : lastSuccessfulConnection // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppConfigImpl extends _AppConfig {
  const _$AppConfigImpl({
    this.apiHost = '10.0.10.100',
    this.apiPort = 8081,
    this.apiUseHttps = false,
    this.autoConnect = true,
    this.connectionTimeout = 5000,
    this.maxRetries = 3,
    this.enableHeartbeat = true,
    this.heartbeatInterval = 500,
    this.heartbeatTimeout = 1000,
    this.lastSuccessfulConnection,
  }) : super._();

  factory _$AppConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppConfigImplFromJson(json);

  // Backend API (Gateway)
  @override
  @JsonKey()
  final String apiHost;
  @override
  @JsonKey()
  final int apiPort;
  @override
  @JsonKey()
  final bool apiUseHttps;
  // Configurações gerais
  @override
  @JsonKey()
  final bool autoConnect;
  @override
  @JsonKey()
  final int connectionTimeout;
  @override
  @JsonKey()
  final int maxRetries;
  @override
  @JsonKey()
  final bool enableHeartbeat;
  @override
  @JsonKey()
  final int heartbeatInterval;
  @override
  @JsonKey()
  final int heartbeatTimeout;
  // Última conexão bem sucedida
  @override
  final DateTime? lastSuccessfulConnection;

  @override
  String toString() {
    return 'AppConfig(apiHost: $apiHost, apiPort: $apiPort, apiUseHttps: $apiUseHttps, autoConnect: $autoConnect, connectionTimeout: $connectionTimeout, maxRetries: $maxRetries, enableHeartbeat: $enableHeartbeat, heartbeatInterval: $heartbeatInterval, heartbeatTimeout: $heartbeatTimeout, lastSuccessfulConnection: $lastSuccessfulConnection)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppConfigImpl &&
            (identical(other.apiHost, apiHost) || other.apiHost == apiHost) &&
            (identical(other.apiPort, apiPort) || other.apiPort == apiPort) &&
            (identical(other.apiUseHttps, apiUseHttps) ||
                other.apiUseHttps == apiUseHttps) &&
            (identical(other.autoConnect, autoConnect) ||
                other.autoConnect == autoConnect) &&
            (identical(other.connectionTimeout, connectionTimeout) ||
                other.connectionTimeout == connectionTimeout) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.enableHeartbeat, enableHeartbeat) ||
                other.enableHeartbeat == enableHeartbeat) &&
            (identical(other.heartbeatInterval, heartbeatInterval) ||
                other.heartbeatInterval == heartbeatInterval) &&
            (identical(other.heartbeatTimeout, heartbeatTimeout) ||
                other.heartbeatTimeout == heartbeatTimeout) &&
            (identical(
                  other.lastSuccessfulConnection,
                  lastSuccessfulConnection,
                ) ||
                other.lastSuccessfulConnection == lastSuccessfulConnection));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    apiHost,
    apiPort,
    apiUseHttps,
    autoConnect,
    connectionTimeout,
    maxRetries,
    enableHeartbeat,
    heartbeatInterval,
    heartbeatTimeout,
    lastSuccessfulConnection,
  );

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      __$$AppConfigImplCopyWithImpl<_$AppConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppConfigImplToJson(this);
  }
}

abstract class _AppConfig extends AppConfig {
  const factory _AppConfig({
    final String apiHost,
    final int apiPort,
    final bool apiUseHttps,
    final bool autoConnect,
    final int connectionTimeout,
    final int maxRetries,
    final bool enableHeartbeat,
    final int heartbeatInterval,
    final int heartbeatTimeout,
    final DateTime? lastSuccessfulConnection,
  }) = _$AppConfigImpl;
  const _AppConfig._() : super._();

  factory _AppConfig.fromJson(Map<String, dynamic> json) =
      _$AppConfigImpl.fromJson;

  // Backend API (Gateway)
  @override
  String get apiHost;
  @override
  int get apiPort;
  @override
  bool get apiUseHttps; // Configurações gerais
  @override
  bool get autoConnect;
  @override
  int get connectionTimeout;
  @override
  int get maxRetries;
  @override
  bool get enableHeartbeat;
  @override
  int get heartbeatInterval;
  @override
  int get heartbeatTimeout; // Última conexão bem sucedida
  @override
  DateTime? get lastSuccessfulConnection;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
