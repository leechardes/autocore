import 'package:autocore_app/core/models/api/theme_config.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static ThemeService? _instance;
  static ThemeService get instance => _instance ??= ThemeService._internal();

  ThemeService._internal();

  ThemeConfig? _currentThemeConfig;
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;
  ThemeMode _themeMode = ThemeMode.system;

  static const String _themeConfigCacheKey = 'theme_config_cache';
  static const String _themeModeKey = 'theme_mode';

  /// Aplica configuração de tema da API
  Future<void> applyThemeConfig(ThemeConfig themeConfig) async {
    try {
      _currentThemeConfig = themeConfig;

      // Gera temas baseados na configuração
      _generateThemes(themeConfig);

      // Persiste a configuração
      await _saveThemeConfig(themeConfig);

      AppLogger.config('Tema aplicado: ${themeConfig.name}');
    } catch (e) {
      AppLogger.error('Erro ao aplicar configuração de tema', error: e);
    }
  }

  /// Gera temas Light e Dark baseados na configuração
  void _generateThemes(ThemeConfig config) {
    final brightness = _getBrightnessFromMode(config.mode);

    // Cores principais
    final primaryColor = _parseColor(config.primaryColor) ?? Colors.blue;
    final secondaryColor =
        _parseColor(config.secondaryColor) ?? Colors.blueAccent;
    final backgroundColor =
        _parseColor(config.backgroundColor) ??
        (brightness == Brightness.dark ? Colors.grey[900]! : Colors.white);
    final surfaceColor = _parseColor(config.surfaceColor) ?? backgroundColor;
    final cardColor = _parseColor(config.cardColor) ?? surfaceColor;

    // Cores de texto
    final textPrimary =
        _parseColor(config.textPrimary) ??
        (brightness == Brightness.dark ? Colors.white : Colors.black);

    // Cores de status
    final successColor = _parseColor(config.successColor) ?? Colors.green;
    final warningColor = _parseColor(config.warningColor) ?? Colors.orange;
    final errorColor = _parseColor(config.errorColor) ?? Colors.red;

    // Color Scheme
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: brightness,
          primary: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
          error: errorColor,
        ).copyWith(
          surface: surfaceColor,
          onSurface: textPrimary,
          onPrimary: _getContrastingTextColor(primaryColor),
          onSecondary: _getContrastingTextColor(secondaryColor),
        );

    // Theme Data base
    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      fontFamily: config.fontFamily,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: _getContrastingTextColor(primaryColor),
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: config.fontSizeTitle,
          fontWeight: FontWeight.w600,
          color: _getContrastingTextColor(primaryColor),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: config.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _parseColor(config.buttonColor) ?? primaryColor,
          foregroundColor:
              _parseColor(config.buttonTextColor) ??
              _getContrastingTextColor(primaryColor),
          minimumSize: Size.fromHeight(config.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          elevation: 2,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _parseColor(config.switchActiveColor) ?? primaryColor;
          }
          return _parseColor(config.switchInactiveColor) ?? Colors.grey;
        }),
      ),

      // Text Theme
      textTheme: _buildTextTheme(config, brightness),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryColor),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color:
            _parseColor(config.dividerColor) ??
            (brightness == Brightness.dark ? Colors.white24 : Colors.black12),
        thickness: 1,
      ),

      // Border Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide(
            color: _parseColor(config.borderColor) ?? Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide(
            color: _parseColor(config.borderColor) ?? Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );

    // Define temas
    if (brightness == Brightness.light) {
      _lightTheme = baseTheme.copyWith(
        scaffoldBackgroundColor: backgroundColor,
        extensions: [
          _buildCustomThemeExtension(
            config,
            successColor,
            warningColor,
            errorColor,
          ),
        ],
      );
    } else {
      _darkTheme = baseTheme.copyWith(
        scaffoldBackgroundColor: backgroundColor,
        extensions: [
          _buildCustomThemeExtension(
            config,
            successColor,
            warningColor,
            errorColor,
          ),
        ],
      );
    }

    // Se o modo for auto, gera ambos os temas
    if (config.mode == 'auto') {
      _generateBothThemes(config);
    }
  }

  /// Gera tanto tema claro quanto escuro para modo automático
  void _generateBothThemes(ThemeConfig config) {
    // Salva configuração original
    final originalMode = config.mode;

    // Gera tema claro
    final lightConfig = config.copyWith(mode: 'light');
    _generateThemes(lightConfig);
    final lightTheme = _lightTheme;

    // Gera tema escuro
    final darkConfig = config.copyWith(mode: 'dark');
    _generateThemes(darkConfig);
    final darkTheme = _darkTheme;

    // Restaura temas gerados
    _lightTheme = lightTheme;
    _darkTheme = darkTheme;

    // Restaura configuração original
    _currentThemeConfig = config.copyWith(mode: originalMode);
  }

  /// Constrói tema de texto personalizado
  TextTheme _buildTextTheme(ThemeConfig config, Brightness brightness) {
    final baseColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final textColor = _parseColor(config.textPrimary) ?? baseColor;
    final secondaryTextColor =
        _parseColor(config.textSecondary) ??
        (brightness == Brightness.dark ? Colors.white70 : Colors.black54);

    return TextTheme(
      bodySmall: TextStyle(
        fontSize: config.fontSizeSmall,
        color: secondaryTextColor,
      ),
      bodyMedium: TextStyle(fontSize: config.fontSizeMedium, color: textColor),
      bodyLarge: TextStyle(
        fontSize: config.fontSizeLarge,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: config.fontSizeMedium,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: config.fontSizeLarge,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: config.fontSizeTitle,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontSize: config.fontSizeTitle,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: config.fontSizeTitle + 4,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontSize: config.fontSizeTitle + 8,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Constrói extensão de tema customizada
  CustomThemeExtension _buildCustomThemeExtension(
    ThemeConfig config,
    Color successColor,
    Color warningColor,
    Color errorColor,
  ) {
    return CustomThemeExtension(
      successColor: successColor,
      warningColor: warningColor,
      errorColor: errorColor,
      infoColor: _parseColor(config.infoColor) ?? Colors.blue,
      gaugeColorRanges: config.gaugeColorRanges,
      defaultGaugeColor: _parseColor(config.defaultGaugeColor) ?? Colors.blue,
      animationDuration: Duration(milliseconds: config.animationDuration),
      enableAnimations: config.enableAnimations,
    );
  }

  /// Obtém brightness do modo de tema
  Brightness _getBrightnessFromMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'dark':
        return Brightness.dark;
      case 'light':
        return Brightness.light;
      case 'auto':
      default:
        return Brightness.light; // Default para light
    }
  }

  /// Converte string hex para Color
  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;

    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Adiciona alpha
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      AppLogger.warning('Erro ao parsear cor: $colorHex');
      return null;
    }
  }

  /// Obtém cor de texto contrastante
  Color _getContrastingTextColor(Color backgroundColor) {
    // Calcula luminância
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Salva configuração de tema no cache
  Future<void> _saveThemeConfig(ThemeConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = config.toJson().toString();
      await prefs.setString(_themeConfigCacheKey, jsonString);
    } catch (e) {
      AppLogger.error('Erro ao salvar configuração de tema', error: e);
    }
  }

  /// Carrega configuração de tema do cache
  Future<ThemeConfig?> _loadThemeConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_themeConfigCacheKey);

      if (jsonString != null) {
        // TODO: Implementar parse do JSON para ThemeConfig
        // Por enquanto retorna null e usa tema padrão
        return null;
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar configuração de tema', error: e);
    }
    return null;
  }

  /// Altera modo de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
      AppLogger.config('Modo de tema alterado para: ${mode.name}');
    } catch (e) {
      AppLogger.error('Erro ao salvar modo de tema', error: e);
    }
  }

  /// Carrega modo de tema salvo
  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_themeModeKey);

      if (modeIndex != null && modeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[modeIndex];
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar modo de tema', error: e);
    }
  }

  /// Getters
  ThemeConfig? get currentThemeConfig => _currentThemeConfig;
  ThemeData? get lightTheme => _lightTheme;
  ThemeData? get darkTheme => _darkTheme;
  ThemeMode get themeMode => _themeMode;

  /// Verifica se tem tema customizado carregado
  bool get hasCustomTheme => _currentThemeConfig != null;

  /// Limpa tema personalizado
  Future<void> clearCustomTheme() async {
    _currentThemeConfig = null;
    _lightTheme = null;
    _darkTheme = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeConfigCacheKey);
      AppLogger.config('Tema personalizado removido');
    } catch (e) {
      AppLogger.error('Erro ao limpar tema personalizado', error: e);
    }
  }

  /// Inicializa serviço
  Future<void> initialize() async {
    await loadThemeMode();
    final cachedConfig = await _loadThemeConfig();

    if (cachedConfig != null) {
      await applyThemeConfig(cachedConfig);
    }

    AppLogger.init('ThemeService');
  }
}

