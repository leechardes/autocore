import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:flutter/material.dart';

/// Helper para fazer binding de telemetria com widgets
class TelemetryBinding {
  /// Converte valor de sensor para display formatado
  static String formatSensorValue({
    required double? value,
    String? unit,
    int decimalPlaces = 1,
    String? fallbackText,
  }) {
    if (value == null) {
      return fallbackText ?? '--';
    }

    final formattedValue = value.toStringAsFixed(decimalPlaces);
    return unit != null ? '$formattedValue $unit' : formattedValue;
  }

  /// Converte estado de relé para texto legível
  static String formatRelayState(bool? state) {
    if (state == null) return 'Desconhecido';
    return state ? 'Ligado' : 'Desligado';
  }

  /// Obtém cor baseada no valor e ranges definidos
  static Color getColorForValue({
    required double? value,
    required List<Map<String, dynamic>> colorRanges,
    Color defaultColor = Colors.blue,
  }) {
    if (value == null || colorRanges.isEmpty) {
      return defaultColor;
    }

    // Ordena por prioridade (maior prioridade primeiro)
    final sortedRanges = List<Map<String, dynamic>>.from(colorRanges);
    sortedRanges.sort(
      (a, b) => ((b['priority'] as int?) ?? 0).compareTo(
        (a['priority'] as int?) ?? 0,
      ),
    );

    for (final range in sortedRanges) {
      final min = range['min'] as double?;
      final max = range['max'] as double?;
      final colorHex = range['color'] as String?;

      if (min != null && max != null && value >= min && value <= max) {
        return _hexToColor(colorHex) ?? defaultColor;
      }
    }

    return defaultColor;
  }

  /// Obtém ícone baseado no estado do relé
  static IconData getRelayIcon(bool? state) {
    if (state == null) return Icons.help_outline;
    return state ? Icons.power : Icons.power_off;
  }

