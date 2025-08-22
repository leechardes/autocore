# AutoCore ESP32 Display - Documentação Completa

Este é o sistema de documentação abrangente para o firmware ESP32 com display do projeto AutoCore. A documentação está organizada por categorias para facilitar navegação e manutenção.

## 📁 Estrutura da Documentação

### 🔧 [Hardware](hardware/)
Documentação completa do hardware ESP32 e periféricos
- **[esp32-pinout.md](hardware/esp32-pinout.md)** - Mapeamento de pinos completo
- **[display-specs.md](hardware/display-specs.md)** - Especificações do display ILI9341
- **[touch-controller.md](hardware/touch-controller.md)** - Controlador touch XPT2046
- **[power-management.md](hardware/power-management.md)** - Gestão de energia e sleep modes
- **[peripherals.md](hardware/peripherals.md)** - Periféricos externos e expansão

### 🎨 [UI System](ui/)
Sistema de interface LVGL e componentes visuais
- **[screen-layouts.md](ui/screen-layouts.md)** - Layouts e estruturas de tela
- **[nav-buttons.md](ui/nav-buttons.md)** - Sistema NavButton detalhado
- **[animations.md](ui/animations.md)** - Animações e transições
- **[themes.md](ui/themes.md)** - Sistema de temas e cores
- **[lvgl-configuration.md](ui/lvgl-configuration.md)** - Configuração LVGL

### 📡 [Communication](communication/)
Protocolos de comunicação MQTT e APIs
- **[mqtt-protocol.md](communication/mqtt-protocol.md)** - Protocolo MQTT v2.2.0 completo
- **[command-list.md](communication/command-list.md)** - Lista de comandos disponíveis
- **[json-schemas.md](communication/json-schemas.md)** - Schemas JSON para validação
- **[websocket-api.md](communication/websocket-api.md)** - API WebSocket
- **[error-codes.md](communication/error-codes.md)** - Códigos de erro

### 🌐 [Networking](networking/)
Conectividade, WiFi e atualizações OTA
- **[wifi-manager.md](networking/wifi-manager.md)** - Gerenciamento WiFi
- **[mdns-discovery.md](networking/mdns-discovery.md)** - Descoberta via mDNS
- **[ota-updates.md](networking/ota-updates.md)** - Sistema OTA completo
- **[connection-retry.md](networking/connection-retry.md)** - Estratégias de reconexão
- **[network-diagnostics.md](networking/network-diagnostics.md)** - Diagnósticos

### 🏗️ [Architecture](architecture/)
Arquitetura do sistema e design patterns
- **[system-architecture.md](architecture/system-architecture.md)** - Arquitetura geral
- **[memory-layout.md](architecture/memory-layout.md)** - Layout de memória
- **[task-scheduling.md](architecture/task-scheduling.md)** - FreeRTOS tasks
- **[event-system.md](architecture/event-system.md)** - Sistema de eventos
- **[state-machine.md](architecture/state-machine.md)** - Máquinas de estado

### 🧩 [Components](components/)
Componentes principais do sistema
- **[screen-factory.md](components/screen-factory.md)** - Factory de criação
- **[command-sender.md](components/command-sender.md)** - Envio de comandos
- **[touch-handler.md](components/touch-handler.md)** - Processamento touch
- **[device-config.md](components/device-config.md)** - Configuração
- **[api-client.md](components/api-client.md)** - Cliente API REST

### 🚀 [Deployment](deployment/)
Build, flash e deploy do firmware
- **[platformio-build.md](deployment/platformio-build.md)** - Build com PlatformIO
- **[flash-firmware.md](deployment/flash-firmware.md)** - Flash do firmware
- **[ota-deployment.md](deployment/ota-deployment.md)** - Deploy OTA
- **[partition-table.md](deployment/partition-table.md)** - Tabela de partições
- **[production-setup.md](deployment/production-setup.md)** - Setup produção

