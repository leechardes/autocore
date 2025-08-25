# 📱 AutoCore Flutter App

## 🎯 Visão Geral

Aplicativo Flutter para controle e monitoramento de dispositivos IoT (ESP32) do sistema AutoCore. Interface moderna e responsiva para interação em tempo real com dispositivos via MQTT e API REST.

**Status**: ✅ **PRODUÇÃO READY** - Zero issues, funcionalidades core completas  
**Versão**: 1.0.0  
**Última Atualização**: 25/08/2025  

### ✨ Principais Funcionalidades
- 🎛️ **Dashboard dinâmico** com widgets configuráveis via API
- 📡 **Comunicação MQTT** robusta com reconexão automática
- 🔄 **Sincronização em tempo real** de telemetria e estados
- 📱 **Interface responsiva** adaptada para múltiplos dispositivos
- 🎨 **Sistema de temas** configurável (dark/light mode)
- 💾 **Cache inteligente** para funcionamento offline
- 🔐 **Auto-registro** automático de dispositivos
- ⚡ **Performance otimizada** (APK 22MB, startup <3s)

### 🏗️ Arquitetura
- **Clean Architecture** com separação clara de responsabilidades
- **Provider pattern** para gerenciamento de estado
- **Repository pattern** para acesso a dados
- **Modular design** com features isoladas

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
├── lib/
│   ├── main.dart                     # Entry point com inicialização
│   ├── core/                         # Funcionalidades base
│   │   ├── constants/               # Constantes (API, MQTT, Device)
│   │   ├── extensions/              # Extensions (Colors, Themes)
│   │   ├── helpers/                 # Bindings e helpers
│   │   ├── models/                  # Modelos centrais (Freezed)
│   │   ├── router/                  # Configuração de rotas
│   │   ├── services/                # Serviços MQTT base
│   │   ├── theme/                   # Sistema de temas ACTheme
│   │   ├── utils/                   # Logger e utilitários
│   │   ├── validators/              # Validadores de dados
│   │   └── widgets/                 # Widgets reutilizáveis
│   ├── domain/                      # Camada de domínio
│   │   ├── entities/               # Entidades de negócio
│   │   ├── models/                 # Modelos de domínio
│   │   └── repositories/           # Contratos de repositório
│   ├── features/                    # Features por módulo
│   │   ├── config/                 # Configuração dinâmica
│   │   ├── dashboard/              # Dashboard principal
│   │   ├── screens/                # Telas dinâmicas
│   │   └── settings/               # Configurações do app
│   ├── infrastructure/             # Camada de infraestrutura
│   │   └── services/               # Services (API, Config, etc.)
│   ├── providers/                  # Providers globais
│   └── services/                   # Serviços legados
├── assets/                         # Recursos estáticos
├── test/                          # Testes (unitários, widget)
├── docs/                          # Documentação completa
│   ├── agents/                    # Agentes de desenvolvimento
│   ├── plans/                     # Planos de implementação
│   ├── architecture/              # Documentação de arquitetura
│   └── development/               # Guias de desenvolvimento
├── Makefile                       # Automação de comandos
└── pubspec.yaml                   # Dependências Flutter
```

## 🔧 Configuração

### Requisitos
- Flutter SDK 3.10+
- Dart 2.19+
- Android Studio / VS Code
- Android SDK (min 21)
- iOS SDK (min 12.0)

### Instalação e Configuração

```bash
# Clone o repositório
cd ~/Projetos/AutoCore/app-flutter

# Use o Makefile para setup completo
make install          # Instala dependências e configura projeto
make run              # Executa o app em modo debug
make build            # Compila APK para produção

# Ou comandos Flutter tradicionais
flutter pub get       # Instala dependências
flutter run           # Executa em modo debug
flutter analyze       # Análise de código (0 issues!)
```

### Comandos Make Disponíveis

```bash
make help             # Mostra todos os comandos
make analyze          # Análise de código
make format           # Formatação automática
make build-debug      # Build APK debug
make build-release    # Build APK release
make test             # Executa testes
make clean            # Limpa cache e builds
make qa               # QA completo (analyze + format + test)
```

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.5
  
  # MQTT Communication  
  mqtt_client: ^10.0.0
  
  # HTTP Client
  dio: ^5.3.2
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # JSON & Models
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  
  # UI Framework
  cupertino_icons: ^1.0.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
```

