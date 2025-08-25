# A10 - Agente de Implementação MQTT v2.2.0 Flutter

## 📋 Objetivo
Implementar as correções críticas e de alta prioridade identificadas na auditoria MQTT, garantindo conformidade com o protocolo v2.2.0 documentado.

## 🎯 Escopo de Implementação

### FASE 1 - Correções Críticas (Implementar Agora)
1. Adicionar `protocol_version` em todos os payloads
2. Corrigir configuração de clean session
3. Implementar códigos de erro padronizados
4. Diferenciar QoS levels por tipo de mensagem
5. Adicionar timeout explícito de 1000ms para heartbeat
6. Corrigir formato do Will Message

### FASE 2 - Funcionalidades Essenciais (Próxima Sprint)
1. Implementar telemetria de estado
2. Implementar eventos de segurança
3. Adicionar validação de payloads
4. Implementar sistema de presets

## 📁 Arquivos a Criar/Modificar

### Novos Arquivos
```
lib/
├── core/
│   ├── constants/
│   │   ├── mqtt_protocol.dart         # Constantes do protocolo
│   │   ├── mqtt_errors.dart           # Códigos de erro
│   │   └── mqtt_qos.dart              # QoS levels
│   ├── models/
│   │   ├── mqtt_base_message.dart     # Classe base com protocol_version
│   │   ├── relay_command.dart         # Comando de relé correto
│   │   ├── heartbeat_message.dart     # Heartbeat correto
│   │   ├── telemetry_state.dart       # Estado de telemetria
│   │   ├── safety_event.dart          # Evento de segurança
│   │   └── error_message.dart         # Mensagem de erro
│   └── validators/
│       └── mqtt_payload_validator.dart # Validação de payloads
└── services/
    └── telemetry_service.dart         # Serviço de telemetria
```

### Arquivos a Modificar
```
lib/
├── infrastructure/
│   └── services/
│       └── mqtt_service.dart          # Corrigir clean session, QoS
├── domain/
│   └── services/
│       └── heartbeat_service.dart     # Adicionar timeout, corrigir payload
└── presentation/
    └── widgets/
        └── momentary_button.dart       # Atualizar para novo formato
```

## 🔧 Implementações

### 1. Protocol Version - Base Message
```dart
// lib/core/constants/mqtt_protocol.dart
class MqttProtocol {
  static const String VERSION = "2.2.0";
  static const int HEARTBEAT_INTERVAL_MS = 500;
  static const int HEARTBEAT_TIMEOUT_MS = 1000;
  static const int RECONNECT_INTERVAL_MS = 5000;
}

// lib/core/models/mqtt_base_message.dart
import 'dart:convert';
import '../constants/mqtt_protocol.dart';

abstract class MqttBaseMessage {
  final DateTime timestamp;
  
  MqttBaseMessage({DateTime? timestamp}) 
    : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    final json = buildPayload();
    json['protocol_version'] = MqttProtocol.VERSION;
    json['timestamp'] = timestamp.toIso8601String();
    return json;
  }
  
  String toJsonString() => jsonEncode(toJson());
  
  Map<String, dynamic> buildPayload();
  
  static T? fromJson<T extends MqttBaseMessage>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) builder,
  ) {
    // Validate protocol version
    if (json['protocol_version'] != MqttProtocol.VERSION) {
      throw MqttProtocolException(
        'Invalid protocol version: ${json['protocol_version']}',
      );
    }
    return builder(json);
  }
}
```

