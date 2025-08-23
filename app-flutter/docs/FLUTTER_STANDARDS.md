# 📱 Padrões de Desenvolvimento Flutter - AutoCore

## 📋 Visão Geral

Este documento estabelece os padrões de desenvolvimento Flutter para o projeto AutoCore, baseado na análise de 96 issues encontradas pelo `flutter analyze`. Estes padrões devem ser seguidos por todos os desenvolvedores e agentes automatizados.

## 🎯 Prioridades de Correção

### 🔴 Crítico (Errors - 1 issue)
1. **undefined_method**: Atualizar dependências para compatibilidade

### 🟡 Alto (Warnings - 5 issues)
1. **inference_failure_on_instance_creation**: Especificar tipos genéricos
2. **inference_failure_on_function_return_type**: Declarar tipos de retorno
3. **avoid_catching_errors**: Capturar exceções específicas

### 🟢 Médio (Info - 90 issues)
1. **constant_identifier_names**: Usar lowerCamelCase para constantes
2. **prefer_relative_imports**: Usar imports de package
3. **prefer_const_constructors**: Adicionar const onde possível

## 📚 1. Convenções de Nomenclatura

### 1.1 Constantes (constant_identifier_names)

❌ **ERRADO**:
```dart
const String MQTT_BROKER = 'autocore.local';
const int MAX_RETRIES = 3;
const Duration HEARTBEAT_INTERVAL = Duration(milliseconds: 500);
```

✅ **CORRETO**:
```dart
const String mqttBroker = 'autocore.local';
const int maxRetries = 3;
const Duration heartbeatInterval = Duration(milliseconds: 500);
```

**Exceção**: Enums e classes de constantes agrupadas podem usar UPPER_CASE quando representam códigos de erro ou protocolo:
```dart
class MqttErrorCode {
  static const String mqtt001 = 'MQTT_001'; // Código do protocolo
}
```

### 1.2 Classes e Tipos

✅ **Padrão**:
```dart
class AutoCoreWidget { }      // PascalCase
typedef JsonMap = Map<String, dynamic>;  // PascalCase
enum ConnectionState { }      // PascalCase
```

### 1.3 Variáveis e Métodos

✅ **Padrão**:
```dart
String deviceUuid = 'esp32-001';  // lowerCamelCase
void sendHeartbeat() { }          // lowerCamelCase
bool isConnected = false;         // lowerCamelCase
```

## 📦 2. Organização de Imports

### 2.1 Ordem e Agrupamento

✅ **CORRETO**:
```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 3. Third-party packages
import 'package:mqtt_client/mqtt_client.dart';
import 'package:logger/logger.dart';

// 4. Nosso package (sempre use package imports)
import 'package:autocore_app/core/constants/mqtt_protocol.dart';
import 'package:autocore_app/core/models/relay_command.dart';
import 'package:autocore_app/infrastructure/services/mqtt_service.dart';
```

### 2.2 Package vs Relative Imports

❌ **ERRADO** (em lib/):
```dart
import '../../core/models/device.dart';
import '../services/mqtt_service.dart';
```

✅ **CORRETO**:
```dart
import 'package:autocore_app/core/models/device.dart';
import 'package:autocore_app/services/mqtt_service.dart';
```

**Exceção**: Use imports relativos apenas em tests/:
```dart
// Em test/widget_test.dart
import '../lib/main.dart'; // OK em testes
```

## 🎨 3. Uso de Const

### 3.1 Widgets Constantes

❌ **ERRADO**:
```dart
return Container(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
);
```

✅ **CORRETO**:
```dart
return Container(
  padding: const EdgeInsets.all(16),
  child: const Text('Hello'),
);
```

### 3.2 Constructors Constantes

✅ **CORRETO**:
```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key}); // Constructor const
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox(  // Widget const
      height: 50,
      child: Text('Const Widget'),
    );
  }
}
```

## 🔍 4. Type Safety e Inference

### 4.1 Tipos Genéricos Explícitos

❌ **ERRADO**:
```dart
final controller = StreamController.broadcast();
final list = [];
final map = {};
```

✅ **CORRETO**:
```dart
final controller = StreamController<String>.broadcast();
final list = <String>[];
final map = <String, dynamic>{};
```

### 4.2 Tipos de Retorno

❌ **ERRADO**:
```dart
getValue() {
  return 'value';
}
```

✅ **CORRETO**:
```dart
String getValue() {
  return 'value';
}

Future<bool> checkConnection() async {
  return true;
}
```

### 4.3 Callbacks e Functions

