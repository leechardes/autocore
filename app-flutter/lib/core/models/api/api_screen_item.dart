import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_screen_item.freezed.dart';
part 'api_screen_item.g.dart';

@freezed
class ApiScreenItem with _$ApiScreenItem {
  const factory ApiScreenItem({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'type')
    required String type, // 'button', 'gauge', 'display', 'switch'
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'position')
    required Map<String, dynamic> position, // {row, col, span_x, span_y}
    @JsonKey(name: 'enabled') @Default(true) bool enabled,
    @JsonKey(name: 'visible') @Default(true) bool visible,

    // Common styling
    @JsonKey(name: 'background_color') String? backgroundColor,
    @JsonKey(name: 'text_color') String? textColor,
    @JsonKey(name: 'border_color') String? borderColor,
    @JsonKey(name: 'icon') String? icon,

    // Button specific
    @JsonKey(name: 'action') String? action,
    @JsonKey(name: 'command') String? command,
    @JsonKey(name: 'payload') Map<String, dynamic>? payload,
    @JsonKey(name: 'is_momentary') @Default(false) bool isMomentary,
    @JsonKey(name: 'hold_duration') int? holdDuration,

    // Gauge/Display specific
    @JsonKey(name: 'telemetry_key') String? telemetryKey,
    @JsonKey(name: 'unit') String? unit,
    @JsonKey(name: 'min_value') double? minValue,
    @JsonKey(name: 'max_value') double? maxValue,
    @JsonKey(name: 'decimal_places') @Default(0) int decimalPlaces,
    @JsonKey(name: 'color_ranges') List<Map<String, dynamic>>? colorRanges,

    // Switch specific
    @JsonKey(name: 'switch_command_on') String? switchCommandOn,
    @JsonKey(name: 'switch_command_off') String? switchCommandOff,
    @JsonKey(name: 'switch_payload_on') Map<String, dynamic>? switchPayloadOn,
    @JsonKey(name: 'switch_payload_off') Map<String, dynamic>? switchPayloadOff,
    @JsonKey(name: 'initial_state') @Default(false) bool initialState,
  }) = _ApiScreenItem;

  factory ApiScreenItem.fromJson(Map<String, dynamic> json) =>
      _$ApiScreenItemFromJson(json);
}
