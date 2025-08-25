// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_screen_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApiScreenItem _$ApiScreenItemFromJson(Map<String, dynamic> json) {
  return _ApiScreenItem.fromJson(json);
}

/// @nodoc
mixin _$ApiScreenItem {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'type')
  String get type => throw _privateConstructorUsedError; // 'button', 'gauge', 'display', 'switch'
  @JsonKey(name: 'title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'position')
  Map<String, dynamic> get position => throw _privateConstructorUsedError; // {row, col, span_x, span_y}
  @JsonKey(name: 'enabled')
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'visible')
  bool get visible => throw _privateConstructorUsedError; // Common styling
  @JsonKey(name: 'background_color')
  String? get backgroundColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_color')
  String? get textColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'border_color')
  String? get borderColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon')
  String? get icon => throw _privateConstructorUsedError; // Button specific
  @JsonKey(name: 'action')
  String? get action => throw _privateConstructorUsedError;
  @JsonKey(name: 'command')
  String? get command => throw _privateConstructorUsedError;
  @JsonKey(name: 'payload')
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_momentary')
  bool get isMomentary => throw _privateConstructorUsedError;
  @JsonKey(name: 'hold_duration')
  int? get holdDuration => throw _privateConstructorUsedError; // Gauge/Display specific
  @JsonKey(name: 'telemetry_key')
  String? get telemetryKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit')
  String? get unit => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_value')
  double? get minValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_value')
  double? get maxValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'decimal_places')
  int get decimalPlaces => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_ranges')
  List<Map<String, dynamic>>? get colorRanges =>
      throw _privateConstructorUsedError; // Switch specific
  @JsonKey(name: 'switch_command_on')
  String? get switchCommandOn => throw _privateConstructorUsedError;
  @JsonKey(name: 'switch_command_off')
  String? get switchCommandOff => throw _privateConstructorUsedError;
  @JsonKey(name: 'switch_payload_on')
  Map<String, dynamic>? get switchPayloadOn =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'switch_payload_off')
  Map<String, dynamic>? get switchPayloadOff =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_state')
  bool get initialState => throw _privateConstructorUsedError;

  /// Serializes this ApiScreenItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiScreenItemCopyWith<ApiScreenItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiScreenItemCopyWith<$Res> {
  factory $ApiScreenItemCopyWith(
    ApiScreenItem value,
    $Res Function(ApiScreenItem) then,
  ) = _$ApiScreenItemCopyWithImpl<$Res, ApiScreenItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'type') String type,
    @JsonKey(name: 'title') String title,
    @JsonKey(name: 'position') Map<String, dynamic> position,
    @JsonKey(name: 'enabled') bool enabled,
    @JsonKey(name: 'visible') bool visible,
    @JsonKey(name: 'background_color') String? backgroundColor,
    @JsonKey(name: 'text_color') String? textColor,
    @JsonKey(name: 'border_color') String? borderColor,
    @JsonKey(name: 'icon') String? icon,
    @JsonKey(name: 'action') String? action,
    @JsonKey(name: 'command') String? command,
    @JsonKey(name: 'payload') Map<String, dynamic>? payload,
    @JsonKey(name: 'is_momentary') bool isMomentary,
    @JsonKey(name: 'hold_duration') int? holdDuration,
    @JsonKey(name: 'telemetry_key') String? telemetryKey,
    @JsonKey(name: 'unit') String? unit,
    @JsonKey(name: 'min_value') double? minValue,
    @JsonKey(name: 'max_value') double? maxValue,
    @JsonKey(name: 'decimal_places') int decimalPlaces,
    @JsonKey(name: 'color_ranges') List<Map<String, dynamic>>? colorRanges,
    @JsonKey(name: 'switch_command_on') String? switchCommandOn,
    @JsonKey(name: 'switch_command_off') String? switchCommandOff,
    @JsonKey(name: 'switch_payload_on') Map<String, dynamic>? switchPayloadOn,
    @JsonKey(name: 'switch_payload_off') Map<String, dynamic>? switchPayloadOff,
    @JsonKey(name: 'initial_state') bool initialState,
  });
}

