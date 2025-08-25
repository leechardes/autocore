// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ThemeConfig _$ThemeConfigFromJson(Map<String, dynamic> json) {
  return _ThemeConfig.fromJson(json);
}

/// @nodoc
mixin _$ThemeConfig {
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'mode')
  String get mode => throw _privateConstructorUsedError; // 'light', 'dark', 'auto'
  // Primary colors
  @JsonKey(name: 'primary_color')
  String get primaryColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_variant')
  String get primaryVariant => throw _privateConstructorUsedError;
  @JsonKey(name: 'secondary_color')
  String get secondaryColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'secondary_variant')
  String get secondaryVariant => throw _privateConstructorUsedError; // Background colors
  @JsonKey(name: 'background_color')
  String get backgroundColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'surface_color')
  String get surfaceColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'card_color')
  String get cardColor => throw _privateConstructorUsedError; // Text colors
  @JsonKey(name: 'text_primary')
  String get textPrimary => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_secondary')
  String get textSecondary => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_disabled')
  String get textDisabled => throw _privateConstructorUsedError; // Status colors
  @JsonKey(name: 'success_color')
  String get successColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'warning_color')
  String get warningColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_color')
  String get errorColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'info_color')
  String get infoColor => throw _privateConstructorUsedError; // UI Element colors
  @JsonKey(name: 'button_color')
  String? get buttonColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'button_text_color')
  String? get buttonTextColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'switch_active_color')
  String? get switchActiveColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'switch_inactive_color')
  String? get switchInactiveColor => throw _privateConstructorUsedError; // Border and divider colors
  @JsonKey(name: 'border_color')
  String? get borderColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'divider_color')
  String? get dividerColor => throw _privateConstructorUsedError; // Gauge and indicator colors
  @JsonKey(name: 'gauge_color_ranges')
  List<ColorRange> get gaugeColorRanges => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_gauge_color')
  String get defaultGaugeColor => throw _privateConstructorUsedError; // Typography
  @JsonKey(name: 'font_family')
  String? get fontFamily => throw _privateConstructorUsedError;
  @JsonKey(name: 'font_size_small')
  double get fontSizeSmall => throw _privateConstructorUsedError;
  @JsonKey(name: 'font_size_medium')
  double get fontSizeMedium => throw _privateConstructorUsedError;
  @JsonKey(name: 'font_size_large')
  double get fontSizeLarge => throw _privateConstructorUsedError;
  @JsonKey(name: 'font_size_title')
  double get fontSizeTitle => throw _privateConstructorUsedError; // Spacing and dimensions
  @JsonKey(name: 'border_radius')
  double get borderRadius => throw _privateConstructorUsedError;
  @JsonKey(name: 'card_elevation')
  double get cardElevation => throw _privateConstructorUsedError;
  @JsonKey(name: 'button_height')
  double get buttonHeight => throw _privateConstructorUsedError; // Animation settings
  @JsonKey(name: 'animation_duration')
  int get animationDuration => throw _privateConstructorUsedError;
  @JsonKey(name: 'enable_animations')
  bool get enableAnimations => throw _privateConstructorUsedError;

  /// Serializes this ThemeConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThemeConfigCopyWith<ThemeConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemeConfigCopyWith<$Res> {
  factory $ThemeConfigCopyWith(
    ThemeConfig value,
    $Res Function(ThemeConfig) then,
  ) = _$ThemeConfigCopyWithImpl<$Res, ThemeConfig>;
  @useResult
  $Res call({
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'mode') String mode,
    @JsonKey(name: 'primary_color') String primaryColor,
    @JsonKey(name: 'primary_variant') String primaryVariant,
    @JsonKey(name: 'secondary_color') String secondaryColor,
    @JsonKey(name: 'secondary_variant') String secondaryVariant,
    @JsonKey(name: 'background_color') String backgroundColor,
    @JsonKey(name: 'surface_color') String surfaceColor,
    @JsonKey(name: 'card_color') String cardColor,
    @JsonKey(name: 'text_primary') String textPrimary,
    @JsonKey(name: 'text_secondary') String textSecondary,
    @JsonKey(name: 'text_disabled') String textDisabled,
    @JsonKey(name: 'success_color') String successColor,
    @JsonKey(name: 'warning_color') String warningColor,
    @JsonKey(name: 'error_color') String errorColor,
    @JsonKey(name: 'info_color') String infoColor,
    @JsonKey(name: 'button_color') String? buttonColor,
    @JsonKey(name: 'button_text_color') String? buttonTextColor,
    @JsonKey(name: 'switch_active_color') String? switchActiveColor,
    @JsonKey(name: 'switch_inactive_color') String? switchInactiveColor,
    @JsonKey(name: 'border_color') String? borderColor,
    @JsonKey(name: 'divider_color') String? dividerColor,
    @JsonKey(name: 'gauge_color_ranges') List<ColorRange> gaugeColorRanges,
    @JsonKey(name: 'default_gauge_color') String defaultGaugeColor,
    @JsonKey(name: 'font_family') String? fontFamily,
    @JsonKey(name: 'font_size_small') double fontSizeSmall,
    @JsonKey(name: 'font_size_medium') double fontSizeMedium,
    @JsonKey(name: 'font_size_large') double fontSizeLarge,
    @JsonKey(name: 'font_size_title') double fontSizeTitle,
    @JsonKey(name: 'border_radius') double borderRadius,
    @JsonKey(name: 'card_elevation') double cardElevation,
    @JsonKey(name: 'button_height') double buttonHeight,
    @JsonKey(name: 'animation_duration') int animationDuration,
    @JsonKey(name: 'enable_animations') bool enableAnimations,
  });
}

