// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ACThemeImpl _$$ACThemeImplFromJson(
  Map<String, dynamic> json,
) => _$ACThemeImpl(
  primaryColor: const ColorConverter().fromJson(
    (json['primaryColor'] as num).toInt(),
  ),
  secondaryColor: const ColorConverter().fromJson(
    (json['secondaryColor'] as num).toInt(),
  ),
  backgroundColor: const ColorConverter().fromJson(
    (json['backgroundColor'] as num).toInt(),
  ),
  surfaceColor: const ColorConverter().fromJson(
    (json['surfaceColor'] as num).toInt(),
  ),
  successColor: const ColorConverter().fromJson(
    (json['successColor'] as num).toInt(),
  ),
  warningColor: const ColorConverter().fromJson(
    (json['warningColor'] as num).toInt(),
  ),
  errorColor: const ColorConverter().fromJson(
    (json['errorColor'] as num).toInt(),
  ),
  infoColor: const ColorConverter().fromJson(
    (json['infoColor'] as num).toInt(),
  ),
  textPrimary: const ColorConverter().fromJson(
    (json['textPrimary'] as num).toInt(),
  ),
  textSecondary: const ColorConverter().fromJson(
    (json['textSecondary'] as num).toInt(),
  ),
  textTertiary: const ColorConverter().fromJson(
    (json['textTertiary'] as num).toInt(),
  ),
  elevatedShadow: const BoxShadowListConverter().fromJson(
    json['elevatedShadow'] as List<Map<String, dynamic>>,
  ),
  depressedShadow: const BoxShadowListConverter().fromJson(
    json['depressedShadow'] as List<Map<String, dynamic>>,
  ),
  subtleShadow: const BoxShadowListConverter().fromJson(
    json['subtleShadow'] as List<Map<String, dynamic>>,
  ),
  borderRadiusSmall: (json['borderRadiusSmall'] as num?)?.toDouble() ?? 8.0,
  borderRadiusMedium: (json['borderRadiusMedium'] as num?)?.toDouble() ?? 12.0,
  borderRadiusLarge: (json['borderRadiusLarge'] as num?)?.toDouble() ?? 16.0,
  spacingXs: (json['spacingXs'] as num?)?.toDouble() ?? 4.0,
  spacingSm: (json['spacingSm'] as num?)?.toDouble() ?? 8.0,
  spacingMd: (json['spacingMd'] as num?)?.toDouble() ?? 16.0,
  spacingLg: (json['spacingLg'] as num?)?.toDouble() ?? 24.0,
  spacingXl: (json['spacingXl'] as num?)?.toDouble() ?? 32.0,
  fontFamily: json['fontFamily'] as String? ?? 'Inter',
  fontSizeSmall: (json['fontSizeSmall'] as num?)?.toDouble() ?? 11.0,
  fontSizeMedium: (json['fontSizeMedium'] as num?)?.toDouble() ?? 14.0,
  fontSizeLarge: (json['fontSizeLarge'] as num?)?.toDouble() ?? 24.0,
  fontWeightLight: json['fontWeightLight'] == null
      ? FontWeight.w300
      : const FontWeightConverter().fromJson(json['fontWeightLight'] as String),
  fontWeightRegular: json['fontWeightRegular'] == null
      ? FontWeight.w400
      : const FontWeightConverter().fromJson(
          json['fontWeightRegular'] as String,
        ),
  fontWeightBold: json['fontWeightBold'] == null
      ? FontWeight.w600
      : const FontWeightConverter().fromJson(json['fontWeightBold'] as String),
  animationFast: json['animationFast'] == null
      ? const Duration(milliseconds: 200)
      : const DurationConverter().fromJson(
          (json['animationFast'] as num).toInt(),
        ),
  animationNormal: json['animationNormal'] == null
      ? const Duration(milliseconds: 300)
      : const DurationConverter().fromJson(
          (json['animationNormal'] as num).toInt(),
        ),
  animationSlow: json['animationSlow'] == null
      ? const Duration(milliseconds: 500)
      : const DurationConverter().fromJson(
          (json['animationSlow'] as num).toInt(),
        ),
  animationCurve: json['animationCurve'] == null
      ? Curves.easeInOut
      : const CurveConverter().fromJson(json['animationCurve'] as String),
);

Map<String, dynamic> _$$ACThemeImplToJson(
  _$ACThemeImpl instance,
) => <String, dynamic>{
  'primaryColor': const ColorConverter().toJson(instance.primaryColor),
  'secondaryColor': const ColorConverter().toJson(instance.secondaryColor),
  'backgroundColor': const ColorConverter().toJson(instance.backgroundColor),
  'surfaceColor': const ColorConverter().toJson(instance.surfaceColor),
  'successColor': const ColorConverter().toJson(instance.successColor),
  'warningColor': const ColorConverter().toJson(instance.warningColor),
  'errorColor': const ColorConverter().toJson(instance.errorColor),
  'infoColor': const ColorConverter().toJson(instance.infoColor),
  'textPrimary': const ColorConverter().toJson(instance.textPrimary),
  'textSecondary': const ColorConverter().toJson(instance.textSecondary),
  'textTertiary': const ColorConverter().toJson(instance.textTertiary),
  'elevatedShadow': const BoxShadowListConverter().toJson(
    instance.elevatedShadow,
  ),
  'depressedShadow': const BoxShadowListConverter().toJson(
    instance.depressedShadow,
  ),
  'subtleShadow': const BoxShadowListConverter().toJson(instance.subtleShadow),
  'borderRadiusSmall': instance.borderRadiusSmall,
  'borderRadiusMedium': instance.borderRadiusMedium,
  'borderRadiusLarge': instance.borderRadiusLarge,
  'spacingXs': instance.spacingXs,
  'spacingSm': instance.spacingSm,
  'spacingMd': instance.spacingMd,
  'spacingLg': instance.spacingLg,
  'spacingXl': instance.spacingXl,
  'fontFamily': instance.fontFamily,
  'fontSizeSmall': instance.fontSizeSmall,
  'fontSizeMedium': instance.fontSizeMedium,
  'fontSizeLarge': instance.fontSizeLarge,
  'fontWeightLight': const FontWeightConverter().toJson(
    instance.fontWeightLight,
  ),
  'fontWeightRegular': const FontWeightConverter().toJson(
    instance.fontWeightRegular,
  ),
  'fontWeightBold': const FontWeightConverter().toJson(instance.fontWeightBold),
  'animationFast': const DurationConverter().toJson(instance.animationFast),
  'animationNormal': const DurationConverter().toJson(instance.animationNormal),
  'animationSlow': const DurationConverter().toJson(instance.animationSlow),
  'animationCurve': const CurveConverter().toJson(instance.animationCurve),
};
