// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_full_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConfigFullResponseImpl _$$ConfigFullResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConfigFullResponseImpl(
  deviceInfo: ApiDeviceInfo.fromJson(
    json['device_info'] as Map<String, dynamic>,
  ),
  systemConfig: SystemConfig.fromJson(
    json['system_config'] as Map<String, dynamic>,
  ),
  screens: (json['screens'] as List<dynamic>)
      .map((e) => ApiScreenConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
  relayBoards: (json['relay_boards'] as List<dynamic>)
      .map((e) => RelayBoardInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  theme: ThemeConfig.fromJson(json['theme'] as Map<String, dynamic>),
  lastUpdated: DateTime.parse(json['last_updated'] as String),
  configVersion: json['config_version'] as String,
);

Map<String, dynamic> _$$ConfigFullResponseImplToJson(
  _$ConfigFullResponseImpl instance,
) => <String, dynamic>{
  'device_info': instance.deviceInfo,
  'system_config': instance.systemConfig,
  'screens': instance.screens,
  'relay_boards': instance.relayBoards,
  'theme': instance.theme,
  'last_updated': instance.lastUpdated.toIso8601String(),
  'config_version': instance.configVersion,
};