/// @nodoc
class _$ThemeConfigCopyWithImpl<$Res, $Val extends ThemeConfig>
    implements $ThemeConfigCopyWith<$Res> {
  _$ThemeConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? mode = null,
    Object? primaryColor = null,
    Object? primaryVariant = null,
    Object? secondaryColor = null,
    Object? secondaryVariant = null,
    Object? backgroundColor = null,
    Object? surfaceColor = null,
    Object? cardColor = null,
    Object? textPrimary = null,
    Object? textSecondary = null,
    Object? textDisabled = null,
    Object? successColor = null,
    Object? warningColor = null,
    Object? errorColor = null,
    Object? infoColor = null,
    Object? buttonColor = freezed,
    Object? buttonTextColor = freezed,
    Object? switchActiveColor = freezed,
    Object? switchInactiveColor = freezed,
    Object? borderColor = freezed,
    Object? dividerColor = freezed,
    Object? gaugeColorRanges = null,
    Object? defaultGaugeColor = null,
    Object? fontFamily = freezed,
    Object? fontSizeSmall = null,
    Object? fontSizeMedium = null,
    Object? fontSizeLarge = null,
    Object? fontSizeTitle = null,
    Object? borderRadius = null,
    Object? cardElevation = null,
    Object? buttonHeight = null,
    Object? animationDuration = null,
    Object? enableAnimations = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String,
            primaryColor: null == primaryColor
                ? _value.primaryColor
                : primaryColor // ignore: cast_nullable_to_non_nullable
                      as String,
            primaryVariant: null == primaryVariant
                ? _value.primaryVariant
                : primaryVariant // ignore: cast_nullable_to_non_nullable
                      as String,
            secondaryColor: null == secondaryColor
                ? _value.secondaryColor
                : secondaryColor // ignore: cast_nullable_to_non_nullable
                      as String,
            secondaryVariant: null == secondaryVariant
                ? _value.secondaryVariant
                : secondaryVariant // ignore: cast_nullable_to_non_nullable
                      as String,
            backgroundColor: null == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as String,
            surfaceColor: null == surfaceColor
                ? _value.surfaceColor
                : surfaceColor // ignore: cast_nullable_to_non_nullable
                      as String,
            cardColor: null == cardColor
                ? _value.cardColor
                : cardColor // ignore: cast_nullable_to_non_nullable
                      as String,
            textPrimary: null == textPrimary
                ? _value.textPrimary
                : textPrimary // ignore: cast_nullable_to_non_nullable
                      as String,
            textSecondary: null == textSecondary
                ? _value.textSecondary
                : textSecondary // ignore: cast_nullable_to_non_nullable
                      as String,
            textDisabled: null == textDisabled
                ? _value.textDisabled
                : textDisabled // ignore: cast_nullable_to_non_nullable
                      as String,
            successColor: null == successColor
                ? _value.successColor
                : successColor // ignore: cast_nullable_to_non_nullable
                      as String,
            warningColor: null == warningColor
                ? _value.warningColor
                : warningColor // ignore: cast_nullable_to_non_nullable
                      as String,
            errorColor: null == errorColor
                ? _value.errorColor
                : errorColor // ignore: cast_nullable_to_non_nullable
                      as String,
            infoColor: null == infoColor
                ? _value.infoColor
                : infoColor // ignore: cast_nullable_to_non_nullable
                      as String,
            buttonColor: freezed == buttonColor
                ? _value.buttonColor
                : buttonColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            buttonTextColor: freezed == buttonTextColor
                ? _value.buttonTextColor
                : buttonTextColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            switchActiveColor: freezed == switchActiveColor
                ? _value.switchActiveColor
                : switchActiveColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            switchInactiveColor: freezed == switchInactiveColor
                ? _value.switchInactiveColor
                : switchInactiveColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            borderColor: freezed == borderColor
                ? _value.borderColor
                : borderColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            dividerColor: freezed == dividerColor
                ? _value.dividerColor
                : dividerColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            gaugeColorRanges: null == gaugeColorRanges
                ? _value.gaugeColorRanges
                : gaugeColorRanges // ignore: cast_nullable_to_non_nullable
                      as List<ColorRange>,
            defaultGaugeColor: null == defaultGaugeColor
                ? _value.defaultGaugeColor
                : defaultGaugeColor // ignore: cast_nullable_to_non_nullable
                      as String,
            fontFamily: freezed == fontFamily
                ? _value.fontFamily
                : fontFamily // ignore: cast_nullable_to_non_nullable
                      as String?,
            fontSizeSmall: null == fontSizeSmall
                ? _value.fontSizeSmall
                : fontSizeSmall // ignore: cast_nullable_to_non_nullable
                      as double,
            fontSizeMedium: null == fontSizeMedium
                ? _value.fontSizeMedium
                : fontSizeMedium // ignore: cast_nullable_to_non_nullable
                      as double,
            fontSizeLarge: null == fontSizeLarge
                ? _value.fontSizeLarge
                : fontSizeLarge // ignore: cast_nullable_to_non_nullable
                      as double,
            fontSizeTitle: null == fontSizeTitle
                ? _value.fontSizeTitle
                : fontSizeTitle // ignore: cast_nullable_to_non_nullable
                      as double,
            borderRadius: null == borderRadius
                ? _value.borderRadius
                : borderRadius // ignore: cast_nullable_to_non_nullable
                      as double,
            cardElevation: null == cardElevation
                ? _value.cardElevation
                : cardElevation // ignore: cast_nullable_to_non_nullable
                      as double,
            buttonHeight: null == buttonHeight
                ? _value.buttonHeight
                : buttonHeight // ignore: cast_nullable_to_non_nullable
                      as double,
            animationDuration: null == animationDuration
                ? _value.animationDuration
                : animationDuration // ignore: cast_nullable_to_non_nullable
                      as int,
            enableAnimations: null == enableAnimations
                ? _value.enableAnimations
                : enableAnimations // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ThemeConfigImplCopyWith<$Res>
    implements $ThemeConfigCopyWith<$Res> {
  factory _$$ThemeConfigImplCopyWith(
    _$ThemeConfigImpl value,
    $Res Function(_$ThemeConfigImpl) then,
  ) = __$$ThemeConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'mode') String mode,
    @JsonKey(name: 'primary_color') String primaryColor,
    @JsonKey(name: 'primary_variant') String primaryVariant,
    @JsonKey(name: 'secondary_color') String secondaryColor,
    @JsonKey(name: 'secondary_variant') String secondaryVariant,
    @JsonKey(name: 'background_color') String backgroundColor,
    @JsonKey(name: 'surface_color') String surfaceColor,
    @JsonKey(name: 'card_color') String cardColor,
    @JsonKey(name: 'text_primary') String textPrimary,
    @JsonKey(name: 'text_secondary') String textSecondary,
    @JsonKey(name: 'text_disabled') String textDisabled,
    @JsonKey(name: 'success_color') String successColor,
    @JsonKey(name: 'warning_color') String warningColor,
    @JsonKey(name: 'error_color') String errorColor,
    @JsonKey(name: 'info_color') String infoColor,
    @JsonKey(name: 'button_color') String? buttonColor,
    @JsonKey(name: 'button_text_color') String? buttonTextColor,
    @JsonKey(name: 'switch_active_color') String? switchActiveColor,
    @JsonKey(name: 'switch_inactive_color') String? switchInactiveColor,
    @JsonKey(name: 'border_color') String? borderColor,
    @JsonKey(name: 'divider_color') String? dividerColor,
    @JsonKey(name: 'gauge_color_ranges') List<ColorRange> gaugeColorRanges,
    @JsonKey(name: 'default_gauge_color') String defaultGaugeColor,
    @JsonKey(name: 'font_family') String? fontFamily,
    @JsonKey(name: 'font_size_small') double fontSizeSmall,
    @JsonKey(name: 'font_size_medium') double fontSizeMedium,
    @JsonKey(name: 'font_size_large') double fontSizeLarge,
    @JsonKey(name: 'font_size_title') double fontSizeTitle,
    @JsonKey(name: 'border_radius') double borderRadius,
    @JsonKey(name: 'card_elevation') double cardElevation,
    @JsonKey(name: 'button_height') double buttonHeight,
    @JsonKey(name: 'animation_duration') int animationDuration,
    @JsonKey(name: 'enable_animations') bool enableAnimations,
  });
}

