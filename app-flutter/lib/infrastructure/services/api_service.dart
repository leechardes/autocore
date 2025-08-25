import 'dart:async';

import 'package:autocore_app/core/constants/api_endpoints.dart';
import 'package:autocore_app/core/models/api/config_full_response.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/domain/models/app_config.dart';
import 'package:autocore_app/domain/models/mqtt_config.dart';
import 'package:dio/dio.dart';

/// Serviço de API que se conecta apenas com dados reais do backend
/// SEM DADOS MOCKADOS OU FALLBACKS
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static ApiService get instance => _instance;

  late Dio _dio;
  bool _initialized = false;

  void init() {
    if (_initialized) return;

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

    // Interceptor para logs e tratamento de erros
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.network('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.network('API Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error('API Error: ${error.message}', error: error);
          // Propaga todos os erros - sem fallback para dados mockados
          handler.next(error);
        },
      ),
    );

    AppLogger.init('ApiService');
    AppLogger.info('API Service inicializado: ${ApiEndpoints.baseUrl}');
    _initialized = true;
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    AppLogger.info('API base URL atualizada: $baseUrl');
  }

  /// Busca configuração completa do dispositivo
  Future<ConfigFullResponse> getFullConfig(String deviceUuid) async {
    if (!_initialized) init();

    try {
      AppLogger.info('Buscando configuração completa para: $deviceUuid');
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.configFull(deviceUuid),
      );

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.info('Configuração completa carregada com sucesso');

        final config = ConfigFullResponse.fromJson(response.data!);

        return config;
      }

      throw Exception('Falha ao carregar configuração: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('Erro ao buscar configuração completa', error: e);
      rethrow; // Não usa dados mockados - propaga erro
    }
  }

  /// Atualiza configuração do dispositivo
  Future<bool> updateDevice(String uuid, Map<String, dynamic> data) async {
    if (!_initialized) init();

    try {
      AppLogger.info('Atualizando dispositivo: $uuid');
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.deviceUpdate(uuid),
        data: data,
      );

      if (response.statusCode == 200) {
        AppLogger.info('Dispositivo atualizado com sucesso');
        return true;
      }

      throw Exception('Falha ao atualizar dispositivo: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('Erro ao atualizar dispositivo', error: e);
      rethrow; // Não usa fallback - propaga erro
    }
  }

  /// Executa comando
  Future<bool> executeCommand(Map<String, dynamic> command) async {
    if (!_initialized) init();

    try {
      AppLogger.info('Executando comando: ${command['type']}');
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.executeCommand,
        data: command,
      );

      if (response.statusCode == 200) {
        AppLogger.info('Comando executado com sucesso');
        return true;
      }

      throw Exception('Falha ao executar comando: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('Erro ao executar comando', error: e);
      rethrow;
    }
  }

  /// Busca status do sistema
  Future<Map<String, dynamic>> getSystemStatus() async {
    if (!_initialized) init();

    try {
      AppLogger.info('Buscando status do sistema');
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.status,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      }

      throw Exception('Falha ao buscar status: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('Erro ao buscar status do sistema', error: e);
      rethrow; // Não usa dados mockados
    }
  }

  /// Busca configurações MQTT do backend
  Future<MqttConfig> getMqttConfig() async {
    if (!_initialized) init();

    try {
      AppLogger.info('Buscando configurações MQTT do backend');
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.mqttConfig,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.info('Configurações MQTT recebidas da API');
        AppLogger.debug('MQTT Config: ${response.data}');

        return MqttConfig.fromJson(response.data!);
      }

      throw Exception(
        'Falha ao buscar configuração MQTT: ${response.statusCode}',
      );
    } catch (e) {
      AppLogger.error('Erro ao buscar configurações MQTT da API', error: e);

      // Se falhar buscar da API, retorna configuração padrão
      AppLogger.warning('Usando configuração MQTT padrão devido a erro na API');
      return MqttConfig.development();
    }
  }

  /// Testa conexão com a API
  Future<bool> testConnection([String? url]) async {
    if (!_initialized) init();

    try {
      AppLogger.info('Testando conexão com API: ${url ?? ApiEndpoints.health}');

      // Se url customizada foi fornecida, usa ela
      if (url != null) {
        final response = await Dio().get<dynamic>(
          url,
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        final success = response.statusCode == 200;
        AppLogger.info(
          'Teste de conexão: ${success ? "Sucesso" : "Falha"} (${response.statusCode})',
        );
        return success;
      }

      // Senão usa a instância configurada
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.health,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final success = response.statusCode == 200;
      AppLogger.info(
        'Teste de conexão: ${success ? "Sucesso" : "Falha"} (${response.statusCode})',
      );
      return success;
    } catch (e) {
      AppLogger.error('Teste de conexão falhou', error: e);
      return false;
    }
  }

  /// Atualiza configurações do serviço
  void updateConfig(AppConfig config) {
    AppLogger.info('Atualizando configurações do ApiService');

    final newBaseUrl =
        '${config.apiUseHttps ? 'https' : 'http'}://${config.apiHost}:${config.apiPort}';

    // Recria o Dio com nova configuração
    _dio = Dio(
      BaseOptions(
        baseUrl: newBaseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
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
          AppLogger.network('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.network('API Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error('API Error: ${error.message}', error: error);
          handler.next(error);
        },
      ),
    );

    AppLogger.info('ApiService configurado com novo baseUrl: $newBaseUrl');
  }
}
