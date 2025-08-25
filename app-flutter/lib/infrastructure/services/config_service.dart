import 'dart:convert';

import 'package:autocore_app/core/constants/api_endpoints.dart';
import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/domain/models/app_config.dart';
import 'package:autocore_app/infrastructure/services/device_registration_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static ConfigService? _instance;
  static ConfigService get instance => _instance ??= ConfigService._internal();

  ConfigService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  late final Dio _dio;
  final String _cacheKey = 'config_full_cache';
  final String _cacheTimestampKey = 'config_cache_timestamp';
  final int _cacheDurationMs = 300000; // 5 minutos

  ConfigFullResponse? _cachedConfig;
  DateTime? _lastFetch;

  /// Busca configuração completa da API com cache inteligente e auto-registro
  Future<ConfigFullResponse> getFullConfig({
    required String deviceUuid,
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro, exceto se forceRefresh
      if (!forceRefresh && _cachedConfig != null && _isCacheValid()) {
        AppLogger.config('Usando configuração do cache');
        return _cachedConfig!;
      }

      AppLogger.config('Buscando configuração da API para device: $deviceUuid');

      // Primeira tentativa: buscar configuração
      try {
        AppLogger.debug(
          'Chamando endpoint: ${ApiEndpoints.configFull(deviceUuid)}',
        );

        final response = await _dio.get<dynamic>(
          ApiEndpoints.configFull(deviceUuid),
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            validateStatus: (status) => status == 200 || status == 404,
          ),
        );

        AppLogger.debug('Response status: ${response.statusCode}');
        AppLogger.debug('Response data type: ${response.data?.runtimeType}');
        AppLogger.debug('Response data: ${response.data}');

        if (response.statusCode == 200 && response.data != null) {
          // Garantir que response.data é um Map
          final Map<String, dynamic> responseData;
          if (response.data is Map<String, dynamic>) {
            responseData = response.data as Map<String, dynamic>;
          } else if (response.data is String) {
            // Se for string, tentar fazer parse JSON
            try {
              responseData =
                  jsonDecode(response.data as String) as Map<String, dynamic>;
            } catch (e) {
              throw Exception('Erro ao fazer parse JSON: $e');
            }
          } else {
            throw Exception(
              'Formato de resposta inválido: ${response.data.runtimeType}',
            );
          }

          // Tentar criar ConfigFullResponse com tratamento de erro
          ConfigFullResponse configData;
          try {
            // Ajustar estrutura da resposta para o formato esperado
            final adjustedData = _adjustResponseFormat(responseData);
            configData = ConfigFullResponse.fromJson(adjustedData);
          } catch (parseError, stack) {
            AppLogger.error('Erro ao fazer parse da configuração: $parseError');
            AppLogger.debug('Stack trace: $stack');
            AppLogger.debug('Dados recebidos: ${responseData.keys.toList()}');
            throw Exception('Erro ao processar configuração: $parseError');
          }

          // Salva no cache
          await _saveToCache(configData);
          _cachedConfig = configData;
          _lastFetch = DateTime.now();

          AppLogger.config('✅ Configuração carregada e salva no cache');
          return configData;
        } else if (response.statusCode == 404) {
          AppLogger.warning(
            '⚠️ Configuração não encontrada (404) - tentando auto-registro',
          );

          // Tenta fazer auto-registro
          final registrationService = DeviceRegistrationService.instance;
          final registrationSuccess = await registrationService.registerDevice(
            deviceUuid,
          );

          if (registrationSuccess) {
            AppLogger.info(
              '✅ Auto-registro concluído, tentando buscar config novamente',
            );

            // Segunda tentativa após registro
            final retryResponse = await _dio.get<dynamic>(
              ApiEndpoints.configFull(deviceUuid),
              options: Options(
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

            if (retryResponse.statusCode == 200 && retryResponse.data != null) {
              // Garantir que response.data é um Map
              final Map<String, dynamic> responseData;
              if (retryResponse.data is Map<String, dynamic>) {
                responseData = retryResponse.data as Map<String, dynamic>;
              } else {
                throw Exception(
                  'Formato de resposta inválido: ${retryResponse.data.runtimeType}',
                );
              }

              // Tentar criar ConfigFullResponse com tratamento de erro
              ConfigFullResponse configData;
              try {
                // Ajustar estrutura da resposta para o formato esperado
                final adjustedData = _adjustResponseFormat(responseData);
                configData = ConfigFullResponse.fromJson(adjustedData);
              } catch (parseError, stack) {
                AppLogger.error(
                  'Erro ao fazer parse da configuração: $parseError',
                );
                AppLogger.debug('Stack trace: $stack');
                AppLogger.debug(
                  'Dados recebidos: ${responseData.keys.toList()}',
                );
                throw Exception('Erro ao processar configuração: $parseError');
              }

              // Salva no cache
              await _saveToCache(configData);
              _cachedConfig = configData;
              _lastFetch = DateTime.now();

              AppLogger.config('✅ Configuração carregada após auto-registro');
              return configData;
            } else {
              throw Exception(
                'Falha ao buscar configuração após registro: ${retryResponse.statusCode}',
              );
            }
          } else {
            throw Exception('Falha no auto-registro do dispositivo');
          }
        } else {
          throw Exception('Resposta inesperada: ${response.statusCode}');
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          AppLogger.warning(
            '⚠️ Configuração não encontrada (404) via DioException - tentando auto-registro',
          );

          // Tenta fazer auto-registro
          final registrationService = DeviceRegistrationService.instance;
          final registrationSuccess = await registrationService.registerDevice(
            deviceUuid,
          );

          if (registrationSuccess) {
            AppLogger.info(
              '✅ Auto-registro concluído, tentando buscar config novamente',
            );

            // Segunda tentativa após registro
            final retryResponse = await _dio.get<dynamic>(
              ApiEndpoints.configFull(deviceUuid),
              options: Options(
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

            if (retryResponse.statusCode == 200 && retryResponse.data != null) {
              // Garantir que response.data é um Map
              final Map<String, dynamic> responseData;
              if (retryResponse.data is Map<String, dynamic>) {
                responseData = retryResponse.data as Map<String, dynamic>;
              } else {
                throw Exception(
                  'Formato de resposta inválido: ${retryResponse.data.runtimeType}',
                );
              }

              // Tentar criar ConfigFullResponse com tratamento de erro
              ConfigFullResponse configData;
              try {
                // Ajustar estrutura da resposta para o formato esperado
                final adjustedData = _adjustResponseFormat(responseData);
                configData = ConfigFullResponse.fromJson(adjustedData);
              } catch (parseError, stack) {
                AppLogger.error(
                  'Erro ao fazer parse da configuração: $parseError',
                );
                AppLogger.debug('Stack trace: $stack');
                AppLogger.debug(
                  'Dados recebidos: ${responseData.keys.toList()}',
                );
                throw Exception('Erro ao processar configuração: $parseError');
              }

              // Salva no cache
              await _saveToCache(configData);
              _cachedConfig = configData;
              _lastFetch = DateTime.now();

              AppLogger.config(
                '✅ Configuração carregada após auto-registro (DioException)',
              );
              return configData;
            }
          }
        }
        rethrow; // Re-lança se não conseguiu resolver
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao buscar configuração: $e');

      // Tenta carregar do cache local em caso de erro
      final cachedData = await _loadFromCache();
      if (cachedData != null) {
        AppLogger.config(
          '📦 Usando configuração do cache devido a erro na API',
        );
        _cachedConfig = cachedData;
        return cachedData;
      }

      rethrow;
    }
  }

  /// Ajusta o formato da resposta da API para o modelo esperado
  Map<String, dynamic> _adjustResponseFormat(Map<String, dynamic> response) {
    AppLogger.debug('Ajustando resposta da API para modelo');

    // Extrair device info da resposta
    final device = response['device'] as Map<String, dynamic>? ?? {};

    // Log dos campos do device para debug
    AppLogger.debug('Device fields: ${device.keys.toList()}');

    final deviceInfo = {
      'uuid': device['uuid'] ?? '8e67eb62-57c9-4e11-9772-f7fd7065199f',
      'name': device['name'] ?? 'AutoCore Device',
      // Campos que podem não existir na resposta atual
      'firmware_version': device['firmware_version'] ?? '1.0.0',
      'hardware_version': device['hardware_version'] ?? '1.0.0',
      'ip_address': device['ip_address'] ?? '10.0.10.100',
      'mac_address': device['mac_address'] ?? '00:00:00:00:00:00',
      'mqtt_broker': '10.0.10.100', // Valor fixo conforme configuração
      'mqtt_port': 1883, // Valor fixo conforme configuração
      'mqtt_client_id': device['uuid'] ?? 'autocore_device',
      'api_base_url': 'http://10.0.10.100:8081',
      'device_type': device['type'] ?? 'esp32_display',
      'timezone': 'America/Sao_Paulo',
      'location': null,
    };

    // Extrair system config
    final system = response['system'] as Map<String, dynamic>? ?? {};
    final systemConfig = {
      'telemetry_enabled': system['telemetry_enabled'] ?? true,
      'telemetry_interval': system['telemetry_interval'] ?? 1000,
      'heartbeat_interval': system['heartbeat_interval'] ?? 5000,
      'auto_reconnect': system['auto_reconnect'] ?? true,
      'reconnect_delay': system['reconnect_delay'] ?? 5000,
      'max_reconnect_attempts': system['max_reconnect_attempts'] ?? 10,
      'debug_mode': system['debug_mode'] ?? false,
      'log_level': system['log_level'] ?? 'info',
      'enable_offline_mode': system['enable_offline_mode'] ?? true,
      'cache_duration': system['cache_duration'] ?? 300000,
      'screen_timeout': system['screen_timeout'] ?? 30000,
      'language': system['language'] ?? 'pt-BR',
    };

    // Extrair theme config
    final theme = response['theme'] as Map<String, dynamic>? ?? {};
    final themeConfig = {
      'name': theme['name'] ?? 'Dark Offroad',
      'mode': theme['mode'] ?? 'dark',
      'primary_color': theme['primary_color'] ?? '#FF6B35',
      'primary_variant': theme['primary_variant'] ?? '#E65A2E',
      'secondary_color': theme['secondary_color'] ?? '#F7931E',
      'secondary_variant': theme['secondary_variant'] ?? '#E6881C',
      'background_color': theme['background_color'] ?? '#1A1A1A',
      'surface_color': theme['surface_color'] ?? '#2D2D2D',
      'card_color': theme['card_color'] ?? '#2D2D2D',
      'text_primary': theme['text_primary'] ?? '#FFFFFF',
      'text_secondary': theme['text_secondary'] ?? '#B0B0B0',
      'text_disabled': theme['text_disabled'] ?? '#666666',
      'success_color': theme['success_color'] ?? '#4CAF50',
      'warning_color': theme['warning_color'] ?? '#FFC107',
      'error_color': theme['error_color'] ?? '#F44336',
      'info_color': theme['info_color'] ?? '#2196F3',
      'button_color': theme['button_color'],
      'button_text_color': theme['button_text_color'],
      'switch_active_color': theme['switch_active_color'],
      'switch_inactive_color': theme['switch_inactive_color'],
      'border_color': theme['border_color'],
      'divider_color': theme['divider_color'],
      'gauge_color_ranges': <String>[],
      'default_gauge_color': '#2196F3',
      'font_family': null,
      'font_size_small': 12.0,
      'font_size_medium': 14.0,
      'font_size_large': 16.0,
      'font_size_title': 20.0,
      'border_radius': 8.0,
      'card_elevation': 2.0,
      'button_height': 48.0,
      'animation_duration': 300,
      'enable_animations': true,
    };

    // Processar screens convertendo IDs de int para String e ajustando estrutura
    List<Map<String, dynamic>> adjustedScreens = [];
    final screens = response['screens'] as List<dynamic>? ?? [];

    for (final screen in screens) {
      if (screen is Map<String, dynamic>) {
        AppLogger.debug('Processando screen: ${screen['name']}');

        // Ajustar screen items convertendo IDs e estrutura
        List<Map<String, dynamic>> adjustedItems = [];
        final items = screen['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          if (item is Map<String, dynamic>) {
            AppLogger.debug('Processando item: ${item['name']}');

            // Converter estrutura do item da API para o modelo esperado
            final adjustedItem = {
              'id': (item['id'] ?? 0).toString(), // Converter int para String
              'type': _mapItemType(
                (item['item_type'] ?? 'button') as String,
              ), // Mapear tipo
              'title': item['label'] ?? item['name'] ?? 'Item', // label ou name
              'position': _createPosition(
                item,
              ), // Criar posição baseada nos dados
              'enabled': item['is_visible'] ?? true,
              'visible': item['is_visible'] ?? true,
              'background_color':
                  (item['custom_colors']
                          as Map<String, dynamic>?)?['background']
                      as String?,
              'text_color':
                  (item['custom_colors'] as Map<String, dynamic>?)?['text']
                      as String?,
              'border_color':
                  (item['custom_colors'] as Map<String, dynamic>?)?['border']
                      as String?,
              'icon': item['icon'],
              'action': item['action_type'],
              'command': item['action_target'] as String?,
              'payload': _parsePayload(item['action_payload'] as String?),
              'is_momentary': _isMomentary(
                (item['relay_channel']
                        as Map<String, dynamic>?)?['function_type']
                    as String?,
              ),
              'hold_duration':
                  (item['relay_channel']
                          as Map<String, dynamic>?)?['max_activation_time']
                      as int?,
              'telemetry_key': item['value_source'],
              'unit': item['unit'],
              'min_value': _parseDouble(item['min_value']),
              'max_value': _parseDouble(item['max_value']),
              'decimal_places': 0,
              'color_ranges': item['color_ranges'],
              'switch_command_on': null,
              'switch_command_off': null,
              'switch_payload_on': null,
              'switch_payload_off': null,
              'initial_state': false,
            };

            adjustedItems.add(adjustedItem);
          }
        }

        // Ajustar screen principal
        final adjustedScreen = {
          'id': (screen['id'] ?? 0).toString(), // Converter int para String
          'name': screen['name'] ?? 'screen',
          'title': screen['title'] ?? 'Tela',
          'order': screen['position'] ?? 0,
          'enabled': screen['is_visible'] ?? true,
          'icon': screen['icon'],
          'route': '/${screen['name'] ?? 'screen'}',
          'items': adjustedItems,
          'refresh_interval': null,
          'requires_authentication': false,
          'background_color': null,
          'text_color': null,
          'layout_type': 'grid',
          'columns': screen['columns_mobile'] ?? 2,
        };

        adjustedScreens.add(adjustedScreen);
      }
    }

    // Processar relay boards
    List<Map<String, dynamic>> adjustedRelayBoards = [];
    final relayBoards = response['relay_boards'] as List<dynamic>? ?? [];

    for (final board in relayBoards) {
      if (board is Map<String, dynamic>) {
        // Ajustar estrutura de relay board da API para o modelo
        final adjustedBoard = {
          'board_id': (board['id'] ?? 0).toString(),
          'name': board['board_model'] ?? 'Relay Board',
          'type': 'relay',
          'address': board['device_uuid'] ?? '',
          'enabled': board['is_active'] ?? true,
          'channels':
              <
                Map<String, dynamic>
              >[], // Vazio por enquanto, seria necessário buscar de outro endpoint
          'firmware_version': null,
          'ip_address': null,
          'port': null,
          'timeout': 5000,
          'retry_attempts': 3,
          'last_heartbeat': null,
          'status': 'unknown',
        };
        adjustedRelayBoards.add(adjustedBoard);
      }
    }

    // Parse timestamp para DateTime
    final timestampStr =
        response['timestamp'] as String? ?? DateTime.now().toIso8601String();
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    final adjustedData = {
      'device_info': deviceInfo,
      'system_config': systemConfig,
      'screens': adjustedScreens,
      'relay_boards': adjustedRelayBoards,
      'theme': themeConfig,
      'last_updated': timestamp.toIso8601String(),
      'config_version': response['version'] ?? '2.0.0',
    };

    AppLogger.debug(
      'Dados ajustados com sucesso - ${adjustedScreens.length} telas processadas',
    );
    return adjustedData;
  }

  /// Mapeia o tipo de item da API para o modelo Flutter
  String _mapItemType(String apiType) {
    switch (apiType) {
      case 'button':
        return 'button';
      case 'switch':
        return 'switch';
      case 'display':
        return 'gauge';
      default:
        return 'button';
    }
  }

  /// Cria posição baseada nos dados do item
  Map<String, dynamic> _createPosition(Map<String, dynamic> item) {
    return {'row': 0, 'col': item['position'] ?? 0, 'span_x': 1, 'span_y': 1};
  }

  /// Parse seguro do payload JSON
  Map<String, dynamic>? _parsePayload(String? payloadStr) {
    if (payloadStr == null || payloadStr.isEmpty) return null;

    try {
      final decoded = jsonDecode(payloadStr);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      AppLogger.warning('Erro ao fazer parse do payload: $payloadStr - $e');
      return null;
    }
  }

  /// Verifica se o tipo de função é momentâneo
  bool _isMomentary(String? functionType) {
    return functionType == 'momentary';
  }

  /// Parse seguro de double
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Verifica se o cache ainda é válido
  bool _isCacheValid() {
    if (_lastFetch == null) return false;

    final now = DateTime.now();
    final diff = now.difference(_lastFetch!).inMilliseconds;
    return diff < _cacheDurationMs;
  }

  /// Salva configuração no cache local
  Future<void> _saveToCache(ConfigFullResponse config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(config.toJson());

      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      AppLogger.config('Configuração salva no cache local');
    } catch (e) {
      AppLogger.error('Erro ao salvar cache: $e');
    }
  }

  /// Carrega configuração do cache local
  Future<ConfigFullResponse?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (jsonString != null && timestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

        // Verifica se o cache não está muito antigo (máximo 1 hora offline)
        if (cacheAge < 3600000) {
          final jsonData = json.decode(jsonString) as Map<String, dynamic>;
          _lastFetch = DateTime.fromMillisecondsSinceEpoch(timestamp);

          AppLogger.config('Configuração carregada do cache local');
          return ConfigFullResponse.fromJson(jsonData);
        }
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar cache: $e');
    }

    return null;
  }

  /// Limpa o cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);

      _cachedConfig = null;
      _lastFetch = null;

      AppLogger.config('Cache de configuração limpo');
    } catch (e) {
      AppLogger.error('Erro ao limpar cache: $e');
    }
  }

  /// Atualiza a configuração forçadamente
  Future<ConfigFullResponse> refreshConfig({required String deviceUuid}) async {
    return getFullConfig(deviceUuid: deviceUuid, forceRefresh: true);
  }

  /// Retorna informações do cache
  Map<String, dynamic> getCacheInfo() {
    return {
      'has_cache': _cachedConfig != null,
      'last_fetch': _lastFetch?.toIso8601String(),
      'cache_valid': _isCacheValid(),
      'cache_age_minutes': _lastFetch != null
          ? DateTime.now().difference(_lastFetch!).inMinutes
          : null,
    };
  }

  /// Pré-carrega a configuração
  Future<void> preloadConfig({required String deviceUuid}) async {
    try {
      await getFullConfig(deviceUuid: deviceUuid);
      AppLogger.config('Configuração pré-carregada com sucesso');
    } catch (e) {
      AppLogger.error('Erro ao pré-carregar configuração: $e');
    }
  }

  /// Atualiza configurações do serviço
  void updateConfig(AppConfig config) {
    AppLogger.info('Atualizando configurações do ConfigService');

    final newBaseUrl =
        '${config.apiUseHttps ? 'https' : 'http'}://${config.apiHost}:${config.apiPort}';

    // Recria o Dio com nova configuração
    _dio = Dio(
      BaseOptions(
        baseUrl: newBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Re-adiciona interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.network(
            'Config Request: ${options.method} ${options.path}',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.network('Config Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error('Config Error: ${error.message}', error: error);
          handler.next(error);
        },
      ),
    );

    // Limpa cache quando muda configuração
    clearCache();

    AppLogger.info('ConfigService configurado com novo baseUrl: $newBaseUrl');
  }
}
