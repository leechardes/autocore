# 📡 Arquitetura MQTT - AutoCore

## Visão Geral

O AutoCore utiliza MQTT como protocolo principal de comunicação entre todos os componentes do sistema. O Mosquitto atua como broker central, coordenando mensagens entre dispositivos ESP32, aplicações web, mobile e o gateway.

> **📌 Nota Importante:** A partir da versão 2.0, toda configuração de dispositivos é feita via **API REST**. O MQTT é usado exclusivamente para telemetria, comandos, status e heartbeat em tempo real.

## 🏗️ Componentes do Sistema

### 1. Mosquitto Broker
- **Função**: Broker MQTT central
- **Porta**: 1883 (desenvolvimento), 8883 (produção com TLS)
- **Host**: Raspberry Pi Zero 2W (mesmo do Gateway)
- **Configuração**: 
  - Mensagens retidas para status
  - QoS 0 para telemetria (performance)
  - QoS 1 para comandos (garantia de entrega)
  - QoS 2 para configurações críticas (exatamente uma vez)

### 2. AutoCore Gateway
- **Função**: Coordenador central e bridge
- **Responsabilidades**:
  - Descoberta automática de dispositivos
  - Roteamento inteligente de mensagens
  - Persistência de dados em SQLite
  - Bridge para serviços cloud (futuro)
  - Gerenciamento de autenticação
  - Monitoramento de saúde do sistema

### 3. Interfaces de Controle (Clientes MQTT)

#### Config App (Web) 
- **Função**: Interface de configuração e monitoramento
- **Papel no Sistema**:
  - Configuração inicial de dispositivos
  - Monitoramento em tempo real via WebSocket
  - Simuladores para desenvolvimento/teste
  - Debug e troubleshooting
- **Controle de Relés**:
  - Interface de teste e validação
  - Não requer heartbeat (ambiente controlado)

#### ESP32 Display
- **Função**: Interface física no veículo
- **Papel no Sistema**:
  - Controle local via tela touch
  - Visualização de telemetria em tempo real
  - **ENVIA HEARTBEATS** para relés momentâneos
  - Renderização de telas configuráveis
- **Responsabilidades Críticas**:
  - Manter heartbeat enquanto botão pressionado
  - Parar heartbeat ao soltar ou perder touch
  - Feedback visual do estado dos relés

#### Flutter App (Mobile/Desktop)
- **Função**: Controle remoto multiplataforma
- **Papel no Sistema**:
  - Controle total do veículo via smartphone
  - **ENVIA HEARTBEATS** para relés momentâneos
  - Notificações push de alertas
  - Visualização de telemetria
- **Responsabilidades Críticas**:
  - Manter heartbeat durante press & hold
  - Gerenciar reconexão em caso de perda de rede
  - Modo offline com sincronização posterior

### 4. Dispositivos ESP32 (Hardware)

#### ESP32 Relay
- **Função**: Controle de relés automotivos
- **Características**:
  - 16/32 canais por placa
  - Proteção por senha/confirmação
  - Estado persistente em caso de reset

#### ESP32 Display
- **Função**: Interface visual no veículo
- **Características**:
  - Telas configuráveis (2.4" a 7")
  - Touch screen opcional
  - Renderização de telemetria em tempo real

#### ESP32 CAN
- **Função**: Interface com ECU do veículo
- **Características**:
  - Leitura de sinais CAN Bus
  - Suporte FuelTech, MegaSquirt, Haltech
  - Tradução CAN → MQTT

#### ESP32 Sensor
- **Função**: Leitura de sensores analógicos/digitais
- **Características**:
  - Temperatura, pressão, nível
  - Calibração remota
  - Filtros de ruído

### 5. Flutter App (Mobile/Desktop)
- **Função**: Controle remoto completo
- **Plataformas**: iOS, Android, Windows, macOS, Linux
- **Características**:
  - Controle de relés
  - Visualização de telemetria
  - Notificações push
  - Modo offline com sincronização

## 🎯 Matriz de Responsabilidades

