import 'package:autocore_app/core/models/api/theme_config.dart';
import 'package:autocore_app/infrastructure/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para o ThemeService
final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService.instance;
});

/// Provider para inicialização do ThemeService
final themeInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(themeServiceProvider);
  await service.initialize();
});

/// StateNotifier para gerenciamento de tema
class ThemeNotifier extends StateNotifier<AsyncValue<ThemeState>> {
  ThemeNotifier(this._themeService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final ThemeService _themeService;

  Future<void> _initialize() async {
    try {
      await _themeService.initialize();
      _updateState();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Aplica configuração de tema da API
  Future<void> applyThemeConfig(ThemeConfig themeConfig) async {
    try {
      await _themeService.applyThemeConfig(themeConfig);
      _updateState();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Altera modo de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _themeService.setThemeMode(mode);
      _updateState();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Limpa tema personalizado
  Future<void> clearCustomTheme() async {
    try {
      await _themeService.clearCustomTheme();
      _updateState();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _updateState() {
    state = AsyncValue.data(
      ThemeState(
        lightTheme: _themeService.lightTheme,
        darkTheme: _themeService.darkTheme,
        themeMode: _themeService.themeMode,
        themeConfig: _themeService.currentThemeConfig,
        hasCustomTheme: _themeService.hasCustomTheme,
      ),
    );
  }
}

/// Provider para o ThemeNotifier
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, AsyncValue<ThemeState>>((ref) {
      final themeService = ref.watch(themeServiceProvider);
      return ThemeNotifier(themeService);
    });

/// Provider para obter estado atual do tema
final currentThemeStateProvider = Provider<ThemeState?>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.valueOrNull;
});

/// Provider para tema light
final lightThemeProvider = Provider<ThemeData?>((ref) {
  final themeState = ref.watch(currentThemeStateProvider);
  return themeState?.lightTheme;
});

/// Provider para tema dark
final darkThemeProvider = Provider<ThemeData?>((ref) {
  final themeState = ref.watch(currentThemeStateProvider);
  return themeState?.darkTheme;
});

/// Provider para modo de tema atual
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(currentThemeStateProvider);
  return themeState?.themeMode ?? ThemeMode.system;
});

/// Provider para configuração de tema atual
final currentThemeConfigProvider = Provider<ThemeConfig?>((ref) {
  final themeState = ref.watch(currentThemeStateProvider);
  return themeState?.themeConfig;
});

/// Provider para verificar se tem tema personalizado
final hasCustomThemeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(currentThemeStateProvider);
  return themeState?.hasCustomTheme ?? false;
});

/// Provider para cores personalizadas do tema
final customColorsProvider = Provider<CustomThemeColors?>((ref) {
  final themeConfig = ref.watch(currentThemeConfigProvider);

  if (themeConfig == null) return null;

  return CustomThemeColors(
    primary: _parseColor(themeConfig.primaryColor),
    secondary: _parseColor(themeConfig.secondaryColor),
    success: _parseColor(themeConfig.successColor),
    warning: _parseColor(themeConfig.warningColor),
    error: _parseColor(themeConfig.errorColor),
    info: _parseColor(themeConfig.infoColor),
  );
});

/// Provider para configurações de animação do tema
final themeAnimationProvider = Provider<ThemeAnimationConfig>((ref) {
  final themeConfig = ref.watch(currentThemeConfigProvider);

  return ThemeAnimationConfig(
    duration: Duration(milliseconds: themeConfig?.animationDuration ?? 300),
    enabled: themeConfig?.enableAnimations ?? true,
  );
});

/// Provider para verificar se deve usar tema escuro
final shouldUseDarkThemeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(currentThemeModeProvider);

  switch (themeMode) {
    case ThemeMode.dark:
      return true;
    case ThemeMode.light:
      return false;
    case ThemeMode.system:
      // TODO: Implementar detecção do tema do sistema
      return false;
  }
});

/// Estado do tema
class ThemeState {
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final ThemeConfig? themeConfig;
  final bool hasCustomTheme;

  const ThemeState({
    this.lightTheme,
    this.darkTheme,
    required this.themeMode,
    this.themeConfig,
    this.hasCustomTheme = false,
  });

  ThemeState copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    ThemeMode? themeMode,
    ThemeConfig? themeConfig,
    bool? hasCustomTheme,
  }) {
    return ThemeState(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeMode: themeMode ?? this.themeMode,
      themeConfig: themeConfig ?? this.themeConfig,
      hasCustomTheme: hasCustomTheme ?? this.hasCustomTheme,
    );
  }
}

/// Cores personalizadas do tema
class CustomThemeColors {
  final Color? primary;
  final Color? secondary;
  final Color? success;
  final Color? warning;
  final Color? error;
  final Color? info;

  const CustomThemeColors({
    this.primary,
    this.secondary,
    this.success,
    this.warning,
    this.error,
    this.info,
  });
}

/// Configurações de animação do tema
class ThemeAnimationConfig {
  final Duration duration;
  final bool enabled;

  const ThemeAnimationConfig({required this.duration, required this.enabled});
}

/// Helper para converter string hex para Color
Color? _parseColor(String? colorHex) {
  if (colorHex == null || colorHex.isEmpty) return null;

  try {
    String hex = colorHex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Adiciona alpha
    }
    return Color(int.parse(hex, radix: 16));
  } catch (e) {
    return null;
  }
}
