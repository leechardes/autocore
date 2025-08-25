import 'dart:async';

import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ACButtonType { elevated, flat, outlined, ghost }

enum ACButtonSize { small, medium, large }

enum ACButtonState { idle, pressed, loading, disabled, success, error }

class ACButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget child;
  final ACButtonType type;
  final ACButtonSize size;
  final ACButtonState state;
  final bool hapticFeedback;
  final Color? color;
  final Color? textColor;
  final Color? successColor;
  final Color? errorColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Duration? animationDuration;
  final Curve? animationCurve;

  // Para auto-reset após sucesso/erro
  final Duration? autoResetDuration;
  final VoidCallback? onStateChanged;

  const ACButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.onLongPress,
    this.type = ACButtonType.elevated,
    this.size = ACButtonSize.medium,
    this.state = ACButtonState.idle,
    this.hapticFeedback = true,
    this.color,
    this.textColor,
    this.successColor,
    this.errorColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.animationDuration,
    this.animationCurve,
    this.autoResetDuration,
    this.onStateChanged,
  });

  // Factory constructors para estados específicos
  const ACButton.loading({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.type = ACButtonType.elevated,
    this.size = ACButtonSize.medium,
    this.hapticFeedback = true,
    this.color,
    this.textColor,
    this.successColor,
    this.errorColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.animationDuration,
    this.animationCurve,
    this.autoResetDuration,
    this.onStateChanged,
  }) : state = ACButtonState.loading;

  const ACButton.disabled({
    super.key,
    required this.child,
    this.type = ACButtonType.elevated,
    this.size = ACButtonSize.medium,
    this.hapticFeedback = true,
    this.color,
    this.textColor,
    this.successColor,
    this.errorColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.animationDuration,
    this.animationCurve,
    this.autoResetDuration,
    this.onStateChanged,
  }) : state = ACButtonState.disabled,
       onPressed = null,
       onLongPress = null;

  @override
  State<ACButton> createState() => _ACButtonState();
}

class _ACButtonState extends State<ACButton> {
  bool _isPressed = false;
  Timer? _autoResetTimer;

  @override
  void initState() {
    super.initState();
    _startAutoResetTimer();
  }

