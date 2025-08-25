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
  String? get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get route => throw _privateConstructorUsedError;
  List<ScreenItem> get items => throw _privateConstructorUsedError;
  String get layout =>
      throw _privateConstructorUsedError; // 'grid', 'list', 'tabs', 'custom'
  int get columns => throw _privateConstructorUsedError;
  bool get showHeader => throw _privateConstructorUsedError;
  bool get showNavigation => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customProperties =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

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
    String? description,
    String? icon,
    String? route,
    List<ScreenItem> items,
    String layout,
    int columns,
    bool showHeader,
    bool showNavigation,
    Map<String, dynamic>? customProperties,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
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
    Object? description = freezed,
    Object? icon = freezed,
    Object? route = freezed,
    Object? items = null,
    Object? layout = null,
    Object? columns = null,
    Object? showHeader = null,
    Object? showNavigation = null,
    Object? customProperties = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
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
                      as List<ScreenItem>,
            layout: null == layout
                ? _value.layout
                : layout // ignore: cast_nullable_to_non_nullable
                      as String,
            columns: null == columns
                ? _value.columns
                : columns // ignore: cast_nullable_to_non_nullable
                      as int,
            showHeader: null == showHeader
                ? _value.showHeader
                : showHeader // ignore: cast_nullable_to_non_nullable
                      as bool,
            showNavigation: null == showNavigation
                ? _value.showNavigation
                : showNavigation // ignore: cast_nullable_to_non_nullable
                      as bool,
            customProperties: freezed == customProperties
                ? _value.customProperties
                : customProperties // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
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
    String? description,
    String? icon,
    String? route,
    List<ScreenItem> items,
    String layout,
    int columns,
    bool showHeader,
    bool showNavigation,
    Map<String, dynamic>? customProperties,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
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
    Object? description = freezed,
    Object? icon = freezed,
    Object? route = freezed,
    Object? items = null,
    Object? layout = null,
    Object? columns = null,
    Object? showHeader = null,
    Object? showNavigation = null,
    Object? customProperties = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
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
                  as List<ScreenItem>,
        layout: null == layout
            ? _value.layout
            : layout // ignore: cast_nullable_to_non_nullable
                  as String,
        columns: null == columns
            ? _value.columns
            : columns // ignore: cast_nullable_to_non_nullable
                  as int,
        showHeader: null == showHeader
            ? _value.showHeader
            : showHeader // ignore: cast_nullable_to_non_nullable
                  as bool,
        showNavigation: null == showNavigation
            ? _value.showNavigation
            : showNavigation // ignore: cast_nullable_to_non_nullable
                  as bool,
        customProperties: freezed == customProperties
            ? _value._customProperties
            : customProperties // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
    this.description,
    this.icon,
    this.route,
    final List<ScreenItem> items = const [],
    this.layout = 'grid',
    this.columns = 2,
    this.showHeader = true,
    this.showNavigation = true,
    final Map<String, dynamic>? customProperties,
    this.createdAt,
    this.updatedAt,
  }) : _items = items,
       _customProperties = customProperties;

  factory _$ScreenConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScreenConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? icon;
  @override
  final String? route;
  final List<ScreenItem> _items;
  @override
  @JsonKey()
  List<ScreenItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final String layout;
  // 'grid', 'list', 'tabs', 'custom'
  @override
  @JsonKey()
  final int columns;
  @override
  @JsonKey()
  final bool showHeader;
  @override
  @JsonKey()
  final bool showNavigation;
  final Map<String, dynamic>? _customProperties;
  @override
  Map<String, dynamic>? get customProperties {
    final value = _customProperties;
    if (value == null) return null;
    if (_customProperties is EqualUnmodifiableMapView) return _customProperties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ScreenConfig(id: $id, name: $name, description: $description, icon: $icon, route: $route, items: $items, layout: $layout, columns: $columns, showHeader: $showHeader, showNavigation: $showNavigation, customProperties: $customProperties, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScreenConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.route, route) || other.route == route) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            (identical(other.columns, columns) || other.columns == columns) &&
            (identical(other.showHeader, showHeader) ||
                other.showHeader == showHeader) &&
            (identical(other.showNavigation, showNavigation) ||
                other.showNavigation == showNavigation) &&
            const DeepCollectionEquality().equals(
              other._customProperties,
              _customProperties,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    icon,
    route,
    const DeepCollectionEquality().hash(_items),
    layout,
    columns,
    showHeader,
    showNavigation,
    const DeepCollectionEquality().hash(_customProperties),
    createdAt,
    updatedAt,
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
    final String? description,
    final String? icon,
    final String? route,
    final List<ScreenItem> items,
    final String layout,
    final int columns,
    final bool showHeader,
    final bool showNavigation,
    final Map<String, dynamic>? customProperties,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ScreenConfigImpl;

  factory _ScreenConfig.fromJson(Map<String, dynamic> json) =
      _$ScreenConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get icon;
  @override
  String? get route;
  @override
  List<ScreenItem> get items;
  @override
  String get layout; // 'grid', 'list', 'tabs', 'custom'
  @override
  int get columns;
  @override
  bool get showHeader;
  @override
  bool get showNavigation;
  @override
  Map<String, dynamic>? get customProperties;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ScreenConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScreenConfigImplCopyWith<_$ScreenConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScreenItem _$ScreenItemFromJson(Map<String, dynamic> json) {
  return _ScreenItem.fromJson(json);
}

/// @nodoc
mixin _$ScreenItem {
  String get id => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'button', 'indicator', 'gauge', 'macro', 'custom'
  String get label => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  bool get visible => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  int? get position => throw _privateConstructorUsedError;
  int? get row => throw _privateConstructorUsedError;
  int? get column =>
      throw _privateConstructorUsedError; // Ação do item (para botões e macros)
  ScreenItemAction? get action =>
      throw _privateConstructorUsedError; // Configurações específicas por tipo
  Map<String, dynamic>? get properties =>
      throw _privateConstructorUsedError; // Configurações de layout
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  String? get backgroundColor => throw _privateConstructorUsedError;
  String? get textColor =>
      throw _privateConstructorUsedError; // Para botões de relé
  int? get relayBoardId => throw _privateConstructorUsedError;
  int? get relayChannelId => throw _privateConstructorUsedError;
  String? get functionType =>
      throw _privateConstructorUsedError; // Para indicadores
  String? get statusTopic => throw _privateConstructorUsedError;
  String? get statusField => throw _privateConstructorUsedError; // Para macros
  int? get macroId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ScreenItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScreenItemCopyWith<ScreenItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScreenItemCopyWith<$Res> {
  factory $ScreenItemCopyWith(
    ScreenItem value,
    $Res Function(ScreenItem) then,
  ) = _$ScreenItemCopyWithImpl<$Res, ScreenItem>;
  @useResult
  $Res call({
    String id,
    String type,
    String label,
    String? description,
    String? icon,
    bool visible,
    bool enabled,
    int? position,
    int? row,
    int? column,
    ScreenItemAction? action,
    Map<String, dynamic>? properties,
    int? width,
    int? height,
    String? backgroundColor,
    String? textColor,
    int? relayBoardId,
    int? relayChannelId,
    String? functionType,
    String? statusTopic,
    String? statusField,
    int? macroId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  $ScreenItemActionCopyWith<$Res>? get action;
}

/// @nodoc
class _$ScreenItemCopyWithImpl<$Res, $Val extends ScreenItem>
    implements $ScreenItemCopyWith<$Res> {
  _$ScreenItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? visible = null,
    Object? enabled = null,
    Object? position = freezed,
    Object? row = freezed,
    Object? column = freezed,
    Object? action = freezed,
    Object? properties = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? relayBoardId = freezed,
    Object? relayChannelId = freezed,
    Object? functionType = freezed,
    Object? statusTopic = freezed,
    Object? statusField = freezed,
    Object? macroId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as bool,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            position: freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int?,
            row: freezed == row
                ? _value.row
                : row // ignore: cast_nullable_to_non_nullable
                      as int?,
            column: freezed == column
                ? _value.column
                : column // ignore: cast_nullable_to_non_nullable
                      as int?,
            action: freezed == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as ScreenItemAction?,
            properties: freezed == properties
                ? _value.properties
                : properties // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            backgroundColor: freezed == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            textColor: freezed == textColor
                ? _value.textColor
                : textColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            relayBoardId: freezed == relayBoardId
                ? _value.relayBoardId
                : relayBoardId // ignore: cast_nullable_to_non_nullable
                      as int?,
            relayChannelId: freezed == relayChannelId
                ? _value.relayChannelId
                : relayChannelId // ignore: cast_nullable_to_non_nullable
                      as int?,
            functionType: freezed == functionType
                ? _value.functionType
                : functionType // ignore: cast_nullable_to_non_nullable
                      as String?,
            statusTopic: freezed == statusTopic
                ? _value.statusTopic
                : statusTopic // ignore: cast_nullable_to_non_nullable
                      as String?,
            statusField: freezed == statusField
                ? _value.statusField
                : statusField // ignore: cast_nullable_to_non_nullable
                      as String?,
            macroId: freezed == macroId
                ? _value.macroId
                : macroId // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of ScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScreenItemActionCopyWith<$Res>? get action {
    if (_value.action == null) {
      return null;
    }

    return $ScreenItemActionCopyWith<$Res>(_value.action!, (value) {
      return _then(_value.copyWith(action: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScreenItemImplCopyWith<$Res>
    implements $ScreenItemCopyWith<$Res> {
  factory _$$ScreenItemImplCopyWith(
    _$ScreenItemImpl value,
    $Res Function(_$ScreenItemImpl) then,
  ) = __$$ScreenItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String label,
    String? description,
    String? icon,
    bool visible,
    bool enabled,
    int? position,
    int? row,
    int? column,
    ScreenItemAction? action,
    Map<String, dynamic>? properties,
    int? width,
    int? height,
    String? backgroundColor,
    String? textColor,
    int? relayBoardId,
    int? relayChannelId,
    String? functionType,
    String? statusTopic,
    String? statusField,
    int? macroId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  $ScreenItemActionCopyWith<$Res>? get action;
}

/// @nodoc
class __$$ScreenItemImplCopyWithImpl<$Res>
    extends _$ScreenItemCopyWithImpl<$Res, _$ScreenItemImpl>
    implements _$$ScreenItemImplCopyWith<$Res> {
  __$$ScreenItemImplCopyWithImpl(
    _$ScreenItemImpl _value,
    $Res Function(_$ScreenItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? visible = null,
    Object? enabled = null,
    Object? position = freezed,
    Object? row = freezed,
    Object? column = freezed,
    Object? action = freezed,
    Object? properties = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? relayBoardId = freezed,
    Object? relayChannelId = freezed,
    Object? functionType = freezed,
    Object? statusTopic = freezed,
    Object? statusField = freezed,
    Object? macroId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ScreenItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        visible: null == visible
            ? _value.visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as bool,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        position: freezed == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int?,
        row: freezed == row
            ? _value.row
            : row // ignore: cast_nullable_to_non_nullable
                  as int?,
        column: freezed == column
            ? _value.column
            : column // ignore: cast_nullable_to_non_nullable
                  as int?,
        action: freezed == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as ScreenItemAction?,
        properties: freezed == properties
            ? _value._properties
            : properties // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        backgroundColor: freezed == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        textColor: freezed == textColor
            ? _value.textColor
            : textColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        relayBoardId: freezed == relayBoardId
            ? _value.relayBoardId
            : relayBoardId // ignore: cast_nullable_to_non_nullable
                  as int?,
        relayChannelId: freezed == relayChannelId
            ? _value.relayChannelId
            : relayChannelId // ignore: cast_nullable_to_non_nullable
                  as int?,
        functionType: freezed == functionType
            ? _value.functionType
            : functionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        statusTopic: freezed == statusTopic
            ? _value.statusTopic
            : statusTopic // ignore: cast_nullable_to_non_nullable
                  as String?,
        statusField: freezed == statusField
            ? _value.statusField
            : statusField // ignore: cast_nullable_to_non_nullable
                  as String?,
        macroId: freezed == macroId
            ? _value.macroId
            : macroId // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScreenItemImpl implements _ScreenItem {
  const _$ScreenItemImpl({
    required this.id,
    required this.type,
    required this.label,
    this.description,
    this.icon,
    this.visible = true,
    this.enabled = true,
    this.position,
    this.row,
    this.column,
    this.action,
    final Map<String, dynamic>? properties,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.relayBoardId,
    this.relayChannelId,
    this.functionType,
    this.statusTopic,
    this.statusField,
    this.macroId,
    this.createdAt,
    this.updatedAt,
  }) : _properties = properties;

  factory _$ScreenItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScreenItemImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  // 'button', 'indicator', 'gauge', 'macro', 'custom'
  @override
  final String label;
  @override
  final String? description;
  @override
  final String? icon;
  @override
  @JsonKey()
  final bool visible;
  @override
  @JsonKey()
  final bool enabled;
  @override
  final int? position;
  @override
  final int? row;
  @override
  final int? column;
  // Ação do item (para botões e macros)
  @override
  final ScreenItemAction? action;
  // Configurações específicas por tipo
  final Map<String, dynamic>? _properties;
  // Configurações específicas por tipo
  @override
  Map<String, dynamic>? get properties {
    final value = _properties;
    if (value == null) return null;
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Configurações de layout
  @override
  final int? width;
  @override
  final int? height;
  @override
  final String? backgroundColor;
  @override
  final String? textColor;
  // Para botões de relé
  @override
  final int? relayBoardId;
  @override
  final int? relayChannelId;
  @override
  final String? functionType;
  // Para indicadores
  @override
  final String? statusTopic;
  @override
  final String? statusField;
  // Para macros
  @override
  final int? macroId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ScreenItem(id: $id, type: $type, label: $label, description: $description, icon: $icon, visible: $visible, enabled: $enabled, position: $position, row: $row, column: $column, action: $action, properties: $properties, width: $width, height: $height, backgroundColor: $backgroundColor, textColor: $textColor, relayBoardId: $relayBoardId, relayChannelId: $relayChannelId, functionType: $functionType, statusTopic: $statusTopic, statusField: $statusField, macroId: $macroId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScreenItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.column, column) || other.column == column) &&
            (identical(other.action, action) || other.action == action) &&
            const DeepCollectionEquality().equals(
              other._properties,
              _properties,
            ) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.relayBoardId, relayBoardId) ||
                other.relayBoardId == relayBoardId) &&
            (identical(other.relayChannelId, relayChannelId) ||
                other.relayChannelId == relayChannelId) &&
            (identical(other.functionType, functionType) ||
                other.functionType == functionType) &&
            (identical(other.statusTopic, statusTopic) ||
                other.statusTopic == statusTopic) &&
            (identical(other.statusField, statusField) ||
                other.statusField == statusField) &&
            (identical(other.macroId, macroId) || other.macroId == macroId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    type,
    label,
    description,
    icon,
    visible,
    enabled,
    position,
    row,
    column,
    action,
    const DeepCollectionEquality().hash(_properties),
    width,
    height,
    backgroundColor,
    textColor,
    relayBoardId,
    relayChannelId,
    functionType,
    statusTopic,
    statusField,
    macroId,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of ScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScreenItemImplCopyWith<_$ScreenItemImpl> get copyWith =>
      __$$ScreenItemImplCopyWithImpl<_$ScreenItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScreenItemImplToJson(this);
  }
}

abstract class _ScreenItem implements ScreenItem {
  const factory _ScreenItem({
    required final String id,
    required final String type,
    required final String label,
    final String? description,
    final String? icon,
    final bool visible,
    final bool enabled,
    final int? position,
    final int? row,
    final int? column,
    final ScreenItemAction? action,
    final Map<String, dynamic>? properties,
    final int? width,
    final int? height,
    final String? backgroundColor,
    final String? textColor,
    final int? relayBoardId,
    final int? relayChannelId,
    final String? functionType,
    final String? statusTopic,
    final String? statusField,
    final int? macroId,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ScreenItemImpl;

  factory _ScreenItem.fromJson(Map<String, dynamic> json) =
      _$ScreenItemImpl.fromJson;

  @override
  String get id;
  @override
  String get type; // 'button', 'indicator', 'gauge', 'macro', 'custom'
  @override
  String get label;
  @override
  String? get description;
  @override
  String? get icon;
  @override
  bool get visible;
  @override
  bool get enabled;
  @override
  int? get position;
  @override
  int? get row;
  @override
  int? get column; // Ação do item (para botões e macros)
  @override
  ScreenItemAction? get action; // Configurações específicas por tipo
  @override
  Map<String, dynamic>? get properties; // Configurações de layout
  @override
  int? get width;
  @override
  int? get height;
  @override
  String? get backgroundColor;
  @override
  String? get textColor; // Para botões de relé
  @override
  int? get relayBoardId;
  @override
  int? get relayChannelId;
  @override
  String? get functionType; // Para indicadores
  @override
  String? get statusTopic;
  @override
  String? get statusField; // Para macros
  @override
  int? get macroId;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ScreenItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScreenItemImplCopyWith<_$ScreenItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScreenItemAction _$ScreenItemActionFromJson(Map<String, dynamic> json) {
  return _ScreenItemAction.fromJson(json);
}

/// @nodoc
mixin _$ScreenItemAction {
  String get type =>
      throw _privateConstructorUsedError; // 'execute_macro', 'relay_command', 'navigate', 'http_request', 'mqtt_publish'
  Map<String, dynamic>? get parameters =>
      throw _privateConstructorUsedError; // Para execute_macro
  int? get macroId => throw _privateConstructorUsedError; // Para relay_command
  int? get boardId => throw _privateConstructorUsedError;
  int? get channel => throw _privateConstructorUsedError;
  bool? get state => throw _privateConstructorUsedError;
  bool? get momentary => throw _privateConstructorUsedError; // Para navigate
  String? get route => throw _privateConstructorUsedError;
  Map<String, String>? get routeParams =>
      throw _privateConstructorUsedError; // Para http_request
  String? get url => throw _privateConstructorUsedError;
  String? get method => throw _privateConstructorUsedError;
  Map<String, dynamic>? get body => throw _privateConstructorUsedError;
  Map<String, String>? get headers =>
      throw _privateConstructorUsedError; // Para mqtt_publish
  String? get topic => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;
  bool? get retain => throw _privateConstructorUsedError;
  int? get qos => throw _privateConstructorUsedError;

  /// Serializes this ScreenItemAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScreenItemAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScreenItemActionCopyWith<ScreenItemAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScreenItemActionCopyWith<$Res> {
  factory $ScreenItemActionCopyWith(
    ScreenItemAction value,
    $Res Function(ScreenItemAction) then,
  ) = _$ScreenItemActionCopyWithImpl<$Res, ScreenItemAction>;
  @useResult
  $Res call({
    String type,
    Map<String, dynamic>? parameters,
    int? macroId,
    int? boardId,
    int? channel,
    bool? state,
    bool? momentary,
    String? route,
    Map<String, String>? routeParams,
    String? url,
    String? method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? topic,
    Map<String, dynamic>? payload,
    bool? retain,
    int? qos,
  });
}

/// @nodoc
class _$ScreenItemActionCopyWithImpl<$Res, $Val extends ScreenItemAction>
    implements $ScreenItemActionCopyWith<$Res> {
  _$ScreenItemActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScreenItemAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? parameters = freezed,
    Object? macroId = freezed,
    Object? boardId = freezed,
    Object? channel = freezed,
    Object? state = freezed,
    Object? momentary = freezed,
    Object? route = freezed,
    Object? routeParams = freezed,
    Object? url = freezed,
    Object? method = freezed,
    Object? body = freezed,
    Object? headers = freezed,
    Object? topic = freezed,
    Object? payload = freezed,
    Object? retain = freezed,
    Object? qos = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            parameters: freezed == parameters
                ? _value.parameters
                : parameters // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            macroId: freezed == macroId
                ? _value.macroId
                : macroId // ignore: cast_nullable_to_non_nullable
                      as int?,
            boardId: freezed == boardId
                ? _value.boardId
                : boardId // ignore: cast_nullable_to_non_nullable
                      as int?,
            channel: freezed == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as int?,
            state: freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as bool?,
            momentary: freezed == momentary
                ? _value.momentary
                : momentary // ignore: cast_nullable_to_non_nullable
                      as bool?,
            route: freezed == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as String?,
            routeParams: freezed == routeParams
                ? _value.routeParams
                : routeParams // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            method: freezed == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String?,
            body: freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            headers: freezed == headers
                ? _value.headers
                : headers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            topic: freezed == topic
                ? _value.topic
                : topic // ignore: cast_nullable_to_non_nullable
                      as String?,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            retain: freezed == retain
                ? _value.retain
                : retain // ignore: cast_nullable_to_non_nullable
                      as bool?,
            qos: freezed == qos
                ? _value.qos
                : qos // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScreenItemActionImplCopyWith<$Res>
    implements $ScreenItemActionCopyWith<$Res> {
  factory _$$ScreenItemActionImplCopyWith(
    _$ScreenItemActionImpl value,
    $Res Function(_$ScreenItemActionImpl) then,
  ) = __$$ScreenItemActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    Map<String, dynamic>? parameters,
    int? macroId,
    int? boardId,
    int? channel,
    bool? state,
    bool? momentary,
    String? route,
    Map<String, String>? routeParams,
    String? url,
    String? method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? topic,
    Map<String, dynamic>? payload,
    bool? retain,
    int? qos,
  });
}

/// @nodoc
class __$$ScreenItemActionImplCopyWithImpl<$Res>
    extends _$ScreenItemActionCopyWithImpl<$Res, _$ScreenItemActionImpl>
    implements _$$ScreenItemActionImplCopyWith<$Res> {
  __$$ScreenItemActionImplCopyWithImpl(
    _$ScreenItemActionImpl _value,
    $Res Function(_$ScreenItemActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScreenItemAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? parameters = freezed,
    Object? macroId = freezed,
    Object? boardId = freezed,
    Object? channel = freezed,
    Object? state = freezed,
    Object? momentary = freezed,
    Object? route = freezed,
    Object? routeParams = freezed,
    Object? url = freezed,
    Object? method = freezed,
    Object? body = freezed,
    Object? headers = freezed,
    Object? topic = freezed,
    Object? payload = freezed,
    Object? retain = freezed,
    Object? qos = freezed,
  }) {
    return _then(
      _$ScreenItemActionImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        parameters: freezed == parameters
            ? _value._parameters
            : parameters // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        macroId: freezed == macroId
            ? _value.macroId
            : macroId // ignore: cast_nullable_to_non_nullable
                  as int?,
        boardId: freezed == boardId
            ? _value.boardId
            : boardId // ignore: cast_nullable_to_non_nullable
                  as int?,
        channel: freezed == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as int?,
        state: freezed == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as bool?,
        momentary: freezed == momentary
            ? _value.momentary
            : momentary // ignore: cast_nullable_to_non_nullable
                  as bool?,
        route: freezed == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as String?,
        routeParams: freezed == routeParams
            ? _value._routeParams
            : routeParams // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        method: freezed == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String?,
        body: freezed == body
            ? _value._body
            : body // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        headers: freezed == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        topic: freezed == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as String?,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        retain: freezed == retain
            ? _value.retain
            : retain // ignore: cast_nullable_to_non_nullable
                  as bool?,
        qos: freezed == qos
            ? _value.qos
            : qos // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScreenItemActionImpl implements _ScreenItemAction {
  const _$ScreenItemActionImpl({
    required this.type,
    final Map<String, dynamic>? parameters,
    this.macroId,
    this.boardId,
    this.channel,
    this.state,
    this.momentary,
    this.route,
    final Map<String, String>? routeParams,
    this.url,
    this.method,
    final Map<String, dynamic>? body,
    final Map<String, String>? headers,
    this.topic,
    final Map<String, dynamic>? payload,
    this.retain,
    this.qos,
  }) : _parameters = parameters,
       _routeParams = routeParams,
       _body = body,
       _headers = headers,
       _payload = payload;

  factory _$ScreenItemActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScreenItemActionImplFromJson(json);

  @override
  final String type;
  // 'execute_macro', 'relay_command', 'navigate', 'http_request', 'mqtt_publish'
  final Map<String, dynamic>? _parameters;
  // 'execute_macro', 'relay_command', 'navigate', 'http_request', 'mqtt_publish'
  @override
  Map<String, dynamic>? get parameters {
    final value = _parameters;
    if (value == null) return null;
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Para execute_macro
  @override
  final int? macroId;
  // Para relay_command
  @override
  final int? boardId;
  @override
  final int? channel;
  @override
  final bool? state;
  @override
  final bool? momentary;
  // Para navigate
  @override
  final String? route;
  final Map<String, String>? _routeParams;
  @override
  Map<String, String>? get routeParams {
    final value = _routeParams;
    if (value == null) return null;
    if (_routeParams is EqualUnmodifiableMapView) return _routeParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Para http_request
  @override
  final String? url;
  @override
  final String? method;
  final Map<String, dynamic>? _body;
  @override
  Map<String, dynamic>? get body {
    final value = _body;
    if (value == null) return null;
    if (_body is EqualUnmodifiableMapView) return _body;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Para mqtt_publish
  @override
  final String? topic;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? retain;
  @override
  final int? qos;

  @override
  String toString() {
    return 'ScreenItemAction(type: $type, parameters: $parameters, macroId: $macroId, boardId: $boardId, channel: $channel, state: $state, momentary: $momentary, route: $route, routeParams: $routeParams, url: $url, method: $method, body: $body, headers: $headers, topic: $topic, payload: $payload, retain: $retain, qos: $qos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScreenItemActionImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(
              other._parameters,
              _parameters,
            ) &&
            (identical(other.macroId, macroId) || other.macroId == macroId) &&
            (identical(other.boardId, boardId) || other.boardId == boardId) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.momentary, momentary) ||
                other.momentary == momentary) &&
            (identical(other.route, route) || other.route == route) &&
            const DeepCollectionEquality().equals(
              other._routeParams,
              _routeParams,
            ) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other._body, _body) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.retain, retain) || other.retain == retain) &&
            (identical(other.qos, qos) || other.qos == qos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    const DeepCollectionEquality().hash(_parameters),
    macroId,
    boardId,
    channel,
    state,
    momentary,
    route,
    const DeepCollectionEquality().hash(_routeParams),
    url,
    method,
    const DeepCollectionEquality().hash(_body),
    const DeepCollectionEquality().hash(_headers),
    topic,
    const DeepCollectionEquality().hash(_payload),
    retain,
    qos,
  );

  /// Create a copy of ScreenItemAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScreenItemActionImplCopyWith<_$ScreenItemActionImpl> get copyWith =>
      __$$ScreenItemActionImplCopyWithImpl<_$ScreenItemActionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScreenItemActionImplToJson(this);
  }
}

abstract class _ScreenItemAction implements ScreenItemAction {
  const factory _ScreenItemAction({
    required final String type,
    final Map<String, dynamic>? parameters,
    final int? macroId,
    final int? boardId,
    final int? channel,
    final bool? state,
    final bool? momentary,
    final String? route,
    final Map<String, String>? routeParams,
    final String? url,
    final String? method,
    final Map<String, dynamic>? body,
    final Map<String, String>? headers,
    final String? topic,
    final Map<String, dynamic>? payload,
    final bool? retain,
    final int? qos,
  }) = _$ScreenItemActionImpl;

  factory _ScreenItemAction.fromJson(Map<String, dynamic> json) =
      _$ScreenItemActionImpl.fromJson;

  @override
  String get type; // 'execute_macro', 'relay_command', 'navigate', 'http_request', 'mqtt_publish'
  @override
  Map<String, dynamic>? get parameters; // Para execute_macro
  @override
  int? get macroId; // Para relay_command
  @override
  int? get boardId;
  @override
  int? get channel;
  @override
  bool? get state;
  @override
  bool? get momentary; // Para navigate
  @override
  String? get route;
  @override
  Map<String, String>? get routeParams; // Para http_request
  @override
  String? get url;
  @override
  String? get method;
  @override
  Map<String, dynamic>? get body;
  @override
  Map<String, String>? get headers; // Para mqtt_publish
  @override
  String? get topic;
  @override
  Map<String, dynamic>? get payload;
  @override
  bool? get retain;
  @override
  int? get qos;

  /// Create a copy of ScreenItemAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScreenItemActionImplCopyWith<_$ScreenItemActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppScreensConfig _$AppScreensConfigFromJson(Map<String, dynamic> json) {
  return _AppScreensConfig.fromJson(json);
}

/// @nodoc
mixin _$AppScreensConfig {
  String get version => throw _privateConstructorUsedError;
  List<ScreenConfig> get screens => throw _privateConstructorUsedError;
  String get defaultScreen => throw _privateConstructorUsedError;
  Map<String, dynamic> get globalSettings => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  String? get configSource => throw _privateConstructorUsedError;

  /// Serializes this AppScreensConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppScreensConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppScreensConfigCopyWith<AppScreensConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppScreensConfigCopyWith<$Res> {
  factory $AppScreensConfigCopyWith(
    AppScreensConfig value,
    $Res Function(AppScreensConfig) then,
  ) = _$AppScreensConfigCopyWithImpl<$Res, AppScreensConfig>;
  @useResult
  $Res call({
    String version,
    List<ScreenConfig> screens,
    String defaultScreen,
    Map<String, dynamic> globalSettings,
    DateTime? lastUpdated,
    String? configSource,
  });
}

/// @nodoc
class _$AppScreensConfigCopyWithImpl<$Res, $Val extends AppScreensConfig>
    implements $AppScreensConfigCopyWith<$Res> {
  _$AppScreensConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppScreensConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? screens = null,
    Object? defaultScreen = null,
    Object? globalSettings = null,
    Object? lastUpdated = freezed,
    Object? configSource = freezed,
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
            defaultScreen: null == defaultScreen
                ? _value.defaultScreen
                : defaultScreen // ignore: cast_nullable_to_non_nullable
                      as String,
            globalSettings: null == globalSettings
                ? _value.globalSettings
                : globalSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            configSource: freezed == configSource
                ? _value.configSource
                : configSource // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppScreensConfigImplCopyWith<$Res>
    implements $AppScreensConfigCopyWith<$Res> {
  factory _$$AppScreensConfigImplCopyWith(
    _$AppScreensConfigImpl value,
    $Res Function(_$AppScreensConfigImpl) then,
  ) = __$$AppScreensConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String version,
    List<ScreenConfig> screens,
    String defaultScreen,
    Map<String, dynamic> globalSettings,
    DateTime? lastUpdated,
    String? configSource,
  });
}

/// @nodoc
class __$$AppScreensConfigImplCopyWithImpl<$Res>
    extends _$AppScreensConfigCopyWithImpl<$Res, _$AppScreensConfigImpl>
    implements _$$AppScreensConfigImplCopyWith<$Res> {
  __$$AppScreensConfigImplCopyWithImpl(
    _$AppScreensConfigImpl _value,
    $Res Function(_$AppScreensConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppScreensConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? screens = null,
    Object? defaultScreen = null,
    Object? globalSettings = null,
    Object? lastUpdated = freezed,
    Object? configSource = freezed,
  }) {
    return _then(
      _$AppScreensConfigImpl(
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        screens: null == screens
            ? _value._screens
            : screens // ignore: cast_nullable_to_non_nullable
                  as List<ScreenConfig>,
        defaultScreen: null == defaultScreen
            ? _value.defaultScreen
            : defaultScreen // ignore: cast_nullable_to_non_nullable
                  as String,
        globalSettings: null == globalSettings
            ? _value._globalSettings
            : globalSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        configSource: freezed == configSource
            ? _value.configSource
            : configSource // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppScreensConfigImpl extends _AppScreensConfig {
  const _$AppScreensConfigImpl({
    this.version = '1.0.0',
    final List<ScreenConfig> screens = const [],
    this.defaultScreen = 'dashboard',
    final Map<String, dynamic> globalSettings = const {},
    this.lastUpdated,
    this.configSource,
  }) : _screens = screens,
       _globalSettings = globalSettings,
       super._();

  factory _$AppScreensConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppScreensConfigImplFromJson(json);

  @override
  @JsonKey()
  final String version;
  final List<ScreenConfig> _screens;
  @override
  @JsonKey()
  List<ScreenConfig> get screens {
    if (_screens is EqualUnmodifiableListView) return _screens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_screens);
  }

  @override
  @JsonKey()
  final String defaultScreen;
  final Map<String, dynamic> _globalSettings;
  @override
  @JsonKey()
  Map<String, dynamic> get globalSettings {
    if (_globalSettings is EqualUnmodifiableMapView) return _globalSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_globalSettings);
  }

  @override
  final DateTime? lastUpdated;
  @override
  final String? configSource;

  @override
  String toString() {
    return 'AppScreensConfig(version: $version, screens: $screens, defaultScreen: $defaultScreen, globalSettings: $globalSettings, lastUpdated: $lastUpdated, configSource: $configSource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppScreensConfigImpl &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality().equals(other._screens, _screens) &&
            (identical(other.defaultScreen, defaultScreen) ||
                other.defaultScreen == defaultScreen) &&
            const DeepCollectionEquality().equals(
              other._globalSettings,
              _globalSettings,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.configSource, configSource) ||
                other.configSource == configSource));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    const DeepCollectionEquality().hash(_screens),
    defaultScreen,
    const DeepCollectionEquality().hash(_globalSettings),
    lastUpdated,
    configSource,
  );

  /// Create a copy of AppScreensConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppScreensConfigImplCopyWith<_$AppScreensConfigImpl> get copyWith =>
      __$$AppScreensConfigImplCopyWithImpl<_$AppScreensConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppScreensConfigImplToJson(this);
  }
}

abstract class _AppScreensConfig extends AppScreensConfig {
  const factory _AppScreensConfig({
    final String version,
    final List<ScreenConfig> screens,
    final String defaultScreen,
    final Map<String, dynamic> globalSettings,
    final DateTime? lastUpdated,
    final String? configSource,
  }) = _$AppScreensConfigImpl;
  const _AppScreensConfig._() : super._();

  factory _AppScreensConfig.fromJson(Map<String, dynamic> json) =
      _$AppScreensConfigImpl.fromJson;

  @override
  String get version;
  @override
  List<ScreenConfig> get screens;
  @override
  String get defaultScreen;
  @override
  Map<String, dynamic> get globalSettings;
  @override
  DateTime? get lastUpdated;
  @override
  String? get configSource;

  /// Create a copy of AppScreensConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppScreensConfigImplCopyWith<_$AppScreensConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
