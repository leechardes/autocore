// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'color_range.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ColorRange _$ColorRangeFromJson(Map<String, dynamic> json) {
  return _ColorRange.fromJson(json);
}

/// @nodoc
mixin _$ColorRange {
  @JsonKey(name: 'min')
  double get min => throw _privateConstructorUsedError;
  @JsonKey(name: 'max')
  double get max => throw _privateConstructorUsedError;
  @JsonKey(name: 'color')
  String get color => throw _privateConstructorUsedError;
  @JsonKey(name: 'label')
  String? get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'priority')
  int get priority => throw _privateConstructorUsedError;

  /// Serializes this ColorRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ColorRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColorRangeCopyWith<ColorRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColorRangeCopyWith<$Res> {
  factory $ColorRangeCopyWith(
    ColorRange value,
    $Res Function(ColorRange) then,
  ) = _$ColorRangeCopyWithImpl<$Res, ColorRange>;
  @useResult
  $Res call({
    @JsonKey(name: 'min') double min,
    @JsonKey(name: 'max') double max,
    @JsonKey(name: 'color') String color,
    @JsonKey(name: 'label') String? label,
    @JsonKey(name: 'priority') int priority,
  });
}

/// @nodoc
class _$ColorRangeCopyWithImpl<$Res, $Val extends ColorRange>
    implements $ColorRangeCopyWith<$Res> {
  _$ColorRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColorRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
    Object? color = null,
    Object? label = freezed,
    Object? priority = null,
  }) {
    return _then(
      _value.copyWith(
            min: null == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as double,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as double,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ColorRangeImplCopyWith<$Res>
    implements $ColorRangeCopyWith<$Res> {
  factory _$$ColorRangeImplCopyWith(
    _$ColorRangeImpl value,
    $Res Function(_$ColorRangeImpl) then,
  ) = __$$ColorRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'min') double min,
    @JsonKey(name: 'max') double max,
    @JsonKey(name: 'color') String color,
    @JsonKey(name: 'label') String? label,
    @JsonKey(name: 'priority') int priority,
  });
}

/// @nodoc
class __$$ColorRangeImplCopyWithImpl<$Res>
    extends _$ColorRangeCopyWithImpl<$Res, _$ColorRangeImpl>
    implements _$$ColorRangeImplCopyWith<$Res> {
  __$$ColorRangeImplCopyWithImpl(
    _$ColorRangeImpl _value,
    $Res Function(_$ColorRangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ColorRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
    Object? color = null,
    Object? label = freezed,
    Object? priority = null,
  }) {
    return _then(
      _$ColorRangeImpl(
        min: null == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as double,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as double,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ColorRangeImpl implements _ColorRange {
  const _$ColorRangeImpl({
    @JsonKey(name: 'min') required this.min,
    @JsonKey(name: 'max') required this.max,
    @JsonKey(name: 'color') required this.color,
    @JsonKey(name: 'label') this.label,
    @JsonKey(name: 'priority') this.priority = 0,
  });

  factory _$ColorRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColorRangeImplFromJson(json);

  @override
  @JsonKey(name: 'min')
  final double min;
  @override
  @JsonKey(name: 'max')
  final double max;
  @override
  @JsonKey(name: 'color')
  final String color;
  @override
  @JsonKey(name: 'label')
  final String? label;
  @override
  @JsonKey(name: 'priority')
  final int priority;

  @override
  String toString() {
    return 'ColorRange(min: $min, max: $max, color: $color, label: $label, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColorRangeImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, min, max, color, label, priority);

  /// Create a copy of ColorRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColorRangeImplCopyWith<_$ColorRangeImpl> get copyWith =>
      __$$ColorRangeImplCopyWithImpl<_$ColorRangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColorRangeImplToJson(this);
  }
}

abstract class _ColorRange implements ColorRange {
  const factory _ColorRange({
    @JsonKey(name: 'min') required final double min,
    @JsonKey(name: 'max') required final double max,
    @JsonKey(name: 'color') required final String color,
    @JsonKey(name: 'label') final String? label,
    @JsonKey(name: 'priority') final int priority,
  }) = _$ColorRangeImpl;

  factory _ColorRange.fromJson(Map<String, dynamic> json) =
      _$ColorRangeImpl.fromJson;

  @override
  @JsonKey(name: 'min')
  double get min;
  @override
  @JsonKey(name: 'max')
  double get max;
  @override
  @JsonKey(name: 'color')
  String get color;
  @override
  @JsonKey(name: 'label')
  String? get label;
  @override
  @JsonKey(name: 'priority')
  int get priority;

  /// Create a copy of ColorRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColorRangeImplCopyWith<_$ColorRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
