/// Widget para indicador visual de heartbeat
/// Implementado como parte do A41 - TODO Implementation
library;

import 'package:flutter/material.dart';

/// Widget que mostra animação de heartbeat
class HeartbeatIndicator extends StatefulWidget {
  const HeartbeatIndicator({
    super.key,
    required this.isActive,
    this.color,
    this.size = 24.0,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  final bool isActive;
  final Color? color;
  final double size;
  final Duration animationDuration;

  @override
  State<HeartbeatIndicator> createState() => _HeartbeatIndicatorState();
}

class _HeartbeatIndicatorState extends State<HeartbeatIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(HeartbeatIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  void _startAnimation() {
    if (_controller.isAnimating) return;
    _controller.repeat(reverse: true);
  }

  void _stopAnimation() {
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = widget.color ?? 
        (widget.isActive ? Colors.red : theme.disabledColor);

    if (!widget.isActive) {
      // Estado inativo - ícone estático
      return Icon(
        Icons.favorite_border,
        color: effectiveColor,
        size: widget.size,
      );
    }

    // Estado ativo - ícone animado
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Icon(
              Icons.favorite,
              color: effectiveColor,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

/// Widget para indicador de status de conexão com heartbeat
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({
    super.key,
    required this.isConnected,
    required this.lastHeartbeat,
    this.size = 20.0,
  });

  final bool isConnected;
  final DateTime? lastHeartbeat;
  final double size;

  bool get _isHeartbeatActive {
    if (!isConnected || lastHeartbeat == null) return false;
    
    // Considera heartbeat ativo se foi nos últimos 60 segundos
    final now = DateTime.now();
    final diff = now.difference(lastHeartbeat!);
    return diff.inSeconds < 60;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicador de conexão
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        
        // Heartbeat indicator
        HeartbeatIndicator(
          isActive: _isHeartbeatActive,
          size: size,
        ),
        
        const SizedBox(width: 8),
        
        // Texto do status
        Text(
          _getStatusText(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isConnected ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    if (!isConnected) return 'Desconectado';
    
    if (lastHeartbeat == null) return 'Conectado';
    
    final now = DateTime.now();
    final diff = now.difference(lastHeartbeat!);
    
    if (diff.inSeconds < 10) return 'Online';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s atrás';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    
    return 'Sem heartbeat';
  }
}