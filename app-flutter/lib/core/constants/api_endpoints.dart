/// Endpoints da API do AutoCore
class ApiEndpoints {
  ApiEndpoints._();

  // Base URLs - usando IP padrão da documentação
  static const String baseUrl = 'http://10.0.10.100:8081';
  static const String wsUrl = 'ws://10.0.10.100:8081/ws';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Configuration - endpoint principal do novo sistema
  static String configFull(String deviceUuid) =>
      '/api/config/full?device_uuid=$deviceUuid';
  static const String configFullPreview = '/api/config/full?preview=true';
  static String configGenerate(String deviceUuid) =>
      '/api/config/generate?device_uuid=$deviceUuid';

  // Devices
  static const String devices = '/api/devices';
  static String device(String uuid) => '/api/devices/$uuid';
  static String deviceByUuid(String uuid) => '/api/devices/uuid/$uuid';
  static String deviceUpdate(String uuid) => '/api/devices/$uuid';
  static String deviceStatus(String uuid) => '/api/devices/$uuid/status';
  static String deviceRelays(String uuid) => '/api/devices/$uuid/relays';

  // Commands
  static const String executeCommand = '/api/commands/execute';
  static String relayCommand(String deviceUuid) =>
      '/api/devices/$deviceUuid/relays';

  // System
  static const String health = '/api/health';
  static const String version = '/api/version';
  static const String status = '/api/status';
  static const String systemInfo = '/api/system/info';

  // MQTT Configuration
  static const String mqttConfig = '/api/mqtt/config';

  // Legacy endpoints (deprecated)
  @Deprecated('Use configFull instead')
  static const String config = '/api/config';
  @Deprecated('Use configFull instead')
  static const String screens = '/api/screens';
  @Deprecated('Use configFull instead')
  static String screen(String id) => '/api/screens/$id';
  @Deprecated('Use configFull instead')
  static String screenItems(int screenId) => '/api/screens/$screenId/items';

  // Macros (legacy)
  @Deprecated('Use configFull instead')
  static const String macros = '/api/macros';
  @Deprecated('Use configFull instead')
  static String macro(int id) => '/api/macros/$id';
  @Deprecated('Use configFull instead')
  static String executeMacro(int id) => '/api/macros/$id/execute';
}
