// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'screen_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScreenConfig _$ScreenConfigFromJson(Map<String, dynamic> json) {
  return _ScreenConfig.fromJson(json);
}

/// @nodoc
mixin _$ScreenConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get route => throw _privateConstructorUsedError;
  ScreenLayout get layout => throw _privateConstructorUsedError;
  List<WidgetConfig> get widgets => throw _privateConstructorUsedError;
  bool get visible => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ScreenConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScreenConfigCopyWith<ScreenConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScreenConfigCopyWith<$Res> {
  factory $ScreenConfigCopyWith(
    ScreenConfig value,
    $Res Function(ScreenConfig) then,
  ) = _$ScreenConfigCopyWithImpl<$Res, ScreenConfig>;
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    String route,
    ScreenLayout layout,
    List<WidgetConfig> widgets,
    bool visible,
    int order,
    Map<String, dynamic>? metadata,
  });

  $ScreenLayoutCopyWith<$Res> get layout;
}

/// @nodoc
class _$ScreenConfigCopyWithImpl<$Res, $Val extends ScreenConfig>
    implements $ScreenConfigCopyWith<$Res> {
  _$ScreenConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? route = null,
    Object? layout = null,
    Object? widgets = null,
    Object? visible = null,
    Object? order = null,
    Object? metadata = freezed,
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
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            route: null == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as String,
            layout: null == layout
                ? _value.layout
                : layout // ignore: cast_nullable_to_non_nullable
                      as ScreenLayout,
            widgets: null == widgets
                ? _value.widgets
                : widgets // ignore: cast_nullable_to_non_nullable
                      as List<WidgetConfig>,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as bool,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of ScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScreenLayoutCopyWith<$Res> get layout {
    return $ScreenLayoutCopyWith<$Res>(_value.layout, (value) {
      return _then(_value.copyWith(layout: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScreenConfigImplCopyWith<$Res>
    implements $ScreenConfigCopyWith<$Res> {
  factory _$$ScreenConfigImplCopyWith(
    _$ScreenConfigImpl value,
    $Res Function(_$ScreenConfigImpl) then,
  ) = __$$ScreenConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    String route,
    ScreenLayout layout,
    List<WidgetConfig> widgets,
    bool visible,
    int order,
    Map<String, dynamic>? metadata,
  });

  @override
  $ScreenLayoutCopyWith<$Res> get layout;
}

/// @nodoc
class __$$ScreenConfigImplCopyWithImpl<$Res>
    extends _$ScreenConfigCopyWithImpl<$Res, _$ScreenConfigImpl>
    implements _$$ScreenConfigImplCopyWith<$Res> {
  __$$ScreenConfigImplCopyWithImpl(
    _$ScreenConfigImpl _value,
    $Res Function(_$ScreenConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? route = null,
    Object? layout = null,
    Object? widgets = null,
    Object? visible = null,
    Object? order = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ScreenConfigImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        route: null == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as String,
        layout: null == layout
            ? _value.layout
            : layout // ignore: cast_nullable_to_non_nullable
                  as ScreenLayout,
        widgets: null == widgets
            ? _value._widgets
            : widgets // ignore: cast_nullable_to_non_nullable
                  as List<WidgetConfig>,
        visible: null == visible
            ? _value.visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as bool,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScreenConfigImpl implements _ScreenConfig {
  const _$ScreenConfigImpl({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    required this.layout,
    final List<WidgetConfig> widgets = const [],
    this.visible = true,
    this.order = 0,
    final Map<String, dynamic>? metadata,
  }) : _widgets = widgets,
       _metadata = metadata;

  factory _$ScreenConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScreenConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  final String route;
  @override
  final ScreenLayout layout;
  final List<WidgetConfig> _widgets;
  @override
  @JsonKey()
  List<WidgetConfig> get widgets {
    if (_widgets is EqualUnmodifiableListView) return _widgets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_widgets);
  }

  @override
  @JsonKey()
  final bool visible;
  @override
  @JsonKey()
  final int order;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ScreenConfig(id: $id, name: $name, icon: $icon, route: $route, layout: $layout, widgets: $widgets, visible: $visible, order: $order, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScreenConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            const DeepCollectionEquality().equals(other._widgets, _widgets) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    icon,
    route,
    layout,
    const DeepCollectionEquality().hash(_widgets),
    visible,
    order,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScreenConfigImplCopyWith<_$ScreenConfigImpl> get copyWith =>
      __$$ScreenConfigImplCopyWithImpl<_$ScreenConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScreenConfigImplToJson(this);
  }
}

abstract class _ScreenConfig implements ScreenConfig {
  const factory _ScreenConfig({
    required final String id,
    required final String name,
    required final String icon,
    required final String route,
    required final ScreenLayout layout,
    final List<WidgetConfig> widgets,
    final bool visible,
    final int order,
    final Map<String, dynamic>? metadata,
  }) = _$ScreenConfigImpl;

  factory _ScreenConfig.fromJson(Map<String, dynamic> json) =
      _$ScreenConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  String get route;
  @override
  ScreenLayout get layout;
  @override
  List<WidgetConfig> get widgets;
  @override
  bool get visible;
  @override
  int get order;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScreenConfigImplCopyWith<_$ScreenConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScreenLayout _$ScreenLayoutFromJson(Map<String, dynamic> json) {
  return _ScreenLayout.fromJson(json);
}

/// @nodoc
mixin _$ScreenLayout {
  String get type => throw _privateConstructorUsedError; // grid, list, custom
  int get columns => throw _privateConstructorUsedError;
  int get maxColumns => throw _privateConstructorUsedError;
  double get minItemWidth => throw _privateConstructorUsedError;
  double get aspectRatio => throw _privateConstructorUsedError;
  EdgeInsetsConfig? get padding => throw _privateConstructorUsedError;
  double get spacing => throw _privateConstructorUsedError;

  /// Serializes this ScreenLayout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScreenLayout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScreenLayoutCopyWith<ScreenLayout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScreenLayoutCopyWith<$Res> {
  factory $ScreenLayoutCopyWith(
    ScreenLayout value,
    $Res Function(ScreenLayout) then,
  ) = _$ScreenLayoutCopyWithImpl<$Res, ScreenLayout>;
  @useResult
  $Res call({
    String type,
    int columns,
    int maxColumns,
    double minItemWidth,
    double aspectRatio,
    EdgeInsetsConfig? padding,
    double spacing,
  });

  $EdgeInsetsConfigCopyWith<$Res>? get padding;
}

/// @nodoc
class _$ScreenLayoutCopyWithImpl<$Res, $Val extends ScreenLayout>
    implements $ScreenLayoutCopyWith<$Res> {
  _$ScreenLayoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScreenLayout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? columns = null,
    Object? maxColumns = null,
    Object? minItemWidth = null,
    Object? aspectRatio = null,
    Object? padding = freezed,
    Object? spacing = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            columns: null == columns
                ? _value.columns
                : columns // ignore: cast_nullable_to_non_nullable
                      as int,
            maxColumns: null == maxColumns
                ? _value.maxColumns
                : maxColumns // ignore: cast_nullable_to_non_nullable
                      as int,
            minItemWidth: null == minItemWidth
                ? _value.minItemWidth
                : minItemWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            aspectRatio: null == aspectRatio
                ? _value.aspectRatio
                : aspectRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            padding: freezed == padding
                ? _value.padding
                : padding // ignore: cast_nullable_to_non_nullable
                      as EdgeInsetsConfig?,
            spacing: null == spacing
                ? _value.spacing
                : spacing // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of ScreenLayout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EdgeInsetsConfigCopyWith<$Res>? get padding {
    if (_value.padding == null) {
      return null;
    }

    return $EdgeInsetsConfigCopyWith<$Res>(_value.padding!, (value) {
      return _then(_value.copyWith(padding: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScreenLayoutImplCopyWith<$Res>
    implements $ScreenLayoutCopyWith<$Res> {
  factory _$$ScreenLayoutImplCopyWith(
    _$ScreenLayoutImpl value,
    $Res Function(_$ScreenLayoutImpl) then,
  ) = __$$ScreenLayoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    int columns,
    int maxColumns,
    double minItemWidth,
    double aspectRatio,
    EdgeInsetsConfig? padding,
    double spacing,
  });

  @override
  $EdgeInsetsConfigCopyWith<$Res>? get padding;
}

/// @nodoc
class __$$ScreenLayoutImplCopyWithImpl<$Res>
    extends _$ScreenLayoutCopyWithImpl<$Res, _$ScreenLayoutImpl>
    implements _$$ScreenLayoutImplCopyWith<$Res> {
  __$$ScreenLayoutImplCopyWithImpl(
    _$ScreenLayoutImpl _value,
    $Res Function(_$ScreenLayoutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScreenLayout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? columns = null,
    Object? maxColumns = null,
    Object? minItemWidth = null,
    Object? aspectRatio = null,
    Object? padding = freezed,
    Object? spacing = null,
  }) {
    return _then(
      _$ScreenLayoutImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        columns: null == columns
            ? _value.columns
            : columns // ignore: cast_nullable_to_non_nullable
                  as int,
        maxColumns: null == maxColumns
            ? _value.maxColumns
            : maxColumns // ignore: cast_nullable_to_non_nullable
                  as int,
        minItemWidth: null == minItemWidth
            ? _value.minItemWidth
            : minItemWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        aspectRatio: null == aspectRatio
            ? _value.aspectRatio
            : aspectRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        padding: freezed == padding
            ? _value.padding
            : padding // ignore: cast_nullable_to_non_nullable
                  as EdgeInsetsConfig?,
        spacing: null == spacing
            ? _value.spacing
            : spacing // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScreenLayoutImpl implements _ScreenLayout {
  const _$ScreenLayoutImpl({
    this.type = 'grid',
    this.columns = 2,
    this.maxColumns = 4,
    this.minItemWidth = 150.0,
    this.aspectRatio = 1.0,
    this.padding,
    this.spacing = 16.0,
  });

  factory _$ScreenLayoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScreenLayoutImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  // grid, list, custom
  @override
  @JsonKey()
  final int columns;
  @override
  @JsonKey()
  final int maxColumns;
  @override
  @JsonKey()
  final double minItemWidth;
  @override
  @JsonKey()
  final double aspectRatio;
  @override
  final EdgeInsetsConfig? padding;
  @override
  @JsonKey()
  final double spacing;

  @override
  String toString() {
    return 'ScreenLayout(type: $type, columns: $columns, maxColumns: $maxColumns, minItemWidth: $minItemWidth, aspectRatio: $aspectRatio, padding: $padding, spacing: $spacing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScreenLayoutImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.columns, columns) || other.columns == columns) &&
            (identical(other.maxColumns, maxColumns) ||
                other.maxColumns == maxColumns) &&
            (identical(other.minItemWidth, minItemWidth) ||
                other.minItemWidth == minItemWidth) &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio) &&
            (identical(other.padding, padding) || other.padding == padding) &&
            (identical(other.spacing, spacing) || other.spacing == spacing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    columns,
    maxColumns,
    minItemWidth,
    aspectRatio,
    padding,
    spacing,
  );

  /// Create a copy of ScreenLayout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScreenLayoutImplCopyWith<_$ScreenLayoutImpl> get copyWith =>
      __$$ScreenLayoutImplCopyWithImpl<_$ScreenLayoutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScreenLayoutImplToJson(this);
  }
}

abstract class _ScreenLayout implements ScreenLayout {
  const factory _ScreenLayout({
    final String type,
    final int columns,
    final int maxColumns,
    final double minItemWidth,
    final double aspectRatio,
    final EdgeInsetsConfig? padding,
    final double spacing,
  }) = _$ScreenLayoutImpl;

  factory _ScreenLayout.fromJson(Map<String, dynamic> json) =
      _$ScreenLayoutImpl.fromJson;

  @override
  String get type; // grid, list, custom
  @override
  int get columns;
  @override
  int get maxColumns;
  @override
  double get minItemWidth;
  @override
  double get aspectRatio;
  @override
  EdgeInsetsConfig? get padding;
  @override
  double get spacing;

  /// Create a copy of ScreenLayout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScreenLayoutImplCopyWith<_$ScreenLayoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WidgetConfig _$WidgetConfigFromJson(Map<String, dynamic> json) {
  return _WidgetConfig.fromJson(json);
}

/// @nodoc
mixin _$WidgetConfig {
  String get id => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // control_tile, gauge, button, container, text, etc
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;
  bool get visible => throw _privateConstructorUsedError;
  List<String> get topics =>
      throw _privateConstructorUsedError; // MQTT topics to subscribe
  Map<String, ActionConfig> get actions => throw _privateConstructorUsedError;
  List<WidgetConfig> get children => throw _privateConstructorUsedError;

  /// Serializes this WidgetConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WidgetConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WidgetConfigCopyWith<WidgetConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WidgetConfigCopyWith<$Res> {
  factory $WidgetConfigCopyWith(
    WidgetConfig value,
    $Res Function(WidgetConfig) then,
  ) = _$WidgetConfigCopyWithImpl<$Res, WidgetConfig>;
  @useResult
  $Res call({
    String id,
    String type,
    Map<String, dynamic> properties,
    bool visible,
    List<String> topics,
    Map<String, ActionConfig> actions,
    List<WidgetConfig> children,
  });
}

/// @nodoc
class _$WidgetConfigCopyWithImpl<$Res, $Val extends WidgetConfig>
    implements $WidgetConfigCopyWith<$Res> {
  _$WidgetConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WidgetConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? properties = null,
    Object? visible = null,
    Object? topics = null,
    Object? actions = null,
    Object? children = null,
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
            properties: null == properties
                ? _value.properties
                : properties // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as bool,
            topics: null == topics
                ? _value.topics
                : topics // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            actions: null == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as Map<String, ActionConfig>,
            children: null == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                      as List<WidgetConfig>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WidgetConfigImplCopyWith<$Res>
    implements $WidgetConfigCopyWith<$Res> {
  factory _$$WidgetConfigImplCopyWith(
    _$WidgetConfigImpl value,
    $Res Function(_$WidgetConfigImpl) then,
  ) = __$$WidgetConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    Map<String, dynamic> properties,
    bool visible,
    List<String> topics,
    Map<String, ActionConfig> actions,
    List<WidgetConfig> children,
  });
}

/// @nodoc
class __$$WidgetConfigImplCopyWithImpl<$Res>
    extends _$WidgetConfigCopyWithImpl<$Res, _$WidgetConfigImpl>
    implements _$$WidgetConfigImplCopyWith<$Res> {
  __$$WidgetConfigImplCopyWithImpl(
    _$WidgetConfigImpl _value,
    $Res Function(_$WidgetConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WidgetConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? properties = null,
    Object? visible = null,
    Object? topics = null,
    Object? actions = null,
    Object? children = null,
  }) {
    return _then(
      _$WidgetConfigImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        properties: null == properties
            ? _value._properties
            : properties // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        visible: null == visible
            ? _value.visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as bool,
        topics: null == topics
            ? _value._topics
            : topics // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        actions: null == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as Map<String, ActionConfig>,
        children: null == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<WidgetConfig>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WidgetConfigImpl implements _WidgetConfig {
  const _$WidgetConfigImpl({
    required this.id,
    required this.type,
    required final Map<String, dynamic> properties,
    this.visible = true,
    final List<String> topics = const [],
    final Map<String, ActionConfig> actions = const {},
    final List<WidgetConfig> children = const [],
  }) : _properties = properties,
       _topics = topics,
       _actions = actions,
       _children = children;

  factory _$WidgetConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$WidgetConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  // control_tile, gauge, button, container, text, etc
  final Map<String, dynamic> _properties;
  // control_tile, gauge, button, container, text, etc
  @override
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  @override
  @JsonKey()
  final bool visible;
  final List<String> _topics;
  @override
  @JsonKey()
  List<String> get topics {
    if (_topics is EqualUnmodifiableListView) return _topics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topics);
  }

  // MQTT topics to subscribe
  final Map<String, ActionConfig> _actions;
  // MQTT topics to subscribe
  @override
  @JsonKey()
  Map<String, ActionConfig> get actions {
    if (_actions is EqualUnmodifiableMapView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_actions);
  }

  final List<WidgetConfig> _children;
  @override
  @JsonKey()
  List<WidgetConfig> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  String toString() {
    return 'WidgetConfig(id: $id, type: $type, properties: $properties, visible: $visible, topics: $topics, actions: $actions, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WidgetConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(
              other._properties,
              _properties,
            ) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            const DeepCollectionEquality().equals(other._topics, _topics) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    const DeepCollectionEquality().hash(_properties),
    visible,
    const DeepCollectionEquality().hash(_topics),
    const DeepCollectionEquality().hash(_actions),
    const DeepCollectionEquality().hash(_children),
  );

  /// Create a copy of WidgetConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WidgetConfigImplCopyWith<_$WidgetConfigImpl> get copyWith =>
      __$$WidgetConfigImplCopyWithImpl<_$WidgetConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WidgetConfigImplToJson(this);
  }
}

abstract class _WidgetConfig implements WidgetConfig {
  const factory _WidgetConfig({
    required final String id,
    required final String type,
    required final Map<String, dynamic> properties,
    final bool visible,
    final List<String> topics,
    final Map<String, ActionConfig> actions,
    final List<WidgetConfig> children,
  }) = _$WidgetConfigImpl;

  factory _WidgetConfig.fromJson(Map<String, dynamic> json) =
      _$WidgetConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get type; // control_tile, gauge, button, container, text, etc
  @override
  Map<String, dynamic> get properties;
  @override
  bool get visible;
  @override
  List<String> get topics; // MQTT topics to subscribe
  @override
  Map<String, ActionConfig> get actions;
  @override
  List<WidgetConfig> get children;

  /// Create a copy of WidgetConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WidgetConfigImplCopyWith<_$WidgetConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActionConfig _$ActionConfigFromJson(Map<String, dynamic> json) {
  return _ActionConfig.fromJson(json);
}

/// @nodoc
mixin _$ActionConfig {
  String get type =>
      throw _privateConstructorUsedError; // mqtt_publish, navigate, dialog, macro
  Map<String, dynamic> get params => throw _privateConstructorUsedError;
  String? get confirmMessage => throw _privateConstructorUsedError;
  bool get requireConfirmation => throw _privateConstructorUsedError;

  /// Serializes this ActionConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionConfigCopyWith<ActionConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionConfigCopyWith<$Res> {
  factory $ActionConfigCopyWith(
    ActionConfig value,
    $Res Function(ActionConfig) then,
  ) = _$ActionConfigCopyWithImpl<$Res, ActionConfig>;
  @useResult
  $Res call({
    String type,
    Map<String, dynamic> params,
    String? confirmMessage,
    bool requireConfirmation,
  });
}

/// @nodoc
class _$ActionConfigCopyWithImpl<$Res, $Val extends ActionConfig>
    implements $ActionConfigCopyWith<$Res> {
  _$ActionConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? params = null,
    Object? confirmMessage = freezed,
    Object? requireConfirmation = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            params: null == params
                ? _value.params
                : params // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            confirmMessage: freezed == confirmMessage
                ? _value.confirmMessage
                : confirmMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            requireConfirmation: null == requireConfirmation
                ? _value.requireConfirmation
                : requireConfirmation // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActionConfigImplCopyWith<$Res>
    implements $ActionConfigCopyWith<$Res> {
  factory _$$ActionConfigImplCopyWith(
    _$ActionConfigImpl value,
    $Res Function(_$ActionConfigImpl) then,
  ) = __$$ActionConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    Map<String, dynamic> params,
    String? confirmMessage,
    bool requireConfirmation,
  });
}

/// @nodoc
class __$$ActionConfigImplCopyWithImpl<$Res>
    extends _$ActionConfigCopyWithImpl<$Res, _$ActionConfigImpl>
    implements _$$ActionConfigImplCopyWith<$Res> {
  __$$ActionConfigImplCopyWithImpl(
    _$ActionConfigImpl _value,
    $Res Function(_$ActionConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? params = null,
    Object? confirmMessage = freezed,
    Object? requireConfirmation = null,
  }) {
    return _then(
      _$ActionConfigImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        params: null == params
            ? _value._params
            : params // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        confirmMessage: freezed == confirmMessage
            ? _value.confirmMessage
            : confirmMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        requireConfirmation: null == requireConfirmation
            ? _value.requireConfirmation
            : requireConfirmation // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionConfigImpl implements _ActionConfig {
  const _$ActionConfigImpl({
    required this.type,
    required final Map<String, dynamic> params,
    this.confirmMessage,
    this.requireConfirmation = false,
  }) : _params = params;

  factory _$ActionConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionConfigImplFromJson(json);

  @override
  final String type;
  // mqtt_publish, navigate, dialog, macro
  final Map<String, dynamic> _params;
  // mqtt_publish, navigate, dialog, macro
  @override
  Map<String, dynamic> get params {
    if (_params is EqualUnmodifiableMapView) return _params;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_params);
  }

  @override
  final String? confirmMessage;
  @override
  @JsonKey()
  final bool requireConfirmation;

  @override
  String toString() {
    return 'ActionConfig(type: $type, params: $params, confirmMessage: $confirmMessage, requireConfirmation: $requireConfirmation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionConfigImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._params, _params) &&
            (identical(other.confirmMessage, confirmMessage) ||
                other.confirmMessage == confirmMessage) &&
            (identical(other.requireConfirmation, requireConfirmation) ||
                other.requireConfirmation == requireConfirmation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    const DeepCollectionEquality().hash(_params),
    confirmMessage,
    requireConfirmation,
  );

  /// Create a copy of ActionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionConfigImplCopyWith<_$ActionConfigImpl> get copyWith =>
      __$$ActionConfigImplCopyWithImpl<_$ActionConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionConfigImplToJson(this);
  }
}

abstract class _ActionConfig implements ActionConfig {
  const factory _ActionConfig({
    required final String type,
    required final Map<String, dynamic> params,
    final String? confirmMessage,
    final bool requireConfirmation,
  }) = _$ActionConfigImpl;

  factory _ActionConfig.fromJson(Map<String, dynamic> json) =
      _$ActionConfigImpl.fromJson;

  @override
  String get type; // mqtt_publish, navigate, dialog, macro
  @override
  Map<String, dynamic> get params;
  @override
  String? get confirmMessage;
  @override
  bool get requireConfirmation;

  /// Create a copy of ActionConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionConfigImplCopyWith<_$ActionConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EdgeInsetsConfig _$EdgeInsetsConfigFromJson(Map<String, dynamic> json) {
  return _EdgeInsetsConfig.fromJson(json);
}

/// @nodoc
mixin _$EdgeInsetsConfig {
  double get top => throw _privateConstructorUsedError;
  double get right => throw _privateConstructorUsedError;
  double get bottom => throw _privateConstructorUsedError;
  double get left => throw _privateConstructorUsedError;

  /// Serializes this EdgeInsetsConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EdgeInsetsConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EdgeInsetsConfigCopyWith<EdgeInsetsConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EdgeInsetsConfigCopyWith<$Res> {
  factory $EdgeInsetsConfigCopyWith(
    EdgeInsetsConfig value,
    $Res Function(EdgeInsetsConfig) then,
  ) = _$EdgeInsetsConfigCopyWithImpl<$Res, EdgeInsetsConfig>;
  @useResult
  $Res call({double top, double right, double bottom, double left});
}

/// @nodoc
class _$EdgeInsetsConfigCopyWithImpl<$Res, $Val extends EdgeInsetsConfig>
    implements $EdgeInsetsConfigCopyWith<$Res> {
  _$EdgeInsetsConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EdgeInsetsConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? top = null,
    Object? right = null,
    Object? bottom = null,
    Object? left = null,
  }) {
    return _then(
      _value.copyWith(
            top: null == top
                ? _value.top
                : top // ignore: cast_nullable_to_non_nullable
                      as double,
            right: null == right
                ? _value.right
                : right // ignore: cast_nullable_to_non_nullable
                      as double,
            bottom: null == bottom
                ? _value.bottom
                : bottom // ignore: cast_nullable_to_non_nullable
                      as double,
            left: null == left
                ? _value.left
                : left // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EdgeInsetsConfigImplCopyWith<$Res>
    implements $EdgeInsetsConfigCopyWith<$Res> {
  factory _$$EdgeInsetsConfigImplCopyWith(
    _$EdgeInsetsConfigImpl value,
    $Res Function(_$EdgeInsetsConfigImpl) then,
  ) = __$$EdgeInsetsConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double top, double right, double bottom, double left});
}

/// @nodoc
class __$$EdgeInsetsConfigImplCopyWithImpl<$Res>
    extends _$EdgeInsetsConfigCopyWithImpl<$Res, _$EdgeInsetsConfigImpl>
    implements _$$EdgeInsetsConfigImplCopyWith<$Res> {
  __$$EdgeInsetsConfigImplCopyWithImpl(
    _$EdgeInsetsConfigImpl _value,
    $Res Function(_$EdgeInsetsConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EdgeInsetsConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? top = null,
    Object? right = null,
    Object? bottom = null,
    Object? left = null,
  }) {
    return _then(
      _$EdgeInsetsConfigImpl(
        top: null == top
            ? _value.top
            : top // ignore: cast_nullable_to_non_nullable
                  as double,
        right: null == right
            ? _value.right
            : right // ignore: cast_nullable_to_non_nullable
                  as double,
        bottom: null == bottom
            ? _value.bottom
            : bottom // ignore: cast_nullable_to_non_nullable
                  as double,
        left: null == left
            ? _value.left
            : left // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EdgeInsetsConfigImpl implements _EdgeInsetsConfig {
  const _$EdgeInsetsConfigImpl({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  factory _$EdgeInsetsConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$EdgeInsetsConfigImplFromJson(json);

  @override
  @JsonKey()
  final double top;
  @override
  @JsonKey()
  final double right;
  @override
  @JsonKey()
  final double bottom;
  @override
  @JsonKey()
  final double left;

  @override
  String toString() {
    return 'EdgeInsetsConfig(top: $top, right: $right, bottom: $bottom, left: $left)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EdgeInsetsConfigImpl &&
            (identical(other.top, top) || other.top == top) &&
            (identical(other.right, right) || other.right == right) &&
            (identical(other.bottom, bottom) || other.bottom == bottom) &&
            (identical(other.left, left) || other.left == left));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, top, right, bottom, left);

  /// Create a copy of EdgeInsetsConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EdgeInsetsConfigImplCopyWith<_$EdgeInsetsConfigImpl> get copyWith =>
      __$$EdgeInsetsConfigImplCopyWithImpl<_$EdgeInsetsConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EdgeInsetsConfigImplToJson(this);
  }
}

abstract class _EdgeInsetsConfig implements EdgeInsetsConfig {
  const factory _EdgeInsetsConfig({
    final double top,
    final double right,
    final double bottom,
    final double left,
  }) = _$EdgeInsetsConfigImpl;

  factory _EdgeInsetsConfig.fromJson(Map<String, dynamic> json) =
      _$EdgeInsetsConfigImpl.fromJson;

  @override
  double get top;
  @override
  double get right;
  @override
  double get bottom;
  @override
  double get left;

  /// Create a copy of EdgeInsetsConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EdgeInsetsConfigImplCopyWith<_$EdgeInsetsConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ControlConfig _$ControlConfigFromJson(Map<String, dynamic> json) {
  return _ControlConfig.fromJson(json);
}

/// @nodoc
mixin _$ControlConfig {
  String get deviceId => throw _privateConstructorUsedError;
  String get channelId => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get controlType => throw _privateConstructorUsedError;
  String get size => throw _privateConstructorUsedError;
  bool get confirmAction => throw _privateConstructorUsedError;
  String? get confirmMessage => throw _privateConstructorUsedError;
  Map<String, dynamic>? get style => throw _privateConstructorUsedError;

  /// Serializes this ControlConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ControlConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ControlConfigCopyWith<ControlConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ControlConfigCopyWith<$Res> {
  factory $ControlConfigCopyWith(
    ControlConfig value,
    $Res Function(ControlConfig) then,
  ) = _$ControlConfigCopyWithImpl<$Res, ControlConfig>;
  @useResult
  $Res call({
    String deviceId,
    String channelId,
    String label,
    String? subtitle,
    String icon,
    String controlType,
    String size,
    bool confirmAction,
    String? confirmMessage,
    Map<String, dynamic>? style,
  });
}

/// @nodoc
class _$ControlConfigCopyWithImpl<$Res, $Val extends ControlConfig>
    implements $ControlConfigCopyWith<$Res> {
  _$ControlConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ControlConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? channelId = null,
    Object? label = null,
    Object? subtitle = freezed,
    Object? icon = null,
    Object? controlType = null,
    Object? size = null,
    Object? confirmAction = null,
    Object? confirmMessage = freezed,
    Object? style = freezed,
  }) {
    return _then(
      _value.copyWith(
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            channelId: null == channelId
                ? _value.channelId
                : channelId // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            subtitle: freezed == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            controlType: null == controlType
                ? _value.controlType
                : controlType // ignore: cast_nullable_to_non_nullable
                      as String,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String,
            confirmAction: null == confirmAction
                ? _value.confirmAction
                : confirmAction // ignore: cast_nullable_to_non_nullable
                      as bool,
            confirmMessage: freezed == confirmMessage
                ? _value.confirmMessage
                : confirmMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            style: freezed == style
                ? _value.style
                : style // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ControlConfigImplCopyWith<$Res>
    implements $ControlConfigCopyWith<$Res> {
  factory _$$ControlConfigImplCopyWith(
    _$ControlConfigImpl value,
    $Res Function(_$ControlConfigImpl) then,
  ) = __$$ControlConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String deviceId,
    String channelId,
    String label,
    String? subtitle,
    String icon,
    String controlType,
    String size,
    bool confirmAction,
    String? confirmMessage,
    Map<String, dynamic>? style,
  });
}

/// @nodoc
class __$$ControlConfigImplCopyWithImpl<$Res>
    extends _$ControlConfigCopyWithImpl<$Res, _$ControlConfigImpl>
    implements _$$ControlConfigImplCopyWith<$Res> {
  __$$ControlConfigImplCopyWithImpl(
    _$ControlConfigImpl _value,
    $Res Function(_$ControlConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ControlConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? channelId = null,
    Object? label = null,
    Object? subtitle = freezed,
    Object? icon = null,
    Object? controlType = null,
    Object? size = null,
    Object? confirmAction = null,
    Object? confirmMessage = freezed,
    Object? style = freezed,
  }) {
    return _then(
      _$ControlConfigImpl(
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        channelId: null == channelId
            ? _value.channelId
            : channelId // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        subtitle: freezed == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        controlType: null == controlType
            ? _value.controlType
            : controlType // ignore: cast_nullable_to_non_nullable
                  as String,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String,
        confirmAction: null == confirmAction
            ? _value.confirmAction
            : confirmAction // ignore: cast_nullable_to_non_nullable
                  as bool,
        confirmMessage: freezed == confirmMessage
            ? _value.confirmMessage
            : confirmMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        style: freezed == style
            ? _value._style
            : style // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ControlConfigImpl implements _ControlConfig {
  const _$ControlConfigImpl({
    required this.deviceId,
    required this.channelId,
    required this.label,
    this.subtitle,
    required this.icon,
    this.controlType = 'toggle',
    this.size = 'normal',
    this.confirmAction = false,
    this.confirmMessage,
    final Map<String, dynamic>? style,
  }) : _style = style;

  factory _$ControlConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ControlConfigImplFromJson(json);

  @override
  final String deviceId;
  @override
  final String channelId;
  @override
  final String label;
  @override
  final String? subtitle;
  @override
  final String icon;
  @override
  @JsonKey()
  final String controlType;
  @override
  @JsonKey()
  final String size;
  @override
  @JsonKey()
  final bool confirmAction;
  @override
  final String? confirmMessage;
  final Map<String, dynamic>? _style;
  @override
  Map<String, dynamic>? get style {
    final value = _style;
    if (value == null) return null;
    if (_style is EqualUnmodifiableMapView) return _style;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ControlConfig(deviceId: $deviceId, channelId: $channelId, label: $label, subtitle: $subtitle, icon: $icon, controlType: $controlType, size: $size, confirmAction: $confirmAction, confirmMessage: $confirmMessage, style: $style)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ControlConfigImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.controlType, controlType) ||
                other.controlType == controlType) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.confirmAction, confirmAction) ||
                other.confirmAction == confirmAction) &&
            (identical(other.confirmMessage, confirmMessage) ||
                other.confirmMessage == confirmMessage) &&
            const DeepCollectionEquality().equals(other._style, _style));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deviceId,
    channelId,
    label,
    subtitle,
    icon,
    controlType,
    size,
    confirmAction,
    confirmMessage,
    const DeepCollectionEquality().hash(_style),
  );

  /// Create a copy of ControlConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ControlConfigImplCopyWith<_$ControlConfigImpl> get copyWith =>
      __$$ControlConfigImplCopyWithImpl<_$ControlConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ControlConfigImplToJson(this);
  }
}

abstract class _ControlConfig implements ControlConfig {
  const factory _ControlConfig({
    required final String deviceId,
    required final String channelId,
    required final String label,
    final String? subtitle,
    required final String icon,
    final String controlType,
    final String size,
    final bool confirmAction,
    final String? confirmMessage,
    final Map<String, dynamic>? style,
  }) = _$ControlConfigImpl;

  factory _ControlConfig.fromJson(Map<String, dynamic> json) =
      _$ControlConfigImpl.fromJson;

  @override
  String get deviceId;
  @override
  String get channelId;
  @override
  String get label;
  @override
  String? get subtitle;
  @override
  String get icon;
  @override
  String get controlType;
  @override
  String get size;
  @override
  bool get confirmAction;
  @override
  String? get confirmMessage;
  @override
  Map<String, dynamic>? get style;

  /// Create a copy of ControlConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ControlConfigImplCopyWith<_$ControlConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceConfig _$DeviceConfigFromJson(Map<String, dynamic> json) {
  return _DeviceConfig.fromJson(json);
}

/// @nodoc
mixin _$DeviceConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get online => throw _privateConstructorUsedError;
  Map<String, ChannelConfig> get channels => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this DeviceConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceConfigCopyWith<DeviceConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceConfigCopyWith<$Res> {
  factory $DeviceConfigCopyWith(
    DeviceConfig value,
    $Res Function(DeviceConfig) then,
  ) = _$DeviceConfigCopyWithImpl<$Res, DeviceConfig>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    bool online,
    Map<String, ChannelConfig> channels,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DeviceConfigCopyWithImpl<$Res, $Val extends DeviceConfig>
    implements $DeviceConfigCopyWith<$Res> {
  _$DeviceConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? online = null,
    Object? channels = null,
    Object? metadata = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            online: null == online
                ? _value.online
                : online // ignore: cast_nullable_to_non_nullable
                      as bool,
            channels: null == channels
                ? _value.channels
                : channels // ignore: cast_nullable_to_non_nullable
                      as Map<String, ChannelConfig>,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceConfigImplCopyWith<$Res>
    implements $DeviceConfigCopyWith<$Res> {
  factory _$$DeviceConfigImplCopyWith(
    _$DeviceConfigImpl value,
    $Res Function(_$DeviceConfigImpl) then,
  ) = __$$DeviceConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    bool online,
    Map<String, ChannelConfig> channels,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DeviceConfigImplCopyWithImpl<$Res>
    extends _$DeviceConfigCopyWithImpl<$Res, _$DeviceConfigImpl>
    implements _$$DeviceConfigImplCopyWith<$Res> {
  __$$DeviceConfigImplCopyWithImpl(
    _$DeviceConfigImpl _value,
    $Res Function(_$DeviceConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? online = null,
    Object? channels = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DeviceConfigImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        online: null == online
            ? _value.online
            : online // ignore: cast_nullable_to_non_nullable
                  as bool,
        channels: null == channels
            ? _value._channels
            : channels // ignore: cast_nullable_to_non_nullable
                  as Map<String, ChannelConfig>,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceConfigImpl implements _DeviceConfig {
  const _$DeviceConfigImpl({
    required this.id,
    required this.name,
    required this.type,
    this.online = true,
    required final Map<String, ChannelConfig> channels,
    final Map<String, dynamic>? metadata,
  }) : _channels = channels,
       _metadata = metadata;

  factory _$DeviceConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  @JsonKey()
  final bool online;
  final Map<String, ChannelConfig> _channels;
  @override
  Map<String, ChannelConfig> get channels {
    if (_channels is EqualUnmodifiableMapView) return _channels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_channels);
  }

  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'DeviceConfig(id: $id, name: $name, type: $type, online: $online, channels: $channels, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.online, online) || other.online == online) &&
            const DeepCollectionEquality().equals(other._channels, _channels) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    online,
    const DeepCollectionEquality().hash(_channels),
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DeviceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceConfigImplCopyWith<_$DeviceConfigImpl> get copyWith =>
      __$$DeviceConfigImplCopyWithImpl<_$DeviceConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceConfigImplToJson(this);
  }
}

abstract class _DeviceConfig implements DeviceConfig {
  const factory _DeviceConfig({
    required final String id,
    required final String name,
    required final String type,
    final bool online,
    required final Map<String, ChannelConfig> channels,
    final Map<String, dynamic>? metadata,
  }) = _$DeviceConfigImpl;

  factory _DeviceConfig.fromJson(Map<String, dynamic> json) =
      _$DeviceConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  bool get online;
  @override
  Map<String, ChannelConfig> get channels;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DeviceConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceConfigImplCopyWith<_$DeviceConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChannelConfig _$ChannelConfigFromJson(Map<String, dynamic> json) {
  return _ChannelConfig.fromJson(json);
}

/// @nodoc
mixin _$ChannelConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get functionType => throw _privateConstructorUsedError;
  bool get state => throw _privateConstructorUsedError;
  double? get dimmerValue => throw _privateConstructorUsedError;
  bool get allowInMacro => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ChannelConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChannelConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChannelConfigCopyWith<ChannelConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelConfigCopyWith<$Res> {
  factory $ChannelConfigCopyWith(
    ChannelConfig value,
    $Res Function(ChannelConfig) then,
  ) = _$ChannelConfigCopyWithImpl<$Res, ChannelConfig>;
  @useResult
  $Res call({
    String id,
    String name,
    String functionType,
    bool state,
    double? dimmerValue,
    bool allowInMacro,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ChannelConfigCopyWithImpl<$Res, $Val extends ChannelConfig>
    implements $ChannelConfigCopyWith<$Res> {
  _$ChannelConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChannelConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? functionType = null,
    Object? state = null,
    Object? dimmerValue = freezed,
    Object? allowInMacro = null,
    Object? metadata = freezed,
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
            functionType: null == functionType
                ? _value.functionType
                : functionType // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as bool,
            dimmerValue: freezed == dimmerValue
                ? _value.dimmerValue
                : dimmerValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            allowInMacro: null == allowInMacro
                ? _value.allowInMacro
                : allowInMacro // ignore: cast_nullable_to_non_nullable
                      as bool,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChannelConfigImplCopyWith<$Res>
    implements $ChannelConfigCopyWith<$Res> {
  factory _$$ChannelConfigImplCopyWith(
    _$ChannelConfigImpl value,
    $Res Function(_$ChannelConfigImpl) then,
  ) = __$$ChannelConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String functionType,
    bool state,
    double? dimmerValue,
    bool allowInMacro,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ChannelConfigImplCopyWithImpl<$Res>
    extends _$ChannelConfigCopyWithImpl<$Res, _$ChannelConfigImpl>
    implements _$$ChannelConfigImplCopyWith<$Res> {
  __$$ChannelConfigImplCopyWithImpl(
    _$ChannelConfigImpl _value,
    $Res Function(_$ChannelConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChannelConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? functionType = null,
    Object? state = null,
    Object? dimmerValue = freezed,
    Object? allowInMacro = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ChannelConfigImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        functionType: null == functionType
            ? _value.functionType
            : functionType // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as bool,
        dimmerValue: freezed == dimmerValue
            ? _value.dimmerValue
            : dimmerValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        allowInMacro: null == allowInMacro
            ? _value.allowInMacro
            : allowInMacro // ignore: cast_nullable_to_non_nullable
                  as bool,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChannelConfigImpl implements _ChannelConfig {
  const _$ChannelConfigImpl({
    required this.id,
    required this.name,
    required this.functionType,
    this.state = false,
    this.dimmerValue,
    this.allowInMacro = true,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$ChannelConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChannelConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String functionType;
  @override
  @JsonKey()
  final bool state;
  @override
  final double? dimmerValue;
  @override
  @JsonKey()
  final bool allowInMacro;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ChannelConfig(id: $id, name: $name, functionType: $functionType, state: $state, dimmerValue: $dimmerValue, allowInMacro: $allowInMacro, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChannelConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.functionType, functionType) ||
                other.functionType == functionType) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.dimmerValue, dimmerValue) ||
                other.dimmerValue == dimmerValue) &&
            (identical(other.allowInMacro, allowInMacro) ||
                other.allowInMacro == allowInMacro) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    functionType,
    state,
    dimmerValue,
    allowInMacro,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ChannelConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChannelConfigImplCopyWith<_$ChannelConfigImpl> get copyWith =>
      __$$ChannelConfigImplCopyWithImpl<_$ChannelConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChannelConfigImplToJson(this);
  }
}

abstract class _ChannelConfig implements ChannelConfig {
  const factory _ChannelConfig({
    required final String id,
    required final String name,
    required final String functionType,
    final bool state,
    final double? dimmerValue,
    final bool allowInMacro,
    final Map<String, dynamic>? metadata,
  }) = _$ChannelConfigImpl;

  factory _ChannelConfig.fromJson(Map<String, dynamic> json) =
      _$ChannelConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get functionType;
  @override
  bool get state;
  @override
  double? get dimmerValue;
  @override
  bool get allowInMacro;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ChannelConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChannelConfigImplCopyWith<_$ChannelConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return _AppConfig.fromJson(json);
}

/// @nodoc
mixin _$AppConfig {
  String get version => throw _privateConstructorUsedError;
  List<ScreenConfig> get screens => throw _privateConstructorUsedError;
  Map<String, DeviceConfig> get devices => throw _privateConstructorUsedError;
  ThemeConfig? get theme => throw _privateConstructorUsedError;
  MqttConfig? get mqtt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get settings => throw _privateConstructorUsedError;

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
    String version,
    List<ScreenConfig> screens,
    Map<String, DeviceConfig> devices,
    ThemeConfig? theme,
    MqttConfig? mqtt,
    Map<String, dynamic>? settings,
  });

  $ThemeConfigCopyWith<$Res>? get theme;
  $MqttConfigCopyWith<$Res>? get mqtt;
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
    Object? version = null,
    Object? screens = null,
    Object? devices = null,
    Object? theme = freezed,
    Object? mqtt = freezed,
    Object? settings = freezed,
  }) {
    return _then(
      _value.copyWith(
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
            screens: null == screens
                ? _value.screens
                : screens // ignore: cast_nullable_to_non_nullable
                      as List<ScreenConfig>,
            devices: null == devices
                ? _value.devices
                : devices // ignore: cast_nullable_to_non_nullable
                      as Map<String, DeviceConfig>,
            theme: freezed == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as ThemeConfig?,
            mqtt: freezed == mqtt
                ? _value.mqtt
                : mqtt // ignore: cast_nullable_to_non_nullable
                      as MqttConfig?,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ThemeConfigCopyWith<$Res>? get theme {
    if (_value.theme == null) {
      return null;
    }

    return $ThemeConfigCopyWith<$Res>(_value.theme!, (value) {
      return _then(_value.copyWith(theme: value) as $Val);
    });
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MqttConfigCopyWith<$Res>? get mqtt {
    if (_value.mqtt == null) {
      return null;
    }

    return $MqttConfigCopyWith<$Res>(_value.mqtt!, (value) {
      return _then(_value.copyWith(mqtt: value) as $Val);
    });
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
    String version,
    List<ScreenConfig> screens,
    Map<String, DeviceConfig> devices,
    ThemeConfig? theme,
    MqttConfig? mqtt,
    Map<String, dynamic>? settings,
  });

  @override
  $ThemeConfigCopyWith<$Res>? get theme;
  @override
  $MqttConfigCopyWith<$Res>? get mqtt;
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
    Object? version = null,
    Object? screens = null,
    Object? devices = null,
    Object? theme = freezed,
    Object? mqtt = freezed,
    Object? settings = freezed,
  }) {
    return _then(
      _$AppConfigImpl(
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        screens: null == screens
            ? _value._screens
            : screens // ignore: cast_nullable_to_non_nullable
                  as List<ScreenConfig>,
        devices: null == devices
            ? _value._devices
            : devices // ignore: cast_nullable_to_non_nullable
                  as Map<String, DeviceConfig>,
        theme: freezed == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as ThemeConfig?,
        mqtt: freezed == mqtt
            ? _value.mqtt
            : mqtt // ignore: cast_nullable_to_non_nullable
                  as MqttConfig?,
        settings: freezed == settings
            ? _value._settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppConfigImpl implements _AppConfig {
  const _$AppConfigImpl({
    required this.version,
    required final List<ScreenConfig> screens,
    required final Map<String, DeviceConfig> devices,
    this.theme,
    this.mqtt,
    final Map<String, dynamic>? settings,
  }) : _screens = screens,
       _devices = devices,
       _settings = settings;

  factory _$AppConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppConfigImplFromJson(json);

  @override
  final String version;
  final List<ScreenConfig> _screens;
  @override
  List<ScreenConfig> get screens {
    if (_screens is EqualUnmodifiableListView) return _screens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_screens);
  }

  final Map<String, DeviceConfig> _devices;
  @override
  Map<String, DeviceConfig> get devices {
    if (_devices is EqualUnmodifiableMapView) return _devices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_devices);
  }

  @override
  final ThemeConfig? theme;
  @override
  final MqttConfig? mqtt;
  final Map<String, dynamic>? _settings;
  @override
  Map<String, dynamic>? get settings {
    final value = _settings;
    if (value == null) return null;
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppConfig(version: $version, screens: $screens, devices: $devices, theme: $theme, mqtt: $mqtt, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppConfigImpl &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality().equals(other._screens, _screens) &&
            const DeepCollectionEquality().equals(other._devices, _devices) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.mqtt, mqtt) || other.mqtt == mqtt) &&
            const DeepCollectionEquality().equals(other._settings, _settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    const DeepCollectionEquality().hash(_screens),
    const DeepCollectionEquality().hash(_devices),
    theme,
    mqtt,
    const DeepCollectionEquality().hash(_settings),
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

abstract class _AppConfig implements AppConfig {
  const factory _AppConfig({
    required final String version,
    required final List<ScreenConfig> screens,
    required final Map<String, DeviceConfig> devices,
    final ThemeConfig? theme,
    final MqttConfig? mqtt,
    final Map<String, dynamic>? settings,
  }) = _$AppConfigImpl;

  factory _AppConfig.fromJson(Map<String, dynamic> json) =
      _$AppConfigImpl.fromJson;

  @override
  String get version;
  @override
  List<ScreenConfig> get screens;
  @override
  Map<String, DeviceConfig> get devices;
  @override
  ThemeConfig? get theme;
  @override
  MqttConfig? get mqtt;
  @override
  Map<String, dynamic>? get settings;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ThemeConfig _$ThemeConfigFromJson(Map<String, dynamic> json) {
  return _ThemeConfig.fromJson(json);
}

/// @nodoc
mixin _$ThemeConfig {
  String get mode => throw _privateConstructorUsedError;
  String? get primaryColor => throw _privateConstructorUsedError;
  String? get accentColor => throw _privateConstructorUsedError;
  Map<String, dynamic>? get custom => throw _privateConstructorUsedError;

  /// Serializes this ThemeConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThemeConfigCopyWith<ThemeConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemeConfigCopyWith<$Res> {
  factory $ThemeConfigCopyWith(
    ThemeConfig value,
    $Res Function(ThemeConfig) then,
  ) = _$ThemeConfigCopyWithImpl<$Res, ThemeConfig>;
  @useResult
  $Res call({
    String mode,
    String? primaryColor,
    String? accentColor,
    Map<String, dynamic>? custom,
  });
}

/// @nodoc
class _$ThemeConfigCopyWithImpl<$Res, $Val extends ThemeConfig>
    implements $ThemeConfigCopyWith<$Res> {
  _$ThemeConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? primaryColor = freezed,
    Object? accentColor = freezed,
    Object? custom = freezed,
  }) {
    return _then(
      _value.copyWith(
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String,
            primaryColor: freezed == primaryColor
                ? _value.primaryColor
                : primaryColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            accentColor: freezed == accentColor
                ? _value.accentColor
                : accentColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            custom: freezed == custom
                ? _value.custom
                : custom // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ThemeConfigImplCopyWith<$Res>
    implements $ThemeConfigCopyWith<$Res> {
  factory _$$ThemeConfigImplCopyWith(
    _$ThemeConfigImpl value,
    $Res Function(_$ThemeConfigImpl) then,
  ) = __$$ThemeConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String mode,
    String? primaryColor,
    String? accentColor,
    Map<String, dynamic>? custom,
  });
}

/// @nodoc
class __$$ThemeConfigImplCopyWithImpl<$Res>
    extends _$ThemeConfigCopyWithImpl<$Res, _$ThemeConfigImpl>
    implements _$$ThemeConfigImplCopyWith<$Res> {
  __$$ThemeConfigImplCopyWithImpl(
    _$ThemeConfigImpl _value,
    $Res Function(_$ThemeConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? primaryColor = freezed,
    Object? accentColor = freezed,
    Object? custom = freezed,
  }) {
    return _then(
      _$ThemeConfigImpl(
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String,
        primaryColor: freezed == primaryColor
            ? _value.primaryColor
            : primaryColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        accentColor: freezed == accentColor
            ? _value.accentColor
            : accentColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        custom: freezed == custom
            ? _value._custom
            : custom // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ThemeConfigImpl implements _ThemeConfig {
  const _$ThemeConfigImpl({
    this.mode = 'dark',
    this.primaryColor,
    this.accentColor,
    final Map<String, dynamic>? custom,
  }) : _custom = custom;

  factory _$ThemeConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThemeConfigImplFromJson(json);

  @override
  @JsonKey()
  final String mode;
  @override
  final String? primaryColor;
  @override
  final String? accentColor;
  final Map<String, dynamic>? _custom;
  @override
  Map<String, dynamic>? get custom {
    final value = _custom;
    if (value == null) return null;
    if (_custom is EqualUnmodifiableMapView) return _custom;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ThemeConfig(mode: $mode, primaryColor: $primaryColor, accentColor: $accentColor, custom: $custom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemeConfigImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor) &&
            const DeepCollectionEquality().equals(other._custom, _custom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    mode,
    primaryColor,
    accentColor,
    const DeepCollectionEquality().hash(_custom),
  );

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemeConfigImplCopyWith<_$ThemeConfigImpl> get copyWith =>
      __$$ThemeConfigImplCopyWithImpl<_$ThemeConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThemeConfigImplToJson(this);
  }
}

abstract class _ThemeConfig implements ThemeConfig {
  const factory _ThemeConfig({
    final String mode,
    final String? primaryColor,
    final String? accentColor,
    final Map<String, dynamic>? custom,
  }) = _$ThemeConfigImpl;

  factory _ThemeConfig.fromJson(Map<String, dynamic> json) =
      _$ThemeConfigImpl.fromJson;

  @override
  String get mode;
  @override
  String? get primaryColor;
  @override
  String? get accentColor;
  @override
  Map<String, dynamic>? get custom;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThemeConfigImplCopyWith<_$ThemeConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MqttConfig _$MqttConfigFromJson(Map<String, dynamic> json) {
  return _MqttConfig.fromJson(json);
}

/// @nodoc
mixin _$MqttConfig {
  String get broker => throw _privateConstructorUsedError;
  int get port => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  List<String> get topics => throw _privateConstructorUsedError;

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
    String clientId,
    List<String> topics,
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
    Object? clientId = null,
    Object? topics = null,
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
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            topics: null == topics
                ? _value.topics
                : topics // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
    String clientId,
    List<String> topics,
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
    Object? clientId = null,
    Object? topics = null,
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
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        topics: null == topics
            ? _value._topics
            : topics // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MqttConfigImpl implements _MqttConfig {
  const _$MqttConfigImpl({
    required this.broker,
    this.port = 1883,
    this.username,
    this.password,
    this.clientId = 'autocore_app',
    final List<String> topics = const ['autocore/#'],
  }) : _topics = topics;

  factory _$MqttConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$MqttConfigImplFromJson(json);

  @override
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
  final String clientId;
  final List<String> _topics;
  @override
  @JsonKey()
  List<String> get topics {
    if (_topics is EqualUnmodifiableListView) return _topics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topics);
  }

  @override
  String toString() {
    return 'MqttConfig(broker: $broker, port: $port, username: $username, password: $password, clientId: $clientId, topics: $topics)';
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
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            const DeepCollectionEquality().equals(other._topics, _topics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    broker,
    port,
    username,
    password,
    clientId,
    const DeepCollectionEquality().hash(_topics),
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

abstract class _MqttConfig implements MqttConfig {
  const factory _MqttConfig({
    required final String broker,
    final int port,
    final String? username,
    final String? password,
    final String clientId,
    final List<String> topics,
  }) = _$MqttConfigImpl;

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
  String get clientId;
  @override
  List<String> get topics;

  /// Create a copy of MqttConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MqttConfigImplCopyWith<_$MqttConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
