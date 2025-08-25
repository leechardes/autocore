import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) =>
      ((color.a * 255).round() << 24) |
      ((color.r * 255).round() << 16) |
      ((color.g * 255).round() << 8) |
      (color.b * 255).round();
}

class ColorListConverter implements JsonConverter<List<Color>, List<int>> {
  const ColorListConverter();

  @override
  List<Color> fromJson(List<int> json) => json.map(Color.new).toList();

  @override
  List<int> toJson(List<Color> colors) => colors
      .map(
        (e) =>
            ((e.a * 255).round() << 24) |
            ((e.r * 255).round() << 16) |
            ((e.g * 255).round() << 8) |
            (e.b * 255).round(),
      )
      .toList();
}

class BoxShadowConverter
    implements JsonConverter<BoxShadow, Map<String, dynamic>> {
  const BoxShadowConverter();

  @override
  BoxShadow fromJson(Map<String, dynamic> json) {
    return BoxShadow(
      color: Color(json['color'] as int),
      offset: Offset(
        (json['offsetX'] as num).toDouble(),
        (json['offsetY'] as num).toDouble(),
      ),
      blurRadius: (json['blurRadius'] as num).toDouble(),
      spreadRadius: (json['spreadRadius'] as num?)?.toDouble() ?? 0.0,
      blurStyle: BlurStyle.values[json['blurStyle'] as int? ?? 0],
    );
  }

  @override
  Map<String, dynamic> toJson(BoxShadow shadow) {
    return {
      'color':
          ((shadow.color.a * 255).round() << 24) |
          ((shadow.color.r * 255).round() << 16) |
          ((shadow.color.g * 255).round() << 8) |
          (shadow.color.b * 255).round(),
      'offsetX': shadow.offset.dx,
      'offsetY': shadow.offset.dy,
      'blurRadius': shadow.blurRadius,
      'spreadRadius': shadow.spreadRadius,
      'blurStyle': shadow.blurStyle.index,
    };
  }
}

class BoxShadowListConverter
    implements JsonConverter<List<BoxShadow>, List<Map<String, dynamic>>> {
  const BoxShadowListConverter();

  @override
  List<BoxShadow> fromJson(List<Map<String, dynamic>> json) {
    const converter = BoxShadowConverter();
    return json.map((e) => converter.fromJson(e)).toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<BoxShadow> shadows) {
    const converter = BoxShadowConverter();
    return shadows.map((e) => converter.toJson(e)).toList();
  }
}

class FontWeightConverter implements JsonConverter<FontWeight, String> {
  const FontWeightConverter();

  @override
  FontWeight fromJson(String json) {
    switch (json) {
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  @override
  String toJson(FontWeight weight) {
    if (weight == FontWeight.w100) return 'w100';
    if (weight == FontWeight.w200) return 'w200';
    if (weight == FontWeight.w300) return 'w300';
    if (weight == FontWeight.w400) return 'w400';
    if (weight == FontWeight.w500) return 'w500';
    if (weight == FontWeight.w600) return 'w600';
    if (weight == FontWeight.w700) return 'w700';
    if (weight == FontWeight.w800) return 'w800';
    if (weight == FontWeight.w900) return 'w900';
    return 'w400';
  }
}

class DurationConverter implements JsonConverter<Duration, int> {
  const DurationConverter();

  @override
  Duration fromJson(int json) => Duration(milliseconds: json);

  @override
  int toJson(Duration duration) => duration.inMilliseconds;
}

class CurveConverter implements JsonConverter<Curve, String> {
  const CurveConverter();

  @override
  Curve fromJson(String json) {
    switch (json) {
      case 'linear':
        return Curves.linear;
      case 'easeIn':
        return Curves.easeIn;
      case 'easeOut':
        return Curves.easeOut;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'fastOutSlowIn':
        return Curves.fastOutSlowIn;
      case 'bounceIn':
        return Curves.bounceIn;
      case 'bounceOut':
        return Curves.bounceOut;
      case 'bounceInOut':
        return Curves.bounceInOut;
      case 'elasticIn':
        return Curves.elasticIn;
      case 'elasticOut':
        return Curves.elasticOut;
      case 'elasticInOut':
        return Curves.elasticInOut;
      default:
        return Curves.easeInOut;
    }
  }

  @override
  String toJson(Curve curve) {
    if (curve == Curves.linear) return 'linear';
    if (curve == Curves.easeIn) return 'easeIn';
    if (curve == Curves.easeOut) return 'easeOut';
    if (curve == Curves.easeInOut) return 'easeInOut';
    if (curve == Curves.fastOutSlowIn) return 'fastOutSlowIn';
    if (curve == Curves.bounceIn) return 'bounceIn';
    if (curve == Curves.bounceOut) return 'bounceOut';
    if (curve == Curves.bounceInOut) return 'bounceInOut';
    if (curve == Curves.elasticIn) return 'elasticIn';
    if (curve == Curves.elasticOut) return 'elasticOut';
    if (curve == Curves.elasticInOut) return 'elasticInOut';
    return 'easeInOut';
  }
}
