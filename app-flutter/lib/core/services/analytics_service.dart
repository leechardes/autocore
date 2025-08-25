/// Serviço base para analytics (preparado para providers futuros)
/// Implementado como parte do A42 - Feature Preparation
library;

import 'package:autocore_app/core/services/feature_flags_service.dart';
import 'package:autocore_app/core/utils/logger.dart';

/// Interface base para eventos de analytics
abstract class AnalyticsEvent {
  /// Nome do evento
  String get name;
  
  /// Parâmetros do evento
  Map<String, dynamic> get parameters;
  
  /// Timestamp do evento
  DateTime get timestamp => DateTime.now();
  
  /// Converte para JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Eventos comuns do sistema
class ButtonClickEvent extends AnalyticsEvent {
  final String buttonId;
  final String screen;
  final String? category;
  
  ButtonClickEvent({
    required this.buttonId,
    required this.screen,
    this.category,
  });
  
  @override
  String get name => 'button_click';
  
  @override
  Map<String, dynamic> get parameters => {
    'button_id': buttonId,
    'screen': screen,
    if (category != null) 'category': category,
  };
}

class ScreenViewEvent extends AnalyticsEvent {
  final String screenName;
  final String? previousScreen;
  final Map<String, dynamic> screenParameters;
  
  ScreenViewEvent({
    required this.screenName,
    this.previousScreen,
    this.screenParameters = const {},
  });
  
  @override
  String get name => 'screen_view';
  
  @override
  Map<String, dynamic> get parameters => {
    'screen_name': screenName,
    if (previousScreen != null) 'previous_screen': previousScreen,
    ...screenParameters,
  };
}

class DeviceActionEvent extends AnalyticsEvent {
  final String action;
  final String deviceId;
  final bool success;
  final String? errorMessage;
  
  DeviceActionEvent({
    required this.action,
    required this.deviceId,
    required this.success,
    this.errorMessage,
  });
  
  @override
  String get name => 'device_action';
  
  @override
  Map<String, dynamic> get parameters => {
    'action': action,
    'device_id': deviceId,
    'success': success,
    if (errorMessage != null) 'error_message': errorMessage,
  };
}

/// Provedor base para analytics
abstract class AnalyticsProvider {
  /// Nome do provedor
  String get name;
  
  /// Inicializa o provedor
  Future<void> initialize();
  
  /// Envia evento
  Future<void> trackEvent(AnalyticsEvent event);
  
  /// Define propriedades do usuário
  Future<void> setUserProperties(Map<String, dynamic> properties);
  
  /// Define ID do usuário
  Future<void> setUserId(String userId);
}

/// Implementação de console para desenvolvimento
class ConsoleAnalyticsProvider extends AnalyticsProvider {
  @override
  String get name => 'console';
  
  @override
  Future<void> initialize() async {
    AppLogger.info('Console Analytics Provider initialized');
  }
  
  @override
  Future<void> trackEvent(AnalyticsEvent event) async {
    AppLogger.info('📊 Analytics Event: ${event.name} - ${event.parameters}');
  }
  
  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    AppLogger.info('👤 Analytics User Properties: $properties');
  }
  
  @override
  Future<void> setUserId(String userId) async {
    AppLogger.info('👤 Analytics User ID: $userId');
  }
}

/// Serviço principal de analytics
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();
  
  AnalyticsService._();
  
  final List<AnalyticsProvider> _providers = [];
  bool _initialized = false;
  
  /// Inicializa o serviço de analytics
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Adiciona provedor padrão para desenvolvimento
    _providers.add(ConsoleAnalyticsProvider());
    
    // Inicializa todos os provedores
    for (final provider in _providers) {
      try {
        await provider.initialize();
        AppLogger.info('Analytics provider ${provider.name} initialized');
      } catch (e) {
        AppLogger.error('Error initializing analytics provider ${provider.name}', 
            error: e);
      }
    }
    
    _initialized = true;
    AppLogger.info('AnalyticsService initialized with ${_providers.length} providers');
  }
  
  /// Adiciona provedor de analytics
  void addProvider(AnalyticsProvider provider) {
    if (_providers.any((p) => p.name == provider.name)) {
      AppLogger.warning('Analytics provider ${provider.name} already exists');
      return;
    }
    
    _providers.add(provider);
    AppLogger.info('Analytics provider ${provider.name} added');
  }
  
  /// Remove provedor de analytics
  void removeProvider(String name) {
    _providers.removeWhere((p) => p.name == name);
    AppLogger.info('Analytics provider $name removed');
  }
  
  /// Envia evento para todos os provedores
  Future<void> track(AnalyticsEvent event) async {
    if (!_initialized) {
      AppLogger.warning('AnalyticsService not initialized, skipping event: ${event.name}');
      return;
    }
    
    if (!FeatureFlagsService.instance.hasAnalytics) {
      // Analytics desabilitado por feature flag
      return;
    }
    
    for (final provider in _providers) {
      try {
        await provider.trackEvent(event);
      } catch (e) {
        AppLogger.error('Error tracking event in provider ${provider.name}', 
            error: e);
      }
    }
  }
  
  /// Define propriedades do usuário
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_initialized || !FeatureFlagsService.instance.hasAnalytics) return;
    
    for (final provider in _providers) {
      try {
        await provider.setUserProperties(properties);
      } catch (e) {
        AppLogger.error('Error setting user properties in provider ${provider.name}', 
            error: e);
      }
    }
  }
  
  /// Define ID do usuário
  Future<void> setUserId(String userId) async {
    if (!_initialized || !FeatureFlagsService.instance.hasAnalytics) return;
    
    for (final provider in _providers) {
      try {
        await provider.setUserId(userId);
      } catch (e) {
        AppLogger.error('Error setting user ID in provider ${provider.name}', 
            error: e);
      }
    }
  }
  
  /// Obtém lista de provedores ativos
  List<String> get activeProviders => 
      _providers.map((p) => p.name).toList();
}

/// Extension para facilitar uso do analytics
extension AnalyticsExtension on AnalyticsService {
  /// Track button click rápido
  void trackButtonClick(String buttonId, String screen, {String? category}) {
    track(ButtonClickEvent(
      buttonId: buttonId, 
      screen: screen, 
      category: category,
    ));
  }
  
  /// Track screen view rápido
  void trackScreenView(String screenName, {String? previousScreen}) {
    track(ScreenViewEvent(
      screenName: screenName, 
      previousScreen: previousScreen,
    ));
  }
  
  /// Track device action rápido
  void trackDeviceAction(String action, String deviceId, bool success, {String? error}) {
    track(DeviceActionEvent(
      action: action,
      deviceId: deviceId,
      success: success,
      errorMessage: error,
    ));
  }
}