### 2. Códigos de Erro Padronizados
```dart
// lib/core/constants/mqtt_errors.dart
enum MqttErrorCode {
  MQTT_001('Connection failed'),
  MQTT_002('Subscribe failed'),
  MQTT_003('Publish timeout'),
  MQTT_004('Invalid message format'),
  MQTT_005('Heartbeat timeout'),
  MQTT_006('Device offline'),
  MQTT_007('Permission denied'),
  MQTT_008('Invalid command');
  
  final String description;
  const MqttErrorCode(this.description);
  
  String get code => name;
}

// lib/core/models/error_message.dart
import 'mqtt_base_message.dart';
import '../constants/mqtt_errors.dart';

class MqttErrorMessage extends MqttBaseMessage {
  final MqttErrorCode errorCode;
  final String message;
  final Map<String, dynamic>? details;
  final String? deviceUuid;
  
  MqttErrorMessage({
    required this.errorCode,
    required this.message,
    this.details,
    this.deviceUuid,
    DateTime? timestamp,
  }) : super(timestamp: timestamp);
  
  @override
  Map<String, dynamic> buildPayload() {
    return {
      'error_code': errorCode.code,
      'error_message': message,
      'error_description': errorCode.description,
      if (details != null) 'details': details,
      if (deviceUuid != null) 'device_uuid': deviceUuid,
    };
  }
  
  factory MqttErrorMessage.fromJson(Map<String, dynamic> json) {
    return MqttBaseMessage.fromJson(
      json,
      (json) => MqttErrorMessage(
        errorCode: MqttErrorCode.values.firstWhere(
          (e) => e.code == json['error_code'],
        ),
        message: json['error_message'],
        details: json['details'],
        deviceUuid: json['device_uuid'],
        timestamp: DateTime.parse(json['timestamp']),
      ),
    )!;
  }
}
```

### 3. QoS Levels Diferenciados
```dart
// lib/core/constants/mqtt_qos.dart
import 'package:mqtt_client/mqtt_client.dart';

class MqttQosLevels {
  // QoS 0 - Fire and forget (telemetria, heartbeat)
  static const MqttQos telemetry = MqttQos.atMostOnce;
  static const MqttQos heartbeat = MqttQos.atMostOnce;
  
  // QoS 1 - At least once (comandos, eventos)
  static const MqttQos commands = MqttQos.atLeastOnce;
  static const MqttQos events = MqttQos.atLeastOnce;
  
  // QoS 2 - Exactly once (crítico - não usado atualmente)
  static const MqttQos critical = MqttQos.exactlyOnce;
  
  static MqttQos getQosForTopic(String topic) {
    if (topic.contains('/telemetry/') || topic.contains('/heartbeat')) {
      return telemetry;
    } else if (topic.contains('/relays/set') || topic.contains('/preset')) {
      return commands;
    } else if (topic.contains('/safety') || topic.contains('/emergency')) {
      return events;
    }
    return MqttQos.atLeastOnce; // default
  }
}
```

### 4. Relay Command Correto
```dart
// lib/core/models/relay_command.dart
import 'mqtt_base_message.dart';

class RelayCommand extends MqttBaseMessage {
  final int channel;
  final bool state;
  final String functionType;
  final bool? momentary;
  final int? pulseMs;
  final String user;
  final String? deviceUuid;
  
  RelayCommand({
    required this.channel,
    required this.state,
    required this.functionType,
    this.momentary,
    this.pulseMs,
    required this.user,
    this.deviceUuid,
    DateTime? timestamp,
  }) : super(timestamp: timestamp);
  
  @override
  Map<String, dynamic> buildPayload() {
    return {
      'channel': channel,
      'state': state,
      'function_type': functionType,
      if (momentary != null) 'momentary': momentary,
      if (pulseMs != null) 'pulse_ms': pulseMs,
      'user': user,
      if (deviceUuid != null) 'device_uuid': deviceUuid,
    };
  }
  
  factory RelayCommand.momentary({
    required int channel,
    required bool state,
    String user = 'flutter_app',
    String? deviceUuid,
  }) {
    return RelayCommand(
      channel: channel,
      state: state,
      functionType: 'momentary',
      momentary: true,
      user: user,
      deviceUuid: deviceUuid,
    );
  }
  
  factory RelayCommand.toggle({
    required int channel,
    required bool state,
    String user = 'flutter_app',
    String? deviceUuid,
  }) {
    return RelayCommand(
      channel: channel,
      state: state,
      functionType: 'toggle',
      user: user,
      deviceUuid: deviceUuid,
    );
  }
}
```

