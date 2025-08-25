# A17 - Telemetry Service Implementation

## 📋 Objetivo
Implementar o TelemetryService para gerenciar dados de telemetria em tempo real via MQTT e binding com widgets.

## 🎯 Service a Implementar

### TelemetryService Principal
```dart
// lib/infrastructure/services/telemetry_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:autocore_app/core/constants/mqtt_topics.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:autocore_app/core/utils/logger.dart';
import 'package:autocore_app/infrastructure/services/config_service.dart';
import 'package:autocore_app/infrastructure/services/mqtt_service.dart';

class TelemetryService {
  static TelemetryService? _instance;
  static TelemetryService get instance => _instance ??= TelemetryService._();

  TelemetryService._();

  final MqttService _mqttService = MqttService.instance;
  final ConfigService _configService = ConfigService.instance;
  
  // Estado da telemetria
  final _telemetryController = StreamController<Map<String, dynamic>>.broadcast();
  final _telemetryDataController = StreamController<TelemetryData>.broadcast();
  
  // Cache de valores
  final Map<String, dynamic> _telemetryCache = {};
  TelemetryData? _lastTelemetryData;
  
  // Subscriptions
  StreamSubscription? _mqttSubscription;
  Timer? _simulationTimer;
  
  // Estado
  bool _isSimulating = false;
  bool _isConnected = false;
  
  // Getters
  Stream<Map<String, dynamic>> get telemetryStream => _telemetryController.stream;
  Stream<TelemetryData> get telemetryDataStream => _telemetryDataController.stream;
  Map<String, dynamic> get currentTelemetry => Map.from(_telemetryCache);
  TelemetryData? get lastTelemetryData => _lastTelemetryData;
  bool get isConnected => _isConnected;
  bool get isSimulating => _isSimulating;
  
  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing TelemetryService');
      
      // Conectar ao MQTT se disponível
      if (_mqttService.isConnected) {
        await _subscribeMqttTelemetry();
      } else {
        // Iniciar simulação se MQTT não estiver disponível
        startSimulation();
      }
      
      // Carregar telemetria inicial da config se disponível
      final configTelemetry = _configService.getTelemetry();
      if (configTelemetry.isNotEmpty) {
        updateTelemetry(configTelemetry);
      }
      
    } catch (e, stack) {
      AppLogger.error('Failed to initialize TelemetryService', 
        error: e, stackTrace: stack);
    }
  }
  
  /// Subscribe aos tópicos MQTT de telemetria
  Future<void> _subscribeMqttTelemetry() async {
    try {
      // Cancelar subscription anterior
      await _mqttSubscription?.cancel();
      
      // Subscribe ao tópico de telemetria
      _mqttSubscription = _mqttService
          .subscribe('autocore/telemetry/+/data')
          .listen((message) {
        try {
          final data = jsonDecode(message) as Map<String, dynamic>;
          
          // Processar e atualizar telemetria
          _processTelemetryMessage(data);
          
          _isConnected = true;
        } catch (e) {
          AppLogger.error('Failed to parse telemetry message', error: e);
        }
      });
      
      AppLogger.info('Subscribed to MQTT telemetry topics');
      
    } catch (e, stack) {
      AppLogger.error('Failed to subscribe MQTT telemetry', 
        error: e, stackTrace: stack);
    }
  }
  
  /// Processa mensagem de telemetria
  void _processTelemetryMessage(Map<String, dynamic> data) {
    try {
      // Atualizar cache
      _telemetryCache.addAll(data);
      
      // Converter para TelemetryData
      final telemetryData = TelemetryData.fromDynamic(data);
      _lastTelemetryData = telemetryData;
      
      // Emitir updates
      _telemetryController.add(_telemetryCache);
      _telemetryDataController.add(telemetryData);
      
      // Atualizar ConfigService
      _configService.updateTelemetry(data);
      
      AppLogger.debug('Telemetry updated: ${data.keys.join(', ')}');
      
    } catch (e) {
      AppLogger.error('Failed to process telemetry', error: e);
    }
  }
  
  /// Atualiza telemetria manualmente
  void updateTelemetry(Map<String, dynamic> data) {
    _processTelemetryMessage(data);
  }
  
  /// Obtém valor específico de telemetria
  dynamic getValue(String key) {
    // Suporta paths como "telemetry.engine_temp"
    if (key.startsWith('telemetry.')) {
      key = key.substring(10); // Remove "telemetry."
    }
    
    return _telemetryCache[key];
  }
  
  /// Obtém valor como double
  double? getDoubleValue(String key) {
    final value = getValue(key);
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  /// Obtém valor como int
  int? getIntValue(String key) {
    final value = getValue(key);
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
  
  /// Stream de valor específico
  Stream<dynamic> getValueStream(String key) {
    return telemetryStream.map((data) => getValue(key));
  }
  
  /// Stream de valor como double
  Stream<double?> getDoubleStream(String key) {
    return telemetryStream.map((_) => getDoubleValue(key));
  }
  
  /// Inicia simulação de dados
  void startSimulation() {
    if (_isSimulating) return;
    
    AppLogger.info('Starting telemetry simulation');
    _isSimulating = true;
    
    // Cancelar timer anterior
    _simulationTimer?.cancel();
    
    // Simular dados a cada 500ms
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _generateSimulatedData();
    });
  }
  
  /// Para simulação
  void stopSimulation() {
    if (!_isSimulating) return;
    
    AppLogger.info('Stopping telemetry simulation');
    _isSimulating = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }
  
  /// Gera dados simulados
  void _generateSimulatedData() {
    final now = DateTime.now();
    final seconds = now.second + (now.millisecond / 1000.0);
    
    // Gerar valores variados baseados no tempo
    final data = {
      'speed': 45.0 + (20.0 * _sin(seconds, 0.1)),
      'rpm': 3200.0 + (800.0 * _sin(seconds, 0.15)),
      'engine_temp': 89.5 + (5.0 * _sin(seconds, 0.05)),
      'oil_pressure': 4.2 + (0.5 * _sin(seconds, 0.08)),
      'fuel_level': 75.8 - (seconds % 60) * 0.1,
      'battery_voltage': 13.8 + (0.2 * _sin(seconds, 0.2)),
      'intake_temp': 23.5 + (2.0 * _sin(seconds, 0.03)),
      'boost_pressure': 0.8 + (0.3 * _sin(seconds, 0.25)),
      'lambda': 0.95 + (0.05 * _sin(seconds, 0.12)),
      'tps': 35.2 + (15.0 * _sin(seconds, 0.18)),
      'ethanol': 27.5,
      'gear': ((seconds / 10).floor() % 6) + 1,
      'timestamp': now.toIso8601String(),
    };
    
    updateTelemetry(data);
  }
  
  /// Função seno para simulação
  double _sin(double value, double frequency) {
    return (value * frequency * 2 * 3.14159).sin();
  }
  
  /// Reconecta ao MQTT
  Future<void> reconnect() async {
    if (_mqttService.isConnected) {
      await _subscribeMqttTelemetry();
      stopSimulation();
    } else {
      startSimulation();
    }
  }
  
  /// Limpa cache
  void clearCache() {
    _telemetryCache.clear();
    _lastTelemetryData = null;
  }
  
  /// Dispose
  void dispose() {
    _mqttSubscription?.cancel();
    _simulationTimer?.cancel();
    _telemetryController.close();
    _telemetryDataController.close();
  }
}
```

