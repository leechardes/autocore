/// Use Case para buscar configuração do dispositivo
library;

import 'package:autocore_app/core/constants/device_constants.dart';
import 'package:autocore_app/core/exceptions/app_exceptions.dart';
import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/core/types/result.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/infrastructure/repositories/config_repository.dart';

/// Use Case para buscar configuração do dispositivo
class GetDeviceConfigUseCase {
  GetDeviceConfigUseCase(this._configRepository);

  final ConfigRepository _configRepository;

  /// Executa busca da configuração com retry e cache
  Future<Result<ConfigFullResponse>> execute({
    String? deviceUuid,
    bool forceRefresh = false,
  }) async {
    final uuid = deviceUuid ?? DeviceConstants.deviceUuid;

    AppLogger.info('Executando GetDeviceConfig para device: $uuid');

    // Validação de entrada
    if (uuid.isEmpty) {
      const error = ValidationException(
        'Device UUID é obrigatório',
        errors: {'deviceUuid': 'UUID não pode estar vazio'},
      );
      return const Failure(error);
    }

    try {
      // Se não é refresh forçado, tenta cache primeiro
      if (!forceRefresh) {
        final cachedResult = await _configRepository.getCached();
        if (cachedResult.isSuccess && cachedResult.dataOrNull != null) {
          AppLogger.info('Configuração obtida do cache');
          return Success(cachedResult.dataOrNull!);
        }
      }

      // Busca da API com retry
      return await _executeWithRetry(uuid);
    } catch (e) {
      final error = ParseException(
        'Erro inesperado ao buscar configuração: $e',
      );
      AppLogger.error('Erro no GetDeviceConfigUseCase', error: error);
      return Failure(error);
    }
  }

  /// Executa busca com retry automático
  Future<Result<ConfigFullResponse>> _executeWithRetry(
    String deviceUuid, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    AppException? lastError;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      AppLogger.info('Tentativa $attempt de $maxRetries');

      final result = await _configRepository.getFullConfig(deviceUuid);

      if (result.isSuccess) {
        AppLogger.info('Configuração obtida com sucesso na tentativa $attempt');
        return result;
      }

      lastError = result.errorOrNull;

      // Se é erro de validação ou configuração, não retry
      if (lastError is ValidationException ||
          lastError is ConfigurationException) {
        break;
      }

      // Se não é última tentativa, aguarda antes do retry
      if (attempt < maxRetries) {
        AppLogger.warning(
          'Falha na tentativa $attempt, retry em ${retryDelay.inSeconds}s',
        );
        await Future<void>.delayed(retryDelay);
      }
    }

    // Se chegou aqui, todas as tentativas falharam
    final finalError = TimeoutException(
      'Falha ao buscar configuração após $maxRetries tentativas. Último erro: ${lastError?.message}',
      duration: Duration(seconds: retryDelay.inSeconds * maxRetries),
    );

    AppLogger.error('Todas as tentativas de busca falharam', error: finalError);
    return Failure(finalError);
  }
}

/// Use Case para atualizar configuração
class UpdateDeviceConfigUseCase {
  UpdateDeviceConfigUseCase(this._configRepository);

  final ConfigRepository _configRepository;

  /// Executa atualização da configuração
  Future<Result<bool>> execute({
    required String deviceUuid,
    required Map<String, dynamic> config,
  }) async {
    AppLogger.info('Executando UpdateDeviceConfig para device: $deviceUuid');

    // Validação de entrada
    if (deviceUuid.isEmpty) {
      const error = ValidationException(
        'Device UUID é obrigatório',
        errors: {'deviceUuid': 'UUID não pode estar vazio'},
      );
      return const Failure(error);
    }

    if (config.isEmpty) {
      const error = ValidationException(
        'Configuração não pode estar vazia',
        errors: {'config': 'Dados de configuração são obrigatórios'},
      );
      return const Failure(error);
    }

    try {
      // Executa update
      final result = await _configRepository.updateConfig(deviceUuid, config);

      if (result.isSuccess) {
        AppLogger.info('Configuração atualizada com sucesso');
      } else {
        AppLogger.error(
          'Falha ao atualizar configuração',
          error: result.errorOrNull,
        );
      }

      return result;
    } catch (e) {
      final error = ParseException(
        'Erro inesperado ao atualizar configuração: $e',
      );
      AppLogger.error('Erro no UpdateDeviceConfigUseCase', error: error);
      return Failure(error);
    }
  }
}