## 🏗️ Arquitetura

### Clean Architecture Implementada
```
┌─────────────────────────────────────┐
│      Features (Presentation)       │
│  Dashboard │ Screens │ Settings     │
│  Widgets, Pages, Controllers        │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│         Domain Layer                │
│   Models (Freezed) │ Entities       │
│   Repository Contracts              │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│      Infrastructure                 │
│  ApiService │ MqttService │ Config  │
│  Providers │ Storage │ Network      │
└─────────────────────────────────────┘
```

### Padrões Arquiteturais Utilizados
- **Repository Pattern**: Abstração para acesso a dados
- **Provider Pattern**: Gerenciamento de estado reativo
- **Dependency Injection**: Injeção via Provider/ChangeNotifier
- **Singleton Services**: Services compartilhados (MQTT, Config)
- **Freezed Models**: Modelos imutáveis com code generation

### Fluxo de Dados
```mermaid
graph TD
    A[UI Widget] --> B[Provider/ChangeNotifier]
    B --> C[Service Layer]
    C --> D[Repository]
    D --> E[Data Source API/MQTT]
    E --> D
    D --> C  
    C --> B
    B --> A
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

## 🎯 Funcionalidades Implementadas

### 1. Dashboard Dinâmico
- **Telas configuráveis** via API `/api/config/full/{device_uuid}`
- **Widgets responsivos**: Buttons, Displays, Gauges, Switches
- **Grid layout** adaptativo (2-4 colunas conforme device)
- **Navegação por tabs** entre screens configuradas
- **Estados em tempo real** via MQTT e telemetria

### 2. Comunicação MQTT Robusta
- **Auto-conexão** com retry inteligente
- **QoS configurável** por tipo de mensagem
- **Heartbeat system** para botões momentâneos
- **Publish/Subscribe** para telemetria e comandos
- **Offline resilience** com cache local

### 3. Gerenciamento de Configuração
- **Auto-registro** de dispositivos UUID v4
- **Download automático** de configuração no startup
- **Cache inteligente** (5min fresh, 1h fallback)
- **Sync API/MQTT** para consistência de dados
- **Fallback offline** com configuração cached

### 4. Sistema de Temas
- **ACTheme** configurável via Freezed
- **Dark/Light mode** baseado em preferências
- **Cores customizáveis** por instalação
- **Responsive design** para múltiplos form factors

### 5. Widgets de Controle
- **ButtonItemWidget**: Ações momentâneas e toggle
- **DisplayItemWidget**: Visualização de valores e unidades
- **GaugeItemWidget**: Medidores circulares animados
- **SwitchItemWidget**: Controles liga/desliga

## 🔄 Arquitetura de Comunicação

### API REST (Backend)
```dart
// Auto-registro de dispositivo
POST /api/devices
{
  "uuid": "esp32-uuid-v4",
  "type": "esp32_display", 
  "name": "AutoCore Flutter App",
  "hardware_version": "Flutter-v1.0"
}

// Configuração completa
GET /api/config/full/{device_uuid}
// Retorna: device, system, screens, themes

// Configuração MQTT
GET /api/mqtt/config
// Retorna: broker, port, credentials
```

### MQTT (Tempo Real)
```dart
// Tópicos de Publish
autocore/devices/{uuid}/commands     // Comandos para ESP32
autocore/devices/{uuid}/heartbeat    // Heartbeat segurança

// Tópicos de Subscribe  
autocore/devices/{uuid}/status       // Status do dispositivo
autocore/devices/{uuid}/telemetry    // Dados de sensores
autocore/devices/{uuid}/events       // Eventos e alertas
```

### Fluxo de Inicialização
```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as Backend API
    participant MQTT as MQTT Broker
    participant Device as ESP32

    App->>API: POST /api/devices (auto-registro)
    API->>App: 201 Created
    App->>API: GET /api/config/full/{uuid}
    API->>App: Configuração completa
    App->>API: GET /api/mqtt/config
    API->>App: Credenciais MQTT
    App->>MQTT: Connect + Subscribe
    MQTT->>App: Connected
    Device->>MQTT: Telemetry data
    MQTT->>App: Real-time updates
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

