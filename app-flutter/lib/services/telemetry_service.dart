import 'dart:convert';

import 'package:autocore_app/core/constants/mqtt_qos.dart';
import 'package:autocore_app/core/models/safety_event.dart';
import 'package:autocore_app/core/models/telemetry_state.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/infrastructure/services/mqtt_service.dart';

class TelemetryService {
  final MqttService _mqttService;

  TelemetryService(this._mqttService);

  Stream<TelemetryState> subscribeToDeviceState(String deviceUuid) {
    return _mqttService
        .subscribe(
          'autocore/telemetry/$deviceUuid/state',
          qos: MqttQosLevels.telemetry,
        )
        .map((payload) {
          try {
            return TelemetryState.fromJson(
              jsonDecode(payload) as Map<String, dynamic>,
            );
          } catch (e) {
            AppLogger.error('Failed to parse telemetry state: $e');
            rethrow;
          }
        });
  }

  Stream<SafetyEvent> subscribeToSafetyEvents(String deviceUuid) {
    return _mqttService
        .subscribe(
          'autocore/telemetry/$deviceUuid/safety',
          qos: MqttQosLevels.events,
        )
        .map((payload) {
          try {
            return SafetyEvent.fromJson(
              jsonDecode(payload) as Map<String, dynamic>,
            );
          } catch (e) {
            AppLogger.error('Failed to parse safety event: $e');
            rethrow;
          }
        });
  }

  void listenForSafetyShutoffs() {
    subscribeToSafetyEvents('+').listen((event) {
      if (event.reason == 'heartbeat_timeout') {
        AppLogger.warning(
          'Safety shutoff on channel ${event.channel}: ${event.reason}',
        );

        // Notificar UI
        _showSafetyNotification(event);
      }
    });
  }

  void _showSafetyNotification(SafetyEvent event) {
    // TODO: Implementar notificação visual
    AppLogger.info(
      'Safety notification: ${event.reason} on channel ${event.channel}',
    );
  }
}
