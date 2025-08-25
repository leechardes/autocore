/// Custom exceptions para melhor error handling
library;

/// Base exception para todas as exceptions da app
abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException: $message';
}

/// Exception de rede/API
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    this.statusCode,
    this.endpoint,
    super.code,
  });

  final int? statusCode;
  final String? endpoint;

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

/// Exception de validação
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.errors = const {},
    super.code,
  });

  final Map<String, String> errors;

  @override
  String toString() => 'ValidationException: $message - Errors: $errors';
}

/// Exception de cache/armazenamento
class CacheException extends AppException {
  const CacheException(super.message, {super.code});

  @override
  String toString() => 'CacheException: $message';
}

/// Exception de parsing/serialização
class ParseException extends AppException {
  const ParseException(super.message, {this.source, super.code});

  final String? source;

  @override
  String toString() => 'ParseException: $message';
}

/// Exception de timeout
class TimeoutException extends AppException {
  const TimeoutException(super.message, {this.duration, super.code});

  final Duration? duration;

  @override
  String toString() =>
      'TimeoutException(${duration?.inMilliseconds}ms): $message';
}

/// Exception de configuração
class ConfigurationException extends AppException {
  const ConfigurationException(super.message, {super.code});

  @override
  String toString() => 'ConfigurationException: $message';
}

/// Exception de MQTT
class MqttException extends AppException {
  const MqttException(
    super.message, {
    this.topic,
    this.connectionState,
    super.code,
  });

  final String? topic;
  final String? connectionState;

  @override
  String toString() => 'MqttException($connectionState): $message';
}

/// Exception de device/hardware
class DeviceException extends AppException {
  const DeviceException(
    super.message, {
    this.deviceId,
    this.deviceType,
    super.code,
  });

  final String? deviceId;
  final String? deviceType;

  @override
  String toString() => 'DeviceException($deviceId): $message';
}