### TelemetryProvider (Riverpod)
```dart
// lib/providers/telemetry_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocore_app/core/models/api/telemetry_data.dart';
import 'package:autocore_app/infrastructure/services/telemetry_service.dart';

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return TelemetryService.instance;
});

final telemetryStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.telemetryStream;
});

final telemetryDataStreamProvider = StreamProvider<TelemetryData>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.telemetryDataStream;
});

final telemetryValueProvider = Provider.family<dynamic, String>((ref, key) {
  final service = ref.watch(telemetryServiceProvider);
  return service.getValue(key);
});

final telemetryDoubleStreamProvider = StreamProvider.family<double?, String>((ref, key) {
  final service = ref.watch(telemetryServiceProvider);
  return service.getDoubleStream(key);
});

final isSimulatingProvider = Provider<bool>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.isSimulating;
});
```

### TelemetryBinding Helper
```dart
// lib/core/helpers/telemetry_binding.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocore_app/providers/telemetry_provider.dart';

/// Widget helper para binding de telemetria
class TelemetryValue extends ConsumerWidget {
  final String valueSource;
  final Widget Function(BuildContext context, double? value) builder;
  final double? defaultValue;
  
  const TelemetryValue({
    super.key,
    required this.valueSource,
    required this.builder,
    this.defaultValue,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(
      telemetryDoubleStreamProvider(valueSource)
    );
    
    return asyncValue.when(
      data: (value) => builder(context, value ?? defaultValue),
      loading: () => builder(context, defaultValue),
      error: (_, __) => builder(context, defaultValue),
    );
  }
}

/// Mixin para widgets que usam telemetria
mixin TelemetryBindingMixin {
  String extractTelemetryKey(String? valueSource) {
    if (valueSource == null) return '';
    
    // Remove prefixo "telemetry." se existir
    if (valueSource.startsWith('telemetry.')) {
      return valueSource.substring(10);
    }
    
    return valueSource;
  }
  
  double normalizeValue(double? value, double min, double max) {
    if (value == null) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
  
  Color getColorForValue(double value, List<ColorRange>? ranges) {
    if (ranges == null || ranges.isEmpty) {
      return Colors.green;
    }
    
    for (final range in ranges) {
      if (value >= range.min && value <= range.max) {
        return Color(int.parse(range.color.replaceAll('#', '0xFF')));
      }
    }
    
    return Colors.grey;
  }
}
```

## ✅ Checklist de Implementação

- [ ] Criar TelemetryService singleton
- [ ] Implementar subscription MQTT
- [ ] Adicionar processamento de mensagens
- [ ] Implementar cache de valores
- [ ] Criar simulador de dados
- [ ] Adicionar value streams
- [ ] Criar providers Riverpod
- [ ] Implementar helpers de binding
- [ ] Adicionar reconnection logic
- [ ] Tratar erros e edge cases

## 🚀 Comandos de Execução

```bash
# 1. Criar arquivos
touch lib/infrastructure/services/telemetry_service.dart
touch lib/providers/telemetry_provider.dart
touch lib/core/helpers/telemetry_binding.dart

# 2. Testar service
flutter test test/services/telemetry_service_test.dart

# 3. Verificar MQTT subscription
# Monitorar logs para ver mensagens recebidas
```

## 📊 Resultado Esperado

Após implementação:
- ✅ TelemetryService recebendo dados MQTT
- ✅ Simulação funcionando como fallback
- ✅ Streams de valores específicos
- ✅ Binding helpers para widgets
- ✅ Cache de valores atual
- ✅ Providers Riverpod integrados

---

**Prioridade**: P0 - CRÍTICO
**Tempo estimado**: 3-4 horas
**Dependências**: A15 (Models), A16 (ConfigService)