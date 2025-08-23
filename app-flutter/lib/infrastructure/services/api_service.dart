import 'dart:async';

import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/domain/entities/macro.dart';
import 'package:autocore_app/domain/models/app_config.dart';
import 'package:autocore_app/domain/models/screen_config.dart';
import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  static ApiService get instance => _instance;
  
  Dio? _dio;
  AppConfig? _config;
  bool _initialized = false;
  
  void init({AppConfig? config}) {
    if (_initialized) return;
    
    _config = config ?? AppConfig.development();
    
    _dio = Dio(BaseOptions(
      baseUrl: _config!.apiUrl,
      connectTimeout: Duration(milliseconds: _config!.connectionTimeout),
      receiveTimeout: Duration(milliseconds: _config!.connectionTimeout * 2),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Interceptor para logs e tratamento de erros
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.network('API Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.network('API Response: ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        // Tratamento melhorado de erros de conexão
        if (error.type == DioExceptionType.connectionError || 
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          AppLogger.warning('Backend offline, usando modo offline');
          // Não propaga o erro de conexão - usa dados offline
          // Retorna resposta fake para não crashar
          handler.resolve(Response(
            requestOptions: error.requestOptions,
            statusCode: 503,
            data: null,
          ));
        } else {
          AppLogger.error('API Error', error: error);
          handler.next(error);
        }
      },
    ));
    
    AppLogger.init('ApiService');
    AppLogger.info('API Service inicializado: ${_config!.apiUrl}');
    _initialized = true;
  }
  
  void updateConfig(AppConfig config) {
    _config = config;
    if (_dio != null) {
      _dio!.options.baseUrl = config.apiUrl;
      _dio!.options.connectTimeout = Duration(milliseconds: config.connectionTimeout);
    }
    AppLogger.info('API config atualizada: ${config.apiUrl}');
  }
  
  // Buscar configuração das telas
  Future<List<ScreenConfig>> getScreens() async {
    if (!_initialized) init();
    
    try {
      AppLogger.info('Buscando screens de: ${_config!.apiUrl}/api/screens');
      final response = await _dio!.get<dynamic>('/api/screens');
      
      AppLogger.debug('Response status: ${response.statusCode}');
      AppLogger.debug('Response data type: ${response.data.runtimeType}');
      
      if (response.data is List) {
        // API retorna diretamente uma lista
        final screensList = (response.data as List).map((screenData) {
          final data = screenData as Map<String, dynamic>;
          // Adapta os dados do backend para o formato esperado
          final adaptedData = <String, dynamic>{
            'id': data['id'].toString(), // Converte int para string
            'name': data['name'] ?? data['title'] ?? '',
            'description': data['description'],
            'icon': data['icon'],
            'route': '/screen/${data['id']}',
            'items': <Map<String, dynamic>>[], // Backend não envia items na listagem
            'layout': 'grid',
            'columns': data['columns_mobile'] ?? 2,
            'showHeader': true,
            'showNavigation': true,
            'customProperties': {
              'screen_type': data['screen_type'],
              'is_visible': data['is_visible'],
              'position': data['position'],
            },
            'createdAt': data['created_at'],
          };
          return ScreenConfig.fromJson(adaptedData);
        }).toList();
        AppLogger.info('Screens carregadas do backend: ${screensList.length}');
        return screensList;
      } else if (response.data is Map && (response.data! as Map<String, dynamic>)['screens'] != null) {
        final screens = ((response.data! as Map<String, dynamic>)['screens'] as List)
            .map((json) => ScreenConfig.fromJson(json as Map<String, dynamic>))
            .toList();
        
        AppLogger.info('Screens carregadas do backend (objeto): ${screens.length}');
        return screens;
      }
      
      AppLogger.warning('Formato de resposta inesperado para screens');
      return [];
    } catch (e) {
      AppLogger.error('Erro ao buscar screens: ${e.toString()}');
      AppLogger.info('Usando screens padrão (offline)');
      // Retornar configuração padrão em caso de erro
      return getDefaultScreensAsModels();
    }
  }
  
  // Buscar macros disponíveis
  Future<List<Macro>> getMacros() async {
    if (!_initialized) init();
    
    try {
      AppLogger.info('Buscando macros de: ${_config!.apiUrl}/api/macros/');
      final response = await _dio!.get<dynamic>('/api/macros/');
      
      AppLogger.debug('Macros response status: ${response.statusCode}');
      AppLogger.debug('Macros response data: ${response.data}');
      
      if (response.data is List) {
        // Adapta o formato do backend para o modelo Flutter
        final macrosList = (response.data as List).map((macroData) {
          final data = macroData as Map<String, dynamic>;
          AppLogger.debug('Macro original do backend: $macroData');
          
          // Converte o formato do backend para o formato esperado pelo modelo
          final adaptedData = <String, dynamic>{
            'id': data['id'],
            'name': data['name'] ?? '',
            'description': data['description'],
            'icon': data['icon'] ?? '⚡',
            'enabled': data['is_active'] ?? true,
            'triggerType': 'manual', // Força sempre manual já que o valor do backend está correto
            'triggerConfig': <String, dynamic>{},
            'actions': [
              // Cria uma ação dummy até o backend enviar as ações reais
              <String, dynamic>{
                'id': 'action_${data['id']}_1',
                'type': 'mqtt_publish',
                'config': <String, dynamic>{
                  'topic': 'autocore/macros/${data['id']}/execute',
                  'payload': '{"executed": true}',
                },
                'description': 'Executa macro ${data['name']}',
                'enabled': true,
              }
            ], // Ação temporária até backend enviar
            'metadata': <String, dynamic>{
              'execution_count': data['execution_count'] ?? 0,
              'last_executed': data['last_executed'],
            },
            'createdAt': data['created_at'],
            'executionCount': data['execution_count'] ?? 0,
            'showInUi': true,
            'isSystem': false,
          };
          
          AppLogger.debug('Macro adaptada para Flutter: $adaptedData');
          
          try {
            return Macro.fromJson(adaptedData);
          } catch (e) {
            AppLogger.error('Erro ao criar Macro.fromJson', error: e);
            AppLogger.error('Dados que causaram erro: $adaptedData');
            rethrow;
          }
        }).toList();
        
        AppLogger.info('Macros carregadas do backend: ${macrosList.length}');
        return macrosList;
      } else if (response.data is Map && (response.data! as Map<String, dynamic>)['macros'] != null) {
        // Caso a API retorne um objeto com array de macros
        final macros = ((response.data! as Map<String, dynamic>)['macros'] as List).map((macroData) {
          final data = macroData as Map<String, dynamic>;
          final adaptedData = <String, dynamic>{
            'id': data['id'],
            'name': data['name'] ?? '',
            'description': data['description'],
            'icon': data['icon'] ?? '⚡',
            'enabled': data['is_active'] ?? true,
            'triggerType': 'manual', // Força sempre manual
            'triggerConfig': <String, dynamic>{},
            'actions': [
              <String, dynamic>{
                'id': 'action_${data['id']}_1',
                'type': 'mqtt_publish',
                'config': <String, dynamic>{
                  'topic': 'autocore/macros/${data['id']}/execute',
                  'payload': '{"executed": true}',
                },
                'description': 'Executa macro ${data['name']}',
                'enabled': true,
              }
            ],
            'metadata': <String, dynamic>{},
            'executionCount': data['execution_count'] ?? 0,
            'showInUi': true,
            'isSystem': false,
          };
          return Macro.fromJson(adaptedData);
        }).toList();
        
        AppLogger.info('Macros carregadas do backend (objeto): ${macros.length}');
        return macros;
      }
      
      AppLogger.warning('Formato de resposta inesperado para macros');
      return [];
    } catch (e) {
      AppLogger.error('Erro ao buscar macros: ${e.toString()}');
      AppLogger.info('Usando macros padrão (offline)');
      // Retornar macros padrão em caso de erro
      return getDefaultMacrosAsModels();
    }
  }
  
  // Executar macro
  Future<bool> executeMacro(int macroId) async {
    if (!_initialized) init();
    
    try {
      final response = await _dio!.post<Map<String, dynamic>>('/api/macros/$macroId/execute');
      
      if (response.statusCode == 200) {
        AppLogger.info('Macro executada: $macroId');
        return true;
      }
      
      return false;
    } catch (e) {
      AppLogger.error('Erro ao executar macro', error: e);
      return false;
    }
  }
  
  // Buscar itens de uma tela específica
  Future<List<dynamic>> getScreenItems(String screenId) async {
    if (!_initialized) init();
    
    try {
      AppLogger.info('Buscando itens da tela: ${_config!.apiUrl}/api/screens/$screenId/items');
      final response = await _dio!.get<List<dynamic>>('/api/screens/$screenId/items');
      
      AppLogger.debug('Items response status: ${response.statusCode}');
      AppLogger.debug('Items response data: ${response.data}');
      
      if (response.data is List) {
        AppLogger.info('Itens carregados para tela $screenId: ${(response.data as List).length}');
        return response.data as List;
      }
      
      AppLogger.warning('Formato de resposta inesperado para itens');
      return [];
    } catch (e) {
      AppLogger.error('Erro ao buscar itens da tela $screenId: ${e.toString()}');
      return [];
    }
  }
  
  // Executar comando de botão
  Future<bool> executeButton(String screenId, String buttonId) async {
    if (!_initialized) init();
    
    try {
      final response = await _dio!.post<Map<String, dynamic>>('/api/screens/$screenId/buttons/$buttonId/execute');
      
      if (response.statusCode == 200) {
        AppLogger.info('Botão executado: $screenId/$buttonId');
        return true;
      }
      
      return false;
    } catch (e) {
      AppLogger.error('Erro ao executar botão', error: e);
      return false;
    }
  }
  
  // Buscar status do sistema
  Future<Map<String, dynamic>> getSystemStatus() async {
    if (!_initialized) init();
    
    try {
      AppLogger.info('Buscando status de: ${_config!.apiUrl}/api/status');
      final response = await _dio!.get<Map<String, dynamic>>('/api/status');
      
      AppLogger.debug('Status response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Erro ao buscar status: ${e.toString()}');
      AppLogger.info('Usando status padrão (offline)');
      // Retornar status padrão
      return {
        'devices': {'active': 0, 'total': 0},
        'battery': {'level': 85, 'voltage': 12.8},
        'temperature': 23.5,
        'uptime': '0h',
        'mqttConnected': false,
      };
    }
  }
  
  // Buscar informações do veículo
  Future<Map<String, dynamic>> getVehicleInfo() async {
    if (!_initialized) init();
    
    try {
      // TODO(autocore): Implementar endpoint /api/vehicle no backend
      // Por enquanto retorna dados mockados
      return {
        'name': 'Ranger XLT',
        'model': 'Ford Ranger 2019',
        'plate': 'ABC-1234',
        'vin': '1HGCM82633A123456',
      };
    } catch (e) {
      AppLogger.error('Erro ao buscar info do veículo', error: e);
      return {};
    }
  }
  
  // Testar conexão
  Future<bool> testConnection() async {
    if (!_initialized) init();
    
    try {
      AppLogger.info('Testando conexão com: ${_config!.apiUrl}/api/health');
      final response = await _dio!.get<Map<String, dynamic>>(
        '/api/health',
        options: Options(
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
      
      final success = response.statusCode == 200;
      AppLogger.info('Teste de conexão: ${success ? "OK" : "FALHOU"} (${response.statusCode})');
      return success;
    } catch (e) {
      AppLogger.error('Teste de conexão falhou: ${e.toString()}');
      return false;
    }
  }
  
  // Configurações padrão quando offline
  // Versão que retorna List<ScreenConfig> para uso interno
  List<ScreenConfig> getDefaultScreensAsModels() {
    return getDefaultScreens()
        .map(ScreenConfig.fromJson)
        .toList();
  }
  
  List<Map<String, dynamic>> getDefaultScreens() {
    return <Map<String, dynamic>>[
      {
        'id': 'lighting',
        'name': 'Iluminação',
        'icon': 'lightbulb',
        'items': <Map<String, dynamic>>[],
      },
      {
        'id': 'winch',
        'name': 'Guincho',
        'icon': 'settings_input_component',
        'items': <Map<String, dynamic>>[],
      },
      {
        'id': 'auxiliary',
        'name': 'Auxiliares',
        'icon': 'toggle_on',
        'items': <Map<String, dynamic>>[],
      },
      {
        'id': 'traction',
        'name': 'Tração',
        'icon': 'explore',
        'items': <Map<String, dynamic>>[],
      },
    ];
  }
  
  // Versão que retorna List<Macro> para uso interno
  List<Macro> getDefaultMacrosAsModels() {
    return getDefaultMacros()
        .map(Macro.fromJson)
        .toList();
  }
  
  List<Map<String, dynamic>> getDefaultMacros() {
    return <Map<String, dynamic>>[
      {
        'id': 1,
        'name': 'Camping',
        'description': 'Configuração para acampamento',
        'icon': '🏕️',
        'enabled': true,
        'triggerType': 'manual',
        'triggerConfig': <String, dynamic>{},
        'actions': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'action_1_1',
            'type': 'mqtt_publish',
            'config': <String, dynamic>{
              'topic': 'autocore/macros/1/execute',
              'payload': '{"executed": true}',
            },
            'description': 'Executa macro Camping',
            'enabled': true,
          }
        ],
        'metadata': <String, dynamic>{},
        'executionCount': 0,
        'showInUi': true,
        'isSystem': false,
      },
      {
        'id': 2,
        'name': 'Emergência',
        'description': 'Luzes de emergência',
        'icon': '🚨',
        'enabled': true,
        'triggerType': 'manual',
        'triggerConfig': <String, dynamic>{},
        'actions': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'action_2_1',
            'type': 'mqtt_publish',
            'config': <String, dynamic>{
              'topic': 'autocore/macros/2/execute',
              'payload': '{"executed": true}',
            },
            'description': 'Executa macro Emergência',
            'enabled': true,
          }
        ],
        'metadata': <String, dynamic>{},
        'executionCount': 0,
        'showInUi': true,
        'isSystem': false,
      },
      {
        'id': 3,
        'name': 'Show',
        'description': 'Modo demonstração',
        'icon': '✨',
        'enabled': true,
        'triggerType': 'manual',
        'triggerConfig': <String, dynamic>{},
        'actions': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'action_3_1',
            'type': 'mqtt_publish',
            'config': <String, dynamic>{
              'topic': 'autocore/macros/3/execute',
              'payload': '{"executed": true}',
            },
            'description': 'Executa macro Show',
            'enabled': true,
          }
        ],
        'metadata': <String, dynamic>{},
        'executionCount': 0,
        'showInUi': true,
        'isSystem': false,
      },
      {
        'id': 4,
        'name': 'Noturno',
        'description': 'Configuração noturna',
        'icon': '🌙',
        'enabled': true,
        'triggerType': 'manual',
        'triggerConfig': <String, dynamic>{},
        'actions': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'action_4_1',
            'type': 'mqtt_publish',
            'config': <String, dynamic>{
              'topic': 'autocore/macros/4/execute',
              'payload': '{"executed": true}',
            },
            'description': 'Executa macro Noturno',
            'enabled': true,
          }
        ],
        'metadata': <String, dynamic>{},
        'executionCount': 0,
        'showInUi': true,
        'isSystem': false,
      },
    ];
  }
}