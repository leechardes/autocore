// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_device_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApiDeviceInfo _$ApiDeviceInfoFromJson(Map<String, dynamic> json) {
  return _ApiDeviceInfo.fromJson(json);
}

/// @nodoc
mixin _$ApiDeviceInfo {
  @JsonKey(name: 'uuid')
  String get uuid => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'firmware_version')
  String get firmwareVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'hardware_version')
  String get hardwareVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'ip_address')
  String get ipAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'mac_address')
  String get macAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'mqtt_broker')
  String get mqttBroker => throw _privateConstructorUsedError;
  @JsonKey(name: 'mqtt_port')
  int get mqttPort => throw _privateConstructorUsedError;
  @JsonKey(name: 'mqtt_client_id')
  String get mqttClientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'api_base_url')
  String get apiBaseUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'device_type')
  String get deviceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'timezone')
  String? get timezone => throw _privateConstructorUsedError;
  @JsonKey(name: 'location')
  String? get location => throw _privateConstructorUsedError;

  /// Serializes this ApiDeviceInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiDeviceInfoCopyWith<ApiDeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiDeviceInfoCopyWith<$Res> {
  factory $ApiDeviceInfoCopyWith(
    ApiDeviceInfo value,
    $Res Function(ApiDeviceInfo) then,
  ) = _$ApiDeviceInfoCopyWithImpl<$Res, ApiDeviceInfo>;
  @useResult
  $Res call({
    @JsonKey(name: 'uuid') String uuid,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'firmware_version') String firmwareVersion,
    @JsonKey(name: 'hardware_version') String hardwareVersion,
    @JsonKey(name: 'ip_address') String ipAddress,
    @JsonKey(name: 'mac_address') String macAddress,
    @JsonKey(name: 'mqtt_broker') String mqttBroker,
    @JsonKey(name: 'mqtt_port') int mqttPort,
    @JsonKey(name: 'mqtt_client_id') String mqttClientId,
    @JsonKey(name: 'api_base_url') String apiBaseUrl,
    @JsonKey(name: 'device_type') String deviceType,
    @JsonKey(name: 'timezone') String? timezone,
    @JsonKey(name: 'location') String? location,
  });
}

/// @nodoc
class _$ApiDeviceInfoCopyWithImpl<$Res, $Val extends ApiDeviceInfo>
    implements $ApiDeviceInfoCopyWith<$Res> {
  _$ApiDeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? name = null,
    Object? firmwareVersion = null,
    Object? hardwareVersion = null,
    Object? ipAddress = null,
    Object? macAddress = null,
    Object? mqttBroker = null,
    Object? mqttPort = null,
    Object? mqttClientId = null,
    Object? apiBaseUrl = null,
    Object? deviceType = null,
    Object? timezone = freezed,
    Object? location = freezed,
  }) {
    return _then(
      _value.copyWith(
            uuid: null == uuid
                ? _value.uuid
                : uuid // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            firmwareVersion: null == firmwareVersion
                ? _value.firmwareVersion
                : firmwareVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            hardwareVersion: null == hardwareVersion
                ? _value.hardwareVersion
                : hardwareVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            macAddress: null == macAddress
                ? _value.macAddress
                : macAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            mqttBroker: null == mqttBroker
                ? _value.mqttBroker
                : mqttBroker // ignore: cast_nullable_to_non_nullable
                      as String,
            mqttPort: null == mqttPort
                ? _value.mqttPort
                : mqttPort // ignore: cast_nullable_to_non_nullable
                      as int,
            mqttClientId: null == mqttClientId
                ? _value.mqttClientId
                : mqttClientId // ignore: cast_nullable_to_non_nullable
                      as String,
            apiBaseUrl: null == apiBaseUrl
                ? _value.apiBaseUrl
                : apiBaseUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceType: null == deviceType
                ? _value.deviceType
                : deviceType // ignore: cast_nullable_to_non_nullable
                      as String,
            timezone: freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiDeviceInfoImplCopyWith<$Res>
    implements $ApiDeviceInfoCopyWith<$Res> {
  factory _$$ApiDeviceInfoImplCopyWith(
    _$ApiDeviceInfoImpl value,
    $Res Function(_$ApiDeviceInfoImpl) then,
  ) = __$$ApiDeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'uuid') String uuid,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'firmware_version') String firmwareVersion,
    @JsonKey(name: 'hardware_version') String hardwareVersion,
    @JsonKey(name: 'ip_address') String ipAddress,
    @JsonKey(name: 'mac_address') String macAddress,
    @JsonKey(name: 'mqtt_broker') String mqttBroker,
    @JsonKey(name: 'mqtt_port') int mqttPort,
    @JsonKey(name: 'mqtt_client_id') String mqttClientId,
    @JsonKey(name: 'api_base_url') String apiBaseUrl,
    @JsonKey(name: 'device_type') String deviceType,
    @JsonKey(name: 'timezone') String? timezone,
    @JsonKey(name: 'location') String? location,
  });
}

