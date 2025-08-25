import 'package:autocore_app/core/models/api/api_device_info.dart';
import 'package:autocore_app/core/models/api/api_screen_config.dart';
import 'package:autocore_app/core/models/api/relay_board_info.dart';
import 'package:autocore_app/core/models/api/system_config.dart';
import 'package:autocore_app/core/models/api/theme_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_full_response.freezed.dart';
part 'config_full_response.g.dart';

@freezed
class ConfigFullResponse with _$ConfigFullResponse {
  const factory ConfigFullResponse({
    @JsonKey(name: 'device_info') required ApiDeviceInfo deviceInfo,
    @JsonKey(name: 'system_config') required SystemConfig systemConfig,
    @JsonKey(name: 'screens') required List<ApiScreenConfig> screens,
    @JsonKey(name: 'relay_boards') required List<RelayBoardInfo> relayBoards,
    @JsonKey(name: 'theme') required ThemeConfig theme,
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
    @JsonKey(name: 'config_version') required String configVersion,
  }) = _ConfigFullResponse;

  factory ConfigFullResponse.fromJson(Map<String, dynamic> json) =>
      _$ConfigFullResponseFromJson(json);
}
