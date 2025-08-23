# A19 - Theme Integration Implementation

## 📋 Objetivo
Implementar integração completa do sistema de temas da API com o app Flutter, aplicando cores e estilos dinamicamente.

## 🎯 Componentes a Implementar

### 1. ThemeService
```dart
// lib/infrastructure/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:autocore_app/core/models/api/theme_config.dart';
import 'package:autocore_app/infrastructure/services/config_service.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static ThemeService? _instance;
  static ThemeService get instance => _instance ??= ThemeService._();

  ThemeService._();

  final ConfigService _configService = ConfigService.instance;
  
  // Cache keys
  static const String _themeModeKey = 'theme_mode';
  static const String _customThemeKey = 'custom_theme';
  
  // Estado
  ThemeMode _themeMode = ThemeMode.system;
  ThemeConfig? _customTheme;
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  ThemeConfig? get customTheme => _customTheme;
  
  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      // Carregar preferências salvas
      await _loadPreferences();
      
      // Tentar carregar tema da API
      final apiTheme = _configService.getTheme();
      if (apiTheme != null) {
        _customTheme = apiTheme;
        AppLogger.info('Theme loaded from API: ${apiTheme.name}');
      }
      
    } catch (e, stack) {
      AppLogger.error('Failed to initialize ThemeService', 
        error: e, stackTrace: stack);
    }
  }
  
  /// Constrói ThemeData do Flutter baseado no ThemeConfig da API
  ThemeData buildThemeData(ThemeConfig config, {bool isDark = false}) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    // Converter cores da API
    final primaryColor = _parseColor(config.primaryColor);
    final secondaryColor = _parseColor(config.secondaryColor);
    final backgroundColor = _parseColor(config.backgroundColor);
    final surfaceColor = _parseColor(config.surfaceColor);
    final errorColor = _parseColor(config.errorColor);
    final warningColor = _parseColor(config.warningColor);
    final successColor = _parseColor(config.successColor);
    final infoColor = _parseColor(config.infoColor);
    
    // Cores de texto
    final textPrimary = _parseColor(config.textPrimary);
    final textSecondary = _parseColor(config.textSecondary);
    
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textPrimary),
        displayMedium: TextStyle(color: textPrimary),
        displaySmall: TextStyle(color: textPrimary),
        headlineLarge: TextStyle(color: textPrimary),
        headlineMedium: TextStyle(color: textPrimary),
        headlineSmall: TextStyle(color: textPrimary),
        titleLarge: TextStyle(color: textPrimary),
        titleMedium: TextStyle(color: textPrimary),
        titleSmall: TextStyle(color: textPrimary),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary),
        labelMedium: TextStyle(color: textPrimary),
        labelSmall: TextStyle(color: textSecondary),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: textSecondary.withOpacity(0.2),
        thickness: 1,
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // Extensions para cores customizadas
      extensions: [
        CustomColors(
          warning: warningColor,
          success: successColor,
          info: infoColor,
        ),
      ],
    );
  }
  
  /// Obtém ThemeData baseado no modo atual
  ThemeData getTheme({required bool isDark}) {
    if (_customTheme != null) {
      return buildThemeData(_customTheme!, isDark: isDark);
    }
    
    // Fallback para tema padrão
    return _getDefaultTheme(isDark: isDark);
  }
  
  /// Altera o modo do tema
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _savePreferences();
    AppLogger.info('Theme mode changed to: $mode');
  }
  
  /// Aplica tema customizado
  Future<void> applyCustomTheme(ThemeConfig theme) async {
    _customTheme = theme;
    await _saveCustomTheme(theme);
    AppLogger.info('Custom theme applied: ${theme.name}');
  }
  
  /// Reseta para tema padrão
  Future<void> resetToDefault() async {
    _customTheme = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customThemeKey);
    AppLogger.info('Theme reset to default');
  }
  
  /// Carrega preferências salvas
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme mode
    final modeIndex = prefs.getInt(_themeModeKey) ?? 0;
    _themeMode = ThemeMode.values[modeIndex];
    
    // Custom theme
    final themeJson = prefs.getString(_customThemeKey);
    if (themeJson != null) {
      try {
        final json = jsonDecode(themeJson) as Map<String, dynamic>;
        _customTheme = ThemeConfig.fromJson(json);
      } catch (e) {
        AppLogger.error('Failed to parse saved theme', error: e);
      }
    }
  }
  
  /// Salva preferências
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, _themeMode.index);
  }
  
  /// Salva tema customizado
  Future<void> _saveCustomTheme(ThemeConfig theme) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(theme.toJson());
    await prefs.setString(_customThemeKey, json);
  }
  
  /// Parse cor hexadecimal
  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Adiciona alpha se não tiver
    }
    return Color(int.parse(hex, radix: 16));
  }
  
  /// Tema padrão fallback
  ThemeData _getDefaultTheme({required bool isDark}) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }
}

/// Extension para cores customizadas
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color warning;
  final Color success;
  final Color info;
  
  const CustomColors({
    required this.warning,
    required this.success,
    required this.info,
  });
  
  @override
  CustomColors copyWith({
    Color? warning,
    Color? success,
    Color? info,
  }) {
    return CustomColors(
      warning: warning ?? this.warning,
      success: success ?? this.success,
      info: info ?? this.info,
    );
  }
  
  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    
    return CustomColors(
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
```