/// @nodoc
class __$$ApiDeviceInfoImplCopyWithImpl<$Res>
    extends _$ApiDeviceInfoCopyWithImpl<$Res, _$ApiDeviceInfoImpl>
    implements _$$ApiDeviceInfoImplCopyWith<$Res> {
  __$$ApiDeviceInfoImplCopyWithImpl(
    _$ApiDeviceInfoImpl _value,
    $Res Function(_$ApiDeviceInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? name = null,
    Object? firmwareVersion = null,
    Object? hardwareVersion = null,
    Object? ipAddress = null,
    Object? macAddress = null,
    Object? mqttBroker = null,
    Object? mqttPort = null,
    Object? mqttClientId = null,
    Object? apiBaseUrl = null,
    Object? deviceType = null,
    Object? timezone = freezed,
    Object? location = freezed,
  }) {
    return _then(
      _$ApiDeviceInfoImpl(
        uuid: null == uuid
            ? _value.uuid
            : uuid // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        firmwareVersion: null == firmwareVersion
            ? _value.firmwareVersion
            : firmwareVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        hardwareVersion: null == hardwareVersion
            ? _value.hardwareVersion
            : hardwareVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        macAddress: null == macAddress
            ? _value.macAddress
            : macAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        mqttBroker: null == mqttBroker
            ? _value.mqttBroker
            : mqttBroker // ignore: cast_nullable_to_non_nullable
                  as String,
        mqttPort: null == mqttPort
            ? _value.mqttPort
            : mqttPort // ignore: cast_nullable_to_non_nullable
                  as int,
        mqttClientId: null == mqttClientId
            ? _value.mqttClientId
            : mqttClientId // ignore: cast_nullable_to_non_nullable
                  as String,
        apiBaseUrl: null == apiBaseUrl
            ? _value.apiBaseUrl
            : apiBaseUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceType: null == deviceType
            ? _value.deviceType
            : deviceType // ignore: cast_nullable_to_non_nullable
                  as String,
        timezone: freezed == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiDeviceInfoImpl implements _ApiDeviceInfo {
  const _$ApiDeviceInfoImpl({
    @JsonKey(name: 'uuid') required this.uuid,
    @JsonKey(name: 'name') required this.name,
    @JsonKey(name: 'firmware_version') required this.firmwareVersion,
    @JsonKey(name: 'hardware_version') required this.hardwareVersion,
    @JsonKey(name: 'ip_address') required this.ipAddress,
    @JsonKey(name: 'mac_address') required this.macAddress,
    @JsonKey(name: 'mqtt_broker') required this.mqttBroker,
    @JsonKey(name: 'mqtt_port') required this.mqttPort,
    @JsonKey(name: 'mqtt_client_id') required this.mqttClientId,
    @JsonKey(name: 'api_base_url') required this.apiBaseUrl,
    @JsonKey(name: 'device_type') required this.deviceType,
    @JsonKey(name: 'timezone') this.timezone,
    @JsonKey(name: 'location') this.location,
  });

  factory _$ApiDeviceInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiDeviceInfoImplFromJson(json);

  @override
  @JsonKey(name: 'uuid')
  final String uuid;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'firmware_version')
  final String firmwareVersion;
  @override
  @JsonKey(name: 'hardware_version')
  final String hardwareVersion;
  @override
  @JsonKey(name: 'ip_address')
  final String ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  final String macAddress;
  @override
  @JsonKey(name: 'mqtt_broker')
  final String mqttBroker;
  @override
  @JsonKey(name: 'mqtt_port')
  final int mqttPort;
  @override
  @JsonKey(name: 'mqtt_client_id')
  final String mqttClientId;
  @override
  @JsonKey(name: 'api_base_url')
  final String apiBaseUrl;
  @override
  @JsonKey(name: 'device_type')
  final String deviceType;
  @override
  @JsonKey(name: 'timezone')
  final String? timezone;
  @override
  @JsonKey(name: 'location')
  final String? location;

  @override
  String toString() {
    return 'ApiDeviceInfo(uuid: $uuid, name: $name, firmwareVersion: $firmwareVersion, hardwareVersion: $hardwareVersion, ipAddress: $ipAddress, macAddress: $macAddress, mqttBroker: $mqttBroker, mqttPort: $mqttPort, mqttClientId: $mqttClientId, apiBaseUrl: $apiBaseUrl, deviceType: $deviceType, timezone: $timezone, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiDeviceInfoImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.firmwareVersion, firmwareVersion) ||
                other.firmwareVersion == firmwareVersion) &&
            (identical(other.hardwareVersion, hardwareVersion) ||
                other.hardwareVersion == hardwareVersion) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.mqttBroker, mqttBroker) ||
                other.mqttBroker == mqttBroker) &&
            (identical(other.mqttPort, mqttPort) ||
                other.mqttPort == mqttPort) &&
            (identical(other.mqttClientId, mqttClientId) ||
                other.mqttClientId == mqttClientId) &&
            (identical(other.apiBaseUrl, apiBaseUrl) ||
                other.apiBaseUrl == apiBaseUrl) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uuid,
    name,
    firmwareVersion,
    hardwareVersion,
    ipAddress,
    macAddress,
    mqttBroker,
    mqttPort,
    mqttClientId,
    apiBaseUrl,
    deviceType,
    timezone,
    location,
  );

  /// Create a copy of ApiDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiDeviceInfoImplCopyWith<_$ApiDeviceInfoImpl> get copyWith =>
      __$$ApiDeviceInfoImplCopyWithImpl<_$ApiDeviceInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiDeviceInfoImplToJson(this);
  }
}

