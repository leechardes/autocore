# 📱 AutoCore Flutter - Plano de Desenvolvimento (Execution-Only)

## 🎯 Visão Geral

Aplicativo Flutter para **execução de comandos veiculares** com interface dinâmica e sistema de segurança crítico (heartbeat). O app carrega configurações do backend e permite apenas visualização e execução - toda configuração é feita via AutoCore Config-App web.

### ⚠️ Escopo Execution-Only

**O que o app FAZ:**
- ✅ Carrega configurações do backend
- ✅ Executa macros via HTTP POST
- ✅ Executa comandos via MQTT
- ✅ Sistema de heartbeat para botões momentâneos
- ✅ Recebe estados em tempo real
- ✅ Cache offline de configurações

**O que o app NÃO FAZ:**
- ❌ Configurar dispositivos, telas ou macros
- ❌ Editar qualquer configuração
- ❌ CRUD de entidades
- ❌ Gerenciar usuários ou permissões

## 📅 CRONOGRAMA

**Duração Total**: 4 semanas (20 dias úteis)
**Foco**: Interface de execução com segurança

### Distribuição por Fases

- **Fase 1 - Fundação e Segurança**: 5 dias (25%)
- **Fase 2 - Interface Dinâmica**: 5 dias (25%)
- **Fase 3 - Execução e Comunicação**: 5 dias (25%)
- **Fase 4 - Polish e Testes**: 5 dias (25%)

---

## 🏗️ FASE 1 - FUNDAÇÃO E SEGURANÇA (Dias 1-5)

### Objetivos
Estabelecer base sólida com arquitetura limpa e implementar sistema crítico de heartbeat.

### 📋 Entregáveis

#### Dia 1: Setup e Estrutura

**Estrutura de Pastas:**
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── mqtt_topics.dart
│   │   └── api_endpoints.dart
│   ├── extensions/
│   │   └── context_extensions.dart
│   ├── models/
│   │   ├── screen_config.dart
│   │   ├── vehicle_info.dart
│   │   └── heartbeat_config.dart
│   ├── services/
│   │   ├── mqtt_service.dart
│   │   ├── heartbeat_service.dart    # CRÍTICO!
│   │   └── storage_service.dart
│   ├── theme/
│   └── widgets/
│       ├── base/
│       └── controls/
│           └── momentary_button.dart  # CRÍTICO!
├── domain/
├── infrastructure/
└── features/
    └── dashboard/
```

#### Dia 2: HeartbeatService (CRÍTICO)

```dart
@injectable
@singleton
class HeartbeatService {
  static const Duration HEARTBEAT_INTERVAL = Duration(milliseconds: 500);
  static const Duration TIMEOUT = Duration(milliseconds: 1000);
  
  final MqttService _mqtt;
  final Map<String, Timer?> _activeHeartbeats = {};
  
  void startMomentary(String deviceUuid, int channel) {
    final key = '$deviceUuid-$channel';
    
    // Comando inicial ON
    _mqtt.publish(
      'autocore/devices/$deviceUuid/relays/set',
      {'channel': channel, 'state': true, 'momentary': true}
    );
    
    // Heartbeat timer
    _activeHeartbeats[key] = Timer.periodic(HEARTBEAT_INTERVAL, (_) {
      _mqtt.publish(
        'autocore/devices/$deviceUuid/relays/heartbeat',
        {'channel': channel, 'sequence': _sequence++}
      );
    });
  }
  
  void stopMomentary(String deviceUuid, int channel) {
    final key = '$deviceUuid-$channel';
    _activeHeartbeats[key]?.cancel();
    _activeHeartbeats.remove(key);
    
    // Comando OFF
    _mqtt.publish(
      'autocore/devices/$deviceUuid/relays/set',
      {'channel': channel, 'state': false}
    );
  }
  
  void emergencyStopAll() {
    for (final timer in _activeHeartbeats.values) {
      timer?.cancel();
    }
    _activeHeartbeats.clear();
  }
}
```

#### Dia 3: MomentaryButton Widget

```dart
class MomentaryButton extends StatefulWidget {
  final String deviceUuid;
  final int channel;
  final String label;
  final IconData icon;
  
  @override
  _MomentaryButtonState createState() => _MomentaryButtonState();
}

class _MomentaryButtonState extends State<MomentaryButton> {
  final _heartbeat = GetIt.I<HeartbeatService>();
  bool _isPressed = false;
  
  void _onPressStart() {
    setState(() => _isPressed = true);
    HapticFeedback.heavyImpact();
    _heartbeat.startMomentary(widget.deviceUuid, widget.channel);
  }
  