  /// Obtém ícone baseado no tipo de sensor
  static IconData getSensorIcon(String sensorType) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
      case 'temp':
        return Icons.thermostat;
      case 'battery':
      case 'voltage':
        return Icons.battery_full;
      case 'current':
        return Icons.flash_on;
      case 'pressure':
        return Icons.speed;
      case 'fuel':
        return Icons.local_gas_station;
      case 'oil':
        return Icons.oil_barrel;
      case 'water':
        return Icons.water_drop;
      case 'humidity':
        return Icons.water_damage;
      default:
        return Icons.sensors;
    }
  }

  /// Verifica se telemetria está atualizada
  static bool isTelemetryFresh(
    TelemetryData? telemetry, {
    int maxAgeSeconds = 10,
  }) {
    if (telemetry?.timestamp == null) return false;

    final now = DateTime.now();
    final age = now.difference(telemetry!.timestamp);
    return age.inSeconds <= maxAgeSeconds;
  }

  /// Obtém status da conexão baseado na telemetria
  static String getConnectionStatus(TelemetryData? telemetry) {
    if (telemetry == null) return 'Desconectado';

    if (isTelemetryFresh(telemetry)) {
      return 'Online';
    } else if (isTelemetryFresh(telemetry, maxAgeSeconds: 60)) {
      return 'Instável';
    } else {
      return 'Offline';
    }
  }

  /// Obtém cor do status da conexão
  static Color getConnectionStatusColor(TelemetryData? telemetry) {
    final status = getConnectionStatus(telemetry);

    switch (status) {
      case 'Online':
        return Colors.green;
      case 'Instável':
        return Colors.orange;
      case 'Offline':
      case 'Desconectado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Converte valor de sensor para gauge percentage
  static double sensorToGaugePercentage({
    required double? value,
    required double minValue,
    required double maxValue,
  }) {
    if (value == null) return 0.0;

    final normalizedValue = (value - minValue) / (maxValue - minValue);
    return normalizedValue.clamp(0.0, 1.0);
  }

  /// Obtém texto do nível de sinal
  static String getSignalStrengthText(int? signalStrength) {
    if (signalStrength == null) return 'Desconhecido';

    if (signalStrength >= 80) return 'Excelente';
    if (signalStrength >= 60) return 'Bom';
    if (signalStrength >= 40) return 'Regular';
    if (signalStrength >= 20) return 'Fraco';
    return 'Muito Fraco';
  }

  /// Obtém ícone do nível de sinal
  static IconData getSignalStrengthIcon(int? signalStrength) {
    if (signalStrength == null) return Icons.signal_cellular_off;

    if (signalStrength >= 80) return Icons.signal_cellular_4_bar;
    if (signalStrength >= 60) return Icons.network_cell;
    if (signalStrength >= 40) return Icons.network_cell;
    if (signalStrength >= 20) return Icons.signal_cellular_alt;
    return Icons.signal_cellular_0_bar;
  }

  /// Obtém texto do nível da bateria
  static String getBatteryLevelText(double? batteryLevel) {
    if (batteryLevel == null) return 'Desconhecido';

    if (batteryLevel >= 13.0) return 'Plena';
    if (batteryLevel >= 12.6) return 'Boa';
    if (batteryLevel >= 12.2) return 'Regular';
    if (batteryLevel >= 11.8) return 'Baixa';
    return 'Crítica';
  }

  /// Obtém cor do nível da bateria
  static Color getBatteryLevelColor(double? batteryLevel) {
    if (batteryLevel == null) return Colors.grey;

    if (batteryLevel >= 13.0) return Colors.green;
    if (batteryLevel >= 12.6) return Colors.lightGreen;
    if (batteryLevel >= 12.2) return Colors.orange;
    if (batteryLevel >= 11.8) return Colors.deepOrange;
    return Colors.red;
  }

  /// Obtém ícone do nível da bateria
  static IconData getBatteryIcon(double? batteryLevel) {
    if (batteryLevel == null) return Icons.battery_unknown;

    if (batteryLevel >= 13.0) return Icons.battery_full;
    if (batteryLevel >= 12.6) return Icons.battery_6_bar;
    if (batteryLevel >= 12.2) return Icons.battery_4_bar;
    if (batteryLevel >= 11.8) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  /// Formata tempo de uptime
  static String formatUptime(int? uptimeSeconds) {
    if (uptimeSeconds == null) return 'Desconhecido';

    final duration = Duration(seconds: uptimeSeconds);

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Converte hex string para Color
  static Color? _hexToColor(String? hex) {
    if (hex == null) return null;

    try {
      String cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex'; // Adiciona alpha
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Obtém mapa de bindings de valor para UI
  static Map<String, dynamic> getValueBindings({
    required Map<String, double> sensorValues,
    required Map<String, bool> relayStates,
    required TelemetryData? telemetry,
  }) {
    return {
      // Sensores formatados
      'battery_voltage': formatSensorValue(
        value: sensorValues['battery_voltage'],
        unit: 'V',
      ),
      'battery_current': formatSensorValue(
        value: sensorValues['battery_current'],
        unit: 'A',
      ),
      'temperature_engine': formatSensorValue(
        value: sensorValues['temperature_engine'],
        unit: '°C',
      ),
      'temperature_cabin': formatSensorValue(
        value: sensorValues['temperature_cabin'],
        unit: '°C',
      ),
      'fuel_level': formatSensorValue(
        value: sensorValues['fuel_level'],
        unit: '%',
        decimalPlaces: 0,
      ),

      // Estados de relés formatados
      'light_front': formatRelayState(relayStates['light_front']),
      'light_rear': formatRelayState(relayStates['light_rear']),
      'winch': formatRelayState(relayStates['winch']),
      'compressor': formatRelayState(relayStates['compressor']),

      // Status geral
      'connection_status': getConnectionStatus(telemetry),
      'signal_strength': getSignalStrengthText(telemetry?.signalStrength),
      'battery_level': getBatteryLevelText(telemetry?.batteryLevel),
      'uptime': formatUptime(telemetry?.uptime),

      // Dados brutos para uso em widgets
      'raw_sensors': sensorValues,
      'raw_relays': relayStates,
      'raw_telemetry': telemetry,
    };
  }
}