/// @nodoc
class __$$ThemeConfigImplCopyWithImpl<$Res>
    extends _$ThemeConfigCopyWithImpl<$Res, _$ThemeConfigImpl>
    implements _$$ThemeConfigImplCopyWith<$Res> {
  __$$ThemeConfigImplCopyWithImpl(
    _$ThemeConfigImpl _value,
    $Res Function(_$ThemeConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? mode = null,
    Object? primaryColor = null,
    Object? primaryVariant = null,
    Object? secondaryColor = null,
    Object? secondaryVariant = null,
    Object? backgroundColor = null,
    Object? surfaceColor = null,
    Object? cardColor = null,
    Object? textPrimary = null,
    Object? textSecondary = null,
    Object? textDisabled = null,
    Object? successColor = null,
    Object? warningColor = null,
    Object? errorColor = null,
    Object? infoColor = null,
    Object? buttonColor = freezed,
    Object? buttonTextColor = freezed,
    Object? switchActiveColor = freezed,
    Object? switchInactiveColor = freezed,
    Object? borderColor = freezed,
    Object? dividerColor = freezed,
    Object? gaugeColorRanges = null,
    Object? defaultGaugeColor = null,
    Object? fontFamily = freezed,
    Object? fontSizeSmall = null,
    Object? fontSizeMedium = null,
    Object? fontSizeLarge = null,
    Object? fontSizeTitle = null,
    Object? borderRadius = null,
    Object? cardElevation = null,
    Object? buttonHeight = null,
    Object? animationDuration = null,
    Object? enableAnimations = null,
  }) {
    return _then(
      _$ThemeConfigImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String,
        primaryColor: null == primaryColor
            ? _value.primaryColor
            : primaryColor // ignore: cast_nullable_to_non_nullable
                  as String,
        primaryVariant: null == primaryVariant
            ? _value.primaryVariant
            : primaryVariant // ignore: cast_nullable_to_non_nullable
                  as String,
        secondaryColor: null == secondaryColor
            ? _value.secondaryColor
            : secondaryColor // ignore: cast_nullable_to_non_nullable
                  as String,
        secondaryVariant: null == secondaryVariant
            ? _value.secondaryVariant
            : secondaryVariant // ignore: cast_nullable_to_non_nullable
                  as String,
        backgroundColor: null == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as String,
        surfaceColor: null == surfaceColor
            ? _value.surfaceColor
            : surfaceColor // ignore: cast_nullable_to_non_nullable
                  as String,
        cardColor: null == cardColor
            ? _value.cardColor
            : cardColor // ignore: cast_nullable_to_non_nullable
                  as String,
        textPrimary: null == textPrimary
            ? _value.textPrimary
            : textPrimary // ignore: cast_nullable_to_non_nullable
                  as String,
        textSecondary: null == textSecondary
            ? _value.textSecondary
            : textSecondary // ignore: cast_nullable_to_non_nullable
                  as String,
        textDisabled: null == textDisabled
            ? _value.textDisabled
            : textDisabled // ignore: cast_nullable_to_non_nullable
                  as String,
        successColor: null == successColor
            ? _value.successColor
            : successColor // ignore: cast_nullable_to_non_nullable
                  as String,
        warningColor: null == warningColor
            ? _value.warningColor
            : warningColor // ignore: cast_nullable_to_non_nullable
                  as String,
        errorColor: null == errorColor
            ? _value.errorColor
            : errorColor // ignore: cast_nullable_to_non_nullable
                  as String,
        infoColor: null == infoColor
            ? _value.infoColor
            : infoColor // ignore: cast_nullable_to_non_nullable
                  as String,
        buttonColor: freezed == buttonColor
            ? _value.buttonColor
            : buttonColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        buttonTextColor: freezed == buttonTextColor
            ? _value.buttonTextColor
            : buttonTextColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        switchActiveColor: freezed == switchActiveColor
            ? _value.switchActiveColor
            : switchActiveColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        switchInactiveColor: freezed == switchInactiveColor
            ? _value.switchInactiveColor
            : switchInactiveColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        borderColor: freezed == borderColor
            ? _value.borderColor
            : borderColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        dividerColor: freezed == dividerColor
            ? _value.dividerColor
            : dividerColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        gaugeColorRanges: null == gaugeColorRanges
            ? _value._gaugeColorRanges
            : gaugeColorRanges // ignore: cast_nullable_to_non_nullable
                  as List<ColorRange>,
        defaultGaugeColor: null == defaultGaugeColor
            ? _value.defaultGaugeColor
            : defaultGaugeColor // ignore: cast_nullable_to_non_nullable
                  as String,
        fontFamily: freezed == fontFamily
            ? _value.fontFamily
            : fontFamily // ignore: cast_nullable_to_non_nullable
                  as String?,
        fontSizeSmall: null == fontSizeSmall
            ? _value.fontSizeSmall
            : fontSizeSmall // ignore: cast_nullable_to_non_nullable
                  as double,
        fontSizeMedium: null == fontSizeMedium
            ? _value.fontSizeMedium
            : fontSizeMedium // ignore: cast_nullable_to_non_nullable
                  as double,
        fontSizeLarge: null == fontSizeLarge
            ? _value.fontSizeLarge
            : fontSizeLarge // ignore: cast_nullable_to_non_nullable
                  as double,
        fontSizeTitle: null == fontSizeTitle
            ? _value.fontSizeTitle
            : fontSizeTitle // ignore: cast_nullable_to_non_nullable
                  as double,
        borderRadius: null == borderRadius
            ? _value.borderRadius
            : borderRadius // ignore: cast_nullable_to_non_nullable
                  as double,
        cardElevation: null == cardElevation
            ? _value.cardElevation
            : cardElevation // ignore: cast_nullable_to_non_nullable
                  as double,
        buttonHeight: null == buttonHeight
            ? _value.buttonHeight
            : buttonHeight // ignore: cast_nullable_to_non_nullable
                  as double,
        animationDuration: null == animationDuration
            ? _value.animationDuration
            : animationDuration // ignore: cast_nullable_to_non_nullable
                  as int,
        enableAnimations: null == enableAnimations
            ? _value.enableAnimations
            : enableAnimations // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ThemeConfigImpl implements _ThemeConfig {
  const _$ThemeConfigImpl({
    @JsonKey(name: 'name') required this.name,
    @JsonKey(name: 'mode') this.mode = 'light',
    @JsonKey(name: 'primary_color') required this.primaryColor,
    @JsonKey(name: 'primary_variant') required this.primaryVariant,
    @JsonKey(name: 'secondary_color') required this.secondaryColor,
    @JsonKey(name: 'secondary_variant') required this.secondaryVariant,
    @JsonKey(name: 'background_color') required this.backgroundColor,
    @JsonKey(name: 'surface_color') required this.surfaceColor,
    @JsonKey(name: 'card_color') required this.cardColor,
    @JsonKey(name: 'text_primary') required this.textPrimary,
    @JsonKey(name: 'text_secondary') required this.textSecondary,
    @JsonKey(name: 'text_disabled') required this.textDisabled,
    @JsonKey(name: 'success_color') this.successColor = '#4CAF50',
    @JsonKey(name: 'warning_color') this.warningColor = '#FF9800',
    @JsonKey(name: 'error_color') this.errorColor = '#F44336',
    @JsonKey(name: 'info_color') this.infoColor = '#2196F3',
    @JsonKey(name: 'button_color') this.buttonColor,
    @JsonKey(name: 'button_text_color') this.buttonTextColor,
    @JsonKey(name: 'switch_active_color') this.switchActiveColor,
    @JsonKey(name: 'switch_inactive_color') this.switchInactiveColor,
    @JsonKey(name: 'border_color') this.borderColor,
    @JsonKey(name: 'divider_color') this.dividerColor,
    @JsonKey(name: 'gauge_color_ranges')
    final List<ColorRange> gaugeColorRanges = const [],
    @JsonKey(name: 'default_gauge_color') this.defaultGaugeColor = '#2196F3',
    @JsonKey(name: 'font_family') this.fontFamily,
    @JsonKey(name: 'font_size_small') this.fontSizeSmall = 12.0,
    @JsonKey(name: 'font_size_medium') this.fontSizeMedium = 14.0,
    @JsonKey(name: 'font_size_large') this.fontSizeLarge = 16.0,
    @JsonKey(name: 'font_size_title') this.fontSizeTitle = 20.0,
    @JsonKey(name: 'border_radius') this.borderRadius = 8.0,
    @JsonKey(name: 'card_elevation') this.cardElevation = 2.0,
    @JsonKey(name: 'button_height') this.buttonHeight = 48.0,
    @JsonKey(name: 'animation_duration') this.animationDuration = 300,
    @JsonKey(name: 'enable_animations') this.enableAnimations = true,
  }) : _gaugeColorRanges = gaugeColorRanges;

  factory _$ThemeConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThemeConfigImplFromJson(json);

  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'mode')
  final String mode;
  // 'light', 'dark', 'auto'
  // Primary colors
  @override
  @JsonKey(name: 'primary_color')
  final String primaryColor;
  @override
  @JsonKey(name: 'primary_variant')
  final String primaryVariant;
  @override
  @JsonKey(name: 'secondary_color')
  final String secondaryColor;
  @override
  @JsonKey(name: 'secondary_variant')
  final String secondaryVariant;
  // Background colors
  @override
  @JsonKey(name: 'background_color')
  final String backgroundColor;
  @override
  @JsonKey(name: 'surface_color')
  final String surfaceColor;
  @override
  @JsonKey(name: 'card_color')
  final String cardColor;
  // Text colors
  @override
  @JsonKey(name: 'text_primary')
  final String textPrimary;
  @override
  @JsonKey(name: 'text_secondary')
  final String textSecondary;
  @override
  @JsonKey(name: 'text_disabled')
  final String textDisabled;
  // Status colors
  @override
  @JsonKey(name: 'success_color')
  final String successColor;
  @override
  @JsonKey(name: 'warning_color')
  final String warningColor;
  @override
  @JsonKey(name: 'error_color')
  final String errorColor;
  @override
  @JsonKey(name: 'info_color')
  final String infoColor;
  // UI Element colors
  @override
  @JsonKey(name: 'button_color')
  final String? buttonColor;
  @override
  @JsonKey(name: 'button_text_color')
  final String? buttonTextColor;
  @override
  @JsonKey(name: 'switch_active_color')
  final String? switchActiveColor;
  @override
  @JsonKey(name: 'switch_inactive_color')
  final String? switchInactiveColor;
  // Border and divider colors
  @override
  @JsonKey(name: 'border_color')
  final String? borderColor;
  @override
  @JsonKey(name: 'divider_color')
  final String? dividerColor;
  // Gauge and indicator colors
  final List<ColorRange> _gaugeColorRanges;
  // Gauge and indicator colors
  @override
  @JsonKey(name: 'gauge_color_ranges')
  List<ColorRange> get gaugeColorRanges {
    if (_gaugeColorRanges is EqualUnmodifiableListView)
      return _gaugeColorRanges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gaugeColorRanges);
  }

  @override
  @JsonKey(name: 'default_gauge_color')
  final String defaultGaugeColor;
  // Typography
  @override
  @JsonKey(name: 'font_family')
  final String? fontFamily;
  @override
  @JsonKey(name: 'font_size_small')
  final double fontSizeSmall;
  @override
  @JsonKey(name: 'font_size_medium')
  final double fontSizeMedium;
  @override
  @JsonKey(name: 'font_size_large')
  final double fontSizeLarge;
  @override
  @JsonKey(name: 'font_size_title')
  final double fontSizeTitle;
  // Spacing and dimensions
  @override
  @JsonKey(name: 'border_radius')
  final double borderRadius;
  @override
  @JsonKey(name: 'card_elevation')
  final double cardElevation;
  @override
  @JsonKey(name: 'button_height')
  final double buttonHeight;
  // Animation settings
  @override
  @JsonKey(name: 'animation_duration')
  final int animationDuration;
  @override
  @JsonKey(name: 'enable_animations')
  final bool enableAnimations;

  @override
  String toString() {
    return 'ThemeConfig(name: $name, mode: $mode, primaryColor: $primaryColor, primaryVariant: $primaryVariant, secondaryColor: $secondaryColor, secondaryVariant: $secondaryVariant, backgroundColor: $backgroundColor, surfaceColor: $surfaceColor, cardColor: $cardColor, textPrimary: $textPrimary, textSecondary: $textSecondary, textDisabled: $textDisabled, successColor: $successColor, warningColor: $warningColor, errorColor: $errorColor, infoColor: $infoColor, buttonColor: $buttonColor, buttonTextColor: $buttonTextColor, switchActiveColor: $switchActiveColor, switchInactiveColor: $switchInactiveColor, borderColor: $borderColor, dividerColor: $dividerColor, gaugeColorRanges: $gaugeColorRanges, defaultGaugeColor: $defaultGaugeColor, fontFamily: $fontFamily, fontSizeSmall: $fontSizeSmall, fontSizeMedium: $fontSizeMedium, fontSizeLarge: $fontSizeLarge, fontSizeTitle: $fontSizeTitle, borderRadius: $borderRadius, cardElevation: $cardElevation, buttonHeight: $buttonHeight, animationDuration: $animationDuration, enableAnimations: $enableAnimations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemeConfigImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.primaryVariant, primaryVariant) ||
                other.primaryVariant == primaryVariant) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor) &&
            (identical(other.secondaryVariant, secondaryVariant) ||
                other.secondaryVariant == secondaryVariant) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.surfaceColor, surfaceColor) ||
                other.surfaceColor == surfaceColor) &&
            (identical(other.cardColor, cardColor) ||
                other.cardColor == cardColor) &&
            (identical(other.textPrimary, textPrimary) ||
                other.textPrimary == textPrimary) &&
            (identical(other.textSecondary, textSecondary) ||
                other.textSecondary == textSecondary) &&
            (identical(other.textDisabled, textDisabled) ||
                other.textDisabled == textDisabled) &&
            (identical(other.successColor, successColor) ||
                other.successColor == successColor) &&
            (identical(other.warningColor, warningColor) ||
                other.warningColor == warningColor) &&
            (identical(other.errorColor, errorColor) ||
                other.errorColor == errorColor) &&
            (identical(other.infoColor, infoColor) ||
                other.infoColor == infoColor) &&
            (identical(other.buttonColor, buttonColor) ||
                other.buttonColor == buttonColor) &&
            (identical(other.buttonTextColor, buttonTextColor) ||
                other.buttonTextColor == buttonTextColor) &&
            (identical(other.switchActiveColor, switchActiveColor) ||
                other.switchActiveColor == switchActiveColor) &&
            (identical(other.switchInactiveColor, switchInactiveColor) ||
                other.switchInactiveColor == switchInactiveColor) &&
            (identical(other.borderColor, borderColor) ||
                other.borderColor == borderColor) &&
            (identical(other.dividerColor, dividerColor) ||
                other.dividerColor == dividerColor) &&
            const DeepCollectionEquality().equals(
              other._gaugeColorRanges,
              _gaugeColorRanges,
            ) &&
            (identical(other.defaultGaugeColor, defaultGaugeColor) ||
                other.defaultGaugeColor == defaultGaugeColor) &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily) &&
            (identical(other.fontSizeSmall, fontSizeSmall) ||
                other.fontSizeSmall == fontSizeSmall) &&
            (identical(other.fontSizeMedium, fontSizeMedium) ||
                other.fontSizeMedium == fontSizeMedium) &&
            (identical(other.fontSizeLarge, fontSizeLarge) ||
                other.fontSizeLarge == fontSizeLarge) &&
            (identical(other.fontSizeTitle, fontSizeTitle) ||
                other.fontSizeTitle == fontSizeTitle) &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius) &&
            (identical(other.cardElevation, cardElevation) ||
                other.cardElevation == cardElevation) &&
            (identical(other.buttonHeight, buttonHeight) ||
                other.buttonHeight == buttonHeight) &&
            (identical(other.animationDuration, animationDuration) ||
                other.animationDuration == animationDuration) &&
            (identical(other.enableAnimations, enableAnimations) ||
                other.enableAnimations == enableAnimations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    name,
    mode,
    primaryColor,
    primaryVariant,
    secondaryColor,
    secondaryVariant,
    backgroundColor,
    surfaceColor,
    cardColor,
    textPrimary,
    textSecondary,
    textDisabled,
    successColor,
    warningColor,
    errorColor,
    infoColor,
    buttonColor,
    buttonTextColor,
    switchActiveColor,
    switchInactiveColor,
    borderColor,
    dividerColor,
    const DeepCollectionEquality().hash(_gaugeColorRanges),
    defaultGaugeColor,
    fontFamily,
    fontSizeSmall,
    fontSizeMedium,
    fontSizeLarge,
    fontSizeTitle,
    borderRadius,
    cardElevation,
    buttonHeight,
    animationDuration,
    enableAnimations,
  ]);

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemeConfigImplCopyWith<_$ThemeConfigImpl> get copyWith =>
      __$$ThemeConfigImplCopyWithImpl<_$ThemeConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThemeConfigImplToJson(this);
  }
}

