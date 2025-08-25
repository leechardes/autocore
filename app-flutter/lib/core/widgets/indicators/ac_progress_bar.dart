import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ACProgressBarType { linear, circular, segmented, stepped }

enum ACProgressBarLabelPosition { none, center, above, below, start, end }

class ACProgressSegment {
  final double value;
  final Color? color;
  final String? label;

  const ACProgressSegment({required this.value, this.color, this.label});
}

class ACProgressBar extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ACProgressBarType type;
  final double? width;
  final double? height;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? trackColor;
  final List<ACProgressSegment>? segments;
  final bool showValue;
  final bool showPercentage;
  final String? label;
  final ACProgressBarLabelPosition labelPosition;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final double? strokeWidth;
  final bool animated;
  final Duration? animationDuration;
  final BorderRadius? borderRadius;
  final bool striped;
  final bool indeterminate;
  final int? steps;
  final Widget? leading;
  final Widget? trailing;

  const ACProgressBar({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.type = ACProgressBarType.linear,
    this.width,
    this.height,
    this.primaryColor,
    this.backgroundColor,
    this.trackColor,
    this.segments,
    this.showValue = false,
    this.showPercentage = true,
    this.label,
    this.labelPosition = ACProgressBarLabelPosition.center,
    this.valueStyle,
    this.labelStyle,
    this.strokeWidth,
    this.animated = true,
    this.animationDuration,
    this.borderRadius,
    this.striped = false,
    this.indeterminate = false,
    this.steps,
    this.leading,
    this.trailing,
  });

  @override
  State<ACProgressBar> createState() => _ACProgressBarState();
}

