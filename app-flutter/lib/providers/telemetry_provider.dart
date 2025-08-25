import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:autocore_app/infrastructure/services/telemetry_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para o TelemetryService
final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return TelemetryService.instance;
});

/// Provider para stream de telemetria
final telemetryStreamProvider = StreamProvider<TelemetryData>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.telemetryStream;
});

/// Provider para stream de estados dos relés
final relayStatesStreamProvider = StreamProvider<Map<String, bool>>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.relayStatesStream;
});

/// Provider para stream de valores dos sensores
final sensorValuesStreamProvider = StreamProvider<Map<String, double>>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.sensorValuesStream;
});

/// StateNotifier para gerenciar telemetria
class TelemetryNotifier extends StateNotifier<AsyncValue<TelemetryData?>> {
  TelemetryNotifier(this._telemetryService)
    : super(const AsyncValue.data(null));

  final TelemetryService _telemetryService;
  String? _currentDeviceUuid;

  /// Inicia telemetria para um dispositivo
  Future<void> startTelemetry({
    required String deviceUuid,
    int? telemetryInterval,
    bool enableSimulation = true,
  }) async {
    if (_currentDeviceUuid == deviceUuid &&
        _telemetryService.isReceivingTelemetry) {
      return; // Já está monitorando este dispositivo
    }

    state = const AsyncValue.loading();
    _currentDeviceUuid = deviceUuid;

    try {
      await _telemetryService.startTelemetry(
        deviceUuid: deviceUuid,
        telemetryInterval: telemetryInterval,
        enableSimulation: enableSimulation,
      );

      // Escuta o stream de telemetria
      _telemetryService.telemetryStream.listen(
        (telemetryData) {
          state = AsyncValue.data(telemetryData);
        },
        onError: (Object error, StackTrace stackTrace) {
          state = AsyncValue.error(error, stackTrace);
        },
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Para telemetria
  Future<void> stopTelemetry() async {
    await _telemetryService.stopTelemetry();
    state = const AsyncValue.data(null);
    _currentDeviceUuid = null;
  }

  /// Atualiza relé simulado
  void updateSimulatedRelay(String relayId, bool state) {
    _telemetryService.updateSimulatedRelay(relayId, state);
  }

  /// Atualiza sensor simulado
  void updateSimulatedSensor(String sensorId, double value) {
    _telemetryService.updateSimulatedSensor(sensorId, value);
  }
}

/// Provider para o TelemetryNotifier
final telemetryNotifierProvider =
    StateNotifierProvider<TelemetryNotifier, AsyncValue<TelemetryData?>>((ref) {
      final telemetryService = ref.watch(telemetryServiceProvider);
      return TelemetryNotifier(telemetryService);
    });

/// Provider para obter última telemetria
final lastTelemetryProvider = Provider<TelemetryData?>((ref) {
  final telemetryState = ref.watch(telemetryNotifierProvider);
  return telemetryState.valueOrNull;
});

/// Provider para verificar se está recebendo telemetria
final isReceivingTelemetryProvider = Provider<bool>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.isReceivingTelemetry;
});

/// Provider para verificar se está em modo simulação
final isSimulatingProvider = Provider<bool>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.isSimulating;
});

/// Provider para obter UUID do dispositivo atual
final currentDeviceUuidProvider = Provider<String?>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.currentDeviceUuid;
});

/// Provider para estados atuais dos relés
final currentRelayStatesProvider = Provider<Map<String, bool>>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.currentRelayStates;
});

/// Provider para valores atuais dos sensores
final currentSensorValuesProvider = Provider<Map<String, double>>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.currentSensorValues;
});

/// Provider para obter valor específico de sensor
final sensorValueProvider = Provider.family<double?, String>((ref, sensorId) {
  final sensorValues = ref.watch(currentSensorValuesProvider);
  return sensorValues[sensorId];
});

/// Provider para obter estado específico de relé
final relayStateProvider = Provider.family<bool?, String>((ref, relayId) {
  final relayStates = ref.watch(currentRelayStatesProvider);
  return relayStates[relayId];
});

/// Provider para estatísticas da telemetria
final telemetryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final telemetryState = ref.watch(telemetryNotifierProvider);
  final lastTelemetry = telemetryState.valueOrNull;
  final isReceiving = ref.watch(isReceivingTelemetryProvider);
  final isSimulating = ref.watch(isSimulatingProvider);

  return {
    'has_data': lastTelemetry != null,
    'is_receiving': isReceiving,
    'is_simulating': isSimulating,
    'last_update': lastTelemetry?.timestamp.toIso8601String(),
    'sequence': lastTelemetry?.sequence,
    'device_uuid': lastTelemetry?.deviceUuid,
    'signal_strength': lastTelemetry?.signalStrength,
    'battery_level': lastTelemetry?.batteryLevel,
    'system_status': lastTelemetry?.systemStatus,
  };
});
