import 'dart:convert';

import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/domain/models/app_config.dart';
import 'package:autocore_app/infrastructure/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppConfig>((
  ref,
) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppConfig> {
  static const String _configKey = 'app_config_settings';

  SettingsNotifier() : super(AppConfig.development()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);

      if (configJson != null) {
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        state = AppConfig(
          apiHost: configMap['apiHost'] as String? ?? '10.0.10.100',
          apiPort: configMap['apiPort'] as int? ?? 8081,
          apiUseHttps: configMap['apiUseHttps'] as bool? ?? false,
          autoConnect: configMap['autoConnect'] as bool? ?? true,
          enableHeartbeat: configMap['enableHeartbeat'] as bool? ?? true,
          heartbeatInterval: configMap['heartbeatInterval'] as int? ?? 500,
          heartbeatTimeout: configMap['heartbeatTimeout'] as int? ?? 1000,
        );
        AppLogger.info('Configurações carregadas do SharedPreferences');
      } else {
        AppLogger.info('Nenhuma configuração salva, usando padrões');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar configurações', error: e);
    }
  }

  void updateConfig(AppConfig config) {
    state = config;
  }

  Future<bool> saveConfig(AppConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final configMap = {
        'apiHost': config.apiHost,
        'apiPort': config.apiPort,
        'apiUseHttps': config.apiUseHttps,
        'autoConnect': config.autoConnect,
        'enableHeartbeat': config.enableHeartbeat,
        'heartbeatInterval': config.heartbeatInterval,
        'heartbeatTimeout': config.heartbeatTimeout,
      };

      final configJson = json.encode(configMap);
      await prefs.setString(_configKey, configJson);

      state = config;

      // Atualizar as configurações nos serviços
      ApiService.instance.updateConfig(config);

      AppLogger.info('Configurações salvas com sucesso');
      return true;
    } catch (e) {
      AppLogger.error('Erro ao salvar configurações', error: e);
      return false;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_configKey);
      state = AppConfig.development();

      // Atualizar as configurações nos serviços
      ApiService.instance.updateConfig(state);

      AppLogger.info('Configurações restauradas aos padrões');
    } catch (e) {
      AppLogger.error('Erro ao resetar configurações', error: e);
    }
  }

  Future<Map<String, bool>> testConnections() async {
    final results = <String, bool>{};

    // Testar API Backend
    try {
      final apiUrl =
          '${state.apiUseHttps ? 'https' : 'http'}://${state.apiHost}:${state.apiPort}/api/health';
      await ApiService.instance.testConnection(apiUrl);
      results['api'] = true;
    } catch (e) {
      AppLogger.error('Teste API falhou', error: e);
      results['api'] = false;
    }

    // Testar Config Service - busca configuração MQTT via API
    try {
      await ApiService.instance.getMqttConfig();
      results['config'] = true;
    } catch (e) {
      AppLogger.error('Teste Config Service falhou', error: e);
      results['config'] = false;
    }

    return results;
  }
}