  void _onPressEnd() {
    setState(() => _isPressed = false);
    _heartbeat.stopMomentary(widget.deviceUuid, widget.channel);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onPressStart(),
      onTapUp: (_) => _onPressEnd(),
      onTapCancel: _onPressEnd,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.orange : Theme.of(context).surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed ? depressedShadow : elevatedShadow,
        ),
        child: Column(
          children: [
            Icon(widget.icon, size: 32),
            Text(widget.label),
            if (_isPressed) PulsingIndicator(),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    // CRÍTICO: Sempre parar heartbeat ao destruir widget
    if (_isPressed) {
      _heartbeat.stopMomentary(widget.deviceUuid, widget.channel);
    }
    super.dispose();
  }
}
```

#### Dia 4: Serviços Core

**MacroService:**
```dart
class MacroService {
  final Dio _dio;
  
  Future<void> executeMacro(int macroId) async {
    try {
      await _dio.post('/api/macros/$macroId/execute');
      HapticFeedback.mediumImpact();
    } catch (e) {
      throw MacroExecutionException(e.toString());
    }
  }
}
```

**ButtonService:**
```dart
class ButtonService {
  final MqttService _mqtt;
  
  Future<void> executeButton(String deviceId, int channel, bool state) async {
    await _mqtt.publish(
      'autocore/devices/$deviceId/relays/set',
      {'channel': channel, 'state': state}
    );
  }
}
```

#### Dia 5: Safety Monitoring

```dart
class SafetyMonitor {
  final MqttService _mqtt;
  final HeartbeatService _heartbeat;
  
  void initialize() {
    // Escutar eventos de safety shutoff
    _mqtt.subscribe('autocore/telemetry/+/safety').listen((message) {
      final event = SafetyEvent.fromJson(message.payload);
      
      if (event.reason == 'heartbeat_timeout') {
        AppLogger.error('SAFETY: Canal ${event.channel} desligado por timeout');
        
        // Notificar usuário
        showSnackBar(
          'Botão desligado automaticamente por segurança',
          type: SnackBarType.warning,
        );
      }
    });
  }
  
  // Auto-release ao minimizar app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _heartbeat.emergencyStopAll();
    }
  }
}
```

---

## 🎨 FASE 2 - INTERFACE DINÂMICA (Dias 6-10)

### Objetivos
Implementar sistema de carregamento dinâmico de interface baseado em configuração do backend.

### 📋 Entregáveis

#### Dia 6: Dashboard Principal

```dart
class DynamicDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Vehicle info (opcional)
          if (config.vehicleInfo != null) 
            VehicleCard(info: config.vehicleInfo),
          
          // 4 botões de navegação (screens)
          ScreenButtons(
            screens: config.screens.take(4).toList(),
            onTap: (screen) => Navigator.pushNamed(context, '/screen/${screen.id}'),
          ),
          
          // Quick Actions (macros)
          QuickActions(
            macros: config.macros,
            onExecute: (macro) => MacroService.execute(macro.id),
          ),
        ],
      ),
      floatingActionButton: EmergencyButton(
        onPressed: () => EmergencyService.stopAll(),
      ),
    );
  }
}
```

#### Dia 7: Dynamic Screen Builder

```dart
class DynamicScreen extends StatelessWidget {
  final ScreenConfig config;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(config.name)),
      body: GridView.builder(
        itemCount: config.items.length,
        itemBuilder: (context, index) {
          final item = config.items[index];
          return ExecutionWidgetBuilder.build(item);
        },
      ),
    );
  }
}
```

#### Dia 8: ExecutionWidgetBuilder

```dart
class ExecutionWidgetBuilder {
  static Widget build(WidgetConfig config) {
    switch (config.type) {
      case 'switch':
        return SwitchControl(
          label: config.label,
          value: config.value,
          onChanged: (value) => _executeCommand(config, value),
        );
        
      case 'momentary':
        return MomentaryButton(
          deviceUuid: config.deviceId,
          channel: config.channel,
          label: config.label,
          icon: config.icon,
        );
        
      case 'tile':
        return ControlTile(
          label: config.label,
          icon: config.icon,
          onTap: () => _executeCommand(config, true),
        );
        
      case 'mode_selector':
        return ModeSelector(
          options: config.options,
          selected: config.value,
          onSelect: (mode) => _executeCommand(config, mode),
        );
        
      default:
        return Container();
    }
  }
}
```

#### Dia 9: Vehicle Info Widget

```dart
class VehicleCard extends StatelessWidget {
  final VehicleInfo? info;
  
