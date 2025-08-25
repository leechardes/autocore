// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'relay_channel_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RelayChannelInfo _$RelayChannelInfoFromJson(Map<String, dynamic> json) {
  return _RelayChannelInfo.fromJson(json);
}

/// @nodoc
mixin _$RelayChannelInfo {
  @JsonKey(name: 'channel_id')
  int get channelId => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'enabled')
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'normally_open')
  bool get normallyOpen => throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_state')
  bool get initialState => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_state')
  bool get currentState => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'group')
  String? get group => throw _privateConstructorUsedError;
  @JsonKey(name: 'safety_enabled')
  bool get safetyEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_on_time')
  int? get maxOnTime => throw _privateConstructorUsedError; // Em milliseconds
  @JsonKey(name: 'min_off_time')
  int? get minOffTime => throw _privateConstructorUsedError; // Em milliseconds
  @JsonKey(name: 'interlock_channels')
  List<int> get interlockChannels => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_activated')
  DateTime? get lastActivated => throw _privateConstructorUsedError;
  @JsonKey(name: 'activation_count')
  int get activationCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_on_time')
  int get totalOnTime => throw _privateConstructorUsedError;

  /// Serializes this RelayChannelInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RelayChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RelayChannelInfoCopyWith<RelayChannelInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelayChannelInfoCopyWith<$Res> {
  factory $RelayChannelInfoCopyWith(
    RelayChannelInfo value,
    $Res Function(RelayChannelInfo) then,
  ) = _$RelayChannelInfoCopyWithImpl<$Res, RelayChannelInfo>;
  @useResult
  $Res call({
    @JsonKey(name: 'channel_id') int channelId,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'enabled') bool enabled,
    @JsonKey(name: 'normally_open') bool normallyOpen,
    @JsonKey(name: 'initial_state') bool initialState,
    @JsonKey(name: 'current_state') bool currentState,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'group') String? group,
    @JsonKey(name: 'safety_enabled') bool safetyEnabled,
    @JsonKey(name: 'max_on_time') int? maxOnTime,
    @JsonKey(name: 'min_off_time') int? minOffTime,
    @JsonKey(name: 'interlock_channels') List<int> interlockChannels,
    @JsonKey(name: 'last_activated') DateTime? lastActivated,
    @JsonKey(name: 'activation_count') int activationCount,
    @JsonKey(name: 'total_on_time') int totalOnTime,
  });
}

/// @nodoc
class _$RelayChannelInfoCopyWithImpl<$Res, $Val extends RelayChannelInfo>
    implements $RelayChannelInfoCopyWith<$Res> {
  _$RelayChannelInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RelayChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channelId = null,
    Object? name = null,
    Object? enabled = null,
    Object? normallyOpen = null,
    Object? initialState = null,
    Object? currentState = null,
    Object? description = freezed,
    Object? group = freezed,
    Object? safetyEnabled = null,
    Object? maxOnTime = freezed,
    Object? minOffTime = freezed,
    Object? interlockChannels = null,
    Object? lastActivated = freezed,
    Object? activationCount = null,
    Object? totalOnTime = null,
  }) {
    return _then(
      _value.copyWith(
            channelId: null == channelId
                ? _value.channelId
                : channelId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            normallyOpen: null == normallyOpen
                ? _value.normallyOpen
                : normallyOpen // ignore: cast_nullable_to_non_nullable
                      as bool,
            initialState: null == initialState
                ? _value.initialState
                : initialState // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentState: null == currentState
                ? _value.currentState
                : currentState // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            group: freezed == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                      as String?,
            safetyEnabled: null == safetyEnabled
                ? _value.safetyEnabled
                : safetyEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            maxOnTime: freezed == maxOnTime
                ? _value.maxOnTime
                : maxOnTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            minOffTime: freezed == minOffTime
                ? _value.minOffTime
                : minOffTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            interlockChannels: null == interlockChannels
                ? _value.interlockChannels
                : interlockChannels // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            lastActivated: freezed == lastActivated
                ? _value.lastActivated
                : lastActivated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            activationCount: null == activationCount
                ? _value.activationCount
                : activationCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalOnTime: null == totalOnTime
                ? _value.totalOnTime
                : totalOnTime // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RelayChannelInfoImplCopyWith<$Res>
    implements $RelayChannelInfoCopyWith<$Res> {
  factory _$$RelayChannelInfoImplCopyWith(
    _$RelayChannelInfoImpl value,
    $Res Function(_$RelayChannelInfoImpl) then,
  ) = __$$RelayChannelInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'channel_id') int channelId,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'enabled') bool enabled,
    @JsonKey(name: 'normally_open') bool normallyOpen,
    @JsonKey(name: 'initial_state') bool initialState,
    @JsonKey(name: 'current_state') bool currentState,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'group') String? group,
    @JsonKey(name: 'safety_enabled') bool safetyEnabled,
    @JsonKey(name: 'max_on_time') int? maxOnTime,
    @JsonKey(name: 'min_off_time') int? minOffTime,
    @JsonKey(name: 'interlock_channels') List<int> interlockChannels,
    @JsonKey(name: 'last_activated') DateTime? lastActivated,
    @JsonKey(name: 'activation_count') int activationCount,
    @JsonKey(name: 'total_on_time') int totalOnTime,
  });
}

