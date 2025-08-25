import 'package:autocore_app/core/theme/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para o tema atual
final themeProvider = StateNotifierProvider<ThemeNotifier, ACTheme>((ref) {
  return ThemeNotifier();
});

// Provider para o modo do tema (dark/light)
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark;
});

// StateNotifier para gerenciar o tema
class ThemeNotifier extends StateNotifier<ACTheme> {
  ThemeNotifier() : super(ACTheme.defaultDark());

  // Alterna entre tema claro e escuro
  void toggleTheme() {
    state = state == ACTheme.defaultDark()
        ? ACTheme.defaultLight()
        : ACTheme.defaultDark();
  }

  // Define um tema específico
  void setTheme(ACTheme theme) {
    state = theme;
  }

  // Atualiza o tema a partir de JSON
  void updateFromJson(Map<String, dynamic> json) {
    state = ACTheme.fromJson(json);
  }

  // Atualiza cores específicas
  void updateColors({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? infoColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
  }) {
    state = state.copyWith(
      primaryColor: primaryColor ?? state.primaryColor,
      secondaryColor: secondaryColor ?? state.secondaryColor,
      backgroundColor: backgroundColor ?? state.backgroundColor,
      surfaceColor: surfaceColor ?? state.surfaceColor,
      successColor: successColor ?? state.successColor,
      warningColor: warningColor ?? state.warningColor,
      errorColor: errorColor ?? state.errorColor,
      infoColor: infoColor ?? state.infoColor,
      textPrimary: textPrimary ?? state.textPrimary,
      textSecondary: textSecondary ?? state.textSecondary,
      textTertiary: textTertiary ?? state.textTertiary,
    );
  }

  // Atualiza espaçamentos
  void updateSpacing({
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
  }) {
    state = state.copyWith(
      spacingXs: spacingXs ?? state.spacingXs,
      spacingSm: spacingSm ?? state.spacingSm,
      spacingMd: spacingMd ?? state.spacingMd,
      spacingLg: spacingLg ?? state.spacingLg,
      spacingXl: spacingXl ?? state.spacingXl,
    );
  }

  // Atualiza border radius
  void updateBorderRadius({
    double? borderRadiusSmall,
    double? borderRadiusMedium,
    double? borderRadiusLarge,
  }) {
    state = state.copyWith(
      borderRadiusSmall: borderRadiusSmall ?? state.borderRadiusSmall,
      borderRadiusMedium: borderRadiusMedium ?? state.borderRadiusMedium,
      borderRadiusLarge: borderRadiusLarge ?? state.borderRadiusLarge,
    );
  }

  // Atualiza fontes
  void updateTypography({
    String? fontFamily,
    double? fontSizeSmall,
    double? fontSizeMedium,
    double? fontSizeLarge,
    FontWeight? fontWeightLight,
    FontWeight? fontWeightRegular,
    FontWeight? fontWeightBold,
  }) {
    state = state.copyWith(
      fontFamily: fontFamily ?? state.fontFamily,
      fontSizeSmall: fontSizeSmall ?? state.fontSizeSmall,
      fontSizeMedium: fontSizeMedium ?? state.fontSizeMedium,
      fontSizeLarge: fontSizeLarge ?? state.fontSizeLarge,
      fontWeightLight: fontWeightLight ?? state.fontWeightLight,
      fontWeightRegular: fontWeightRegular ?? state.fontWeightRegular,
      fontWeightBold: fontWeightBold ?? state.fontWeightBold,
    );
  }

  // Atualiza animações
  void updateAnimations({
    Duration? animationFast,
    Duration? animationNormal,
    Duration? animationSlow,
    Curve? animationCurve,
  }) {
    state = state.copyWith(
      animationFast: animationFast ?? state.animationFast,
      animationNormal: animationNormal ?? state.animationNormal,
      animationSlow: animationSlow ?? state.animationSlow,
      animationCurve: animationCurve ?? state.animationCurve,
    );
  }

  // Atualiza sombras
  void updateShadows({
    List<BoxShadow>? elevatedShadow,
    List<BoxShadow>? depressedShadow,
    List<BoxShadow>? subtleShadow,
  }) {
    state = state.copyWith(
      elevatedShadow: elevatedShadow ?? state.elevatedShadow,
      depressedShadow: depressedShadow ?? state.depressedShadow,
      subtleShadow: subtleShadow ?? state.subtleShadow,
    );
  }
}
