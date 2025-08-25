# Plano de Implementação de Testes - AutoCore Flutter

## 📋 Resumo Executivo

Este documento estabelece um plano abrangente para implementação de testes no projeto AutoCore Flutter, incluindo testes unitários, de widget e de integração.

**Data do Plano**: 25/08/2025  
**Status Atual**: ❌ Sem cobertura de testes (0%)  
**Meta**: Cobertura de testes >80% em funcionalidades críticas  
**Prioridade**: 🔴 Alta (essential para produção robusta)  

## 🎯 Estado Atual dos Testes

### Situação Existente
```
test/
├── unit_test_config_service.dart  # ✅ Teste básico do ConfigService
├── widget_test.dart              # ❌ Teste padrão não customizado  
└── test_todos.dart              # ❌ Arquivo de teste temporário
```

**Coverage Atual**: ~0% (apenas 1 teste funcional)  
**Issues Identificadas**:
- Nenhum teste para services críticos (MQTT, API, Device Registration)
- Nenhum teste de widget para componentes customizados
- Nenhum teste de integração
- Sem configuração de coverage reporting

## 🏗️ Estratégia de Implementação

### Pirâmide de Testes
```
        /\
       /  \
      / UI \     <- Integration Tests (20%)
     /      \
    /        \
   / Widget   \   <- Widget Tests (30%)
  /            \
 /              \
/__Unit Tests___\ <- Unit Tests (50%)
```

**Filosofia**: Mais testes unitários (rápidos/confiáveis), menos testes de integração (lentos/frágeis)

## 📊 Plano de Cobertura por Camada

### 🔴 Prioridade P0: Funcionalidades Críticas (80%+ coverage)

#### P0.1 Services Core
| Serviço | Testes Unitários | Testes de Integração | Prioridade |
|---------|------------------|----------------------|------------|
| `MqttService` | ✅ Essential | ✅ Essential | 🔴 P0 |
| `ConfigService` | ✅ Essential | ✅ Essential | 🔴 P0 |
| `ApiService` | ✅ Essential | ⚠️ Nice-to-have | 🔴 P0 |
| `DeviceRegistrationService` | ✅ Essential | ⚠️ Nice-to-have | 🔴 P0 |
| `TelemetryService` | ✅ Essential | ⚠️ Nice-to-have | 🔴 P0 |

#### P0.2 Models Critical
| Modelo | Serialization Tests | Validation Tests | Prioridade |
|--------|-------------------|------------------|------------|
| `ConfigFullResponse` | ✅ Essential | ✅ Essential | 🔴 P0 |
| `ScreenConfig` | ✅ Essential | ✅ Essential | 🔴 P0 |
| `DeviceInfo` | ✅ Essential | ⚠️ Nice-to-have | 🔴 P0 |

### 🟠 Prioridade P1: Funcionalidades Importantes (60%+ coverage)

#### P1.1 Widgets Custom
| Widget | Widget Tests | Interaction Tests | Prioridade |
|--------|-------------|------------------|------------|
| `DynamicScreenWrapper` | ✅ Important | ⚠️ Nice-to-have | 🟠 P1 |
| `ButtonItemWidget` | ✅ Important | ✅ Important | 🟠 P1 |
| `GaugeItemWidget` | ✅ Important | ⚠️ Nice-to-have | 🟠 P1 |
| `DisplayItemWidget` | ✅ Important | ⚠️ Nice-to-have | 🟠 P1 |

#### P1.2 Providers/State Management
| Provider | State Tests | Notification Tests | Prioridade |
|----------|-------------|-------------------|------------|
| `ConfigProvider` | ✅ Important | ✅ Important | 🟠 P1 |
| `ThemeProvider` | ⚠️ Nice-to-have | ⚠️ Nice-to-have | 🟠 P1 |
| `TelemetryProvider` | ✅ Important | ⚠️ Nice-to-have | 🟠 P1 |

### 🟡 Prioridade P2: Funcionalidades Auxiliares (40%+ coverage)

#### P2.1 Utils e Helpers
| Componente | Unit Tests | Edge Case Tests | Prioridade |
|------------|-----------|----------------|------------|
| `AppLogger` | ⚠️ Nice-to-have | ⚠️ Nice-to-have | 🟡 P2 |
| `ColorExtensions` | ⚠️ Nice-to-have | ❌ Skip | 🟡 P2 |
| `Validators` | ⚠️ Nice-to-have | ⚠️ Nice-to-have | 🟡 P2 |