abstract class _ThemeConfig implements ThemeConfig {
  const factory _ThemeConfig({
    @JsonKey(name: 'name') required final String name,
    @JsonKey(name: 'mode') final String mode,
    @JsonKey(name: 'primary_color') required final String primaryColor,
    @JsonKey(name: 'primary_variant') required final String primaryVariant,
    @JsonKey(name: 'secondary_color') required final String secondaryColor,
    @JsonKey(name: 'secondary_variant') required final String secondaryVariant,
    @JsonKey(name: 'background_color') required final String backgroundColor,
    @JsonKey(name: 'surface_color') required final String surfaceColor,
    @JsonKey(name: 'card_color') required final String cardColor,
    @JsonKey(name: 'text_primary') required final String textPrimary,
    @JsonKey(name: 'text_secondary') required final String textSecondary,
    @JsonKey(name: 'text_disabled') required final String textDisabled,
    @JsonKey(name: 'success_color') final String successColor,
    @JsonKey(name: 'warning_color') final String warningColor,
    @JsonKey(name: 'error_color') final String errorColor,
    @JsonKey(name: 'info_color') final String infoColor,
    @JsonKey(name: 'button_color') final String? buttonColor,
    @JsonKey(name: 'button_text_color') final String? buttonTextColor,
    @JsonKey(name: 'switch_active_color') final String? switchActiveColor,
    @JsonKey(name: 'switch_inactive_color') final String? switchInactiveColor,
    @JsonKey(name: 'border_color') final String? borderColor,
    @JsonKey(name: 'divider_color') final String? dividerColor,
    @JsonKey(name: 'gauge_color_ranges')
    final List<ColorRange> gaugeColorRanges,
    @JsonKey(name: 'default_gauge_color') final String defaultGaugeColor,
    @JsonKey(name: 'font_family') final String? fontFamily,
    @JsonKey(name: 'font_size_small') final double fontSizeSmall,
    @JsonKey(name: 'font_size_medium') final double fontSizeMedium,
    @JsonKey(name: 'font_size_large') final double fontSizeLarge,
    @JsonKey(name: 'font_size_title') final double fontSizeTitle,
    @JsonKey(name: 'border_radius') final double borderRadius,
    @JsonKey(name: 'card_elevation') final double cardElevation,
    @JsonKey(name: 'button_height') final double buttonHeight,
    @JsonKey(name: 'animation_duration') final int animationDuration,
    @JsonKey(name: 'enable_animations') final bool enableAnimations,
  }) = _$ThemeConfigImpl;