### 👨‍💻 [Development](development/)
Guias para desenvolvedores
- **[getting-started.md](development/getting-started.md)** - Como começar
- **[platformio-setup.md](development/platformio-setup.md)** - Setup PlatformIO
- **[debugging-guide.md](development/debugging-guide.md)** - Debug e troubleshooting
- **[serial-monitor.md](development/serial-monitor.md)** - Monitor serial
- **[unit-testing.md](development/unit-testing.md)** - Testes unitários

### 🔒 [Security](security/)
Segurança e autenticação
- **[secure-boot.md](security/secure-boot.md)** - Boot seguro
- **[flash-encryption.md](security/flash-encryption.md)** - Criptografia flash
- **[mqtt-tls.md](security/mqtt-tls.md)** - TLS para MQTT
- **[api-authentication.md](security/api-authentication.md)** - Autenticação API
- **[firmware-signing.md](security/firmware-signing.md)** - Assinatura firmware

### 🔍 [Troubleshooting](troubleshooting/)
Resolução de problemas comuns
- **[common-errors.md](troubleshooting/common-errors.md)** - Erros comuns
- **[wifi-issues.md](troubleshooting/wifi-issues.md)** - Problemas WiFi
- **[display-problems.md](troubleshooting/display-problems.md)** - Problemas display
- **[memory-issues.md](troubleshooting/memory-issues.md)** - Problemas memória
- **[boot-loops.md](troubleshooting/boot-loops.md)** - Boot loops

### ⚡ [Performance](performance/)
Otimização e performance
- **[memory-optimization.md](performance/memory-optimization.md)** - Otimização memória
- **[power-consumption.md](performance/power-consumption.md)** - Consumo energia
- **[response-time.md](performance/response-time.md)** - Tempo resposta
- **[profiling.md](performance/profiling.md)** - Profiling performance

### 📋 [Templates](templates/)
Templates para desenvolvimento
- **[screen-template.h](templates/screen-template.h)** - Template tela LVGL
- **[screen-template.cpp](templates/screen-template.cpp)** - Implementação tela
- **[component-template.h](templates/component-template.h)** - Template componente
- **[component-template.cpp](templates/component-template.cpp)** - Implementação componente
- **[test-template.cpp](templates/test-template.cpp)** - Template testes

### 🤖 [Agents](agents/)
Sistema de agentes para automação
- **[dashboard.md](agents/dashboard.md)** - Dashboard dos agentes
- **[A01-screen-creator/](agents/active-agents/A01-screen-creator/)** - Criador de telas
- **[A02-component-builder/](agents/active-agents/A02-component-builder/)** - Builder componentes
- **[A03-command-generator/](agents/active-agents/A03-command-generator/)** - Gerador comandos
- **[A04-ota-deployer/](agents/active-agents/A04-ota-deployer/)** - Deploy OTA
- **[A05-performance-profiler/](agents/active-agents/A05-performance-profiler/)** - Profiler

## 🚀 Quick Start

### Para Desenvolvedores
1. **Setup**: Leia [Development/Getting Started](development/getting-started.md)
2. **Hardware**: Configure conforme [Hardware/ESP32 Pinout](hardware/esp32-pinout.md)
3. **Build**: Siga [Deployment/PlatformIO Build](deployment/platformio-build.md)
4. **Debug**: Use [Development/Debugging Guide](development/debugging-guide.md)

### Para Usuários do Sistema
1. **Instalação**: Veja [Deployment/Flash Firmware](deployment/flash-firmware.md)
2. **Configuração**: Configure via [Communication/MQTT Protocol](communication/mqtt-protocol.md)
3. **Troubleshooting**: Consulte [Troubleshooting/Common Errors](troubleshooting/common-errors.md)

### Para Integradores
1. **API**: Entenda [Communication/Command List](communication/command-list.md)
2. **Protocolos**: Implemente [Communication/JSON Schemas](communication/json-schemas.md)
3. **Rede**: Configure [Networking/WiFi Manager](networking/wifi-manager.md)

