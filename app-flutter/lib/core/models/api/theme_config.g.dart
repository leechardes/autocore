// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThemeConfigImpl _$$ThemeConfigImplFromJson(Map<String, dynamic> json) =>
    _$ThemeConfigImpl(
      name: json['name'] as String,
      mode: json['mode'] as String? ?? 'light',
      primaryColor: json['primary_color'] as String,
      primaryVariant: json['primary_variant'] as String,
      secondaryColor: json['secondary_color'] as String,
      secondaryVariant: json['secondary_variant'] as String,
      backgroundColor: json['background_color'] as String,
      surfaceColor: json['surface_color'] as String,
      cardColor: json['card_color'] as String,
      textPrimary: json['text_primary'] as String,
      textSecondary: json['text_secondary'] as String,
      textDisabled: json['text_disabled'] as String,
      successColor: json['success_color'] as String? ?? '#4CAF50',
      warningColor: json['warning_color'] as String? ?? '#FF9800',
      errorColor: json['error_color'] as String? ?? '#F44336',
      infoColor: json['info_color'] as String? ?? '#2196F3',
      buttonColor: json['button_color'] as String?,
      buttonTextColor: json['button_text_color'] as String?,
      switchActiveColor: json['switch_active_color'] as String?,
      switchInactiveColor: json['switch_inactive_color'] as String?,
      borderColor: json['border_color'] as String?,
      dividerColor: json['divider_color'] as String?,
      gaugeColorRanges:
          (json['gauge_color_ranges'] as List<dynamic>?)
              ?.map((e) => ColorRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      defaultGaugeColor: json['default_gauge_color'] as String? ?? '#2196F3',
      fontFamily: json['font_family'] as String?,
      fontSizeSmall: (json['font_size_small'] as num?)?.toDouble() ?? 12.0,
      fontSizeMedium: (json['font_size_medium'] as num?)?.toDouble() ?? 14.0,
      fontSizeLarge: (json['font_size_large'] as num?)?.toDouble() ?? 16.0,
      fontSizeTitle: (json['font_size_title'] as num?)?.toDouble() ?? 20.0,
      borderRadius: (json['border_radius'] as num?)?.toDouble() ?? 8.0,
      cardElevation: (json['card_elevation'] as num?)?.toDouble() ?? 2.0,
      buttonHeight: (json['button_height'] as num?)?.toDouble() ?? 48.0,
      animationDuration: (json['animation_duration'] as num?)?.toInt() ?? 300,
      enableAnimations: json['enable_animations'] as bool? ?? true,
    );

Map<String, dynamic> _$$ThemeConfigImplToJson(_$ThemeConfigImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mode': instance.mode,
      'primary_color': instance.primaryColor,
      'primary_variant': instance.primaryVariant,
      'secondary_color': instance.secondaryColor,
      'secondary_variant': instance.secondaryVariant,
      'background_color': instance.backgroundColor,
      'surface_color': instance.surfaceColor,
      'card_color': instance.cardColor,
      'text_primary': instance.textPrimary,
      'text_secondary': instance.textSecondary,
      'text_disabled': instance.textDisabled,
      'success_color': instance.successColor,
      'warning_color': instance.warningColor,
      'error_color': instance.errorColor,
      'info_color': instance.infoColor,
      'button_color': instance.buttonColor,
      'button_text_color': instance.buttonTextColor,
      'switch_active_color': instance.switchActiveColor,
      'switch_inactive_color': instance.switchInactiveColor,
      'border_color': instance.borderColor,
      'divider_color': instance.dividerColor,
      'gauge_color_ranges': instance.gaugeColorRanges,
      'default_gauge_color': instance.defaultGaugeColor,
      'font_family': instance.fontFamily,
      'font_size_small': instance.fontSizeSmall,
      'font_size_medium': instance.fontSizeMedium,
      'font_size_large': instance.fontSizeLarge,
      'font_size_title': instance.fontSizeTitle,
      'border_radius': instance.borderRadius,
      'card_elevation': instance.cardElevation,
      'button_height': instance.buttonHeight,
      'animation_duration': instance.animationDuration,
      'enable_animations': instance.enableAnimations,
    };