  factory _ThemeConfig.fromJson(Map<String, dynamic> json) =
      _$ThemeConfigImpl.fromJson;

  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'mode')
  String get mode; // 'light', 'dark', 'auto'
  // Primary colors
  @override
  @JsonKey(name: 'primary_color')
  String get primaryColor;
  @override
  @JsonKey(name: 'primary_variant')
  String get primaryVariant;
  @override
  @JsonKey(name: 'secondary_color')
  String get secondaryColor;
  @override
  @JsonKey(name: 'secondary_variant')
  String get secondaryVariant; // Background colors
  @override
  @JsonKey(name: 'background_color')
  String get backgroundColor;
  @override
  @JsonKey(name: 'surface_color')
  String get surfaceColor;
  @override
  @JsonKey(name: 'card_color')
  String get cardColor; // Text colors
  @override
  @JsonKey(name: 'text_primary')
  String get textPrimary;
  @override
  @JsonKey(name: 'text_secondary')
  String get textSecondary;
  @override
  @JsonKey(name: 'text_disabled')
  String get textDisabled; // Status colors
  @override
  @JsonKey(name: 'success_color')
  String get successColor;
  @override
  @JsonKey(name: 'warning_color')
  String get warningColor;
  @override
  @JsonKey(name: 'error_color')
  String get errorColor;
  @override
  @JsonKey(name: 'info_color')
  String get infoColor; // UI Element colors
  @override
  @JsonKey(name: 'button_color')
  String? get buttonColor;
  @override
  @JsonKey(name: 'button_text_color')
  String? get buttonTextColor;
  @override
  @JsonKey(name: 'switch_active_color')
  String? get switchActiveColor;
  @override
  @JsonKey(name: 'switch_inactive_color')
  String? get switchInactiveColor; // Border and divider colors
  @override
  @JsonKey(name: 'border_color')
  String? get borderColor;
  @override
  @JsonKey(name: 'divider_color')
  String? get dividerColor; // Gauge and indicator colors
  @override
  @JsonKey(name: 'gauge_color_ranges')
  List<ColorRange> get gaugeColorRanges;
  @override
  @JsonKey(name: 'default_gauge_color')
  String get defaultGaugeColor; // Typography
  @override
  @JsonKey(name: 'font_family')
  String? get fontFamily;
  @override
  @JsonKey(name: 'font_size_small')
  double get fontSizeSmall;
  @override
  @JsonKey(name: 'font_size_medium')
  double get fontSizeMedium;
  @override
  @JsonKey(name: 'font_size_large')
  double get fontSizeLarge;
  @override
  @JsonKey(name: 'font_size_title')
  double get fontSizeTitle; // Spacing and dimensions
  @override
  @JsonKey(name: 'border_radius')
  double get borderRadius;
  @override
  @JsonKey(name: 'card_elevation')
  double get cardElevation;
  @override
  @JsonKey(name: 'button_height')
  double get buttonHeight; // Animation settings
  @override
  @JsonKey(name: 'animation_duration')
  int get animationDuration;
  @override
  @JsonKey(name: 'enable_animations')
  bool get enableAnimations;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThemeConfigImplCopyWith<_$ThemeConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
