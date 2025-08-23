# A16 - Config Service Implementation

## 📋 Objetivo
Implementar o ConfigService completo para consumir o endpoint `/api/config/full/{device_uuid}` e gerenciar configuração do app.

## 🎯 Service a Implementar

### ConfigService Principal
```dart
// lib/infrastructure/services/config_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:autocore_app/core/constants/api_endpoints.dart';
import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/infrastructure/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static ConfigService? _instance;
  static ConfigService get instance => _instance ??= ConfigService._();

  ConfigService._();

  final ApiService _apiService = ApiService.instance;
  
  // Estado da configuração
  ConfigFullResponse? _currentConfig;
  final _configController = StreamController<ConfigFullResponse>.broadcast();
  
  // Cache
  static const String _cacheKey = 'config_full_cache';
  static const String _cacheTimestampKey = 'config_cache_timestamp';
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  // Device UUID
  String? _deviceUuid;
  
  // Getters
  ConfigFullResponse? get currentConfig => _currentConfig;
  Stream<ConfigFullResponse> get configStream => _configController.stream;
  bool get hasConfig => _currentConfig != null;
  
  /// Inicializa o serviço com device UUID
  Future<void> initialize({String? deviceUuid}) async {
    try {
      _deviceUuid = deviceUuid ?? await _getOrGenerateDeviceUuid();
      
      // Tentar carregar do cache primeiro
      final cached = await _loadFromCache();
      if (cached != null) {
        _currentConfig = cached;
        _configController.add(cached);
        AppLogger.info('Config loaded from cache');
        
        // Atualizar em background se cache expirado
        if (await _isCacheExpired()) {
          _refreshInBackground();
        }
      } else {
        // Carregar da API se não houver cache
        await refreshConfig();
      }
    } catch (e, stack) {
      AppLogger.error('Failed to initialize ConfigService', 
        error: e, stackTrace: stack);
      
      // Usar configuração padrão como fallback
      _loadDefaultConfig();
    }
  }
  
  /// Busca configuração completa da API
  Future<ConfigFullResponse?> refreshConfig() async {
    try {
      if (_deviceUuid == null) {
        throw Exception('Device UUID not set');
      }
      
      AppLogger.info('Fetching config for device: $_deviceUuid');
      
      final response = await _apiService.dio.get<Map<String, dynamic>>(
        '/api/config/full/$_deviceUuid',
      );
      
      if (response.data != null) {
        final config = ConfigFullResponse.fromJson(response.data!);
        
        // Validar versão do protocolo
        if (!_isProtocolCompatible(config.protocolVersion)) {
          AppLogger.warning('Protocol version mismatch: ${config.protocolVersion}');
        }
        
        // Atualizar estado
        _currentConfig = config;
        _configController.add(config);
        
        // Salvar no cache
        await _saveToCache(config);
        
        AppLogger.info('Config refreshed successfully');
        return config;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.warning('Device not found, using preview mode');
        return await getPreviewConfig();
      }
      AppLogger.error('API error fetching config', error: e);
    } catch (e, stack) {
      AppLogger.error('Failed to refresh config', 
        error: e, stackTrace: stack);
    }
    
    return null;
  }
  
  /// Obtém configuração em modo preview
  Future<ConfigFullResponse?> getPreviewConfig() async {
    try {
      final response = await _apiService.dio.get<Map<String, dynamic>>(
        '/api/config/full',
        queryParameters: {'preview': true},
      );
      
      if (response.data != null) {
        final config = ConfigFullResponse.fromJson(response.data!);
        _currentConfig = config;
        _configController.add(config);
        return config;
      }
    } catch (e, stack) {
      AppLogger.error('Failed to get preview config', 
        error: e, stackTrace: stack);
    }
    
    return null;
  }
  
  /// Obtém telas configuradas
  List<ApiScreenConfig> getScreens() {
    if (_currentConfig == null) return [];
    
    // Filtrar por device type
    final isSmallDisplay = _isSmallDisplay();
    
    return _currentConfig!.screens
        .where((screen) => screen.isVisible)
        .where((screen) => isSmallDisplay 
            ? screen.showOnDisplaySmall 
            : screen.showOnDisplayLarge)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }
  
  /// Obtém tema configurado
  ThemeConfig? getTheme() {
    return _currentConfig?.theme;
  }
  
  /// Obtém telemetria atual
  Map<String, dynamic> getTelemetry() {
    return _currentConfig?.telemetry ?? {};
  }
  
  /// Obtém valor de telemetria específico
  dynamic getTelemetryValue(String key) {
    final parts = key.split('.');
    if (parts.first == 'telemetry' && parts.length > 1) {
      return getTelemetry()[parts[1]];
    }
    return null;
  }
  
  /// Atualiza telemetria local
  void updateTelemetry(Map<String, dynamic> data) {
    if (_currentConfig != null) {
      _currentConfig = _currentConfig!.copyWith(
        telemetry: {...getTelemetry(), ...data},
      );
      _configController.add(_currentConfig!);
    }
  }
  
  /// Obtém informação de relay board
  RelayBoardInfo? getRelayBoard(int boardId) {
    return _currentConfig?.relayBoards
        .firstWhere((board) => board.id == boardId, 
            orElse: () => throw Exception('Board not found'));
  }
  
  /// Verifica se é display pequeno
  bool _isSmallDisplay() {
    // TODO: Implementar detecção real baseada no device
    return false; // Por enquanto assume display grande (mobile)
  }
  
  /// Gera ou recupera UUID do dispositivo
  Future<String> _getOrGenerateDeviceUuid() async {
    final prefs = await SharedPreferences.getInstance();
    
    var uuid = prefs.getString('device_uuid');
    if (uuid == null) {
      // Gerar UUID único para o app
      uuid = 'flutter-app-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_uuid', uuid);
    }
    
    return uuid;
  }
  
  /// Carrega configuração do cache
  Future<ConfigFullResponse?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return ConfigFullResponse.fromJson(json);
      }
    } catch (e) {
      AppLogger.error('Failed to load from cache', error: e);
    }
    
    return null;
  }
  
  /// Salva configuração no cache
  Future<void> _saveToCache(ConfigFullResponse config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(config.toJson());
      
      await prefs.setString(_cacheKey, json);
      await prefs.setInt(_cacheTimestampKey, 
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      AppLogger.error('Failed to save to cache', error: e);
    }
  }
  
  /// Verifica se cache expirou
  Future<bool> _isCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_cacheTimestampKey);
    
    if (timestamp == null) return true;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) > _cacheExpiration;
  }
  
  /// Atualiza config em background
  void _refreshInBackground() {
    Future.delayed(const Duration(seconds: 2), () {
      refreshConfig().then((_) {
        AppLogger.info('Config refreshed in background');
      });
    });
  }
  
  /// Verifica compatibilidade de protocolo
  bool _isProtocolCompatible(String version) {
    // Aceitar versões 2.x.x
    return version.startsWith('2.');
  }
  
  /// Carrega configuração padrão
  void _loadDefaultConfig() {
    // TODO: Implementar config padrão para fallback
    AppLogger.warning('Using default config as fallback');
  }
  
  /// Limpa cache e estado
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
    
    _currentConfig = null;
    _deviceUuid = null;
  }
  
  /// Dispose
  void dispose() {
    _configController.close();
  }
}
```

