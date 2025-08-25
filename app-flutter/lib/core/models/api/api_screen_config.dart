import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_screen_config.freezed.dart';
part 'api_screen_config.g.dart';

@freezed
class ApiScreenConfig with _$ApiScreenConfig {
  const factory ApiScreenConfig({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'order') required int order,
    @JsonKey(name: 'enabled') @Default(true) bool enabled,
    @JsonKey(name: 'icon') String? icon,
    @JsonKey(name: 'route') String? route,
    @JsonKey(name: 'items') @Default([]) List<ApiScreenItem> items,
    @JsonKey(name: 'refresh_interval') int? refreshInterval,
    @JsonKey(name: 'requires_authentication')
    @Default(false)
    bool requiresAuthentication,
    @JsonKey(name: 'background_color') String? backgroundColor,
    @JsonKey(name: 'text_color') String? textColor,
    @JsonKey(name: 'layout_type') @Default('grid') String layoutType,
    @JsonKey(name: 'columns') @Default(2) int columns,
  }) = _ApiScreenConfig;

  factory ApiScreenConfig.fromJson(Map<String, dynamic> json) =>
      _$ApiScreenConfigFromJson(json);
}
