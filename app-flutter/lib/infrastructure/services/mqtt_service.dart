import 'dart:async';
import 'dart:convert';

import 'package:autocore_app/core/constants/device_constants.dart';
import 'package:autocore_app/core/constants/mqtt_protocol.dart';
import 'package:autocore_app/core/constants/mqtt_qos.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/domain/models/mqtt_config.dart';
import 'package:autocore_app/infrastructure/services/api_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço central de MQTT para comunicação com dispositivos AutoCore
///
/// Responsável por:
/// - Conectar ao broker MQTT
/// - Publicar comandos para dispositivos
/// - Subscrever a tópicos de estado
/// - Gerenciar reconexão automática
class MqttService {
  static MqttService? _instance;
  static MqttService get instance => _instance ??= MqttService._();

  MqttService._();

  MqttServerClient? _client;
  final Map<String, StreamController<String>> _subscriptions = {};
  final Map<String, StreamSubscription<dynamic>> _streamSubscriptions = {};

  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;

  MqttConfig? _currentConfig;

  // Configurações do broker
  static const String _defaultHost = '10.0.10.100';
  static const int _defaultPort = 1883;
  // Usa UUID fixo do dispositivo
  final String _deviceUuid = DeviceConstants.deviceUuid;

  bool get isConnected => _isConnected;

  /// Busca configuração MQTT da API e salva localmente
  Future<MqttConfig> _fetchMqttConfig() async {
    AppLogger.info('Buscando configuração MQTT da API');

    try {
      // Buscar da API primeiro
      final apiConfig = await ApiService.instance.getMqttConfig();

      // Buscar configuração local salva
      final localConfig = await _getSavedConfig();

      // Merge: configurações da API como base, locais têm prioridade
      final mergedConfig = localConfig != null
          ? apiConfig.mergeWithLocal(localConfig)
          : apiConfig;

      // Salvar configuração atualizada
      await _saveConfig(mergedConfig);

      AppLogger.info(
        'Configuração MQTT obtida e salva: ${mergedConfig.broker}:${mergedConfig.port}',
      );
      return mergedConfig;
    } catch (e) {
      AppLogger.error(
        'Erro ao buscar configuração da API, usando configuração salva',
        error: e,
      );

      // Se falhou buscar da API, usa configuração salva ou padrão
      final savedConfig = await _getSavedConfig();
      if (savedConfig != null) {
        AppLogger.info('Usando configuração MQTT salva localmente');
        return savedConfig;
      }

      AppLogger.warning('Usando configuração MQTT padrão');
      return MqttConfig.development();
    }
  }

