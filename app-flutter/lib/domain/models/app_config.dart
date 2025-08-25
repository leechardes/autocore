import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    // Backend API (Gateway)
    @Default('10.0.10.100') String apiHost,
    @Default(8081) int apiPort,
    @Default(false) bool apiUseHttps,

    // Configurações gerais
    @Default(true) bool autoConnect,
    @Default(5000) int connectionTimeout,
    @Default(3) int maxRetries,
    @Default(true) bool enableHeartbeat,
    @Default(500) int heartbeatInterval,
    @Default(1000) int heartbeatTimeout,

    // Última conexão bem sucedida
    DateTime? lastSuccessfulConnection,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  const AppConfig._();

  // URLs computadas
  String get apiUrl {
    final protocol = apiUseHttps ? 'https' : 'http';
    return '$protocol://$apiHost:$apiPort';
  }

  // Configurações padrão para desenvolvimento
  static AppConfig development() =>
      const AppConfig(apiHost: '10.0.10.100', apiPort: 8081);

  // Configurações para produção
  static AppConfig production() => const AppConfig(apiHost: 'autocore.local');
}
