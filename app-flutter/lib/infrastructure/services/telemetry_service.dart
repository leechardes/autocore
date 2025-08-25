import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:autocore_app/core/constants/mqtt_topics.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:autocore_app/core/services/mqtt_service.dart';
import 'package:autocore_app/core/utils/logger.dart';

class TelemetryService {
  static TelemetryService? _instance;
  static TelemetryService get instance =>
      _instance ??= TelemetryService._internal();

  TelemetryService._internal();

  final MqttService _mqttService = MqttService.instance;
  final Random _random = Random();

  // Streams
  final StreamController<TelemetryData> _telemetryController =
      StreamController<TelemetryData>.broadcast();
  final StreamController<Map<String, bool>> _relayStatesController =
      StreamController<Map<String, bool>>.broadcast();
  final StreamController<Map<String, double>> _sensorValuesController =
      StreamController<Map<String, double>>.broadcast();

  // Estado interno
  bool _isSubscribed = false;
  bool _isSimulating = false;
  String? _currentDeviceUuid;
  Timer? _simulationTimer;
  Timer? _heartbeatTimer;

  // Dados simulados
  final Map<String, bool> _currentRelayStates = {};
  final Map<String, double> _currentSensorValues = {};
  int _sequenceCounter = 0;

  // Getters para streams
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  Stream<Map<String, bool>> get relayStatesStream =>
      _relayStatesController.stream;
  Stream<Map<String, double>> get sensorValuesStream =>
      _sensorValuesController.stream;

  /// Inicia monitoramento de telemetria para um dispositivo
  Future<void> startTelemetry({
    required String deviceUuid,
    int? telemetryInterval,
    bool enableSimulation = true,
  }) async {
    _currentDeviceUuid = deviceUuid;

    try {
      // Tenta se inscrever no MQTT
      await _subscribeToMqtt(deviceUuid);

      // Se não conseguir conectar ao MQTT e simulação estiver habilitada
      if (!_isSubscribed && enableSimulation) {
        AppLogger.warning(
          'MQTT não disponível, iniciando simulação de telemetria',
        );
        await _startSimulation(telemetryInterval ?? 1000);
      }

      AppLogger.init('TelemetryService para device: $deviceUuid');
    } catch (e) {
      AppLogger.error('Erro ao iniciar telemetria', error: e);

      if (enableSimulation) {
        AppLogger.info('Iniciando modo de simulação devido a erro');
        await _startSimulation(telemetryInterval ?? 1000);
      }
    }
  }

  /// Para monitoramento de telemetria
  Future<void> stopTelemetry() async {
    _simulationTimer?.cancel();
    _heartbeatTimer?.cancel();

    if (_isSubscribed && _currentDeviceUuid != null) {
      await _unsubscribeFromMqtt(_currentDeviceUuid!);
    }

    _isSubscribed = false;
    _isSimulating = false;
    _currentDeviceUuid = null;

    AppLogger.dispose('TelemetryService');
  }

  /// Subscreve aos tópicos MQTT de telemetria
  Future<void> _subscribeToMqtt(String deviceUuid) async {
    try {
      if (!_mqttService.isConnected) {
        throw Exception('MQTT não está conectado');
      }

      // Tópicos de telemetria
      final telemetryTopic = MqttTopics.deviceTelemetry(deviceUuid);
      final relayTopic = MqttTopics.deviceRelays(deviceUuid);
      final sensorTopic = MqttTopics.deviceSensors(deviceUuid);
      final heartbeatTopic = MqttTopics.deviceHeartbeat(deviceUuid);

      // Subscreve aos tópicos e configura listeners
      _mqttService.subscribe(telemetryTopic).listen((payload) {
        _handleMqttMessage({'topic': telemetryTopic, 'payload': payload});
      });

      _mqttService.subscribe(relayTopic).listen((payload) {
        _handleMqttMessage({'topic': relayTopic, 'payload': payload});
      });

      _mqttService.subscribe(sensorTopic).listen((payload) {
        _handleMqttMessage({'topic': sensorTopic, 'payload': payload});
      });

      _mqttService.subscribe(heartbeatTopic).listen((payload) {
        _handleMqttMessage({'topic': heartbeatTopic, 'payload': payload});
      });

      _isSubscribed = true;
      AppLogger.config(
        'Subscrito aos tópicos MQTT de telemetria para $deviceUuid',
      );
    } catch (e) {
      AppLogger.error('Erro ao subscrever aos tópicos MQTT', error: e);
      rethrow;
    }
  }