/// @nodoc
class _$ApiScreenItemCopyWithImpl<$Res, $Val extends ApiScreenItem>
    implements $ApiScreenItemCopyWith<$Res> {
  _$ApiScreenItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? position = null,
    Object? enabled = null,
    Object? visible = null,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? borderColor = freezed,
    Object? icon = freezed,
    Object? action = freezed,
    Object? command = freezed,
    Object? payload = freezed,
    Object? isMomentary = null,
    Object? holdDuration = freezed,
    Object? telemetryKey = freezed,
    Object? unit = freezed,
    Object? minValue = freezed,
    Object? maxValue = freezed,
    Object? decimalPlaces = null,
    Object? colorRanges = freezed,
    Object? switchCommandOn = freezed,
    Object? switchCommandOff = freezed,
    Object? switchPayloadOn = freezed,
    Object? switchPayloadOff = freezed,
    Object? initialState = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as bool,
            backgroundColor: freezed == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            textColor: freezed == textColor
                ? _value.textColor
                : textColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            borderColor: freezed == borderColor
                ? _value.borderColor
                : borderColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            action: freezed == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String?,
            command: freezed == command
                ? _value.command
                : command // ignore: cast_nullable_to_non_nullable
                      as String?,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            isMomentary: null == isMomentary
                ? _value.isMomentary
                : isMomentary // ignore: cast_nullable_to_non_nullable
                      as bool,
            holdDuration: freezed == holdDuration
                ? _value.holdDuration
                : holdDuration // ignore: cast_nullable_to_non_nullable
                      as int?,
            telemetryKey: freezed == telemetryKey
                ? _value.telemetryKey
                : telemetryKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
            minValue: freezed == minValue
                ? _value.minValue
                : minValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            maxValue: freezed == maxValue
                ? _value.maxValue
                : maxValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            decimalPlaces: null == decimalPlaces
                ? _value.decimalPlaces
                : decimalPlaces // ignore: cast_nullable_to_non_nullable
                      as int,
            colorRanges: freezed == colorRanges
                ? _value.colorRanges
                : colorRanges // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>?,
            switchCommandOn: freezed == switchCommandOn
                ? _value.switchCommandOn
                : switchCommandOn // ignore: cast_nullable_to_non_nullable
                      as String?,
            switchCommandOff: freezed == switchCommandOff
                ? _value.switchCommandOff
                : switchCommandOff // ignore: cast_nullable_to_non_nullable
                      as String?,
            switchPayloadOn: freezed == switchPayloadOn
                ? _value.switchPayloadOn
                : switchPayloadOn // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            switchPayloadOff: freezed == switchPayloadOff
                ? _value.switchPayloadOff
                : switchPayloadOff // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            initialState: null == initialState
                ? _value.initialState
                : initialState // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiScreenItemImplCopyWith<$Res>
    implements $ApiScreenItemCopyWith<$Res> {
  factory _$$ApiScreenItemImplCopyWith(
    _$ApiScreenItemImpl value,
    $Res Function(_$ApiScreenItemImpl) then,
  ) = __$$ApiScreenItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'type') String type,
    @JsonKey(name: 'title') String title,
    @JsonKey(name: 'position') Map<String, dynamic> position,
    @JsonKey(name: 'enabled') bool enabled,
    @JsonKey(name: 'visible') bool visible,
    @JsonKey(name: 'background_color') String? backgroundColor,
    @JsonKey(name: 'text_color') String? textColor,
    @JsonKey(name: 'border_color') String? borderColor,
    @JsonKey(name: 'icon') String? icon,
    @JsonKey(name: 'action') String? action,
    @JsonKey(name: 'command') String? command,
    @JsonKey(name: 'payload') Map<String, dynamic>? payload,
    @JsonKey(name: 'is_momentary') bool isMomentary,
    @JsonKey(name: 'hold_duration') int? holdDuration,
    @JsonKey(name: 'telemetry_key') String? telemetryKey,
    @JsonKey(name: 'unit') String? unit,
    @JsonKey(name: 'min_value') double? minValue,
    @JsonKey(name: 'max_value') double? maxValue,
    @JsonKey(name: 'decimal_places') int decimalPlaces,
    @JsonKey(name: 'color_ranges') List<Map<String, dynamic>>? colorRanges,
    @JsonKey(name: 'switch_command_on') String? switchCommandOn,
    @JsonKey(name: 'switch_command_off') String? switchCommandOff,
    @JsonKey(name: 'switch_payload_on') Map<String, dynamic>? switchPayloadOn,
    @JsonKey(name: 'switch_payload_off') Map<String, dynamic>? switchPayloadOff,
    @JsonKey(name: 'initial_state') bool initialState,
  });
}

