/// Base class para feature modules
/// Implementado como parte do A42 - Feature Preparation
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Interface base para todos os feature modules
abstract class BaseFeatureModule {
  /// Nome único do módulo
  String get name;
  
  /// Nome para exibição na UI
  String get displayName;
  
  /// Ícone do módulo
  IconData get icon;
  
  /// Versão do módulo
  String get version => '1.0.0';
  
  /// Descrição do módulo
  String get description => '';
  
  /// Se o módulo está habilitado
  bool get enabled => true;
  
  /// Rotas do módulo
  List<RouteBase> get routes => [];
  
  /// Inicializa o módulo
  Future<void> initialize() async {}
  
  /// Dispose do módulo
  Future<void> dispose() async {}
  
  /// Verifica se o módulo pode ser carregado
  bool canLoad() => enabled;
}

/// Implementação padrão para feature modules simples
abstract class SimpleFeatureModule extends BaseFeatureModule {
  /// Widget principal do módulo
  Widget get mainScreen;
  
  /// Rota principal do módulo
  String get mainRoute => '/$name';
  
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: mainRoute,
      name: name,
      builder: (context, state) => mainScreen,
    ),
  ];
}

/// Implementação para feature modules com múltiplas telas
abstract class MultiScreenFeatureModule extends BaseFeatureModule {
  /// Mapeamento de rotas para widgets
  Map<String, Widget Function(BuildContext, GoRouterState)> get screenMap;
  
  @override
  List<RouteBase> get routes {
    return screenMap.entries.map((entry) {
      return GoRoute(
        path: entry.key,
        name: '${name}_${entry.key.replaceAll('/', '_')}',
        builder: entry.value,
      );
    }).toList();
  }
}

/// Configuração de um feature module
class FeatureModuleConfig {
  final String name;
  final String displayName;
  final IconData icon;
  final String version;
  final String description;
  final bool enabled;
  final List<String> dependencies;
  final Map<String, dynamic> settings;
  
  const FeatureModuleConfig({
    required this.name,
    required this.displayName,
    required this.icon,
    this.version = '1.0.0',
    this.description = '',
    this.enabled = true,
    this.dependencies = const [],
    this.settings = const {},
  });
  
  /// Cria configuração a partir de JSON
  factory FeatureModuleConfig.fromJson(Map<String, dynamic> json) {
    return FeatureModuleConfig(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      icon: _iconFromString(json['icon'] as String? ?? 'extension'),
      version: json['version'] as String? ?? '1.0.0',
      description: json['description'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      dependencies: (json['dependencies'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }
  
  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'icon': _iconToString(icon),
      'version': version,
      'description': description,
      'enabled': enabled,
      'dependencies': dependencies,
      'settings': settings,
    };
  }
  
  static IconData _iconFromString(String iconName) {
    // Mapeamento básico de ícones
    const iconMap = {
      'extension': Icons.extension,
      'settings': Icons.settings,
      'dashboard': Icons.dashboard,
      'analytics': Icons.analytics,
      'notifications': Icons.notifications,
      'sync': Icons.sync,
      'security': Icons.security,
      'devices': Icons.devices,
      'home': Icons.home,
      'info': Icons.info,
    };
    
    return iconMap[iconName] ?? Icons.extension;
  }
  
  static String _iconToString(IconData icon) {
    // Reverse mapping para os ícones mais comuns  
    final reverseMap = {
      Icons.extension: 'extension',
      Icons.settings: 'settings',
      Icons.dashboard: 'dashboard',
      Icons.analytics: 'analytics',
      Icons.notifications: 'notifications',
      Icons.sync: 'sync',
      Icons.security: 'security',
      Icons.devices: 'devices',
      Icons.home: 'home',
      Icons.info: 'info',
    };
    
    return reverseMap[icon] ?? 'extension';
  }
}

/// Gerenciador de feature modules
class FeatureModuleManager {
  static FeatureModuleManager? _instance;
  static FeatureModuleManager get instance => 
      _instance ??= FeatureModuleManager._();
  
  FeatureModuleManager._();
  
  final List<BaseFeatureModule> _modules = [];
  final Map<String, FeatureModuleConfig> _configs = {};
  bool _initialized = false;
  
  /// Registra um feature module
  void registerModule(BaseFeatureModule module) {
    if (_modules.any((m) => m.name == module.name)) {
      throw StateError('Module ${module.name} already registered');
    }
    
    _modules.add(module);
    _configs[module.name] = FeatureModuleConfig(
      name: module.name,
      displayName: module.displayName,
      icon: module.icon,
      version: module.version,
      description: module.description,
      enabled: module.enabled,
    );
  }
  
  /// Obtém todos os módulos registrados
  List<BaseFeatureModule> get modules => List.unmodifiable(_modules);
  
  /// Obtém módulos habilitados
  List<BaseFeatureModule> get enabledModules => 
      _modules.where((m) => m.enabled).toList();
  
  /// Busca módulo por nome
  BaseFeatureModule? getModule(String name) {
    try {
      return _modules.firstWhere((m) => m.name == name);
    } catch (e) {
      return null;
    }
  }
  
  /// Obtém configuração do módulo
  FeatureModuleConfig? getConfig(String name) {
    return _configs[name];
  }
  
  /// Inicializa todos os módulos
  Future<void> initializeModules() async {
    if (_initialized) return;
    
    for (final module in enabledModules) {
      if (module.canLoad()) {
        try {
          await module.initialize();
        } catch (e) {
          // Log error but continue initialization
          debugPrint('Error initializing module ${module.name}: $e');
        }
      }
    }
    
    _initialized = true;
  }
  
  /// Disposes todos os módulos
  Future<void> disposeModules() async {
    for (final module in _modules) {
      try {
        await module.dispose();
      } catch (e) {
        debugPrint('Error disposing module ${module.name}: $e');
      }
    }
    
    _initialized = false;
  }
  
  /// Obtém todas as rotas dos módulos habilitados
  List<RouteBase> getAllRoutes() {
    final routes = <RouteBase>[];
    
    for (final module in enabledModules) {
      if (module.canLoad()) {
        routes.addAll(module.routes);
      }
    }
    
    return routes;
  }
}