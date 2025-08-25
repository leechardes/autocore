import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/infrastructure/services/heartbeat_service.dart';
import 'package:autocore_app/infrastructure/services/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Botão momentâneo com heartbeat para segurança
/// Usado para buzina, guincho, partida, etc.
class MomentaryButton extends StatefulWidget {
  final String deviceUuid;
  final int channel;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;
  final bool enabled;

  const MomentaryButton({
    super.key,
    required this.deviceUuid,
    required this.channel,
    required this.label,
    required this.icon,
    this.onPressed,
    this.onReleased,
    this.enabled = true,
  });

  @override
  State<MomentaryButton> createState() => _MomentaryButtonState();
}

class _MomentaryButtonState extends State<MomentaryButton> {
  bool _isPressed = false;

  @override
  void dispose() {
    // Garantir que o heartbeat seja parado ao destruir o widget
    if (_isPressed) {
      HeartbeatService.instance.stopMomentary(
        widget.deviceUuid,
        widget.channel,
      );
    }
    super.dispose();
  }

  void _startMomentary() {
    if (!widget.enabled || _isPressed) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Callback
    widget.onPressed?.call();

    AppLogger.info(
      'Iniciando botão momentâneo: ${widget.label} (canal ${widget.channel})',
    );

    // Usar HeartbeatService central para segurança
    HeartbeatService.instance
        .startMomentary(
          widget.deviceUuid,
          widget.channel,
          channelName: widget.label,
        )
        .then((success) {
          if (success && mounted) {
            setState(() {
              _isPressed = true;
            });
          } else {
            AppLogger.error('Falha ao iniciar heartbeat para ${widget.label}');
          }
        });
  }

  void _stopMomentary() {
    if (!_isPressed) return;

    setState(() {
      _isPressed = false;
    });

    // Callback
    widget.onReleased?.call();

    AppLogger.info('Parando botão momentâneo: ${widget.label}');

    // Usar HeartbeatService central para parar
    HeartbeatService.instance.stopMomentary(widget.deviceUuid, widget.channel);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.enabled && MqttService.instance.isConnected;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _startMomentary() : null,
      onTapUp: isEnabled ? (_) => _stopMomentary() : null,
      onTapCancel: isEnabled ? _stopMomentary : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isPressed
              ? theme.colorScheme.primary
              : isEnabled
              ? theme.colorScheme.surface
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 2,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 32,
              color: _isPressed
                  ? theme.colorScheme.onPrimary
                  : isEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: _isPressed
                    ? theme.colorScheme.onPrimary
                    : isEnabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!MqttService.instance.isConnected)
              Text(
                'Offline',
                style: TextStyle(fontSize: 10, color: theme.colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}