/// @nodoc
class __$$ApiScreenItemImplCopyWithImpl<$Res>
    extends _$ApiScreenItemCopyWithImpl<$Res, _$ApiScreenItemImpl>
    implements _$$ApiScreenItemImplCopyWith<$Res> {
  __$$ApiScreenItemImplCopyWithImpl(
    _$ApiScreenItemImpl _value,
    $Res Function(_$ApiScreenItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? position = null,
    Object? enabled = null,
    Object? visible = null,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? borderColor = freezed,
    Object? icon = freezed,
    Object? action = freezed,
    Object? command = freezed,
    Object? payload = freezed,
    Object? isMomentary = null,
    Object? holdDuration = freezed,
    Object? telemetryKey = freezed,
    Object? unit = freezed,
    Object? minValue = freezed,
    Object? maxValue = freezed,
    Object? decimalPlaces = null,
    Object? colorRanges = freezed,
    Object? switchCommandOn = freezed,
    Object? switchCommandOff = freezed,
    Object? switchPayloadOn = freezed,
    Object? switchPayloadOff = freezed,
    Object? initialState = null,
  }) {
    return _then(
      _$ApiScreenItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value._position
            : position // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        visible: null == visible
            ? _value.visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as bool,
        backgroundColor: freezed == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        textColor: freezed == textColor
            ? _value.textColor
            : textColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        borderColor: freezed == borderColor
            ? _value.borderColor
            : borderColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        action: freezed == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String?,
        command: freezed == command
            ? _value.command
            : command // ignore: cast_nullable_to_non_nullable
                  as String?,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        isMomentary: null == isMomentary
            ? _value.isMomentary
            : isMomentary // ignore: cast_nullable_to_non_nullable
                  as bool,
        holdDuration: freezed == holdDuration
            ? _value.holdDuration
            : holdDuration // ignore: cast_nullable_to_non_nullable
                  as int?,
        telemetryKey: freezed == telemetryKey
            ? _value.telemetryKey
            : telemetryKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
        minValue: freezed == minValue
            ? _value.minValue
            : minValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        maxValue: freezed == maxValue
            ? _value.maxValue
            : maxValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        decimalPlaces: null == decimalPlaces
            ? _value.decimalPlaces
            : decimalPlaces // ignore: cast_nullable_to_non_nullable
                  as int,
        colorRanges: freezed == colorRanges
            ? _value._colorRanges
            : colorRanges // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>?,
        switchCommandOn: freezed == switchCommandOn
            ? _value.switchCommandOn
            : switchCommandOn // ignore: cast_nullable_to_non_nullable
                  as String?,
        switchCommandOff: freezed == switchCommandOff
            ? _value.switchCommandOff
            : switchCommandOff // ignore: cast_nullable_to_non_nullable
                  as String?,
        switchPayloadOn: freezed == switchPayloadOn
            ? _value._switchPayloadOn
            : switchPayloadOn // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        switchPayloadOff: freezed == switchPayloadOff
            ? _value._switchPayloadOff
            : switchPayloadOff // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        initialState: null == initialState
            ? _value.initialState
            : initialState // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiScreenItemImpl implements _ApiScreenItem {
  const _$ApiScreenItemImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'type') required this.type,
    @JsonKey(name: 'title') required this.title,
    @JsonKey(name: 'position') required final Map<String, dynamic> position,
    @JsonKey(name: 'enabled') this.enabled = true,
    @JsonKey(name: 'visible') this.visible = true,
    @JsonKey(name: 'background_color') this.backgroundColor,
    @JsonKey(name: 'text_color') this.textColor,
    @JsonKey(name: 'border_color') this.borderColor,
    @JsonKey(name: 'icon') this.icon,
    @JsonKey(name: 'action') this.action,
    @JsonKey(name: 'command') this.command,
    @JsonKey(name: 'payload') final Map<String, dynamic>? payload,
    @JsonKey(name: 'is_momentary') this.isMomentary = false,
    @JsonKey(name: 'hold_duration') this.holdDuration,
    @JsonKey(name: 'telemetry_key') this.telemetryKey,
    @JsonKey(name: 'unit') this.unit,
    @JsonKey(name: 'min_value') this.minValue,
    @JsonKey(name: 'max_value') this.maxValue,
    @JsonKey(name: 'decimal_places') this.decimalPlaces = 0,
    @JsonKey(name: 'color_ranges')
    final List<Map<String, dynamic>>? colorRanges,
    @JsonKey(name: 'switch_command_on') this.switchCommandOn,
    @JsonKey(name: 'switch_command_off') this.switchCommandOff,
    @JsonKey(name: 'switch_payload_on')
    final Map<String, dynamic>? switchPayloadOn,
    @JsonKey(name: 'switch_payload_off')
    final Map<String, dynamic>? switchPayloadOff,
    @JsonKey(name: 'initial_state') this.initialState = false,
  }) : _position = position,
       _payload = payload,
       _colorRanges = colorRanges,
       _switchPayloadOn = switchPayloadOn,
       _switchPayloadOff = switchPayloadOff;

  factory _$ApiScreenItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiScreenItemImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'type')
  final String type;
  // 'button', 'gauge', 'display', 'switch'
  @override
  @JsonKey(name: 'title')
  final String title;
  final Map<String, dynamic> _position;
  @override
  @JsonKey(name: 'position')
  Map<String, dynamic> get position {
    if (_position is EqualUnmodifiableMapView) return _position;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_position);
  }

  // {row, col, span_x, span_y}
  @override
  @JsonKey(name: 'enabled')
  final bool enabled;
  @override
  @JsonKey(name: 'visible')
  final bool visible;
  // Common styling
  @override
  @JsonKey(name: 'background_color')
  final String? backgroundColor;
  @override
  @JsonKey(name: 'text_color')
  final String? textColor;
  @override
  @JsonKey(name: 'border_color')
  final String? borderColor;
  @override
  @JsonKey(name: 'icon')
  final String? icon;
  // Button specific
  @override
  @JsonKey(name: 'action')
  final String? action;
  @override
  @JsonKey(name: 'command')
  final String? command;
  final Map<String, dynamic>? _payload;
  @override
  @JsonKey(name: 'payload')
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'is_momentary')
  final bool isMomentary;
  @override
  @JsonKey(name: 'hold_duration')
  final int? holdDuration;
  // Gauge/Display specific
  @override
  @JsonKey(name: 'telemetry_key')
  final String? telemetryKey;
  @override
  @JsonKey(name: 'unit')
  final String? unit;
  @override
  @JsonKey(name: 'min_value')
  final double? minValue;
  @override
  @JsonKey(name: 'max_value')
  final double? maxValue;
  @override
  @JsonKey(name: 'decimal_places')
  final int decimalPlaces;
  final List<Map<String, dynamic>>? _colorRanges;
  @override
  @JsonKey(name: 'color_ranges')
  List<Map<String, dynamic>>? get colorRanges {
    final value = _colorRanges;
    if (value == null) return null;
    if (_colorRanges is EqualUnmodifiableListView) return _colorRanges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Switch specific
  @override
  @JsonKey(name: 'switch_command_on')
  final String? switchCommandOn;
  @override
  @JsonKey(name: 'switch_command_off')
  final String? switchCommandOff;
  final Map<String, dynamic>? _switchPayloadOn;
  @override
  @JsonKey(name: 'switch_payload_on')
  Map<String, dynamic>? get switchPayloadOn {
    final value = _switchPayloadOn;
    if (value == null) return null;
    if (_switchPayloadOn is EqualUnmodifiableMapView) return _switchPayloadOn;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _switchPayloadOff;
  @override
  @JsonKey(name: 'switch_payload_off')
  Map<String, dynamic>? get switchPayloadOff {
    final value = _switchPayloadOff;
    if (value == null) return null;
    if (_switchPayloadOff is EqualUnmodifiableMapView) return _switchPayloadOff;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'initial_state')
  final bool initialState;

  @override
  String toString() {
    return 'ApiScreenItem(id: $id, type: $type, title: $title, position: $position, enabled: $enabled, visible: $visible, backgroundColor: $backgroundColor, textColor: $textColor, borderColor: $borderColor, icon: $icon, action: $action, command: $command, payload: $payload, isMomentary: $isMomentary, holdDuration: $holdDuration, telemetryKey: $telemetryKey, unit: $unit, minValue: $minValue, maxValue: $maxValue, decimalPlaces: $decimalPlaces, colorRanges: $colorRanges, switchCommandOn: $switchCommandOn, switchCommandOff: $switchCommandOff, switchPayloadOn: $switchPayloadOn, switchPayloadOff: $switchPayloadOff, initialState: $initialState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiScreenItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._position, _position) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.borderColor, borderColor) ||
                other.borderColor == borderColor) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.command, command) || other.command == command) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.isMomentary, isMomentary) ||
                other.isMomentary == isMomentary) &&
            (identical(other.holdDuration, holdDuration) ||
                other.holdDuration == holdDuration) &&
            (identical(other.telemetryKey, telemetryKey) ||
                other.telemetryKey == telemetryKey) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.minValue, minValue) ||
                other.minValue == minValue) &&
            (identical(other.maxValue, maxValue) ||
                other.maxValue == maxValue) &&
            (identical(other.decimalPlaces, decimalPlaces) ||
                other.decimalPlaces == decimalPlaces) &&
            const DeepCollectionEquality().equals(
              other._colorRanges,
              _colorRanges,
            ) &&
            (identical(other.switchCommandOn, switchCommandOn) ||
                other.switchCommandOn == switchCommandOn) &&
            (identical(other.switchCommandOff, switchCommandOff) ||
                other.switchCommandOff == switchCommandOff) &&
            const DeepCollectionEquality().equals(
              other._switchPayloadOn,
              _switchPayloadOn,
            ) &&
            const DeepCollectionEquality().equals(
              other._switchPayloadOff,
              _switchPayloadOff,
            ) &&
            (identical(other.initialState, initialState) ||
                other.initialState == initialState));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    type,
    title,
    const DeepCollectionEquality().hash(_position),
    enabled,
    visible,
    backgroundColor,
    textColor,
    borderColor,
    icon,
    action,
    command,
    const DeepCollectionEquality().hash(_payload),
    isMomentary,
    holdDuration,
    telemetryKey,
    unit,
    minValue,
    maxValue,
    decimalPlaces,
    const DeepCollectionEquality().hash(_colorRanges),
    switchCommandOn,
    switchCommandOff,
    const DeepCollectionEquality().hash(_switchPayloadOn),
    const DeepCollectionEquality().hash(_switchPayloadOff),
    initialState,
  ]);

  /// Create a copy of ApiScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiScreenItemImplCopyWith<_$ApiScreenItemImpl> get copyWith =>
      __$$ApiScreenItemImplCopyWithImpl<_$ApiScreenItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiScreenItemImplToJson(this);
  }
}