/// Extensão de tema personalizada
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color successColor;
  final Color warningColor;
  final Color errorColor;
  final Color infoColor;
  final List<dynamic> gaugeColorRanges;
  final Color defaultGaugeColor;
  final Duration animationDuration;
  final bool enableAnimations;

  const CustomThemeExtension({
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.infoColor,
    required this.gaugeColorRanges,
    required this.defaultGaugeColor,
    required this.animationDuration,
    required this.enableAnimations,
  });

  @override
  CustomThemeExtension copyWith({
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? infoColor,
    List<dynamic>? gaugeColorRanges,
    Color? defaultGaugeColor,
    Duration? animationDuration,
    bool? enableAnimations,
  }) {
    return CustomThemeExtension(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      infoColor: infoColor ?? this.infoColor,
      gaugeColorRanges: gaugeColorRanges ?? this.gaugeColorRanges,
      defaultGaugeColor: defaultGaugeColor ?? this.defaultGaugeColor,
      animationDuration: animationDuration ?? this.animationDuration,
      enableAnimations: enableAnimations ?? this.enableAnimations,
    );
  }

  @override
  CustomThemeExtension lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) {
      return this;
    }

    return CustomThemeExtension(
      successColor:
          Color.lerp(successColor, other.successColor, t) ?? successColor,
      warningColor:
          Color.lerp(warningColor, other.warningColor, t) ?? warningColor,
      errorColor: Color.lerp(errorColor, other.errorColor, t) ?? errorColor,
      infoColor: Color.lerp(infoColor, other.infoColor, t) ?? infoColor,
      gaugeColorRanges: t < 0.5 ? gaugeColorRanges : other.gaugeColorRanges,
      defaultGaugeColor:
          Color.lerp(defaultGaugeColor, other.defaultGaugeColor, t) ??
          defaultGaugeColor,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
      enableAnimations: t < 0.5 ? enableAnimations : other.enableAnimations,
    );
  }
}
