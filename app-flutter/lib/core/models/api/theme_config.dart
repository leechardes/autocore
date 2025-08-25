import 'package:autocore_app/core/models/api/color_range.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_config.freezed.dart';
part 'theme_config.g.dart';

@freezed
class ThemeConfig with _$ThemeConfig {
  const factory ThemeConfig({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'mode')
    @Default('light')
    String mode, // 'light', 'dark', 'auto'
    // Primary colors
    @JsonKey(name: 'primary_color') required String primaryColor,
    @JsonKey(name: 'primary_variant') required String primaryVariant,
    @JsonKey(name: 'secondary_color') required String secondaryColor,
    @JsonKey(name: 'secondary_variant') required String secondaryVariant,

    // Background colors
    @JsonKey(name: 'background_color') required String backgroundColor,
    @JsonKey(name: 'surface_color') required String surfaceColor,
    @JsonKey(name: 'card_color') required String cardColor,

    // Text colors
    @JsonKey(name: 'text_primary') required String textPrimary,
    @JsonKey(name: 'text_secondary') required String textSecondary,
    @JsonKey(name: 'text_disabled') required String textDisabled,

    // Status colors
    @JsonKey(name: 'success_color') @Default('#4CAF50') String successColor,
    @JsonKey(name: 'warning_color') @Default('#FF9800') String warningColor,
    @JsonKey(name: 'error_color') @Default('#F44336') String errorColor,
    @JsonKey(name: 'info_color') @Default('#2196F3') String infoColor,

    // UI Element colors
    @JsonKey(name: 'button_color') String? buttonColor,
    @JsonKey(name: 'button_text_color') String? buttonTextColor,
    @JsonKey(name: 'switch_active_color') String? switchActiveColor,
    @JsonKey(name: 'switch_inactive_color') String? switchInactiveColor,

    // Border and divider colors
    @JsonKey(name: 'border_color') String? borderColor,
    @JsonKey(name: 'divider_color') String? dividerColor,

    // Gauge and indicator colors
    @JsonKey(name: 'gauge_color_ranges')
    @Default([])
    List<ColorRange> gaugeColorRanges,
    @JsonKey(name: 'default_gauge_color')
    @Default('#2196F3')
    String defaultGaugeColor,

    // Typography
    @JsonKey(name: 'font_family') String? fontFamily,
    @JsonKey(name: 'font_size_small') @Default(12.0) double fontSizeSmall,
    @JsonKey(name: 'font_size_medium') @Default(14.0) double fontSizeMedium,
    @JsonKey(name: 'font_size_large') @Default(16.0) double fontSizeLarge,
    @JsonKey(name: 'font_size_title') @Default(20.0) double fontSizeTitle,

    // Spacing and dimensions
    @JsonKey(name: 'border_radius') @Default(8.0) double borderRadius,
    @JsonKey(name: 'card_elevation') @Default(2.0) double cardElevation,
    @JsonKey(name: 'button_height') @Default(48.0) double buttonHeight,

    // Animation settings
    @JsonKey(name: 'animation_duration') @Default(300) int animationDuration,
    @JsonKey(name: 'enable_animations') @Default(true) bool enableAnimations,
  }) = _ThemeConfig;

  factory ThemeConfig.fromJson(Map<String, dynamic> json) =>
      _$ThemeConfigFromJson(json);
}
