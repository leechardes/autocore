import 'package:autocore_app/core/models/screen_config.dart';
import 'package:autocore_app/features/config/services/config_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para o serviço de configuração
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService.instance;
});

// Provider para a configuração atual do app
final configProvider = StateNotifierProvider<ConfigNotifier, AppConfig?>((ref) {
  final service = ref.watch(configServiceProvider);
  return ConfigNotifier(service);
});

// StateNotifier para gerenciar o estado da configuração
class ConfigNotifier extends StateNotifier<AppConfig?> {
  final ConfigService _service;

  ConfigNotifier(this._service) : super(null) {
    _loadInitialConfig();
  }

  Future<void> _loadInitialConfig() async {
    try {
      // Tenta carregar da configuração local primeiro
      await _service.loadConfig();
      state = _service.currentConfig;
    } catch (e) {
      // Se falhar, cria uma configuração padrão mínima
      state = _createDefaultConfig();
    }
  }

  Future<void> loadFromUrl(String url) async {
    await _service.loadConfigFromUrl(url);
    state = _service.currentConfig;
  }

  Future<void> loadFromAsset() async {
    await _service.loadDefaultConfig();
    state = _service.currentConfig;
  }

  void updateConfig(AppConfig config) {
    state = config;
  }

  AppConfig _createDefaultConfig() {
    return const AppConfig(
      version: '1.0.0',
      screens: [
        ScreenConfig(
          id: 'home',
          name: 'Home',
          icon: 'home',
          route: '/',
          layout: ScreenLayout(),
          widgets: [],
        ),
      ],
      devices: {},
    );
  }
}

// Provider para tela específica
final screenConfigProvider = Provider.family<ScreenConfig?, String>((
  ref,
  route,
) {
  final config = ref.watch(configProvider);
  if (config == null) return null;

  try {
    return config.screens.firstWhere((s) => s.route == route);
  } catch (e) {
    return null;
  }
});

// Provider para dispositivos
final devicesProvider = Provider<Map<String, DeviceConfig>>((ref) {
  final config = ref.watch(configProvider);
  return config?.devices ?? {};
});

// Provider para dispositivo específico
final deviceProvider = Provider.family<DeviceConfig?, String>((ref, deviceId) {
  final devices = ref.watch(devicesProvider);
  return devices[deviceId];
});

// Provider para tema
final themeConfigProvider = Provider<ThemeConfig?>((ref) {
  final config = ref.watch(configProvider);
  return config?.theme;
});

// Provider para configurações MQTT
final mqttConfigProvider = Provider<MqttConfig?>((ref) {
  final config = ref.watch(configProvider);
  return config?.mqtt;
});
