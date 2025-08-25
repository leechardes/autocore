import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'screen_config.freezed.dart';
part 'screen_config.g.dart';

@freezed
class ScreenConfig with _$ScreenConfig {
  const factory ScreenConfig({
    required String id,
    required String name,
    required String icon,
    required String route,
    required ScreenLayout layout,
    @Default([]) List<WidgetConfig> widgets,
    @Default(true) bool visible,
    @Default(0) int order,
    Map<String, dynamic>? metadata,
  }) = _ScreenConfig;

  factory ScreenConfig.fromJson(Map<String, dynamic> json) =>
      _$ScreenConfigFromJson(json);
}

@freezed
class ScreenLayout with _$ScreenLayout {
  const factory ScreenLayout({
    @Default('grid') String type, // grid, list, custom
    @Default(2) int columns,
    @Default(4) int maxColumns,
    @Default(150.0) double minItemWidth,
    @Default(1.0) double aspectRatio,
    EdgeInsetsConfig? padding,
    @Default(16.0) double spacing,
  }) = _ScreenLayout;

  factory ScreenLayout.fromJson(Map<String, dynamic> json) =>
      _$ScreenLayoutFromJson(json);
}

@freezed
class WidgetConfig with _$WidgetConfig {
  const factory WidgetConfig({
    required String id,
    required String type, // control_tile, gauge, button, container, text, etc
    required Map<String, dynamic> properties,
    @Default(true) bool visible,
    @Default([]) List<String> topics, // MQTT topics to subscribe
    @Default({}) Map<String, ActionConfig> actions,
    @Default([]) List<WidgetConfig> children,
  }) = _WidgetConfig;

  factory WidgetConfig.fromJson(Map<String, dynamic> json) =>
      _$WidgetConfigFromJson(json);
}

@freezed
class ActionConfig with _$ActionConfig {
  const factory ActionConfig({
    required String type, // mqtt_publish, navigate, dialog, macro
    required Map<String, dynamic> params,
    String? confirmMessage,
    @Default(false) bool requireConfirmation,
  }) = _ActionConfig;

  factory ActionConfig.fromJson(Map<String, dynamic> json) =>
      _$ActionConfigFromJson(json);
}

@freezed
class EdgeInsetsConfig with _$EdgeInsetsConfig {
  const factory EdgeInsetsConfig({
    @Default(0) double top,
    @Default(0) double right,
    @Default(0) double bottom,
    @Default(0) double left,
  }) = _EdgeInsetsConfig;

  factory EdgeInsetsConfig.fromJson(Map<String, dynamic> json) =>
      _$EdgeInsetsConfigFromJson(json);
}

extension EdgeInsetsConfigExtension on EdgeInsetsConfig {
  EdgeInsets toEdgeInsets() => EdgeInsets.fromLTRB(left, top, right, bottom);
}

// Control configurations
@freezed
class ControlConfig with _$ControlConfig {
  const factory ControlConfig({
    required String deviceId,
    required String channelId,
    required String label,
    String? subtitle,
    required String icon,
    @Default('toggle') String controlType,
    @Default('normal') String size,
    @Default(false) bool confirmAction,
    String? confirmMessage,
    Map<String, dynamic>? style,
  }) = _ControlConfig;

  factory ControlConfig.fromJson(Map<String, dynamic> json) =>
      _$ControlConfigFromJson(json);
}

// Device configuration
@freezed
class DeviceConfig with _$DeviceConfig {
  const factory DeviceConfig({
    required String id,
    required String name,
    required String type,
    @Default(true) bool online,
    required Map<String, ChannelConfig> channels,
    Map<String, dynamic>? metadata,
  }) = _DeviceConfig;

  factory DeviceConfig.fromJson(Map<String, dynamic> json) =>
      _$DeviceConfigFromJson(json);
}

@freezed
class ChannelConfig with _$ChannelConfig {
  const factory ChannelConfig({
    required String id,
    required String name,
    required String functionType,
    @Default(false) bool state,
    double? dimmerValue,
    @Default(true) bool allowInMacro,
    Map<String, dynamic>? metadata,
  }) = _ChannelConfig;

  factory ChannelConfig.fromJson(Map<String, dynamic> json) =>
      _$ChannelConfigFromJson(json);
}

// App configuration
@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    required String version,
    required List<ScreenConfig> screens,
    required Map<String, DeviceConfig> devices,
    ThemeConfig? theme,
    MqttConfig? mqtt,
    Map<String, dynamic>? settings,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}

@freezed
class ThemeConfig with _$ThemeConfig {
  const factory ThemeConfig({
    @Default('dark') String mode,
    String? primaryColor,
    String? accentColor,
    Map<String, dynamic>? custom,
  }) = _ThemeConfig;

  factory ThemeConfig.fromJson(Map<String, dynamic> json) =>
      _$ThemeConfigFromJson(json);
}

@freezed
class MqttConfig with _$MqttConfig {
  const factory MqttConfig({
    required String broker,
    @Default(1883) int port,
    String? username,
    String? password,
    @Default('autocore_app') String clientId,
    @Default(['autocore/#']) List<String> topics,
  }) = _MqttConfig;

  factory MqttConfig.fromJson(Map<String, dynamic> json) =>
      _$MqttConfigFromJson(json);
}
