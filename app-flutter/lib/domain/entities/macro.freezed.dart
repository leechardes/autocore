// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'macro.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Macro _$MacroFromJson(Map<String, dynamic> json) {
  return _Macro.fromJson(json);
}

/// @nodoc
mixin _$Macro {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  MacroTriggerType get triggerType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get triggerConfig => throw _privateConstructorUsedError;
  List<MacroAction> get actions => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastExecutedAt => throw _privateConstructorUsedError;
  int? get executionCount => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  bool get isSystem => throw _privateConstructorUsedError;
  bool get showInUi => throw _privateConstructorUsedError;

  /// Serializes this Macro to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Macro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MacroCopyWith<Macro> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroCopyWith<$Res> {
  factory $MacroCopyWith(Macro value, $Res Function(Macro) then) =
      _$MacroCopyWithImpl<$Res, Macro>;
  @useResult
  $Res call({
    int id,
    String name,
    String? description,
    String? icon,
    bool enabled,
    MacroTriggerType triggerType,
    Map<String, dynamic>? triggerConfig,
    List<MacroAction> actions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastExecutedAt,
    int? executionCount,
    String? category,
    List<String>? tags,
    bool isSystem,
    bool showInUi,
  });
}

/// @nodoc
class _$MacroCopyWithImpl<$Res, $Val extends Macro>
    implements $MacroCopyWith<$Res> {
  _$MacroCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Macro
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? enabled = null,
    Object? triggerType = null,
    Object? triggerConfig = freezed,
    Object? actions = null,
    Object? metadata = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastExecutedAt = freezed,
    Object? executionCount = freezed,
    Object? category = freezed,
    Object? tags = freezed,
    Object? isSystem = null,
    Object? showInUi = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
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
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            triggerType: null == triggerType
                ? _value.triggerType
                : triggerType // ignore: cast_nullable_to_non_nullable
                      as MacroTriggerType,
            triggerConfig: freezed == triggerConfig
                ? _value.triggerConfig
                : triggerConfig // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            actions: null == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<MacroAction>,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastExecutedAt: freezed == lastExecutedAt
                ? _value.lastExecutedAt
                : lastExecutedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            executionCount: freezed == executionCount
                ? _value.executionCount
                : executionCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            isSystem: null == isSystem
                ? _value.isSystem
                : isSystem // ignore: cast_nullable_to_non_nullable
                      as bool,
            showInUi: null == showInUi
                ? _value.showInUi
                : showInUi // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MacroImplCopyWith<$Res> implements $MacroCopyWith<$Res> {
  factory _$$MacroImplCopyWith(
    _$MacroImpl value,
    $Res Function(_$MacroImpl) then,
  ) = __$$MacroImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String? description,
    String? icon,
    bool enabled,
    MacroTriggerType triggerType,
    Map<String, dynamic>? triggerConfig,
    List<MacroAction> actions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastExecutedAt,
    int? executionCount,
    String? category,
    List<String>? tags,
    bool isSystem,
    bool showInUi,
  });
}