### 5. Heartbeat Message Correto
```dart
// lib/core/models/heartbeat_message.dart
import 'mqtt_base_message.dart';

class HeartbeatMessage extends MqttBaseMessage {
  final int channel;
  final int sequence;
  final String sourceUuid;
  final String targetUuid;
  
  HeartbeatMessage({
    required this.channel,
    required this.sequence,
    required this.sourceUuid,
    required this.targetUuid,
    DateTime? timestamp,
  }) : super(timestamp: timestamp);
  
  @override
  Map<String, dynamic> buildPayload() {
    return {
      'channel': channel,
      'sequence': sequence,
      'source_uuid': sourceUuid,
      'target_uuid': targetUuid,
    };
  }
  
  factory HeartbeatMessage.fromJson(Map<String, dynamic> json) {
    return MqttBaseMessage.fromJson(
      json,
      (json) => HeartbeatMessage(
        channel: json['channel'],
        sequence: json['sequence'],
        sourceUuid: json['source_uuid'],
        targetUuid: json['target_uuid'],
        timestamp: DateTime.parse(json['timestamp']),
      ),
    )!;
  }
}
```

### 6. Correção do MqttService
```dart
// lib/infrastructure/services/mqtt_service.dart - MODIFICAÇÕES

// 1. Corrigir clean session
final connMessage = MqttConnectMessage()
    .withClientIdentifier(_clientId)
    .startNotClean() // ✅ MUDANÇA CRÍTICA - era .startClean()
    .withWillQos(MqttQos.atLeastOnce)
    .withWillTopic('autocore/devices/$_clientId/status')
    .withWillMessage(jsonEncode({
      'protocol_version': MqttProtocol.VERSION,
      'uuid': _clientId,
      'status': 'offline',
      'timestamp': DateTime.now().toIso8601String(),
      'reason': 'unexpected_disconnect'
    })) // ✅ Will message correto
    .keepAliveFor(60);

// 2. Publish com QoS diferenciado
Future<void> publish(String topic, String message, {MqttQos? qos}) async {
  final effectiveQos = qos ?? MqttQosLevels.getQosForTopic(topic);
  
  final builder = MqttClientPayloadBuilder();
  builder.addString(message);
  
  client!.publishMessage(
    topic,
    effectiveQos, // ✅ QoS dinâmico
    builder.payload!,
  );
  
  _logger.debug('Published to $topic with QoS ${effectiveQos.index}');
}

// 3. Subscribe com QoS diferenciado
Stream<String> subscribe(String topic, {MqttQos? qos}) {
  final effectiveQos = qos ?? MqttQosLevels.getQosForTopic(topic);
  
  client!.subscribe(topic, effectiveQos);
  _logger.info('Subscribed to $topic with QoS ${effectiveQos.index}');
  
  return client!.updates!
      .where((List<MqttReceivedMessage<MqttMessage>> messages) =>
          messages.any((msg) => msg.topic == topic))
      .map((messages) {
        final msg = messages.firstWhere((m) => m.topic == topic);
        final payload = msg.payload as MqttPublishMessage;
        return MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );
      });
}
```

