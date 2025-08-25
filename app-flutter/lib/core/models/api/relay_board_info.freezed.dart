// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'relay_board_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RelayBoardInfo _$RelayBoardInfoFromJson(Map<String, dynamic> json) {
  return _RelayBoardInfo.fromJson(json);
}

/// @nodoc
mixin _$RelayBoardInfo {
  @JsonKey(name: 'board_id')
  String get boardId => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'type')
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'address')
  String get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'enabled')
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'channels')
  List<RelayChannelInfo> get channels => throw _privateConstructorUsedError;
  @JsonKey(name: 'firmware_version')
  String? get firmwareVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'ip_address')
  String? get ipAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'port')
  int? get port => throw _privateConstructorUsedError;
  @JsonKey(name: 'timeout')
  int get timeout => throw _privateConstructorUsedError;
  @JsonKey(name: 'retry_attempts')
  int get retryAttempts => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_heartbeat')
  DateTime? get lastHeartbeat => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;

  /// Serializes this RelayBoardInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RelayBoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RelayBoardInfoCopyWith<RelayBoardInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelayBoardInfoCopyWith<$Res> {
  factory $RelayBoardInfoCopyWith(
    RelayBoardInfo value,
    $Res Function(RelayBoardInfo) then,
  ) = _$RelayBoardInfoCopyWithImpl<$Res, RelayBoardInfo>;
  @useResult
  $Res call({
    @JsonKey(name: 'board_id') String boardId,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'type') String type,
    @JsonKey(name: 'address') String address,
    @JsonKey(name: 'enabled') bool enabled,
    @JsonKey(name: 'channels') List<RelayChannelInfo> channels,
    @JsonKey(name: 'firmware_version') String? firmwareVersion,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'port') int? port,
    @JsonKey(name: 'timeout') int timeout,
    @JsonKey(name: 'retry_attempts') int retryAttempts,
    @JsonKey(name: 'last_heartbeat') DateTime? lastHeartbeat,
    @JsonKey(name: 'status') String status,
  });
}

/// @nodoc
class _$RelayBoardInfoCopyWithImpl<$Res, $Val extends RelayBoardInfo>
    implements $RelayBoardInfoCopyWith<$Res> {
  _$RelayBoardInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RelayBoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boardId = null,
    Object? name = null,
    Object? type = null,
    Object? address = null,
    Object? enabled = null,
    Object? channels = null,
    Object? firmwareVersion = freezed,
    Object? ipAddress = freezed,
    Object? port = freezed,
    Object? timeout = null,
    Object? retryAttempts = null,
    Object? lastHeartbeat = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            boardId: null == boardId
                ? _value.boardId
                : boardId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            channels: null == channels
                ? _value.channels
                : channels // ignore: cast_nullable_to_non_nullable
                      as List<RelayChannelInfo>,
            firmwareVersion: freezed == firmwareVersion
                ? _value.firmwareVersion
                : firmwareVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            port: freezed == port
                ? _value.port
                : port // ignore: cast_nullable_to_non_nullable
                      as int?,
            timeout: null == timeout
                ? _value.timeout
                : timeout // ignore: cast_nullable_to_non_nullable
                      as int,
            retryAttempts: null == retryAttempts
                ? _value.retryAttempts
                : retryAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            lastHeartbeat: freezed == lastHeartbeat
                ? _value.lastHeartbeat
                : lastHeartbeat // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RelayBoardInfoImplCopyWith<$Res>
    implements $RelayBoardInfoCopyWith<$Res> {
  factory _$$RelayBoardInfoImplCopyWith(
    _$RelayBoardInfoImpl value,
    $Res Function(_$RelayBoardInfoImpl) then,
  ) = __$$RelayBoardInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'board_id') String boardId,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'type') String type,
    @JsonKey(name: 'address') String address,
    @JsonKey(name: 'enabled') bool enabled,
    @JsonKey(name: 'channels') List<RelayChannelInfo> channels,
    @JsonKey(name: 'firmware_version') String? firmwareVersion,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'port') int? port,
    @JsonKey(name: 'timeout') int timeout,
    @JsonKey(name: 'retry_attempts') int retryAttempts,
    @JsonKey(name: 'last_heartbeat') DateTime? lastHeartbeat,
    @JsonKey(name: 'status') String status,
  });
}