❌ **ERRADO**:
```dart
Function onTap;
var callback;
```

✅ **CORRETO**:
```dart
void Function()? onTap;
void Function(String value)? onChanged;
Future<void> Function(int id)? onDelete;
```

## 🚫 5. Tratamento de Erros

### 5.1 Evitar Catch Genérico

❌ **ERRADO**:
```dart
try {
  await connectMqtt();
} catch (e) {  // Muito genérico
  print(e);
}
```

✅ **CORRETO**:
```dart
try {
  await connectMqtt();
} on SocketException catch (e) {
  AppLogger.error('Network error', error: e);
} on TimeoutException catch (e) {
  AppLogger.error('Connection timeout', error: e);
} catch (e, stack) {
  AppLogger.error('Unexpected error', error: e, stackTrace: stack);
}
```

### 5.2 Nunca Usar Print

❌ **ERRADO**:
```dart
print('Debug: $value');
debugPrint('Error: $error');
```

✅ **CORRETO**:
```dart
AppLogger.debug('Debug value: $value');
AppLogger.error('Operation failed', error: error);
AppLogger.info('Connected successfully');
```

## 📝 6. TODOs e Comentários

### 6.1 Formato Flutter para TODOs

❌ **ERRADO**:
```dart
// TODO: Implementar feature
// FIXME: Corrigir bug
```

✅ **CORRETO**:
```dart
// TODO(leechardes): Implementar heartbeat - https://github.com/autocore/issues/123
// FIXME(team): Resolver timeout em conexões lentas
// HACK(temp): Workaround até fix do package
```

### 6.2 Documentação de Código

✅ **CORRETO**:
```dart
/// Serviço de heartbeat para botões momentâneos.
/// 
/// Mantém comunicação constante com ESP32 para evitar
/// travamento de botões em estado ligado.
/// 
/// **CRÍTICO**: Timeout de 1s para segurança.
class HeartbeatService {
  /// Inicia heartbeat para canal específico.
  /// 
  /// [deviceUuid] UUID do dispositivo ESP32
  /// [channel] Número do canal (1-8)
  /// 
  /// Retorna `true` se iniciado com sucesso.
  Future<bool> startMomentary(String deviceUuid, int channel) {
    // ...
  }
}
```

## 🧹 7. Limpeza de Recursos

### 7.1 Dispose Obrigatório

✅ **CORRETO**:
```dart
class _MyWidgetState extends State<MyWidget> {
  late final StreamController<String> _controller;
  Timer? _timer;
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _controller = StreamController<String>.broadcast();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});
    _subscription = stream.listen((_) {});
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _controller.close();
    super.dispose();
  }
}
```

## 🔄 8. Null Safety

### 8.1 Evitar Casts Inseguros

❌ **ERRADO**:
```dart
final value = json['key'] as String;  // Pode causar erro
final list = data as List<String>;     // Cast perigoso
```

✅ **CORRETO**:
```dart
final value = json['key'] as String?;
final list = List<String>.from(data as List? ?? []);

// Com validação
if (json['key'] is String) {
  final value = json['key'] as String;
}
```

### 8.2 Operadores Null-Aware

✅ **CORRETO**:
```dart
final length = text?.length ?? 0;
widget.onTap?.call();
_controller?.close();

// Null assertion apenas quando garantido
final nonNull = nullableValue!; // Use com cuidado
```

### 8.3 Evitar Null Checks Desnecessários (!)

O Dart é inteligente com null safety. **NUNCA** use `!` quando o compilador já sabe que o valor não é null.

❌ **ERRADO - Null checks desnecessários**:
```dart
// 1. Em variáveis non-nullable
String name = "Flutter";
print(name!.length);  // Warning: unnecessary null check

// 2. Após verificar null (smart cast)
if (user != null) {
  print(user!.name);  // Warning: Dart já sabe que não é null
}

// 3. Em late variables inicializadas
late String config;
config = loadConfig();
print(config!);  // Warning: late var já foi inicializada

// 4. Em parâmetros required
void processData({required String data}) {
  print(data!.length);  // Warning: required nunca é null
}

// 5. Após cast para tipo non-nullable
final items = response.data as List<String>;
print(items!.length);  // Warning: cast já garante non-nullable

// 6. Em variáveis final/const
final String apiUrl = getApiUrl();
makeRequest(apiUrl!);  // Warning: final String não pode ser null
```

