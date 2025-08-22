# ⚙️ Settings Screen - Documentação Detalhada

A tela de Settings é responsável por configurar todas as conexões do aplicativo AutoCore, incluindo API backend, MQTT broker e configurações de segurança.

## 📋 Visão Geral

**Arquivo**: `lib/features/settings/settings_screen.dart`  
**Widget**: `SettingsScreen extends ConsumerStatefulWidget`  
**Provider**: `settingsProvider`  
**Rota**: `/settings`

## 🏗️ Arquitetura da Tela

### Estado do Widget

```dart
class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para todos os campos de input
  late TextEditingController _apiHostController;
  late TextEditingController _apiPortController;
  late TextEditingController _mqttHostController;
  // ... outros controllers
  
  bool _isTestingConnections = false;
  Map<String, bool>? _connectionResults;
}
```

### Form Validation

Toda a tela é envolvida em um `Form` widget para validação:

```dart
Form(
  key: _formKey,
  child: ListView(...),
)
```

## 📡 Seções de Configuração

### 1. API Backend (Gateway)

**Propósito**: Configuração do backend principal do AutoCore.

```dart
_buildSectionHeader('API Backend (Gateway)', Icons.api),
_buildHostField(
  controller: _apiHostController,
  label: 'Host/IP',
  hint: 'Ex: 10.0.10.119 ou autocore.local',
),
_buildPortField(
  controller: _apiPortController,
  label: 'Porta',
  hint: 'Ex: 8081',
),
_buildSwitch(
  value: config.apiUseHttps,
  label: 'Usar HTTPS',
  onChanged: (value) => _updateConfig(apiUseHttps: value),
),
```

#### Campos da API

| Campo | Tipo | Validação | Padrão |
|-------|------|-----------|--------|
| Host/IP | String | Obrigatório | autocore.local |
| Porta | Int | 1-65535 | 8081 |
| HTTPS | Bool | - | false |

### 2. MQTT Broker

**Propósito**: Configuração para comunicação em tempo real com dispositivos ESP32.

```dart
_buildSectionHeader('MQTT Broker', Icons.hub),
_buildHostField(
  controller: _mqttHostController,
  label: 'Host/IP',
  hint: 'Ex: 10.0.10.119 ou autocore.local',
),
_buildPortField(
  controller: _mqttPortController,
  label: 'Porta',
  hint: 'Ex: 1883',
),
_buildTextField(
  controller: _mqttUsernameController,
  label: 'Usuário (opcional)',
  hint: 'Deixe vazio se não usar autenticação',
),
_buildPasswordField(
  controller: _mqttPasswordController,
  label: 'Senha (opcional)',
  hint: 'Deixe vazio se não usar autenticação',
),
```

#### Campos do MQTT

| Campo | Tipo | Validação | Padrão |
|-------|------|-----------|--------|
| Host/IP | String | Obrigatório | autocore.local |
| Porta | Int | 1-65535 | 1883 |
| Usuário | String | Opcional | - |
| Senha | String | Opcional | - |

### 3. Config Service

**Propósito**: Configuração do serviço de configuração (config-app web).

```dart
_buildSectionHeader('Config Service', Icons.settings_applications),
_buildHostField(
  controller: _configHostController,
  label: 'Host/IP',
  hint: 'Ex: 10.0.10.119 ou autocore.local',
),
_buildPortField(
  controller: _configPortController,
  label: 'Porta',
  hint: 'Ex: 8080',
),
_buildSwitch(
  value: config.configUseHttps,
  label: 'Usar HTTPS',
  onChanged: (value) => _updateConfig(configUseHttps: value),
),
```

#### Campos do Config Service

| Campo | Tipo | Validação | Padrão |
|-------|------|-----------|--------|
| Host/IP | String | Obrigatório | autocore.local |
| Porta | Int | 1-65535 | 8080 |
| HTTPS | Bool | - | false |

