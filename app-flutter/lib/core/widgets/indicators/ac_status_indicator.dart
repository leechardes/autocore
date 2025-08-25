import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ACStatusType {
  online,
  offline,
  connected,
  disconnected,
  active,
  inactive,
  warning,
  error,
  success,
  info,
  custom,
}

enum ACIndicatorSize { small, medium, large }

enum ACIndicatorShape { circle, square, rounded }

class ACStatusIndicator extends StatelessWidget {
  final ACStatusType status;
  final ACIndicatorSize size;
  final ACIndicatorShape shape;
  final String? label;
  final bool showLabel;
  final bool pulse;
  final bool glow;
  final Color? color;
  final Color? backgroundColor;
  final IconData? icon;
  final Duration? pulseDuration;
  final TextStyle? labelStyle;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const ACStatusIndicator({
    super.key,
    required this.status,
    this.size = ACIndicatorSize.medium,
    this.shape = ACIndicatorShape.circle,
    this.label,
    this.showLabel = true,
    this.pulse = true,
    this.glow = false,
    this.color,
    this.backgroundColor,
    this.icon,
    this.pulseDuration,
    this.labelStyle,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    final effectiveColor = _getEffectiveColor(context);
    final effectiveSize = _getEffectiveSize();
    final effectiveIcon = _getEffectiveIcon();

    Widget indicator = Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: effectiveColor,
        shape: shape == ACIndicatorShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: shape == ACIndicatorShape.rounded
            ? BorderRadius.circular(effectiveSize * 0.2)
            : shape == ACIndicatorShape.square
            ? BorderRadius.zero
            : null,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: 0.5),
                  blurRadius: effectiveSize * 0.3,
                  spreadRadius: effectiveSize * 0.1,
                ),
              ]
            : null,
      ),
      child: effectiveIcon != null
          ? Icon(effectiveIcon, color: Colors.white, size: effectiveSize * 0.6)
          : null,
    );

    // Add pulse animation if enabled
    if (pulse && _shouldPulse()) {
      indicator = Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring
          Container(
                width: effectiveSize,
                height: effectiveSize,
                decoration: BoxDecoration(
                  color: effectiveColor,
                  shape: shape == ACIndicatorShape.circle
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: shape == ACIndicatorShape.rounded
                      ? BorderRadius.circular(effectiveSize * 0.2)
                      : shape == ACIndicatorShape.square
                      ? BorderRadius.zero
                      : null,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.5, 1.5),
                duration: pulseDuration ?? 1500.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(
                duration: pulseDuration ?? 1500.ms,
                curve: Curves.easeOut,
              ),
          // Main indicator
          indicator,
        ],
      );
    }

    // Add glow animation
    if (glow) {
      indicator = indicator
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .boxShadow(
            begin: BoxShadow(
              color: effectiveColor.withValues(alpha: 0.3),
              blurRadius: effectiveSize * 0.2,
              spreadRadius: 0,
            ),
            end: BoxShadow(
              color: effectiveColor.withValues(alpha: 0.6),
              blurRadius: effectiveSize * 0.4,
              spreadRadius: effectiveSize * 0.1,
            ),
            duration: 1000.ms,
          );
    }

    // Build final widget with optional label
    Widget result = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          if (showLabel &&
              (label != null || status != ACStatusType.custom)) ...[
            SizedBox(width: theme.spacingSm),
            Text(
              label ?? _getDefaultLabel(),
              style:
                  labelStyle ??
                  TextStyle(
                    color: theme.textPrimary,
                    fontSize: _getLabelFontSize(context),
                    fontWeight: theme.fontWeightRegular,
                  ),
            ),
          ],
        ],
      ),
    );

    // Add tap handler if provided
    if (onTap != null) {
      result = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.borderRadiusSmall),
        child: result,
      );
    }

    return result;
  }

  Color _getEffectiveColor(BuildContext context) {
    if (color != null) return color!;

    final theme = context.acTheme;

    switch (status) {
      case ACStatusType.online:
      case ACStatusType.connected:
      case ACStatusType.active:
      case ACStatusType.success:
        return theme.successColor;
      case ACStatusType.offline:
      case ACStatusType.disconnected:
      case ACStatusType.inactive:
        return theme.textTertiary;
      case ACStatusType.warning:
        return theme.warningColor;
      case ACStatusType.error:
        return theme.errorColor;
      case ACStatusType.info:
        return theme.infoColor;
      case ACStatusType.custom:
        return theme.primaryColor;
    }
  }

  double _getEffectiveSize() {
    switch (size) {
      case ACIndicatorSize.small:
        return 8;
      case ACIndicatorSize.medium:
        return 12;
      case ACIndicatorSize.large:
        return 16;
    }
  }

  double _getLabelFontSize(BuildContext context) {
    final theme = context.acTheme;

    switch (size) {
      case ACIndicatorSize.small:
        return theme.fontSizeSmall;
      case ACIndicatorSize.medium:
        return theme.fontSizeMedium;
      case ACIndicatorSize.large:
        return theme.fontSizeLarge;
    }
  }

  IconData? _getEffectiveIcon() {
    if (icon != null) return icon;

    switch (status) {
      case ACStatusType.online:
      case ACStatusType.connected:
        return Icons.check_circle;
      case ACStatusType.offline:
      case ACStatusType.disconnected:
        return Icons.cancel;
      case ACStatusType.active:
        return Icons.play_circle_filled;
      case ACStatusType.inactive:
        return Icons.pause_circle_filled;
      case ACStatusType.warning:
        return Icons.warning;
      case ACStatusType.error:
        return Icons.error;
      case ACStatusType.success:
        return Icons.check_circle;
      case ACStatusType.info:
        return Icons.info;
      case ACStatusType.custom:
        return null;
    }
  }

  String _getDefaultLabel() {
    switch (status) {
      case ACStatusType.online:
        return 'Online';
      case ACStatusType.offline:
        return 'Offline';
      case ACStatusType.connected:
        return 'Conectado';
      case ACStatusType.disconnected:
        return 'Desconectado';
      case ACStatusType.active:
        return 'Ativo';
      case ACStatusType.inactive:
        return 'Inativo';
      case ACStatusType.warning:
        return 'Atenção';
      case ACStatusType.error:
        return 'Erro';
      case ACStatusType.success:
        return 'Sucesso';
      case ACStatusType.info:
        return 'Info';
      case ACStatusType.custom:
        return '';
    }
  }

  bool _shouldPulse() {
    switch (status) {
      case ACStatusType.online:
      case ACStatusType.connected:
      case ACStatusType.active:
      case ACStatusType.warning:
        return true;
      default:
        return false;
    }
  }

  // Factory constructors for common use cases

  factory ACStatusIndicator.connection({
    required bool isConnected,
    ACIndicatorSize size = ACIndicatorSize.medium,
    bool showLabel = true,
    String? customLabel,
  }) {
    return ACStatusIndicator(
      status: isConnected ? ACStatusType.connected : ACStatusType.disconnected,
      size: size,
      showLabel: showLabel,
      label: customLabel,
      pulse: isConnected,
    );
  }

  factory ACStatusIndicator.device({
    required bool isOnline,
    ACIndicatorSize size = ACIndicatorSize.small,
    bool showLabel = false,
  }) {
    return ACStatusIndicator(
      status: isOnline ? ACStatusType.online : ACStatusType.offline,
      size: size,
      showLabel: showLabel,
      pulse: isOnline,
      glow: isOnline,
    );
  }

  factory ACStatusIndicator.loading({
    ACIndicatorSize size = ACIndicatorSize.medium,
    Color? color,
    String? label,
  }) {
    return ACStatusIndicator(
      status: ACStatusType.custom,
      size: size,
      color: color,
      label: label ?? 'Carregando...',
      showLabel: true,
      pulse: true,
    );
  }

  factory ACStatusIndicator.error({
    String? message,
    ACIndicatorSize size = ACIndicatorSize.medium,
    VoidCallback? onTap,
  }) {
    return ACStatusIndicator(
      status: ACStatusType.error,
      size: size,
      label: message ?? 'Erro',
      showLabel: true,
      pulse: false,
      glow: true,
      onTap: onTap,
    );
  }

  factory ACStatusIndicator.success({
    String? message,
    ACIndicatorSize size = ACIndicatorSize.medium,
  }) {
    return ACStatusIndicator(
      status: ACStatusType.success,
      size: size,
      label: message ?? 'Sucesso',
      showLabel: true,
      pulse: false,
      glow: false,
    );
  }
}
