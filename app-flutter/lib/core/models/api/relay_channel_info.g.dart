// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relay_channel_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RelayChannelInfoImpl _$$RelayChannelInfoImplFromJson(
  Map<String, dynamic> json,
) => _$RelayChannelInfoImpl(
  channelId: (json['channel_id'] as num).toInt(),
  name: json['name'] as String,
  enabled: json['enabled'] as bool? ?? true,
  normallyOpen: json['normally_open'] as bool? ?? true,
  initialState: json['initial_state'] as bool? ?? false,
  currentState: json['current_state'] as bool? ?? false,
  description: json['description'] as String?,
  group: json['group'] as String?,
  safetyEnabled: json['safety_enabled'] as bool? ?? false,
  maxOnTime: (json['max_on_time'] as num?)?.toInt(),
  minOffTime: (json['min_off_time'] as num?)?.toInt(),
  interlockChannels:
      (json['interlock_channels'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  lastActivated: json['last_activated'] == null
      ? null
      : DateTime.parse(json['last_activated'] as String),
  activationCount: (json['activation_count'] as num?)?.toInt() ?? 0,
  totalOnTime: (json['total_on_time'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$RelayChannelInfoImplToJson(
  _$RelayChannelInfoImpl instance,
) => <String, dynamic>{
  'channel_id': instance.channelId,
  'name': instance.name,
  'enabled': instance.enabled,
  'normally_open': instance.normallyOpen,
  'initial_state': instance.initialState,
  'current_state': instance.currentState,
  'description': instance.description,
  'group': instance.group,
  'safety_enabled': instance.safetyEnabled,
  'max_on_time': instance.maxOnTime,
  'min_off_time': instance.minOffTime,
  'interlock_channels': instance.interlockChannels,
  'last_activated': instance.lastActivated?.toIso8601String(),
  'activation_count': instance.activationCount,
  'total_on_time': instance.totalOnTime,
};