/// @nodoc
class __$$RelayChannelInfoImplCopyWithImpl<$Res>
    extends _$RelayChannelInfoCopyWithImpl<$Res, _$RelayChannelInfoImpl>
    implements _$$RelayChannelInfoImplCopyWith<$Res> {
  __$$RelayChannelInfoImplCopyWithImpl(
    _$RelayChannelInfoImpl _value,
    $Res Function(_$RelayChannelInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RelayChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channelId = null,
    Object? name = null,
    Object? enabled = null,
    Object? normallyOpen = null,
    Object? initialState = null,
    Object? currentState = null,
    Object? description = freezed,
    Object? group = freezed,
    Object? safetyEnabled = null,
    Object? maxOnTime = freezed,
    Object? minOffTime = freezed,
    Object? interlockChannels = null,
    Object? lastActivated = freezed,
    Object? activationCount = null,
    Object? totalOnTime = null,
  }) {
    return _then(
      _$RelayChannelInfoImpl(
        channelId: null == channelId
            ? _value.channelId
            : channelId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        normallyOpen: null == normallyOpen
            ? _value.normallyOpen
            : normallyOpen // ignore: cast_nullable_to_non_nullable
                  as bool,
        initialState: null == initialState
            ? _value.initialState
            : initialState // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentState: null == currentState
            ? _value.currentState
            : currentState // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        group: freezed == group
            ? _value.group
            : group // ignore: cast_nullable_to_non_nullable
                  as String?,
        safetyEnabled: null == safetyEnabled
            ? _value.safetyEnabled
            : safetyEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        maxOnTime: freezed == maxOnTime
            ? _value.maxOnTime
            : maxOnTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        minOffTime: freezed == minOffTime
            ? _value.minOffTime
            : minOffTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        interlockChannels: null == interlockChannels
            ? _value._interlockChannels
            : interlockChannels // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        lastActivated: freezed == lastActivated
            ? _value.lastActivated
            : lastActivated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        activationCount: null == activationCount
            ? _value.activationCount
            : activationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalOnTime: null == totalOnTime
            ? _value.totalOnTime
            : totalOnTime // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RelayChannelInfoImpl implements _RelayChannelInfo {
  const _$RelayChannelInfoImpl({
    @JsonKey(name: 'channel_id') required this.channelId,
    @JsonKey(name: 'name') required this.name,
    @JsonKey(name: 'enabled') this.enabled = true,
    @JsonKey(name: 'normally_open') this.normallyOpen = true,
    @JsonKey(name: 'initial_state') this.initialState = false,
    @JsonKey(name: 'current_state') this.currentState = false,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'group') this.group,
    @JsonKey(name: 'safety_enabled') this.safetyEnabled = false,
    @JsonKey(name: 'max_on_time') this.maxOnTime,
    @JsonKey(name: 'min_off_time') this.minOffTime,
    @JsonKey(name: 'interlock_channels')
    final List<int> interlockChannels = const [],
    @JsonKey(name: 'last_activated') this.lastActivated,
    @JsonKey(name: 'activation_count') this.activationCount = 0,
    @JsonKey(name: 'total_on_time') this.totalOnTime = 0,
  }) : _interlockChannels = interlockChannels;

  factory _$RelayChannelInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelayChannelInfoImplFromJson(json);

  @override
  @JsonKey(name: 'channel_id')
  final int channelId;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'enabled')
  final bool enabled;
  @override
  @JsonKey(name: 'normally_open')
  final bool normallyOpen;
  @override
  @JsonKey(name: 'initial_state')
  final bool initialState;
  @override
  @JsonKey(name: 'current_state')
  final bool currentState;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'group')
  final String? group;
  @override
  @JsonKey(name: 'safety_enabled')
  final bool safetyEnabled;
  @override
  @JsonKey(name: 'max_on_time')
  final int? maxOnTime;
  // Em milliseconds
  @override
  @JsonKey(name: 'min_off_time')
  final int? minOffTime;
  // Em milliseconds
  final List<int> _interlockChannels;
  // Em milliseconds
  @override
  @JsonKey(name: 'interlock_channels')
  List<int> get interlockChannels {
    if (_interlockChannels is EqualUnmodifiableListView)
      return _interlockChannels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interlockChannels);
  }

  @override
  @JsonKey(name: 'last_activated')
  final DateTime? lastActivated;
  @override
  @JsonKey(name: 'activation_count')
  final int activationCount;
  @override
  @JsonKey(name: 'total_on_time')
  final int totalOnTime;

  @override
  String toString() {
    return 'RelayChannelInfo(channelId: $channelId, name: $name, enabled: $enabled, normallyOpen: $normallyOpen, initialState: $initialState, currentState: $currentState, description: $description, group: $group, safetyEnabled: $safetyEnabled, maxOnTime: $maxOnTime, minOffTime: $minOffTime, interlockChannels: $interlockChannels, lastActivated: $lastActivated, activationCount: $activationCount, totalOnTime: $totalOnTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelayChannelInfoImpl &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.normallyOpen, normallyOpen) ||
                other.normallyOpen == normallyOpen) &&
            (identical(other.initialState, initialState) ||
                other.initialState == initialState) &&
            (identical(other.currentState, currentState) ||
                other.currentState == currentState) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.safetyEnabled, safetyEnabled) ||
                other.safetyEnabled == safetyEnabled) &&
            (identical(other.maxOnTime, maxOnTime) ||
                other.maxOnTime == maxOnTime) &&
            (identical(other.minOffTime, minOffTime) ||
                other.minOffTime == minOffTime) &&
            const DeepCollectionEquality().equals(
              other._interlockChannels,
              _interlockChannels,
            ) &&
            (identical(other.lastActivated, lastActivated) ||
                other.lastActivated == lastActivated) &&
            (identical(other.activationCount, activationCount) ||
                other.activationCount == activationCount) &&
            (identical(other.totalOnTime, totalOnTime) ||
                other.totalOnTime == totalOnTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    channelId,
    name,
    enabled,
    normallyOpen,
    initialState,
    currentState,
    description,
    group,
    safetyEnabled,
    maxOnTime,
    minOffTime,
    const DeepCollectionEquality().hash(_interlockChannels),
    lastActivated,
    activationCount,
    totalOnTime,
  );

  /// Create a copy of RelayChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RelayChannelInfoImplCopyWith<_$RelayChannelInfoImpl> get copyWith =>
      __$$RelayChannelInfoImplCopyWithImpl<_$RelayChannelInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RelayChannelInfoImplToJson(this);
  }
}

