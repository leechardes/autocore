// dart:math removido - não necessário para layout vertical simples
import 'package:autocore_app/core/helpers/telemetry_binding.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:flutter/material.dart';

class GaugeItemWidget extends StatelessWidget {
  final ApiScreenItem item;
  final TelemetryData? telemetryData;
  final Map<String, bool> relayStates;
  final Map<String, double> sensorValues;

  const GaugeItemWidget({
    super.key,
    required this.item,
    this.telemetryData,
    this.relayStates = const {},
    this.sensorValues = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = _getCurrentValue();
    // Percentage não é mais usado no novo layout

    return Card(
      elevation: 0, // Flat design
      color: _getCardColor(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFF27272A), // Border sutil
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header: Título + Ícone (como React)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título em maiúsculas com letter spacing (como React)
                Text(
                  item.title.toUpperCase(),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Ícone pequeno e sutil
                Icon(
                  _getGaugeIcon(),
                  size: 16, // Pequeno
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Valor grande com unidade
            Text(
              '${_getDisplayValue(currentValue)} ${item.unit ?? ""}',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }

  double? _getCurrentValue() {
    if (item.telemetryKey == null) return null;

    final key = item.telemetryKey;

    // Busca valor nos sensores
    if (sensorValues.containsKey(key)) {
      final value = sensorValues[key];
      return value;
    }

    // Se é um relé, converte booleano para numérico
    if (relayStates.containsKey(key)) {
      final boolValue = relayStates[key];
      final numValue = boolValue == true ? 1.0 : 0.0;
      return numValue;
    }

    return null;
  }

  // Novo método para display separado (valor sem unidade)
  String _getDisplayValue(double? value) {
    if (value == null) return '--';

    final decimalPlaces = item.decimalPlaces;
    return value.toStringAsFixed(decimalPlaces);
  }

  IconData _getGaugeIcon() {
    if (item.icon != null) {
      final icon = _getIconFromString(item.icon!);
      if (icon != null) return icon;
    }

    if (item.telemetryKey != null) {
      return TelemetryBinding.getSensorIcon(item.telemetryKey!);
    }

    return Icons.speed;
  }

  Color _getCardColor(ThemeData theme) {
    if (item.backgroundColor != null) {
      return _hexToColor(item.backgroundColor!) ?? theme.cardColor;
    }
    // Usar surface color para match com React
    return theme.cardColor;
  }

  IconData? _getIconFromString(String iconName) {
    const iconMap = {
      'speed': Icons.speed,
      'thermostat': Icons.thermostat,
      'battery_full': Icons.battery_full,
      'water_drop': Icons.water_drop,
      'local_gas_station': Icons.local_gas_station,
      'oil_barrel': Icons.oil_barrel,
      'flash_on': Icons.flash_on,
      'sensors': Icons.sensors,
      'gauge': Icons.speed,
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

// CircularGaugePainter removido conforme especificação A32-PHASE1-CRITICAL-FIXES
// Layout vertical simples não requer custom painters
