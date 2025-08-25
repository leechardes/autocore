import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log;

/// Logger centralizado para o AutoCore
///
/// Uso:
/// ```dart
/// AppLogger.info('Mensagem informativa');
/// AppLogger.warning('Aviso importante');
/// AppLogger.error('Erro ocorreu', error: exception, stackTrace: stack);
/// ```
class AppLogger {
  static final _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: log.DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? log.Level.debug : log.Level.info,
  );

  static final _fileLogger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: false,
      printEmojis: false,
      dateTimeFormat: log.DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: kDebugMode ? null : _FileOutput(),
  );

  /// Log de debug (só aparece em modo debug)
  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log informativo
  static void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    _fileLogger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log de aviso
  static void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _fileLogger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log de erro
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _fileLogger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log de erro fatal
  static void fatal(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _fileLogger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log verbose (muito detalhado)
  static void verbose(String message) {
    if (kDebugMode) {
      _logger.t(message);
    }
  }

  /// Log de rede (MQTT, HTTP, etc)
  static void network(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final logMessage = StringBuffer(message);
      if (data != null && data.isNotEmpty) {
        logMessage.write('\n');
        data.forEach((key, value) {
          logMessage.write('  $key: $value\n');
        });
      }
      _logger.d('[NETWORK] $logMessage');
    }
  }

  /// Log de configuração
  static void config(String message, {Map<String, dynamic>? data}) {
    final logMessage = StringBuffer(message);
    if (data != null && data.isNotEmpty) {
      logMessage.write('\n');
      data.forEach((key, value) {
        logMessage.write('  $key: $value\n');
      });
    }
    _logger.i('[CONFIG] $logMessage');
  }

  /// Log de performance
  static void performance(String operation, Duration duration) {
    final milliseconds = duration.inMilliseconds;
    final message = '$operation levou ${milliseconds}ms';

    if (milliseconds > 1000) {
      warning('[PERFORMANCE] $message');
    } else if (milliseconds > 500) {
      info('[PERFORMANCE] $message');
    } else if (kDebugMode) {
      debug('[PERFORMANCE] $message');
    }
  }

  /// Medir tempo de execução
  static Future<T> measureTime<T>(
    String operation,
    Future<T> Function() task,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await task();
      stopwatch.stop();
      performance(operation, stopwatch.elapsed);
      return result;
    } catch (e, stack) {
      stopwatch.stop();
      error(
        '$operation falhou após ${stopwatch.elapsed.inMilliseconds}ms',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Log de ação do usuário
  static void userAction(String action, {Map<String, dynamic>? params}) {
    final logMessage = StringBuffer('[USER ACTION] $action');
    if (params != null && params.isNotEmpty) {
      logMessage.write(' - Params: $params');
    }
    info(logMessage.toString());
  }

  /// Log de mudança de estado
  static void stateChange(String component, String oldState, String newState) {
    info('[STATE] $component: $oldState -> $newState');
  }

  /// Log de inicialização
  static void init(String component) {
    info('[INIT] Inicializando $component');
  }

  /// Log de dispose/cleanup
  static void dispose(String component) {
    debug('[DISPOSE] Liberando recursos de $component');
  }
}

/// Output customizado para salvar logs em arquivo (implementação futura)
class _FileOutput extends log.LogOutput {
  @override
  void output(log.OutputEvent event) {
    // TODO(autocore): Implementar salvamento em arquivo
    // Por enquanto, método vazio - não imprime nada em produção
  }
}

/// Extension para facilitar logs em widgets
extension LoggerExtension on String {
  void logInfo() => AppLogger.info(this);
  void logWarning() => AppLogger.warning(this);
  void logError() => AppLogger.error(this);
  void logDebug() => AppLogger.debug(this);
}
