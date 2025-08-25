// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_range.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ColorRangeImpl _$$ColorRangeImplFromJson(Map<String, dynamic> json) =>
    _$ColorRangeImpl(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      color: json['color'] as String,
      label: json['label'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ColorRangeImplToJson(_$ColorRangeImpl instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'color': instance.color,
      'label': instance.label,
      'priority': instance.priority,
    };
