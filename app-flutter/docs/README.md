# AutoCore Flutter App - Documentação Completa

Documentação abrangente do aplicativo Flutter do AutoCore para gestão de dispositivos IoT ESP32.

## 📱 Visão Geral

O AutoCore App é um aplicativo Flutter multiplataforma para controle e monitoramento de dispositivos ESP32 através de interface intuitiva e comunicação MQTT em tempo real.

### Tecnologias Principais

- **Framework**: Flutter 3.8.1+
- **State Management**: Riverpod 2.4.10
- **Comunicação**: MQTT Client 10.0.0, Dio 5.4.0  
- **UI**: Google Fonts, Flutter Animate, Lottie
- **Storage**: Shared Preferences, Hive Flutter
- **Navegação**: Go Router 14.0.0

## 📁 Estrutura da Documentação

### 🖥️ [Screens](screens/)
Documentação completa de todas as telas do aplicativo
- [Dashboard](screens/dashboard-screens.md) - Tela principal de controle
- [Settings](screens/settings-screens.md) - Configurações do app
- [Dynamic Screens](screens/device-screens.md) - Telas dinâmicas baseadas em configuração
- [Navigation Flow](screens/navigation-flow.md) - Fluxo de navegação

### 🧩 [Widgets](widgets/)  
Catálogo de widgets customizados criados
- [Base Widgets](widgets/ui-widgets.md) - Componentes base (AC Button, Container, Grid)
- [Controls](widgets/form-widgets.md) - Controles de interface (Switch, Control Tile)
- [Indicators](widgets/chart-widgets.md) - Indicadores visuais (Gauge, Progress Bar, Status)
- [Dynamic Widgets](widgets/animation-widgets.md) - Widgets dinâmicos

### ⚙️ [Services](services/)
Serviços e integrações do aplicativo
- [MQTT Service](services/mqtt-service.md) - Comunicação MQTT com ESP32
- [API Service](services/api-service.md) - Integração com backend
- [Config Service](services/storage-service.md) - Gerenciamento de configurações
- [Heartbeat Service](services/notification-service.md) - Monitoramento de dispositivos

### 🔄 [State Management](state/)
Sistema de gerenciamento de estado com Riverpod
- [Providers](state/providers.md) - Configuração de providers
- [Riverpod Setup](state/riverpod-setup.md) - Setup e arquitetura
- [State Models](state/state-models.md) - Modelos de estado
- [Data Flow](state/data-flow.md) - Fluxo de dados

### 🏗️ [Architecture](architecture/)
Arquitetura e padrões do aplicativo
- [App Architecture](architecture/app-architecture.md) - Visão geral da arquitetura
- [Folder Structure](architecture/folder-structure.md) - Organização de pastas
- [Design Patterns](architecture/design-patterns.md) - Padrões utilizados

### 📱 [Platform](platform/)
Configurações específicas de plataforma
- [Android Setup](platform/android-setup.md) - Configuração Android
- [iOS Setup](platform/ios-setup.md) - Configuração iOS
- [Permissions](platform/permissions.md) - Permissões necessárias

### 🚀 [Development](development/)
Guias de desenvolvimento
- [Getting Started](development/getting-started.md) - Primeiros passos
- [Coding Standards](development/coding-standards.md) - Padrões de código
- [Testing Guide](development/widget-testing.md) - Guia de testes

### 🎨 [UI/UX](ui-ux/)
Design system e experiência do usuário
- [Design System](ui-ux/design-system.md) - Sistema de design
- [Theme Configuration](ui-ux/theme-configuration.md) - Configuração de temas
- [Accessibility](ui-ux/accessibility.md) - Acessibilidade

### 🔧 [Templates](templates/)
Templates para novos componentes
- [Screen Template](templates/screen-template.dart) - Template para telas
- [Widget Template](templates/widget-template.dart) - Template para widgets
- [Service Template](templates/service-template.dart) - Template para services

### 🤖 [Agents](agents/)
Sistema de agentes automáticos para desenvolvimento
- [Dashboard de Agentes](agents/dashboard.md) - Painel de controle
- [Agentes Ativos](agents/active-agents/) - Agentes em execução

## 🔗 Links Rápidos

- [Configuração de Desenvolvimento](development/getting-started.md)
- [Padrões de Código](development/coding-standards.md)
- [Integração MQTT](services/mqtt-service.md)
- [Widgets Customizados](widgets/ui-widgets.md)
- [State Management](state/riverpod-setup.md)

## 📊 Métricas do Projeto

- **Screens**: 5+ telas documentadas
- **Widgets**: 13+ widgets customizados
- **Services**: 6+ serviços implementados
- **Providers**: 4+ providers configurados
- **Plataformas**: Android e iOS

## 🚀 Início Rápido

1. Clone o repositório
2. Configure o ambiente Flutter
3. Execute `flutter pub get`
4. Conecte o dispositivo ESP32
5. Execute `flutter run`

## 🤝 Contribuindo

Consulte os [padrões de código](development/coding-standards.md) antes de contribuir.

---

**Última atualização**: 22/08/2025  
**Versão da documentação**: 1.0.0