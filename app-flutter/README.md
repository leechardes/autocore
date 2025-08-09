# 📱 AutoCore Flutter - Interface de Execução

## ⚠️ ESCOPO: Execução com Segurança Crítica

Interface móvel para **controle e execução** de comandos veiculares. Carrega configurações do backend e permite apenas **visualização e execução** de comandos.

### 🎯 O que o App FAZ:
- ✅ **EXECUTA** macros e comandos via HTTP/MQTT
- ✅ **VISUALIZA** estados em tempo real
- ✅ **HEARTBEAT** obrigatório para botões momentâneos
- ✅ **CACHEIA** configurações para uso offline

### ❌ O que o App NÃO FAZ:
- ❌ **NÃO** configura dispositivos, telas ou macros
- ❌ **NÃO** possui editores ou CRUD
- ❌ **NÃO** gerencia usuários

> **Toda configuração é feita via AutoCore Config-App web**

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

## 🔒 Sistema de Segurança - Heartbeat

### Botões Momentâneos (CRÍTICO)
Botões como **buzina**, **guincho**, **partida** e **lampejo** DEVEM usar heartbeat:

```dart
// Heartbeat a cada 500ms enquanto pressionado
HeartbeatService.startMomentary(deviceId, channel); // onPressed
HeartbeatService.stopMomentary(deviceId, channel);  // onReleased
```

**Parâmetros de Segurança:**
- **Intervalo**: 500ms entre heartbeats
- **Timeout**: 1s sem heartbeat = desligamento automático
- **Auto-release**: Ao minimizar app ou perder foco
- **Safety shutoff**: ESP32 desliga relé automaticamente

## 🎯 Funcionalidades Principais

### 1. Dashboard Principal
- **Vehicle Info** (opcional): Status, tração, bateria
- **4 Botões de Navegação**: Screens dinâmicas do backend
- **Quick Actions**: Macros configuradas (Camping, Emergência, etc)
- **Botão de Emergência**: FAB vermelho para parada total

### 2. Screens Dinâmicas
Cada screen pode ter:
- **Switches**: Liga/desliga (Farol Alto, Diferencial)
- **Tiles**: Botões de ação (Neblina, Strobo)
- **Momentâneos**: Com heartbeat (Buzina, Guincho)
- **Seleção de Modos**: Exclusivos (4x2, 4x4 High, 4x4 Low)

### 3. Execução de Comandos
- **Macros**: `POST /api/macros/{id}/execute`
- **Botões**: Via MQTT ou HTTP
- **Momentâneos**: Via MQTT com heartbeat
- **Feedback**: Háptico e visual

## 🔄 Comunicação

### Carregamento de Configuração
```dart
GET /api/config
// Retorna screens, items, macros
```

### Execução de Macros
```dart
POST /api/macros/{id}/execute
```

### Heartbeat (Momentâneos)
```dart
// Comando inicial
mqtt.publish('autocore/devices/{uuid}/relays/set', {
  "channel": 5,
  "state": true,
  "momentary": true
});

// Heartbeat a cada 500ms
mqtt.publish('autocore/devices/{uuid}/relays/heartbeat', {
  "channel": 5,
  "sequence": 1
});
```

### Estados via MQTT
```dart
// Subscribe para receber estados
autocore/telemetry/+/status
autocore/telemetry/+/safety  // Safety shutoff events
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

## 📱 Estrutura de Telas

### Tela Principal (Dashboard)
```dart
DynamicDashboard(
  vehicleInfo: VehicleInfo(),      // Opcional
  navigationButtons: [...]         // 4 screens dinâmicas
  quickActions: [...]              // Macros horizontais
  emergencyButton: true            // FAB vermelho
)
```

### Screens Dinâmicas
```dart
DynamicScreen(
  config: screenConfig,           // Do backend
  items: [
    SwitchControl(),              // Liga/desliga
    ControlTile(),                // Botões de ação
    MomentaryButton(),            // Com heartbeat!
    ModeSelector()                // Seleção exclusiva
  ]
)
```

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

## 📝 Interface Dinâmica

O app carrega configurações do backend para exibir:
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
  "macros": [
    {
      "id": 1,
      "name": "Modo Trilha",
      "description": "Ativa configuração para off-road"
    }
  ]
}
```

## 🔐 Segurança

### Crítico - Heartbeat
- **Obrigatório** para botões momentâneos
- **Auto-release** ao perder foco
- **Safety shutoff** automático no ESP32
- **Notificação** de eventos de segurança

### Geral
- Autenticação via PIN/Biometria
- Confirmação para ações críticas
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

**AutoCore Flutter** - Interface móvel de execução para controle veicular

> **IMPORTANTE**: Interface de execução com segurança crítica. Sistema de heartbeat obrigatório para botões momentâneos. Toda configuração via Config-App web.