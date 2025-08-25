import 'package:autocore_app/core/theme/color_converter.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_model.freezed.dart';
part 'theme_model.g.dart';

@freezed
class ACTheme with _$ACTheme {
  @JsonSerializable(explicitToJson: true)
  const factory ACTheme({
    // Cores principais
    @ColorConverter() required Color primaryColor,
    @ColorConverter() required Color secondaryColor,
    @ColorConverter() required Color backgroundColor,
    @ColorConverter() required Color surfaceColor,

    // Cores de estado
    @ColorConverter() required Color successColor,
    @ColorConverter() required Color warningColor,
    @ColorConverter() required Color errorColor,
    @ColorConverter() required Color infoColor,

    // Cores de texto
    @ColorConverter() required Color textPrimary,
    @ColorConverter() required Color textSecondary,
    @ColorConverter() required Color textTertiary,

    // Sombras (Neumorfismo)
    @BoxShadowListConverter() required List<BoxShadow> elevatedShadow,
    @BoxShadowListConverter() required List<BoxShadow> depressedShadow,
    @BoxShadowListConverter() required List<BoxShadow> subtleShadow,

    // Dimensões
    @Default(8.0) double borderRadiusSmall,
    @Default(12.0) double borderRadiusMedium,
    @Default(16.0) double borderRadiusLarge,

    // Espaçamentos
    @Default(4.0) double spacingXs,
    @Default(8.0) double spacingSm,
    @Default(16.0) double spacingMd,
    @Default(24.0) double spacingLg,
    @Default(32.0) double spacingXl,

    // Tipografia - Ajustada para match com frontend React
    @Default('Inter') String fontFamily, // Match com React (Inter)
    @Default(11.0) double fontSizeSmall, // text-xs (12px no web = 11pt mobile)
    @Default(14.0) double fontSizeMedium, // text-sm equivalente
    @Default(24.0) double fontSizeLarge, // text-2xl para valores
    @FontWeightConverter() @Default(FontWeight.w300) FontWeight fontWeightLight,
    @FontWeightConverter()
    @Default(FontWeight.w400)
    FontWeight fontWeightRegular,
    @FontWeightConverter() @Default(FontWeight.w600) FontWeight fontWeightBold,

    // Animações - Especificação A34-PHASE3-POLISH-FIXES: transições suaves 200-300ms
    @DurationConverter()
    @Default(Duration(milliseconds: 200))
    Duration animationFast, // 200ms conforme especificação
    @DurationConverter()
    @Default(Duration(milliseconds: 300))
    Duration animationNormal, // 300ms conforme especificação
    @DurationConverter()
    @Default(Duration(milliseconds: 500))
    Duration animationSlow,
    @CurveConverter() @Default(Curves.easeInOut) Curve animationCurve,
  }) = _ACTheme;

  factory ACTheme.fromJson(Map<String, dynamic> json) =>
      _$ACThemeFromJson(json);

  static ACTheme defaultDark() => ACTheme(
    // Cores principais - Especificação A32-PHASE1-CRITICAL-FIXES
    primaryColor: const Color(0xFF007AFF),
    secondaryColor: const Color(0xFF5AC8FA),
    backgroundColor: const Color(0xFF0A0A0B), // #0A0A0B especificação FASE 1
    surfaceColor: const Color(0xFF18181B), // #18181B especificação FASE 1
    // Cores de estado
    successColor: const Color(0xFF4CAF50),
    warningColor: const Color(0xFFFF9800),
    errorColor: const Color(0xFFF44336),
    infoColor: const Color(0xFF2196F3),

    // Cores de texto - Especificação A32-PHASE1-CRITICAL-FIXES
    textPrimary: const Color(0xFFFAFAFA), // #FAFAFA mais sutil que branco puro
    textSecondary: const Color(0xFFA1A1AA), // #A1A1AA especificação FASE 1
    textTertiary: const Color(0xFF71717A), // #71717A mais consistente com theme
    // Sombras neumórficas
    elevatedShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        offset: const Offset(2, 2),
        blurRadius: 6,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.05),
        offset: const Offset(-2, -2),
        blurRadius: 6,
      ),
    ],
    depressedShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        offset: const Offset(-2, -2),
        blurRadius: 4,
        spreadRadius: -2,
        blurStyle: BlurStyle.inner,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.03),
        offset: const Offset(2, 2),
        blurRadius: 4,
        spreadRadius: -2,
        blurStyle: BlurStyle.inner,
      ),
    ],
    subtleShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        offset: const Offset(0, 1),
        blurRadius: 3,
      ),
    ],
  );

  static ACTheme defaultLight() => ACTheme(
    // Cores principais
    primaryColor: const Color(0xFF007AFF),
    secondaryColor: const Color(0xFF5AC8FA),
    backgroundColor: const Color(0xFFF2F2F7),
    surfaceColor: const Color(0xFFFFFFFF),

    // Cores de estado
    successColor: const Color(0xFF4CAF50),
    warningColor: const Color(0xFFFF9800),
    errorColor: const Color(0xFFF44336),
    infoColor: const Color(0xFF2196F3),

    // Cores de texto
    textPrimary: const Color(0xFF000000),
    textSecondary: const Color(0xFF666666),
    textTertiary: const Color(0xFF999999),

    // Sombras neumórficas
    elevatedShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.3),
        offset: const Offset(2, 2),
        blurRadius: 6,
      ),
      const BoxShadow(
        color: Colors.white,
        offset: Offset(-2, -2),
        blurRadius: 6,
      ),
    ],
    depressedShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.3),
        offset: const Offset(-2, -2),
        blurRadius: 4,
        spreadRadius: -2,
        blurStyle: BlurStyle.inner,
      ),
      const BoxShadow(
        color: Colors.white,
        offset: Offset(2, 2),
        blurRadius: 4,
        spreadRadius: -2,
        blurStyle: BlurStyle.inner,
      ),
    ],
    subtleShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.2),
        offset: const Offset(0, 1),
        blurRadius: 3,
      ),
    ],
  );
}