## 🛠️ Implementação Técnica

### Configuração Base

#### pubspec.yaml Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.6
  test: ^1.24.6
  integration_test:
    sdk: flutter
  network_image_mock: ^2.1.1
  golden_toolkit: ^0.15.0  # Para golden tests
```

#### test/helpers/test_helpers.dart
```dart
// Configuração central para testes
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

// Mock classes
@GenerateMocks([
  ApiService,
  MqttService,
  ConfigService,
  DeviceRegistrationService,
])
import 'test_helpers.mocks.dart';

class TestHelpers {
  static Widget wrapWithApp(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
  }
  
  static Widget wrapWithProvider<T extends ChangeNotifier>(
    Widget widget,
    T provider,
  ) {
    return ChangeNotifierProvider<T>.value(
      value: provider,
      child: wrapWithApp(widget),
    );
  }
}

// Mock data
class MockData {
  static final configFullResponse = ConfigFullResponse(
    version: '2.0.0',
    protocolVersion: '2.2.0',
    timestamp: '2025-08-25T10:00:00Z',
    device: DeviceInfo(
      id: '1',
      uuid: 'test-uuid',
      type: 'esp32_display',
      name: 'Test Device',
      status: 'online',
    ),
    system: SystemInfo(name: 'Test System'),
    screens: [mockScreen],
  );
  
  static final mockScreen = ScreenConfig(
    id: '1',
    name: 'home',
    title: 'Test Screen',
    items: [mockButtonItem],
  );
  
  static final mockButtonItem = ScreenItem(
    id: '1',
    itemType: 'button',
    name: 'test_button',
    label: 'Test Button',
  );
}
```

### Estrutura de Testes

```
test/
├── helpers/
│   ├── test_helpers.dart
│   ├── test_helpers.mocks.dart
│   └── mock_data.dart
├── unit/
│   ├── services/
│   │   ├── mqtt_service_test.dart
│   │   ├── config_service_test.dart
│   │   ├── api_service_test.dart
│   │   └── device_registration_service_test.dart
│   ├── models/
│   │   ├── config_full_response_test.dart
│   │   └── screen_config_test.dart
│   └── providers/
│       ├── config_provider_test.dart
│       └── telemetry_provider_test.dart
├── widget/
│   ├── screens/
│   │   └── dashboard_page_test.dart
│   ├── widgets/
│   │   ├── button_item_widget_test.dart
│   │   ├── gauge_item_widget_test.dart
│   │   └── display_item_widget_test.dart
│   └── dynamic/
│       └── dynamic_screen_wrapper_test.dart
├── integration/
│   ├── app_flow_test.dart
│   ├── mqtt_integration_test.dart
│   └── config_loading_test.dart
└── golden/
    ├── button_golden_test.dart
    └── gauge_golden_test.dart
