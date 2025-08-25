import 'package:freezed_annotation/freezed_annotation.dart';

part 'mqtt_config.freezed.dart';
part 'mqtt_config.g.dart';

@freezed
class MqttConfig with _$MqttConfig {
  const factory MqttConfig({
    @Default('10.0.10.100') String broker,
    @Default(1883) int port,
    String? username,
    String? password,
    @Default('autocore') String topicPrefix,
    @Default(60) int keepalive,
    @Default(1) int qos,
    @Default(false) bool retain,
    @Default('autocore-{device_uuid}') String clientIdPattern,
    @Default(true) bool autoReconnect,
    @Default(5) int maxReconnectAttempts,
    @Default(5000) int reconnectInterval,
    @Default(30000) int connectionTimeout,
    DateTime? lastUpdated,
  }) = _MqttConfig;

  factory MqttConfig.fromJson(Map<String, dynamic> json) =>
      _$MqttConfigFromJson(json);

  const MqttConfig._();

  // Gera o client ID substituindo o placeholder
  String getClientId(String deviceUuid) {
    return clientIdPattern.replaceAll('{device_uuid}', deviceUuid);
  }

  // Verifica se a configuração é válida
  bool get isValid {
    return broker.isNotEmpty &&
        port > 0 &&
        port <= 65535 &&
        topicPrefix.isNotEmpty;
  }

  // Cria uma configuração padrão para desenvolvimento
  static MqttConfig development() => const MqttConfig(
    broker: '10.0.10.100',
    port: 1883,
    topicPrefix: 'autocore',
    clientIdPattern: 'autocore-dev-{device_uuid}',
  );

  // Cria uma configuração padrão para produção
  static MqttConfig production() => const MqttConfig(
    broker: 'autocore.local',
    port: 1883,
    topicPrefix: 'autocore',
    clientIdPattern: 'autocore-{device_uuid}',
  );

  // Merge com configurações locais, priorizando configurações manuais
  MqttConfig mergeWithLocal(MqttConfig? localConfig) {
    if (localConfig == null) return this;

    // Se configuração local tem valores personalizados, mantém eles
    return copyWith(
      broker: localConfig.broker != '10.0.10.100' ? localConfig.broker : broker,
      port: localConfig.port != 1883 ? localConfig.port : port,
      username: localConfig.username?.isNotEmpty == true
          ? localConfig.username
          : username,
      password: localConfig.password?.isNotEmpty == true
          ? localConfig.password
          : password,
      topicPrefix: localConfig.topicPrefix != 'autocore'
          ? localConfig.topicPrefix
          : topicPrefix,
      keepalive: localConfig.keepalive != 60
          ? localConfig.keepalive
          : keepalive,
      qos: localConfig.qos != 1 ? localConfig.qos : qos,
      retain: localConfig.retain != false ? localConfig.retain : retain,
      clientIdPattern: localConfig.clientIdPattern != 'autocore-{device_uuid}'
          ? localConfig.clientIdPattern
          : clientIdPattern,
      autoReconnect: localConfig.autoReconnect != true
          ? localConfig.autoReconnect
          : autoReconnect,
      maxReconnectAttempts: localConfig.maxReconnectAttempts != 5
          ? localConfig.maxReconnectAttempts
          : maxReconnectAttempts,
      reconnectInterval: localConfig.reconnectInterval != 5000
          ? localConfig.reconnectInterval
          : reconnectInterval,
      connectionTimeout: localConfig.connectionTimeout != 30000
          ? localConfig.connectionTimeout
          : connectionTimeout,
      lastUpdated: DateTime.now(),
    );
  }
}