  /// Salva configuração MQTT localmente
  Future<void> _saveConfig(MqttConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = jsonEncode(config.toJson());
      await prefs.setString('mqtt_config', configJson);
      AppLogger.debug('Configuração MQTT salva localmente');
    } catch (e) {
      AppLogger.error('Erro ao salvar configuração MQTT', error: e);
    }
  }

  /// Recupera configuração MQTT salva localmente
  Future<MqttConfig?> _getSavedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('mqtt_config');

      if (configJson != null) {
        final configData = jsonDecode(configJson) as Map<String, dynamic>;
        final config = MqttConfig.fromJson(configData);
        AppLogger.debug('Configuração MQTT recuperada do storage local');
        return config;
      }

      return null;
    } catch (e) {
      AppLogger.error('Erro ao recuperar configuração MQTT salva', error: e);
      return null;
    }
  }

  /// Inicializa e conecta ao broker MQTT
  Future<bool> connect({
    String? host,
    int? port,
    String? username,
    String? password,
  }) async {
    if (_isConnecting || _isConnected) {
      return _isConnected;
    }

    _isConnecting = true;

    try {
      // Buscar configuração da API ou usar parâmetros fornecidos
      if (host == null &&
          port == null &&
          username == null &&
          password == null) {
        _currentConfig = await _fetchMqttConfig();
      } else {
        // Usar parâmetros fornecidos (configuração manual)
        _currentConfig = MqttConfig(
          broker: host ?? _defaultHost,
          port: port ?? _defaultPort,
          username: username,
          password: password,
        );
      }

      // Gerar client ID baseado no padrão da configuração
      final clientId = _currentConfig!.getClientId(_deviceUuid);

      AppLogger.info(
        'Conectando MQTT com configuração: ${_currentConfig!.broker}:${_currentConfig!.port}',
      );
      AppLogger.debug('Client ID: $clientId');

      _client = MqttServerClient(_currentConfig!.broker, clientId);
      _client!.port = _currentConfig!.port;
      _client!.keepAlivePeriod = _currentConfig!.keepalive;
      _client!.connectTimeoutPeriod = _currentConfig!.connectionTimeout;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onUnsubscribed = _onUnsubscribed;
      _client!.onSubscribed = _onSubscribed;
      _client!.onSubscribeFail = _onSubscribeFail;
      _client!.pongCallback = _onPong;

      // Configurar mensagem de última vontade
      final willTopic =
          '${_currentConfig!.topicPrefix}/devices/$clientId/status';
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .withWillTopic(willTopic)
          .withWillMessage(
            jsonEncode({
              'protocol_version': MqttProtocol.version,
              'uuid': clientId,
              'status': 'offline',
              'timestamp': DateTime.now().toIso8601String(),
              'reason': 'unexpected_disconnect',
            }),
          )
          .withWillQos(MqttQos.values[_currentConfig!.qos])
          .startClean(); // Clean session

      final configUsername = _currentConfig!.username;
      final configPassword = _currentConfig!.password;
      if (configUsername != null && configPassword != null) {
        connMessage.authenticateAs(configUsername, configPassword);
      }

      _client!.connectionMessage = connMessage;

      AppLogger.info(
        'Conectando ao MQTT broker: ${_currentConfig!.broker}:${_currentConfig!.port}',
      );

      final status = await _client!.connect();

      if (status?.state == MqttConnectionState.connected) {
        _isConnected = true;
        _isConnecting = false;
        AppLogger.info('Conectado ao MQTT broker com sucesso');

        // Publicar status online
        final statusTopic =
            '${_currentConfig!.topicPrefix}/devices/$clientId/status';
        await publish(
          statusTopic,
          jsonEncode({
            'protocol_version': MqttProtocol.version,
            'uuid': clientId,
            'status': 'online',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          retain: _currentConfig!.retain,
        );

        // Reestabelecer subscriptions
        await _resubscribeAll();

        return true;
      } else {
        AppLogger.error('Falha na conexão MQTT: ${status?.returnCode}');
        _isConnecting = false;
        return false;
      }
    } catch (e, stack) {
      AppLogger.error('Erro ao conectar MQTT', error: e, stackTrace: stack);
      _isConnecting = false;
      return false;
    }
  }

  /// Publica uma mensagem em um tópico
  Future<bool> publish(
    String topic,
    String message, {
    MqttQos? qos,
    bool retain = false,
  }) async {
    final effectiveQos = qos ?? MqttQosLevels.getQosForTopic(topic);
    if (!_isConnected || _client == null) {
      AppLogger.warning('MQTT não conectado, ignorando publicação: $topic');
      return false;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      _client!.publishMessage(
        topic,
        effectiveQos,
        builder.payload!,
        retain: retain,
      );

      AppLogger.network(
        'MQTT Published',
        data: {
          'topic': topic,
          'message': message,
          'qos': effectiveQos.index,
          'retain': retain,
        },
      );

      return true;
    } catch (e, stack) {
      AppLogger.error('Erro ao publicar MQTT', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Publica um objeto JSON em um tópico
  Future<bool> publishJson(
    String topic,
    Map<String, dynamic> data, {
    MqttQos? qos,
    bool retain = false,
  }) async {
    return publish(topic, jsonEncode(data), qos: qos, retain: retain);
  }

  /// Subscreve a um tópico e retorna stream de mensagens
  Stream<String> subscribe(String topic, {MqttQos? qos}) {
    final effectiveQos = qos ?? MqttQosLevels.getQosForTopic(topic);
    // Se já temos subscription ativa, retorna o stream existente
    if (_subscriptions.containsKey(topic)) {
      return _subscriptions[topic]!.stream;
    }

    // ignore: close_sinks - Controller é fechado no dispose() método (linha 311)
    final controller = StreamController<String>.broadcast();
    _subscriptions[topic] = controller;

    // Se conectado, faz subscription imediata
    if (_isConnected && _client != null) {
      _subscribeToTopic(topic, effectiveQos);
    }

    return controller.stream;
  }

  /// Cancela subscription de um tópico
  Future<void> unsubscribe(String topic) async {
    await _subscriptions[topic]?.close();
    _subscriptions.remove(topic);

    await _streamSubscriptions[topic]?.cancel();
    _streamSubscriptions.remove(topic);

    if (_isConnected && _client != null) {
      _client!.unsubscribe(topic);
      AppLogger.info('Unsubscribed from topic: $topic');
    }
  }

  void _subscribeToTopic(String topic, MqttQos qos) {
    if (_client == null) return;

    _client!.subscribe(topic, qos);

    AppLogger.info('Subscribed to $topic with QoS ${qos.index}');

    // Escutar mensagens deste tópico
    _streamSubscriptions[topic] = _client!.updates!
        .where((messages) => messages.any((msg) => msg.topic == topic))
        .listen((messages) {
          for (final message in messages) {
            if (message.topic == topic) {
              final payload = MqttPublishPayload.bytesToStringAsString(
                (message.payload as MqttPublishMessage).payload.message,
              );

              AppLogger.network(
                'MQTT Received',
                data: {'topic': topic, 'payload': payload},
              );

              _subscriptions[topic]?.add(payload);
            }
          }
        });
  }

  Future<void> _resubscribeAll() async {
    for (final topic in _subscriptions.keys) {
      _subscribeToTopic(topic, MqttQos.atLeastOnce);
    }
  }

  void _onConnected() {
    _isConnected = true;
    _reconnectTimer?.cancel();
    AppLogger.info('MQTT conectado');
  }

  void _onDisconnected() {
    _isConnected = false;
    AppLogger.warning('MQTT desconectado');
    _startReconnectTimer();
  }

  void _onUnsubscribed(String? topic) {
    AppLogger.info('MQTT unsubscribed: ${topic ?? "unknown"}');
  }

  void _onSubscribed(String topic) {
    AppLogger.info('MQTT subscribed: $topic');
  }

  void _onSubscribeFail(String topic) {
    AppLogger.error('MQTT subscribe failed: $topic');
  }

  void _onPong() {
    AppLogger.debug('MQTT pong received');
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isConnecting) {
        AppLogger.info('Tentando reconectar MQTT...');
        connect();
      }
    });
  }

  /// Desconecta do broker MQTT
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();

    if (_isConnected && _client != null && _currentConfig != null) {
      // Publicar status offline
      final clientId = _currentConfig!.getClientId(_deviceUuid);
      final statusTopic =
          '${_currentConfig!.topicPrefix}/devices/$clientId/status';

      await publish(
        statusTopic,
        jsonEncode({
          'protocol_version': MqttProtocol.version,
          'uuid': clientId,
          'status': 'offline',
          'timestamp': DateTime.now().toIso8601String(),
          'reason': 'clean_disconnect',
        }),
        retain: _currentConfig!.retain,
      );

      _client!.disconnect();
    }

    _isConnected = false;
    _isConnecting = false;
  }

  /// Limpa todos os recursos
  void dispose() {
    _reconnectTimer?.cancel();

    for (final controller in _subscriptions.values) {
      controller.close();
    }
    _subscriptions.clear();

    for (final subscription in _streamSubscriptions.values) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();

    if (_client != null) {
      _client!.disconnect();
    }
  }

  /// Força refresh da configuração MQTT da API
  Future<void> refreshConfig() async {
    AppLogger.info('Forçando refresh da configuração MQTT');

    final wasConnected = _isConnected;

    // Desconecta se conectado
    if (wasConnected) {
      await disconnect();
    }

    // Busca nova configuração da API
    _currentConfig = await _fetchMqttConfig();

    // Reconecta se estava conectado
    if (wasConnected) {
      await connect();
    }

    AppLogger.info('Configuração MQTT atualizada com sucesso');
  }

  /// Testa conexão com o broker MQTT usando configuração da API
  Future<bool> testConnection() async {
    try {
      // Buscar configuração da API
      final config = await ApiService.instance.getMqttConfig();

      AppLogger.info(
        'Testando conexão MQTT com ${config.broker}:${config.port}',
      );

      final testClient = MqttServerClient(
        config.broker,
        'test_${DateTime.now().millisecondsSinceEpoch}',
      );
      testClient.port = config.port;
      testClient.autoReconnect = false;
      testClient.keepAlivePeriod = 5;
      testClient.connectTimeoutPeriod = 5000;
      testClient.logging(on: false);

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('test_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      // Usar credenciais da API
      if (config.username != null && config.password != null) {
        connMessage.authenticateAs(config.username, config.password);
      }

      testClient.connectionMessage = connMessage;

      try {
        await testClient.connect();
        final connected =
            testClient.connectionStatus?.state == MqttConnectionState.connected;

        if (connected) {
          testClient.disconnect();
        }

        AppLogger.info('Teste MQTT: ${connected ? "Sucesso" : "Falha"}');
        return connected;
      } catch (e) {
        AppLogger.error('Erro no teste MQTT', error: e);
        return false;
      }
    } catch (e) {
      AppLogger.error('Erro ao testar conexão MQTT', error: e);
      return false;
    }
  }
}
