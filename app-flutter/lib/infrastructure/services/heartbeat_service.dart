import 'dart:async';

import 'package:autocore_app/core/constants/mqtt_errors.dart';
import 'package:autocore_app/core/constants/mqtt_protocol.dart';
import 'package:autocore_app/core/constants/mqtt_qos.dart';
import 'package:autocore_app/core/models/error_message.dart';
import 'package:autocore_app/core/models/heartbeat_message.dart';
import 'package:autocore_app/core/models/relay_command.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/infrastructure/services/mqtt_service.dart';

/// Serviço crítico de heartbeat para botões momentâneos
///
/// **IMPORTANTE DE SEGURANÇA**: Este serviço é essencial para evitar que
/// botões momentâneos (buzina, guincho, partida) fiquem travados no estado ligado.
///
/// Funcionamento:
/// - Envia heartbeats a cada 500ms quando um botão momentâneo está ativo
/// - ESP32 desliga automaticamente o canal se não receber heartbeat por 1s
/// - Garante que nenhum botão fica ligado permanentemente
class HeartbeatService {
  static HeartbeatService? _instance;
  static HeartbeatService get instance => _instance ??= HeartbeatService._();

  HeartbeatService._();

  final MqttService _mqttService = MqttService.instance;
  final String _appUuid = 'flutter-app-001'; // TODO: get from config

  // Timings críticos de segurança
  static const Duration heartbeatInterval = Duration(
    milliseconds: MqttProtocol.heartbeatIntervalMs,
  );
  static const Duration heartbeatTimeout = Duration(
    milliseconds: MqttProtocol.heartbeatTimeoutMs,
  );
  static const int maxRetries = 3;

  // Estado dos heartbeats ativos
  final Map<String, _HeartbeatState> _activeHeartbeats = {};

  // Channels que DEVEM usar heartbeat (momentâneos)
  static const List<String> momentaryChannels = [
    'buzina',
    'guincho_in',
    'guincho_out',
    'partida',
    'lampejo',
  ];

  bool get hasActiveHeartbeats => _activeHeartbeats.isNotEmpty;

  List<String> get activeDevices => _activeHeartbeats.keys.toList();