  /// Remove subscrição dos tópicos MQTT
  Future<void> _unsubscribeFromMqtt(String deviceUuid) async {
    try {
      final telemetryTopic = MqttTopics.deviceTelemetry(deviceUuid);
      final relayTopic = MqttTopics.deviceRelays(deviceUuid);
      final sensorTopic = MqttTopics.deviceSensors(deviceUuid);
      final heartbeatTopic = MqttTopics.deviceHeartbeat(deviceUuid);

      _mqttService.unsubscribe(telemetryTopic);
      _mqttService.unsubscribe(relayTopic);
      _mqttService.unsubscribe(sensorTopic);
      _mqttService.unsubscribe(heartbeatTopic);

      AppLogger.config('Dessuscrito dos tópicos MQTT para $deviceUuid');
    } catch (e) {
      AppLogger.error('Erro ao dessuscrever dos tópicos MQTT', error: e);
    }
  }

  /// Processa mensagens MQTT recebidas
  void _handleMqttMessage(Map<String, dynamic> message) {
    try {
      final topic = message['topic'] as String;
      final payload = message['payload'] as String;

      if (_currentDeviceUuid == null) return;

      AppLogger.network('Mensagem MQTT recebida: $topic');

      if (topic.contains('/telemetry')) {
        _handleTelemetryMessage(payload);
      } else if (topic.contains('/relays')) {
        _handleRelayMessage(payload);
      } else if (topic.contains('/sensors')) {
        _handleSensorMessage(payload);
      } else if (topic.contains('/heartbeat')) {
        _handleHeartbeatMessage(payload);
      }
    } catch (e) {
      AppLogger.error('Erro ao processar mensagem MQTT', error: e);
    }
  }

  /// Processa mensagem de telemetria
  void _handleTelemetryMessage(String payload) {
    try {
      final data = json.decode(payload) as Map<String, dynamic>;

      final telemetryData = TelemetryData(
        timestamp: DateTime.now(),
        deviceUuid: _currentDeviceUuid!,
        sequence: (data['sequence'] as int?) ?? _sequenceCounter++,
        data: data,
        signalStrength: data['signal_strength'] as int?,
        batteryLevel: (data['battery_level'] as num?)?.toDouble(),
        temperature: (data['temperature'] as num?)?.toDouble(),
        humidity: (data['humidity'] as num?)?.toDouble(),
        pressure: (data['pressure'] as num?)?.toDouble(),
        relayStates: data['relay_states'] != null
            ? Map<String, bool>.from(data['relay_states'] as Map)
            : null,
        sensorValues: data['sensor_values'] != null
            ? (data['sensor_values'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
              )
            : null,
        systemStatus: data['system_status'] as String?,
        errorCodes: data['error_codes'] != null
            ? List<String>.from(data['error_codes'] as List)
            : null,
        uptime: data['uptime'] as int?,
        memoryUsage: (data['memory_usage'] as num?)?.toDouble(),
        cpuUsage: (data['cpu_usage'] as num?)?.toDouble(),
        networkStatus: data['network_status'] as String?,
        wifiStrength: data['wifi_strength'] as int?,
        gpsCoordinates: data['gps_coordinates'] != null
            ? (data['gps_coordinates'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
              )
            : null,
        rawPayload: payload,
      );

      _telemetryController.add(telemetryData);
    } catch (e) {
      AppLogger.error('Erro ao processar telemetria MQTT', error: e);
    }
  }

  /// Processa mensagem de estado dos relés
  void _handleRelayMessage(String payload) {
    try {
      final data = json.decode(payload) as Map<String, dynamic>;
      final relayStates = Map<String, bool>.from(data);

      _currentRelayStates.addAll(relayStates);
      _relayStatesController.add(Map<String, bool>.from(_currentRelayStates));
    } catch (e) {
      AppLogger.error('Erro ao processar estados de relé', error: e);
    }
  }

  /// Processa mensagem de sensores
  void _handleSensorMessage(String payload) {
    try {
      final data = json.decode(payload) as Map<String, dynamic>;
      final sensorValues = <String, double>{};

      data.forEach((key, value) {
        if (value is num) {
          sensorValues[key] = value.toDouble();
        }
      });

      _currentSensorValues.addAll(sensorValues);
      _sensorValuesController.add(
        Map<String, double>.from(_currentSensorValues),
      );
    } catch (e) {
      AppLogger.error('Erro ao processar valores de sensores', error: e);
    }
  }

  /// Processa mensagem de heartbeat
  void _handleHeartbeatMessage(String payload) {
    try {
      final data = json.decode(payload) as Map<String, dynamic>;
      AppLogger.network('Heartbeat recebido: ${data['timestamp']}');
    } catch (e) {
      AppLogger.error('Erro ao processar heartbeat', error: e);
    }
  }

  /// Inicia simulação de telemetria
  Future<void> _startSimulation(int intervalMs) async {
    _isSimulating = true;

    // Inicializa dados simulados
    _initializeSimulatedData();

    _simulationTimer = Timer.periodic(Duration(milliseconds: intervalMs), (
      timer,
    ) {
      _generateSimulatedTelemetry();
    });

    // Heartbeat simulado a cada 5 segundos
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _generateSimulatedHeartbeat();
    });

    AppLogger.config('Simulação de telemetria iniciada (${intervalMs}ms)');
  }