## 🔧 Especificações Técnicas

### Hardware
- **Microcontrolador**: ESP32-WROOM-32 (240MHz dual-core)
- **Display**: ILI9341 240x320 SPI TFT (16-bit colors)
- **Touch**: XPT2046 resistivo 4-wire
- **Memória**: 4MB Flash, 520KB SRAM, 64KB LVGL heap
- **Conectividade**: WiFi 802.11 b/g/n, Bluetooth (não usado)

### Software
- **Framework**: Arduino + PlatformIO
- **UI Library**: LVGL 8.3.11
- **Communication**: MQTT v2.2.0, HTTP/HTTPS REST
- **OTA**: Arduino OTA + HTTP OTA + MQTT coordination
- **Security**: TLS 1.2+, device authentication, firmware signing

### Performance
- **CPU Frequency**: 80-240MHz (dynamic scaling)
- **Display Refresh**: 30ms (33 FPS)
- **Touch Response**: <50ms
- **MQTT Latency**: <200ms
- **Memory Usage**: ~180KB free heap (typical)

## 📊 Métricas do Sistema

### Componentes Documentados
- **Hardware**: 5 documentos principais
- **UI System**: 5 documentos LVGL
- **Communication**: 5 protocolos documentados
- **Components**: 32 classes principais
- **Commands**: 16 tipos de comando MQTT
- **Templates**: 5 templates C++
- **Agents**: 5 agentes especializados

### Cobertura de Funcionalidades
- ✅ **Display Control**: 100% documentado
- ✅ **Touch Input**: 100% documentado  
- ✅ **MQTT Communication**: 100% documentado
- ✅ **WiFi Management**: 100% documentado
- ✅ **OTA Updates**: 100% documentado
- ✅ **Memory Management**: 100% documentado
- ✅ **Error Handling**: 100% documentado
- ✅ **Security**: 100% documentado

## 🔄 Workflow de Desenvolvimento

### 1. Feature Development
```
Requirement → Design → [Template] → Implementation → Testing → Documentation
```

### 2. Agent-Assisted Development
```
User Input → [Agent] → Generated Code → Validation → Integration → Deploy
```

### 3. Testing & Validation
```
Unit Tests → Integration Tests → Hardware Tests → Performance Tests → User Acceptance
```

### 4. Deployment Pipeline
```
Build → Sign → Upload → OTA Notify → Device Update → Validation → Monitoring
```

## 🤝 Contribuindo

### Adicionando Nova Documentação
1. Seguir estrutura de pastas existente
2. Usar templates em [`templates/`](templates/)
3. Incluir exemplos práticos
4. Validar com agentes quando aplicável

### Atualizando Componentes
1. Documentar mudanças em CHANGELOG.md
2. Atualizar diagramas arquiteturais
3. Revisar templates afetados
4. Executar agentes de validação

### Reporting Issues
1. Consultar [Troubleshooting](troubleshooting/) primeiro
2. Usar [Issues Template] para reportar
3. Incluir logs relevantes
4. Testar com agentes de diagnóstico

## 📞 Suporte

### Documentação
- **Online**: Esta documentação completa
- **Inline**: Comentários no código fonte
- **APIs**: Schemas JSON auto-documentados
- **Agents**: Sistema de ajuda integrado

### Ferramentas de Debug
- **Serial Monitor**: Debug em tempo real
- **LVGL Inspector**: Inspeção de UI
- **MQTT Monitor**: Monitoramento protocolos
- **Memory Profiler**: Análise de memória

### Contato
- **Projeto**: AutoCore ESP32 Display System
- **Versão**: 2.2.0
- **Documentação**: v1.0.0
- **Última Atualização**: 2025-01-18

## 📄 Licença

Este projeto está licenciado sob a MIT License. Veja o arquivo LICENSE para detalhes.

---

**🚀 AutoCore ESP32 Display - Powering the Future of IoT Interfaces**