/// @nodoc
class __$$MacroImplCopyWithImpl<$Res>
    extends _$MacroCopyWithImpl<$Res, _$MacroImpl>
    implements _$$MacroImplCopyWith<$Res> {
  __$$MacroImplCopyWithImpl(
    _$MacroImpl _value,
    $Res Function(_$MacroImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Macro
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? enabled = null,
    Object? triggerType = null,
    Object? triggerConfig = freezed,
    Object? actions = null,
    Object? metadata = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastExecutedAt = freezed,
    Object? executionCount = freezed,
    Object? category = freezed,
    Object? tags = freezed,
    Object? isSystem = null,
    Object? showInUi = null,
  }) {
    return _then(
      _$MacroImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
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
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        triggerType: null == triggerType
            ? _value.triggerType
            : triggerType // ignore: cast_nullable_to_non_nullable
                  as MacroTriggerType,
        triggerConfig: freezed == triggerConfig
            ? _value._triggerConfig
            : triggerConfig // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        actions: null == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<MacroAction>,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastExecutedAt: freezed == lastExecutedAt
            ? _value.lastExecutedAt
            : lastExecutedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        executionCount: freezed == executionCount
            ? _value.executionCount
            : executionCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        isSystem: null == isSystem
            ? _value.isSystem
            : isSystem // ignore: cast_nullable_to_non_nullable
                  as bool,
        showInUi: null == showInUi
            ? _value.showInUi
            : showInUi // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MacroImpl implements _Macro {
  const _$MacroImpl({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.enabled,
    required this.triggerType,
    final Map<String, dynamic>? triggerConfig,
    required final List<MacroAction> actions,
    final Map<String, dynamic>? metadata,
    this.createdAt,
    this.updatedAt,
    this.lastExecutedAt,
    this.executionCount,
    this.category,
    final List<String>? tags,
    this.isSystem = false,
    this.showInUi = true,
  }) : _triggerConfig = triggerConfig,
       _actions = actions,
       _metadata = metadata,
       _tags = tags;

  factory _$MacroImpl.fromJson(Map<String, dynamic> json) =>
      _$$MacroImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? icon;
  @override
  final bool enabled;
  @override
  final MacroTriggerType triggerType;
  final Map<String, dynamic>? _triggerConfig;
  @override
  Map<String, dynamic>? get triggerConfig {
    final value = _triggerConfig;
    if (value == null) return null;
    if (_triggerConfig is EqualUnmodifiableMapView) return _triggerConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<MacroAction> _actions;
  @override
  List<MacroAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
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
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? lastExecutedAt;
  @override
  final int? executionCount;
  @override
  final String? category;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isSystem;
  @override
  @JsonKey()
  final bool showInUi;

  @override
  String toString() {
    return 'Macro(id: $id, name: $name, description: $description, icon: $icon, enabled: $enabled, triggerType: $triggerType, triggerConfig: $triggerConfig, actions: $actions, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, lastExecutedAt: $lastExecutedAt, executionCount: $executionCount, category: $category, tags: $tags, isSystem: $isSystem, showInUi: $showInUi)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.triggerType, triggerType) ||
                other.triggerType == triggerType) &&
            const DeepCollectionEquality().equals(
              other._triggerConfig,
              _triggerConfig,
            ) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastExecutedAt, lastExecutedAt) ||
                other.lastExecutedAt == lastExecutedAt) &&
            (identical(other.executionCount, executionCount) ||
                other.executionCount == executionCount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isSystem, isSystem) ||
                other.isSystem == isSystem) &&
            (identical(other.showInUi, showInUi) ||
                other.showInUi == showInUi));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    icon,
    enabled,
    triggerType,
    const DeepCollectionEquality().hash(_triggerConfig),
    const DeepCollectionEquality().hash(_actions),
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
    updatedAt,
    lastExecutedAt,
    executionCount,
    category,
    const DeepCollectionEquality().hash(_tags),
    isSystem,
    showInUi,
  );

  /// Create a copy of Macro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroImplCopyWith<_$MacroImpl> get copyWith =>
      __$$MacroImplCopyWithImpl<_$MacroImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MacroImplToJson(this);
  }
}

abstract class _Macro implements Macro {
  const factory _Macro({
    required final int id,
    required final String name,
    final String? description,
    final String? icon,
    required final bool enabled,
    required final MacroTriggerType triggerType,
    final Map<String, dynamic>? triggerConfig,
    required final List<MacroAction> actions,
    final Map<String, dynamic>? metadata,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final DateTime? lastExecutedAt,
    final int? executionCount,
    final String? category,
    final List<String>? tags,
    final bool isSystem,
    final bool showInUi,
  }) = _$MacroImpl;

  factory _Macro.fromJson(Map<String, dynamic> json) = _$MacroImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get icon;
  @override
  bool get enabled;
  @override
  MacroTriggerType get triggerType;
  @override
  Map<String, dynamic>? get triggerConfig;
  @override
  List<MacroAction> get actions;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get lastExecutedAt;
  @override
  int? get executionCount;
  @override
  String? get category;
  @override
  List<String>? get tags;
  @override
  bool get isSystem;
  @override
  bool get showInUi;