| Componente | Publica | Subscreve | Heartbeat | Responsabilidade Principal |
|------------|---------|-----------|-----------|---------------------------|
| **ESP32 Relay** | - Estado dos relés<br>- Telemetria<br>- Safety events | - Comandos de controle<br>- Heartbeats | **RECEBE** e monitora | Executar comandos com segurança |
| **ESP32 Display** | - Touch events<br>- Comandos relé<br>- Heartbeats | - Estado dos relés<br>- Telemetria CAN | **ENVIA** continuamente | Interface local no veículo |
| **Flutter App** | - Comandos relé<br>- Heartbeats<br>- Requisições | - Estado dos relés<br>- Telemetria<br>- Notificações | **ENVIA** continuamente | Controle remoto completo |
| **Config App** | - Comandos teste | - Todos (monitor)<br>- Estados | Não necessário | Configuração via API e debug |
| **Gateway** | - Roteamento<br>- Agregações<br>- Comandos | - Tudo (broker) | Não aplicável | Coordenação e persistência |
| **ESP32 CAN** | - Telemetria CAN<br>- Status | - Comandos | Não aplicável | Bridge CAN→MQTT |
| **ESP32 Sensor** | - Dados sensores<br>- Status | - Comandos<br>- Calibração | Não aplicável | Aquisição de dados |

## 📊 Estrutura de Tópicos MQTT

### Convenção de Nomenclatura
```
autocore/{categoria}/{device_uuid}/{recurso}/{ação}
```

### Categorias Principais

#### 1. Dispositivos (`devices`)
```
# Status do dispositivo
autocore/devices/{uuid}/status
autocore/devices/{uuid}/announce

# Recursos específicos por tipo
autocore/devices/{uuid}/relays/state
autocore/devices/{uuid}/relays/set
autocore/devices/{uuid}/relays/heartbeat
autocore/devices/{uuid}/display/screen
autocore/devices/{uuid}/display/touch
autocore/devices/{uuid}/sensors/data
```

#### 2. Telemetria (`telemetry`)
```
# Dados de sensores
autocore/telemetry/sensors/{sensor_id}
autocore/telemetry/can/{signal_name}
autocore/telemetry/calculated/{metric}

# Telemetria de dispositivos
autocore/telemetry/relays
autocore/telemetry/displays

# Agregações
autocore/telemetry/summary/minute
autocore/telemetry/summary/hour
```

#### 3. Sistema (`system`)
```
# Gateway
autocore/gateway/status
autocore/gateway/stats

# Descoberta
autocore/discovery/announce
autocore/discovery/request

# Broadcast
autocore/system/broadcast
autocore/system/alert
autocore/system/update
```

#### 4. Comandos (`commands`)
```
# Comandos globais
autocore/commands/all/{action}
autocore/commands/group/{group_id}/{action}
autocore/commands/device/{uuid}/{action}
```


## 🔄 Fluxos de Comunicação

### 1. Descoberta de Dispositivo
```mermaid
sequenceDiagram
    ESP32->>Broker: PUBLISH autocore/discovery/announce
    Gateway->>Broker: SUBSCRIBE autocore/discovery/+
    Gateway->>Database: Registrar dispositivo
    ESP32->>API: GET /api/config/{uuid}
    ESP32->>Broker: PUBLISH autocore/devices/{uuid}/status
```

### 2. Comando de Relé Toggle (App → ESP32)
```mermaid
sequenceDiagram
    FlutterApp->>Broker: PUBLISH autocore/devices/{uuid}/relays/set
    ESP32Relay->>Broker: SUBSCRIBE autocore/devices/{uuid}/relays/set
    ESP32Relay->>Hardware: Acionar relé
    ESP32Relay->>Broker: PUBLISH autocore/devices/{uuid}/relays/state
    FlutterApp->>Broker: SUBSCRIBE autocore/devices/{uuid}/relays/state
    Display->>Broker: SUBSCRIBE autocore/devices/{uuid}/relays/state
```

### 2.1. Comando de Relé Momentâneo com Heartbeat
```mermaid
sequenceDiagram
    participant User
    participant Client as Display/App
    participant Broker as Mosquitto
    participant Relay as ESP32 Relay
    
    User->>Client: Press & Hold
    Client->>Broker: PUBLISH autocore/devices/{uuid}/relays/set {state: true, momentary: true}
    Relay->>Broker: SUBSCRIBE autocore/devices/{uuid}/relays/set
    Relay->>Relay: Liga relé + Inicia monitor timeout
    
    loop Enquanto pressionado (cada 500ms)
        Client->>Broker: PUBLISH autocore/devices/{uuid}/relays/heartbeat {channel: 1}
        Relay->>Relay: Reset timeout counter
    end
    
    User->>Client: Release
    Client->>Broker: PUBLISH autocore/devices/{uuid}/relays/set {state: false}
    Relay->>Relay: Desliga relé
    
    Note over Relay: Se timeout > 1s sem heartbeat
    Relay->>Relay: DESLIGA AUTOMATICAMENTE
    Relay->>Broker: PUBLISH autocore/telemetry/relays {uuid: "esp32-relay-001", event: "safety_shutoff"}
```

