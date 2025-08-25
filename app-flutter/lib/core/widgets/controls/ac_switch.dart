import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ACSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? subtitle;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final double? width;
  final double? height;
  final bool hapticFeedback;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final bool showLabel;
  final TextStyle? labelStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsets? padding;

  const ACSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.width = 60,
    this.height = 34,
    this.hapticFeedback = true,
    this.activeIcon,
    this.inactiveIcon,
    this.showLabel = true,
    this.labelStyle,
    this.subtitleStyle,
    this.padding,
  });

  @override
  State<ACSwitch> createState() => _ACSwitchState();
}

class _ACSwitchState extends State<ACSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _trackColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(ACSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      final newValue = !widget.value;

      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }

      widget.onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    final isDisabled = widget.onChanged == null;

    // Cores efetivas
    final effectiveActiveColor = widget.activeColor ?? theme.successColor;
    final effectiveInactiveColor = widget.inactiveColor ?? theme.textTertiary;
    final effectiveActiveTrackColor =
        widget.activeTrackColor ?? effectiveActiveColor.withValues(alpha: 0.5);
    final effectiveInactiveTrackColor =
        widget.inactiveTrackColor ??
        effectiveInactiveColor.withValues(alpha: 0.3);

    // Configurar animações de cor
    _colorAnimation = ColorTween(
      begin: effectiveInactiveColor,
      end: effectiveActiveColor,
    ).animate(_animation);

    _trackColorAnimation = ColorTween(
      begin: effectiveInactiveTrackColor,
      end: effectiveActiveTrackColor,
    ).animate(_animation);

    final switchWidget = GestureDetector(
      onTap: isDisabled ? null : _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height! / 2),
              color: _trackColorAnimation.value,
              boxShadow: theme.subtleShadow,
            ),
            child: Stack(
              children: [
                // Track com ícones opcionais
                if (widget.activeIcon != null || widget.inactiveIcon != null)
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.height! * 0.2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.inactiveIcon != null)
                            Opacity(
                              opacity: 1.0 - _animation.value,
                              child: widget.inactiveIcon,
                            ),
                          if (widget.activeIcon != null)
                            Opacity(
                              opacity: _animation.value,
                              child: widget.activeIcon,
                            ),
                        ],
                      ),
                    ),
                  ),

                // Thumb
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left:
                      _animation.value * (widget.width! - widget.height! + 4) +
                      2,
                  top: 2,
                  child: Container(
                    width: widget.height! - 4,
                    height: widget.height! - 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDisabled ? Colors.grey : _colorAnimation.value,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Se não houver label, retornar apenas o switch
    if (widget.label == null && !widget.showLabel) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: switchWidget,
      );
    }

    // Com label
    return Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.label != null && widget.showLabel) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label!,
                        style:
                            widget.labelStyle ??
                            TextStyle(
                              color: isDisabled
                                  ? theme.textTertiary
                                  : theme.textPrimary,
                              fontSize: theme.fontSizeMedium,
                              fontWeight: theme.fontWeightRegular,
                            ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style:
                              widget.subtitleStyle ??
                              TextStyle(
                                color: theme.textTertiary,
                                fontSize: theme.fontSizeSmall,
                                fontWeight: theme.fontWeightLight,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: theme.spacingMd),
              ],
              switchWidget,
            ],
          ),
        )
        .animate(target: widget.value ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 100.ms,
        );
  }
}
