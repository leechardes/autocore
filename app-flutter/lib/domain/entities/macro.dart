import 'package:freezed_annotation/freezed_annotation.dart';

part 'macro.freezed.dart';
part 'macro.g.dart';

enum MacroActionType {
  @JsonValue('mqtt_publish')
  mqttPublish,
  @JsonValue('http_request')
  httpRequest,
  @JsonValue('delay')
  delay,
  @JsonValue('navigate')
  navigate,
  @JsonValue('toggle')
  toggle,
  @JsonValue('set_value')
  setValue,
  @JsonValue('conditional')
  conditional,
  @JsonValue('batch')
  batch,
}

enum MacroTriggerType {
  @JsonValue('manual')
  manual,
  @JsonValue('mqtt_message')
  mqttMessage,
  @JsonValue('time')
  time,
  @JsonValue('condition')
  condition,
  @JsonValue('startup')
  startup,
  @JsonValue('device_state')
  deviceState,
}

@freezed
class Macro with _$Macro {
  const factory Macro({
    required int id,
    required String name,
    String? description,
    String? icon,
    required bool enabled,
    required MacroTriggerType triggerType,
    Map<String, dynamic>? triggerConfig,
    required List<MacroAction> actions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastExecutedAt,
    int? executionCount,
    String? category,
    List<String>? tags,
    @Default(false) bool isSystem,
    @Default(true) bool showInUi,
  }) = _Macro;

  factory Macro.fromJson(Map<String, dynamic> json) => _$MacroFromJson(json);
}

@freezed
class MacroAction with _$MacroAction {
  const factory MacroAction({
    required String id,
    required MacroActionType type,
    required Map<String, dynamic> config,
    String? description,
    @Default(true) bool enabled,
    int? delayMs,
    MacroCondition? condition,
    List<MacroAction>? thenActions,
    List<MacroAction>? elseActions,
  }) = _MacroAction;

  factory MacroAction.fromJson(Map<String, dynamic> json) =>
      _$MacroActionFromJson(json);
}

@freezed
class MacroCondition with _$MacroCondition {
  const factory MacroCondition({
    required String type,
    required String field,
    required String operator,
    dynamic value,
    List<MacroCondition>? andConditions,
    List<MacroCondition>? orConditions,
  }) = _MacroCondition;

  factory MacroCondition.fromJson(Map<String, dynamic> json) =>
      _$MacroConditionFromJson(json);
}

@freezed
class MacroExecution with _$MacroExecution {
  const factory MacroExecution({
    required String id,
    required int macroId,
    required String macroName,
    required DateTime startedAt,
    DateTime? completedAt,
    required MacroExecutionStatus status,
    List<MacroActionResult>? actionResults,
    String? error,
    Map<String, dynamic>? context,
  }) = _MacroExecution;

  factory MacroExecution.fromJson(Map<String, dynamic> json) =>
      _$MacroExecutionFromJson(json);
}

@freezed
class MacroActionResult with _$MacroActionResult {
  const factory MacroActionResult({
    required String actionId,
    required MacroActionType actionType,
    required bool success,
    String? error,
    Map<String, dynamic>? result,
    required DateTime executedAt,
    int? durationMs,
  }) = _MacroActionResult;

  factory MacroActionResult.fromJson(Map<String, dynamic> json) =>
      _$MacroActionResultFromJson(json);
}

enum MacroExecutionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('running')
  running,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

// Macro templates para facilitar a criação
class MacroTemplates {
  static Macro toggleLight({
    required String name,
    required String deviceId,
    required int channelId,
  }) {
    return Macro(
      id: 0,
      name: name,
      description: 'Alterna estado da luz',
      icon: 'lightbulb',
      enabled: true,
      triggerType: MacroTriggerType.manual,
      actions: [
        MacroAction(
          id: '1',
          type: MacroActionType.mqttPublish,
          config: {
            'topic': 'autocore/device/$deviceId/channel/$channelId/toggle',
            'payload': {'command': 'toggle'},
          },
        ),
      ],
    );
  }

  static Macro sequentialLights({
    required String name,
    required String deviceId,
    required List<int> channelIds,
    int delayMs = 500,
  }) {
    return Macro(
      id: 0,
      name: name,
      description: 'Liga luzes em sequência',
      icon: 'auto_awesome',
      enabled: true,
      triggerType: MacroTriggerType.manual,
      actions: channelIds.map((channelId) {
        return MacroAction(
          id: channelId.toString(),
          type: MacroActionType.mqttPublish,
          config: {
            'topic': 'autocore/device/$deviceId/channel/$channelId/set',
            'payload': {'state': true},
          },
          delayMs: delayMs,
        );
      }).toList(),
    );
  }

  static Macro conditionalAction({
    required String name,
    required String conditionTopic,
    required String conditionField,
    required dynamic conditionValue,
    required MacroAction thenAction,
    MacroAction? elseAction,
  }) {
    return Macro(
      id: 0,
      name: name,
      enabled: true,
      triggerType: MacroTriggerType.condition,
      triggerConfig: {
        'topic': conditionTopic,
        'field': conditionField,
        'value': conditionValue,
      },
      actions: [
        MacroAction(
          id: '1',
          type: MacroActionType.conditional,
          config: {},
          condition: MacroCondition(
            type: 'mqtt',
            field: conditionField,
            operator: '==',
            value: conditionValue,
          ),
          thenActions: [thenAction],
          elseActions: elseAction != null ? [elseAction] : null,
        ),
      ],
    );
  }

  static Macro timedAction({
    required String name,
    required String time,
    required List<MacroAction> actions,
    List<String>? weekdays,
  }) {
    return Macro(
      id: 0,
      name: name,
      description: 'Executa às $time',
      icon: 'schedule',
      enabled: true,
      triggerType: MacroTriggerType.time,
      triggerConfig: {
        'time': time,
        'weekdays':
            weekdays ?? ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      },
      actions: actions,
    );
  }
}
