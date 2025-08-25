import 'dart:async';
import 'dart:convert';

import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/domain/entities/macro.dart';
import 'package:autocore_app/infrastructure/services/mqtt_service.dart';
import 'package:uuid/uuid.dart';

class MacroService {
  final MqttService _mqttService = MqttService.instance;
  final _uuid = const Uuid();

  final Map<int, Macro> _macros = {};
  final Map<String, MacroExecution> _executions = {};
  final Map<MacroTriggerType, List<Macro>> _triggerIndex = {};
  final StreamController<MacroExecution> _executionController =
      StreamController<MacroExecution>.broadcast();
  final StreamController<List<Macro>> _macrosController =
      StreamController<List<Macro>>.broadcast();

  Timer? _scheduledTimer;
  final Map<String, StreamSubscription<dynamic>> _mqttSubscriptions = {};

  MacroService() {
    _initialize();
  }

  void _initialize() {
    AppLogger.init('MacroService');
    _loadMacros();
    _setupTriggers();
    _startScheduler();
  }

  Stream<MacroExecution> get executionStream => _executionController.stream;
  Stream<List<Macro>> get macrosStream => _macrosController.stream;
  List<Macro> get macros => _macros.values.toList();

  void _loadMacros() {
    // TODO(dev): Carregar macros do banco de dados ou API
    // Por enquanto, vamos criar alguns macros de exemplo

    final exampleMacros = [
      MacroTemplates.toggleLight(
        name: 'Liga/Desliga Farol',
        deviceId: 'esp32_001',
        channelId: 1,
      ).copyWith(id: 1),

      MacroTemplates.sequentialLights(
        name: 'Sequência de Luzes',
        deviceId: 'esp32_001',
        channelIds: [1, 2, 3, 4],
        delayMs: 300,
      ).copyWith(id: 2),

      MacroTemplates.timedAction(
        name: 'Desligar Tudo à Noite',
        time: '23:00',
        actions: [
          const MacroAction(
            id: '1',
            type: MacroActionType.mqttPublish,
            config: {
              'topic': 'autocore/device/all/channels/off',
              'payload': {'command': 'all_off'},
            },
          ),
        ],
      ).copyWith(id: 3),
    ];

    for (final macro in exampleMacros) {
      _macros[macro.id] = macro;
      _indexTrigger(macro);
    }

    _notifyMacrosChanged();
  }

  void _indexTrigger(Macro macro) {
    if (!_triggerIndex.containsKey(macro.triggerType)) {
      _triggerIndex[macro.triggerType] = [];
    }
    _triggerIndex[macro.triggerType]!.add(macro);
  }

  void _setupTriggers() {
    // Configurar listeners para triggers MQTT
    _setupMqttTriggers();

    // Configurar triggers de condição
    _setupConditionTriggers();
  }

  void _setupMqttTriggers() {
    final mqttMacros = _triggerIndex[MacroTriggerType.mqttMessage] ?? [];

    for (final macro in mqttMacros) {
      if (macro.triggerConfig != null &&
          macro.triggerConfig!['topic'] != null) {
        final topic = macro.triggerConfig!['topic'] as String;

        _mqttSubscriptions[topic] = _mqttService.subscribe(topic).listen((
          message,
        ) {
          _handleMqttTrigger(macro, message);
        });

        AppLogger.info(
          'Configurado trigger MQTT para macro ${macro.name}: $topic',
        );
      }
    }
  }

  void _setupConditionTriggers() {
    final conditionMacros = _triggerIndex[MacroTriggerType.condition] ?? [];

    for (final macro in conditionMacros) {
      if (macro.triggerConfig != null &&
          macro.triggerConfig!['topic'] != null) {
        final topic = macro.triggerConfig!['topic'] as String;

        _mqttSubscriptions['condition_${macro.id}'] = _mqttService
            .subscribe(topic)
            .listen((message) {
              _evaluateConditionTrigger(macro, message);
            });

        AppLogger.info(
          'Configurado trigger de condição para macro ${macro.name}: $topic',
        );
      }
    }
  }