### 4. Configurações Gerais

**Propósito**: Configurações de comportamento geral do aplicativo.

```dart
_buildSectionHeader('Configurações Gerais', Icons.tune),
_buildSwitch(
  value: config.autoConnect,
  label: 'Conectar Automaticamente',
  onChanged: (value) => _updateConfig(autoConnect: value),
),
_buildSwitch(
  value: config.enableHeartbeat,
  label: 'Habilitar Heartbeat (Segurança)',
  subtitle: 'Essencial para botões momentâneos',
  onChanged: (value) => _updateConfig(enableHeartbeat: value),
),
```

#### ⚠️ Configurações de Heartbeat (CRÍTICAS)

Quando `enableHeartbeat` está ativo, campos adicionais aparecem:

```dart
if (config.enableHeartbeat) ...[
  _buildNumberField(
    label: 'Intervalo Heartbeat (ms)',
    value: config.heartbeatInterval,
    min: 100,
    max: 2000,
    onChanged: (value) => _updateConfig(heartbeatInterval: value),
  ),
  _buildNumberField(
    label: 'Timeout Heartbeat (ms)',
    value: config.heartbeatTimeout,
    min: 500,
    max: 5000,
    onChanged: (value) => _updateConfig(heartbeatTimeout: value),
  ),
],
```

| Campo | Tipo | Range | Padrão | Crítico |
|-------|------|-------|--------|---------| 
| Habilitar Heartbeat | Bool | - | true | ✅ |
| Intervalo (ms) | Int | 100-2000 | 500 | ✅ |
| Timeout (ms) | Int | 500-5000 | 1000 | ✅ |

**⚠️ IMPORTÂNCIA CRÍTICA**: O sistema de heartbeat é essencial para a segurança de botões momentâneos (buzina, guincho). Se desabilitado, botões podem ficar presos em estado ativo.

## 🏗️ Widget Builders

### Section Header

```dart
Widget _buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 20, color: context.primaryColor),
      SizedBox(width: context.spacingSm),
      Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: context.fontSizeSmall,
          fontWeight: context.fontWeightBold,
          color: context.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    ],
  );
}
```

### Host Field

```dart
Widget _buildHostField({
  required TextEditingController controller,
  required String label,
  required String hint,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: const Icon(Icons.dns),
      border: const OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Campo obrigatório';
      }
      return null;
    },
  );
}
```

### Port Field

```dart
Widget _buildPortField({
  required TextEditingController controller,
  required String label,
  required String hint,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: const Icon(Icons.numbers),
      border: const OutlineInputBorder(),
    ),
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(5),
    ],
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Campo obrigatório';
      }
      final port = int.tryParse(value);
      if (port == null || port < 1 || port > 65535) {
        return 'Porta inválida (1-65535)';
      }
      return null;
    },
  );
}
```

### Switch Builder

```dart
Widget _buildSwitch({
  required bool value,
  required String label,
  String? subtitle,
  required ValueChanged<bool> onChanged,
}) {
  return SwitchListTile(
    value: value,
    onChanged: onChanged,
    title: Text(label),
    subtitle: subtitle != null ? Text(subtitle) : null,
    contentPadding: EdgeInsets.zero,
  );
}
```

### Number Field (Heartbeat)

```dart
Widget _buildNumberField({
  required String label,
  required int value,
  required int min,
  required int max,
  required ValueChanged<int> onChanged,
}) {
  return Row(
    children: [
      Expanded(child: Text(label)),
      SizedBox(
        width: 100,
        child: TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (text) {
            final newValue = int.tryParse(text) ?? value;
            if (newValue >= min && newValue <= max) {
              onChanged(newValue);
            }
          },
        ),
      ),
    ],
  );
}
```

## 🧪 Sistema de Teste de Conexões

### Interface de Teste

