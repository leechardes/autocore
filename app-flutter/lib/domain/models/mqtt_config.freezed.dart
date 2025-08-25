// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mqtt_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MqttConfig _$MqttConfigFromJson(Map<String, dynamic> json) {
  return _MqttConfig.fromJson(json);
}

/// @nodoc
mixin _$MqttConfig {
  String get broker => throw _privateConstructorUsedError;
  int get port => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  String get topicPrefix => throw _privateConstructorUsedError;
  int get keepalive => throw _privateConstructorUsedError;
  int get qos => throw _privateConstructorUsedError;
  bool get retain => throw _privateConstructorUsedError;
  String get clientIdPattern => throw _privateConstructorUsedError;
  bool get autoReconnect => throw _privateConstructorUsedError;
  int get maxReconnectAttempts => throw _privateConstructorUsedError;
  int get reconnectInterval => throw _privateConstructorUsedError;
  int get connectionTimeout => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this MqttConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MqttConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MqttConfigCopyWith<MqttConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MqttConfigCopyWith<$Res> {
  factory $MqttConfigCopyWith(
    MqttConfig value,
    $Res Function(MqttConfig) then,
  ) = _$MqttConfigCopyWithImpl<$Res, MqttConfig>;
  @useResult
  $Res call({
    String broker,
    int port,
    String? username,
    String? password,
    String topicPrefix,
    int keepalive,
    int qos,
    bool retain,
    String clientIdPattern,
    bool autoReconnect,
    int maxReconnectAttempts,
    int reconnectInterval,
    int connectionTimeout,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class _$MqttConfigCopyWithImpl<$Res, $Val extends MqttConfig>
    implements $MqttConfigCopyWith<$Res> {
  _$MqttConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MqttConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? broker = null,
    Object? port = null,
    Object? username = freezed,
    Object? password = freezed,
    Object? topicPrefix = null,
    Object? keepalive = null,
    Object? qos = null,
    Object? retain = null,
    Object? clientIdPattern = null,
    Object? autoReconnect = null,
    Object? maxReconnectAttempts = null,
    Object? reconnectInterval = null,
    Object? connectionTimeout = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _value.copyWith(
            broker: null == broker
                ? _value.broker
                : broker // ignore: cast_nullable_to_non_nullable
                      as String,
            port: null == port
                ? _value.port
                : port // ignore: cast_nullable_to_non_nullable
                      as int,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            topicPrefix: null == topicPrefix
                ? _value.topicPrefix
                : topicPrefix // ignore: cast_nullable_to_non_nullable
                      as String,
            keepalive: null == keepalive
                ? _value.keepalive
                : keepalive // ignore: cast_nullable_to_non_nullable
                      as int,
            qos: null == qos
                ? _value.qos
                : qos // ignore: cast_nullable_to_non_nullable
                      as int,
            retain: null == retain
                ? _value.retain
                : retain // ignore: cast_nullable_to_non_nullable
                      as bool,
            clientIdPattern: null == clientIdPattern
                ? _value.clientIdPattern
                : clientIdPattern // ignore: cast_nullable_to_non_nullable
                      as String,
            autoReconnect: null == autoReconnect
                ? _value.autoReconnect
                : autoReconnect // ignore: cast_nullable_to_non_nullable
                      as bool,
            maxReconnectAttempts: null == maxReconnectAttempts
                ? _value.maxReconnectAttempts
                : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            reconnectInterval: null == reconnectInterval
                ? _value.reconnectInterval
                : reconnectInterval // ignore: cast_nullable_to_non_nullable
                      as int,
            connectionTimeout: null == connectionTimeout
                ? _value.connectionTimeout
                : connectionTimeout // ignore: cast_nullable_to_non_nullable
                      as int,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MqttConfigImplCopyWith<$Res>
    implements $MqttConfigCopyWith<$Res> {
  factory _$$MqttConfigImplCopyWith(
    _$MqttConfigImpl value,
    $Res Function(_$MqttConfigImpl) then,
  ) = __$$MqttConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String broker,
    int port,
    String? username,
    String? password,
    String topicPrefix,
    int keepalive,
    int qos,
    bool retain,
    String clientIdPattern,
    bool autoReconnect,
    int maxReconnectAttempts,
    int reconnectInterval,
    int connectionTimeout,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$MqttConfigImplCopyWithImpl<$Res>
    extends _$MqttConfigCopyWithImpl<$Res, _$MqttConfigImpl>
    implements _$$MqttConfigImplCopyWith<$Res> {
  __$$MqttConfigImplCopyWithImpl(
    _$MqttConfigImpl _value,
    $Res Function(_$MqttConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MqttConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? broker = null,
    Object? port = null,
    Object? username = freezed,
    Object? password = freezed,
    Object? topicPrefix = null,
    Object? keepalive = null,
    Object? qos = null,
    Object? retain = null,
    Object? clientIdPattern = null,
    Object? autoReconnect = null,
    Object? maxReconnectAttempts = null,
    Object? reconnectInterval = null,
    Object? connectionTimeout = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$MqttConfigImpl(
        broker: null == broker
            ? _value.broker
            : broker // ignore: cast_nullable_to_non_nullable
                  as String,
        port: null == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as int,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        topicPrefix: null == topicPrefix
            ? _value.topicPrefix
            : topicPrefix // ignore: cast_nullable_to_non_nullable
                  as String,
        keepalive: null == keepalive
            ? _value.keepalive
            : keepalive // ignore: cast_nullable_to_non_nullable
                  as int,
        qos: null == qos
            ? _value.qos
            : qos // ignore: cast_nullable_to_non_nullable
                  as int,
        retain: null == retain
            ? _value.retain
            : retain // ignore: cast_nullable_to_non_nullable
                  as bool,
        clientIdPattern: null == clientIdPattern
            ? _value.clientIdPattern
            : clientIdPattern // ignore: cast_nullable_to_non_nullable
                  as String,
        autoReconnect: null == autoReconnect
            ? _value.autoReconnect
            : autoReconnect // ignore: cast_nullable_to_non_nullable
                  as bool,
        maxReconnectAttempts: null == maxReconnectAttempts
            ? _value.maxReconnectAttempts
            : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        reconnectInterval: null == reconnectInterval
            ? _value.reconnectInterval
            : reconnectInterval // ignore: cast_nullable_to_non_nullable
                  as int,
        connectionTimeout: null == connectionTimeout
            ? _value.connectionTimeout
            : connectionTimeout // ignore: cast_nullable_to_non_nullable
                  as int,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MqttConfigImpl extends _MqttConfig {
  const _$MqttConfigImpl({
    this.broker = '10.0.10.100',
    this.port = 1883,
    this.username,
    this.password,
    this.topicPrefix = 'autocore',
    this.keepalive = 60,
    this.qos = 1,
    this.retain = false,
    this.clientIdPattern = 'autocore-{device_uuid}',
    this.autoReconnect = true,
    this.maxReconnectAttempts = 5,
    this.reconnectInterval = 5000,
    this.connectionTimeout = 30000,
    this.lastUpdated,
  }) : super._();

  factory _$MqttConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$MqttConfigImplFromJson(json);

  @override
  @JsonKey()
  final String broker;
  @override
  @JsonKey()
  final int port;
  @override
  final String? username;
  @override
  final String? password;
  @override
  @JsonKey()
  final String topicPrefix;
  @override
  @JsonKey()
  final int keepalive;
  @override
  @JsonKey()
  final int qos;
  @override
  @JsonKey()
  final bool retain;
  @override
  @JsonKey()
  final String clientIdPattern;
  @override
  @JsonKey()
  final bool autoReconnect;
  @override
  @JsonKey()
  final int maxReconnectAttempts;
  @override
  @JsonKey()
  final int reconnectInterval;
  @override
  @JsonKey()
  final int connectionTimeout;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'MqttConfig(broker: $broker, port: $port, username: $username, password: $password, topicPrefix: $topicPrefix, keepalive: $keepalive, qos: $qos, retain: $retain, clientIdPattern: $clientIdPattern, autoReconnect: $autoReconnect, maxReconnectAttempts: $maxReconnectAttempts, reconnectInterval: $reconnectInterval, connectionTimeout: $connectionTimeout, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MqttConfigImpl &&
            (identical(other.broker, broker) || other.broker == broker) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.topicPrefix, topicPrefix) ||
                other.topicPrefix == topicPrefix) &&
            (identical(other.keepalive, keepalive) ||
                other.keepalive == keepalive) &&
            (identical(other.qos, qos) || other.qos == qos) &&
            (identical(other.retain, retain) || other.retain == retain) &&
            (identical(other.clientIdPattern, clientIdPattern) ||
                other.clientIdPattern == clientIdPattern) &&
            (identical(other.autoReconnect, autoReconnect) ||
                other.autoReconnect == autoReconnect) &&
            (identical(other.maxReconnectAttempts, maxReconnectAttempts) ||
                other.maxReconnectAttempts == maxReconnectAttempts) &&
            (identical(other.reconnectInterval, reconnectInterval) ||
                other.reconnectInterval == reconnectInterval) &&
            (identical(other.connectionTimeout, connectionTimeout) ||
                other.connectionTimeout == connectionTimeout) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    broker,
    port,
    username,
    password,
    topicPrefix,
    keepalive,
    qos,
    retain,
    clientIdPattern,
    autoReconnect,
    maxReconnectAttempts,
    reconnectInterval,
    connectionTimeout,
    lastUpdated,
  );

  /// Create a copy of MqttConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MqttConfigImplCopyWith<_$MqttConfigImpl> get copyWith =>
      __$$MqttConfigImplCopyWithImpl<_$MqttConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MqttConfigImplToJson(this);
  }
}

abstract class _MqttConfig extends MqttConfig {
  const factory _MqttConfig({
    final String broker,
    final int port,
    final String? username,
    final String? password,
    final String topicPrefix,
    final int keepalive,
    final int qos,
    final bool retain,
    final String clientIdPattern,
    final bool autoReconnect,
    final int maxReconnectAttempts,
    final int reconnectInterval,
    final int connectionTimeout,
    final DateTime? lastUpdated,
  }) = _$MqttConfigImpl;
  const _MqttConfig._() : super._();

  factory _MqttConfig.fromJson(Map<String, dynamic> json) =
      _$MqttConfigImpl.fromJson;

  @override
  String get broker;
  @override
  int get port;
  @override
  String? get username;
  @override
  String? get password;
  @override
  String get topicPrefix;
  @override
  int get keepalive;
  @override
  int get qos;
  @override
  bool get retain;
  @override
  String get clientIdPattern;
  @override
  bool get autoReconnect;
  @override
  int get maxReconnectAttempts;
  @override
  int get reconnectInterval;
  @override
  int get connectionTimeout;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of MqttConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MqttConfigImplCopyWith<_$MqttConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
