import 'dart:async';
import 'dart:convert';

import 'package:autocore_app/core/models/screen_config.dart';
import 'package:autocore_app/core/services/mqtt_service.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static final ConfigService instance = ConfigService._internal();
  ConfigService._internal();

  AppConfig? _currentConfig;
  final _configController = StreamController<AppConfig>.broadcast();
  StreamSubscription<String>? _mqttSubscription;

  Stream<AppConfig> get configStream => _configController.stream;
  AppConfig? get currentConfig => _currentConfig;

  // Inicializar serviço
  Future<void> init() async {
    // Tentar carregar configuração salva
    await _loadSavedConfig();

    // Se não houver configuração salva, carregar padrão
    if (_currentConfig == null) {
      await loadDefaultConfig();
    }

    // Escutar atualizações via MQTT
    _subscribeMqttUpdates();
  }

  // Carregar configuração padrão do asset
  Future<void> loadDefaultConfig() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/config/default_config.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      await updateConfig(AppConfig.fromJson(jsonData));
    } catch (e) {
      AppLogger.error('Erro ao carregar configuração padrão', error: e);
      // Criar configuração mínima
      await updateConfig(_createMinimalConfig());
    }
  }

  // Carregar configuração de URL
  Future<void> loadConfigFromUrl(String url) async {
    try {
      // TODO(autocore): Implementar download de configuração
      // Por enquanto, simular com delay
      await Future<void>.delayed(const Duration(seconds: 2));

      // Usar configuração de exemplo
      final config = _createExampleConfig();
      await updateConfig(config);
    } catch (e) {
      AppLogger.error('Erro ao carregar configuração de URL', error: e);
      rethrow;
    }
  }

  // Método público loadConfig para o provider
  Future<void> loadConfig() async {
    await _loadSavedConfig();
  }

  // Carregar configuração salva
  Future<void> _loadSavedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('app_config');

      if (jsonString != null) {
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        _currentConfig = AppConfig.fromJson(jsonData);
        _configController.add(_currentConfig!);
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar configuração salva', error: e);
    }
  }

  // Salvar configuração
  Future<void> _saveConfig() async {
    if (_currentConfig == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_currentConfig!.toJson());
      await prefs.setString('app_config', jsonString);
    } catch (e) {
      AppLogger.error('Erro ao salvar configuração', error: e);
    }
  }

  // Atualizar configuração
  Future<void> updateConfig(AppConfig config) async {
    _currentConfig = config;
    _configController.add(config);
    await _saveConfig();
  }

  // Escutar atualizações via MQTT
  void _subscribeMqttUpdates() {
    _mqttSubscription?.cancel();
    _mqttSubscription = MqttService.instance
        .subscribe('autocore/config/app')
        .listen((payload) {
          try {
            final jsonData = json.decode(payload) as Map<String, dynamic>;
            final config = AppConfig.fromJson(jsonData);
            updateConfig(config);
          } catch (e) {
            AppLogger.error('Erro ao processar configuração MQTT', error: e);
          }
        });
  }

  // Obter tela por ID
  ScreenConfig? getScreen(String screenId) {
    if (_currentConfig == null) return null;
    try {
      return _currentConfig!.screens.firstWhere((s) => s.id == screenId);
    } catch (e) {
      return null;
    }
  }

  // Obter telas visíveis ordenadas
  List<ScreenConfig> getVisibleScreens() {
    if (_currentConfig == null) return [];

    return _currentConfig!.screens.where((s) => s.visible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  // Obter dispositivo por ID
  DeviceConfig? getDevice(String deviceId) {
    return _currentConfig?.devices[deviceId];
  }

  // Obter canal de dispositivo
  ChannelConfig? getChannel(String deviceId, String channelId) {
    final device = getDevice(deviceId);
    return device?.channels[channelId];
  }

  // Criar configuração mínima
  AppConfig _createMinimalConfig() {
    return const AppConfig(
      version: '1.0.0',
      screens: [
        ScreenConfig(
          id: 'home',
          name: 'Home',
          icon: 'home',
          route: '/home',
          layout: ScreenLayout(type: 'grid', columns: 2),
          widgets: [
            WidgetConfig(
              id: 'welcome',
              type: 'text',
              properties: {
                'text': 'Bem-vindo ao AutoCore',
                'fontSize': 24,
                'fontWeight': 'bold',
              },
            ),
            WidgetConfig(
              id: 'status',
              type: 'text',
              properties: {
                'text': 'Aguardando configuração...',
                'fontSize': 16,
              },
            ),
          ],
        ),
      ],
      devices: {},
    );
  }

  // Criar configuração de exemplo
  AppConfig _createExampleConfig() {
    return AppConfig(
      version: '1.0.0',
      screens: [
        // Tela inicial com navegação
        const ScreenConfig(
          id: 'home',
          name: 'Home',
          icon: 'home',
          route: '/home',
          layout: ScreenLayout(type: 'grid', columns: 2, spacing: 16),
          widgets: [
            // Botões de navegação
            WidgetConfig(
              id: 'nav_lights',
              type: 'button',
              properties: {
                'text': 'Iluminação',
                'icon': 'lightbulb',
                'size': 'large',
                'type': 'elevated',
              },
              actions: {
                'onPressed': ActionConfig(
                  type: 'navigate',
                  params: {'screen': 'lighting'},
                ),
              },
            ),
            WidgetConfig(
              id: 'nav_winch',
              type: 'button',
              properties: {
                'text': 'Guincho',
                'icon': 'settings',
                'size': 'large',
                'type': 'elevated',
              },
              actions: {
                'onPressed': ActionConfig(
                  type: 'navigate',
                  params: {'screen': 'winch'},
                ),
              },
            ),
            WidgetConfig(
              id: 'nav_telemetry',
              type: 'button',
              properties: {
                'text': 'Telemetria',
                'icon': 'gauge',
                'size': 'large',
                'type': 'elevated',
              },
              actions: {
                'onPressed': ActionConfig(
                  type: 'navigate',
                  params: {'screen': 'telemetry'},
                ),
              },
            ),
            WidgetConfig(
              id: 'nav_macros',
              type: 'button',
              properties: {
                'text': 'Macros',
                'icon': 'play',
                'size': 'large',
                'type': 'elevated',
              },
              actions: {
                'onPressed': ActionConfig(
                  type: 'navigate',
                  params: {'screen': 'macros'},
                ),
              },
            ),
          ],
        ),

        // Tela de iluminação
        const ScreenConfig(
          id: 'lighting',
          name: 'Iluminação',
          icon: 'lightbulb',
          route: '/lighting',
          layout: ScreenLayout(type: 'grid', columns: 2, spacing: 12),
          widgets: [
            WidgetConfig(
              id: 'light_front',
              type: 'control_tile',
              properties: {
                'label': 'Farol Alto',
                'icon': 'lightbulb',
                'controlType': 'toggle',
                'deviceId': 'relay_board_1',
                'channelId': 'ch1',
              },
            ),
            WidgetConfig(
              id: 'light_low',
              type: 'control_tile',
              properties: {
                'label': 'Farol Baixo',
                'icon': 'lightbulb',
                'controlType': 'toggle',
                'deviceId': 'relay_board_1',
                'channelId': 'ch2',
              },
            ),
            WidgetConfig(
              id: 'light_fog',
              type: 'control_tile',
              properties: {
                'label': 'Neblina',
                'icon': 'lightbulb',
                'controlType': 'toggle',
                'deviceId': 'relay_board_1',
                'channelId': 'ch3',
              },
            ),
            WidgetConfig(
              id: 'light_emergency',
              type: 'control_tile',
              properties: {
                'label': 'Emergência',
                'icon': 'warning',
                'controlType': 'toggle',
                'deviceId': 'relay_board_1',
                'channelId': 'ch4',
                'confirmAction': true,
                'confirmMessage': 'Ativar luzes de emergência?',
              },
            ),
          ],
        ),

        // Tela de telemetria
        const ScreenConfig(
          id: 'telemetry',
          name: 'Telemetria',
          icon: 'gauge',
          route: '/telemetry',
          layout: ScreenLayout(type: 'grid', columns: 2, spacing: 12),
          widgets: [
            WidgetConfig(
              id: 'speed',
              type: 'gauge',
              properties: {
                'label': 'Velocidade',
                'stateKey': 'telemetry.speed',
                'min': 0,
                'max': 200,
                'unit': 'km/h',
                'type': 'semicircular',
              },
            ),
            WidgetConfig(
              id: 'rpm',
              type: 'gauge',
              properties: {
                'label': 'RPM',
                'stateKey': 'telemetry.rpm',
                'min': 0,
                'max': 8000,
                'unit': 'rpm',
                'type': 'semicircular',
                'zones': [
                  {'start': 0, 'end': 2000, 'color': '#00ff00'},
                  {'start': 2000, 'end': 6000, 'color': '#ffff00'},
                  {'start': 6000, 'end': 8000, 'color': '#ff0000'},
                ],
              },
            ),
            WidgetConfig(
              id: 'temp',
              type: 'gauge',
              properties: {
                'label': 'Temperatura',
                'stateKey': 'telemetry.temp',
                'min': 0,
                'max': 120,
                'unit': '°C',
                'type': 'linear',
              },
            ),
            WidgetConfig(
              id: 'fuel',
              type: 'gauge',
              properties: {
                'label': 'Combustível',
                'stateKey': 'telemetry.fuel',
                'min': 0,
                'max': 100,
                'unit': '%',
                'type': 'battery',
              },
            ),
          ],
        ),

        // Tela de guincho
        const ScreenConfig(
          id: 'winch',
          name: 'Guincho',
          icon: 'settings',
          route: '/winch',
          layout: ScreenLayout(type: 'grid', columns: 1, spacing: 16),
          widgets: [
            WidgetConfig(
              id: 'winch_control',
              type: 'container',
              properties: {'type': 'elevated', 'padding': 'lg'},
              children: [
                WidgetConfig(
                  id: 'winch_title',
                  type: 'text',
                  properties: {
                    'text': 'Controle do Guincho',
                    'fontSize': 20,
                    'fontWeight': 'bold',
                  },
                ),
                WidgetConfig(
                  id: 'winch_spacer',
                  type: 'spacer',
                  properties: {'size': 'md'},
                ),
                WidgetConfig(
                  id: 'winch_buttons',
                  type: 'row',
                  properties: {'mainAxisAlignment': 'spaceEvenly'},
                  children: [
                    WidgetConfig(
                      id: 'winch_up',
                      type: 'button',
                      properties: {
                        'text': 'Subir',
                        'icon': 'arrow_upward',
                        'type': 'elevated',
                        'color': 'success',
                      },
                      actions: {
                        'onPressed': ActionConfig(
                          type: 'mqtt_publish',
                          params: {
                            'topic': 'autocore/winch/control',
                            'payload': {'action': 'up'},
                          },
                          requireConfirmation: true,
                          confirmMessage: 'Iniciar guincho para cima?',
                        ),
                      },
                    ),
                    WidgetConfig(
                      id: 'winch_stop',
                      type: 'button',
                      properties: {
                        'text': 'Parar',
                        'icon': 'stop',
                        'type': 'elevated',
                        'color': 'error',
                      },
                      actions: {
                        'onPressed': ActionConfig(
                          type: 'mqtt_publish',
                          params: {
                            'topic': 'autocore/winch/control',
                            'payload': {'action': 'stop'},
                          },
                        ),
                      },
                    ),
                    WidgetConfig(
                      id: 'winch_down',
                      type: 'button',
                      properties: {
                        'text': 'Descer',
                        'icon': 'arrow_downward',
                        'type': 'elevated',
                        'color': 'warning',
                      },
                      actions: {
                        'onPressed': ActionConfig(
                          type: 'mqtt_publish',
                          params: {
                            'topic': 'autocore/winch/control',
                            'payload': {'action': 'down'},
                          },
                          requireConfirmation: true,
                          confirmMessage: 'Iniciar guincho para baixo?',
                        ),
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Tela de macros
        const ScreenConfig(
          id: 'macros',
          name: 'Macros',
          icon: 'play',
          route: '/macros',
          layout: ScreenLayout(type: 'list', spacing: 8),
          widgets: [
            WidgetConfig(
              id: 'macro_night',
              type: 'control_tile',
              properties: {
                'label': 'Modo Noturno',
                'subtitle': 'Ativa iluminação completa',
                'icon': 'lightbulb',
                'controlType': 'toggle',
                'size': 'expanded',
              },
              actions: {
                'onToggle': ActionConfig(
                  type: 'macro',
                  params: {'macroId': 'night_mode'},
                ),
              },
            ),
            WidgetConfig(
              id: 'macro_trail',
              type: 'control_tile',
              properties: {
                'label': 'Modo Trilha',
                'subtitle': 'Configura para off-road',
                'icon': 'settings',
                'controlType': 'toggle',
                'size': 'expanded',
              },
              actions: {
                'onToggle': ActionConfig(
                  type: 'macro',
                  params: {'macroId': 'trail_mode'},
                ),
              },
            ),
            WidgetConfig(
              id: 'macro_camping',
              type: 'control_tile',
              properties: {
                'label': 'Modo Camping',
                'subtitle': 'Prepara para acampamento',
                'icon': 'home',
                'controlType': 'toggle',
                'size': 'expanded',
              },
              actions: {
                'onToggle': ActionConfig(
                  type: 'macro',
                  params: {'macroId': 'camping_mode'},
                ),
              },
            ),
          ],
        ),
      ],
      devices: {
        'relay_board_1': const DeviceConfig(
          id: 'relay_board_1',
          name: 'Placa de Relés 1',
          type: 'relay_board',
          online: true,
          channels: {
            'ch1': ChannelConfig(
              id: 'ch1',
              name: 'Canal 1',
              functionType: 'light_high',
              state: false,
              allowInMacro: true,
            ),
            'ch2': ChannelConfig(
              id: 'ch2',
              name: 'Canal 2',
              functionType: 'light_low',
              state: false,
              allowInMacro: true,
            ),
            'ch3': ChannelConfig(
              id: 'ch3',
              name: 'Canal 3',
              functionType: 'light_fog',
              state: false,
              allowInMacro: true,
            ),
            'ch4': ChannelConfig(
              id: 'ch4',
              name: 'Canal 4',
              functionType: 'light_emergency',
              state: false,
              allowInMacro: true,
            ),
          },
        ),
      },
      mqtt: MqttConfig(
        broker: '192.168.1.100',
        port: 1883,
        clientId: 'autocore_app_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  void dispose() {
    _mqttSubscription?.cancel();
    _configController.close();
  }
}
