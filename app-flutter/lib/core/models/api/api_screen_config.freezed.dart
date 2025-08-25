// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_screen_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApiScreenConfig _$ApiScreenConfigFromJson(Map<String, dynamic> json) {
  return _ApiScreenConfig.fromJson(json);
}

/// @nodoc
mixin _$ApiScreenConfig {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'order')
  int get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'enabled')
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon')
  String? get icon => throw _privateConstructorUsedError;
  @JsonKey(name: 'route')
  String? get route => throw _privateConstructorUsedError;
  @JsonKey(name: 'items')
  List<ApiScreenItem> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh_interval')
  int? get refreshInterval => throw _privateConstructorUsedError;
  @JsonKey(name: 'requires_authentication')
  bool get requiresAuthentication => throw _privateConstructorUsedError;
  @JsonKey(name: 'background_color')
  String? get backgroundColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_color')
  String? get textColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'layout_type')
  String get layoutType => throw _privateConstructorUsedError;
  @JsonKey(name: 'columns')
  int get columns => throw _privateConstructorUsedError;

  /// Serializes this ApiScreenConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiScreenConfigCopyWith<ApiScreenConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiScreenConfigCopyWith<$Res> {
  factory $ApiScreenConfigCopyWith(
    ApiScreenConfig value,
    $Res Function(ApiScreenConfig) then,
  ) = _$ApiScreenConfigCopyWithImpl<$Res, ApiScreenConfig>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'title') String title,
    @JsonKey(name: 'order') int order,
    @JsonKey(name: 'enabled') bool enabled,
    @JsonKey(name: 'icon') String? icon,
    @JsonKey(name: 'route') String? route,
    @JsonKey(name: 'items') List<ApiScreenItem> items,
    @JsonKey(name: 'refresh_interval') int? refreshInterval,
    @JsonKey(name: 'requires_authentication') bool requiresAuthentication,
    @JsonKey(name: 'background_color') String? backgroundColor,
    @JsonKey(name: 'text_color') String? textColor,
    @JsonKey(name: 'layout_type') String layoutType,
    @JsonKey(name: 'columns') int columns,
  });
}

/// @nodoc
class _$ApiScreenConfigCopyWithImpl<$Res, $Val extends ApiScreenConfig>
    implements $ApiScreenConfigCopyWith<$Res> {
  _$ApiScreenConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? title = null,
    Object? order = null,
    Object? enabled = null,
    Object? icon = freezed,
    Object? route = freezed,
    Object? items = null,
    Object? refreshInterval = freezed,
    Object? requiresAuthentication = null,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? layoutType = null,
    Object? columns = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            route: freezed == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as String?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ApiScreenItem>,
            refreshInterval: freezed == refreshInterval
                ? _value.refreshInterval
                : refreshInterval // ignore: cast_nullable_to_non_nullable
                      as int?,
            requiresAuthentication: null == requiresAuthentication
                ? _value.requiresAuthentication
                : requiresAuthentication // ignore: cast_nullable_to_non_nullable
                      as bool,
            backgroundColor: freezed == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            textColor: freezed == textColor
                ? _value.textColor
                : textColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            layoutType: null == layoutType
                ? _value.layoutType
                : layoutType // ignore: cast_nullable_to_non_nullable
                      as String,
            columns: null == columns
                ? _value.columns
                : columns // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiScreenConfigImplCopyWith<$Res>
    implements $ApiScreenConfigCopyWith<$Res> {
  factory _$$ApiScreenConfigImplCopyWith(
    _$ApiScreenConfigImpl value,
    $Res Function(_$ApiScreenConfigImpl) then,
  ) = __$$ApiScreenConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'title') String title,
    @JsonKey(name: 'order') int order,
    @JsonKey(name: 'enabled') bool enabled,
    @JsonKey(name: 'icon') String? icon,
    @JsonKey(name: 'route') String? route,
    @JsonKey(name: 'items') List<ApiScreenItem> items,
    @JsonKey(name: 'refresh_interval') int? refreshInterval,
    @JsonKey(name: 'requires_authentication') bool requiresAuthentication,
    @JsonKey(name: 'background_color') String? backgroundColor,
    @JsonKey(name: 'text_color') String? textColor,
    @JsonKey(name: 'layout_type') String layoutType,
    @JsonKey(name: 'columns') int columns,
  });
}