abstract class _ApiDeviceInfo implements ApiDeviceInfo {
  const factory _ApiDeviceInfo({
    @JsonKey(name: 'uuid') required final String uuid,
    @JsonKey(name: 'name') required final String name,
    @JsonKey(name: 'firmware_version') required final String firmwareVersion,
    @JsonKey(name: 'hardware_version') required final String hardwareVersion,
    @JsonKey(name: 'ip_address') required final String ipAddress,
    @JsonKey(name: 'mac_address') required final String macAddress,
    @JsonKey(name: 'mqtt_broker') required final String mqttBroker,
    @JsonKey(name: 'mqtt_port') required final int mqttPort,
    @JsonKey(name: 'mqtt_client_id') required final String mqttClientId,
    @JsonKey(name: 'api_base_url') required final String apiBaseUrl,
    @JsonKey(name: 'device_type') required final String deviceType,
    @JsonKey(name: 'timezone') final String? timezone,
    @JsonKey(name: 'location') final String? location,
  }) = _$ApiDeviceInfoImpl;

  factory _ApiDeviceInfo.fromJson(Map<String, dynamic> json) =
      _$ApiDeviceInfoImpl.fromJson;

  @override
  @JsonKey(name: 'uuid')
  String get uuid;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'firmware_version')
  String get firmwareVersion;
  @override
  @JsonKey(name: 'hardware_version')
  String get hardwareVersion;
  @override
  @JsonKey(name: 'ip_address')
  String get ipAddress;
  @override
  @JsonKey(name: 'mac_address')
  String get macAddress;
  @override
  @JsonKey(name: 'mqtt_broker')
  String get mqttBroker;
  @override
  @JsonKey(name: 'mqtt_port')
  int get mqttPort;
  @override
  @JsonKey(name: 'mqtt_client_id')
  String get mqttClientId;
  @override
  @JsonKey(name: 'api_base_url')
  String get apiBaseUrl;
  @override
  @JsonKey(name: 'device_type')
  String get deviceType;
  @override
  @JsonKey(name: 'timezone')
  String? get timezone;
  @override
  @JsonKey(name: 'location')
  String? get location;

  /// Create a copy of ApiDeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiDeviceInfoImplCopyWith<_$ApiDeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
