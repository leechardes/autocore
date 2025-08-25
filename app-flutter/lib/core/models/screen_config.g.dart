// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScreenConfigImpl _$$ScreenConfigImplFromJson(Map<String, dynamic> json) =>
    _$ScreenConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      route: json['route'] as String,
      layout: ScreenLayout.fromJson(json['layout'] as Map<String, dynamic>),
      widgets:
          (json['widgets'] as List<dynamic>?)
              ?.map((e) => WidgetConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      visible: json['visible'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ScreenConfigImplToJson(_$ScreenConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'route': instance.route,
      'layout': instance.layout,
      'widgets': instance.widgets,
      'visible': instance.visible,
      'order': instance.order,
      'metadata': instance.metadata,
    };

_$ScreenLayoutImpl _$$ScreenLayoutImplFromJson(Map<String, dynamic> json) =>
    _$ScreenLayoutImpl(
      type: json['type'] as String? ?? 'grid',
      columns: (json['columns'] as num?)?.toInt() ?? 2,
      maxColumns: (json['maxColumns'] as num?)?.toInt() ?? 4,
      minItemWidth: (json['minItemWidth'] as num?)?.toDouble() ?? 150.0,
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 1.0,
      padding: json['padding'] == null
          ? null
          : EdgeInsetsConfig.fromJson(json['padding'] as Map<String, dynamic>),
      spacing: (json['spacing'] as num?)?.toDouble() ?? 16.0,
    );

Map<String, dynamic> _$$ScreenLayoutImplToJson(_$ScreenLayoutImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'columns': instance.columns,
      'maxColumns': instance.maxColumns,
      'minItemWidth': instance.minItemWidth,
      'aspectRatio': instance.aspectRatio,
      'padding': instance.padding,
      'spacing': instance.spacing,
    };

_$WidgetConfigImpl _$$WidgetConfigImplFromJson(Map<String, dynamic> json) =>
    _$WidgetConfigImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      properties: json['properties'] as Map<String, dynamic>,
      visible: json['visible'] as bool? ?? true,
      topics:
          (json['topics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      actions:
          (json['actions'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, ActionConfig.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => WidgetConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WidgetConfigImplToJson(_$WidgetConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'properties': instance.properties,
      'visible': instance.visible,
      'topics': instance.topics,
      'actions': instance.actions,
      'children': instance.children,
    };

_$ActionConfigImpl _$$ActionConfigImplFromJson(Map<String, dynamic> json) =>
    _$ActionConfigImpl(
      type: json['type'] as String,
      params: json['params'] as Map<String, dynamic>,
      confirmMessage: json['confirmMessage'] as String?,
      requireConfirmation: json['requireConfirmation'] as bool? ?? false,
    );

Map<String, dynamic> _$$ActionConfigImplToJson(_$ActionConfigImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'params': instance.params,
      'confirmMessage': instance.confirmMessage,
      'requireConfirmation': instance.requireConfirmation,
    };

_$EdgeInsetsConfigImpl _$$EdgeInsetsConfigImplFromJson(
  Map<String, dynamic> json,
) => _$EdgeInsetsConfigImpl(
  top: (json['top'] as num?)?.toDouble() ?? 0,
  right: (json['right'] as num?)?.toDouble() ?? 0,
  bottom: (json['bottom'] as num?)?.toDouble() ?? 0,
  left: (json['left'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$EdgeInsetsConfigImplToJson(
  _$EdgeInsetsConfigImpl instance,
) => <String, dynamic>{
  'top': instance.top,
  'right': instance.right,
  'bottom': instance.bottom,
  'left': instance.left,
};

_$ControlConfigImpl _$$ControlConfigImplFromJson(Map<String, dynamic> json) =>
    _$ControlConfigImpl(
      deviceId: json['deviceId'] as String,
      channelId: json['channelId'] as String,
      label: json['label'] as String,
      subtitle: json['subtitle'] as String?,
      icon: json['icon'] as String,
      controlType: json['controlType'] as String? ?? 'toggle',
      size: json['size'] as String? ?? 'normal',
      confirmAction: json['confirmAction'] as bool? ?? false,
      confirmMessage: json['confirmMessage'] as String?,
      style: json['style'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ControlConfigImplToJson(_$ControlConfigImpl instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'channelId': instance.channelId,
      'label': instance.label,
      'subtitle': instance.subtitle,
      'icon': instance.icon,
      'controlType': instance.controlType,
      'size': instance.size,
      'confirmAction': instance.confirmAction,
      'confirmMessage': instance.confirmMessage,
      'style': instance.style,
    };

_$DeviceConfigImpl _$$DeviceConfigImplFromJson(Map<String, dynamic> json) =>
    _$DeviceConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      online: json['online'] as bool? ?? true,
      channels: (json['channels'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, ChannelConfig.fromJson(e as Map<String, dynamic>)),
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$DeviceConfigImplToJson(_$DeviceConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'online': instance.online,
      'channels': instance.channels,
      'metadata': instance.metadata,
    };

_$ChannelConfigImpl _$$ChannelConfigImplFromJson(Map<String, dynamic> json) =>
    _$ChannelConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      functionType: json['functionType'] as String,
      state: json['state'] as bool? ?? false,
      dimmerValue: (json['dimmerValue'] as num?)?.toDouble(),
      allowInMacro: json['allowInMacro'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ChannelConfigImplToJson(_$ChannelConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'functionType': instance.functionType,
      'state': instance.state,
      'dimmerValue': instance.dimmerValue,
      'allowInMacro': instance.allowInMacro,
      'metadata': instance.metadata,
    };

_$AppConfigImpl _$$AppConfigImplFromJson(Map<String, dynamic> json) =>
    _$AppConfigImpl(
      version: json['version'] as String,
      screens: (json['screens'] as List<dynamic>)
          .map((e) => ScreenConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      devices: (json['devices'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, DeviceConfig.fromJson(e as Map<String, dynamic>)),
      ),
      theme: json['theme'] == null
          ? null
          : ThemeConfig.fromJson(json['theme'] as Map<String, dynamic>),
      mqtt: json['mqtt'] == null
          ? null
          : MqttConfig.fromJson(json['mqtt'] as Map<String, dynamic>),
      settings: json['settings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AppConfigImplToJson(_$AppConfigImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'screens': instance.screens,
      'devices': instance.devices,
      'theme': instance.theme,
      'mqtt': instance.mqtt,
      'settings': instance.settings,
    };

_$ThemeConfigImpl _$$ThemeConfigImplFromJson(Map<String, dynamic> json) =>
    _$ThemeConfigImpl(
      mode: json['mode'] as String? ?? 'dark',
      primaryColor: json['primaryColor'] as String?,
      accentColor: json['accentColor'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ThemeConfigImplToJson(_$ThemeConfigImpl instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'primaryColor': instance.primaryColor,
      'accentColor': instance.accentColor,
      'custom': instance.custom,
    };

_$MqttConfigImpl _$$MqttConfigImplFromJson(Map<String, dynamic> json) =>
    _$MqttConfigImpl(
      broker: json['broker'] as String,
      port: (json['port'] as num?)?.toInt() ?? 1883,
      username: json['username'] as String?,
      password: json['password'] as String?,
      clientId: json['clientId'] as String? ?? 'autocore_app',
      topics:
          (json['topics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['autocore/#'],
    );

Map<String, dynamic> _$$MqttConfigImplToJson(_$MqttConfigImpl instance) =>
    <String, dynamic>{
      'broker': instance.broker,
      'port': instance.port,
      'username': instance.username,
      'password': instance.password,
      'clientId': instance.clientId,
      'topics': instance.topics,
    };