## 📊 Status de Qualidade

### Métricas Atuais ✅
- **Flutter Analyze**: 0 issues (ZERO WARNINGS!)
- **Build APK**: 22MB (otimizado)
- **Compile Time**: ~30s debug, ~45s release
- **Arquivos Dart**: 111 files bem estruturados
- **Modelos Freezed**: 16 classes com JSON serialization
- **Padrões**: 100% conformidade com FLUTTER_STANDARDS.md

### Testes 🧪
```bash
# Executar testes existentes
flutter test                    # Testes unitários
make test                      # Via Makefile

# Coverage (em desenvolvimento)
flutter test --coverage       # Gerar coverage report
make qa                       # QA completo

# Testes existentes
test/unit_test_config_service.dart  # ConfigService validado
```

### Build & Deploy 🚀
```bash
# Development
make run                      # Debug mode
make build-debug             # APK debug

# Production  
make build-release           # APK release (22MB)
flutter build appbundle     # Android App Bundle
flutter build ios           # iOS build
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

## 📚 Documentação Completa

### Guias Disponíveis
- 📖 `docs/README.md` - Índice de documentação
- 🏗️ `docs/architecture/APP-ARCHITECTURE.md` - Arquitetura detalhada
- 📱 `docs/development/GETTING-STARTED.md` - Setup de desenvolvimento
- 🎨 `docs/FLUTTER-STANDARDS.md` - Padrões de código (100% compliance)
- 🔧 `docs/services/API-SERVICE.md` - Documentação de services
- 📋 `docs/plans/` - Planos de implementação futura

### Agentes de Desenvolvimento
O projeto utilizou 28 agentes autônomos para implementação:
- ✅ A09-A36: Todos implementados e arquivados em `docs/agents/archived/`
- 📊 QA completo realizado (A11, A20, A36)
- 🏆 Zero issues alcançado (A12, A13)

## 🔍 Monitoramento e Logging

### AppLogger Estruturado
```dart
AppLogger.info('Carregando configuração do dispositivo');
AppLogger.warning('Falha na conexão MQTT, tentando reconectar');
AppLogger.error('Erro ao processar comando', error: e, stackTrace: stack);
AppLogger.debug('Telemetry update: ${data.keys.join(', ')}');
```

### Métricas Coletadas
- ⚡ Performance de startup e navegação
- 📡 Latência e status das conexões MQTT/HTTP
- 💾 Cache hits/misses para otimização
- 🎛️ Interações do usuário com widgets

## 🤝 Desenvolvimento

### Padrões de Código
- 📋 Seguir `FLUTTER-STANDARDS.md` rigorosamente
- 🧪 Escrever testes para novas funcionalidades
- 📝 Documentar APIs públicas
- 🔍 Usar `flutter analyze` antes de commits
- ✅ Zero warnings/errors obrigatório

### Contributing Workflow
1. **Branch**: `feature/nome-da-feature`
2. **Development**: Seguir padrões estabelecidos
3. **Testing**: Garantir que testes passem
4. **QA**: `make qa` deve passar sem issues
5. **PR**: Code review obrigatório
6. **Merge**: Apenas após aprovação

## 🏆 Conquistas do Projeto

- ✅ **Zero Issues**: Flutter analyze sem warnings
- ⚡ **Performance**: APK 22MB, startup <3s
- 🏗️ **Arquitetura**: Clean Architecture implementada
- 🎯 **Funcionalidades**: 100% das specs implementadas
- 📊 **Qualidade**: Padrões rigorosos seguidos
- 🤖 **Automação**: 28 agentes implementaram o projeto

## 📄 Licença e Contato

**Licença**: Proprietário - AutoCore © 2025  
**Responsável**: Lee Chardes  
**Repositório**: `/Users/leechardes/Projetos/AutoCore/app-flutter`  
**Status**: ✅ **PRODUÇÃO READY**  

---

> **AutoCore Flutter App** - Interface moderna e robusta para controle IoT  
> Desenvolvido com excelência técnica e zero compromissos de qualidade.