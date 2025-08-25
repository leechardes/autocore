/// Repository para operações de configuração
library;

import 'package:autocore_app/core/exceptions/app_exceptions.dart';
import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/core/repositories/base_repository.dart';
import 'package:autocore_app/core/types/result.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/domain/models/app_config.dart';
import 'package:autocore_app/infrastructure/services/api_service.dart';
import 'package:dio/dio.dart';

/// Repository abstrato para configurações
abstract class ConfigRepository extends CachedRepository<ConfigFullResponse> {
  Future<Result<ConfigFullResponse>> getFullConfig(String deviceUuid);
  Future<Result<bool>> updateConfig(
    String deviceUuid,
    Map<String, dynamic> config,
  );
  Future<Result<AppConfig>> getAppConfig();
}

/// Implementação do ConfigRepository usando API
class ApiConfigRepository implements ConfigRepository {
  ApiConfigRepository(this._apiService);

  final ApiService _apiService;
  ConfigFullResponse? _cachedConfig;
  DateTime? _lastCacheTime;

  static const Duration _cacheTimeout = Duration(minutes: 5);

  @override
  Future<Result<ConfigFullResponse>> getFullConfig(String deviceUuid) async {
    try {
      // Verifica cache primeiro
      if (_isCacheValid()) {
        AppLogger.info('Retornando configuração do cache');
        return Success(_cachedConfig!);
      }

      AppLogger.info('Buscando configuração da API para device: $deviceUuid');
      final config = await _apiService.getFullConfig(deviceUuid);

      // Salva no cache
      await saveToCache(config);

      return Success(config);
    } on DioException catch (e) {
      final exception = _mapDioError(e, deviceUuid);
      AppLogger.error('Erro ao buscar configuração', error: exception);
      return Failure(exception);
    } catch (e) {
      final exception = NetworkException(
        'Erro inesperado ao buscar configuração: $e',
        endpoint: '/config/$deviceUuid',
      );
      AppLogger.error('Erro inesperado', error: exception);
      return Failure(exception);
    }
  }

  @override
  Future<Result<bool>> updateConfig(
    String deviceUuid,
    Map<String, dynamic> config,
  ) async {
    try {
      AppLogger.info('Atualizando configuração do device: $deviceUuid');
      final success = await _apiService.updateDevice(deviceUuid, config);

      if (success) {
        // Invalida cache após update
        await clearCache();
        AppLogger.info('Configuração atualizada com sucesso');
        return const Success(true);
      } else {
        return const Failure(
          NetworkException('Falha ao atualizar configuração'),
        );
      }
    } on DioException catch (e) {
      final exception = _mapDioError(e, deviceUuid);
      AppLogger.error('Erro ao atualizar configuração', error: exception);
      return Failure(exception);
    } catch (e) {
      final exception = NetworkException(
        'Erro inesperado ao atualizar configuração: $e',
        endpoint: '/device/$deviceUuid',
      );
      return Failure(exception);
    }
  }

  @override
  Future<Result<AppConfig>> getAppConfig() async {
    // Busca configuração geral da aplicação
    final configResult = await getFullConfig('default');

    return configResult.map((config) {
      return const AppConfig(
        apiHost: '10.0.10.100',
        apiPort: 8081,
        apiUseHttps: false,
        autoConnect: true,
        connectionTimeout: 5000,
        maxRetries: 3,
        enableHeartbeat: true,
        heartbeatInterval: 500,
        heartbeatTimeout: 1000,
      );
    });
  }

  @override
  Future<Result<ConfigFullResponse>> refresh() async {
    await clearCache();
    // Needs deviceUuid - this is a simplified version
    return const Failure(
      ConfigurationException('Device UUID required for refresh'),
    );
  }

  @override
  Future<Result<ConfigFullResponse?>> getCached() async {
    if (_isCacheValid()) {
      return Success(_cachedConfig);
    }
    return const Success(null);
  }

  @override
  Future<void> saveToCache(ConfigFullResponse data) async {
    _cachedConfig = data;
    _lastCacheTime = DateTime.now();
    AppLogger.info('Configuração salva no cache');
  }

  @override
  Future<void> clearCache() async {
    _cachedConfig = null;
    _lastCacheTime = null;
    AppLogger.info('Cache de configuração limpo');
  }

  @override
  Future<bool> isOnline() async {
    try {
      // Simple ping to check connectivity
      await _apiService.getSystemStatus();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isCacheValid() {
    return _cachedConfig != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheTimeout;
  }

  NetworkException _mapDioError(DioException error, String context) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data != null 
        ? (error.response!.data as Map<String, dynamic>)['message'] as String? ?? error.message
        : error.message;

    return NetworkException(
      'Erro de rede: $message',
      statusCode: statusCode,
      endpoint: error.requestOptions.path,
      code: 'CONFIG_ERROR_$statusCode',
    );
  }
}
