# AutoCore - App Flutter

## 📱 Visão Geral

Aplicativo móvel de controle veicular desenvolvido em Flutter com **interface 100% dinâmica configurada via JSON**. Não há telas hardcoded - toda a interface é construída dinamicamente a partir de arquivos de configuração, permitindo total customização sem necessidade de recompilação.

## 🎨 Design System

### Conceito Visual
- **Estilo**: Neumorfismo elegante inspirado em Tesla
- **Tema**: Dark mode como padrão
- **Cores principais**:
  - Background: `#1C1C1E` a `#2C2C2E`
  - Accent Blue: `#007AFF` 
  - Active Green: `#32D74B`
  - Warning Orange: `#FF9500`
  - Danger Red: `#FF3B30`

### Características do Design
- Sombras neumórficas sutis para profundidade
- Gradientes em elementos ativos
- Transições suaves e feedback háptico
- Interface otimizada para uso em movimento

## 📁 Estrutura do Projeto

```
app-flutter/
├── ui-prototype.html     # Protótipo visual HTML
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── routes.dart
│   ├── core/
│   │   ├── theme/       # Design system
│   │   ├── constants/   # Constantes do app
│   │   ├── utils/       # Utilitários
│   │   └── services/    # Serviços (MQTT, Storage)
│   ├── data/
│   │   ├── models/      # Modelos de dados
│   │   ├── providers/   # Providers de dados
│   │   └── repositories/
│   ├── presentation/
│   │   ├── screens/     # Telas do app
│   │   ├── widgets/     # Widgets reutilizáveis
│   │   └── controllers/ # Controllers GetX/Riverpod
│   └── config/
│       ├── mqtt_config.dart
│       └── app_config.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
└── pubspec.yaml
```

## 🔧 Configuração

### Requisitos
- Flutter SDK 3.10+
- Dart 2.19+
- Android Studio / VS Code
- Android SDK (min 21)
- iOS SDK (min 12.0)

### Instalação

```bash
# Clone o repositório
cd ~/Projetos/AutoCore/app-flutter

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.6.5           # ou riverpod: ^2.3.6
  
  # MQTT Communication
  mqtt_client: ^10.0.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI Components
  flutter_neumorphic: ^3.2.0
  animations: ^2.0.7
  flutter_vibrate: ^1.3.0
  
  # Utilities
  dio: ^5.3.2
  json_annotation: ^4.8.1
  equatable: ^2.0.5
```

## 🏗️ Arquitetura

### Clean Architecture
```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (Screens, Widgets, Controllers)  │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│          Domain Layer               │
│    (Use Cases, Entities, Repos)     │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│           Data Layer                │
│    (Models, Providers, Services)    │
└─────────────────────────────────────┘
```

## 🎯 Funcionalidades Principais

### 1. Dashboard
- Visualização do status do veículo
- Indicador de bateria em tempo real
- Grid de categorias de controle
- Ações rápidas configuráveis

### 2. Controle de Iluminação
- Faróis (alto/baixo)
- LEDs auxiliares
- Luzes de neblina
- Strobo e emergência

### 3. Controle do Guincho
- Operação momentânea (recolher/soltar)
- Indicador de status
- Proteção com confirmação

### 4. Controle de Tração
- Modos: 4x2, 4x4 High, 4x4 Low
- Bloqueio de diferenciais
- Seleção exclusiva

### 5. Controles Auxiliares
- Buzina (momentâneo)
- Tomada 12V
- Compressor de ar
- Rádio VHF
- Climatizador
- Som externo

## 🔄 Comunicação MQTT

### Tópicos Principais
```dart
// Publicação
autocore/devices/{deviceId}/command
autocore/relays/{relayId}/set

// Assinatura
autocore/devices/+/status
autocore/relays/+/state
autocore/can/data
autocore/config/update
```

### Exemplo de Payload
```json
{
  "device_id": "app_mobile_001",
  "command": "relay_toggle",
  "target": "relay_1",
  "value": true,
  "timestamp": "2024-01-01T12:00:00Z"
}
```

## 🎨 Componentes Reutilizáveis

### NeumorphicButton
```dart
NeumorphicButton(
  onPressed: () {},
  style: NeumorphicStyle(
    depth: 8,
    intensity: 0.7,
    color: AppColors.surface,
  ),
  child: Icon(Icons.power_settings_new),
)
```

### ControlTile
```dart
ControlTile(
  icon: Icons.lightbulb,
  label: 'Farol Alto',
  type: ControlType.toggle,
  onChanged: (value) {},
)
```

### StatusIndicator
```dart
StatusIndicator(
  label: 'Bateria',
  value: '12.8V',
  isActive: true,
)
```

## 📱 Telas Implementadas

1. **SplashScreen** - Tela inicial com logo
2. **DashboardScreen** - Painel principal
3. **LightingScreen** - Controles de iluminação
4. **WinchScreen** - Controle do guincho
5. **TractionScreen** - Modos de tração
6. **AuxiliaryScreen** - Controles auxiliares
7. **SettingsScreen** - Configurações

## 🧪 Testes

```bash
# Testes unitários
flutter test

# Testes de widget
flutter test test/widget_test.dart

# Coverage
flutter test --coverage
```

## 🚀 Build & Deploy

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
flutter build ipa
```

## 📝 Configuração Dinâmica

O app lê configurações do servidor via MQTT:
```json
{
  "screens": [
    {
      "id": 1,
      "name": "lighting",
      "title": "Iluminação",
      "items": [...]
    }
  ],
  "theme": {
    "primary_color": "#007AFF",
    "secondary_color": "#32D74B"
  }
}
```

## 🔐 Segurança

- Autenticação via PIN/Biometria
- Confirmação para ações críticas
- Timeout de sessão configurável
- Comunicação MQTT com TLS

## 📊 Monitoramento

- Logs de ações enviados ao gateway
- Telemetria de uso
- Crash reporting (Firebase Crashlytics)
- Analytics de funcionalidades

## 🤝 Contribuindo

1. Siga o padrão de código Dart
2. Escreva testes para novas funcionalidades
3. Documente mudanças significativas
4. Use conventional commits

## 📄 Licença

Proprietário - AutoCore © 2024

---

**AutoCore** - Interface móvel inteligente para controle veicular