```

## 📝 Exemplos de Implementação

### Unit Test: MqttService
```dart
// test/unit/services/mqtt_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('MqttService', () {
    late MqttService mqttService;
    late MockMqttServerClient mockClient;

    setUp(() {
      mockClient = MockMqttServerClient();
      mqttService = MqttService(client: mockClient);
    });

    tearDown(() {
      mqttService.dispose();
    });

    group('connect()', () {
      test('should connect successfully with valid credentials', () async {
        // Arrange
        when(mockClient.connect()).thenAnswer((_) async => MqttClientConnectionStatus.connected);
        
        // Act
        final result = await mqttService.connect();
        
        // Assert
        expect(result, isTrue);
        verify(mockClient.connect()).called(1);
      });

      test('should handle connection failure gracefully', () async {
        // Arrange
        when(mockClient.connect()).thenThrow(SocketException('Connection failed'));
        
        // Act
        final result = await mqttService.connect();
        
        // Assert
        expect(result, isFalse);
        expect(mqttService.isConnected, isFalse);
      });

      test('should retry connection on failure', () async {
        // Arrange
        when(mockClient.connect())
          .thenThrow(SocketException('First attempt'))
          .thenAnswer((_) async => MqttClientConnectionStatus.connected);
        
        // Act
        final result = await mqttService.connect(retryCount: 2);
        
        // Assert
        expect(result, isTrue);
        verify(mockClient.connect()).called(2);
      });
    });

    group('publish()', () {
      test('should publish message with correct QoS', () async {
        // Arrange
        when(mockClient.connectionStatus?.state).thenReturn(MqttConnectionState.connected);
        
        // Act
        await mqttService.publish('test/topic', {'message': 'test'});
        
        // Assert
        verify(mockClient.publishMessage(
          'test/topic',
          MqttQos.atLeastOnce,
          argThat(contains('test')),
        )).called(1);
      });

      test('should throw when not connected', () async {
        // Arrange
        when(mockClient.connectionStatus?.state).thenReturn(MqttConnectionState.disconnected);
        
        // Act & Assert
        expect(
          () => mqttService.publish('test/topic', {'message': 'test'}),
          throwsA(isA<MqttNotConnectedException>()),
        );
      });
    });

    group('subscribe()', () {
      test('should subscribe to topic successfully', () {
        // Arrange
        when(mockClient.connectionStatus?.state).thenReturn(MqttConnectionState.connected);
        
        // Act
        mqttService.subscribe('test/topic');
        
        // Assert
        verify(mockClient.subscribe('test/topic', MqttQos.atLeastOnce)).called(1);
      });
    });
  });
}
```

### Widget Test: ButtonItemWidget
```dart
// test/widget/widgets/button_item_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../lib/features/screens/widgets/button_item_widget.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ButtonItemWidget', () {
    late ScreenItem mockButtonItem;
    late MockTelemetryProvider mockTelemetryProvider;

    setUp(() {
      mockButtonItem = MockData.mockButtonItem;
      mockTelemetryProvider = MockTelemetryProvider();
    });

    testWidgets('should render button with correct label', (tester) async {
      // Act
      await tester.pumpWidget(
        TestHelpers.wrapWithProvider(
          ButtonItemWidget(item: mockButtonItem),
          mockTelemetryProvider,
        ),
      );

      // Assert
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      bool wasPressed = false;
      
      await tester.pumpWidget(
        TestHelpers.wrapWithProvider(
          ButtonItemWidget(
            item: mockButtonItem,
            onButtonPressed: (itemId, command, payload) {
              wasPressed = true;
            },
          ),
          mockTelemetryProvider,
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should show loading state when pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(
        TestHelpers.wrapWithProvider(
          ButtonItemWidget(
            item: mockButtonItem,
            onButtonPressed: (itemId, command, payload) async {
              await Future.delayed(Duration(milliseconds: 100));
            },
          ),
          mockTelemetryProvider,
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should disable button when action is null', (tester) async {
      // Arrange
      final disabledButton = mockButtonItem.copyWith(actionType: null);
      
      await tester.pumpWidget(
        TestHelpers.wrapWithProvider(
          ButtonItemWidget(item: disabledButton),
          mockTelemetryProvider,
        ),
      );

      // Act
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      // Assert
      expect(button.onPressed, isNull);
    });
  });
}
```

### Integration Test: Config Loading Flow
```dart
// integration_test/config_loading_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:autocore_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Config Loading Integration', () {
    testWidgets('should load config and display dashboard', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for config to load
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Should show dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should handle offline mode gracefully', (tester) async {
      // TODO: Implement network interceptor to simulate offline
      // For now, test would require manual network disconnection
    });

    testWidgets('should navigate between screens', (tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Wait for load
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Tap on settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Should show settings screen
      expect(find.text('System Settings'), findsOneWidget);
    });
  });
}
```

## 🚀 Roadmap de Implementação

### Phase 1: Fundação (1 semana)
**Objetivo**: Estabelecer infraestrutura de testes

**Tasks**:
- [ ] Configurar dependências de teste
- [ ] Criar estrutura de pastas
- [ ] Implementar TestHelpers e MockData
- [ ] Configurar CI/CD para testes
- [ ] Gerar mocks com build_runner

**Deliverables**:
- ✅ Estrutura base de testes
- ✅ Mocks gerados
- ✅ CI configurado

**Estimativa**: 8-12 horas

### Phase 2: Services Core (2 semanas)
**Objetivo**: Testar funcionalidades críticas

**Tasks**:
- [ ] Implementar testes para MqttService
- [ ] Implementar testes para ConfigService  
- [ ] Implementar testes para ApiService
- [ ] Implementar testes para DeviceRegistrationService
- [ ] Implementar testes para TelemetryService

**Target Coverage**: 80%+ em services críticos

**Estimativa**: 20-30 horas

### Phase 3: Models e Serialization (1 semana)
**Objetivo**: Validar parsing e modelos

**Tasks**:
- [ ] Testes de serialization JSON
- [ ] Testes de validação de dados
- [ ] Edge cases (null, empty, invalid data)
- [ ] Performance tests para parsing

**Target Coverage**: 90%+ em models críticos

**Estimativa**: 12-16 horas

### Phase 4: Widget Tests (2 semanas)
**Objetivo**: Testar componentes UI

**Tasks**:
- [ ] Testes para widgets customizados
- [ ] Interaction tests (tap, scroll, etc.)
- [ ] State management tests
- [ ] Golden tests para UI consistency

**Target Coverage**: 70%+ em widgets críticos

**Estimativa**: 24-32 horas

### Phase 5: Integration Tests (1 semana)
**Objetivo**: Testar fluxos end-to-end

**Tasks**:
- [ ] App launch flow
- [ ] Config loading flow
- [ ] MQTT connection flow
- [ ] Screen navigation flow

**Target Coverage**: Major user flows

**Estimativa**: 16-20 horas

## 📊 Configuração de Coverage

### lcov.info Configuration
```yaml
# dart_test.yaml
test_on: "vm"
coverage:
  - "lib/**"
