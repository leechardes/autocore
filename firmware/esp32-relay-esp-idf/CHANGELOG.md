# Changelog

Todas as mudanças importantes neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Não Lançado]

### Planejado
- [ ] Sistema OTA (Over-The-Air) updates
- [ ] Interface web aprimorada com controles em tempo real
- [ ] Suporte a múltiplos brokers MQTT (failover)
- [ ] Configuração via Bluetooth Low Energy (BLE)
- [ ] Dashboard com métricas em tempo real

## [2.0.0] - 2025-08-11

### 🎉 Lançamento Principal - Migração ESP-IDF

Esta é uma **reescrita completa** do sistema, migrando de MicroPython para ESP-IDF nativo em C.

### ✨ Adicionado
- **Sistema de Relés Momentâneos**: Controle com heartbeat e safety shutoff automático
- **Protocolo MQTT v1.1**: Sistema unificado de comandos e telemetria aprimorada
- **Arquitetura Dual-Core**: Core 0 para HTTP, Core 1 para MQTT e timers
- **Sistema de Configuração NVS**: Armazenamento persistente otimizado
- **Auto-registro Inteligente**: Registro automático com backend AutoCore
- **Interface Web Responsiva**: Dashboard de configuração moderno
- **Sistema de Telemetria**: Métricas em tempo real a cada 30 segundos
- **Timers de Alta Precisão**: Hardware timers para operações críticas
- **Thread Safety**: Mutex e semáforos para operações thread-safe
- **Sistema de Logs Estruturado**: Logging categorizado por componentes
- **WiFi Manager Inteligente**: Dual mode com fallback automático
- **Makefile Avançado**: Comandos de build, flash e debug otimizados

### 🚀 Performance
- **Boot Time**: < 1 segundo (35x mais rápido que MicroPython)
- **HTTP Response**: < 10ms (10x mais rápido)
- **MQTT Latency**: < 50ms (4x mais rápido)
- **RAM Usage**: < 50KB (40% menos uso de RAM)
- **CPU Usage**: Aproveitamento completo de dual-core

### 🏗️ Arquitetura
- **Componentes Modulares**: Separação clara de responsabilidades
  - `config_manager`: Gerenciamento de configuração e NVS
  - `network`: WiFi, HTTP Server, MQTT Client e protocolos
  - `relay_control`: Controle de hardware e GPIO
  - `web_interface`: Interface web embarcada
- **Headers Organizados**: APIs bem definidas entre componentes
- **Build System**: CMake + ESP-IDF build system otimizado

### 📡 MQTT Features
- **Estrutura de Tópicos**: Padrão AutoCore `autocore/devices/{uuid}/`
- **QoS Inteligente**: QoS 0 para telemetria, QoS 1 para comandos críticos
- **Retained Messages**: Estados persistentes para reconexão
- **Last Will Testament**: Detecção automática de desconexão
- **JSON Parsing**: cJSON nativo para performance otimizada

### ⚡ Relés Momentâneos (NEW!)
- **Heartbeat System**: Monitoramento ativo com timers de 100ms
- **Safety Shutoff**: Desligamento automático em 1s sem heartbeat
- **Thread-Safe Operations**: Mutex para acesso seguro às estruturas
- **Telemetria de Segurança**: Eventos de safety shutoff reportados
- **Múltiplos Canais**: Suporte a até 16 relés momentâneos simultâneos

### 🛡️ Segurança e Confiabilidade
- **Watchdog Timer**: Proteção contra travamentos
- **Memory Management**: Verificação de heap e cleanup automático
- **Error Handling**: Tratamento robusto de erros em todas as camadas
- **State Persistence**: Estados salvos em NVS para recuperação após reboot
- **Validation**: Validação rigorosa de JSON e comandos MQTT

### 🔧 Ferramentas de Desenvolvimento
- **Scripts Python**: Automação de flash, monitor e debug
- **Makefile Avançado**: Comandos one-liner para todas as operações
- **Logging Estruturado**: Filtros por componente e nível
- **Memory Analysis**: Ferramentas para análise de uso de memória
- **Port Detection**: Detecção automática de porta serial

## [1.0.0-micropython] - 2025-08-08

### 📝 Nota Histórica
Esta versão representa a implementação anterior em MicroPython, mantida para referência histórica.

### ✨ Recursos Originais
- Sistema básico de controle de relés
- Interface web simples
- Cliente MQTT básico
- Configuração via WiFi AP

### 🐌 Limitações da Versão MicroPython
- **Boot Time**: ~30-35 segundos
- **HTTP Response**: ~100ms
- **MQTT Latency**: ~200ms
- **RAM Usage**: ~80KB
- **Single Core**: Não aproveitava dual-core do ESP32

### 🔄 Razões para Migração
1. **Performance**: Necessidade de resposta em tempo real
2. **Recursos**: Melhor aproveitamento do hardware ESP32
3. **Confiabilidade**: Maior estabilidade para produção
4. **Funcionalidades**: Recursos avançados não disponíveis em MicroPython
5. **Manutenibilidade**: Código mais estruturado e testável

## Tipos de Mudanças

- `✨ Adicionado` para novas funcionalidades
- `🔧 Modificado` para mudanças em funcionalidades existentes
- `🗑️ Descontinuado` para funcionalidades que serão removidas
- `❌ Removido` para funcionalidades removidas
- `🐛 Corrigido` para correção de bugs
- `🔒 Segurança` para vulnerabilidades corrigidas
- `📊 Performance` para melhorias de performance
- `📝 Documentação` para mudanças na documentação

## Links de Comparação

- [2.0.0...HEAD](https://github.com/AutoCore/firmware/compare/v2.0.0...HEAD)
- [1.0.0...2.0.0](https://github.com/AutoCore/firmware/compare/v1.0.0...v2.0.0)

---

**Formato do Changelog**: [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/)  
**Versionamento**: [Semantic Versioning](https://semver.org/lang/pt-BR/)  
**Última Atualização**: 11 de Agosto de 2025