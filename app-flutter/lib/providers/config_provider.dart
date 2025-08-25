import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/infrastructure/services/config_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para o ConfigService
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService.instance;
});

/// Provider para buscar configuração completa
final configFullProvider = FutureProvider.family<ConfigFullResponse, String>((
  ref,
  deviceUuid,
) async {
  final configService = ref.watch(configServiceProvider);
  return configService.getFullConfig(deviceUuid: deviceUuid);
});

/// Provider para forçar refresh da configuração
final configRefreshProvider = FutureProvider.family<ConfigFullResponse, String>(
  (ref, deviceUuid) async {
    final configService = ref.watch(configServiceProvider);
    return configService.refreshConfig(deviceUuid: deviceUuid);
  },
);

/// Provider para informações do cache da configuração
final configCacheInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final configService = ref.watch(configServiceProvider);
  return configService.getCacheInfo();
});

/// Provider para limpar cache
final configClearCacheProvider = FutureProvider<void>((ref) async {
  final configService = ref.watch(configServiceProvider);
  await configService.clearCache();

  // Invalida outros providers relacionados à configuração
  ref.invalidateSelf();
});

/// StateNotifier para gerenciar estado da configuração
class ConfigNotifier extends StateNotifier<AsyncValue<ConfigFullResponse?>> {
  ConfigNotifier(this._configService) : super(const AsyncValue.data(null));

  final ConfigService _configService;
  String? _currentDeviceUuid;

  /// Carrega configuração para um dispositivo
  Future<void> loadConfig(String deviceUuid) async {
    if (_currentDeviceUuid == deviceUuid &&
        state.hasValue &&
        state.value != null) {
      return; // Já carregado para este dispositivo
    }

    state = const AsyncValue.loading();
    _currentDeviceUuid = deviceUuid;

    try {
      final config = await _configService.getFullConfig(deviceUuid: deviceUuid);
      state = AsyncValue.data(config);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Atualiza configuração forçadamente
  Future<void> refresh() async {
    if (_currentDeviceUuid == null) return;

    state = const AsyncValue.loading();

    try {
      final config = await _configService.refreshConfig(
        deviceUuid: _currentDeviceUuid!,
      );
      state = AsyncValue.data(config);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Limpa configuração atual
  void clear() {
    state = const AsyncValue.data(null);
    _currentDeviceUuid = null;
  }

  /// Limpa cache e recarrega
  Future<void> clearCacheAndReload() async {
    await _configService.clearCache();
    if (_currentDeviceUuid != null) {
      await loadConfig(_currentDeviceUuid!);
    }
  }
}

/// Provider para o ConfigNotifier
final configNotifierProvider =
    StateNotifierProvider<ConfigNotifier, AsyncValue<ConfigFullResponse?>>((
      ref,
    ) {
      final configService = ref.watch(configServiceProvider);
      return ConfigNotifier(configService);
    });

/// Provider para obter configuração atual de forma síncrona
final currentConfigProvider = Provider<ConfigFullResponse?>((ref) {
  final configState = ref.watch(configNotifierProvider);
  return configState.valueOrNull;
});

/// Provider para verificar se tem configuração carregada
final hasConfigProvider = Provider<bool>((ref) {
  final config = ref.watch(currentConfigProvider);
  return config != null;
});

/// Provider para device info atual
final currentDeviceInfoProvider = Provider((ref) {
  final config = ref.watch(currentConfigProvider);
  return config?.deviceInfo;
});

/// Provider para tema atual
final currentThemeProvider = Provider((ref) {
  final config = ref.watch(currentConfigProvider);
  return config?.theme;
});

/// Provider para telas configuradas
final configuredScreensProvider = Provider((ref) {
  final config = ref.watch(currentConfigProvider);
  return config?.screens ?? [];
});

/// Provider para placas de relé configuradas
final configuredRelayBoardsProvider = Provider((ref) {
  final config = ref.watch(currentConfigProvider);
  return config?.relayBoards ?? [];
});

/// Provider para configurações do sistema
final systemConfigProvider = Provider((ref) {
  final config = ref.watch(currentConfigProvider);
  return config?.systemConfig;
});