  /// Create a copy of Macro
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MacroImplCopyWith<_$MacroImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MacroAction _$MacroActionFromJson(Map<String, dynamic> json) {
  return _MacroAction.fromJson(json);
}

/// @nodoc
mixin _$MacroAction {
  String get id => throw _privateConstructorUsedError;
  MacroActionType get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get config => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  int? get delayMs => throw _privateConstructorUsedError;
  MacroCondition? get condition => throw _privateConstructorUsedError;
  List<MacroAction>? get thenActions => throw _privateConstructorUsedError;
  List<MacroAction>? get elseActions => throw _privateConstructorUsedError;

  /// Serializes this MacroAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MacroAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MacroActionCopyWith<MacroAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroActionCopyWith<$Res> {
  factory $MacroActionCopyWith(
    MacroAction value,
    $Res Function(MacroAction) then,
  ) = _$MacroActionCopyWithImpl<$Res, MacroAction>;
  @useResult
  $Res call({
    String id,
    MacroActionType type,
    Map<String, dynamic> config,
    String? description,
    bool enabled,
    int? delayMs,
    MacroCondition? condition,
    List<MacroAction>? thenActions,
    List<MacroAction>? elseActions,
  });

  $MacroConditionCopyWith<$Res>? get condition;
}

/// @nodoc
class _$MacroActionCopyWithImpl<$Res, $Val extends MacroAction>
    implements $MacroActionCopyWith<$Res> {
  _$MacroActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MacroAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? config = null,
    Object? description = freezed,
    Object? enabled = null,
    Object? delayMs = freezed,
    Object? condition = freezed,
    Object? thenActions = freezed,
    Object? elseActions = freezed,
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
                      as MacroActionType,
            config: null == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            delayMs: freezed == delayMs
                ? _value.delayMs
                : delayMs // ignore: cast_nullable_to_non_nullable
                      as int?,
            condition: freezed == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as MacroCondition?,
            thenActions: freezed == thenActions
                ? _value.thenActions
                : thenActions // ignore: cast_nullable_to_non_nullable
                      as List<MacroAction>?,
            elseActions: freezed == elseActions
                ? _value.elseActions
                : elseActions // ignore: cast_nullable_to_non_nullable
                      as List<MacroAction>?,
          )
          as $Val,
    );
  }

  /// Create a copy of MacroAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MacroConditionCopyWith<$Res>? get condition {
    if (_value.condition == null) {
      return null;
    }

    return $MacroConditionCopyWith<$Res>(_value.condition!, (value) {
      return _then(_value.copyWith(condition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MacroActionImplCopyWith<$Res>
    implements $MacroActionCopyWith<$Res> {
  factory _$$MacroActionImplCopyWith(
    _$MacroActionImpl value,
    $Res Function(_$MacroActionImpl) then,
  ) = __$$MacroActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    MacroActionType type,
    Map<String, dynamic> config,
    String? description,
    bool enabled,
    int? delayMs,
    MacroCondition? condition,
    List<MacroAction>? thenActions,
    List<MacroAction>? elseActions,
  });

  @override
  $MacroConditionCopyWith<$Res>? get condition;
}

/// @nodoc
class __$$MacroActionImplCopyWithImpl<$Res>
    extends _$MacroActionCopyWithImpl<$Res, _$MacroActionImpl>
    implements _$$MacroActionImplCopyWith<$Res> {
  __$$MacroActionImplCopyWithImpl(
    _$MacroActionImpl _value,
    $Res Function(_$MacroActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MacroAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? config = null,
    Object? description = freezed,
    Object? enabled = null,
    Object? delayMs = freezed,
    Object? condition = freezed,
    Object? thenActions = freezed,
    Object? elseActions = freezed,
  }) {
    return _then(
      _$MacroActionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MacroActionType,
        config: null == config
            ? _value._config
            : config // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        delayMs: freezed == delayMs
            ? _value.delayMs
            : delayMs // ignore: cast_nullable_to_non_nullable
                  as int?,
        condition: freezed == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as MacroCondition?,
        thenActions: freezed == thenActions
            ? _value._thenActions
            : thenActions // ignore: cast_nullable_to_non_nullable
                  as List<MacroAction>?,
        elseActions: freezed == elseActions
            ? _value._elseActions
            : elseActions // ignore: cast_nullable_to_non_nullable
                  as List<MacroAction>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MacroActionImpl implements _MacroAction {
  const _$MacroActionImpl({
    required this.id,
    required this.type,
    required final Map<String, dynamic> config,
    this.description,
    this.enabled = true,
    this.delayMs,
    this.condition,
    final List<MacroAction>? thenActions,
    final List<MacroAction>? elseActions,
  }) : _config = config,
       _thenActions = thenActions,
       _elseActions = elseActions;

  factory _$MacroActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MacroActionImplFromJson(json);

  @override
  final String id;
  @override
  final MacroActionType type;
  final Map<String, dynamic> _config;
  @override
  Map<String, dynamic> get config {
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_config);
  }

  @override
  final String? description;
  @override
  @JsonKey()
  final bool enabled;
  @override
  final int? delayMs;
  @override
  final MacroCondition? condition;
  final List<MacroAction>? _thenActions;
  @override
  List<MacroAction>? get thenActions {
    final value = _thenActions;
    if (value == null) return null;
    if (_thenActions is EqualUnmodifiableListView) return _thenActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<MacroAction>? _elseActions;
  @override
  List<MacroAction>? get elseActions {
    final value = _elseActions;
    if (value == null) return null;
    if (_elseActions is EqualUnmodifiableListView) return _elseActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MacroAction(id: $id, type: $type, config: $config, description: $description, enabled: $enabled, delayMs: $delayMs, condition: $condition, thenActions: $thenActions, elseActions: $elseActions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.delayMs, delayMs) || other.delayMs == delayMs) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            const DeepCollectionEquality().equals(
              other._thenActions,
              _thenActions,
            ) &&
            const DeepCollectionEquality().equals(
              other._elseActions,
              _elseActions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    const DeepCollectionEquality().hash(_config),
    description,
    enabled,
    delayMs,
    condition,
    const DeepCollectionEquality().hash(_thenActions),
    const DeepCollectionEquality().hash(_elseActions),
  );

  /// Create a copy of MacroAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroActionImplCopyWith<_$MacroActionImpl> get copyWith =>
      __$$MacroActionImplCopyWithImpl<_$MacroActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MacroActionImplToJson(this);
  }
}

abstract class _MacroAction implements MacroAction {
  const factory _MacroAction({
    required final String id,
    required final MacroActionType type,
    required final Map<String, dynamic> config,
    final String? description,
    final bool enabled,
    final int? delayMs,
    final MacroCondition? condition,
    final List<MacroAction>? thenActions,
    final List<MacroAction>? elseActions,
  }) = _$MacroActionImpl;

  factory _MacroAction.fromJson(Map<String, dynamic> json) =
      _$MacroActionImpl.fromJson;

  @override
  String get id;
  @override
  MacroActionType get type;
  @override
  Map<String, dynamic> get config;
  @override
  String? get description;
  @override
  bool get enabled;
  @override
  int? get delayMs;
  @override
  MacroCondition? get condition;
  @override
  List<MacroAction>? get thenActions;
  @override
  List<MacroAction>? get elseActions;

  /// Create a copy of MacroAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MacroActionImplCopyWith<_$MacroActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MacroCondition _$MacroConditionFromJson(Map<String, dynamic> json) {
  return _MacroCondition.fromJson(json);
}

/// @nodoc
mixin _$MacroCondition {
  String get type => throw _privateConstructorUsedError;
  String get field => throw _privateConstructorUsedError;
  String get operator => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;
  List<MacroCondition>? get andConditions => throw _privateConstructorUsedError;
  List<MacroCondition>? get orConditions => throw _privateConstructorUsedError;

  /// Serializes this MacroCondition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MacroCondition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MacroConditionCopyWith<MacroCondition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroConditionCopyWith<$Res> {
  factory $MacroConditionCopyWith(
    MacroCondition value,
    $Res Function(MacroCondition) then,
  ) = _$MacroConditionCopyWithImpl<$Res, MacroCondition>;
  @useResult
  $Res call({
    String type,
    String field,
    String operator,
    dynamic value,
    List<MacroCondition>? andConditions,
    List<MacroCondition>? orConditions,
  });
}

/// @nodoc
class _$MacroConditionCopyWithImpl<$Res, $Val extends MacroCondition>
    implements $MacroConditionCopyWith<$Res> {
  _$MacroConditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MacroCondition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? field = null,
    Object? operator = null,
    Object? value = freezed,
    Object? andConditions = freezed,
    Object? orConditions = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            field: null == field
                ? _value.field
                : field // ignore: cast_nullable_to_non_nullable
                      as String,
            operator: null == operator
                ? _value.operator
                : operator // ignore: cast_nullable_to_non_nullable
                      as String,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            andConditions: freezed == andConditions
                ? _value.andConditions
                : andConditions // ignore: cast_nullable_to_non_nullable
                      as List<MacroCondition>?,
            orConditions: freezed == orConditions
                ? _value.orConditions
                : orConditions // ignore: cast_nullable_to_non_nullable
                      as List<MacroCondition>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MacroConditionImplCopyWith<$Res>
    implements $MacroConditionCopyWith<$Res> {
  factory _$$MacroConditionImplCopyWith(
    _$MacroConditionImpl value,
    $Res Function(_$MacroConditionImpl) then,
  ) = __$$MacroConditionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String field,
    String operator,
    dynamic value,
    List<MacroCondition>? andConditions,
    List<MacroCondition>? orConditions,
  });
}

/// @nodoc
class __$$MacroConditionImplCopyWithImpl<$Res>
    extends _$MacroConditionCopyWithImpl<$Res, _$MacroConditionImpl>
    implements _$$MacroConditionImplCopyWith<$Res> {
  __$$MacroConditionImplCopyWithImpl(
    _$MacroConditionImpl _value,
    $Res Function(_$MacroConditionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MacroCondition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? field = null,
    Object? operator = null,
    Object? value = freezed,
    Object? andConditions = freezed,
    Object? orConditions = freezed,
  }) {
    return _then(
      _$MacroConditionImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        field: null == field
            ? _value.field
            : field // ignore: cast_nullable_to_non_nullable
                  as String,
        operator: null == operator
            ? _value.operator
            : operator // ignore: cast_nullable_to_non_nullable
                  as String,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        andConditions: freezed == andConditions
            ? _value._andConditions
            : andConditions // ignore: cast_nullable_to_non_nullable
                  as List<MacroCondition>?,
        orConditions: freezed == orConditions
            ? _value._orConditions
            : orConditions // ignore: cast_nullable_to_non_nullable
                  as List<MacroCondition>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MacroConditionImpl implements _MacroCondition {
  const _$MacroConditionImpl({
    required this.type,
    required this.field,
    required this.operator,
    this.value,
    final List<MacroCondition>? andConditions,
    final List<MacroCondition>? orConditions,
  }) : _andConditions = andConditions,
       _orConditions = orConditions;

  factory _$MacroConditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MacroConditionImplFromJson(json);

  @override
  final String type;
  @override
  final String field;
  @override
  final String operator;
  @override
  final dynamic value;
  final List<MacroCondition>? _andConditions;
  @override
  List<MacroCondition>? get andConditions {
    final value = _andConditions;
    if (value == null) return null;
    if (_andConditions is EqualUnmodifiableListView) return _andConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<MacroCondition>? _orConditions;
  @override
  List<MacroCondition>? get orConditions {
    final value = _orConditions;
    if (value == null) return null;
    if (_orConditions is EqualUnmodifiableListView) return _orConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MacroCondition(type: $type, field: $field, operator: $operator, value: $value, andConditions: $andConditions, orConditions: $orConditions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroConditionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.operator, operator) ||
                other.operator == operator) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            const DeepCollectionEquality().equals(
              other._andConditions,
              _andConditions,
            ) &&
            const DeepCollectionEquality().equals(
              other._orConditions,
              _orConditions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    field,
    operator,
    const DeepCollectionEquality().hash(value),
    const DeepCollectionEquality().hash(_andConditions),
    const DeepCollectionEquality().hash(_orConditions),
  );

  /// Create a copy of MacroCondition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroConditionImplCopyWith<_$MacroConditionImpl> get copyWith =>
      __$$MacroConditionImplCopyWithImpl<_$MacroConditionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MacroConditionImplToJson(this);
  }
}

abstract class _MacroCondition implements MacroCondition {
  const factory _MacroCondition({
    required final String type,
    required final String field,
    required final String operator,
    final dynamic value,
    final List<MacroCondition>? andConditions,
    final List<MacroCondition>? orConditions,
  }) = _$MacroConditionImpl;

  factory _MacroCondition.fromJson(Map<String, dynamic> json) =
      _$MacroConditionImpl.fromJson;

  @override
  String get type;
  @override
  String get field;
  @override
  String get operator;
  @override
  dynamic get value;
  @override
  List<MacroCondition>? get andConditions;
  @override
  List<MacroCondition>? get orConditions;

  /// Create a copy of MacroCondition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MacroConditionImplCopyWith<_$MacroConditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MacroExecution _$MacroExecutionFromJson(Map<String, dynamic> json) {
  return _MacroExecution.fromJson(json);
}

/// @nodoc
mixin _$MacroExecution {
  String get id => throw _privateConstructorUsedError;
  int get macroId => throw _privateConstructorUsedError;
  String get macroName => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  MacroExecutionStatus get status => throw _privateConstructorUsedError;
  List<MacroActionResult>? get actionResults =>
      throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, dynamic>? get context => throw _privateConstructorUsedError;

  /// Serializes this MacroExecution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MacroExecution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MacroExecutionCopyWith<MacroExecution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroExecutionCopyWith<$Res> {
  factory $MacroExecutionCopyWith(
    MacroExecution value,
    $Res Function(MacroExecution) then,
  ) = _$MacroExecutionCopyWithImpl<$Res, MacroExecution>;
  @useResult
  $Res call({
    String id,
    int macroId,
    String macroName,
    DateTime startedAt,
    DateTime? completedAt,
    MacroExecutionStatus status,
    List<MacroActionResult>? actionResults,
    String? error,
    Map<String, dynamic>? context,
  });
}

/// @nodoc
class _$MacroExecutionCopyWithImpl<$Res, $Val extends MacroExecution>
    implements $MacroExecutionCopyWith<$Res> {
  _$MacroExecutionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MacroExecution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? macroId = null,
    Object? macroName = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? status = null,
    Object? actionResults = freezed,
    Object? error = freezed,
    Object? context = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            macroId: null == macroId
                ? _value.macroId
                : macroId // ignore: cast_nullable_to_non_nullable
                      as int,
            macroName: null == macroName
                ? _value.macroName
                : macroName // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MacroExecutionStatus,
            actionResults: freezed == actionResults
                ? _value.actionResults
                : actionResults // ignore: cast_nullable_to_non_nullable
                      as List<MacroActionResult>?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            context: freezed == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MacroExecutionImplCopyWith<$Res>
    implements $MacroExecutionCopyWith<$Res> {
  factory _$$MacroExecutionImplCopyWith(
    _$MacroExecutionImpl value,
    $Res Function(_$MacroExecutionImpl) then,
  ) = __$$MacroExecutionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int macroId,
    String macroName,
    DateTime startedAt,
    DateTime? completedAt,
    MacroExecutionStatus status,
    List<MacroActionResult>? actionResults,
    String? error,
    Map<String, dynamic>? context,
  });
}

/// @nodoc
class __$$MacroExecutionImplCopyWithImpl<$Res>
    extends _$MacroExecutionCopyWithImpl<$Res, _$MacroExecutionImpl>
    implements _$$MacroExecutionImplCopyWith<$Res> {
  __$$MacroExecutionImplCopyWithImpl(
    _$MacroExecutionImpl _value,
    $Res Function(_$MacroExecutionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MacroExecution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? macroId = null,
    Object? macroName = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? status = null,
    Object? actionResults = freezed,
    Object? error = freezed,
    Object? context = freezed,
  }) {
    return _then(
      _$MacroExecutionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        macroId: null == macroId
            ? _value.macroId
            : macroId // ignore: cast_nullable_to_non_nullable
                  as int,
        macroName: null == macroName
            ? _value.macroName
            : macroName // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MacroExecutionStatus,
        actionResults: freezed == actionResults
            ? _value._actionResults
            : actionResults // ignore: cast_nullable_to_non_nullable
                  as List<MacroActionResult>?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        context: freezed == context
            ? _value._context
            : context // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MacroExecutionImpl implements _MacroExecution {
  const _$MacroExecutionImpl({
    required this.id,
    required this.macroId,
    required this.macroName,
    required this.startedAt,
    this.completedAt,
    required this.status,
    final List<MacroActionResult>? actionResults,
    this.error,
    final Map<String, dynamic>? context,
  }) : _actionResults = actionResults,
       _context = context;

  factory _$MacroExecutionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MacroExecutionImplFromJson(json);

  @override
  final String id;
  @override
  final int macroId;
  @override
  final String macroName;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  final MacroExecutionStatus status;
  final List<MacroActionResult>? _actionResults;
  @override
  List<MacroActionResult>? get actionResults {
    final value = _actionResults;
    if (value == null) return null;
    if (_actionResults is EqualUnmodifiableListView) return _actionResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? error;
  final Map<String, dynamic>? _context;
  @override
  Map<String, dynamic>? get context {
    final value = _context;
    if (value == null) return null;
    if (_context is EqualUnmodifiableMapView) return _context;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MacroExecution(id: $id, macroId: $macroId, macroName: $macroName, startedAt: $startedAt, completedAt: $completedAt, status: $status, actionResults: $actionResults, error: $error, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroExecutionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.macroId, macroId) || other.macroId == macroId) &&
            (identical(other.macroName, macroName) ||
                other.macroName == macroName) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._actionResults,
              _actionResults,
            ) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._context, _context));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    macroId,
    macroName,
    startedAt,
    completedAt,
    status,
    const DeepCollectionEquality().hash(_actionResults),
    error,
    const DeepCollectionEquality().hash(_context),
  );

  /// Create a copy of MacroExecution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroExecutionImplCopyWith<_$MacroExecutionImpl> get copyWith =>
      __$$MacroExecutionImplCopyWithImpl<_$MacroExecutionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MacroExecutionImplToJson(this);
  }
}

abstract class _MacroExecution implements MacroExecution {
  const factory _MacroExecution({
    required final String id,
    required final int macroId,
    required final String macroName,
    required final DateTime startedAt,
    final DateTime? completedAt,
    required final MacroExecutionStatus status,
    final List<MacroActionResult>? actionResults,
    final String? error,
    final Map<String, dynamic>? context,
  }) = _$MacroExecutionImpl;

  factory _MacroExecution.fromJson(Map<String, dynamic> json) =
      _$MacroExecutionImpl.fromJson;

  @override
  String get id;
  @override
  int get macroId;
  @override
  String get macroName;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;
  @override
  MacroExecutionStatus get status;
  @override
  List<MacroActionResult>? get actionResults;
  @override
  String? get error;
  @override
  Map<String, dynamic>? get context;

  /// Create a copy of MacroExecution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MacroExecutionImplCopyWith<_$MacroExecutionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MacroActionResult _$MacroActionResultFromJson(Map<String, dynamic> json) {
  return _MacroActionResult.fromJson(json);
}

/// @nodoc
mixin _$MacroActionResult {
  String get actionId => throw _privateConstructorUsedError;
  MacroActionType get actionType => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, dynamic>? get result => throw _privateConstructorUsedError;
  DateTime get executedAt => throw _privateConstructorUsedError;
  int? get durationMs => throw _privateConstructorUsedError;

  /// Serializes this MacroActionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MacroActionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MacroActionResultCopyWith<MacroActionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroActionResultCopyWith<$Res> {
  factory $MacroActionResultCopyWith(
    MacroActionResult value,
    $Res Function(MacroActionResult) then,
  ) = _$MacroActionResultCopyWithImpl<$Res, MacroActionResult>;
  @useResult
  $Res call({
    String actionId,
    MacroActionType actionType,
    bool success,
    String? error,
    Map<String, dynamic>? result,
    DateTime executedAt,
    int? durationMs,
  });
}

/// @nodoc
class _$MacroActionResultCopyWithImpl<$Res, $Val extends MacroActionResult>
    implements $MacroActionResultCopyWith<$Res> {
  _$MacroActionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MacroActionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionId = null,
    Object? actionType = null,
    Object? success = null,
    Object? error = freezed,
    Object? result = freezed,
    Object? executedAt = null,
    Object? durationMs = freezed,
  }) {
    return _then(
      _value.copyWith(
            actionId: null == actionId
                ? _value.actionId
                : actionId // ignore: cast_nullable_to_non_nullable
                      as String,
            actionType: null == actionType
                ? _value.actionType
                : actionType // ignore: cast_nullable_to_non_nullable
                      as MacroActionType,
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            executedAt: null == executedAt
                ? _value.executedAt
                : executedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMs: freezed == durationMs
                ? _value.durationMs
                : durationMs // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MacroActionResultImplCopyWith<$Res>
    implements $MacroActionResultCopyWith<$Res> {
  factory _$$MacroActionResultImplCopyWith(
    _$MacroActionResultImpl value,
    $Res Function(_$MacroActionResultImpl) then,
  ) = __$$MacroActionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String actionId,
    MacroActionType actionType,
    bool success,
    String? error,
    Map<String, dynamic>? result,
    DateTime executedAt,
    int? durationMs,
  });
}

/// @nodoc
class __$$MacroActionResultImplCopyWithImpl<$Res>
    extends _$MacroActionResultCopyWithImpl<$Res, _$MacroActionResultImpl>
    implements _$$MacroActionResultImplCopyWith<$Res> {
  __$$MacroActionResultImplCopyWithImpl(
    _$MacroActionResultImpl _value,
    $Res Function(_$MacroActionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MacroActionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionId = null,
    Object? actionType = null,
    Object? success = null,
    Object? error = freezed,
    Object? result = freezed,
    Object? executedAt = null,
    Object? durationMs = freezed,
  }) {
    return _then(
      _$MacroActionResultImpl(
        actionId: null == actionId
            ? _value.actionId
            : actionId // ignore: cast_nullable_to_non_nullable
                  as String,
        actionType: null == actionType
            ? _value.actionType
            : actionType // ignore: cast_nullable_to_non_nullable
                  as MacroActionType,
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        result: freezed == result
            ? _value._result
            : result // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        executedAt: null == executedAt
            ? _value.executedAt
            : executedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMs: freezed == durationMs
            ? _value.durationMs
            : durationMs // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MacroActionResultImpl implements _MacroActionResult {
  const _$MacroActionResultImpl({
    required this.actionId,
    required this.actionType,
    required this.success,
    this.error,
    final Map<String, dynamic>? result,
    required this.executedAt,
    this.durationMs,
  }) : _result = result;

  factory _$MacroActionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MacroActionResultImplFromJson(json);

  @override
  final String actionId;
  @override
  final MacroActionType actionType;
  @override
  final bool success;
  @override
  final String? error;
  final Map<String, dynamic>? _result;
  @override
  Map<String, dynamic>? get result {
    final value = _result;
    if (value == null) return null;
    if (_result is EqualUnmodifiableMapView) return _result;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime executedAt;
  @override
  final int? durationMs;

  @override
  String toString() {
    return 'MacroActionResult(actionId: $actionId, actionType: $actionType, success: $success, error: $error, result: $result, executedAt: $executedAt, durationMs: $durationMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroActionResultImpl &&
            (identical(other.actionId, actionId) ||
                other.actionId == actionId) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._result, _result) &&
            (identical(other.executedAt, executedAt) ||
                other.executedAt == executedAt) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    actionId,
    actionType,
    success,
    error,
    const DeepCollectionEquality().hash(_result),
    executedAt,
    durationMs,
  );

  /// Create a copy of MacroActionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroActionResultImplCopyWith<_$MacroActionResultImpl> get copyWith =>
      __$$MacroActionResultImplCopyWithImpl<_$MacroActionResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MacroActionResultImplToJson(this);
  }
}

abstract class _MacroActionResult implements MacroActionResult {
  const factory _MacroActionResult({
    required final String actionId,
    required final MacroActionType actionType,
    required final bool success,
    final String? error,
    final Map<String, dynamic>? result,
    required final DateTime executedAt,
    final int? durationMs,
  }) = _$MacroActionResultImpl;

  factory _MacroActionResult.fromJson(Map<String, dynamic> json) =
      _$MacroActionResultImpl.fromJson;

  @override
  String get actionId;
  @override
  MacroActionType get actionType;
  @override
  bool get success;
  @override
  String? get error;
  @override
  Map<String, dynamic>? get result;
  @override
  DateTime get executedAt;
  @override
  int? get durationMs;

  /// Create a copy of MacroActionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MacroActionResultImplCopyWith<_$MacroActionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