class _ACProgressBarState extends State<ACProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _indeterminateController;
  late Animation<double> _progressAnimation;
  late Animation<double> _indeterminateAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 800),
      vsync: this,
    );

    _indeterminateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: widget.min, end: widget.value)
        .animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _indeterminateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _indeterminateController, curve: Curves.linear),
    );

    if (widget.animated && !widget.indeterminate) {
      _progressController.forward();
    }

    if (widget.indeterminate) {
      _indeterminateController.repeat();
    }
  }

  @override
  void didUpdateWidget(ACProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value &&
        widget.animated &&
        !widget.indeterminate) {
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.value,
          ).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeInOutCubic,
            ),
          );
      _progressController.forward(from: 0);
    }

    if (widget.indeterminate && !oldWidget.indeterminate) {
      _indeterminateController.repeat();
    } else if (!widget.indeterminate && oldWidget.indeterminate) {
      _indeterminateController.stop();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _indeterminateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case ACProgressBarType.linear:
        return _buildLinearProgress(context);
      case ACProgressBarType.circular:
        return _buildCircularProgress(context);
      case ACProgressBarType.segmented:
        return _buildSegmentedProgress(context);
      case ACProgressBarType.stepped:
        return _buildSteppedProgress(context);
    }
  }

  Widget _buildLinearProgress(BuildContext context) {
    final theme = context.acTheme;
    final effectiveWidth = widget.width ?? 200;
    final effectiveHeight = widget.height ?? 8;

    Widget progressBar = SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: AnimatedBuilder(
        animation: widget.indeterminate
            ? _indeterminateAnimation
            : _progressAnimation,
        builder: (context, child) {
          final percentage = widget.indeterminate
              ? 1.0
              : (_progressAnimation.value - widget.min) /
                    (widget.max - widget.min);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Track
              Container(
                decoration: BoxDecoration(
                  color:
                      widget.trackColor ??
                      widget.backgroundColor ??
                      theme.surfaceColor,
                  borderRadius:
                      widget.borderRadius ??
                      BorderRadius.circular(effectiveHeight / 2),
                  boxShadow: theme.depressedShadow,
                ),
              ),
              // Progress
              if (widget.indeterminate)
                _buildIndeterminateLinear(
                  theme,
                  effectiveWidth,
                  effectiveHeight,
                )
              else
                AnimatedContainer(
                  duration: widget.animationDuration ?? 300.ms,
                  width: effectiveWidth * percentage.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    gradient: widget.striped
                        ? _createStripedGradient(
                            widget.primaryColor ?? theme.primaryColor,
                          )
                        : LinearGradient(
                            colors: [
                              widget.primaryColor ?? theme.primaryColor,
                              (widget.primaryColor ?? theme.primaryColor)
                                  .withValues(alpha: 0.8),
                            ],
                          ),
                    borderRadius:
                        widget.borderRadius ??
                        BorderRadius.circular(effectiveHeight / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.primaryColor ?? theme.primaryColor)
                            .withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              // Label
              if (widget.labelPosition == ACProgressBarLabelPosition.center &&
                  (widget.showValue || widget.showPercentage))
                Positioned.fill(
                  child: Center(
                    child: Text(
                      _getProgressText(percentage),
                      style:
                          widget.valueStyle ??
                          TextStyle(
                            fontSize: effectiveHeight * 0.7,
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
    );

    // Add label if needed
    if (widget.label != null ||
        (widget.labelPosition != ACProgressBarLabelPosition.center &&
            widget.labelPosition != ACProgressBarLabelPosition.none)) {
      progressBar = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelPosition == ACProgressBarLabelPosition.above)
            _buildLabel(context),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                SizedBox(width: theme.spacingXs),
              ],
              if (widget.labelPosition == ACProgressBarLabelPosition.start)
                _buildLabel(context),
              Expanded(child: progressBar),
              if (widget.labelPosition == ACProgressBarLabelPosition.end)
                _buildLabel(context),
              if (widget.trailing != null) ...[
                SizedBox(width: theme.spacingXs),
                widget.trailing!,
              ],
            ],
          ),
          if (widget.labelPosition == ACProgressBarLabelPosition.below)
            _buildLabel(context),
        ],
      );
    }

    return progressBar;
  }

  Widget _buildCircularProgress(BuildContext context) {
    final theme = context.acTheme;
    final size = widget.width ?? widget.height ?? 48;
    final strokeWidth = widget.strokeWidth ?? size * 0.1;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: widget.indeterminate
            ? _indeterminateAnimation
            : _progressAnimation,
        builder: (context, child) {
          final percentage = widget.indeterminate
              ? null
              : (_progressAnimation.value - widget.min) /
                    (widget.max - widget.min);

          if (widget.indeterminate) {
            return CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.primaryColor ?? theme.primaryColor,
              ),
              backgroundColor:
                  widget.trackColor ??
                  widget.backgroundColor ??
                  theme.surfaceColor,
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.primaryColor ?? theme.primaryColor,
                ),
                backgroundColor:
                    widget.trackColor ??
                    widget.backgroundColor ??
                    theme.surfaceColor,
              ),
              if (widget.showValue || widget.showPercentage)
                Text(
                  _getProgressText(percentage ?? 0),
                  style:
                      widget.valueStyle ??
                      TextStyle(
                        fontSize: size * 0.2,
                        fontWeight: theme.fontWeightBold,
                        color: theme.textPrimary,
                      ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentedProgress(BuildContext context) {
    final theme = context.acTheme;
    final effectiveWidth = widget.width ?? 200;
    final effectiveHeight = widget.height ?? 24;

    if (widget.segments == null || widget.segments!.isEmpty) {
      return _buildLinearProgress(context);
    }

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          final currentValue = widget.animated
              ? _progressAnimation.value
              : widget.value;

          return Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color:
                      widget.trackColor ??
                      widget.backgroundColor ??
                      theme.surfaceColor,
                  borderRadius:
                      widget.borderRadius ??
                      BorderRadius.circular(theme.borderRadiusSmall),
                  boxShadow: theme.depressedShadow,
                ),
              ),
              // Segments
              Row(
                children: widget.segments!.map((segment) {
                  final segmentWidth =
                      effectiveWidth *
                      (segment.value /
                          widget.segments!.fold(
                            0.0,
                            (sum, s) => sum + s.value,
                          ));
                  final isActive = currentValue >= segment.value;

                  return AnimatedContainer(
                    duration: widget.animationDuration ?? 300.ms,
                    width: segmentWidth,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (segment.color ?? theme.primaryColor)
                          : Colors.transparent,
                      borderRadius:
                          widget.borderRadius ??
                          BorderRadius.circular(theme.borderRadiusSmall),
                    ),
                    child: segment.label != null
                        ? Center(
                            child: Text(
                              segment.label!,
                              style: TextStyle(
                                fontSize: effectiveHeight * 0.5,
                                color: isActive
                                    ? theme.textPrimary
                                    : theme.textSecondary,
                                fontWeight: theme.fontWeightRegular,
                              ),
                            ),
                          )
                        : null,
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSteppedProgress(BuildContext context) {
    final theme = context.acTheme;
    final effectiveWidth = widget.width ?? 200;
    final effectiveHeight = widget.height ?? 40;
    final steps = widget.steps ?? 5;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          final currentValue = widget.animated
              ? _progressAnimation.value
              : widget.value;
          final percentage =
              (currentValue - widget.min) / (widget.max - widget.min);
          final activeSteps = (percentage * steps).floor();

          return Row(
            children: List.generate(steps, (index) {
              final isActive = index < activeSteps;
              final isCurrent = index == activeSteps;
              // final stepWidth = (effectiveWidth - (steps - 1) * 4) / steps;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < steps - 1 ? 4 : 0),
                  height: effectiveHeight,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (widget.primaryColor ?? theme.primaryColor)
                        : isCurrent
                        ? (widget.primaryColor ?? theme.primaryColor)
                              .withValues(alpha: 0.5)
                        : widget.trackColor ??
                              widget.backgroundColor ??
                              theme.surfaceColor,
                    borderRadius: BorderRadius.circular(
                      theme.borderRadiusSmall,
                    ),
                    boxShadow: isActive ? theme.subtleShadow : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: effectiveHeight * 0.4,
                        color: isActive ? Colors.white : theme.textSecondary,
                        fontWeight: theme.fontWeightRegular,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildIndeterminateLinear(dynamic theme, double width, double height) {
    return AnimatedBuilder(
      animation: _indeterminateAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              left: width * (_indeterminateAnimation.value - 0.3),
              width: width * 0.3,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (widget.primaryColor ?? Colors.blue).withValues(alpha: 0),
                      widget.primaryColor ?? Colors.blue,
                      (widget.primaryColor ?? Colors.blue).withValues(alpha: 0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(BuildContext context) {
    final theme = context.acTheme;
    final percentage =
        (_progressAnimation.value - widget.min) / (widget.max - widget.min);

    String text = widget.label ?? '';
    if (widget.showValue || widget.showPercentage) {
      final progressText = _getProgressText(percentage);
      text = text.isEmpty ? progressText : '$text: $progressText';
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingXs,
        vertical: theme.spacingXs / 2,
      ),
      child: Text(
        text,
        style:
            widget.labelStyle ??
            TextStyle(
              fontSize: theme.fontSizeSmall,
              color: theme.textSecondary,
            ),
      ),
    );
  }

  String _getProgressText(double percentage) {
    if (widget.showPercentage) {
      return '${(percentage * 100).toStringAsFixed(0)}%';
    } else if (widget.showValue) {
      return widget.value.toStringAsFixed(1);
    }
    return '';
  }

  LinearGradient _createStripedGradient(Color color) {
    return LinearGradient(
      colors: [
        color,
        color,
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.8),
      ],
      stops: const [0.0, 0.5, 0.5, 1.0],
      tileMode: TileMode.repeated,
      transform: const GradientRotation(0.785398), // 45 degrees
    );
  }
}
