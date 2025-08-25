import 'package:autocore_app/infrastructure/services/theme_service.dart';
import 'package:flutter/material.dart';

/// Extensões para facilitar acesso às cores personalizadas do tema
extension ThemeExtensions on ThemeData {
  /// Obtém extensão personalizada do tema
  CustomThemeExtension? get customTheme {
    return extension<CustomThemeExtension>();
  }

  /// Cores de status
  Color get successColor {
    return customTheme?.successColor ?? Colors.green;
  }

  Color get warningColor {
    return customTheme?.warningColor ?? Colors.orange;
  }

  Color get errorColor {
    return customTheme?.errorColor ?? colorScheme.error;
  }

  Color get infoColor {
    return customTheme?.infoColor ?? Colors.blue;
  }

  /// Cor padrão para gauges
  Color get defaultGaugeColor {
    return customTheme?.defaultGaugeColor ?? colorScheme.primary;
  }

  /// Configurações de animação
  Duration get animationDuration {
    return customTheme?.animationDuration ?? const Duration(milliseconds: 300);
  }

  bool get enableAnimations {
    return customTheme?.enableAnimations ?? true;
  }

  /// Ranges de cores para gauges
  List<dynamic> get gaugeColorRanges {
    return customTheme?.gaugeColorRanges ?? [];
  }
}

/// Extensões para BuildContext para acesso fácil ao tema
extension ThemeContextExtensions on BuildContext {
  /// Acesso rápido ao ThemeData
  ThemeData get theme => Theme.of(this);

  /// Acesso rápido ao ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Acesso rápido ao TextTheme
  TextTheme get textTheme => theme.textTheme;

  /// Cores personalizadas
  CustomThemeExtension? get customTheme => theme.customTheme;

  /// Cores de status
  Color get successColor => theme.successColor;
  Color get warningColor => theme.warningColor;
  Color get errorColor => theme.errorColor;
  Color get infoColor => theme.infoColor;

  /// Cores semânticas baseadas no contexto
  Color getSemanticColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return successColor;
      case 'warning':
        return warningColor;
      case 'error':
      case 'danger':
        return errorColor;
      case 'info':
        return infoColor;
      case 'primary':
        return colorScheme.primary;
      case 'secondary':
        return colorScheme.secondary;
      default:
        return colorScheme.onSurface;
    }
  }

  /// Verifica se está usando tema escuro
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Verifica se está usando tema claro
  bool get isLightMode => theme.brightness == Brightness.light;
}

/// Extensões para cores com utilidades
extension ColorExtensions on Color {
  /// Obtém cor contrastante (preto ou branco)
  Color get contrastingColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Obtém versão mais escura da cor
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  /// Obtém versão mais clara da cor
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightened.toColor();
  }

  /// Obtém versão com opacidade
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  /// Converte para string hexadecimal
  String toHex({bool includeAlpha = true}) {
    if (includeAlpha) {
      return '#${(a * 255).round().toRadixString(16).padLeft(2, '0')}${(r * 255).round().toRadixString(16).padLeft(2, '0')}${(g * 255).round().toRadixString(16).padLeft(2, '0')}${(b * 255).round().toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    } else {
      return '#${(r * 255).round().toRadixString(16).padLeft(2, '0')}${(g * 255).round().toRadixString(16).padLeft(2, '0')}${(b * 255).round().toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    }
  }

  /// Verifica se a cor é clara
  bool get isLight => computeLuminance() > 0.5;

  /// Verifica se a cor é escura
  bool get isDark => !isLight;
}

/// Extensões para trabalhar com ranges de cores
extension ColorRangeExtensions on List<Map<String, dynamic>> {
  /// Obtém cor baseada no valor
  Color? getColorForValue(double value, Color defaultColor) {
    // Ordena por prioridade (maior prioridade primeiro)
    final sortedRanges = [...this];
    sortedRanges.sort(
      (a, b) => ((b['priority'] as int?) ?? 0).compareTo(
        (a['priority'] as int?) ?? 0,
      ),
    );

    for (final range in sortedRanges) {
      final min = range['min'] as double?;
      final max = range['max'] as double?;
      final colorHex = range['color'] as String?;

      if (min != null && max != null && value >= min && value <= max) {
        final color = _parseColor(colorHex);
        if (color != null) return color;
      }
    }

    return defaultColor;
  }
}

/// Helper para converter hex para Color
Color? _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;

  try {
    String cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex'; // Adiciona alpha
    }
    return Color(int.parse(cleanHex, radix: 16));
  } catch (e) {
    return null;
  }
}

/// Mixin para widgets que precisam de cores de status
mixin StatusColorMixin {
  Color getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'connected':
      case 'active':
      case 'running':
        return context.successColor;
      case 'warning':
      case 'unstable':
      case 'degraded':
        return context.warningColor;
      case 'offline':
      case 'disconnected':
      case 'error':
      case 'failed':
        return context.errorColor;
      case 'info':
      case 'pending':
      case 'loading':
        return context.infoColor;
      default:
        return context.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'connected':
        return Icons.wifi;
      case 'offline':
      case 'disconnected':
        return Icons.wifi_off;
      case 'warning':
      case 'unstable':
        return Icons.warning;
      case 'error':
      case 'failed':
        return Icons.error;
      case 'loading':
      case 'pending':
        return Icons.hourglass_empty;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }
}
