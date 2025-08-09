# 📱 Flutter Standards - AutoCore App

## 🎯 Objetivo
Este documento define os padrões de código, boas práticas e diretrizes para o desenvolvimento do AutoCore Flutter App. **SEMPRE consulte este documento antes de codificar**.

## ⚠️ Versão do Flutter
- **Flutter**: 3.32.4 ou superior
- **Dart**: 3.8.1 ou superior
- **Min SDK**: Android 21, iOS 12.0

---

## 🚫 O QUE NÃO FAZER (Evite Erros Comuns)

### ❌ Imports Relativos em lib/
```dart
// ❌ ERRADO - Import relativo
import '../../shared/extensions.dart';
import '../models/user.dart';

// ✅ CORRETO - Sempre use package imports
import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:autocore_app/domain/models/user.dart';
```

### ❌ TODOs Mal Formatados
```dart
// ❌ ERRADO - Formato incorreto
// TODO: Implementar feature
// ToDo: Fix this
// FIXME - Corrigir bug

// ✅ CORRETO - Flutter style
// TODO(username): Implementar feature - https://github.com/issue/123
// TODO(autocore): Corrigir bug crítico no heartbeat
```

### ❌ APIs Deprecated
```dart
// ❌ ERRADO - APIs deprecated do Flutter 3.32+
color.withOpacity(0.5)              // deprecated
logger.v('verbose')                 // deprecated no Logger
DateTimeFormat.dateAndTime          // deprecated

// ✅ CORRETO - APIs atuais
color.withValues(alpha: 0.5)        // mantém precisão de cor
logger.t('trace')                    // trace ao invés de verbose
DateTimeFormat.onlyTimeAndSinceStart // formato atual
```

### ❌ Type Inference Falha
```dart
// ❌ ERRADO - Tipo não pode ser inferido
Future.delayed(Duration(seconds: 1));
ref.watch(provider);
list.map(Color).toList();

// ✅ CORRETO - Tipos explícitos
Future.delayed<void>(Duration(seconds: 1));
ref.watch<ThemeModel>(themeProvider);
list.map<Color>((value) => Color(value)).toList();
```

### ❌ Ordenação de Imports Incorreta
```dart
// ❌ ERRADO - Desordenado
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:autocore_app/app.dart';
import 'dart:convert';

// ✅ CORRETO - Ordem correta
import 'dart:async';                    // 1º Dart SDK
import 'dart:convert';

import 'package:flutter/material.dart';  // 2º Flutter/packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:autocore_app/app.dart';  // 3º Nosso package
import 'package:autocore_app/core/theme.dart';
```

### ❌ Const Constructors Não Usados
```dart
// ❌ ERRADO - Sem const
return Container(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
);

// ✅ CORRETO - Use const onde possível
return Container(
  padding: const EdgeInsets.all(16),
  child: const Text('Hello'),
);
```

### ❌ Variáveis Não Usadas
```dart
// ❌ ERRADO - Variável não usada
} catch (e, stack) {  // stack não é usada
  print('Error: $e');
}

// ✅ CORRETO - Remova se não usar
} catch (e) {
  AppLogger.error('Error', error: e);
}

// ✅ OU - Use se necessário
} catch (e, stack) {
  AppLogger.error('Error', error: e, stackTrace: stack);
}
```

### ❌ Métodos/Variáveis Privados Não Usados
```dart
// ❌ ERRADO - Método privado não usado
void _unusedMethod() {
  // código
}

// ✅ CORRETO - Comente com TODO se for usar depois
// TODO(autocore): Descomentar quando implementar feature X
// void _futureMethod() {
//   // código
// }
```

### ❌ Usar print() ou debugPrint()
```dart
// ❌ ERRADO - print direto
print('Debug message');
debugPrint('Error: $e');

// ✅ CORRETO - Use AppLogger
AppLogger.debug('Debug message');
AppLogger.error('Error', error: e);
```

### ❌ NUNCA Use Ignore Statements
```dart
// ❌ ERRADO - Nunca ignore warnings
// ignore: unused_element
void _myMethod() {}

// ignore_for_file: unused_import

// ✅ CORRETO - Corrija o problema
// Remova código não usado ou comente com TODO

// TODO(autocore): Descomentar quando implementar feature X
// void _futureMethod() {}
```

---

## ✅ O QUE FAZER (Boas Práticas)

### ✅ Use AppLogger ao Invés de Print
```dart
// ❌ ERRADO
print('Debug message');
debugPrint('Info');

// ✅ CORRETO
AppLogger.debug('Debug message');
AppLogger.info('Operação completada');
AppLogger.error('Erro crítico', error: e, stackTrace: stack);
AppLogger.performance('loadData', duration);
```

### ✅ Heartbeat Obrigatório para Momentâneos
```dart
// ✅ SEMPRE use HeartbeatService para botões momentâneos
class BuzinaButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MomentaryButton(  // Widget com heartbeat embutido
      deviceUuid: 'esp32-001',
      channel: 5,
      label: 'Buzina',
      icon: Icons.volume_up,
    );
  }
}

// NUNCA faça botão momentâneo sem heartbeat!
```

### ✅ Dispose Sempre
```dart
class _MyWidgetState extends State<MyWidget> {
  late final StreamController _controller;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _controller = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {});
  }
  
  @override
  void dispose() {
    _timer?.cancel();        // SEMPRE cancele timers
    _controller.close();     // SEMPRE feche streams
    super.dispose();         // SEMPRE chame super.dispose()
  }
}
```