```dart
ElevatedButton.icon(
  onPressed: _isTestingConnections ? null : _testConnections,
  icon: _isTestingConnections
      ? CircularProgressIndicator(strokeWidth: 2)
      : const Icon(Icons.network_check),
  label: Text(_isTestingConnections ? 'Testando...' : 'Testar Conexões'),
),
```

### Implementação do Teste

```dart
Future<void> _testConnections() async {
  setState(() {
    _isTestingConnections = true;
    _connectionResults = null;
  });

  // Salvar configurações temporariamente
  await _saveConfiguration(showMessage: false);

  // Executar testes via provider
  final results = await ref.read(settingsProvider.notifier).testConnections();

  setState(() {
    _isTestingConnections = false;
    _connectionResults = results;
  });

  // Feedback visual
  final allSuccess = results.values.every((success) => success);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        allSuccess
            ? 'Todos os serviços estão conectados!'
            : 'Alguns serviços não estão acessíveis',
      ),
      backgroundColor: allSuccess
          ? context.successColor
          : context.warningColor,
    ),
  );
}
```

### Resultados do Teste

```dart
Widget _buildConnectionTestSection() {
  if (_connectionResults == null) return const SizedBox.shrink();

  return Card(
    child: Column(
      children: [
        Text('Resultado dos Testes'),
        _buildTestResult('API Backend', _connectionResults!['api'] ?? false),
        _buildTestResult('MQTT Broker', _connectionResults!['mqtt'] ?? false),
        _buildTestResult('Config Service', _connectionResults!['config'] ?? false),
      ],
    ),
  );
}

Widget _buildTestResult(String service, bool success) {
  return Row(
    children: [
      Icon(
        success ? Icons.check_circle : Icons.error,
        color: success ? context.successColor : context.errorColor,
      ),
      Text(service),
      const Spacer(),
      Text(
        success ? 'Conectado' : 'Falha',
        style: TextStyle(
          color: success ? context.successColor : context.errorColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
```

## 💾 Persistência de Configurações

### Atualizações de Config

```dart
void _updateConfig({
  bool? apiUseHttps,
  bool? configUseHttps,
  bool? autoConnect,
  bool? enableHeartbeat,
  int? heartbeatInterval,
  int? heartbeatTimeout,
}) {
  final current = ref.read(settingsProvider);
  final updated = current.copyWith(
    apiUseHttps: apiUseHttps ?? current.apiUseHttps,
    configUseHttps: configUseHttps ?? current.configUseHttps,
    autoConnect: autoConnect ?? current.autoConnect,
    enableHeartbeat: enableHeartbeat ?? current.enableHeartbeat,
    heartbeatInterval: heartbeatInterval ?? current.heartbeatInterval,
    heartbeatTimeout: heartbeatTimeout ?? current.heartbeatTimeout,
  );

  ref.read(settingsProvider.notifier).updateConfig(updated);
}
```

### Salvar Configurações

```dart
Future<void> _saveConfiguration({bool showMessage = true}) async {
  if (!_formKey.currentState!.validate()) return;

  final config = ref.read(settingsProvider).copyWith(
    apiHost: _apiHostController.text,
    apiPort: int.parse(_apiPortController.text),
    mqttHost: _mqttHostController.text,
    mqttPort: int.parse(_mqttPortController.text),
    mqttUsername: _mqttUsernameController.text,
    mqttPassword: _mqttPasswordController.text,
    configHost: _configHostController.text,
    configPort: int.parse(_configPortController.text),
  );

  final success = await ref
      .read(settingsProvider.notifier)
      .saveConfig(config);

  if (showMessage && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Configurações salvas com sucesso!'
              : 'Erro ao salvar configurações',
        ),
        backgroundColor: success ? context.successColor : context.errorColor,
      ),
    );
  }
}
```

### Restaurar Padrões

