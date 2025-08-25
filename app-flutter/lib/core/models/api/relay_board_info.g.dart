// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relay_board_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RelayBoardInfoImpl _$$RelayBoardInfoImplFromJson(Map<String, dynamic> json) =>
    _$RelayBoardInfoImpl(
      boardId: json['board_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      address: json['address'] as String,
      enabled: json['enabled'] as bool? ?? true,
      channels: (json['channels'] as List<dynamic>)
          .map((e) => RelayChannelInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      firmwareVersion: json['firmware_version'] as String?,
      ipAddress: json['ip_address'] as String?,
      port: (json['port'] as num?)?.toInt(),
      timeout: (json['timeout'] as num?)?.toInt() ?? 5000,
      retryAttempts: (json['retry_attempts'] as num?)?.toInt() ?? 3,
      lastHeartbeat: json['last_heartbeat'] == null
          ? null
          : DateTime.parse(json['last_heartbeat'] as String),
      status: json['status'] as String? ?? 'unknown',
    );

Map<String, dynamic> _$$RelayBoardInfoImplToJson(
  _$RelayBoardInfoImpl instance,
) => <String, dynamic>{
  'board_id': instance.boardId,
  'name': instance.name,
  'type': instance.type,
  'address': instance.address,
  'enabled': instance.enabled,
  'channels': instance.channels,
  'firmware_version': instance.firmwareVersion,
  'ip_address': instance.ipAddress,
  'port': instance.port,
  'timeout': instance.timeout,
  'retry_attempts': instance.retryAttempts,
  'last_heartbeat': instance.lastHeartbeat?.toIso8601String(),
  'status': instance.status,
};
