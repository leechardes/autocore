// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScreenConfigImpl _$$ScreenConfigImplFromJson(Map<String, dynamic> json) =>
    _$ScreenConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      route: json['route'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ScreenItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      layout: json['layout'] as String? ?? 'grid',
      columns: (json['columns'] as num?)?.toInt() ?? 2,
      showHeader: json['showHeader'] as bool? ?? true,
      showNavigation: json['showNavigation'] as bool? ?? true,
      customProperties: json['customProperties'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ScreenConfigImplToJson(_$ScreenConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'route': instance.route,
      'items': instance.items,
      'layout': instance.layout,
      'columns': instance.columns,
      'showHeader': instance.showHeader,
      'showNavigation': instance.showNavigation,
      'customProperties': instance.customProperties,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$ScreenItemImpl _$$ScreenItemImplFromJson(Map<String, dynamic> json) =>
    _$ScreenItemImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      visible: json['visible'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      position: (json['position'] as num?)?.toInt(),
      row: (json['row'] as num?)?.toInt(),
      column: (json['column'] as num?)?.toInt(),
      action: json['action'] == null
          ? null
          : ScreenItemAction.fromJson(json['action'] as Map<String, dynamic>),
      properties: json['properties'] as Map<String, dynamic>?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
      relayBoardId: (json['relayBoardId'] as num?)?.toInt(),
      relayChannelId: (json['relayChannelId'] as num?)?.toInt(),
      functionType: json['functionType'] as String?,
      statusTopic: json['statusTopic'] as String?,
      statusField: json['statusField'] as String?,
      macroId: (json['macroId'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ScreenItemImplToJson(_$ScreenItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'label': instance.label,
      'description': instance.description,
      'icon': instance.icon,
      'visible': instance.visible,
      'enabled': instance.enabled,
      'position': instance.position,
      'row': instance.row,
      'column': instance.column,
      'action': instance.action,
      'properties': instance.properties,
      'width': instance.width,
      'height': instance.height,
      'backgroundColor': instance.backgroundColor,
      'textColor': instance.textColor,
      'relayBoardId': instance.relayBoardId,
      'relayChannelId': instance.relayChannelId,
      'functionType': instance.functionType,
      'statusTopic': instance.statusTopic,
      'statusField': instance.statusField,
      'macroId': instance.macroId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$ScreenItemActionImpl _$$ScreenItemActionImplFromJson(
  Map<String, dynamic> json,
) => _$ScreenItemActionImpl(
  type: json['type'] as String,
  parameters: json['parameters'] as Map<String, dynamic>?,
  macroId: (json['macroId'] as num?)?.toInt(),
  boardId: (json['boardId'] as num?)?.toInt(),
  channel: (json['channel'] as num?)?.toInt(),
  state: json['state'] as bool?,
  momentary: json['momentary'] as bool?,
  route: json['route'] as String?,
  routeParams: (json['routeParams'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  url: json['url'] as String?,
  method: json['method'] as String?,
  body: json['body'] as Map<String, dynamic>?,
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  topic: json['topic'] as String?,
  payload: json['payload'] as Map<String, dynamic>?,
  retain: json['retain'] as bool?,
  qos: (json['qos'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ScreenItemActionImplToJson(
  _$ScreenItemActionImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'parameters': instance.parameters,
  'macroId': instance.macroId,
  'boardId': instance.boardId,
  'channel': instance.channel,
  'state': instance.state,
  'momentary': instance.momentary,
  'route': instance.route,
  'routeParams': instance.routeParams,
  'url': instance.url,
  'method': instance.method,
  'body': instance.body,
  'headers': instance.headers,
  'topic': instance.topic,
  'payload': instance.payload,
  'retain': instance.retain,
  'qos': instance.qos,
};

_$AppScreensConfigImpl _$$AppScreensConfigImplFromJson(
  Map<String, dynamic> json,
) => _$AppScreensConfigImpl(
  version: json['version'] as String? ?? '1.0.0',
  screens:
      (json['screens'] as List<dynamic>?)
          ?.map((e) => ScreenConfig.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  defaultScreen: json['defaultScreen'] as String? ?? 'dashboard',
  globalSettings: json['globalSettings'] as Map<String, dynamic>? ?? const {},
  lastUpdated: json['lastUpdated'] == null
      ? null
      : DateTime.parse(json['lastUpdated'] as String),
  configSource: json['configSource'] as String?,
);

Map<String, dynamic> _$$AppScreensConfigImplToJson(
  _$AppScreensConfigImpl instance,
) => <String, dynamic>{
  'version': instance.version,
  'screens': instance.screens,
  'defaultScreen': instance.defaultScreen,
  'globalSettings': instance.globalSettings,
  'lastUpdated': instance.lastUpdated?.toIso8601String(),
  'configSource': instance.configSource,
};
