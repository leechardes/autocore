import 'package:autocore_app/core/models/api/api_screen_item.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:autocore_app/features/screens/widgets/button_item_widget.dart';
import 'package:autocore_app/features/screens/widgets/display_item_widget.dart';
import 'package:autocore_app/features/screens/widgets/gauge_item_widget.dart';
import 'package:autocore_app/features/screens/widgets/switch_item_widget.dart';
import 'package:flutter/material.dart';

class ScreenItemFactory {
  static Widget buildItem({
    required ApiScreenItem item,
    TelemetryData? telemetryData,
    Map<String, bool> relayStates = const {},
    Map<String, double> sensorValues = const {},
    void Function(String, Map<String, dynamic>?)? onButtonPressed,
    void Function(bool)? onSwitchChanged,
  }) {
    switch (item.type.toLowerCase()) {
      case 'button':
        return ButtonItemWidget(
          item: item,
          telemetryData: telemetryData,
          relayStates: relayStates,
          sensorValues: sensorValues,
          onPressed: onButtonPressed,
        );

      case 'gauge':
        return GaugeItemWidget(
          item: item,
          telemetryData: telemetryData,
          relayStates: relayStates,
          sensorValues: sensorValues,
        );

      case 'display':
        return DisplayItemWidget(
          item: item,
          telemetryData: telemetryData,
          relayStates: relayStates,
          sensorValues: sensorValues,
        );

      case 'switch':
        return SwitchItemWidget(
          item: item,
          telemetryData: telemetryData,
          relayStates: relayStates,
          sensorValues: sensorValues,
          onChanged: onSwitchChanged,
        );

      default:
        return _buildUnsupportedItem(item);
    }
  }

  static Widget _buildUnsupportedItem(ApiScreenItem item) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_outlined,
              color: Colors.orange,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Tipo não suportado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.type,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
