import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum AutoCoreMqttState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class MqttService {
  static MqttService? _instance;
  static MqttService get instance => _instance ??= MqttService._();

  MqttService._();

  late MqttServerClient _client;
  final Logger _logger = Logger();

  // Connection parameters
  String _serverUrl = '';
  int _port = 1883;
  String _clientId = '';
  String? _username;
  String? _password;

  // State management
  final _connectionStateController =
      StreamController<AutoCoreMqttState>.broadcast();
  Stream<AutoCoreMqttState> get connectionState =>
      _connectionStateController.stream;
  AutoCoreMqttState _currentState = AutoCoreMqttState.disconnected;

  // Message streams - Controllers are closed in dispose()
  final Map<String, StreamController<String>> _topicControllers = {};
  final Map<String, StreamSubscription<String>> _subscriptions = {};

  // Reconnection
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 10;
  final Duration _reconnectDelay = const Duration(seconds: 5);

  // Queue for offline messages
  final List<_QueuedMessage> _messageQueue = [];

  /// Initialize MQTT connection
  Future<bool> connect({
    required String serverUrl,
    int port = 1883,
    String? clientId,
    String? username,
    String? password,
    bool autoReconnect = true,
  }) async {
    try {
      _serverUrl = serverUrl;
      _port = port;
      _clientId =
          clientId ?? 'autocore_${DateTime.now().millisecondsSinceEpoch}';
      _username = username;
      _password = password;

      _updateConnectionState(AutoCoreMqttState.connecting);

      // Create client
      _client = MqttServerClient.withPort(_serverUrl, _clientId, _port);

      // Configure client
      _client.logging(on: false);
      _client.keepAlivePeriod = 60;
      _client.autoReconnect = autoReconnect;
      _client.onAutoReconnect = _onAutoReconnect;
      _client.onAutoReconnected = _onAutoReconnected;
      _client.onConnected = _onConnected;
      _client.onDisconnected = _onDisconnected;
      _client.onSubscribed = _onSubscribed;
      _client.onUnsubscribed = _onUnsubscribed;

      // Set protocol
      _client.setProtocolV311();

      // Connection message
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce)
          .withWillTopic('autocore/status/$_clientId')
          .withWillMessage('offline')
          .withWillRetain();

      if (_username != null && _password != null) {
        connMessage.authenticateAs(_username, _password);
      }

      _client.connectionMessage = connMessage;

      // Connect
      _logger.i('Connecting to MQTT broker at $_serverUrl:$_port');
      await _client.connect(_username, _password);

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        _logger.i('Connected to MQTT broker');
        _setupMessageListener();
        _processQueuedMessages();
        return true;
      }

      _logger.e('Failed to connect to MQTT broker');
      _updateConnectionState(AutoCoreMqttState.error);
      return false;
    } catch (e) {
      _logger.e('Error connecting to MQTT: $e');
      _updateConnectionState(AutoCoreMqttState.error);
      _startReconnectTimer();
      return false;
    }
  }

  /// Disconnect from MQTT broker
  Future<void> disconnect() async {
    _updateConnectionState(AutoCoreMqttState.disconnecting);
    _cancelReconnectTimer();

    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // Close topic controllers
    for (final controller in _topicControllers.values) {
      await controller.close();
    }
    _topicControllers.clear();

    // Disconnect client
    _client.disconnect();
    _updateConnectionState(AutoCoreMqttState.disconnected);

    _logger.i('Disconnected from MQTT broker');
  }

  /// Get or create a stream controller for a topic
  StreamController<String> _getOrCreateController(String topic) {
    if (!_topicControllers.containsKey(topic)) {
      final newController = StreamController<String>.broadcast();
      _topicControllers[topic] = newController;
      return newController;
    }
    return _topicControllers[topic]!;
  }

  /// Subscribe to a topic
  Stream<String> subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    // Get or create controller for this topic
    _getOrCreateController(topic);

    // Subscribe if connected
    if (_currentState == AutoCoreMqttState.connected) {
      _client.subscribe(topic, qos);
      _logger.d('Subscribed to topic: $topic');
    } else {
      // Queue subscription for when connected
      _logger.d('Queued subscription to topic: $topic');
    }

    // Return the stream from the managed controller
    return _topicControllers[topic]!.stream;
  }

  /// Unsubscribe from a topic
  void unsubscribe(String topic) {
    if (_currentState == AutoCoreMqttState.connected) {
      _client.unsubscribe(topic);
    }

    _topicControllers[topic]?.close();
    _topicControllers.remove(topic);
    _subscriptions[topic]?.cancel();
    _subscriptions.remove(topic);

    _logger.d('Unsubscribed from topic: $topic');
  }

  /// Publish a message to a topic
  void publish(
    String topic,
    String message, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    if (_currentState == AutoCoreMqttState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      _client.publishMessage(topic, qos, builder.payload!, retain: retain);
      _logger.d('Published to $topic: $message');
    } else {
      // Queue message for later
      _messageQueue.add(
        _QueuedMessage(
          topic: topic,
          message: message,
          qos: qos,
          retain: retain,
        ),
      );
      _logger.d('Queued message for $topic (offline)');
    }
  }

  /// Publish JSON data
  void publishJson(
    String topic,
    Map<String, dynamic> data, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    final message = jsonEncode(data);
    publish(topic, message, qos: qos, retain: retain);
  }

  /// Get current connection state
  AutoCoreMqttState get currentConnectionState => _currentState;

  /// Check if connected
  bool get isConnected => _currentState == AutoCoreMqttState.connected;

  // Private methods

  void _setupMessageListener() {
    _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        final topic = message.topic;

        if (message.payload is MqttPublishMessage) {
          final payload = message.payload as MqttPublishMessage;
          final msg = MqttPublishPayload.bytesToStringAsString(
            payload.payload.message,
          );

          _logger.d('Received message on $topic: $msg');

          // Send to appropriate controller
          _topicControllers[topic]?.add(msg);

          // Check for wildcard subscriptions
          for (final subscribedTopic in _topicControllers.keys) {
            if (_matchTopic(subscribedTopic, topic)) {
              _topicControllers[subscribedTopic]?.add(msg);
            }
          }
        }
      }
    });
  }

  bool _matchTopic(String pattern, String topic) {
    if (pattern == topic) return true;

    // Handle wildcards
    if (pattern.contains('+') || pattern.contains('#')) {
      final patternParts = pattern.split('/');
      final topicParts = topic.split('/');

      if (pattern.contains('#')) {
        // # must be at the end
        final hashIndex = patternParts.indexOf('#');
        if (hashIndex != patternParts.length - 1) return false;

        // Check all parts before #
        for (int i = 0; i < hashIndex; i++) {
          if (i >= topicParts.length) return false;
          if (patternParts[i] != '+' && patternParts[i] != topicParts[i]) {
            return false;
          }
        }
        return true;
      }

      // Handle + wildcard
      if (patternParts.length != topicParts.length) return false;

      for (int i = 0; i < patternParts.length; i++) {
        if (patternParts[i] != '+' && patternParts[i] != topicParts[i]) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  void _updateConnectionState(AutoCoreMqttState newState) {
    _currentState = newState;
    _connectionStateController.add(newState);
    _logger.i('Connection state changed to: $newState');
  }

  void _onConnected() {
    _updateConnectionState(AutoCoreMqttState.connected);
    _reconnectAttempts = 0;
    _cancelReconnectTimer();

    // Resubscribe to all topics
    for (final topic in _topicControllers.keys) {
      _client.subscribe(topic, MqttQos.atLeastOnce);
    }

    // Publish online status
    publish('autocore/status/$_clientId', 'online', retain: true);
  }

  void _onDisconnected() {
    _updateConnectionState(AutoCoreMqttState.disconnected);
    _startReconnectTimer();
  }

  void _onAutoReconnect() {
    _logger.i('Auto-reconnecting to MQTT broker...');
    _updateConnectionState(AutoCoreMqttState.connecting);
  }

  void _onAutoReconnected() {
    _logger.i('Auto-reconnected to MQTT broker');
    _onConnected();
  }

  void _onSubscribed(String topic) {
    _logger.d('Subscription confirmed for topic: $topic');
  }

  void _onUnsubscribed(String? topic) {
    _logger.d('Unsubscription confirmed for topic: $topic');
  }

  void _startReconnectTimer() {
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectTimer = Timer.periodic(_reconnectDelay, (timer) {
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        _logger.e('Max reconnection attempts reached');
        timer.cancel();
        _updateConnectionState(AutoCoreMqttState.error);
        return;
      }

      _reconnectAttempts++;
      _logger.i('Reconnection attempt $_reconnectAttempts');

      connect(
        serverUrl: _serverUrl,
        port: _port,
        clientId: _clientId,
        username: _username,
        password: _password,
      );
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _processQueuedMessages() {
    if (_messageQueue.isEmpty) return;

    _logger.i('Processing ${_messageQueue.length} queued messages');

    for (final queuedMessage in _messageQueue) {
      publish(
        queuedMessage.topic,
        queuedMessage.message,
        qos: queuedMessage.qos,
        retain: queuedMessage.retain,
      );
    }

    _messageQueue.clear();
  }

  /// Dispose of resources
  void dispose() {
    // Close all topic controllers
    for (final controller in _topicControllers.values) {
      controller.close();
    }
    _topicControllers.clear();

    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Close connection state controller
    _connectionStateController.close();

    // Cancel timers
    _cancelReconnectTimer();

    // Disconnect from broker
    if (isConnected) {
      disconnect();
    }

    _logger.i('MqttService disposed');
  }
}

class _QueuedMessage {
  final String topic;
  final String message;
  final MqttQos qos;
  final bool retain;

  _QueuedMessage({
    required this.topic,
    required this.message,
    required this.qos,
    required this.retain,
  });
}