  @override
  void didUpdateWidget(ACButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _startAutoResetTimer();
      widget.onStateChanged?.call();
    }
  }

  @override
  void dispose() {
    _autoResetTimer?.cancel();
    super.dispose();
  }

  void _startAutoResetTimer() {
    _autoResetTimer?.cancel();

    if ((widget.state == ACButtonState.success ||
            widget.state == ACButtonState.error) &&
        widget.autoResetDuration != null) {
      _autoResetTimer = Timer(widget.autoResetDuration!, () {
        if (mounted && widget.onStateChanged != null) {
          widget.onStateChanged!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    final isDisabled =
        widget.state == ACButtonState.disabled ||
        (widget.onPressed == null && widget.onLongPress == null);

    final effectiveColor = _getEffectiveColor(context);
    final effectiveTextColor = _getEffectiveTextColor(context);
    final effectivePadding = _getEffectivePadding(context);
    final effectiveBorderRadius = _getEffectiveBorderRadius(context);
    final effectiveBoxShadow = _getEffectiveBoxShadow(context);
    final effectiveHeight = _getEffectiveHeight(context);

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _handleTapDown(),
      onTapUp: isDisabled ? null : (_) => _handleTapUp(),
      onTapCancel: isDisabled ? null : _handleTapCancel,
      onTap: isDisabled ? null : _handleTap,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      child:
          AnimatedContainer(
                duration: widget.animationDuration ?? theme.animationFast,
                curve: widget.animationCurve ?? theme.animationCurve,
                width: widget.width,
                height: effectiveHeight,
                decoration: BoxDecoration(
                  color: _getStateColor(effectiveColor, isDisabled),
                  borderRadius: effectiveBorderRadius,
                  border: widget.type == ACButtonType.outlined
                      ? Border.all(
                          color: isDisabled
                              ? effectiveColor.withValues(alpha: 0.3)
                              : effectiveColor,
                          width: 2,
                        )
                      : null,
                  boxShadow: isDisabled
                      ? null
                      : _isPressed
                      ? theme.depressedShadow
                      : effectiveBoxShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: effectivePadding,
                    child: Center(child: _buildChild(effectiveTextColor)),
                  ),
                ),
              )
              .animate(target: _isPressed ? 1 : 0)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(0.95, 0.95),
                duration: 100.ms,
              ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      width: _getLoadingSize(),
      height: _getLoadingSize(),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Color _getEffectiveColor(BuildContext context) {
    final theme = context.acTheme;

    if (widget.color != null) return widget.color!;

    switch (widget.type) {
      case ACButtonType.elevated:
        return theme.primaryColor;
      case ACButtonType.flat:
        return theme.surfaceColor;
      case ACButtonType.outlined:
        return Colors.transparent;
      case ACButtonType.ghost:
        return Colors.transparent;
    }
  }

  Color _getEffectiveTextColor(BuildContext context) {
    final theme = context.acTheme;

    if (widget.textColor != null) return widget.textColor!;

    switch (widget.type) {
      case ACButtonType.elevated:
        return Colors.white;
      case ACButtonType.flat:
        return theme.textPrimary;
      case ACButtonType.outlined:
        return theme.primaryColor;
      case ACButtonType.ghost:
        return theme.textPrimary;
    }
  }

  EdgeInsets _getEffectivePadding(BuildContext context) {
    if (widget.padding != null) return widget.padding!;

    final theme = context.acTheme;

    switch (widget.size) {
      case ACButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: theme.spacingMd,
          vertical: theme.spacingSm,
        );
      case ACButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: theme.spacingLg,
          vertical: theme.spacingMd,
        );
      case ACButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: theme.spacingXl,
          vertical: theme.spacingLg,
        );
    }
  }

  BorderRadius _getEffectiveBorderRadius(BuildContext context) {
    if (widget.borderRadius != null) return widget.borderRadius!;

    final theme = context.acTheme;

    switch (widget.size) {
      case ACButtonSize.small:
        return BorderRadius.circular(theme.borderRadiusSmall);
      case ACButtonSize.medium:
        return BorderRadius.circular(theme.borderRadiusMedium);
      case ACButtonSize.large:
        return BorderRadius.circular(theme.borderRadiusLarge);
    }
  }

  List<BoxShadow>? _getEffectiveBoxShadow(BuildContext context) {
    if (widget.boxShadow != null) return widget.boxShadow;

    final theme = context.acTheme;

    switch (widget.type) {
      case ACButtonType.elevated:
        return theme.elevatedShadow;
      case ACButtonType.flat:
        return theme.subtleShadow;
      case ACButtonType.outlined:
      case ACButtonType.ghost:
        return null;
    }
  }

  double? _getEffectiveHeight(BuildContext context) {
    if (widget.height != null) return widget.height;

    switch (widget.size) {
      case ACButtonSize.small:
        return 32;
      case ACButtonSize.medium:
        return 44;
      case ACButtonSize.large:
        return 56;
    }
  }

  double _getFontSize(BuildContext context) {
    final theme = context.acTheme;

    switch (widget.size) {
      case ACButtonSize.small:
        return theme.fontSizeSmall;
      case ACButtonSize.medium:
        return theme.fontSizeMedium;
      case ACButtonSize.large:
        return theme.fontSizeLarge;
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ACButtonSize.small:
        return 16;
      case ACButtonSize.medium:
        return 20;
      case ACButtonSize.large:
        return 24;
    }
  }

  void _handleTapDown() {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp() {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTap() {
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  void _handleLongPress() {
    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  /// Obtém a cor baseada no estado atual do botão
  Color _getStateColor(Color baseColor, bool isDisabled) {
    if (isDisabled) {
      return baseColor.withValues(alpha: 0.3);
    }

    switch (widget.state) {
      case ACButtonState.idle:
        return _isPressed ? baseColor.withValues(alpha: 0.8) : baseColor;
      case ACButtonState.pressed:
        return baseColor.withValues(alpha: 0.8);
      case ACButtonState.loading:
        return baseColor.withValues(alpha: 0.9);
      case ACButtonState.disabled:
        return baseColor.withValues(alpha: 0.3);
      case ACButtonState.success:
        final theme = context.acTheme;
        return widget.successColor ?? theme.successColor;
      case ACButtonState.error:
        final theme = context.acTheme;
        return widget.errorColor ?? theme.errorColor;
    }
  }

  /// Constrói o child apropriado baseado no estado
  Widget _buildChild(Color textColor) {
    final theme = context.acTheme;
    final isDisabled =
        widget.state == ACButtonState.disabled ||
        (widget.onPressed == null && widget.onLongPress == null);

    switch (widget.state) {
      case ACButtonState.loading:
        return _buildLoadingIndicator(textColor);

      case ACButtonState.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: _getFontSize(context), color: Colors.white),
            const SizedBox(width: 8),
            DefaultTextStyle(
              style: TextStyle(
                color: Colors.white,
                fontSize: _getFontSize(context),
                fontWeight: theme.fontWeightRegular,
              ),
              child: widget.child,
            ),
          ],
        );

      case ACButtonState.error:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: _getFontSize(context), color: Colors.white),
            const SizedBox(width: 8),
            DefaultTextStyle(
              style: TextStyle(
                color: Colors.white,
                fontSize: _getFontSize(context),
                fontWeight: theme.fontWeightRegular,
              ),
              child: widget.child,
            ),
          ],
        );

      default:
        return DefaultTextStyle(
          style: TextStyle(
            color: isDisabled ? textColor.withValues(alpha: 0.3) : textColor,
            fontSize: _getFontSize(context),
            fontWeight: theme.fontWeightRegular,
          ),
          child: widget.child,
        );
    }
  }
}
