// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_full_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConfigFullResponse _$ConfigFullResponseFromJson(Map<String, dynamic> json) {
  return _ConfigFullResponse.fromJson(json);
}

/// @nodoc
mixin _$ConfigFullResponse {
  @JsonKey(name: 'device_info')
  ApiDeviceInfo get deviceInfo => throw _privateConstructorUsedError;
  @JsonKey(name: 'system_config')
  SystemConfig get systemConfig => throw _privateConstructorUsedError;
  @JsonKey(name: 'screens')
  List<ApiScreenConfig> get screens => throw _privateConstructorUsedError;
  @JsonKey(name: 'relay_boards')
  List<RelayBoardInfo> get relayBoards => throw _privateConstructorUsedError;
  @JsonKey(name: 'theme')
  ThemeConfig get theme => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'config_version')
  String get configVersion => throw _privateConstructorUsedError;

  /// Serializes this ConfigFullResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConfigFullResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfigFullResponseCopyWith<ConfigFullResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigFullResponseCopyWith<$Res> {
  factory $ConfigFullResponseCopyWith(
    ConfigFullResponse value,
    $Res Function(ConfigFullResponse) then,
  ) = _$ConfigFullResponseCopyWithImpl<$Res, ConfigFullResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'device_info') ApiDeviceInfo deviceInfo,
    @JsonKey(name: 'system_config') SystemConfig systemConfig,
    @JsonKey(name: 'screens') List<ApiScreenConfig> screens,
    @JsonKey(name: 'relay_boards') List<RelayBoardInfo> relayBoards,
    @JsonKey(name: 'theme') ThemeConfig theme,
    @JsonKey(name: 'last_updated') DateTime lastUpdated,
    @JsonKey(name: 'config_version') String configVersion,
  });

  $ApiDeviceInfoCopyWith<$Res> get deviceInfo;
  $SystemConfigCopyWith<$Res> get systemConfig;
  $ThemeConfigCopyWith<$Res> get theme;
}

