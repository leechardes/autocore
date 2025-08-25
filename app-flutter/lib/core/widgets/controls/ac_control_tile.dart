import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:autocore_app/core/widgets/base/ac_button.dart';
import 'package:autocore_app/core/widgets/base/ac_container.dart';
import 'package:autocore_app/core/widgets/controls/ac_switch.dart';
import 'package:autocore_app/core/widgets/indicators/ac_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ACControlType {
  toggle, // Simple on/off
  dimmer, // With brightness control
  momentary, // Press and hold
  timer, // With timer control
  state, // Multiple states
}

enum ACControlSize { compact, normal, expanded }

class ACControlTile extends StatefulWidget {
  final String id;
  final String label;
  final String? subtitle;
  final IconData icon;
  final ACControlType type;
  final ACControlSize size;
  final bool value;
  final double? dimmerValue;
  final int? timerSeconds;
  final ValueChanged<bool>? onToggle;
  final ValueChanged<double>? onDimmerChanged;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isOnline;
  final bool isLoading;
  final bool showStatus;
  final bool confirmAction;
  final String? confirmMessage;
  final Color? activeColor;
  final Color? inactiveColor;
  final Widget? trailing;
  final bool hapticFeedback;

  const ACControlTile({
    super.key,
    required this.id,
    required this.label,
    this.subtitle,
    required this.icon,
    this.type = ACControlType.toggle,
    this.size = ACControlSize.normal,
    this.value = false,
    this.dimmerValue,
    this.timerSeconds,
    this.onToggle,
    this.onDimmerChanged,
    this.onPressed,
    this.onLongPress,
    this.isOnline = true,
    this.isLoading = false,
    this.showStatus = true,
    this.confirmAction = false,
    this.confirmMessage,
    this.activeColor,
    this.inactiveColor,
    this.trailing,
    this.hapticFeedback = true,
  });

  @override
  State<ACControlTile> createState() => _ACControlTileState();
}