  /// Inicializa dados simulados
  void _initializeSimulatedData() {
    // Relés simulados
    _currentRelayStates.addAll({
      'light_front': false,
      'light_rear': false,
      'winch': false,
      'compressor': false,
      'aux_1': false,
      'aux_2': false,
    });

    // Sensores simulados
    _currentSensorValues.addAll({
      'battery_voltage': 12.8,
      'battery_current': 0.5,
      'temperature_engine': 85.0,
      'temperature_cabin': 22.0,
      'fuel_level': 75.0,
      'oil_pressure': 4.2,
      'water_temperature': 88.0,
    });
  }

  /// Gera telemetria simulada
  void _generateSimulatedTelemetry() {
    if (!_isSimulating || _currentDeviceUuid == null) return;

    // Varia valores dos sensores
    _currentSensorValues['battery_voltage'] = 12.0 + _random.nextDouble() * 2.0;
    _currentSensorValues['battery_current'] = _random.nextDouble() * 10.0;
    _currentSensorValues['temperature_engine'] =
        80.0 + _random.nextDouble() * 20.0;
    _currentSensorValues['temperature_cabin'] =
        20.0 + _random.nextDouble() * 10.0;
    _currentSensorValues['fuel_level'] = 70.0 + _random.nextDouble() * 10.0;

    // Ocasionalmente liga/desliga relés
    if (_random.nextDouble() < 0.1) {
      // 10% de chance
      final relayKeys = _currentRelayStates.keys.toList();
      final randomRelay = relayKeys[_random.nextInt(relayKeys.length)];
      _currentRelayStates[randomRelay] = !_currentRelayStates[randomRelay]!;
    }

    // Cria dados de telemetria
    final telemetryData = TelemetryData(
      timestamp: DateTime.now(),
      deviceUuid: _currentDeviceUuid!,
      sequence: _sequenceCounter++,
      data: {
        'simulated': true,
        'relay_states': _currentRelayStates,
        'sensor_values': _currentSensorValues,
      },
      signalStrength: 80 + _random.nextInt(20),
      batteryLevel: _currentSensorValues['battery_voltage'],
      temperature: _currentSensorValues['temperature_cabin'],
      relayStates: Map<String, bool>.from(_currentRelayStates),
      sensorValues: Map<String, double>.from(_currentSensorValues),
      systemStatus: 'running',
      uptime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      memoryUsage: 20.0 + _random.nextDouble() * 30.0,
      cpuUsage: 5.0 + _random.nextDouble() * 25.0,
      networkStatus: 'connected',
      wifiStrength: 70 + _random.nextInt(30),
    );

    _telemetryController.add(telemetryData);
    _relayStatesController.add(Map<String, bool>.from(_currentRelayStates));
    _sensorValuesController.add(Map<String, double>.from(_currentSensorValues));
  }

  /// Gera heartbeat simulado
  void _generateSimulatedHeartbeat() {
    if (!_isSimulating) return;

    AppLogger.network('Heartbeat simulado gerado');
  }

  /// Obtém último estado dos relés
  Map<String, bool> get currentRelayStates =>
      Map<String, bool>.from(_currentRelayStates);

  /// Obtém últimos valores dos sensores
  Map<String, double> get currentSensorValues =>
      Map<String, double>.from(_currentSensorValues);

  /// Verifica se está recebendo telemetria
  bool get isReceivingTelemetry => _isSubscribed || _isSimulating;

  /// Verifica se está em modo simulação
  bool get isSimulating => _isSimulating;

  /// Obtém UUID do dispositivo atual
  String? get currentDeviceUuid => _currentDeviceUuid;

  /// Força atualização de um relé (para simulação)
  void updateSimulatedRelay(String relayId, bool state) {
    if (_isSimulating) {
      _currentRelayStates[relayId] = state;
      _relayStatesController.add(Map<String, bool>.from(_currentRelayStates));

      AppLogger.userAction(
        'Relé $relayId ${state ? "ligado" : "desligado"} (simulado)',
      );
    }
  }

  /// Força atualização de um sensor (para simulação)
  void updateSimulatedSensor(String sensorId, double value) {
    if (_isSimulating) {
      _currentSensorValues[sensorId] = value;
      _sensorValuesController.add(
        Map<String, double>.from(_currentSensorValues),
      );

      AppLogger.userAction(
        'Sensor $sensorId atualizado para $value (simulado)',
      );
    }
  }

  /// Limpa recursos
  void dispose() {
    _simulationTimer?.cancel();
    _heartbeatTimer?.cancel();
    _telemetryController.close();
    _relayStatesController.close();
    _sensorValuesController.close();
  }
}
