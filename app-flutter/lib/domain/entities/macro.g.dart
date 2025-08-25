// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MacroImpl _$$MacroImplFromJson(Map<String, dynamic> json) => _$MacroImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  icon: json['icon'] as String?,
  enabled: json['enabled'] as bool,
  triggerType: $enumDecode(_$MacroTriggerTypeEnumMap, json['triggerType']),
  triggerConfig: json['triggerConfig'] as Map<String, dynamic>?,
  actions: (json['actions'] as List<dynamic>)
      .map((e) => MacroAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  lastExecutedAt: json['lastExecutedAt'] == null
      ? null
      : DateTime.parse(json['lastExecutedAt'] as String),
  executionCount: (json['executionCount'] as num?)?.toInt(),
  category: json['category'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isSystem: json['isSystem'] as bool? ?? false,
  showInUi: json['showInUi'] as bool? ?? true,
);

Map<String, dynamic> _$$MacroImplToJson(_$MacroImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'enabled': instance.enabled,
      'triggerType': _$MacroTriggerTypeEnumMap[instance.triggerType]!,
      'triggerConfig': instance.triggerConfig,
      'actions': instance.actions,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastExecutedAt': instance.lastExecutedAt?.toIso8601String(),
      'executionCount': instance.executionCount,
      'category': instance.category,
      'tags': instance.tags,
      'isSystem': instance.isSystem,
      'showInUi': instance.showInUi,
    };

const _$MacroTriggerTypeEnumMap = {
  MacroTriggerType.manual: 'manual',
  MacroTriggerType.mqttMessage: 'mqtt_message',
  MacroTriggerType.time: 'time',
  MacroTriggerType.condition: 'condition',
  MacroTriggerType.startup: 'startup',
  MacroTriggerType.deviceState: 'device_state',
};

_$MacroActionImpl _$$MacroActionImplFromJson(Map<String, dynamic> json) =>
    _$MacroActionImpl(
      id: json['id'] as String,
      type: $enumDecode(_$MacroActionTypeEnumMap, json['type']),
      config: json['config'] as Map<String, dynamic>,
      description: json['description'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      delayMs: (json['delayMs'] as num?)?.toInt(),
      condition: json['condition'] == null
          ? null
          : MacroCondition.fromJson(json['condition'] as Map<String, dynamic>),
      thenActions: (json['thenActions'] as List<dynamic>?)
          ?.map((e) => MacroAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      elseActions: (json['elseActions'] as List<dynamic>?)
          ?.map((e) => MacroAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MacroActionImplToJson(_$MacroActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MacroActionTypeEnumMap[instance.type]!,
      'config': instance.config,
      'description': instance.description,
      'enabled': instance.enabled,
      'delayMs': instance.delayMs,
      'condition': instance.condition,
      'thenActions': instance.thenActions,
      'elseActions': instance.elseActions,
    };

const _$MacroActionTypeEnumMap = {
  MacroActionType.mqttPublish: 'mqtt_publish',
  MacroActionType.httpRequest: 'http_request',
  MacroActionType.delay: 'delay',
  MacroActionType.navigate: 'navigate',
  MacroActionType.toggle: 'toggle',
  MacroActionType.setValue: 'set_value',
  MacroActionType.conditional: 'conditional',
  MacroActionType.batch: 'batch',
};

_$MacroConditionImpl _$$MacroConditionImplFromJson(Map<String, dynamic> json) =>
    _$MacroConditionImpl(
      type: json['type'] as String,
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
      andConditions: (json['andConditions'] as List<dynamic>?)
          ?.map((e) => MacroCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      orConditions: (json['orConditions'] as List<dynamic>?)
          ?.map((e) => MacroCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MacroConditionImplToJson(
  _$MacroConditionImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'field': instance.field,
  'operator': instance.operator,
  'value': instance.value,
  'andConditions': instance.andConditions,
  'orConditions': instance.orConditions,
};

_$MacroExecutionImpl _$$MacroExecutionImplFromJson(Map<String, dynamic> json) =>
    _$MacroExecutionImpl(
      id: json['id'] as String,
      macroId: (json['macroId'] as num).toInt(),
      macroName: json['macroName'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      status: $enumDecode(_$MacroExecutionStatusEnumMap, json['status']),
      actionResults: (json['actionResults'] as List<dynamic>?)
          ?.map((e) => MacroActionResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
      context: json['context'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MacroExecutionImplToJson(
  _$MacroExecutionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'macroId': instance.macroId,
  'macroName': instance.macroName,
  'startedAt': instance.startedAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'status': _$MacroExecutionStatusEnumMap[instance.status]!,
  'actionResults': instance.actionResults,
  'error': instance.error,
  'context': instance.context,
};

const _$MacroExecutionStatusEnumMap = {
  MacroExecutionStatus.pending: 'pending',
  MacroExecutionStatus.running: 'running',
  MacroExecutionStatus.completed: 'completed',
  MacroExecutionStatus.failed: 'failed',
  MacroExecutionStatus.cancelled: 'cancelled',
};

_$MacroActionResultImpl _$$MacroActionResultImplFromJson(
  Map<String, dynamic> json,
) => _$MacroActionResultImpl(
  actionId: json['actionId'] as String,
  actionType: $enumDecode(_$MacroActionTypeEnumMap, json['actionType']),
  success: json['success'] as bool,
  error: json['error'] as String?,
  result: json['result'] as Map<String, dynamic>?,
  executedAt: DateTime.parse(json['executedAt'] as String),
  durationMs: (json['durationMs'] as num?)?.toInt(),
);

Map<String, dynamic> _$$MacroActionResultImplToJson(
  _$MacroActionResultImpl instance,
) => <String, dynamic>{
  'actionId': instance.actionId,
  'actionType': _$MacroActionTypeEnumMap[instance.actionType]!,
  'success': instance.success,
  'error': instance.error,
  'result': instance.result,
  'executedAt': instance.executedAt.toIso8601String(),
  'durationMs': instance.durationMs,
};
