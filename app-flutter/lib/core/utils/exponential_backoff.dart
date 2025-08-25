/// Utilitário para retry com backoff exponencial
/// Implementado como parte do A41 - TODO Implementation
library;

import 'package:autocore_app/core/utils/logger.dart';

/// Classe para implementar retry com backoff exponencial
class ExponentialBackoff {
  /// Executa operação com retry automático e backoff exponencial
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double multiplier = 2.0,
    Duration? maxDelay,
    bool Function(Object error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    final effectiveMaxDelay = maxDelay ?? const Duration(minutes: 5);
    
    while (attempt < maxAttempts) {
      try {
        AppLogger.info('Executando operação - tentativa ${attempt + 1}/$maxAttempts');
        return await operation();
      } catch (error) {
        attempt++;
        
        // Se chegou ao máximo de tentativas, relança o erro
        if (attempt >= maxAttempts) {
          AppLogger.error(
            'Máximo de tentativas ($maxAttempts) atingido, falhando',
            error: error,
          );
          rethrow;
        }
        
        // Verifica se deve fazer retry baseado no tipo do erro
        if (shouldRetry != null && !shouldRetry(error)) {
          AppLogger.warning('Erro não recuperável detectado, parando retry');
          rethrow;
        }
        
        AppLogger.warning(
          'Tentativa $attempt falhou, retry em ${delay.inSeconds}s',
          error: error,
        );
        
        // Aguarda o delay antes do próximo retry
        await Future<void>.delayed(delay);
        
        // Calcula próximo delay com backoff exponencial
        final nextDelay = Duration(
          milliseconds: (delay.inMilliseconds * multiplier).round(),
        );
        
        // Limita o delay máximo
        delay = nextDelay > effectiveMaxDelay ? effectiveMaxDelay : nextDelay;
      }
    }
    
    // Esta linha nunca deveria ser alcançada, mas é necessária para o compilador
    throw StateError('Código não deveria chegar aqui');
  }
  
  /// Versão simplificada para operações HTTP/Network
  static Future<T> retryNetwork<T>(
    Future<T> Function() operation, {
    int maxAttempts = 5,
  }) async {
    return retry<T>(
      operation,
      maxAttempts: maxAttempts,
      initialDelay: const Duration(milliseconds: 500),
      multiplier: 1.5,
      maxDelay: const Duration(seconds: 30),
      shouldRetry: (error) {
        // Retry apenas para erros de rede, timeout, etc
        final errorString = error.toString().toLowerCase();
        return errorString.contains('timeout') ||
            errorString.contains('connection') ||
            errorString.contains('network') ||
            errorString.contains('socket');
      },
    );
  }
  
  /// Versão simplificada para operações MQTT
  static Future<T> retryMqtt<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
  }) async {
    return retry<T>(
      operation,
      maxAttempts: maxAttempts,
      initialDelay: const Duration(milliseconds: 200),
      multiplier: 2.0,
      maxDelay: const Duration(seconds: 10),
      shouldRetry: (error) {
        // Retry para erros de conexão MQTT
        final errorString = error.toString().toLowerCase();
        return errorString.contains('mqtt') ||
            errorString.contains('connection') ||
            errorString.contains('disconnected') ||
            errorString.contains('timeout');
      },
    );
  }
}