exclude:
  - "lib/**/*.g.dart"
  - "lib/**/*.freezed.dart"  
  - "lib/**/generated/**"
  - "test/**"
```

### Coverage Commands
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# View coverage in browser  
open coverage/html/index.html

# Coverage summary
lcov --summary coverage/lcov.info
```

### CI/CD Integration
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.13.0'
          
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: bash <(curl -s https://codecov.io/bash)
      
      # Fail if coverage < 80%
      - name: Check coverage
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep -E "lines.*:" | grep -oE "[0-9]+\.[0-9]+%" | sed 's/%//')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 80%"
            exit 1
          fi
```

## ⚠️ Challenges e Soluções

### Challenge 1: Mocking MQTT
**Problema**: MQTT client é complexo para mockar
**Solução**: 
- Criar interface `IMqttClient` 
- Implementar `MockMqttClient`
- Usar dependency injection

### Challenge 2: Testing Async Operations
**Problema**: Services são assíncronos com timers
**Solução**:
- Usar `fakeAsync()` para controlar tempo
- Mock timers quando necessário
- Aguardar `pumpAndSettle()` adequadamente

### Challenge 3: Testing Network Calls
**Problema**: Testes dependem de rede externa
**Solução**:
- Mock HTTP client com `MockAdapter` 
- Usar `nock` equivalente para Dart
- Interceptors para simular cenários

### Challenge 4: Widget Tests com Provider
**Problema**: Widgets dependem de providers complexos
**Solução**:
- Create mock providers
- Use `MultiProvider` nos tests
- Mockar apenas o necessário

## 📈 Métricas de Sucesso

### Coverage Targets
| Componente | Target | Justificativa |
|------------|--------|---------------|
| Services | 85%+ | Core business logic |
| Models | 90%+ | Data integrity crítica |
| Widgets | 70%+ | UI components |
| Utils | 50%+ | Helper functions |
| Overall | 80%+ | Industry standard |

### Quality Gates
- [ ] All tests pass ✅
- [ ] Coverage > 80% ✅
- [ ] No flaky tests ✅
- [ ] Fast execution (<2 min) ✅
- [ ] CI/CD integration ✅

### Success Metrics
- **Bug Detection**: Tests catch bugs before production
- **Refactoring Safety**: Confident refactoring with tests
- **Documentation**: Tests as living documentation
- **Team Velocity**: Faster development with good tests

## 🎯 Conclusão

A implementação de testes no AutoCore Flutter é **essencial** para:

1. **Confiabilidade**: Garantir que funcionalidades críticas funcionem
2. **Manutenibilidade**: Refatorar código com segurança  
3. **Qualidade**: Detectar bugs antes de chegar em produção
4. **Documentação**: Testes como documentação viva

**Recomendação**: Implementar incrementalmente, começando com **Phase 1 (Fundação)** e **Phase 2 (Services Core)** para estabelecer base sólida.

**Status**: 🔴 Crítico - Testes são necessários antes de escalar o projeto

---

**Documento gerado por**: A36-DOCUMENTATION-ORGANIZATION  
**Data**: 25/08/2025  
**Próxima revisão**: 01/09/2025  
**Prioridade de execução**: Alta (fundamental para produção robusta)