import 'package:autocore_app/core/models/api/relay_channel_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'relay_board_info.freezed.dart';
part 'relay_board_info.g.dart';

@freezed
class RelayBoardInfo with _$RelayBoardInfo {
  const factory RelayBoardInfo({
    @JsonKey(name: 'board_id') required String boardId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'address') required String address,
    @JsonKey(name: 'enabled') @Default(true) bool enabled,
    @JsonKey(name: 'channels') required List<RelayChannelInfo> channels,
    @JsonKey(name: 'firmware_version') String? firmwareVersion,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'port') int? port,
    @JsonKey(name: 'timeout') @Default(5000) int timeout,
    @JsonKey(name: 'retry_attempts') @Default(3) int retryAttempts,
    @JsonKey(name: 'last_heartbeat') DateTime? lastHeartbeat,
    @JsonKey(name: 'status')
    @Default('unknown')
    String status, // 'online', 'offline', 'error', 'unknown'
  }) = _RelayBoardInfo;

  factory RelayBoardInfo.fromJson(Map<String, dynamic> json) =>
      _$RelayBoardInfoFromJson(json);
}
