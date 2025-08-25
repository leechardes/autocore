import 'package:autocore_app/core/helpers/telemetry_binding.dart';
import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:flutter/material.dart';

class DisplayItemWidget extends StatelessWidget {
  final ApiScreenItem item;
  final TelemetryData? telemetryData;
  final Map<String, bool> relayStates;
  final Map<String, double> sensorValues;

  const DisplayItemWidget({
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
    final isOnline = _isValueFresh();

    return Card(
      elevation: 4,
      color: _getCardColor(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: _getBorderSide(theme),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título com indicador de status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getDisplayIcon(),
                  size: 20,
                  color: _getIconColor(theme, currentValue),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: _getTextColor(theme),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Valor principal
            Text(
              _getDisplayValue(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: _getValueColor(theme, currentValue),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Informação adicional
            if (_getAdditionalInfo().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _getAdditionalInfo(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Barra de progresso (se aplicável)
            if (_shouldShowProgressBar())
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildProgressBar(theme, currentValue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, dynamic currentValue) {
    final percentage = _getProgressPercentage(currentValue);

    return Column(
      children: [
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(theme, currentValue),
          ),
          minHeight: 4,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.minValue?.toStringAsFixed(0) ?? '0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              item.maxValue?.toStringAsFixed(0) ?? '100',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  dynamic _getCurrentValue() {
    if (item.telemetryKey == null) return null;

    final key = item.telemetryKey;

    // Busca valor nos sensores primeiro
    if (sensorValues.containsKey(key)) {
      return sensorValues[key];
    }

    // Verifica estados de relé
    if (relayStates.containsKey(key)) {
      return relayStates[key];
    }

    return null;
  }

  bool _isValueFresh() {
    if (telemetryData == null) return false;

    return TelemetryBinding.isTelemetryFresh(telemetryData, maxAgeSeconds: 30);
  }

  String _getDisplayValue() {
    final currentValue = _getCurrentValue();

    if (currentValue == null) {
      return '--';
    }

    // Se é um valor booleano (relé)
    if (currentValue is bool) {
      return TelemetryBinding.formatRelayState(currentValue);
    }

    // Se é um valor numérico (sensor)
    if (currentValue is double || currentValue is int) {
      return TelemetryBinding.formatSensorValue(
        value: (currentValue as num).toDouble(),
        unit: item.unit,
        decimalPlaces: item.decimalPlaces,
        fallbackText: '--',
      );
    }

    // Fallback para string
    return currentValue.toString();
  }

  String _getAdditionalInfo() {
    final List<String> info = [];

    // Último update
    if (telemetryData?.timestamp != null) {
      final now = DateTime.now();
      final diff = now.difference(telemetryData!.timestamp);

      if (diff.inSeconds < 60) {
        info.add('${diff.inSeconds}s atrás');
      } else if (diff.inMinutes < 60) {
        info.add('${diff.inMinutes}min atrás');
      } else {
        info.add('${diff.inHours}h atrás');
      }
    }

    // Range (se aplicável)
    if (item.minValue != null && item.maxValue != null) {
      final currentValue = _getCurrentValue();
      if (currentValue is num) {
        final percentage = _getProgressPercentage(currentValue);
        if (percentage < 0.2) {
          info.add('Baixo');
        } else if (percentage > 0.8) {
          info.add('Alto');
        }
      }
    }

    return info.join(' • ');
  }

  bool _shouldShowProgressBar() {
    final currentValue = _getCurrentValue();
    return currentValue is num &&
        item.minValue != null &&
        item.maxValue != null;
  }

  double _getProgressPercentage(dynamic value) {
    if (value == null || value is! num) return 0.0;

    final minValue = item.minValue ?? 0.0;
    final maxValue = item.maxValue ?? 100.0;

    return TelemetryBinding.sensorToGaugePercentage(
      value: value.toDouble(),
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  Color _getProgressColor(ThemeData theme, dynamic value) {
    if (value == null || value is! num) return theme.disabledColor;

    // Se tem ranges de cor configurados, usa eles
    if (item.colorRanges != null && item.colorRanges!.isNotEmpty) {
      return TelemetryBinding.getColorForValue(
        value: value.toDouble(),
        colorRanges: item.colorRanges!,
        defaultColor: theme.primaryColor,
      );
    }

    // Cores padrão baseadas em percentual
    final percentage = _getProgressPercentage(value);

    if (percentage >= 0.8) return Colors.red;
    if (percentage >= 0.6) return Colors.orange;
    if (percentage >= 0.4) return Colors.yellow;
    return theme.primaryColor;
  }

  IconData _getDisplayIcon() {
    if (item.icon != null) {
      final icon = _getIconFromString(item.icon!);
      if (icon != null) return icon;
    }

    if (item.telemetryKey != null) {
      // Se é um relé
      if (relayStates.containsKey(item.telemetryKey)) {
        final state = _getCurrentValue() as bool?;
        return TelemetryBinding.getRelayIcon(state);
      }

      // Se é um sensor
      if (sensorValues.containsKey(item.telemetryKey)) {
        return TelemetryBinding.getSensorIcon(item.telemetryKey!);
      }
    }

    return Icons.monitor;
  }

  Color _getIconColor(ThemeData theme, dynamic value) {
    if (value == null) return theme.disabledColor;

    if (value is bool) {
      return value ? theme.primaryColor : theme.disabledColor;
    }

    if (value is num) {
      return _getProgressColor(theme, value);
    }

    return theme.iconTheme.color ?? Colors.grey;
  }

  Color _getValueColor(ThemeData theme, dynamic value) {
    if (value == null) return theme.disabledColor;

    if (value is bool) {
      return value ? theme.primaryColor : theme.disabledColor;
    }

    if (value is num) {
      return _getProgressColor(theme, value);
    }

    return theme.textTheme.headlineSmall?.color ?? Colors.black;
  }

  Color _getCardColor(ThemeData theme) {
    if (item.backgroundColor != null) {
      return _hexToColor(item.backgroundColor!) ?? theme.cardColor;
    }
    return theme.cardColor;
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
    return BorderSide.none;
  }

  IconData? _getIconFromString(String iconName) {
    const iconMap = {
      'monitor': Icons.monitor,
      'display_settings': Icons.display_settings,
      'info': Icons.info,
      'data_usage': Icons.data_usage,
      'analytics': Icons.analytics,
      'dashboard': Icons.dashboard,
      'thermostat': Icons.thermostat,
      'battery_full': Icons.battery_full,
      'water_drop': Icons.water_drop,
      'local_gas_station': Icons.local_gas_station,
      'speed': Icons.speed,
      'sensors': Icons.sensors,
      'memory': Icons.memory,
      'storage': Icons.storage,
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