/// @nodoc
class __$$ApiScreenConfigImplCopyWithImpl<$Res>
    extends _$ApiScreenConfigCopyWithImpl<$Res, _$ApiScreenConfigImpl>
    implements _$$ApiScreenConfigImplCopyWith<$Res> {
  __$$ApiScreenConfigImplCopyWithImpl(
    _$ApiScreenConfigImpl _value,
    $Res Function(_$ApiScreenConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? title = null,
    Object? order = null,
    Object? enabled = null,
    Object? icon = freezed,
    Object? route = freezed,
    Object? items = null,
    Object? refreshInterval = freezed,
    Object? requiresAuthentication = null,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? layoutType = null,
    Object? columns = null,
  }) {
    return _then(
      _$ApiScreenConfigImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        route: freezed == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as String?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ApiScreenItem>,
        refreshInterval: freezed == refreshInterval
            ? _value.refreshInterval
            : refreshInterval // ignore: cast_nullable_to_non_nullable
                  as int?,
        requiresAuthentication: null == requiresAuthentication
            ? _value.requiresAuthentication
            : requiresAuthentication // ignore: cast_nullable_to_non_nullable
                  as bool,
        backgroundColor: freezed == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        textColor: freezed == textColor
            ? _value.textColor
            : textColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        layoutType: null == layoutType
            ? _value.layoutType
            : layoutType // ignore: cast_nullable_to_non_nullable
                  as String,
        columns: null == columns
            ? _value.columns
            : columns // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiScreenConfigImpl implements _ApiScreenConfig {
  const _$ApiScreenConfigImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'name') required this.name,
    @JsonKey(name: 'title') required this.title,
    @JsonKey(name: 'order') required this.order,
    @JsonKey(name: 'enabled') this.enabled = true,
    @JsonKey(name: 'icon') this.icon,
    @JsonKey(name: 'route') this.route,
    @JsonKey(name: 'items') final List<ApiScreenItem> items = const [],
    @JsonKey(name: 'refresh_interval') this.refreshInterval,
    @JsonKey(name: 'requires_authentication')
    this.requiresAuthentication = false,
    @JsonKey(name: 'background_color') this.backgroundColor,
    @JsonKey(name: 'text_color') this.textColor,
    @JsonKey(name: 'layout_type') this.layoutType = 'grid',
    @JsonKey(name: 'columns') this.columns = 2,
  }) : _items = items;

  factory _$ApiScreenConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiScreenConfigImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'title')
  final String title;
  @override
  @JsonKey(name: 'order')
  final int order;
  @override
  @JsonKey(name: 'enabled')
  final bool enabled;
  @override
  @JsonKey(name: 'icon')
  final String? icon;
  @override
  @JsonKey(name: 'route')
  final String? route;
  final List<ApiScreenItem> _items;
  @override
  @JsonKey(name: 'items')
  List<ApiScreenItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey(name: 'refresh_interval')
  final int? refreshInterval;
  @override
  @JsonKey(name: 'requires_authentication')
  final bool requiresAuthentication;
  @override
  @JsonKey(name: 'background_color')
  final String? backgroundColor;
  @override
  @JsonKey(name: 'text_color')
  final String? textColor;
  @override
  @JsonKey(name: 'layout_type')
  final String layoutType;
  @override
  @JsonKey(name: 'columns')
  final int columns;

  @override
  String toString() {
    return 'ApiScreenConfig(id: $id, name: $name, title: $title, order: $order, enabled: $enabled, icon: $icon, route: $route, items: $items, refreshInterval: $refreshInterval, requiresAuthentication: $requiresAuthentication, backgroundColor: $backgroundColor, textColor: $textColor, layoutType: $layoutType, columns: $columns)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiScreenConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.route, route) || other.route == route) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.refreshInterval, refreshInterval) ||
                other.refreshInterval == refreshInterval) &&
            (identical(other.requiresAuthentication, requiresAuthentication) ||
                other.requiresAuthentication == requiresAuthentication) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.layoutType, layoutType) ||
                other.layoutType == layoutType) &&
            (identical(other.columns, columns) || other.columns == columns));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    title,
    order,
    enabled,
    icon,
    route,
    const DeepCollectionEquality().hash(_items),
    refreshInterval,
    requiresAuthentication,
    backgroundColor,
    textColor,
    layoutType,
    columns,
  );

  /// Create a copy of ApiScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiScreenConfigImplCopyWith<_$ApiScreenConfigImpl> get copyWith =>
      __$$ApiScreenConfigImplCopyWithImpl<_$ApiScreenConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiScreenConfigImplToJson(this);
  }
}

abstract class _ApiScreenConfig implements ApiScreenConfig {
  const factory _ApiScreenConfig({
    @JsonKey(name: 'id') required final String id,
    @JsonKey(name: 'name') required final String name,
    @JsonKey(name: 'title') required final String title,
    @JsonKey(name: 'order') required final int order,
    @JsonKey(name: 'enabled') final bool enabled,
    @JsonKey(name: 'icon') final String? icon,
    @JsonKey(name: 'route') final String? route,
    @JsonKey(name: 'items') final List<ApiScreenItem> items,
    @JsonKey(name: 'refresh_interval') final int? refreshInterval,
    @JsonKey(name: 'requires_authentication') final bool requiresAuthentication,
    @JsonKey(name: 'background_color') final String? backgroundColor,
    @JsonKey(name: 'text_color') final String? textColor,
    @JsonKey(name: 'layout_type') final String layoutType,
    @JsonKey(name: 'columns') final int columns,
  }) = _$ApiScreenConfigImpl;

  factory _ApiScreenConfig.fromJson(Map<String, dynamic> json) =
      _$ApiScreenConfigImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'title')
  String get title;
  @override
  @JsonKey(name: 'order')
  int get order;
  @override
  @JsonKey(name: 'enabled')
  bool get enabled;
  @override
  @JsonKey(name: 'icon')
  String? get icon;
  @override
  @JsonKey(name: 'route')
  String? get route;
  @override
  @JsonKey(name: 'items')
  List<ApiScreenItem> get items;
  @override
  @JsonKey(name: 'refresh_interval')
  int? get refreshInterval;
  @override
  @JsonKey(name: 'requires_authentication')
  bool get requiresAuthentication;
  @override
  @JsonKey(name: 'background_color')
  String? get backgroundColor;
  @override
  @JsonKey(name: 'text_color')
  String? get textColor;
  @override
  @JsonKey(name: 'layout_type')
  String get layoutType;
  @override
  @JsonKey(name: 'columns')
  int get columns;

  /// Create a copy of ApiScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiScreenConfigImplCopyWith<_$ApiScreenConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