### ConfigProvider (Riverpod)
```dart
// lib/providers/config_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/infrastructure/services/config_service.dart';

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService.instance;
});

final configProvider = StreamProvider<ConfigFullResponse?>((ref) {
  final service = ref.watch(configServiceProvider);
  return service.configStream;
});

final currentConfigProvider = Provider<ConfigFullResponse?>((ref) {
  final service = ref.watch(configServiceProvider);
  return service.currentConfig;
});

final screensProvider = Provider<List<ApiScreenConfig>>((ref) {
  final service = ref.watch(configServiceProvider);
  return service.getScreens();
});

final themeConfigProvider = Provider<ThemeConfig?>((ref) {
  final service = ref.watch(configServiceProvider);
  return service.getTheme();
});

final telemetryProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(configServiceProvider);
  return service.getTelemetry();
});
```

## ✅ Checklist de Implementação

- [ ] Criar ConfigService com singleton
- [ ] Implementar fetch do endpoint /api/config/full
- [ ] Adicionar cache local com SharedPreferences
- [ ] Implementar fallback para preview mode
- [ ] Adicionar device UUID management
- [ ] Criar stream para updates de config
- [ ] Implementar telemetria updates
- [ ] Adicionar providers Riverpod
- [ ] Tratar erros e edge cases
- [ ] Adicionar logs apropriados

## 🚀 Comandos de Execução

```bash
# 1. Criar arquivo service
touch lib/infrastructure/services/config_service.dart

# 2. Criar providers
touch lib/providers/config_provider.dart

# 3. Atualizar ApiService se necessário
# Verificar se endpoint está configurado

# 4. Testar service
flutter test test/services/config_service_test.dart
```

## 📊 Resultado Esperado

Após implementação:
- ✅ ConfigService singleton funcionando
- ✅ Fetch único de /api/config/full
- ✅ Cache persistente local
- ✅ Fallback para preview mode
- ✅ Stream de updates funcionando
- ✅ Providers Riverpod integrados

---

**Prioridade**: P0 - CRÍTICO
**Tempo estimado**: 3-4 horas
**Dependências**: A15 (Models implementados)