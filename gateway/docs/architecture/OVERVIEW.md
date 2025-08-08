# Arquitetura do AutoCore Gateway

## 🎯 Visão Geral

O AutoCore Gateway é o hub central de comunicação MQTT do sistema AutoCore, responsável por orquestrar toda comunicação com dispositivos ESP32 distribuídos no veículo.

## 🏗️ Arquitetura de Alto Nível

```
┌─────────────────────────────────────────────────────────────┐
│                    AutoCore Ecosystem                        │
├─────────────────────────────────────────────────────────────┤
│  Config App          │  Gateway (MQTT Hub)  │  Database      │
│  ┌─────────────┐     │  ┌─────────────────┐  │  ┌───────────┐ │
│  │ Web UI      │────▶│  │ MQTT Client     │◀─┼─▶│ SQLite    │ │
│  │ REST API    │     │  │ Message Handler │  │  │ Shared    │ │
│  │ Device Mgmt │     │  │ Device Manager  │  │  │ Repos     │ │
│  └─────────────┘     │  │ Telemetry Svc   │  │  └───────────┘ │
│                      │  └─────────────────┘  │               │
└─────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │    MQTT Broker        │
                    │   (Mosquitto)         │
                    └───────────┬───────────┘
                                │
    ┌───────────────┬───────────┼───────────┬───────────────┐
    │               │           │           │               │
┌───▼────┐  ┌───────▼──┐  ┌────▼────┐  ┌───▼────┐  ┌──────▼───┐
│ESP32   │  │ESP32     │  │ESP32    │  │ESP32   │  │ESP32     │
│Display │  │Relay     │  │CAN      │  │Mobile  │  │Sensors   │
│Small   │  │Board     │  │Gateway  │  │Device  │  │Board     │
└────────┘  └──────────┘  └─────────┘  └────────┘  └──────────┘
```

## 📦 Componentes Principais

### 1. Core Components (`src/core/`)

#### Config (`config.py`)
- **Responsabilidade**: Gerenciamento de configurações
- **Funcionalidades**:
  - Carregamento de variáveis de ambiente
  - Definição de tópicos MQTT
  - Validação de paths e dependências
  - Geração de tópicos específicos por dispositivo

#### MQTT Client (`mqtt_client.py`)
- **Responsabilidade**: Comunicação MQTT assíncrona
- **Funcionalidades**:
  - Conexão e reconexão automática
  - Subscrição a tópicos do sistema
  - Publicação com QoS diferenciado
  - Estatísticas de comunicação
  - Last Will Testament

#### Message Handler (`message_handler.py`)
- **Responsabilidade**: Processamento de mensagens MQTT
- **Funcionalidades**:
  - Roteamento por tipo de mensagem
  - Validação de payloads JSON
  - Context tracking com timestamps
  - Tratamento de erros

#### Device Manager (`device_manager.py`)
- **Responsabilidade**: Gestão de dispositivos ESP32
- **Funcionalidades**:
  - Cache em memória de dispositivos
  - Sincronização com database
  - Detecção de offline por timeout
  - Gerenciamento de comandos

### 2. Services (`src/services/`)

#### Telemetry Service (`telemetry_service.py`)
- **Responsabilidade**: Pipeline de telemetria
- **Funcionalidades**:
  - Buffer inteligente com flush automático
  - Processamento de múltiplas fontes
  - Batch processing para performance
  - Armazenamento estruturado

### 3. Gateway Main (`src/main.py`)
- **Responsabilidade**: Orquestração do sistema
- **Funcionalidades**:
  - Inicialização de componentes
  - Loop principal com heartbeat
  - Shutdown graceful
  - Tratamento de sinais

## 🔄 Fluxo de Dados

### 1. Inicialização
```
Gateway Start → Load Config → Init Database → 
Connect MQTT → Subscribe Topics → Start Main Loop
```

### 2. Device Discovery
```
ESP32 → MQTT Publish (announce) → Message Handler → 
Device Manager → Database Update → Cache Update
```

### 3. Telemetry Flow
```
ESP32 Sensors → MQTT Publish (telemetry) → Message Handler →
Telemetry Service → Buffer → Batch Storage → Database
```

### 4. Command Flow
```
Config App → REST API → Database → Gateway Poll →
MQTT Publish (command) → ESP32 → Response → Update Status
```

## 🎭 Padrões Arquiteturais

### 1. **Repository Pattern**
- Database abstraction através de repositories compartilhados
- Separação entre lógica de negócio e persistência

### 2. **Observer Pattern** 
- Message handlers reagem a tipos específicos de mensagens
- Event-driven architecture

### 3. **Strategy Pattern**
- Diferentes processadores para tipos de telemetria
- Flexibilidade para novos tipos de sensores

### 4. **Factory Pattern**
- Criação de contextos de mensagem
- Geração de tópicos MQTT

## 🔐 Segurança

### 1. **MQTT Security**
- Autenticação opcional com username/password
- TLS encryption (configurável)
- Topic validation
- QoS levels por tipo de mensagem

### 2. **Input Validation**
- JSON schema validation
- Topic pattern matching
- Device UUID verification

### 3. **Rate Limiting**
- Implicit via MQTT QoS
- Message timeout handling
- Device timeout detection

## 📊 Performance

### 1. **Asynchronous Operations**
- Full asyncio implementation
- Non-blocking I/O operations
- Concurrent message processing

### 2. **Memory Optimization**
- Device cache with LRU eviction
- Telemetry buffering
- Batch database operations

### 3. **Resource Management**
- Connection pooling
- Graceful shutdown
- Memory usage monitoring

## 🔧 Configurabilidade

### 1. **Environment Variables**
- MQTT broker settings
- Database paths
- Performance tuning
- Logging configuration

### 2. **Topic Structure**
- Flexible topic patterns
- Device-specific routing
- Message type classification

### 3. **Service Parameters**
- Buffer sizes
- Timeout values
- Batch intervals
- Log levels

## 🚀 Escalabilidade

### 1. **Horizontal Scaling**
- Multiple gateway instances (futuro)
- Load balancing via MQTT broker
- Shared database state

### 2. **Vertical Scaling**
- Configurable performance parameters
- Memory usage optimization
- Efficient data structures

### 3. **Device Scaling**
- Dynamic device discovery
- Automatic topic subscription
- Efficient message routing

---

Esta arquitetura garante:
- ✅ **Confiabilidade**: Auto-reconexão e error handling
- ✅ **Performance**: Operações assíncronas e batching
- ✅ **Escalabilidade**: Design modular e configurável  
- ✅ **Manutenibilidade**: Separação clara de responsabilidades
- ✅ **Flexibilidade**: Extensível para novos tipos de dispositivos