  void _handleMqttTrigger(Macro macro, String message) {
    if (!macro.enabled) return;

    try {
      final payload = json.decode(message) as Map<String, dynamic>;

      // Verificar se a mensagem atende aos critérios do trigger
      if (_matchesTriggerCriteria(macro.triggerConfig!, payload)) {
        execute(macro.id, context: {'trigger': 'mqtt', 'payload': payload});
      }
    } catch (e) {
      AppLogger.error('Erro ao processar trigger MQTT', error: e);
    }
  }

  void _evaluateConditionTrigger(Macro macro, String message) {
    if (!macro.enabled) return;

    try {
      final payload = json.decode(message) as Map<String, dynamic>;
      final field = macro.triggerConfig!['field'] as String;
      final expectedValue = macro.triggerConfig!['value'];

      if (payload[field] == expectedValue) {
        execute(
          macro.id,
          context: {'trigger': 'condition', 'payload': payload},
        );
      }
    } catch (e) {
      AppLogger.error('Erro ao avaliar condição', error: e);
    }
  }

  bool _matchesTriggerCriteria(
    Map<String, dynamic> criteria,
    Map<String, dynamic> payload,
  ) {
    // Implementar lógica de matching de critérios
    // Verifica se todos os critérios são atendidos
    for (final entry in criteria.entries) {
      final key = entry.key;
      final expectedValue = entry.value;

      // Pular chaves especiais
      if (['topic', 'field', 'value'].contains(key)) continue;

      if (!payload.containsKey(key) || payload[key] != expectedValue) {
        return false;
      }
    }

    return true;
  }

