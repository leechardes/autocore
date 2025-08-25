// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_screen_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiScreenConfigImpl _$$ApiScreenConfigImplFromJson(
  Map<String, dynamic> json,
) => _$ApiScreenConfigImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  title: json['title'] as String,
  order: (json['order'] as num).toInt(),
  enabled: json['enabled'] as bool? ?? true,
  icon: json['icon'] as String?,
  route: json['route'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ApiScreenItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  refreshInterval: (json['refresh_interval'] as num?)?.toInt(),
  requiresAuthentication: json['requires_authentication'] as bool? ?? false,
  backgroundColor: json['background_color'] as String?,
  textColor: json['text_color'] as String?,
  layoutType: json['layout_type'] as String? ?? 'grid',
  columns: (json['columns'] as num?)?.toInt() ?? 2,
);

Map<String, dynamic> _$$ApiScreenConfigImplToJson(
  _$ApiScreenConfigImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'title': instance.title,
  'order': instance.order,
  'enabled': instance.enabled,
  'icon': instance.icon,
  'route': instance.route,
  'items': instance.items,
  'refresh_interval': instance.refreshInterval,
  'requires_authentication': instance.requiresAuthentication,
  'background_color': instance.backgroundColor,
  'text_color': instance.textColor,
  'layout_type': instance.layoutType,
  'columns': instance.columns,
};