✅ **CORRETO - Sem null checks redundantes**:
```dart
// 1. Variáveis non-nullable não precisam de !
String name = "Flutter";
print(name.length);

// 2. Smart cast automático após verificação
if (user != null) {
  print(user.name);  // Dart faz smart cast
}

// 3. Late variables não precisam de ! após inicialização
late String config;
config = loadConfig();
print(config);

// 4. Parâmetros required são sempre non-null
void processData({required String data}) {
  print(data.length);
}

// 5. Cast já define o tipo
final items = response.data as List<String>;
print(items.length);

// 6. Tipos non-nullable são garantidos
final String apiUrl = getApiUrl();
makeRequest(apiUrl);
```

### 8.4 Quando Usar ! (Null Assertion)

Use `!` **APENAS** quando você tem certeza que o valor não é null, mas o Dart não consegue inferir:

✅ **USO CORRETO de !**:
```dart
// 1. Quando você validou externamente
Map<String, String?> cache = {};
if (cache.containsKey('token')) {
  final token = cache['token']!;  // OK - você garantiu que existe
}

// 2. Em testes quando você controla os dados
test('should parse response', () {
  final response = mockResponse();
  expect(response.data!.length, 3);  // OK em testes
});

// 3. Após validação complexa
if (validateConfig(config)) {
  // validateConfig garante que config.apiUrl não é null
  final url = config.apiUrl!;  // OK se validado
}
```

### 8.5 Regras de Ouro para Null Safety

1. **Prefira tipos non-nullable** sempre que possível
2. **Use `?` para valores opcionais** ao invés de late
3. **Evite `!` exceto quando absolutamente necessário**
4. **Confie no smart cast** do Dart
5. **Use `??` e `?.` para null-aware operations**
6. **Valide early, use safely** - valide nulls no início

## 🎯 9. Performance

### 9.1 Prefer Final

✅ **CORRETO**:
```dart
for (final item in items) {  // final ao invés de var
  processItem(item);
}

final result = calculate();  // Imutável
const duration = Duration(seconds: 1);  // Compile-time constant
```

### 9.2 Evitar Rebuilds Desnecessários

✅ **CORRETO**:
```dart
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});  // const constructor
  
  @override
  Widget build(BuildContext context) {
    return const ExpensiveChild();  // const child
  }
}

// Use keys para preservar estado
ListView.builder(
  itemBuilder: (context, index) {
    return MyItem(
      key: ValueKey(items[index].id),  // Preserve estado
      data: items[index],
    );
  },
);
```

## 📊 10. Widgets e Arquitetura

### 10.1 Separação de Responsabilidades

✅ **CORRETO**:
```dart
// Widget de apresentação
class ButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  
  const ButtonWidget({
    super.key,
    required this.label,
    this.onPressed,
  });
}

// Lógica de negócio
class ButtonController {
  Future<void> handlePress() async {
    await sendCommand();
  }
}
```

### 10.2 Composição sobre Herança

✅ **CORRETO**:
```dart
// Prefira composição
class CustomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: customDecoration,
      child: ElevatedButton(...),  // Reutiliza widget existente
    );
  }
}
```

## 🔧 11. Configuração do Projeto

### 11.1 analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "test/**"
    - "docs/**"
  
  errors:
    invalid_annotation_target: ignore
    undefined_prefixed_name: ignore

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - avoid_unnecessary_containers
    - constant_identifier_names
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_relative_imports: false  # Usamos package imports
    - sort_pub_dependencies
    - unnecessary_this
    - use_key_in_widget_constructors
```

### 11.2 pubspec.yaml Dependencies

```yaml
dependencies:
  mqtt_client: ^10.0.0  # Versão com startNotClean()
  logger: ^2.0.0
  
dev_dependencies:
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
```

## 🚀 12. Scripts de Validação

### 12.1 Comando de Análise

```bash
# Análise completa
flutter analyze

# Análise com fix automático
dart fix --apply

# Verificar apenas erros
flutter analyze --no-fatal-infos

# CI/CD pipeline
flutter analyze --no-fatal-warnings --no-fatal-infos || exit 1
```

### 12.2 Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 Running Flutter analyze..."
flutter analyze --no-fatal-infos

if [ $? -ne 0 ]; then
  echo "❌ Flutter analyze failed. Fix issues before committing."
  exit 1
fi

echo "✅ Flutter analyze passed!"
```

## 📈 13. Métricas de Qualidade

### Targets

| Métrica | Target | Atual |
|---------|--------|-------|
| Errors | 0 | 1 |
| Warnings | 0 | 5 |
| Info (críticos) | < 20 | 90 |
| Code Coverage | > 80% | - |
| Cyclomatic Complexity | < 10 | - |

