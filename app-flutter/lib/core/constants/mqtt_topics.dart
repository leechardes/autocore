/// Tópicos MQTT do AutoCore
class MqttTopics {
  MqttTopics._();

  // Configuração do broker
  static const String broker = 'autocore.local';
  static const int port = 1883;
  static const String clientId = 'autocore_flutter_app';

  // Prefixo base
  static const String prefix = 'autocore';

  // === TELEMETRIA (Subscribe) ===

  // Status geral
  static const String telemetryAll = '$prefix/telemetry/+/+';
  static const String telemetryStatus = '$prefix/telemetry/+/status';
  static const String telemetryBattery = '$prefix/telemetry/+/battery';
  static const String telemetrySafety = '$prefix/telemetry/+/safety';

  // Telemetria específica
  static String deviceTelemetry(String deviceId) =>
      '$prefix/telemetry/$deviceId/+';
  static String batteryVoltage(String deviceId) =>
      '$prefix/telemetry/$deviceId/battery';
  static String systemStatus(String deviceId) =>
      '$prefix/telemetry/$deviceId/status';
  static String deviceRelays(String deviceId) =>
      '$prefix/telemetry/$deviceId/relays';
  static String deviceSensors(String deviceId) =>
      '$prefix/telemetry/$deviceId/sensors';
  static String deviceHeartbeat(String deviceId) =>
      '$prefix/telemetry/$deviceId/heartbeat';

  // === COMANDOS (Publish) ===

  // Relays
  static String relaySet(String uuid) => '$prefix/devices/$uuid/relays/set';
  static String relayHeartbeat(String uuid) =>
      '$prefix/devices/$uuid/relays/heartbeat';
  static String relayChannel(String uuid, int channel) =>
      '$prefix/devices/$uuid/relays/$channel';

  // Macros
  static const String macroExecute = '$prefix/macros/execute';
  static String macroStatus(int id) => '$prefix/macros/$id/status';

  // === ESTADOS (Subscribe) ===

  static const String statesAll = '$prefix/states/+';
  static String deviceState(String deviceId) =>
      '$prefix/states/devices/$deviceId';
  static String relayState(String deviceId, int channel) =>
      '$prefix/states/relays/$deviceId/$channel';

  // === CONFIGURAÇÃO (Subscribe) ===

  static const String configUpdate = '$prefix/config/update';
  static const String configTheme = '$prefix/config/theme';
  static const String configScreens = '$prefix/config/screens';

  // === EVENTOS DE SEGURANÇA (Subscribe) ===

  static const String safetyAll = '$prefix/safety/+';
  static const String safetyShutoff = '$prefix/safety/shutoff';
  static const String safetyTimeout = '$prefix/safety/timeout';
  static const String emergencyStop = '$prefix/safety/emergency';

  // === SISTEMA ===

  static const String systemOnline = '$prefix/system/online';
  static const String systemOffline = '$prefix/system/offline';
  static const String systemHeartbeat = '$prefix/system/heartbeat';

  // Will Messages (Last Will and Testament)
  static const String willTopic = '$prefix/clients/$clientId/status';
  static const String willMessageOffline = 'offline';
  static const String willMessageOnline = 'online';
}