  /// Inicia heartbeat para um botão momentâneo
  ///
  /// [deviceUuid] - UUID do dispositivo (ex: 'esp32-relay-001')
  /// [channel] - Número do canal do relé (1-8)
  /// [channelName] - Nome do canal para logging (opcional)
  Future<bool> startMomentary(
    String deviceUuid,
    int channel, {
    String? channelName,
  }) async {
    final key = '$deviceUuid-$channel';

    // Verificar se já está ativo
    if (_activeHeartbeats.containsKey(key)) {
      AppLogger.warning('Heartbeat já ativo para $key');
      return true;
    }

    AppLogger.info(
      'Iniciando heartbeat momentâneo: $key (${channelName ?? 'canal $channel'})',
    );

    try {
      // Enviar comando inicial ON com formato correto
      final command = RelayCommand.momentary(
        channel: channel,
        state: true,
        deviceUuid: deviceUuid,
      );

      final success = await _mqttService.publish(
        'autocore/devices/$deviceUuid/relays/set',
        command.toJsonString(),
        qos: MqttQosLevels.commands, // QoS 1 para comando
      );

      if (!success) {
        AppLogger.error('Falha ao enviar comando inicial para $key');
        return false;
      }

      // Criar estado do heartbeat
      final state = _HeartbeatState(
        deviceUuid: deviceUuid,
        channel: channel,
        channelName: channelName,
        startedAt: DateTime.now(),
      );

      // Iniciar timer de heartbeat
      state.timer = Timer.periodic(heartbeatInterval, (timer) {
        _sendHeartbeat(key, state);
      });

      // Iniciar timer de timeout
      _startTimeoutTimer(key, state);

      _activeHeartbeats[key] = state;

      AppLogger.info('Heartbeat iniciado com sucesso para $key');
      return true;
    } catch (e, stack) {
      AppLogger.error(
        'Erro ao iniciar heartbeat para $key',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Para heartbeat de um botão momentâneo
  Future<bool> stopMomentary(String deviceUuid, int channel) async {
    final key = '$deviceUuid-$channel';
    final state = _activeHeartbeats[key];

    if (state == null) {
      AppLogger.warning('Tentativa de parar heartbeat não ativo: $key');
      return true; // Não é erro, só não tinha heartbeat
    }

    AppLogger.info('Parando heartbeat momentâneo: $key');

    try {
      // Parar timers
      state.timer?.cancel();
      state.timeoutTimer?.cancel();

      // Enviar comando OFF com formato correto
      final command = RelayCommand.momentary(
        channel: channel,
        state: false,
        deviceUuid: deviceUuid,
      );

      await _mqttService.publish(
        'autocore/devices/$deviceUuid/relays/set',
        command.toJsonString(),
        qos: MqttQosLevels.commands,
      );

      // Remover do estado
      _activeHeartbeats.remove(key);

      final duration = DateTime.now().difference(state.startedAt);
      AppLogger.info(
        'Heartbeat parado: $key (duração: ${duration.inMilliseconds}ms)',
      );

      return true;
    } catch (e, stack) {
      AppLogger.error(
        'Erro ao parar heartbeat para $key',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Para TODOS os heartbeats imediatamente (EMERGÊNCIA)
  ///
  /// Usado quando:
  /// - App perde foco
  /// - App é minimizado
  /// - Erro crítico
  /// - Parada de emergência
  Future<void> emergencyStopAll() async {
    if (_activeHeartbeats.isEmpty) {
      AppLogger.debug('Nenhum heartbeat ativo para parar');
      return;
    }

    AppLogger.warning(
      '🚨 PARADA DE EMERGÊNCIA - Parando ${_activeHeartbeats.length} heartbeats',
    );

    final stopFutures = <Future<bool>>[];

    // Para todos os heartbeats em paralelo
    for (final key in _activeHeartbeats.keys.toList()) {
      final state = _activeHeartbeats[key]!;

      // Para timers imediatamente
      state.timer?.cancel();
      state.timeoutTimer?.cancel();

      // Envia comando OFF (não aguarda)
      final command = RelayCommand.momentary(
        channel: state.channel,
        state: false,
        deviceUuid: state.deviceUuid,
      );

      stopFutures.add(
        _mqttService.publish(
          'autocore/devices/${state.deviceUuid}/relays/set',
          command.toJsonString(),
          qos: MqttQosLevels.commands,
        ),
      );
    }

    // Limpa estado
    _activeHeartbeats.clear();

    // Aguarda todos os comandos OFF (com timeout)
    try {
      await Future.wait(stopFutures).timeout(const Duration(seconds: 2));
      AppLogger.warning('Todos os heartbeats foram parados');
    } catch (e) {
      AppLogger.error(
        'Timeout ao parar heartbeats, mas estado foi limpo',
        error: e,
      );
    }
  }

  /// Verifica se um dispositivo/canal está com heartbeat ativo
  bool isActive(String deviceUuid, int channel) {
    final key = '$deviceUuid-$channel';
    return _activeHeartbeats.containsKey(key);
  }

  /// Obtém estatísticas de um heartbeat ativo
  Map<String, dynamic>? getStats(String deviceUuid, int channel) {
    final key = '$deviceUuid-$channel';
    final state = _activeHeartbeats[key];

    if (state == null) return null;

    final now = DateTime.now();
    final duration = now.difference(state.startedAt);

    return {
      'device': state.deviceUuid,
      'channel': state.channel,
      'channel_name': state.channelName,
      'started_at': state.startedAt.toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'heartbeat_count': state.heartbeatCount,
      'last_heartbeat': state.lastHeartbeat?.toIso8601String(),
      'failed_attempts': state.failedAttempts,
    };
  }

  /// Obtém estatísticas de todos os heartbeats ativos
  Map<String, dynamic> getAllStats() {
    final stats = <String, dynamic>{};

    for (final key in _activeHeartbeats.keys) {
      final parts = key.split('-');
      if (parts.length >= 2) {
        final deviceUuid = parts.sublist(0, parts.length - 1).join('-');
        final channel = int.tryParse(parts.last) ?? 0;
        stats[key] = getStats(deviceUuid, channel);
      }
    }

    return {
      'active_count': _activeHeartbeats.length,
      'heartbeats': stats,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  void _startTimeoutTimer(String key, _HeartbeatState state) {
    // Cancelar timer anterior se existir
    state.timeoutTimer?.cancel();

    state.timeoutTimer = Timer(heartbeatTimeout, () {
      AppLogger.error('Heartbeat timeout for $key');

      // Enviar erro padronizado
      final error = MqttErrorMessage(
        errorCode: MqttErrorCode.mqtt005,
        message: 'Heartbeat timeout detected',
        details: {
          'channel': state.channel,
          'device_uuid': state.deviceUuid,
          'last_sequence': state.heartbeatCount,
        },
        deviceUuid: _appUuid,
      );

      _mqttService.publish(
        'autocore/errors/$_appUuid/heartbeat_timeout',
        error.toJsonString(),
        qos: MqttQosLevels.events,
      );

      // Parar heartbeat
      final parts = key.split('-');
      if (parts.length >= 2) {
        final deviceUuid = parts.sublist(0, parts.length - 1).join('-');
        final channel = int.tryParse(parts.last) ?? 0;
        stopMomentary(deviceUuid, channel);
      }
    });
  }

  Future<void> _sendHeartbeat(String key, _HeartbeatState state) async {
    try {
      state.heartbeatCount++;
      state.lastHeartbeat = DateTime.now();

      final heartbeat = HeartbeatMessage(
        channel: state.channel,
        sequence: state.heartbeatCount,
        sourceUuid: _appUuid,
        targetUuid: state.deviceUuid,
      );

      final success = await _mqttService.publish(
        'autocore/devices/${state.deviceUuid}/relays/heartbeat',
        heartbeat.toJsonString(),
        qos: MqttQosLevels.heartbeat, // QoS 0 para heartbeat
      );

      if (!success) {
        state.failedAttempts++;
        AppLogger.warning(
          'Falha no heartbeat $key (tentativa ${state.failedAttempts})',
        );

        // Se muitas falhas, para o heartbeat por segurança
        if (state.failedAttempts >= maxRetries) {
          AppLogger.error(
            'Muitas falhas no heartbeat $key, parando por segurança',
          );
          final parts = key.split('-');
          if (parts.length >= 2) {
            final deviceUuid = parts.sublist(0, parts.length - 1).join('-');
            final channel = int.tryParse(parts.last) ?? 0;
            await stopMomentary(deviceUuid, channel);
          }
        }
      } else {
        // Reset contador de falhas em caso de sucesso
        state.failedAttempts = 0;

        // Reiniciar timer de timeout a cada heartbeat bem-sucedido
        _startTimeoutTimer(key, state);
      }
    } catch (e, stack) {
      AppLogger.error(
        'Erro ao enviar heartbeat $key',
        error: e,
        stackTrace: stack,
      );
      state.failedAttempts++;
    }
  }

  /// Limpa todos os recursos
  void dispose() {
    AppLogger.info('Descartando HeartbeatService');

    // Para todos os heartbeats sem aguardar (dispose deve ser rápido)
    for (final state in _activeHeartbeats.values) {
      state.timer?.cancel();
      state.timeoutTimer?.cancel();
    }

    _activeHeartbeats.clear();
  }
}

/// Estado interno de um heartbeat ativo
class _HeartbeatState {
  final String deviceUuid;
  final int channel;
  final String? channelName;
  final DateTime startedAt;

  Timer? timer;
  Timer? timeoutTimer;
  int heartbeatCount = 0;
  DateTime? lastHeartbeat;
  int failedAttempts = 0;

  _HeartbeatState({
    required this.deviceUuid,
    required this.channel,
    this.channelName,
    required this.startedAt,
  });
}
