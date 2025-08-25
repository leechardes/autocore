/// Serviço para gerenciar feature flags
/// Implementado como parte do A42 - Feature Preparation
library;

import 'package:autocore_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para controle de feature flags
class FeatureFlagsService {
  static FeatureFlagsService? _instance;
  static FeatureFlagsService get instance => _instance ??= FeatureFlagsService._();
  
  FeatureFlagsService._();
  
  SharedPreferences? _prefs;
  bool _initialized = false;
  
  /// Feature flags padrão do sistema
  static const Map<String, bool> _defaults = {
    // UI Features
    'new_ui_components': false,
    'dark_mode': true,
    'animations': true,
    
    // Performance Features  
    'lazy_loading': true,
    'cache_optimization': true,
    'background_sync': false,
    
    // Analytics & Monitoring
    'analytics': false,
    'crash_reporting': false,
    'performance_monitoring': false,
    
    // Experimental Features
    'offline_mode': false,
    'push_notifications': false,
    'voice_commands': false,
    
    // Debug Features (só em desenvolvimento)
    'debug_logs': false,
    'mock_data': false,
    'force_errors': false,
  };
  
  /// Inicializa o serviço de feature flags
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      
      AppLogger.info('FeatureFlagsService inicializado com ${_defaults.length} flags');
      
      // Log das flags ativas em desenvolvimento
      if (_isDebugMode()) {
        _logActiveFeatures();
      }
    } catch (e) {
      AppLogger.error('Erro ao inicializar FeatureFlagsService', error: e);
    }
  }
  
  /// Verifica se uma feature está habilitada
  bool isEnabled(String featureName) {
    if (!_initialized || _prefs == null) {
      AppLogger.warning('FeatureFlagsService não inicializado, usando padrão para $featureName');
      return _defaults[featureName] ?? false;
    }
    
    // Verifica override local primeiro
    final localOverride = _prefs!.getBool('feature_flag_$featureName');
    if (localOverride != null) {
      return localOverride;
    }
    
    // Usa valor padrão
    return _defaults[featureName] ?? false;
  }
  
  /// Define override local para uma feature
  Future<bool> setOverride(String featureName, bool enabled) async {
    if (!_initialized || _prefs == null) {
      AppLogger.error('FeatureFlagsService não inicializado');
      return false;
    }
    
    try {
      await _prefs!.setBool('feature_flag_$featureName', enabled);
      AppLogger.info('Feature flag override definido: $featureName = $enabled');
      return true;
    } catch (e) {
      AppLogger.error('Erro ao definir override da feature flag', error: e);
      return false;
    }
  }
  
  /// Remove override local, voltando ao padrão
  Future<bool> removeOverride(String featureName) async {
    if (!_initialized || _prefs == null) {
      AppLogger.error('FeatureFlagsService não inicializado');
      return false;
    }
    
    try {
      await _prefs!.remove('feature_flag_$featureName');
      AppLogger.info('Feature flag override removido: $featureName');
      return true;
    } catch (e) {
      AppLogger.error('Erro ao remover override da feature flag', error: e);
      return false;
    }
  }
  
  /// Obtém todas as feature flags disponíveis
  Map<String, bool> getAllFeatures() {
    if (!_initialized) return _defaults;
    
    final Map<String, bool> features = {};
    
    for (final feature in _defaults.keys) {
      features[feature] = isEnabled(feature);
    }
    
    return features;
  }
  
  /// Obtém apenas features ativas
  Map<String, bool> getActiveFeatures() {
    return getAllFeatures()..removeWhere((key, value) => !value);
  }
  
  /// Reseta todas as feature flags para o padrão
  Future<bool> resetToDefaults() async {
    if (!_initialized || _prefs == null) {
      AppLogger.error('FeatureFlagsService não inicializado');
      return false;
    }
    
    try {
      // Remove todos os overrides
      for (final feature in _defaults.keys) {
        await _prefs!.remove('feature_flag_$feature');
      }
      
      AppLogger.info('Todas as feature flags resetadas para o padrão');
      return true;
    } catch (e) {
      AppLogger.error('Erro ao resetar feature flags', error: e);
      return false;
    }
  }
  
  /// Verifica se está em modo debug
  bool _isDebugMode() {
    bool debugMode = false;
    assert(debugMode = true); // Só é true em debug builds
    return debugMode;
  }
  
  /// Log das features ativas (apenas em debug)
  void _logActiveFeatures() {
    final activeFeatures = getActiveFeatures();
    
    if (activeFeatures.isEmpty) {
      AppLogger.info('Nenhuma feature flag está ativa');
    } else {
      AppLogger.info('Feature flags ativas: ${activeFeatures.keys.join(', ')}');
    }
  }
}

/// Extension para facilitar uso das feature flags
extension FeatureFlagsExtension on FeatureFlagsService {
  // UI Features
  bool get hasNewUIComponents => isEnabled('new_ui_components');
  bool get hasDarkMode => isEnabled('dark_mode');
  bool get hasAnimations => isEnabled('animations');
  
  // Performance Features
  bool get hasLazyLoading => isEnabled('lazy_loading');
  bool get hasCacheOptimization => isEnabled('cache_optimization');
  bool get hasBackgroundSync => isEnabled('background_sync');
  
  // Analytics & Monitoring
  bool get hasAnalytics => isEnabled('analytics');
  bool get hasCrashReporting => isEnabled('crash_reporting');
  bool get hasPerformanceMonitoring => isEnabled('performance_monitoring');
  
  // Experimental Features
  bool get hasOfflineMode => isEnabled('offline_mode');
  bool get hasPushNotifications => isEnabled('push_notifications');
  bool get hasVoiceCommands => isEnabled('voice_commands');
  
  // Debug Features
  bool get hasDebugLogs => isEnabled('debug_logs');
  bool get hasMockData => isEnabled('mock_data');
  bool get hasForceErrors => isEnabled('force_errors');
}