### 3. Telemetria CAN
```mermaid
sequenceDiagram
    ECU->>ESP32CAN: CAN Bus data
    ESP32CAN->>Broker: PUBLISH autocore/telemetry/can/+
    Gateway->>Broker: SUBSCRIBE autocore/telemetry/can/+
    Gateway->>Database: Armazenar telemetria
    Display->>Broker: SUBSCRIBE autocore/telemetry/can/+
    FlutterApp->>Broker: SUBSCRIBE autocore/telemetry/can/+
```

### 4. Evento Touch no Display
```mermaid
sequenceDiagram
    User->>ESP32Display: Touch event
    ESP32Display->>Broker: PUBLISH autocore/devices/{uuid}/display/touch
    Gateway->>Broker: SUBSCRIBE autocore/devices/{uuid}/display/touch
    Gateway->>Broker: PUBLISH autocore/devices/{relay_uuid}/relays/set
    ESP32Relay->>Broker: SUBSCRIBE autocore/devices/{relay_uuid}/relays/set
```

## 📦 Formato de Mensagens (Payloads)

### Status do Dispositivo
```json
{
  "uuid": "esp32-relay-001",
  "type": "esp32_relay",
  "status": "online",
  "timestamp": "2025-08-08T10:30:00Z",
  "uptime": 3600,
  "firmware_version": "1.0.0",
  "ip_address": "192.168.1.100",
  "wifi_signal": -65,
  "free_memory": 45000
}
```

### Estado de Relés
```json
{
  "uuid": "esp32-relay-001",
  "board_id": 1,
  "timestamp": "2025-08-08T10:30:00Z",
  "channels": {
    "1": true,
    "2": false,
    "3": true,
    "4": false
  }
}
```

### Comando de Relé Toggle
```json
{
  "channel": 1,
  "state": true,
  "function_type": "toggle",
  "user": "mobile_app",
  "timestamp": "2025-08-08T10:30:00Z"
}
```

### Comando de Relé Momentâneo
```json
{
  "channel": 1,
  "state": true,
  "function_type": "momentary",
  "momentary": true,
  "user": "display_touch",
  "timestamp": "2025-08-08T10:30:00Z"
}
```

### Heartbeat de Relé Momentâneo
```json
{
  "channel": 1,
  "source_uuid": "esp32-display-001",
  "target_uuid": "esp32-relay-001",
  "timestamp": "2025-08-08T10:30:00Z",
  "sequence": 42
}
```

### Telemetria de Relay (Evento de Mudança)
```json
{
  "uuid": "esp32-relay-001",
  "board_id": 1,
  "timestamp": "2025-08-12T12:46:34.914991",
  "event": "relay_change",
  "channel": 2,
  "state": false,
  "trigger": "simulator"
}
```

### Evento de Safety Shutoff
```json
{
  "uuid": "esp32-relay-001",
  "board_id": 1,
  "event": "safety_shutoff",
  "channel": 1,
  "reason": "heartbeat_timeout",
  "timeout_ms": 1000,
  "last_heartbeat": "2025-08-08T10:30:00Z",
  "timestamp": "2025-08-08T10:30:01Z"
}
```

### Telemetria CAN
```json
{
  "timestamp": "2025-08-08T10:30:00Z",
  "signals": {
    "RPM": {
      "value": 2500,
      "unit": "rpm",
      "can_id": "0x200"
    },
    "TPS": {
      "value": 45.2,
      "unit": "%",
      "can_id": "0x201"
    },
    "ECT": {
      "value": 87.5,
      "unit": "°C",
      "can_id": "0x202"
    }
  }
}
```

### Evento Touch
```json
{
  "screen_id": 1,
  "item_id": 5,
  "action": "tap",
  "position": {
    "x": 150,
    "y": 200
  },
  "timestamp": "2025-08-08T10:30:00Z"
}
```


## 🔒 Segurança

### Sistema de Heartbeat para Relés Momentâneos

#### Problema Resolvido
Relés momentâneos (buzina, guincho, partida) devem desligar automaticamente se:
- Perda de conexão de rede
- Travamento do aplicativo
- Falha no cliente MQTT
- Timeout de comunicação

#### Implementação
1. **Cliente (Display/App)**:
   - Envia heartbeat a cada 500ms enquanto botão pressionado
   - Para heartbeat ao soltar botão
   - Envia comando OFF explícito ao soltar

2. **ESP32 Relay**:
   - Monitora heartbeats recebidos
   - Timeout de 1 segundo sem heartbeat
   - Desliga automaticamente por segurança
   - Publica evento `safety_shutoff` para auditoria

3. **Parâmetros Configuráveis**:
   - `heartbeat_interval`: 500ms (frequência de envio)
   - `heartbeat_timeout`: 1000ms (timeout para desligar)
   - `retry_count`: 3 (tentativas antes de desligar)