class _ACControlTileState extends State<ACControlTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;
  double _currentDimmerValue = 0.0;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _currentDimmerValue = widget.dimmerValue ?? (widget.value ? 100.0 : 0.0);
    _remainingSeconds = widget.timerSeconds ?? 0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ACContainer(
          type: _isPressed
              ? ACContainerType.depressed
              : widget.value
              ? ACContainerType.elevated
              : ACContainerType.surface,
          onTap: _handleTap,
          onLongPress:
              widget.onLongPress ??
              (widget.type == ACControlType.momentary
                  ? _handleLongPress
                  : null),
          padding: _getPadding(context),
          animated: true,
          child: Opacity(
            opacity: widget.isOnline ? 1.0 : 0.5,
            child: _buildContent(context),
          ),
        )
        .animate(target: widget.value ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(0.98, 0.98),
          duration: 100.ms,
        );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.size) {
      case ACControlSize.compact:
        return _buildCompactLayout(context);
      case ACControlSize.normal:
        return _buildNormalLayout(context);
      case ACControlSize.expanded:
        return _buildExpandedLayout(context);
    }
  }

  Widget _buildCompactLayout(BuildContext context) {
    final theme = context.acTheme;
    final effectiveColor = widget.value
        ? (widget.activeColor ?? theme.primaryColor)
        : (widget.inactiveColor ?? theme.textTertiary);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.icon,
          color: effectiveColor,
          size: 20,
        ), // 20px para buttons - especificação A33-PHASE2-IMPORTANT-FIXES
        SizedBox(height: theme.spacingXs),
        Text(
          widget.label,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: theme.fontSizeSmall,
            fontWeight: widget.value
                ? theme.fontWeightBold
                : theme.fontWeightRegular,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.showStatus) ...[
          SizedBox(height: theme.spacingXs),
          ACStatusIndicator(
            status: widget.isOnline
                ? (widget.value ? ACStatusType.active : ACStatusType.inactive)
                : ACStatusType.offline,
            size: ACIndicatorSize.small,
            showLabel: false,
          ),
        ],
      ],
    );
  }

  Widget _buildNormalLayout(BuildContext context) {
    final theme = context.acTheme;
    final effectiveColor = widget.value
        ? (widget.activeColor ?? theme.primaryColor)
        : (widget.inactiveColor ?? theme.textTertiary);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(theme.spacingSm),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(theme.borderRadiusSmall),
          ),
          child: Icon(
            widget.icon,
            color: effectiveColor,
            size: 20,
          ), // 20px para buttons - especificação A33-PHASE2-IMPORTANT-FIXES
        ),
        SizedBox(width: theme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: theme.fontSizeMedium,
                        fontWeight: theme.fontWeightRegular,
                      ),
                    ),
                  ),
                  if (widget.showStatus && !widget.isLoading)
                    ACStatusIndicator(
                      status: widget.isOnline
                          ? ACStatusType.online
                          : ACStatusType.offline,
                      size: ACIndicatorSize.small,
                      showLabel: false,
                    ),
                ],
              ),
              if (widget.subtitle != null) ...[
                SizedBox(height: theme.spacingXs),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: theme.fontSizeSmall,
                  ),
                ),
              ],
              if (widget.type == ACControlType.timer &&
                  _remainingSeconds > 0) ...[
                SizedBox(height: theme.spacingXs),
                Text(
                  'Timer: ${_formatTime(_remainingSeconds)}',
                  style: TextStyle(
                    color: theme.warningColor,
                    fontSize: theme.fontSizeSmall,
                    fontWeight: theme.fontWeightBold,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.isLoading)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (widget.trailing != null)
          widget.trailing!
        else
          _buildControl(context),
      ],
    );
  }

  Widget _buildExpandedLayout(BuildContext context) {
    final theme = context.acTheme;
    final effectiveColor = widget.value
        ? (widget.activeColor ?? theme.primaryColor)
        : (widget.inactiveColor ?? theme.textTertiary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(theme.spacingMd),
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(theme.borderRadiusMedium),
              ),
              child: Icon(
                widget.icon,
                color: effectiveColor,
                size: 20,
              ), // 20px para buttons - especificação A33-PHASE2-IMPORTANT-FIXES
            ),
            SizedBox(width: theme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: theme.fontSizeLarge,
                      fontWeight: theme.fontWeightBold,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: theme.spacingXs),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: theme.fontSizeMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.showStatus)
              ACStatusIndicator(
                status: widget.isOnline
                    ? (widget.value
                          ? ACStatusType.active
                          : ACStatusType.inactive)
                    : ACStatusType.offline,
                size: ACIndicatorSize.medium,
                showLabel: true,
              ),
          ],
        ),
        if (widget.type == ACControlType.dimmer) ...[
          SizedBox(height: theme.spacingMd),
          _buildDimmerControl(context),
        ],
        SizedBox(height: theme.spacingMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.type == ACControlType.timer) _buildTimerControl(context),
            if (widget.type != ACControlType.dimmer) _buildControl(context),
          ],
        ),
      ],
    );
  }

  Widget _buildControl(BuildContext context) {
    switch (widget.type) {
      case ACControlType.toggle:
      case ACControlType.dimmer:
        return ACSwitch(
          value: widget.value,
          onChanged: widget.onToggle,
          showLabel: false,
        );
      case ACControlType.momentary:
        return ACButton(
          onPressed: widget.onPressed,
          onLongPress: widget.onLongPress,
          type: ACButtonType.elevated,
          size: ACButtonSize.small,
          child: const Icon(Icons.touch_app, size: 20),
        );
      case ACControlType.timer:
        return ACSwitch(
          value: widget.value,
          onChanged: widget.onToggle,
          showLabel: false,
        );
      case ACControlType.state:
        return ACButton(
          onPressed: widget.onPressed,
          type: ACButtonType.outlined,
          size: ACButtonSize.small,
          child: Text(widget.value ? 'ON' : 'OFF'),
        );
    }
  }

  Widget _buildDimmerControl(BuildContext context) {
    final theme = context.acTheme;

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.brightness_low, color: theme.textTertiary, size: 20),
            Expanded(
              child: Slider(
                value: _currentDimmerValue,
                min: 0,
                max: 100,
                activeColor: widget.activeColor ?? theme.primaryColor,
                inactiveColor: theme.surfaceColor,
                onChanged: widget.value
                    ? (value) {
                        setState(() {
                          _currentDimmerValue = value;
                        });
                        widget.onDimmerChanged?.call(value);
                      }
                    : null,
              ),
            ),
            Icon(Icons.brightness_high, color: theme.textPrimary, size: 20),
            SizedBox(width: theme.spacingSm),
            SizedBox(
              width: 40,
              child: Text(
                '${_currentDimmerValue.toInt()}%',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: theme.fontSizeSmall,
                  fontWeight: theme.fontWeightBold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerControl(BuildContext context) {
    final theme = context.acTheme;

    return Row(
      children: [
        Icon(Icons.timer, color: theme.textSecondary, size: 20),
        SizedBox(width: theme.spacingSm),
        Text(
          _formatTime(_remainingSeconds),
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: theme.fontSizeMedium,
            fontWeight: theme.fontWeightBold,
          ),
        ),
      ],
    );
  }

  EdgeInsets _getPadding(BuildContext context) {
    final theme = context.acTheme;

    switch (widget.size) {
      case ACControlSize.compact:
        return EdgeInsets.all(theme.spacingSm);
      case ACControlSize.normal:
        return EdgeInsets.all(theme.spacingMd);
      case ACControlSize.expanded:
        return EdgeInsets.all(theme.spacingLg);
    }
  }

  Future<void> _handleTap() async {
    if (!widget.isOnline || widget.isLoading) return;

    if (widget.confirmAction) {
      final confirmed = await _showConfirmDialog();
      if (!confirmed) return;
    }

    if (widget.hapticFeedback) {
      await HapticFeedback.lightImpact();
    }

    switch (widget.type) {
      case ACControlType.toggle:
      case ACControlType.dimmer:
      case ACControlType.timer:
        widget.onToggle?.call(!widget.value);
        break;
      case ACControlType.momentary:
      case ACControlType.state:
        widget.onPressed?.call();
        break;
    }
  }

  void _handleLongPress() {
    if (!widget.isOnline || widget.isLoading) return;

    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _isPressed = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = context.acTheme;
        return AlertDialog(
          backgroundColor: theme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.borderRadiusMedium),
          ),
          title: Text(
            'Confirmar Ação',
            style: TextStyle(color: theme.textPrimary),
          ),
          content: Text(
            widget.confirmMessage ?? 'Deseja executar esta ação?',
            style: TextStyle(color: theme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: theme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Confirmar',
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
