import 'package:freezed_annotation/freezed_annotation.dart';

part 'screen_config.freezed.dart';
part 'screen_config.g.dart';

/// Configuração de uma tela dinâmica do app
///
/// Define como uma tela deve ser renderizada, incluindo:
/// - Informações básicas da tela (nome, ícone, rota)
/// - Lista de itens/widgets a serem exibidos
/// - Layout e organização dos elementos
@freezed
class ScreenConfig with _$ScreenConfig {
  const factory ScreenConfig({
    required String id,
    required String name,
    String? description,
    String? icon,
    String? route,
    @Default([]) List<ScreenItem> items,
    @Default('grid') String layout, // 'grid', 'list', 'tabs', 'custom'
    @Default(2) int columns,
    @Default(true) bool showHeader,
    @Default(true) bool showNavigation,
    Map<String, dynamic>? customProperties,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ScreenConfig;

  factory ScreenConfig.fromJson(Map<String, dynamic> json) =>
      _$ScreenConfigFromJson(json);
}

/// Item individual de uma tela (botão, indicador, controle, etc.)
@freezed
class ScreenItem with _$ScreenItem {
  const factory ScreenItem({
    required String id,
    required String type, // 'button', 'indicator', 'gauge', 'macro', 'custom'
    required String label,
    String? description,
    String? icon,
    @Default(true) bool visible,
    @Default(true) bool enabled,
    int? position,
    int? row,
    int? column,

    // Ação do item (para botões e macros)
    ScreenItemAction? action,

    // Configurações específicas por tipo
    Map<String, dynamic>? properties,

    // Configurações de layout
    int? width,
    int? height,
    String? backgroundColor,
    String? textColor,

    // Para botões de relé
    int? relayBoardId,
    int? relayChannelId,
    String? functionType,

    // Para indicadores
    String? statusTopic,
    String? statusField,

    // Para macros
    int? macroId,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ScreenItem;

  factory ScreenItem.fromJson(Map<String, dynamic> json) =>
      _$ScreenItemFromJson(json);
}

/// Ação de um item de tela
@freezed
class ScreenItemAction with _$ScreenItemAction {
  const factory ScreenItemAction({
    required String
    type, // 'execute_macro', 'relay_command', 'navigate', 'http_request', 'mqtt_publish'
    Map<String, dynamic>? parameters,

    // Para execute_macro
    int? macroId,

    // Para relay_command
    int? boardId,
    int? channel,
    bool? state,
    bool? momentary,

    // Para navigate
    String? route,
    Map<String, String>? routeParams,

    // Para http_request
    String? url,
    String? method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,

    // Para mqtt_publish
    String? topic,
    Map<String, dynamic>? payload,
    bool? retain,
    int? qos,
  }) = _ScreenItemAction;

  factory ScreenItemAction.fromJson(Map<String, dynamic> json) =>
      _$ScreenItemActionFromJson(json);
}

/// Configuração completa da aplicação (múltiplas telas)
@freezed
class AppScreensConfig with _$AppScreensConfig {
  const factory AppScreensConfig({
    @Default('1.0.0') String version,
    @Default([]) List<ScreenConfig> screens,
    @Default('dashboard') String defaultScreen,
    @Default({}) Map<String, dynamic> globalSettings,
    DateTime? lastUpdated,
    String? configSource, // 'backend', 'cache', 'default'
  }) = _AppScreensConfig;

  factory AppScreensConfig.fromJson(Map<String, dynamic> json) =>
      _$AppScreensConfigFromJson(json);

  const AppScreensConfig._();

  /// Encontra uma tela por ID
  ScreenConfig? getScreen(String id) {
    try {
      return screens.firstWhere((screen) => screen.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtém todas as telas visíveis para navegação
  List<ScreenConfig> get navigableScreens {
    return screens.where((screen) => screen.showNavigation).toList();
  }

  /// Obtém a tela padrão ou a primeira disponível
  ScreenConfig? get defaultScreenConfig {
    final defaultScr = getScreen(defaultScreen);
    if (defaultScr != null) return defaultScr;

    return screens.isNotEmpty ? screens.first : null;
  }
}
