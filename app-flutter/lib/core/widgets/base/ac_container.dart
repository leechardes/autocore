import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

enum ACContainerType { surface, elevated, depressed, flat, outlined }

class ACContainer extends StatelessWidget {
  final Widget child;
  final ACContainerType type;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Alignment? alignment;
  final bool animated;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool rippleEffect;

  const ACContainer({
    super.key,
    required this.child,
    this.type = ACContainerType.surface,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.alignment,
    this.animated = false,
    this.animationDuration,
    this.animationCurve,
    this.onTap,
    this.onLongPress,
    this.rippleEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;

    final effectiveColor = _getEffectiveColor(context);
    final effectiveBorderRadius = _getEffectiveBorderRadius(context);
    final effectiveBoxShadow = _getEffectiveBoxShadow(context);
    final effectivePadding = padding ?? EdgeInsets.all(theme.spacingMd);
    final effectiveBorder = _getEffectiveBorder(context);

    final decoration = BoxDecoration(
      color: gradient == null ? effectiveColor : null,
      gradient: gradient,
      borderRadius: effectiveBorderRadius,
      border: effectiveBorder,
      boxShadow: effectiveBoxShadow,
    );

    Widget container = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      margin: margin,
      alignment: alignment,
      decoration: decoration,
      child: child,
    );

    // Adicionar ripple effect se houver onTap
    if (onTap != null || onLongPress != null) {
      container = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: effectiveBorderRadius,
          splashColor: rippleEffect
              ? theme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          highlightColor: rippleEffect
              ? theme.primaryColor.withValues(alpha: 0.05)
              : Colors.transparent,
          child: container,
        ),
      );
    }

    // Adicionar animação se solicitado
    if (animated) {
      return AnimatedContainer(
        duration: animationDuration ?? theme.animationNormal,
        curve: animationCurve ?? theme.animationCurve,
        width: width,
        height: height,
        padding: effectivePadding,
        margin: margin,
        alignment: alignment,
        decoration: decoration,
        child: child,
      );
    }

    return container;
  }

  Color _getEffectiveColor(BuildContext context) {
    if (color != null) return color!;

    final theme = context.acTheme;

    switch (type) {
      case ACContainerType.surface:
        return theme.surfaceColor;
      case ACContainerType.elevated:
      case ACContainerType.depressed:
        return theme.surfaceColor;
      case ACContainerType.flat:
        return theme.backgroundColor;
      case ACContainerType.outlined:
        return Colors.transparent;
    }
  }

  BorderRadius _getEffectiveBorderRadius(BuildContext context) {
    if (borderRadius != null) return borderRadius!;

    final theme = context.acTheme;
    return BorderRadius.circular(theme.borderRadiusMedium);
  }

  List<BoxShadow>? _getEffectiveBoxShadow(BuildContext context) {
    if (boxShadow != null) return boxShadow;

    final theme = context.acTheme;

    switch (type) {
      case ACContainerType.surface:
        return theme.subtleShadow;
      case ACContainerType.elevated:
        return theme.elevatedShadow;
      case ACContainerType.depressed:
        return theme.depressedShadow;
      case ACContainerType.flat:
      case ACContainerType.outlined:
        return null;
    }
  }

  Border? _getEffectiveBorder(BuildContext context) {
    if (border != null) return border;

    if (type == ACContainerType.outlined) {
      final theme = context.acTheme;
      return Border.all(
        color: theme.primaryColor.withValues(alpha: 0.3),
        width: 1,
      );
    }

    return null;
  }

  // Factory constructors para casos comuns
  factory ACContainer.card({
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    VoidCallback? onTap,
  }) {
    return ACContainer(
      type: ACContainerType.elevated,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  factory ACContainer.neumorphic({
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool isPressed = false,
  }) {
    return ACContainer(
      type: isPressed ? ACContainerType.depressed : ACContainerType.elevated,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  factory ACContainer.gradient({
    required Widget child,
    required List<Color> colors,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return ACContainer(
      gradient: LinearGradient(colors: colors, begin: begin, end: end),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}