  @override
  Widget build(BuildContext context) {
    if (info == null) return SizedBox.shrink();
    
    return Card(
      child: Column(
        children: [
          if (info.image != null)
            Image.network(info.image, height: 100),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatusIndicator(
                label: 'Sistema',
                value: info.systemStatus,
                isActive: info.isOnline,
              ),
              StatusIndicator(
                label: 'Tração',
                value: info.tractionMode,
              ),
              StatusIndicator(
                label: 'Bateria',
                value: '${info.batteryVoltage}V',
                color: _getBatteryColor(info.batteryVoltage),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### Dia 10: Quick Actions (Macros)

```dart
class QuickActions extends StatelessWidget {
  final List<Macro> macros;
  final Function(Macro) onExecute;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: macros.length,
        itemBuilder: (context, index) {
          final macro = macros[index];
          return ActionCard(
            icon: macro.icon,
            label: macro.name,
            onTap: () async {
              HapticFeedback.mediumImpact();
              await onExecute(macro);
              _showExecutionFeedback(context, macro);
            },
          );
        },
      ),
    );
  }
}
```

---

## 🚀 FASE 3 - EXECUÇÃO E COMUNICAÇÃO (Dias 11-15)

### Objetivos
Implementar comunicação robusta com backend e sistema de estados em tempo real.

### 📋 Entregáveis

#### Dia 11: MQTT Integration

```dart
class MqttManager {
  final MqttService _mqtt;
  final StateManager _state;
  
  void initialize() {
    // Subscribe em tópicos de telemetria
    _mqtt.subscribe('autocore/telemetry/+/status');
    _mqtt.subscribe('autocore/telemetry/+/battery');
    _mqtt.subscribe('autocore/telemetry/+/safety');
    
    // Processar mensagens
    _mqtt.messages.listen((message) {
      switch (message.topic) {
        case 'autocore/telemetry/battery':
          _state.updateBattery(BatteryStatus.fromJson(message.payload));
          break;
        case 'autocore/telemetry/safety':
          _handleSafetyEvent(SafetyEvent.fromJson(message.payload));
          break;
      }
    });
  }
}
```

#### Dia 12: State Management

```dart
class DeviceStateProvider extends ChangeNotifier {
  final Map<String, DeviceState> _states = {};
  
  void updateDeviceState(String deviceId, DeviceState state) {
    _states[deviceId] = state;
    notifyListeners();
  }
  
  DeviceState? getDeviceState(String deviceId) => _states[deviceId];
  
  Stream<DeviceState> watchDevice(String deviceId) {
    return Stream.periodic(Duration(seconds: 1))
      .map((_) => _states[deviceId])
      .where((state) => state != null)
      .cast<DeviceState>();
  }
}
```

#### Dia 13: Offline Queue

```dart
class OfflineQueue {
  final Queue<Command> _pending = Queue();
  final StorageService _storage;
  
  Future<void> addCommand(Command cmd) async {
    _pending.add(cmd);
    await _storage.savePendingCommands(_pending.toList());
  }
  
  Future<void> processPending() async {
    while (_pending.isNotEmpty) {
      final cmd = _pending.removeFirst();
      try {
        await cmd.execute();
      } catch (e) {
        _pending.addFirst(cmd); // Re-add on failure
        break;
      }
    }
  }
}
```

#### Dia 14: Error Handling

```dart
class ErrorHandler {
  static void handleError(dynamic error, StackTrace? stack) {
    AppLogger.error('Error occurred', error: error, stackTrace: stack);
    
    if (error is HeartbeatException) {
      _showCriticalError('Falha no sistema de segurança');
      HeartbeatService.emergencyStopAll();
    } else if (error is MqttException) {
      _showConnectionError('Conexão perdida com o gateway');
    } else if (error is MacroException) {
      _showExecutionError('Falha ao executar macro');
    }
  }
}
```

#### Dia 15: Connection Recovery

```dart
class ConnectionManager {
  Timer? _reconnectTimer;
  int _retryCount = 0;
  
  void startAutoReconnect() {
    _reconnectTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      if (!_mqtt.isConnected) {
        try {
          await _mqtt.connect();
          _retryCount = 0;
        } catch (e) {
          _retryCount++;
          if (_retryCount > 10) {
            _showPersistentConnectionError();
          }
        }
      }
    });
  }
}
```

---

## 🧪 FASE 4 - POLISH E TESTES (Dias 16-20)

### Objetivos
Finalizar interface, implementar feedback visual/háptico e garantir cobertura de testes.

### 📋 Entregáveis

#### Dia 16: Visual Feedback

```dart
class FeedbackService {
  static void buttonPress() => HapticFeedback.lightImpact();
  static void switchToggle() => HapticFeedback.mediumImpact();
  static void momentaryPress() => HapticFeedback.heavyImpact();
  static void emergency() => HapticFeedback.vibrate();
  
  static void showSuccess(String message) {
    Get.snackbar(
      'Sucesso',
      message,
      backgroundColor: Colors.green,
      icon: Icon(Icons.check_circle),
      duration: Duration(seconds: 2),
    );
  }
  
  static void showError(String message) {
    Get.snackbar(
      'Erro',
      message,
      backgroundColor: Colors.red,
      icon: Icon(Icons.error),
      duration: Duration(seconds: 3),
    );
  }
}
```

#### Dia 17: Performance Optimization

```dart
class PerformanceOptimizer {
  // Widget keys para preservar estado
  static final dashboardKey = GlobalKey();
  static final screenKeys = <String, GlobalKey>{};
  
  // Cache de imagens
  static void precacheAssets(BuildContext context) {
    precacheImage(AssetImage('assets/logo.png'), context);
    precacheImage(AssetImage('assets/vehicle.png'), context);
  }
  
  // Lazy loading
  static Widget lazyLoadScreen(String screenId) {
    return FutureBuilder<ScreenConfig>(
      future: ConfigService.loadScreen(screenId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingIndicator();
        return DynamicScreen(config: snapshot.data!);
      },
    );
  }
}
```

#### Dia 18-19: Testes

**Testes Unitários:**
```dart
void main() {
  group('HeartbeatService Tests', () {
    test('should start heartbeat with correct interval', () {
      final service = HeartbeatService(mockMqtt);
      service.startMomentary('device1', 5);
      
      verify(mockMqtt.publish(any, any)).called(1);
      
      // Wait for heartbeat
      await Future.delayed(Duration(milliseconds: 600));
      verify(mockMqtt.publish(contains('heartbeat'), any)).called(1);
    });
    
    test('should stop heartbeat on emergency', () {
      final service = HeartbeatService(mockMqtt);
      service.startMomentary('device1', 5);
      service.emergencyStopAll();
      
      expect(service.activeHeartbeats, isEmpty);
    });
  });
}
```

**Testes de Widget:**
```dart
void main() {
  testWidgets('MomentaryButton should send heartbeat', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MomentaryButton(
          deviceUuid: 'test',
          channel: 1,
          label: 'Buzina',
          icon: Icons.volume_up,
        ),
      ),
    );
    
    // Press button
    await tester.press(find.byType(MomentaryButton));
    verify(mockHeartbeat.startMomentary('test', 1)).called(1);
    
    // Release button
    await tester.pumpAndSettle();
    verify(mockHeartbeat.stopMomentary('test', 1)).called(1);
  });
}
```

#### Dia 20: Documentação e Deploy

**Documentação:**
- README.md atualizado
- Guia de instalação
- Documentação de segurança (heartbeat)
- Troubleshooting guide

**Build & Deploy:**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Bundle size check
flutter build apk --analyze-size
```

---

## 📊 MÉTRICAS DE SUCESSO

### Funcionalidades Core
- ✅ Sistema de heartbeat implementado e testado
- ✅ Interface 100% dinâmica via backend
- ✅ Execução de macros funcional
- ✅ Estados em tempo real via MQTT
- ✅ Safety shutoff automático

### Segurança
- ✅ Heartbeat timeout de 1 segundo
- ✅ Auto-release ao minimizar app
- ✅ Emergency stop funcional
- ✅ Notificações de safety events

### Performance
- ✅ Tempo de carregamento < 2s
- ✅ 60 FPS em animações
- ✅ Bundle size < 15MB
- ✅ Consumo de bateria otimizado

### Qualidade
- ✅ Cobertura de testes > 70%
- ✅ Zero crashes em produção
- ✅ Feedback háptico em todas interações
- ✅ Documentação completa

## 🚨 PONTOS CRÍTICOS

1. **Heartbeat é OBRIGATÓRIO** para botões momentâneos
2. **Sempre implementar dispose()** para parar heartbeats
3. **Auto-release ao perder foco** do app
4. **Notificar safety shutoffs** ao usuário
5. **Testar exaustivamente** sistema de segurança

---

**AutoCore Flutter** - Interface de execução com segurança crítica