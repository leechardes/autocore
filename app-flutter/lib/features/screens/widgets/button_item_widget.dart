// Removido import não usado
import 'package:autocore_app/core/helpers/telemetry_binding.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:flutter/material.dart';

class ButtonItemWidget extends StatefulWidget {
  final ApiScreenItem item;
  final TelemetryData? telemetryData;
  final Map<String, bool> relayStates;
  final Map<String, double> sensorValues;
  final void Function(String, Map<String, dynamic>?)? onPressed;
  final void Function(bool)? onSwitchChanged;
  final bool isSwitchMode;

  const ButtonItemWidget({
    super.key,
    required this.item,
    this.telemetryData,
    this.relayStates = const {},
    this.sensorValues = const {},
    this.onPressed,
    this.onSwitchChanged,
    this.isSwitchMode = false,
  });

  @override
  State<ButtonItemWidget> createState() => _ButtonItemWidgetState();
}

class _ButtonItemWidgetState extends State<ButtonItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isSwitchMode) {
      return _buildSwitchCard(context, theme);
    } else {
      return _buildButtonCard(context, theme);
    }
  }

  Widget _buildButtonCard(BuildContext context, ThemeData theme) {
    final isActive = _getCurrentState();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: 0, // Flat design
            shadowColor: isActive
                ? theme.primaryColor.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.2),
            color: _getCardColor(theme, isActive),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(
                color: Color(0xFF27272A), // Border sutil
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: widget.item.enabled ? _handleButtonPress : null,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: () => _handleTapUp(null),
              borderRadius: BorderRadius.circular(8),
              splashColor: theme.primaryColor.withValues(alpha: 0.2),
              highlightColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Container(
                // Altura fixa para match com React (h-20 = 80px)
                height: 80,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ícone no topo (como React)
                    if (_isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    else
                      Icon(
                        _getItemIcon(),
                        size: 20, // Tamanho moderado
                        color: theme.iconTheme.color,
                      ),
                    const SizedBox(height: 8),
                    // Label embaixo (como React)
                    Text(
                      widget.item.title,
                      style: theme.textTheme.titleSmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchCard(BuildContext context, ThemeData theme) {
    final isActive = _getCurrentState();

    return Card(
      elevation: 0, // Flat design
      shadowColor: isActive
          ? theme.primaryColor.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.2),
      color: _getCardColor(theme, isActive),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFF27272A), // Border sutil
          width: 1,
        ),
      ),
      child: Container(
        height: 80, // Altura fixa para consistência
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          // Layout horizontal para switch (como React)
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ícone + Label (lado esquerdo)
            Expanded(
              child: Row(
                children: [
                  Icon(
                    _getItemIcon(),
                    size: 20, // Ícone menor
                    color: _getIconColor(theme, isActive),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _getTextColor(theme, isActive),
                        fontWeight: FontWeight.w500,
                        fontSize: 14, // text-sm equivalente
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Switch (lado direito)
            Switch(
              value: isActive,
              onChanged: widget.item.enabled ? _handleSwitchChanged : null,
              activeColor: _getActiveColor(theme),
              activeTrackColor: theme.primaryColor.withValues(alpha: 0.5),
              inactiveThumbColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              inactiveTrackColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails? details) {
    _animationController.reverse();
  }

  Future<void> _handleButtonPress() async {
    if (_isLoading || !widget.item.enabled) return;

    setState(() => _isLoading = true);

    try {
      final command = widget.item.command ?? widget.item.action ?? 'toggle';
      final payload = widget.item.payload ?? {};

      widget.onPressed?.call(command, payload);

      // Simula delay para feedback visual
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      // Log error
      debugPrint('Erro ao executar comando do botão: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSwitchChanged(bool value) {
    if (!widget.item.enabled) return;

    widget.onSwitchChanged?.call(value);

    // Executa comando apropriado
    final command = value
        ? (widget.item.switchCommandOn ?? 'on')
        : (widget.item.switchCommandOff ?? 'off');

    final payload = value
        ? (widget.item.switchPayloadOn ?? {'state': true})
        : (widget.item.switchPayloadOff ?? {'state': false});

    widget.onPressed?.call(command, payload);
  }

  bool _getCurrentState() {
    // Se tem telemetryKey, usa o valor da telemetria
    if (widget.item.telemetryKey != null) {
      final key = widget.item.telemetryKey;

      // Verifica estados de relé primeiro
      if (widget.relayStates.containsKey(key)) {
        return widget.relayStates[key] ?? false;
      }

      // Verifica valores de sensor
      if (widget.sensorValues.containsKey(key)) {
        final value = widget.sensorValues[key];
        return value != null && value > 0;
      }
    }

    // Fallback para estado inicial configurado
    return widget.item.initialState;
  }

  // Método removido - não mais usado no novo layout

  IconData _getItemIcon() {
    if (widget.item.icon != null) {
      return _getIconFromString(widget.item.icon!) ?? Icons.touch_app;
    }

    if (widget.item.telemetryKey != null) {
      if (widget.relayStates.containsKey(widget.item.telemetryKey)) {
        return TelemetryBinding.getRelayIcon(_getCurrentState());
      } else if (widget.sensorValues.containsKey(widget.item.telemetryKey)) {
        return TelemetryBinding.getSensorIcon(widget.item.telemetryKey!);
      }
    }

    return widget.isSwitchMode ? Icons.toggle_on : Icons.touch_app;
  }

  Color _getCardColor(ThemeData theme, bool isActive) {
    if (widget.item.backgroundColor != null) {
      return _hexToColor(widget.item.backgroundColor!) ?? theme.cardColor;
    }

    // Usar cor base padrão para match com React
    final baseColor = theme.cardColor;

    if (isActive) {
      // Estado ativo com cor primária mais sutil
      return Color.alphaBlend(
        theme.primaryColor.withValues(alpha: 0.1),
        baseColor,
      );
    }

    return baseColor;
  }

  Color _getIconColor(ThemeData theme, bool isActive) {
    if (widget.item.textColor != null) {
      return _hexToColor(widget.item.textColor!) ?? theme.primaryColor;
    }

    if (isActive) {
      // Cor mais vibrante quando ativo
      return theme.primaryColor;
    }

    // Cor padrão com boa visibilidade
    return theme.iconTheme.color?.withValues(alpha: 0.85) ??
        theme.colorScheme.onSurface.withValues(alpha: 0.7);
  }

  Color? _getTextColor(ThemeData theme, bool isActive) {
    if (widget.item.textColor != null) {
      return _hexToColor(widget.item.textColor!);
    }

    return isActive ? theme.primaryColor : theme.textTheme.titleSmall?.color;
  }

  Color _getActiveColor(ThemeData theme) {
    return theme.primaryColor;
  }

  IconData? _getIconFromString(String iconName) {
    // Mapeamento básico de nomes de ícones
    const iconMap = {
      'lightbulb': Icons.lightbulb,
      'lightbulb_outline': Icons.lightbulb_outline,
      'power': Icons.power,
      'power_settings_new': Icons.power_settings_new,
      'toggle_on': Icons.toggle_on,
      'toggle_off': Icons.toggle_off,
      'flash_on': Icons.flash_on,
      'flash_off': Icons.flash_off,
      'settings': Icons.settings,
      'build': Icons.build,
      'construction': Icons.construction,
      'handyman': Icons.handyman,
      'water_drop': Icons.water_drop,
      'air': Icons.air,
      'ac_unit': Icons.ac_unit,
      'heat_pump': Icons.heat_pump,
    };

    return iconMap[iconName.toLowerCase()];
  }

  Color? _hexToColor(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return null;
    }
  }
}
