/// Constantes do dispositivo Flutter
class DeviceConstants {
  DeviceConstants._();

  /// UUID fixo do dispositivo registrado no backend
  /// Este UUID foi registrado no banco de dados e deve ser usado sempre
  static const String deviceUuid = '8e67eb62-57c9-4e11-9772-f7fd7065199f';

  /// Nome do dispositivo
  static const String deviceName = 'AutoCore Flutter App';

  /// Tipo do dispositivo
  static const String deviceType = 'esp32_display';

  /// Versão do firmware/app
  static const String firmwareVersion = '1.0.0';

  /// Versão do hardware
  static const String hardwareVersion = 'Flutter-v1.0';

  /// Modelo do dispositivo
  static const String deviceModel = 'Flutter Mobile App';

  /// Fabricante
  static const String manufacturer = 'AutoCore';

  /// Localização padrão
  static const String defaultLocation = 'Mobile App';

  /// Chaves de persistência
  static const String deviceUuidKey = 'device_uuid';
  static const String registrationStatusKey = 'device_registered';

  /// Configuração padrão
  static const Map<String, dynamic> defaultConfiguration = {
    'theme': 'dark',
    'language': 'pt-BR',
  };

  /// Capacidades do dispositivo
  static const Map<String, dynamic> capabilities = {
    'has_touch': true,
    'has_wifi': true,
    'resolution': 'responsive',
    'platform': 'flutter',
  };
}