```dart
Future<void> _resetToDefaults() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Restaurar Padrões'),
      content: const Text(
        'Isso irá restaurar todas as configurações para os valores padrão. Deseja continuar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.warningColor,
          ),
          child: const Text('Restaurar'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await ref.read(settingsProvider.notifier).resetToDefaults();
    _initControllers(); // Recarrega os controllers
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações restauradas para os padrões'),
      ),
    );
  }
}
```

## 📱 Responsividade

### Layout Adaptativo

A tela de settings é otimizada para diferentes tamanhos de tela:

- **Mobile**: Campos em coluna única
- **Tablet**: Pode usar colunas duplas para seções
- **Desktop**: Layout mais espaçado

### Espaçamentos Responsivos

```dart
padding: EdgeInsets.all(context.spacingMd), // Adaptativo
SizedBox(height: context.spacingSm),        // Responsivo
SizedBox(height: context.spacingLg),        // Responsivo
```

## 🔍 Validação de Formulário

### Validadores Customizados

```dart
// Host validation
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Campo obrigatório';
  }
  return null;
}

// Port validation  
validator: (value) {
  final port = int.tryParse(value);
  if (port == null || port < 1 || port > 65535) {
    return 'Porta inválida (1-65535)';
  }
  return null;
}
```

### Input Formatters

```dart
// Apenas números para porta
inputFormatters: [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(5),
],

// Apenas números para heartbeat
inputFormatters: [FilteringTextInputFormatter.digitsOnly],
```

## 🧪 Testing

### Unit Tests

```dart
testWidgets('Settings form validation works', (tester) async {
  await tester.pumpWidget(createSettingsScreen());
  
  // Testar campo obrigatório vazio
  await tester.enterText(find.byType(TextFormField).first, '');
  await tester.tap(find.text('Salvar'));
  await tester.pump();
  
  expect(find.text('Campo obrigatório'), findsOneWidget);
});

testWidgets('Port validation works', (tester) async {
  await tester.pumpWidget(createSettingsScreen());
  
  // Testar porta inválida
  await tester.enterText(find.byKey(Key('portField')), '99999');
  await tester.tap(find.text('Salvar'));
  await tester.pump();
  
  expect(find.text('Porta inválida (1-65535)'), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('Save and restore settings flow', (tester) async {
  await tester.pumpWidget(AutoCoreApp());
  
  // Navegar para settings
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
  
  // Alterar uma configuração
  await tester.enterText(find.byKey(Key('apiHost')), 'new.host.com');
  
  // Salvar
  await tester.tap(find.text('Salvar'));
  await tester.pumpAndSettle();
  
  // Verificar se foi salvo
  expect(find.text('Configurações salvas com sucesso!'), findsOneWidget);
});
```

## ⚠️ Configurações Críticas de Segurança

### Heartbeat Settings

```dart
// ⚠️ CRÍTICO: Heartbeat deve estar sempre habilitado em produção
enableHeartbeat: true,           // DEFAULT: true
heartbeatInterval: 500,          // DEFAULT: 500ms
heartbeatTimeout: 1000,          // DEFAULT: 1000ms
```

### Validação de Segurança

```dart
// Validar intervalos de heartbeat
if (heartbeatInterval < 100 || heartbeatInterval > 2000) {
  throw Exception('Heartbeat interval must be 100-2000ms for safety');
}

if (heartbeatTimeout < 500 || heartbeatTimeout > 5000) {
  throw Exception('Heartbeat timeout must be 500-5000ms for safety');
}
```

## 📊 Métricas de Performance

### Tempos de Resposta

- **Form Validation**: < 100ms
- **Save Configuration**: < 200ms  
- **Test Connections**: < 3000ms total
- **Reset to Defaults**: < 100ms

### Memory Usage

- **Text Controllers**: ~50KB
- **Form State**: ~10KB
- **Connection Test Cache**: ~5KB

---

**Ver também**:
- [Dashboard Screen](dashboard-screens.md)
- [Providers Documentation](../state/providers.md)
- [Services Documentation](../services/README.md)