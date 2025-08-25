import 'dart:math' as math;

import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ACGaugeType { circular, linear, battery, semicircular }

class ACGaugeZone {
  final double start;
  final double end;
  final Color color;
  final String? label;

  const ACGaugeZone({
    required this.start,
    required this.end,
    required this.color,
    this.label,
  });
}

class ACGauge extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ACGaugeType type;
  final String? unit;
  final String? label;
  final double? width;
  final double? height;
  final Color? primaryColor;
  final Color? backgroundColor;
  final List<ACGaugeZone>? zones;
  final bool showValue;
  final bool showLabel;
  final bool animated;
  final Duration? animationDuration;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final double? strokeWidth;

  const ACGauge({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.type = ACGaugeType.circular,
    this.unit,
    this.label,
    this.width,
    this.height,
    this.primaryColor,
    this.backgroundColor,
    this.zones,
    this.showValue = true,
    this.showLabel = true,
    this.animated = true,
    this.animationDuration,
    this.valueStyle,
    this.labelStyle,
    this.strokeWidth,
  });

  @override
  State<ACGauge> createState() => _ACGaugeState();
}

class _ACGaugeState extends State<ACGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: widget.min, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    if (widget.animated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ACGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.animated) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case ACGaugeType.circular:
        return _buildCircularGauge(context);
      case ACGaugeType.linear:
        return _buildLinearGauge(context);
      case ACGaugeType.battery:
        return _buildBatteryGauge(context);
      case ACGaugeType.semicircular:
        return _buildSemicircularGauge(context);
    }
  }

  Widget _buildCircularGauge(BuildContext context) {
    final theme = context.acTheme;
    final size = widget.width ?? widget.height ?? 200;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animatedValue = widget.animated
              ? _animation.value
              : widget.value;
          return CustomPaint(
            painter: _CircularGaugePainter(
              value: animatedValue,
              min: widget.min,
              max: widget.max,
              primaryColor: widget.primaryColor ?? theme.primaryColor,
              backgroundColor: widget.backgroundColor ?? theme.surfaceColor,
              strokeWidth: widget.strokeWidth ?? size * 0.1,
              zones: widget.zones,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showValue)
                    Text(
                      '${animatedValue.toStringAsFixed(1)}${widget.unit ?? ''}',
                      style:
                          widget.valueStyle ??
                          TextStyle(
                            fontSize: size * 0.15,
                            fontWeight: theme.fontWeightBold,
                            color: _getValueColor(animatedValue),
                          ),
                    ),
                  if (widget.showLabel && widget.label != null)
                    Text(
                      widget.label!,
                      style:
                          widget.labelStyle ??
                          TextStyle(
                            fontSize: size * 0.08,
                            color: theme.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinearGauge(BuildContext context) {
    final theme = context.acTheme;
    final width = widget.width ?? 200;
    final height = widget.height ?? 40;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabel && widget.label != null)
            Padding(
              padding: EdgeInsets.only(bottom: theme.spacingXs),
              child: Text(
                widget.label!,
                style:
                    widget.labelStyle ??
                    TextStyle(
                      fontSize: theme.fontSizeSmall,
                      color: theme.textSecondary,
                    ),
              ),
            ),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final animatedValue = widget.animated
                    ? _animation.value
                    : widget.value;
                final percentage =
                    (animatedValue - widget.min) / (widget.max - widget.min);

                return Stack(
                  children: [
                    // Background
                    Container(
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ?? theme.surfaceColor,
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: theme.depressedShadow,
                      ),
                    ),
                    // Zones
                    if (widget.zones != null)
                      ...widget.zones!.map((zone) {
                        final zoneStart =
                            (zone.start - widget.min) /
                            (widget.max - widget.min);
                        final zoneEnd =
                            (zone.end - widget.min) / (widget.max - widget.min);
                        return Positioned(
                          left: width * zoneStart,
                          width: width * (zoneEnd - zoneStart),
                          top: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: zone.color.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(height / 2),
                            ),
                          ),
                        );
                      }),
                    // Progress
                    AnimatedContainer(
                      duration: widget.animationDuration ?? 300.ms,
                      width: width * percentage.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getValueColor(animatedValue),
                            _getValueColor(
                              animatedValue,
                            ).withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: _getValueColor(
                              animatedValue,
                            ).withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    // Value text
                    if (widget.showValue)
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '${animatedValue.toStringAsFixed(1)}${widget.unit ?? ''}',
                            style:
                                widget.valueStyle ??
                                TextStyle(
                                  fontSize: height * 0.4,
                                  fontWeight: theme.fontWeightBold,
                                  color: theme.textPrimary,
                                ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryGauge(BuildContext context) {
    final theme = context.acTheme;
    final width = widget.width ?? 100;
    final height = widget.height ?? 50;

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animatedValue = widget.animated
              ? _animation.value
              : widget.value;
          final percentage =
              (animatedValue - widget.min) / (widget.max - widget.min);

          return CustomPaint(
            painter: _BatteryGaugePainter(
              percentage: percentage,
              color: _getBatteryColor(percentage),
              backgroundColor: widget.backgroundColor ?? theme.surfaceColor,
            ),
            child: Center(
              child: widget.showValue
                  ? Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style:
                          widget.valueStyle ??
                          TextStyle(
                            fontSize: height * 0.3,
                            fontWeight: theme.fontWeightBold,
                            color: theme.textPrimary,
                          ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSemicircularGauge(BuildContext context) {
    final theme = context.acTheme;
    final width = widget.width ?? 200;
    final height = widget.height ?? 100;

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animatedValue = widget.animated
              ? _animation.value
              : widget.value;
          return CustomPaint(
            painter: _SemicircularGaugePainter(
              value: animatedValue,
              min: widget.min,
              max: widget.max,
              primaryColor: widget.primaryColor ?? theme.primaryColor,
              backgroundColor: widget.backgroundColor ?? theme.surfaceColor,
              strokeWidth: widget.strokeWidth ?? width * 0.08,
              zones: widget.zones,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: height * 0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showValue)
                      Text(
                        '${animatedValue.toStringAsFixed(1)}${widget.unit ?? ''}',
                        style:
                            widget.valueStyle ??
                            TextStyle(
                              fontSize: width * 0.12,
                              fontWeight: theme.fontWeightBold,
                              color: _getValueColor(animatedValue),
                            ),
                      ),
                    if (widget.showLabel && widget.label != null)
                      Text(
                        widget.label!,
                        style:
                            widget.labelStyle ??
                            TextStyle(
                              fontSize: width * 0.06,
                              color: theme.textSecondary,
                            ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getValueColor(double value) {
    final theme = context.acTheme;

    if (widget.zones != null) {
      for (final zone in widget.zones!) {
        if (value >= zone.start && value <= zone.end) {
          return zone.color;
        }
      }
    }

    return widget.primaryColor ?? theme.primaryColor;
  }

  Color _getBatteryColor(double percentage) {
    final theme = context.acTheme;

    if (percentage < 0.2) return theme.errorColor;
    if (percentage < 0.5) return theme.warningColor;
    return theme.successColor;
  }
}

// Custom Painters

class _CircularGaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;
  final List<ACGaugeZone>? zones;

  _CircularGaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.primaryColor,
    required this.backgroundColor,
    required this.strokeWidth,
    this.zones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Value arc
    final percentage = (value - min) / (max - min);
    final sweepAngle = 2 * math.pi * percentage;

    final valuePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(_CircularGaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class _BatteryGaugePainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  _BatteryGaugePainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final batteryBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.15, size.width * 0.9, size.height * 0.7),
      const Radius.circular(4),
    );

    final batteryTip = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.9,
        size.height * 0.35,
        size.width * 0.1,
        size.height * 0.3,
      ),
      const Radius.circular(2),
    );

    // Draw battery outline
    final outlinePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(batteryBody, outlinePaint);
    canvas.drawRRect(batteryTip, outlinePaint);

    // Draw battery fill
    if (percentage > 0) {
      final fillWidth = (size.width * 0.9 - 8) * percentage;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          4,
          size.height * 0.15 + 4,
          fillWidth,
          size.height * 0.7 - 8,
        ),
        const Radius.circular(2),
      );

      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(fillRect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_BatteryGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}

class _SemicircularGaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;
  final List<ACGaugeZone>? zones;

  _SemicircularGaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.primaryColor,
    required this.backgroundColor,
    required this.strokeWidth,
    this.zones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth;

    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Value arc
    final percentage = (value - min) / (max - min);
    final sweepAngle = math.pi * percentage;

    final valuePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(_SemicircularGaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