### 2. ThemeProvider
```dart
// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocore_app/infrastructure/services/theme_service.dart';

final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService.instance;
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(themeServiceProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ThemeService _themeService;
  
  ThemeModeNotifier(this._themeService) : super(_themeService.themeMode);
  
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _themeService.setThemeMode(mode);
  }
}

final lightThemeProvider = Provider<ThemeData>((ref) {
  final service = ref.watch(themeServiceProvider);
  return service.getTheme(isDark: false);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final service = ref.watch(themeServiceProvider);
  return service.getTheme(isDark: true);
});
```

### 3. App Integration
```dart
// lib/app.dart - Atualização
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocore_app/providers/theme_provider.dart';

class AutoCoreApp extends ConsumerWidget {
  const AutoCoreApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    
    return MaterialApp(
      title: 'AutoCore',
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      // ... resto da configuração
    );
  }
}
```

### 4. Theme Extensions Helper
```dart
// lib/core/extensions/theme_extensions.dart
import 'package:flutter/material.dart';
import 'package:autocore_app/infrastructure/services/theme_service.dart';

extension ThemeContextExtension on BuildContext {
  CustomColors? get customColors => 
      Theme.of(this).extension<CustomColors>();
  
  Color get warningColor => 
      customColors?.warning ?? Colors.orange;
  
  Color get successColor => 
      customColors?.success ?? Colors.green;
  
  Color get infoColor => 
      customColors?.info ?? Colors.blue;
}

// Uso em widgets:
// context.warningColor
// context.successColor
// context.infoColor
```

## ✅ Checklist de Implementação

- [ ] Criar ThemeService singleton
- [ ] Implementar parsing de cores da API
- [ ] Criar ThemeData builder
- [ ] Adicionar persistência local
- [ ] Implementar providers Riverpod
- [ ] Integrar com App principal
- [ ] Criar extension para cores custom
- [ ] Adicionar fallback para tema padrão
- [ ] Testar com diferentes temas da API

## 🚀 Comandos de Execução

```bash
# 1. Criar arquivos
touch lib/infrastructure/services/theme_service.dart
touch lib/providers/theme_provider.dart
touch lib/core/extensions/theme_extensions.dart

# 2. Atualizar app.dart
# Adicionar integração com providers

# 3. Testar tema
flutter run
```

## 📊 Resultado Esperado

Após implementação:
- ✅ Tema da API aplicado automaticamente
- ✅ Cores customizadas funcionando
- ✅ Persistência de preferências
- ✅ Troca dinâmica de tema
- ✅ Fallback para tema padrão
- ✅ Extensions para cores especiais

---

**Prioridade**: P1 - ALTO
**Tempo estimado**: 2-3 horas
**Dependências**: A15, A16