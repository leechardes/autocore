class MqttProtocol {
  static const String version = '2.2.0';
  static const int heartbeatIntervalMs = 500;
  static const int heartbeatTimeoutMs = 1000;
  static const int reconnectIntervalMs = 5000;
}

class MqttProtocolException implements Exception {
  final String message;
  MqttProtocolException(this.message);

  @override
  String toString() => 'MqttProtocolException: $message';
}