/// @nodoc
class _$ConfigFullResponseCopyWithImpl<$Res, $Val extends ConfigFullResponse>
    implements $ConfigFullResponseCopyWith<$Res> {
  _$ConfigFullResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfigFullResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceInfo = null,
    Object? systemConfig = null,
    Object? screens = null,
    Object? relayBoards = null,
    Object? theme = null,
    Object? lastUpdated = null,
    Object? configVersion = null,
  }) {
    return _then(
      _value.copyWith(
            deviceInfo: null == deviceInfo
                ? _value.deviceInfo
                : deviceInfo // ignore: cast_nullable_to_non_nullable
                      as ApiDeviceInfo,
            systemConfig: null == systemConfig
                ? _value.systemConfig
                : systemConfig // ignore: cast_nullable_to_non_nullable
                      as SystemConfig,
            screens: null == screens
                ? _value.screens
                : screens // ignore: cast_nullable_to_non_nullable
                      as List<ApiScreenConfig>,
            relayBoards: null == relayBoards
                ? _value.relayBoards
                : relayBoards // ignore: cast_nullable_to_non_nullable
                      as List<RelayBoardInfo>,
            theme: null == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as ThemeConfig,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            configVersion: null == configVersion
                ? _value.configVersion
                : configVersion // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ConfigFullResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ApiDeviceInfoCopyWith<$Res> get deviceInfo {
    return $ApiDeviceInfoCopyWith<$Res>(_value.deviceInfo, (value) {
      return _then(_value.copyWith(deviceInfo: value) as $Val);
    });
  }

  /// Create a copy of ConfigFullResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SystemConfigCopyWith<$Res> get systemConfig {
    return $SystemConfigCopyWith<$Res>(_value.systemConfig, (value) {
      return _then(_value.copyWith(systemConfig: value) as $Val);
    });
  }

  /// Create a copy of ConfigFullResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ThemeConfigCopyWith<$Res> get theme {
    return $ThemeConfigCopyWith<$Res>(_value.theme, (value) {
      return _then(_value.copyWith(theme: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConfigFullResponseImplCopyWith<$Res>
    implements $ConfigFullResponseCopyWith<$Res> {
  factory _$$ConfigFullResponseImplCopyWith(
    _$ConfigFullResponseImpl value,
    $Res Function(_$ConfigFullResponseImpl) then,
  ) = __$$ConfigFullResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'device_info') ApiDeviceInfo deviceInfo,
    @JsonKey(name: 'system_config') SystemConfig systemConfig,
    @JsonKey(name: 'screens') List<ApiScreenConfig> screens,
    @JsonKey(name: 'relay_boards') List<RelayBoardInfo> relayBoards,
    @JsonKey(name: 'theme') ThemeConfig theme,
    @JsonKey(name: 'last_updated') DateTime lastUpdated,
    @JsonKey(name: 'config_version') String configVersion,
  });

  @override
  $ApiDeviceInfoCopyWith<$Res> get deviceInfo;
  @override
  $SystemConfigCopyWith<$Res> get systemConfig;
  @override
  $ThemeConfigCopyWith<$Res> get theme;
}

/// @nodoc
class __$$ConfigFullResponseImplCopyWithImpl<$Res>
    extends _$ConfigFullResponseCopyWithImpl<$Res, _$ConfigFullResponseImpl>
    implements _$$ConfigFullResponseImplCopyWith<$Res> {
  __$$ConfigFullResponseImplCopyWithImpl(
    _$ConfigFullResponseImpl _value,
    $Res Function(_$ConfigFullResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConfigFullResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceInfo = null,
    Object? systemConfig = null,
    Object? screens = null,
    Object? relayBoards = null,
    Object? theme = null,
    Object? lastUpdated = null,
    Object? configVersion = null,
  }) {
    return _then(
      _$ConfigFullResponseImpl(
        deviceInfo: null == deviceInfo
            ? _value.deviceInfo
            : deviceInfo // ignore: cast_nullable_to_non_nullable
                  as ApiDeviceInfo,
        systemConfig: null == systemConfig
            ? _value.systemConfig
            : systemConfig // ignore: cast_nullable_to_non_nullable
                  as SystemConfig,
        screens: null == screens
            ? _value._screens
            : screens // ignore: cast_nullable_to_non_nullable
                  as List<ApiScreenConfig>,
        relayBoards: null == relayBoards
            ? _value._relayBoards
            : relayBoards // ignore: cast_nullable_to_non_nullable
                  as List<RelayBoardInfo>,
        theme: null == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as ThemeConfig,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        configVersion: null == configVersion
            ? _value.configVersion
            : configVersion // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConfigFullResponseImpl implements _ConfigFullResponse {
  const _$ConfigFullResponseImpl({
    @JsonKey(name: 'device_info') required this.deviceInfo,
    @JsonKey(name: 'system_config') required this.systemConfig,
    @JsonKey(name: 'screens') required final List<ApiScreenConfig> screens,
    @JsonKey(name: 'relay_boards')
    required final List<RelayBoardInfo> relayBoards,
    @JsonKey(name: 'theme') required this.theme,
    @JsonKey(name: 'last_updated') required this.lastUpdated,
    @JsonKey(name: 'config_version') required this.configVersion,
  }) : _screens = screens,
       _relayBoards = relayBoards;

  factory _$ConfigFullResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfigFullResponseImplFromJson(json);

  @override
  @JsonKey(name: 'device_info')
  final ApiDeviceInfo deviceInfo;
  @override
  @JsonKey(name: 'system_config')
  final SystemConfig systemConfig;
  final List<ApiScreenConfig> _screens;
  @override
  @JsonKey(name: 'screens')
  List<ApiScreenConfig> get screens {
    if (_screens is EqualUnmodifiableListView) return _screens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_screens);
  }

  final List<RelayBoardInfo> _relayBoards;
  @override
  @JsonKey(name: 'relay_boards')
  List<RelayBoardInfo> get relayBoards {
    if (_relayBoards is EqualUnmodifiableListView) return _relayBoards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relayBoards);
  }

  @override
  @JsonKey(name: 'theme')
  final ThemeConfig theme;
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;
  @override
  @JsonKey(name: 'config_version')
  final String configVersion;

  @override
  String toString() {
    return 'ConfigFullResponse(deviceInfo: $deviceInfo, systemConfig: $systemConfig, screens: $screens, relayBoards: $relayBoards, theme: $theme, lastUpdated: $lastUpdated, configVersion: $configVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfigFullResponseImpl &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            (identical(other.systemConfig, systemConfig) ||
                other.systemConfig == systemConfig) &&
            const DeepCollectionEquality().equals(other._screens, _screens) &&
            const DeepCollectionEquality().equals(
              other._relayBoards,
              _relayBoards,
            ) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.configVersion, configVersion) ||
                other.configVersion == configVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deviceInfo,
    systemConfig,
    const DeepCollectionEquality().hash(_screens),
    const DeepCollectionEquality().hash(_relayBoards),
    theme,
    lastUpdated,
    configVersion,
  );

  /// Create a copy of ConfigFullResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfigFullResponseImplCopyWith<_$ConfigFullResponseImpl> get copyWith =>
      __$$ConfigFullResponseImplCopyWithImpl<_$ConfigFullResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfigFullResponseImplToJson(this);
  }
}

abstract class _ConfigFullResponse implements ConfigFullResponse {
  const factory _ConfigFullResponse({
    @JsonKey(name: 'device_info') required final ApiDeviceInfo deviceInfo,
    @JsonKey(name: 'system_config') required final SystemConfig systemConfig,
    @JsonKey(name: 'screens') required final List<ApiScreenConfig> screens,
    @JsonKey(name: 'relay_boards')
    required final List<RelayBoardInfo> relayBoards,
    @JsonKey(name: 'theme') required final ThemeConfig theme,
    @JsonKey(name: 'last_updated') required final DateTime lastUpdated,
    @JsonKey(name: 'config_version') required final String configVersion,
  }) = _$ConfigFullResponseImpl;

  factory _ConfigFullResponse.fromJson(Map<String, dynamic> json) =
      _$ConfigFullResponseImpl.fromJson;

  @override
  @JsonKey(name: 'device_info')
  ApiDeviceInfo get deviceInfo;
  @override
  @JsonKey(name: 'system_config')
  SystemConfig get systemConfig;
  @override
  @JsonKey(name: 'screens')
  List<ApiScreenConfig> get screens;
  @override
  @JsonKey(name: 'relay_boards')
  List<RelayBoardInfo> get relayBoards;
  @override
  @JsonKey(name: 'theme')
  ThemeConfig get theme;
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;
  @override
  @JsonKey(name: 'config_version')
  String get configVersion;

  /// Create a copy of ConfigFullResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfigFullResponseImplCopyWith<_$ConfigFullResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