### ✅ Null Safety Correto
```dart
// ✅ Use ? para nullable
String? getName() => _name;

// ✅ Use ! com cuidado (apenas quando CERTEZA que não é null)
final name = getName()!; // Perigoso!

// ✅ Prefira null-aware operators
final name = getName() ?? 'Sem nome';
final length = getName()?.length ?? 0;

// ✅ Use late com cuidado
late final TextEditingController controller; // Inicialize no initState
```

---

## 📦 Constantes do Projeto

### API Endpoints
```dart
// core/constants/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'http://autocore.local:8081';
  static const String wsUrl = 'ws://autocore.local:8081/ws';
  
  // Config
  static const String config = '/api/config';
  static const String screens = '/api/screens';
  
  // Macros
  static const String macros = '/api/macros';
  static String executeMacro(int id) => '/api/macros/$id/execute';
  
  // Devices
  static const String devices = '/api/devices';
  static String deviceStatus(String id) => '/api/devices/$id/status';
}
```

### MQTT Topics
```dart
// core/constants/mqtt_topics.dart
class MqttTopics {
  static const String broker = 'autocore.local';
  static const int port = 1883;
  
  // Prefixos
  static const String prefix = 'autocore';
  
  // Telemetria
  static const String telemetry = '$prefix/telemetry/+/status';
  static const String battery = '$prefix/telemetry/+/battery';
  static const String safety = '$prefix/telemetry/+/safety';
  
  // Comandos
  static String relaySet(String uuid) => '$prefix/devices/$uuid/relays/set';
  static String relayHeartbeat(String uuid) => '$prefix/devices/$uuid/relays/heartbeat';
  
  // Estados
  static const String states = '$prefix/states/+';
}
```

### Heartbeat Config
```dart
// core/constants/heartbeat_config.dart
class HeartbeatConfig {
  // Timings críticos de segurança
  static const Duration interval = Duration(milliseconds: 500);
  static const Duration timeout = Duration(milliseconds: 1000);
  static const int maxRetries = 3;
  
  // Canais que DEVEM usar heartbeat
  static const List<String> momentaryChannels = [
    'buzina',
    'guincho_in',
    'guincho_out',
    'partida',
    'lampejo',
  ];
}
```

---

## 🛠️ Utilitários e Extensions

### Context Extensions
```dart
// Sempre disponível via import de context_extensions.dart
context.acTheme           // Tema atual
context.primaryColor       // Cor primária
context.screenWidth        // Largura da tela
context.isMobile          // É mobile?
context.spacingMd         // Espaçamento médio
```

### Widget Extensions
```dart
// Facilita composição
myWidget.withPadding(EdgeInsets.all(16))
myWidget.centered()
myWidget.expanded(flex: 2)
```

### String Extensions para Logs
```dart
'Operação completada'.logInfo();
'Erro crítico'.logError();
'Debug info'.logDebug();
```

---

## 🏗️ Arquitetura e Organização

### Estrutura de Pastas
```
lib/
├── core/           # Núcleo compartilhado
├── domain/         # Regras de negócio
├── infrastructure/ # Implementações
└── features/       # Funcionalidades/Telas
```

### Padrão de Nomenclatura
- **Arquivos**: snake_case.dart
- **Classes**: PascalCase
- **Variáveis**: camelCase
- **Constantes**: SCREAMING_SNAKE_CASE ou lowerCamelCase
- **Privadas**: _comUnderscore

### Providers (Riverpod)
```dart
// SEMPRE typed providers
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeModel>((ref) {
  return ThemeNotifier();
});

// NUNCA dynamic providers
final badProvider = Provider((ref) => something); // ❌
```

---

## 🧪 Testes

### Nomenclatura de Testes
```dart
void main() {
  group('HeartbeatService', () {
    test('should start heartbeat with 500ms interval', () {
      // Arrange
      final service = HeartbeatService(mockMqtt);
      
      // Act
      service.startMomentary('device1', 5);
      
      // Assert
      expect(service.isActive('device1', 5), isTrue);
    });
  });
}
```

---

## 🔧 Comandos Flutter Importantes

### Análise e Correção
```bash
# SEMPRE execute antes de commitar
flutter analyze

# Corrige automaticamente alguns problemas
dart fix --apply

# Formata código
dart format .

# Limpa build antigo
flutter clean

# Atualiza dependências
flutter pub get
```

### Build e Deploy
```bash
# Build APK para Android
flutter build apk --release

# Build para iOS
flutter build ios --release

# Build web
flutter build web --release
```

## 🚨 Checklist Antes de Commitar

- [ ] Rodou `flutter analyze` sem erros?
- [ ] Imports estão ordenados corretamente?
- [ ] TODOs seguem formato `// TODO(username):`?
- [ ] Usou const onde possível?
- [ ] Implementou dispose() onde necessário?
- [ ] Botões momentâneos têm heartbeat?
- [ ] Usou AppLogger ao invés de print?
- [ ] Tipos genéricos estão explícitos?
- [ ] Removeu código morto e variáveis não usadas?
- [ ] Comentou métodos não usados com TODO ao invés de deletar?
- [ ] Verificou se não há ignore statements no código?

---

## 📝 Snippets Úteis

### Stateful Widget com Dispose
```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
  
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Inicialização
  }
  
  @override
  void dispose() {
    // Limpeza
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Consumer Widget (Riverpod)
```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Container();
  }
}
```

---

**IMPORTANTE**: Este documento é a fonte da verdade para padrões Flutter no projeto AutoCore. Mantenha-o atualizado e consulte sempre!