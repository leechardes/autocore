import 'package:autocore_app/core/helpers/telemetry_binding.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:flutter/material.dart';

/// Widget Switch dedicado para match exato com React
/// Baseado no componente Switch do React com layout horizontal
class SwitchItemWidget extends StatelessWidget {
  final ApiScreenItem item;
  final TelemetryData? telemetryData;
  final Map<String, bool> relayStates;
  final Map<String, double> sensorValues;
  final void Function(bool)? onChanged;

  const SwitchItemWidget({
    super.key,
    required this.item,
    this.telemetryData,
    this.relayStates = const {},
    this.sensorValues = const {},
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _getCurrentState();

    return Card(
      elevation: 2, // Elevação sutil para match com React
      color: _getCardColor(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: _getBorderSide(theme),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Icon + Label (como React)
            Expanded(
              child: Row(
                children: [
                  Icon(
                    _getItemIcon(),
                    size: 20, // h-5 w-5 equivalente
                    color: _getIconColor(theme, isActive),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _getTextColor(theme),
                        fontWeight: FontWeight.w500,
                        fontSize: 14, // text-sm equivalente
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Right side: Switch (como React)
            Switch(
              value: isActive,
              onChanged: item.enabled ? onChanged : null,
              activeColor: theme.primaryColor,
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

  bool _getCurrentState() {
    // Se tem telemetryKey, usa o valor da telemetria
    if (item.telemetryKey != null) {
      final key = item.telemetryKey;

      // Verifica estados de relé primeiro
      if (relayStates.containsKey(key)) {
        return relayStates[key] ?? false;
      }

      // Verifica valores de sensor
      if (sensorValues.containsKey(key)) {
        final value = sensorValues[key];
        return value != null && value > 0;
      }
    }

    // Fallback para estado inicial configurado
    return item.initialState;
  }

  IconData _getItemIcon() {
    if (item.icon != null) {
      return _getIconFromString(item.icon!) ?? Icons.toggle_on;
    }

    if (item.telemetryKey != null) {
      if (relayStates.containsKey(item.telemetryKey)) {
        return TelemetryBinding.getRelayIcon(_getCurrentState());
      } else if (sensorValues.containsKey(item.telemetryKey)) {
        return TelemetryBinding.getSensorIcon(item.telemetryKey!);
      }
    }

    return Icons.toggle_on;
  }

  Color _getCardColor(ThemeData theme) {
    if (item.backgroundColor != null) {
      return _hexToColor(item.backgroundColor!) ?? theme.cardColor;
    }
    return theme.cardColor;
  }

  Color _getIconColor(ThemeData theme, bool isActive) {
    if (item.textColor != null) {
      return _hexToColor(item.textColor!) ??
          theme.iconTheme.color ??
          Colors.grey;
    }

    return isActive
        ? theme.primaryColor
        : theme.iconTheme.color?.withValues(alpha: 0.7) ?? Colors.grey;
  }

  Color? _getTextColor(ThemeData theme) {
    if (item.textColor != null) {
      return _hexToColor(item.textColor!);
    }
    return theme.textTheme.titleSmall?.color;
  }

  BorderSide _getBorderSide(ThemeData theme) {
    if (item.borderColor != null) {
      final color = _hexToColor(item.borderColor!);
      if (color != null) {
        return BorderSide(color: color, width: 1);
      }
    }
    // Borda sutil para match com React cards
    return BorderSide(
      color: theme.dividerColor.withValues(alpha: 0.12),
      width: 1,
    );
  }

  IconData? _getIconFromString(String iconName) {
    // Mapeamento básico de nomes de ícones
    const iconMap = {
      'toggle_on': Icons.toggle_on,
      'toggle_off': Icons.toggle_off,
      'lightbulb': Icons.lightbulb,
      'power': Icons.power,
      'flash_on': Icons.flash_on,
      'settings': Icons.settings,
      'build': Icons.build,
      'water_drop': Icons.water_drop,
      'air': Icons.air,
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