#### Tipos de Relé
- **Toggle**: Liga/desliga com clique simples
- **Momentary**: Liga enquanto pressionado (requer heartbeat)
- **Pulse**: Liga por tempo determinado e desliga
- **Timed**: Liga com timer configurável

### Desenvolvimento
- Sem autenticação (rede local isolada)
- Conexões não criptografadas
- Todas as mensagens em texto claro
- Simuladores para teste sem hardware

### Produção (Planejado)
- TLS/SSL na porta 8883
- Autenticação por usuário/senha
- ACL (Access Control Lists) por tópico
- Tokens JWT para comandos críticos
- Criptografia de payloads sensíveis
- Rate limiting por cliente

## 📈 Quality of Service (QoS)

### QoS 0 - Fire and Forget
- Telemetria de sensores
- Status periódico
- Dados não críticos

### QoS 1 - At Least Once
- Comandos de relés
- Alertas
- Heartbeats

### QoS 2 - Exactly Once
- Atualizações de firmware
- Comandos críticos de segurança
- Comandos financeiros (futuro)

## 🔄 Retained Messages

Mensagens que devem ser retidas:
- `autocore/devices/{uuid}/status` - Último status conhecido
- `autocore/devices/{uuid}/relays/state` - Estado atual dos relés
- `autocore/gateway/status` - Status do gateway

## 📊 Métricas e Monitoramento

### Métricas Coletadas
- Mensagens por segundo
- Latência média
- Dispositivos online
- Taxa de erro
- Uso de banda

### Tópicos de Monitoramento
```
autocore/metrics/messages_per_second
autocore/metrics/connected_clients
autocore/metrics/average_latency
autocore/metrics/error_rate
```

## 🚀 Otimizações

### Para Raspberry Pi Zero 2W
1. **Batch de mensagens** - Agrupar telemetria em intervalos
2. **Compressão** - gzip para payloads grandes
3. **Rate limiting** - Máximo 10 msgs/segundo por dispositivo
4. **Cache local** - SQLite para dados históricos
5. **Filtros no broker** - Reduzir tráfego desnecessário

### Para ESP32
1. **Buffer de mensagens** - Queue para reconexão
2. **Heartbeat otimizado** - 30 segundos
3. **Payload mínimo** - Apenas campos alterados
4. **Sleep mode** - Entre transmissões

## 🔮 Evolução Futura

### Fase 1 - Local (Atual)
- Comunicação local via Mosquitto
- Sem autenticação
- Interface web de configuração

### Fase 2 - Segurança
- TLS/SSL
- Autenticação e autorização
- Logs de auditoria

### Fase 3 - Cloud Bridge
- Bridge para AWS IoT / Azure IoT
- Backup em cloud
- Análise de dados históricos

### Fase 4 - IA e Automação
- Detecção de anomalias
- Automações baseadas em padrões
- Manutenção preditiva

## 📝 Boas Práticas

### Nomenclatura de Tópicos
- Usar lowercase com underscore
- UUID único por dispositivo
- Versioning em tópicos críticos
- Evitar caracteres especiais

### Payloads
- JSON para legibilidade
- MessagePack para performance (futuro)
- Sempre incluir timestamp
- Versioning de schema

### Conexão
- Reconnect automático com backoff
- Last Will Testament configurado
- Client ID único e persistente
- Clean session = false para QoS > 0

## 🛠️ Ferramentas de Debug

### Linha de Comando
```bash
# Subscrever em todos os tópicos
mosquitto_sub -h localhost -t "autocore/#" -v

# Publicar mensagem de teste
mosquitto_pub -h localhost -t "autocore/test" -m '{"test": true}'

# Monitor de performance
mosquitto_sub -h localhost -t "$SYS/#" -v
```

### GUI
- MQTT Explorer (Windows/Mac/Linux)
- MQTT.fx (Java-based)
- MQTTLens (Chrome extension)

### Programático
- Config App - Monitor MQTT
- Flutter App - Debug console
- Gateway logs - `/var/log/autocore/`

---

**Última Atualização:** 12 de Agosto de 2025  
**Versão:** 2.1.0  
**Maintainer:** AutoCore Team

### Changelog
- v2.1.0 - Removida configuração via MQTT (migrado para API REST)
- v2.1.0 - Atualizada estrutura de tópicos e fluxos
- v2.0.0 - Adicionado sistema de heartbeat para relés momentâneos
- v2.0.0 - Documentado papel específico de cada componente
- v2.0.0 - Adicionada matriz de responsabilidades
- v1.0.0 - Documentação inicial da arquitetura MQTT