  void _startScheduler() {
    _scheduledTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkScheduledMacros();
    });
  }

  void _checkScheduledMacros() {
    final now = DateTime.now();
    final timeMacros = _triggerIndex[MacroTriggerType.time] ?? [];

    for (final macro in timeMacros) {
      if (!macro.enabled) continue;

      if (macro.triggerConfig != null && macro.triggerConfig!['time'] != null) {
        final scheduledTime = macro.triggerConfig!['time'] as String;
        final parts = scheduledTime.split(':');

        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;

          if (now.hour == hour && now.minute == minute) {
            // Verificar dias da semana se configurado
            final weekdays = macro.triggerConfig!['weekdays'] as List<String>?;

            if (weekdays == null || _isWeekdayEnabled(now, weekdays)) {
              execute(macro.id, context: {'trigger': 'scheduled'});
            }
          }
        }
      }
    }
  }

  bool _isWeekdayEnabled(DateTime date, List<String> weekdays) {
    const weekdayMap = {
      1: 'mon',
      2: 'tue',
      3: 'wed',
      4: 'thu',
      5: 'fri',
      6: 'sat',
      7: 'sun',
    };

    final currentWeekday = weekdayMap[date.weekday];
    return weekdays.contains(currentWeekday);
  }

  Future<MacroExecution> execute(
    int macroId, {
    Map<String, dynamic>? context,
  }) async {
    final macro = _macros[macroId];

    if (macro == null) {
      throw Exception('Macro não encontrado: $macroId');
    }

    if (!macro.enabled) {
      throw Exception('Macro desabilitado: ${macro.name}');
    }

    final executionId = _uuid.v4();
    final execution = MacroExecution(
      id: executionId,
      macroId: macroId,
      macroName: macro.name,
      startedAt: DateTime.now(),
      status: MacroExecutionStatus.running,
      context: context,
    );

    _executions[executionId] = execution;
    _executionController.add(execution);

    AppLogger.info('Executando macro: ${macro.name}');

    try {
      final results = <MacroActionResult>[];

      for (final action in macro.actions) {
        if (!action.enabled) continue;

        // Aplicar delay se configurado
        if (action.delayMs != null && action.delayMs! > 0) {
          await Future<void>.delayed(Duration(milliseconds: action.delayMs!));
        }

        // Avaliar condição se existir
        if (action.condition != null) {
          final conditionMet = await _evaluateCondition(
            action.condition!,
            context,
          );

          if (conditionMet && action.thenActions != null) {
            for (final thenAction in action.thenActions!) {
              final result = await _executeAction(thenAction, context);
              results.add(result);
            }
          } else if (!conditionMet && action.elseActions != null) {
            for (final elseAction in action.elseActions!) {
              final result = await _executeAction(elseAction, context);
              results.add(result);
            }
          }
        } else {
          final result = await _executeAction(action, context);
          results.add(result);
        }
      }

      final completedExecution = execution.copyWith(
        completedAt: DateTime.now(),
        status: MacroExecutionStatus.completed,
        actionResults: results,
      );

      _executions[executionId] = completedExecution;
      _executionController.add(completedExecution);

      // Atualizar estatísticas do macro
      _updateMacroStats(macroId);

      AppLogger.info('Macro executado com sucesso: ${macro.name}');

      return completedExecution;
    } catch (e) {
      AppLogger.error('Erro ao executar macro: ${macro.name}', error: e);

      final failedExecution = execution.copyWith(
        completedAt: DateTime.now(),
        status: MacroExecutionStatus.failed,
        error: e.toString(),
      );

      _executions[executionId] = failedExecution;
      _executionController.add(failedExecution);

      return failedExecution;
    }
  }

  Future<bool> _evaluateCondition(
    MacroCondition condition,
    Map<String, dynamic>? context,
  ) async {
    // Implementar avaliação de condições
    // Por enquanto, sempre retorna true
    return true;
  }

  Future<MacroActionResult> _executeAction(
    MacroAction action,
    Map<String, dynamic>? context,
  ) async {
    final startTime = DateTime.now();

    try {
      dynamic result;

      switch (action.type) {
        case MacroActionType.mqttPublish:
          result = await _executeMqttPublish(action.config);
          break;

        case MacroActionType.httpRequest:
          result = await _executeHttpRequest(action.config);
          break;

        case MacroActionType.delay:
          await Future<void>.delayed(
            Duration(milliseconds: (action.config['ms'] as int?) ?? 1000),
          );
          result = {'delayed': action.config['ms']};
          break;

        case MacroActionType.navigate:
          // Navegação será tratada pela UI
          result = {'navigate': action.config['screen']};
          break;

        case MacroActionType.toggle:
          result = await _executeToggle(action.config);
          break;

        case MacroActionType.setValue:
          result = await _executeSetValue(action.config);
          break;

        case MacroActionType.conditional:
          // Já tratado no execute()
          result = {'conditional': 'evaluated'};
          break;

        case MacroActionType.batch:
          result = await _executeBatch(action.config);
          break;
      }

      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return MacroActionResult(
        actionId: action.id,
        actionType: action.type,
        success: true,
        result: result is Map<String, dynamic> ? result : {'value': result},
        executedAt: DateTime.now(),
        durationMs: duration,
      );
    } catch (e) {
      AppLogger.error('Erro ao executar ação', error: e);

      return MacroActionResult(
        actionId: action.id,
        actionType: action.type,
        success: false,
        error: e.toString(),
        executedAt: DateTime.now(),
        durationMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    }
  }

  Future<Map<String, dynamic>> _executeMqttPublish(
    Map<String, dynamic> config,
  ) async {
    final topic = config['topic'] as String;
    final payload = config['payload'];
    final retain = config['retain'] ?? false;
    final qos = config['qos'] ?? 0;

    AppLogger.network(
      'MQTT Publish',
      data: {'topic': topic, 'payload': payload, 'retain': retain, 'qos': qos},
    );

    // Publicar via MQTT real
    final success = await _mqttService.publishJson(
      topic,
      payload is Map<String, dynamic> ? payload : {'value': payload},
      retain: retain is bool ? retain : retain == true,
    );

    return {
      'topic': topic,
      'payload': payload,
      'published': success,
      'retain': retain,
      'qos': qos,
    };
  }

  Future<Map<String, dynamic>> _executeHttpRequest(
    Map<String, dynamic> config,
  ) async {
    final url = config['url'] as String;
    final method = config['method'] ?? 'GET';

    // TODO(autocore): Implementar HTTP client quando a dependência estiver disponível
    AppLogger.network('HTTP Request simulado: $method $url');

    return {'statusCode': 200, 'body': '{}', 'success': true, 'mock': true};
  }

  Future<Map<String, dynamic>> _executeToggle(
    Map<String, dynamic> config,
  ) async {
    final topic = config['topic'] as String;
    final field = config['field'] ?? 'state';

    AppLogger.network(
      'MQTT Toggle',
      data: {'topic': topic, 'command': 'toggle', 'field': field},
    );

    // Publicar comando de toggle via MQTT
    final success = await _mqttService.publishJson(topic, {
      'command': 'toggle',
      'field': field,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return {'topic': topic, 'field': field, 'toggled': success};
  }

  Future<Map<String, dynamic>> _executeSetValue(
    Map<String, dynamic> config,
  ) async {
    final topic = config['topic'] as String;
    final field = config['field'] as String;
    final value = config['value'];

    AppLogger.network(
      'MQTT SetValue',
      data: {'topic': topic, 'field': field, 'value': value},
    );

    // Publicar comando de setValue via MQTT
    final success = await _mqttService.publishJson(topic, {
      'command': 'set',
      'field': field,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return {'topic': topic, 'field': field, 'value': value, 'set': success};
  }

  Future<Map<String, dynamic>> _executeBatch(
    Map<String, dynamic> config,
  ) async {
    final actions = config['actions'] as List<dynamic>;
    final parallel = (config['parallel'] as bool?) ?? false;
    final results = <String, dynamic>{};

    if (parallel) {
      // Executar ações em paralelo
      final futures = actions.map((actionConfig) async {
        final action = MacroAction.fromJson(
          actionConfig as Map<String, dynamic>,
        );
        return _executeAction(action, null);
      });

      final actionResults = await Future.wait(futures);

      for (var i = 0; i < actionResults.length; i++) {
        results['action_$i'] = actionResults[i].toJson();
      }
    } else {
      // Executar ações em sequência
      for (var i = 0; i < actions.length; i++) {
        final action = MacroAction.fromJson(actions[i] as Map<String, dynamic>);
        final result = await _executeAction(action, null);
        results['action_$i'] = result.toJson();
      }
    }

    return results;
  }

  void _updateMacroStats(int macroId) {
    final macro = _macros[macroId];
    if (macro != null) {
      _macros[macroId] = macro.copyWith(
        lastExecutedAt: DateTime.now(),
        executionCount: (macro.executionCount ?? 0) + 1,
      );
      _notifyMacrosChanged();
    }
  }

  void addMacro(Macro macro) {
    _macros[macro.id] = macro;
    _indexTrigger(macro);
    _setupTriggersForMacro(macro);
    _notifyMacrosChanged();
  }

  void updateMacro(Macro macro) {
    // Remover triggers antigos
    final oldMacro = _macros[macro.id];
    if (oldMacro != null) {
      _removeTriggersForMacro(oldMacro);
    }

    // Atualizar macro
    _macros[macro.id] = macro;
    _indexTrigger(macro);
    _setupTriggersForMacro(macro);
    _notifyMacrosChanged();
  }

  void deleteMacro(int macroId) {
    final macro = _macros[macroId];
    if (macro != null) {
      _removeTriggersForMacro(macro);
      _macros.remove(macroId);
      _notifyMacrosChanged();
    }
  }

  void _setupTriggersForMacro(Macro macro) {
    if (macro.triggerType == MacroTriggerType.mqttMessage ||
        macro.triggerType == MacroTriggerType.condition) {
      _setupMqttTriggers();
    }
  }

  void _removeTriggersForMacro(Macro macro) {
    // Remover do índice
    _triggerIndex[macro.triggerType]?.remove(macro);

    // Cancelar subscriptions MQTT relacionadas
    if (macro.triggerType == MacroTriggerType.mqttMessage) {
      final topic = macro.triggerConfig?['topic'] as String?;
      if (topic != null) {
        _mqttSubscriptions[topic]?.cancel();
        _mqttSubscriptions.remove(topic);
      }
    } else if (macro.triggerType == MacroTriggerType.condition) {
      final key = 'condition_${macro.id}';
      _mqttSubscriptions[key]?.cancel();
      _mqttSubscriptions.remove(key);
    }
  }

  void _notifyMacrosChanged() {
    _macrosController.add(macros);
  }

  MacroExecution? getExecution(String executionId) {
    return _executions[executionId];
  }

  List<MacroExecution> getRecentExecutions({int limit = 10}) {
    final sorted = _executions.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return sorted.take(limit).toList();
  }

  void dispose() {
    _scheduledTimer?.cancel();

    for (final subscription in _mqttSubscriptions.values) {
      subscription.cancel();
    }

    _executionController.close();
    _macrosController.close();
  }
}