### Progresso de Correção

- [x] Documentação de padrões criada
- [ ] Atualizar mqtt_client para v10.0.0+
- [ ] Converter UPPER_CASE para lowerCamelCase
- [ ] Converter relative imports para package imports
- [ ] Adicionar const constructors
- [ ] Implementar type safety completo
- [ ] Configurar CI/CD com análise

## 🎓 14. Referências

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://flutter.dev/docs/development/style-guide)
- [Dart Linter Rules](https://dart.dev/tools/linter-rules)
- [AutoCore MQTT Protocol v2.2.0](../protocolo-mqtt-completo.md)

## 📝 15. Checklist para Code Review

- [ ] Nomes seguem lowerCamelCase para constantes?
- [ ] Imports usam package: ao invés de relativos?
- [ ] Widgets têm const onde possível?
- [ ] Tipos genéricos são explícitos?
- [ ] Recursos são liberados no dispose()?
- [ ] Erros são tratados especificamente?
- [ ] TODOs seguem formato Flutter?
- [ ] Não há prints no código?
- [ ] Null safety está correto?
- [ ] **Não há null checks (!) desnecessários?**
- [ ] Performance foi considerada?

---

**Última atualização**: 2025-08-23
**Versão**: 1.2.0
**Conformidade**: Flutter 3.x / Dart 3.x

## 🆕 16. Padrões Específicos do Projeto AutoCore

### 16.1 Material Colors Nullable

⚠️ **PROBLEMA ENCONTRADO**:
```dart
// Colors.grey[600] retorna Color? mas componentes esperam Color
_buildStatusRow('Status:', text, Colors.grey[600]); // ERROR
```

✅ **SOLUÇÃO**:
```dart
// Use null assertion quando garantido que a cor existe
_buildStatusRow('Status:', text, Colors.grey[600]!); // OK

// Ou prefira cores com fallback
_buildStatusRow('Status:', text, Colors.grey[600] ?? Colors.grey); // MELHOR
```

### 16.2 Widget Lists com Nullable

⚠️ **PROBLEMA ENCONTRADO**:
```dart
children: [
  if (widget.leading != null) ...[
    widget.leading,  // ERROR: Widget? em List<Widget>
  ],
],
```

✅ **SOLUÇÃO**:
```dart
children: [
  if (widget.leading != null) ...[
    widget.leading!,  // OK: garantido não-null pelo if
  ],
],
```

### 16.3 Switch Statements Exaustivos

⚠️ **PROBLEMA ENCONTRADO**:
```dart
switch (type) {
  case TypeA:
    return valueA;
  case TypeB:
    return valueB;
}
return null; // Dead code - switch já é exaustivo
```

✅ **SOLUÇÃO**:
```dart
switch (type) {
  case TypeA:
    return valueA;
  case TypeB:
    return valueB;
}
// Sem return adicional - Dart infere que é exaustivo
```

### 16.4 Null Assertion Após Verificação

⚠️ **USO INCONSISTENTE** encontrado no projeto:
```dart
if (action.condition != null) {
  await _evaluateCondition(action.condition); // ERROR: ainda é nullable
}

// Mas em outros lugares:
if (widget.telemetryKey != null) {
  use(widget.telemetryKey!); // Uso correto após verificação
}
```

✅ **PADRÃO CONSISTENTE**:
```dart
// Sempre use ! após verificação if != null
if (action.condition != null) {
  await _evaluateCondition(action.condition!); // OK
}

if (widget.telemetryKey != null) {
  use(widget.telemetryKey!); // OK
}
```

### 16.5 Smart Cast vs Explicit Null Checks

O projeto teve 2 casos de null checks desnecessários que foram corrigidos:

❌ **ANTES (com warning)**:
```dart
if (widget.item.telemetryKey != null) {
  if (widget.relayStates.containsKey(widget.item.telemetryKey!)) {
    // Warning: unnecessary null check após verificação
  }
}
```

✅ **DEPOIS (sem warning)**:
```dart
if (widget.item.telemetryKey != null) {
  if (widget.relayStates.containsKey(widget.item.telemetryKey)) {
    // Smart cast automático - sem ! necessário
  }
}
```

### 📝 Changelog
- **v1.2.0** (2025-08-23): Adicionada seção 16 com padrões específicos do AutoCore
- **v1.1.0** (2025-08-23): Adicionada seção 8.3-8.5 sobre null checks desnecessários  
- **v1.0.0** (2025-08-22): Versão inicial com 15 seções de padrões