/// @nodoc
class __$$RelayBoardInfoImplCopyWithImpl<$Res>
    extends _$RelayBoardInfoCopyWithImpl<$Res, _$RelayBoardInfoImpl>
    implements _$$RelayBoardInfoImplCopyWith<$Res> {
  __$$RelayBoardInfoImplCopyWithImpl(
    _$RelayBoardInfoImpl _value,
    $Res Function(_$RelayBoardInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RelayBoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boardId = null,
    Object? name = null,
    Object? type = null,
    Object? address = null,
    Object? enabled = null,
    Object? channels = null,
    Object? firmwareVersion = freezed,
    Object? ipAddress = freezed,
    Object? port = freezed,
    Object? timeout = null,
    Object? retryAttempts = null,
    Object? lastHeartbeat = freezed,
    Object? status = null,
  }) {
    return _then(
      _$RelayBoardInfoImpl(
        boardId: null == boardId
            ? _value.boardId
            : boardId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        channels: null == channels
            ? _value._channels
            : channels // ignore: cast_nullable_to_non_nullable
                  as List<RelayChannelInfo>,
        firmwareVersion: freezed == firmwareVersion
            ? _value.firmwareVersion
            : firmwareVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        port: freezed == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as int?,
        timeout: null == timeout
            ? _value.timeout
            : timeout // ignore: cast_nullable_to_non_nullable
                  as int,
        retryAttempts: null == retryAttempts
            ? _value.retryAttempts
            : retryAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        lastHeartbeat: freezed == lastHeartbeat
            ? _value.lastHeartbeat
            : lastHeartbeat // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RelayBoardInfoImpl implements _RelayBoardInfo {
  const _$RelayBoardInfoImpl({
    @JsonKey(name: 'board_id') required this.boardId,
    @JsonKey(name: 'name') required this.name,
    @JsonKey(name: 'type') required this.type,
    @JsonKey(name: 'address') required this.address,
    @JsonKey(name: 'enabled') this.enabled = true,
    @JsonKey(name: 'channels') required final List<RelayChannelInfo> channels,
    @JsonKey(name: 'firmware_version') this.firmwareVersion,
    @JsonKey(name: 'ip_address') this.ipAddress,
    @JsonKey(name: 'port') this.port,
    @JsonKey(name: 'timeout') this.timeout = 5000,
    @JsonKey(name: 'retry_attempts') this.retryAttempts = 3,
    @JsonKey(name: 'last_heartbeat') this.lastHeartbeat,
    @JsonKey(name: 'status') this.status = 'unknown',
  }) : _channels = channels;

  factory _$RelayBoardInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelayBoardInfoImplFromJson(json);

  @override
  @JsonKey(name: 'board_id')
  final String boardId;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'type')
  final String type;
  @override
  @JsonKey(name: 'address')
  final String address;
  @override
  @JsonKey(name: 'enabled')
  final bool enabled;
  final List<RelayChannelInfo> _channels;
  @override
  @JsonKey(name: 'channels')
  List<RelayChannelInfo> get channels {
    if (_channels is EqualUnmodifiableListView) return _channels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_channels);
  }

  @override
  @JsonKey(name: 'firmware_version')
  final String? firmwareVersion;
  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  @override
  @JsonKey(name: 'port')
  final int? port;
  @override
  @JsonKey(name: 'timeout')
  final int timeout;
  @override
  @JsonKey(name: 'retry_attempts')
  final int retryAttempts;
  @override
  @JsonKey(name: 'last_heartbeat')
  final DateTime? lastHeartbeat;
  @override
  @JsonKey(name: 'status')
  final String status;

  @override
  String toString() {
    return 'RelayBoardInfo(boardId: $boardId, name: $name, type: $type, address: $address, enabled: $enabled, channels: $channels, firmwareVersion: $firmwareVersion, ipAddress: $ipAddress, port: $port, timeout: $timeout, retryAttempts: $retryAttempts, lastHeartbeat: $lastHeartbeat, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelayBoardInfoImpl &&
            (identical(other.boardId, boardId) || other.boardId == boardId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            const DeepCollectionEquality().equals(other._channels, _channels) &&
            (identical(other.firmwareVersion, firmwareVersion) ||
                other.firmwareVersion == firmwareVersion) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.timeout, timeout) || other.timeout == timeout) &&
            (identical(other.retryAttempts, retryAttempts) ||
                other.retryAttempts == retryAttempts) &&
            (identical(other.lastHeartbeat, lastHeartbeat) ||
                other.lastHeartbeat == lastHeartbeat) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    boardId,
    name,
    type,
    address,
    enabled,
    const DeepCollectionEquality().hash(_channels),
    firmwareVersion,
    ipAddress,
    port,
    timeout,
    retryAttempts,
    lastHeartbeat,
    status,
  );

  /// Create a copy of RelayBoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RelayBoardInfoImplCopyWith<_$RelayBoardInfoImpl> get copyWith =>
      __$$RelayBoardInfoImplCopyWithImpl<_$RelayBoardInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RelayBoardInfoImplToJson(this);
  }
}

abstract class _RelayBoardInfo implements RelayBoardInfo {
  const factory _RelayBoardInfo({
    @JsonKey(name: 'board_id') required final String boardId,
    @JsonKey(name: 'name') required final String name,
    @JsonKey(name: 'type') required final String type,
    @JsonKey(name: 'address') required final String address,
    @JsonKey(name: 'enabled') final bool enabled,
    @JsonKey(name: 'channels') required final List<RelayChannelInfo> channels,
    @JsonKey(name: 'firmware_version') final String? firmwareVersion,
    @JsonKey(name: 'ip_address') final String? ipAddress,
    @JsonKey(name: 'port') final int? port,
    @JsonKey(name: 'timeout') final int timeout,
    @JsonKey(name: 'retry_attempts') final int retryAttempts,
    @JsonKey(name: 'last_heartbeat') final DateTime? lastHeartbeat,
    @JsonKey(name: 'status') final String status,
  }) = _$RelayBoardInfoImpl;

  factory _RelayBoardInfo.fromJson(Map<String, dynamic> json) =
      _$RelayBoardInfoImpl.fromJson;

  @override
  @JsonKey(name: 'board_id')
  String get boardId;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'type')
  String get type;
  @override
  @JsonKey(name: 'address')
  String get address;
  @override
  @JsonKey(name: 'enabled')
  bool get enabled;
  @override
  @JsonKey(name: 'channels')
  List<RelayChannelInfo> get channels;
  @override
  @JsonKey(name: 'firmware_version')
  String? get firmwareVersion;
  @override
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @override
  @JsonKey(name: 'port')
  int? get port;
  @override
  @JsonKey(name: 'timeout')
  int get timeout;
  @override
  @JsonKey(name: 'retry_attempts')
  int get retryAttempts;
  @override
  @JsonKey(name: 'last_heartbeat')
  DateTime? get lastHeartbeat;
  @override
  @JsonKey(name: 'status')
  String get status;

  /// Create a copy of RelayBoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RelayBoardInfoImplCopyWith<_$RelayBoardInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