abstract class _RelayChannelInfo implements RelayChannelInfo {
  const factory _RelayChannelInfo({
    @JsonKey(name: 'channel_id') required final int channelId,
    @JsonKey(name: 'name') required final String name,
    @JsonKey(name: 'enabled') final bool enabled,
    @JsonKey(name: 'normally_open') final bool normallyOpen,
    @JsonKey(name: 'initial_state') final bool initialState,
    @JsonKey(name: 'current_state') final bool currentState,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'group') final String? group,
    @JsonKey(name: 'safety_enabled') final bool safetyEnabled,
    @JsonKey(name: 'max_on_time') final int? maxOnTime,
    @JsonKey(name: 'min_off_time') final int? minOffTime,
    @JsonKey(name: 'interlock_channels') final List<int> interlockChannels,
    @JsonKey(name: 'last_activated') final DateTime? lastActivated,
    @JsonKey(name: 'activation_count') final int activationCount,
    @JsonKey(name: 'total_on_time') final int totalOnTime,
  }) = _$RelayChannelInfoImpl;

  factory _RelayChannelInfo.fromJson(Map<String, dynamic> json) =
      _$RelayChannelInfoImpl.fromJson;

  @override
  @JsonKey(name: 'channel_id')
  int get channelId;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'enabled')
  bool get enabled;
  @override
  @JsonKey(name: 'normally_open')
  bool get normallyOpen;
  @override
  @JsonKey(name: 'initial_state')
  bool get initialState;
  @override
  @JsonKey(name: 'current_state')
  bool get currentState;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'group')
  String? get group;
  @override
  @JsonKey(name: 'safety_enabled')
  bool get safetyEnabled;
  @override
  @JsonKey(name: 'max_on_time')
  int? get maxOnTime; // Em milliseconds
  @override
  @JsonKey(name: 'min_off_time')
  int? get minOffTime; // Em milliseconds
  @override
  @JsonKey(name: 'interlock_channels')
  List<int> get interlockChannels;
  @override
  @JsonKey(name: 'last_activated')
  DateTime? get lastActivated;
  @override
  @JsonKey(name: 'activation_count')
  int get activationCount;
  @override
  @JsonKey(name: 'total_on_time')
  int get totalOnTime;

  /// Create a copy of RelayChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RelayChannelInfoImplCopyWith<_$RelayChannelInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