### 7. Correção do HeartbeatService
```dart
// lib/domain/services/heartbeat_service.dart - MODIFICAÇÕES

import '../../core/models/relay_command.dart';
import '../../core/models/heartbeat_message.dart';
import '../../core/constants/mqtt_protocol.dart';
import '../../core/constants/mqtt_qos.dart';

class HeartbeatService {
  static const Duration HEARTBEAT_INTERVAL = 
      Duration(milliseconds: MqttProtocol.HEARTBEAT_INTERVAL_MS);
  static const Duration HEARTBEAT_TIMEOUT = 
      Duration(milliseconds: MqttProtocol.HEARTBEAT_TIMEOUT_MS);
  
  final String _appUuid = 'flutter-app-001'; // TODO: get from config
  
  void startHeartbeat(HeartbeatState state) {
    // Enviar comando inicial com formato correto
    final command = RelayCommand.momentary(
      channel: state.channel,
      state: true,
      deviceUuid: state.deviceUuid,
    );
    
    _mqttService.publish(
      'autocore/devices/${state.deviceUuid}/relays/set',
      command.toJsonString(),
      qos: MqttQosLevels.commands, // ✅ QoS 1 para comando
    );
    
    // Iniciar heartbeat timer
    state.heartbeatTimer = Timer.periodic(HEARTBEAT_INTERVAL, (_) {
      state.heartbeatCount++;
      
      final heartbeat = HeartbeatMessage(
        channel: state.channel,
        sequence: state.heartbeatCount,
        sourceUuid: _appUuid,
        targetUuid: state.deviceUuid,
      );
      
      _mqttService.publish(
        'autocore/devices/${state.deviceUuid}/relays/heartbeat',
        heartbeat.toJsonString(),
        qos: MqttQosLevels.heartbeat, // ✅ QoS 0 para heartbeat
      );
      
      state.lastHeartbeat = DateTime.now();
      
      // ✅ Verificar timeout explicitamente
      _checkHeartbeatTimeout(state);
    });
  }
  
  void _checkHeartbeatTimeout(HeartbeatState state) {
    // Criar timer de timeout
    state.timeoutTimer?.cancel();
    state.timeoutTimer = Timer(HEARTBEAT_TIMEOUT, () {
      _logger.error('Heartbeat timeout for channel ${state.channel}');
      
      // Enviar erro padronizado
      final error = MqttErrorMessage(
        errorCode: MqttErrorCode.MQTT_005,
        message: 'Heartbeat timeout detected',
        details: {
          'channel': state.channel,
          'device_uuid': state.deviceUuid,
          'last_sequence': state.heartbeatCount,
        },
        deviceUuid: _appUuid,
      );
      
      _mqttService.publish(
        'autocore/errors/$_appUuid/heartbeat_timeout',
        error.toJsonString(),
        qos: MqttQosLevels.events,
      );
      
      // Parar heartbeat
      stopHeartbeat(state);
      
      // Notificar UI
      state.onTimeout?.call();
    });
  }
  
  void stopHeartbeat(HeartbeatState state) {
    state.heartbeatTimer?.cancel();
    state.timeoutTimer?.cancel();
    
    // Enviar comando OFF com formato correto
    final command = RelayCommand.momentary(
      channel: state.channel,
      state: false,
      deviceUuid: state.deviceUuid,
    );
    
    _mqttService.publish(
      'autocore/devices/${state.deviceUuid}/relays/set',
      command.toJsonString(),
      qos: MqttQosLevels.commands,
    );
  }
}
```

### 8. Telemetria Service (Nova)
```dart
// lib/services/telemetry_service.dart
import 'dart:convert';
import '../core/models/telemetry_state.dart';
import '../core/models/safety_event.dart';
import '../core/constants/mqtt_qos.dart';

class TelemetryService {
  final MqttService _mqttService;
  
  TelemetryService(this._mqttService);
  
  Stream<TelemetryState> subscribeToDeviceState(String deviceUuid) {
    return _mqttService
        .subscribe(
          'autocore/telemetry/$deviceUuid/state',
          qos: MqttQosLevels.telemetry,
        )
        .map((payload) => TelemetryState.fromJson(jsonDecode(payload)));
  }
  
  Stream<SafetyEvent> subscribeToSafetyEvents(String deviceUuid) {
    return _mqttService
        .subscribe(
          'autocore/telemetry/$deviceUuid/safety',
          qos: MqttQosLevels.events,
        )
        .map((payload) => SafetyEvent.fromJson(jsonDecode(payload)));
  }
  
  void listenForSafetyShutoffs() {
    subscribeToSafetyEvents('+').listen((event) {
      if (event.reason == 'heartbeat_timeout') {
        _logger.warning(
          'Safety shutoff on channel ${event.channel}: ${event.reason}',
        );
        
        // Notificar UI
        _showSafetyNotification(event);
      }
    });
  }
  
  void _showSafetyNotification(SafetyEvent event) {
    // Implementar notificação visual
  }
}
```