abstract class _ApiScreenItem implements ApiScreenItem {
  const factory _ApiScreenItem({
    @JsonKey(name: 'id') required final String id,
    @JsonKey(name: 'type') required final String type,
    @JsonKey(name: 'title') required final String title,
    @JsonKey(name: 'position') required final Map<String, dynamic> position,
    @JsonKey(name: 'enabled') final bool enabled,
    @JsonKey(name: 'visible') final bool visible,
    @JsonKey(name: 'background_color') final String? backgroundColor,
    @JsonKey(name: 'text_color') final String? textColor,
    @JsonKey(name: 'border_color') final String? borderColor,
    @JsonKey(name: 'icon') final String? icon,
    @JsonKey(name: 'action') final String? action,
    @JsonKey(name: 'command') final String? command,
    @JsonKey(name: 'payload') final Map<String, dynamic>? payload,
    @JsonKey(name: 'is_momentary') final bool isMomentary,
    @JsonKey(name: 'hold_duration') final int? holdDuration,
    @JsonKey(name: 'telemetry_key') final String? telemetryKey,
    @JsonKey(name: 'unit') final String? unit,
    @JsonKey(name: 'min_value') final double? minValue,
    @JsonKey(name: 'max_value') final double? maxValue,
    @JsonKey(name: 'decimal_places') final int decimalPlaces,
    @JsonKey(name: 'color_ranges')
    final List<Map<String, dynamic>>? colorRanges,
    @JsonKey(name: 'switch_command_on') final String? switchCommandOn,
    @JsonKey(name: 'switch_command_off') final String? switchCommandOff,
    @JsonKey(name: 'switch_payload_on')
    final Map<String, dynamic>? switchPayloadOn,
    @JsonKey(name: 'switch_payload_off')
    final Map<String, dynamic>? switchPayloadOff,
    @JsonKey(name: 'initial_state') final bool initialState,
  }) = _$ApiScreenItemImpl;

