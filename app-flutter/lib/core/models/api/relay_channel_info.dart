import 'package:freezed_annotation/freezed_annotation.dart';

part 'relay_channel_info.freezed.dart';
part 'relay_channel_info.g.dart';

@freezed
class RelayChannelInfo with _$RelayChannelInfo {
  const factory RelayChannelInfo({
    @JsonKey(name: 'channel_id') required int channelId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'enabled') @Default(true) bool enabled,
    @JsonKey(name: 'normally_open') @Default(true) bool normallyOpen,
    @JsonKey(name: 'initial_state') @Default(false) bool initialState,
    @JsonKey(name: 'current_state') @Default(false) bool currentState,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'group') String? group,
    @JsonKey(name: 'safety_enabled') @Default(false) bool safetyEnabled,
    @JsonKey(name: 'max_on_time') int? maxOnTime, // Em milliseconds
    @JsonKey(name: 'min_off_time') int? minOffTime, // Em milliseconds
    @JsonKey(name: 'interlock_channels')
    @Default([])
    List<int> interlockChannels,
    @JsonKey(name: 'last_activated') DateTime? lastActivated,
    @JsonKey(name: 'activation_count') @Default(0) int activationCount,
    @JsonKey(name: 'total_on_time')
    @Default(0)
    int totalOnTime, // Em milliseconds
  }) = _RelayChannelInfo;

  factory RelayChannelInfo.fromJson(Map<String, dynamic> json) =>
      _$RelayChannelInfoFromJson(json);
}