### 9. Payload Validator
```dart
// lib/core/validators/mqtt_payload_validator.dart
import '../constants/mqtt_protocol.dart';

class MqttPayloadValidator {
  static bool validateProtocolVersion(Map<String, dynamic> payload) {
    final version = payload['protocol_version'];
    if (version == null) {
      throw ValidationException('Missing protocol_version');
    }
    if (version != MqttProtocol.VERSION) {
      throw ValidationException(
        'Invalid protocol version: $version (expected ${MqttProtocol.VERSION})',
      );
    }
    return true;
  }
  
  static bool validateRelayCommand(Map<String, dynamic> payload) {
    validateProtocolVersion(payload);
    
    if (!payload.containsKey('channel')) {
      throw ValidationException('Missing channel');
    }
    if (!payload.containsKey('state')) {
      throw ValidationException('Missing state');
    }
    if (!payload.containsKey('function_type')) {
      throw ValidationException('Missing function_type');
    }
    
    final channel = payload['channel'];
    if (channel is! int || channel < 1 || channel > 32) {
      throw ValidationException('Invalid channel: $channel');
    }
    
    return true;
  }
  
  static bool validateHeartbeat(Map<String, dynamic> payload) {
    validateProtocolVersion(payload);
    
    if (!payload.containsKey('sequence')) {
      throw ValidationException('Missing sequence');
    }
    if (!payload.containsKey('channel')) {
      throw ValidationException('Missing channel');
    }
    
    return true;
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}
```

## 📋 Checklist de Implementação

### FASE 1 - Crítico (14 horas)
- [ ] Criar estrutura de pastas core/
- [ ] Implementar MqttBaseMessage com protocol_version
- [ ] Implementar MqttErrorCode e MqttErrorMessage
- [ ] Implementar MqttQosLevels
- [ ] Criar RelayCommand com formato correto
- [ ] Criar HeartbeatMessage com formato correto
- [ ] Corrigir clean session no MqttService
- [ ] Adicionar QoS diferenciado no MqttService
- [ ] Corrigir Will Message
- [ ] Atualizar HeartbeatService com timeout explícito
- [ ] Atualizar HeartbeatService com novos modelos
- [ ] Testar comandos de relé
- [ ] Testar heartbeat
- [ ] Testar reconexão

### FASE 2 - Alta Prioridade (20 horas)
- [ ] Implementar TelemetryState model
- [ ] Implementar SafetyEvent model
- [ ] Criar TelemetryService
- [ ] Implementar MqttPayloadValidator
- [ ] Adicionar validação em todos os subscribes
- [ ] Implementar PresetCommand
- [ ] Testar telemetria
- [ ] Testar eventos de segurança
- [ ] Documentar mudanças

## ✅ Resultado Esperado
- Conformidade com protocolo MQTT v2.2.0: **85%+**
- Todos os payloads com protocol_version
- QoS apropriado por tipo de mensagem
- Códigos de erro padronizados
- Heartbeat com timeout explícito
- Telemetria funcional
- Validação de payloads

## 🚀 Comandos de Execução
```bash
# Navegação
cd /Users/leechardes/Projetos/AutoCore/app-flutter

# Criar estrutura de pastas
mkdir -p lib/core/{constants,models,validators}
mkdir -p lib/services

# Rodar testes após implementação
flutter test

# Verificar análise estática
flutter analyze
```