  factory _ApiScreenItem.fromJson(Map<String, dynamic> json) =
      _$ApiScreenItemImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'type')
  String get type; // 'button', 'gauge', 'display', 'switch'
  @override
  @JsonKey(name: 'title')
  String get title;
  @override
  @JsonKey(name: 'position')
  Map<String, dynamic> get position; // {row, col, span_x, span_y}
  @override
  @JsonKey(name: 'enabled')
  bool get enabled;
  @override
  @JsonKey(name: 'visible')
  bool get visible; // Common styling
  @override
  @JsonKey(name: 'background_color')
  String? get backgroundColor;
  @override
  @JsonKey(name: 'text_color')
  String? get textColor;
  @override
  @JsonKey(name: 'border_color')
  String? get borderColor;
  @override
  @JsonKey(name: 'icon')
  String? get icon; // Button specific
  @override
  @JsonKey(name: 'action')
  String? get action;
  @override
  @JsonKey(name: 'command')
  String? get command;
  @override
  @JsonKey(name: 'payload')
  Map<String, dynamic>? get payload;
  @override
  @JsonKey(name: 'is_momentary')
  bool get isMomentary;
  @override
  @JsonKey(name: 'hold_duration')
  int? get holdDuration; // Gauge/Display specific
  @override
  @JsonKey(name: 'telemetry_key')
  String? get telemetryKey;
  @override
  @JsonKey(name: 'unit')
  String? get unit;
  @override
  @JsonKey(name: 'min_value')
  double? get minValue;
  @override
  @JsonKey(name: 'max_value')
  double? get maxValue;
  @override
  @JsonKey(name: 'decimal_places')
  int get decimalPlaces;
  @override
  @JsonKey(name: 'color_ranges')
  List<Map<String, dynamic>>? get colorRanges; // Switch specific
  @override
  @JsonKey(name: 'switch_command_on')
  String? get switchCommandOn;
  @override
  @JsonKey(name: 'switch_command_off')
  String? get switchCommandOff;
  @override
  @JsonKey(name: 'switch_payload_on')
  Map<String, dynamic>? get switchPayloadOn;
  @override
  @JsonKey(name: 'switch_payload_off')
  Map<String, dynamic>? get switchPayloadOff;
  @override
  @JsonKey(name: 'initial_state')
  bool get initialState;

  /// Create a copy of ApiScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiScreenItemImplCopyWith<_$ApiScreenItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
