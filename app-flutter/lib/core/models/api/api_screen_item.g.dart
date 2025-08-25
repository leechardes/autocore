// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_screen_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiScreenItemImpl _$$ApiScreenItemImplFromJson(Map<String, dynamic> json) =>
    _$ApiScreenItemImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      position: json['position'] as Map<String, dynamic>,
      enabled: json['enabled'] as bool? ?? true,
      visible: json['visible'] as bool? ?? true,
      backgroundColor: json['background_color'] as String?,
      textColor: json['text_color'] as String?,
      borderColor: json['border_color'] as String?,
      icon: json['icon'] as String?,
      action: json['action'] as String?,
      command: json['command'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
      isMomentary: json['is_momentary'] as bool? ?? false,
      holdDuration: (json['hold_duration'] as num?)?.toInt(),
      telemetryKey: json['telemetry_key'] as String?,
      unit: json['unit'] as String?,
      minValue: (json['min_value'] as num?)?.toDouble(),
      maxValue: (json['max_value'] as num?)?.toDouble(),
      decimalPlaces: (json['decimal_places'] as num?)?.toInt() ?? 0,
      colorRanges: (json['color_ranges'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      switchCommandOn: json['switch_command_on'] as String?,
      switchCommandOff: json['switch_command_off'] as String?,
      switchPayloadOn: json['switch_payload_on'] as Map<String, dynamic>?,
      switchPayloadOff: json['switch_payload_off'] as Map<String, dynamic>?,
      initialState: json['initial_state'] as bool? ?? false,
    );

Map<String, dynamic> _$$ApiScreenItemImplToJson(_$ApiScreenItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'position': instance.position,
      'enabled': instance.enabled,
      'visible': instance.visible,
      'background_color': instance.backgroundColor,
      'text_color': instance.textColor,
      'border_color': instance.borderColor,
      'icon': instance.icon,
      'action': instance.action,
      'command': instance.command,
      'payload': instance.payload,
      'is_momentary': instance.isMomentary,
      'hold_duration': instance.holdDuration,
      'telemetry_key': instance.telemetryKey,
      'unit': instance.unit,
      'min_value': instance.minValue,
      'max_value': instance.maxValue,
      'decimal_places': instance.decimalPlaces,
      'color_ranges': instance.colorRanges,
      'switch_command_on': instance.switchCommandOn,
      'switch_command_off': instance.switchCommandOff,
      'switch_payload_on': instance.switchPayloadOn,
      'switch_payload_off': instance.switchPayloadOff,
      'initial_state': instance.initialState,
    };
