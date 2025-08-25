import 'package:freezed_annotation/freezed_annotation.dart';

part 'color_range.freezed.dart';
part 'color_range.g.dart';

@freezed
class ColorRange with _$ColorRange {
  const factory ColorRange({
    @JsonKey(name: 'min') required double min,
    @JsonKey(name: 'max') required double max,
    @JsonKey(name: 'color') required String color,
    @JsonKey(name: 'label') String? label,
    @JsonKey(name: 'priority') @Default(0) int priority,
  }) = _ColorRange;

  factory ColorRange.fromJson(Map<String, dynamic> json) =>
      _$ColorRangeFromJson(json);
}
