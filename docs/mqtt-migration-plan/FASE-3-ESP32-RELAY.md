# 🔧 FASE 3: Correção do ESP32-Relay - MQTT v2.2.0

## 📊 Resumo
- **Componente**: ESP32 Relay (PlatformIO)
- **Criticidade**: MÉDIA (controle de relés)
- **Violações identificadas**: 8
- **Esforço estimado**: 10-14 horas
- **Prioridade**: P1 (Após Gateway e Config-App)

## 🔍 Análise de Violações

### 1. Configuração via MQTT (CRÍTICO)
**Arquivo**: `firmware/esp32-relay/src/mqtt/mqtt_handler.cpp`
**Linhas**: 44-46, 174-189

#### Atual (INCORRETO):
```cpp
void MQTTHandler::handleMessage(const String& topic, const String& payload) {
    if (topic.endsWith("/relay/command")) {
        handleRelayCommand(payload);
    } 
    else if (topic.endsWith("/config")) {  // VIOLAÇÃO!
        handleConfiguration(payload);
    }
    else if (topic.endsWith("/heartbeat")) {
        handleHeartbeat(payload);
    }
}

void MQTTHandler::handleConfiguration(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Processando configuração via MQTT");
    // TODO: Implementar processamento de configuração
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, payload);
    // ... processamento ...
}
```

#### Correção (v2.2.0):
```cpp
void MQTTHandler::handleMessage(const String& topic, const String& payload) {
    // Remover completamente handler de configuração
    if (topic.endsWith("/relays/set")) {  // Corrigido: relay → relays
        handleRelayCommand(payload);
    }
    else if (topic.endsWith("/relays/heartbeat")) {  // Corrigido: path
        handleHeartbeat(payload);
    }
    // Configuração agora é feita via API REST no boot
}

// DELETAR handleConfiguration completamente

// Adicionar no setup():
void MQTTHandler::setup() {
    // Buscar configuração via API REST
    fetchConfigurationFromAPI();
    
    // Subscrever apenas tópicos operacionais
    subscribeOperationalTopics();
}

void MQTTHandler::fetchConfigurationFromAPI() {
    HTTPClient http;
    String configUrl = String("http://") + config.api_host + 
                      "/api/devices/" + config.device_uuid + "/config";
    
    http.begin(configUrl);
    int httpCode = http.GET();
    
    if (httpCode == 200) {
        String payload = http.getString();
        applyConfiguration(payload);
    }
    http.end();
}
```

### 2. Tópicos Incorretos
**Arquivo**: `firmware/esp32-relay/src/mqtt/mqtt_client.cpp`
**Linhas**: 241-244

#### Atual (INCORRETO):
```cpp
void MQTTClient::subscribeToTopics() {
    String relayCommandTopic = "autocore/devices/" + deviceId + "/relay/command";
    String heartbeatTopic = "autocore/devices/" + deviceId + "/heartbeat";
    String configTopic = "autocore/devices/" + deviceId + "/config";
    
    subscribe(relayCommandTopic, 1);
    subscribe(heartbeatTopic, 0);  // QoS incorreto!
    subscribe(configTopic, 2);     // Não deve existir!
}
```

#### Correção (v2.2.0):
```cpp
void MQTTClient::subscribeToTopics() {
    // Tópicos corrigidos conforme v2.2.0
    String relaySetTopic = "autocore/devices/" + deviceId + "/relays/set";
    String heartbeatTopic = "autocore/devices/" + deviceId + "/relays/heartbeat";
    String broadcastTopic = "autocore/system/broadcast";
    String commandsTopic = "autocore/commands/all/+";
    
    // QoS corretos
    subscribe(relaySetTopic, 1);      // QoS 1 para comandos
    subscribe(heartbeatTopic, 1);     // QoS 1 para heartbeat (garantia)
    subscribe(broadcastTopic, 0);     // QoS 0 para broadcast
    subscribe(commandsTopic, 1);       // QoS 1 para comandos globais
    
    LOG_INFO("Subscribed to v2.2.0 compliant topics");
}

void MQTTClient::publishState() {
    String stateTopic = "autocore/devices/" + deviceId + "/relays/state";
    
    DynamicJsonDocument doc(512);
    doc["protocol_version"] = "2.2.0";  // OBRIGATÓRIO
    doc["uuid"] = deviceId;
    doc["board_id"] = BOARD_ID;
    doc["timestamp"] = getISOTimestamp();
    
    JsonObject channels = doc.createNestedObject("channels");
    for (int i = 1; i <= NUM_CHANNELS; i++) {
        channels[String(i)] = relayController->getState(i);
    }
    
    String payload;
    serializeJson(doc, payload);
    
    publish(stateTopic, payload, 1, true);  // QoS 1, retained
}
```

### 3. Heartbeat Incompleto
**Arquivo**: `firmware/esp32-relay/src/mqtt/mqtt_handler.cpp`
**Linhas**: 128-172

#### Atual (INCOMPLETO):
```cpp
void MQTTHandler::handleHeartbeat(const String& payload) {
    DynamicJsonDocument doc(256);
    deserializeJson(doc, payload);
    
    int channel = doc["channel"];
    
    // Implementação básica sem timeout adequado
    lastHeartbeat[channel] = millis();
    
    // Falta lógica de safety shutoff
}
```

#### Correção (v2.2.0):
```cpp
// mqtt_handler.h
class MQTTHandler {
private:
    struct HeartbeatMonitor {
        unsigned long lastReceived = 0;
        String sourceUuid = "";
        int sequence = 0;
        bool active = false;
    };
    
    HeartbeatMonitor heartbeatMonitors[MAX_CHANNELS];
    static const unsigned long HEARTBEAT_TIMEOUT = 1000;  // 1 segundo
    static const unsigned long HEARTBEAT_INTERVAL = 500;  // Esperado a cada 500ms
    
public:
    void checkHeartbeatTimeouts();
};

// mqtt_handler.cpp
void MQTTHandler::handleHeartbeat(const String& payload) {
    DynamicJsonDocument doc(512);
    DeserializationError error = deserializeJson(doc, payload);
    
    if (error) {
        publishError("ERR_002", "INVALID_PAYLOAD", "Invalid heartbeat format");
        return;
    }
    
    // Validar protocol_version
    if (!doc.containsKey("protocol_version")) {
        publishError("ERR_008", "PROTOCOL_MISMATCH", "Missing protocol_version");
        return;
    }
    
    String version = doc["protocol_version"];
    if (!version.startsWith("2.")) {
        publishError("ERR_008", "PROTOCOL_MISMATCH", "Incompatible version: " + version);
        return;
    }
    
    int channel = doc["channel"];
    String sourceUuid = doc["source_uuid"];
    int sequence = doc["sequence"];
    
    if (channel < 1 || channel > MAX_CHANNELS) {
        publishError("ERR_001", "COMMAND_FAILED", "Invalid channel: " + String(channel));
        return;
    }
    
    // Atualizar monitor de heartbeat
    HeartbeatMonitor& monitor = heartbeatMonitors[channel - 1];
    
    // Verificar se é um novo heartbeat ou continuação
    if (!monitor.active || monitor.sourceUuid != sourceUuid) {
        monitor.sourceUuid = sourceUuid;
        monitor.active = true;
        LOG_INFO("Started heartbeat monitoring for channel " + String(channel));
    }
    
    // Verificar sequência (detectar perda de pacotes)
    if (monitor.sequence > 0 && sequence != monitor.sequence + 1) {
        LOG_WARN("Heartbeat sequence gap detected. Expected: " + 
                String(monitor.sequence + 1) + ", Got: " + String(sequence));
    }
    
    monitor.lastReceived = millis();
    monitor.sequence = sequence;
    
    // Manter relé ligado enquanto recebe heartbeat
    if (relayController->getFunctionType(channel) == MOMENTARY) {
        relayController->setState(channel, true);
    }
}

void MQTTHandler::checkHeartbeatTimeouts() {
    unsigned long now = millis();
    
    for (int i = 0; i < MAX_CHANNELS; i++) {
        HeartbeatMonitor& monitor = heartbeatMonitors[i];
        
        if (monitor.active) {
            unsigned long elapsed = now - monitor.lastReceived;
            
            if (elapsed > HEARTBEAT_TIMEOUT) {
                // SAFETY SHUTOFF!
                int channel = i + 1;
                
                LOG_WARN("Heartbeat timeout on channel " + String(channel));
                
                // Desligar relé imediatamente
                if (relayController->getFunctionType(channel) == MOMENTARY) {
                    relayController->setState(channel, false);
                    
                    // Publicar evento de safety shutoff
                    publishSafetyShutoffEvent(channel, monitor.sourceUuid, 
                                             monitor.lastReceived);
                }
                
                // Resetar monitor
                monitor.active = false;
                monitor.sourceUuid = "";
                monitor.sequence = 0;
            }
        }
    }
}

void MQTTHandler::publishSafetyShutoffEvent(int channel, String sourceUuid, 
                                            unsigned long lastHeartbeat) {
    String topic = "autocore/telemetry/relays/data";
    
    DynamicJsonDocument doc(512);
    doc["protocol_version"] = "2.2.0";
    doc["uuid"] = deviceId;
    doc["board_id"] = BOARD_ID;
    doc["event"] = "safety_shutoff";
    doc["channel"] = channel;
    doc["reason"] = "heartbeat_timeout";
    doc["timeout_ms"] = HEARTBEAT_TIMEOUT;
    doc["source_uuid"] = sourceUuid;
    doc["last_heartbeat"] = getISOTimestamp(lastHeartbeat);
    doc["timestamp"] = getISOTimestamp();
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, 1);  // QoS 1
}

// Adicionar no loop principal:
void loop() {
    mqttHandler.checkHeartbeatTimeouts();  // Verificar a cada loop
    // ... resto do loop ...
}
```

### 4. Falta Protocol Version nos Payloads
**Arquivo**: `firmware/esp32-relay/src/mqtt/mqtt_handler.cpp`
**Múltiplas ocorrências**

#### Implementação de Classe Base:
```cpp
// mqtt_message.h - Nova classe base para mensagens
class MQTTMessage {
protected:
    static const char* PROTOCOL_VERSION = "2.2.0";
    
    void addBaseFields(JsonDocument& doc, const String& deviceUuid) {
        doc["protocol_version"] = PROTOCOL_VERSION;
        doc["uuid"] = deviceUuid;
        doc["timestamp"] = getISOTimestamp();
    }
    
    bool validateIncomingMessage(const JsonDocument& doc) {
        if (!doc.containsKey("protocol_version")) {
            LOG_ERROR("Missing protocol_version");
            return false;
        }
        
        String version = doc["protocol_version"];
        if (!version.startsWith("2.")) {
            LOG_ERROR("Incompatible protocol version: " + version);
            return false;
        }
        
        return true;
    }
    
public:
    static String getISOTimestamp() {
        // Implementar timestamp ISO 8601
        time_t now;
        time(&now);
        char buf[30];
        strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", gmtime(&now));
        return String(buf);
    }
};
```

### 5. Last Will Testament Ausente
**Arquivo**: `firmware/esp32-relay/src/mqtt/mqtt_client.cpp`
**Linha**: Conexão MQTT

#### Atual (SEM LWT):
```cpp
void MQTTClient::connect() {
    client.setServer(broker, port);
    client.connect(clientId.c_str());
}
```

#### Correção (v2.2.0):
```cpp
void MQTTClient::connect() {
    // Preparar Last Will Testament
    String lwtTopic = "autocore/devices/" + deviceId + "/status";
    
    DynamicJsonDocument lwtDoc(256);
    lwtDoc["protocol_version"] = "2.2.0";
    lwtDoc["uuid"] = deviceId;
    lwtDoc["status"] = "offline";
    lwtDoc["timestamp"] = getISOTimestamp();
    lwtDoc["reason"] = "unexpected_disconnect";
    lwtDoc["last_seen"] = getISOTimestamp();
    
    String lwtPayload;
    serializeJson(lwtDoc, lwtPayload);
    
    // Configurar cliente com LWT
    client.setServer(broker, port);
    
    // Conectar com LWT
    bool connected = client.connect(
        clientId.c_str(),
        nullptr,           // username (se houver)
        nullptr,           // password (se houver)
        lwtTopic.c_str(),  // will topic
        1,                 // will QoS
        true,              // will retain
        lwtPayload.c_str() // will message
    );
    
    if (connected) {
        LOG_INFO("Connected with LWT configured");
        publishOnlineStatus();
    }
}

void MQTTClient::publishOnlineStatus() {
    String statusTopic = "autocore/devices/" + deviceId + "/status";
    
    DynamicJsonDocument doc(512);
    doc["protocol_version"] = "2.2.0";
    doc["uuid"] = deviceId;
    doc["status"] = "online";
    doc["timestamp"] = getISOTimestamp();
    doc["firmware_version"] = FIRMWARE_VERSION;
    doc["ip_address"] = WiFi.localIP().toString();
    doc["wifi_signal"] = WiFi.RSSI();
    doc["free_memory"] = ESP.getFreeHeap();
    doc["uptime"] = millis() / 1000;
    
    String payload;
    serializeJson(doc, payload);
    
    publish(statusTopic, payload, 1, true);  // QoS 1, retained
}
```

### 6. Telemetria com UUID no Tópico
**Arquivo**: `firmware/esp32-relay/src/mqtt/mqtt_handler.cpp`

#### Atual:
```cpp
void MQTTHandler::publishTelemetry() {
    String topic = "autocore/devices/" + deviceId + "/telemetry";
    // ...
}
```

#### Correção:
```cpp
void MQTTHandler::publishTelemetry() {
    // UUID agora vai apenas no payload, não no tópico
    String topic = "autocore/telemetry/relays/data";
    
    DynamicJsonDocument doc(1024);
    doc["protocol_version"] = "2.2.0";
    doc["uuid"] = deviceId;  // UUID no payload!
    doc["board_id"] = BOARD_ID;
    doc["timestamp"] = getISOTimestamp();
    
    // Adicionar métricas
    JsonObject metrics = doc.createNestedObject("metrics");
    metrics["uptime"] = millis() / 1000;
    metrics["free_heap"] = ESP.getFreeHeap();
    metrics["wifi_rssi"] = WiFi.RSSI();
    metrics["temperature"] = readInternalTemperature();
    
    // Estados dos relés
    JsonObject channels = doc.createNestedObject("channels");
    for (int i = 1; i <= NUM_CHANNELS; i++) {
        JsonObject ch = channels.createNestedObject(String(i));
        ch["state"] = relayController->getState(i);
        ch["function_type"] = relayController->getFunctionTypeString(i);
        ch["activation_count"] = relayController->getActivationCount(i);
    }
    
    String payload;
    serializeJson(doc, payload);
    
    publish(topic, payload, 0);  // QoS 0 para telemetria
}
```

### 7. Tratamento de Erros
**Novo arquivo**: `firmware/esp32-relay/src/mqtt/error_handler.cpp`

```cpp
// error_handler.h
#ifndef ERROR_HANDLER_H
#define ERROR_HANDLER_H

enum ErrorCode {
    ERR_001_COMMAND_FAILED,
    ERR_002_INVALID_PAYLOAD,
    ERR_003_TIMEOUT,
    ERR_004_UNAUTHORIZED,
    ERR_005_DEVICE_BUSY,
    ERR_006_HARDWARE_FAULT,
    ERR_007_NETWORK_ERROR,
    ERR_008_PROTOCOL_MISMATCH
};

class ErrorHandler {
private:
    MQTTClient* mqttClient;
    String deviceUuid;
    
public:
    ErrorHandler(MQTTClient* client, const String& uuid);
    
    void publishError(const String& code, const String& type, 
                     const String& message, JsonDocument* context = nullptr);
    
    static const char* getErrorCodeString(ErrorCode code);
    static const char* getErrorTypeString(ErrorCode code);
};

#endif

// error_handler.cpp
#include "error_handler.h"

void ErrorHandler::publishError(const String& code, const String& type,
                               const String& message, JsonDocument* context) {
    String topic = "autocore/errors/" + deviceUuid + "/" + type.toLowerCase();
    
    DynamicJsonDocument doc(512);
    doc["protocol_version"] = "2.2.0";
    doc["uuid"] = deviceUuid;
    doc["error_code"] = code;
    doc["error_type"] = type;
    doc["error_message"] = message;
    doc["timestamp"] = MQTTMessage::getISOTimestamp();
    
    if (context != nullptr) {
        doc["context"] = *context;
    }
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, 1);  // QoS 1 para erros
    
    LOG_ERROR(code + ": " + message);
}
```

### 8. Configuração de QoS
**Arquivo**: `firmware/esp32-relay/src/config/device_config.h`

```cpp
// device_config.h - Adicionar constantes de QoS
#ifndef DEVICE_CONFIG_H
#define DEVICE_CONFIG_H

// Configurações MQTT v2.2.0
#define MQTT_PROTOCOL_VERSION "2.2.0"

// QoS Levels conforme arquitetura v2.2.0
#define QOS_TELEMETRY    0  // Fire and forget
#define QOS_COMMANDS     1  // At least once
#define QOS_HEARTBEAT    1  // At least once
#define QOS_STATUS       1  // At least once
#define QOS_CRITICAL     2  // Exactly once (apenas comandos críticos)

// Timeouts
#define HEARTBEAT_TIMEOUT_MS     1000  // 1 segundo
#define HEARTBEAT_INTERVAL_MS    500   // 500ms
#define STATUS_PUBLISH_INTERVAL  30000 // 30 segundos

// Limites
#define MAX_MESSAGES_PER_SECOND  100
#define MAX_PAYLOAD_SIZE         65536  // 64KB

// UUID Format
#define DEVICE_UUID_FORMAT "esp32-relay-%03d"  // esp32-relay-001

#endif
```

## 📝 Implementação Passo a Passo

### Passo 1: Backup e Branch
```bash
cd firmware/esp32-relay
git checkout -b fix/mqtt-v2.2.0-esp32-relay
cp -r src src.backup
```

### Passo 2: Remover Configuração via MQTT
1. Deletar `handleConfiguration()` de mqtt_handler.cpp
2. Remover subscrição do tópico `/config`
3. Implementar `fetchConfigurationFromAPI()`

### Passo 3: Corrigir Tópicos
1. Find/replace: `/relay/` → `/relays/`
2. Atualizar todas as subscrições
3. Corrigir publicações

### Passo 4: Implementar Protocol Version
1. Criar classe base `MQTTMessage`
2. Adicionar em todos os payloads
3. Validar em mensagens recebidas

### Passo 5: Implementar Heartbeat Completo
1. Criar `HeartbeatMonitor` struct
2. Implementar timeout de 1 segundo
3. Adicionar safety shutoff
4. Publicar eventos

### Passo 6: Configurar LWT
1. Modificar conexão MQTT
2. Adicionar payload de LWT
3. Publicar status online após conectar

### Passo 7: Implementar Error Handler
1. Criar error_handler.cpp/h
2. Integrar em todos os handlers
3. Substituir logs por erros padronizados

### Passo 8: Testes
```cpp
// test/test_mqtt_conformance.cpp
#include <unity.h>
#include "../src/mqtt/mqtt_handler.h"

void test_protocol_version_in_payload() {
    DynamicJsonDocument doc(256);
    MQTTHandler handler;
    
    handler.createStatusPayload(doc);
    
    TEST_ASSERT_TRUE(doc.containsKey("protocol_version"));
    TEST_ASSERT_EQUAL_STRING("2.2.0", doc["protocol_version"]);
}

void test_heartbeat_timeout() {
    MQTTHandler handler;
    
    // Simular heartbeat
    String heartbeat = R"({
        "protocol_version": "2.2.0",
        "channel": 1,
        "source_uuid": "test-001",
        "sequence": 1
    })";
    
    handler.handleHeartbeat(heartbeat);
    
    // Esperar mais que timeout
    delay(1100);
    
    handler.checkHeartbeatTimeouts();
    
    // Verificar se relé foi desligado
    TEST_ASSERT_FALSE(relayController.getState(1));
}

void test_topic_structure() {
    MQTTClient client;
    
    String topic = client.getRelaySetTopic();
    TEST_ASSERT_TRUE(topic.startsWith("autocore/devices/"));
    TEST_ASSERT_TRUE(topic.endsWith("/relays/set"));
}

void setup() {
    UNITY_BEGIN();
    
    RUN_TEST(test_protocol_version_in_payload);
    RUN_TEST(test_heartbeat_timeout);
    RUN_TEST(test_topic_structure);
    
    UNITY_END();
}

void loop() {}
```

## 🧪 Validação

### Checklist de Validação
- [ ] Configuração removida do MQTT (apenas API REST)
- [ ] Todos os tópicos seguem padrão v2.2.0
- [ ] Protocol version em todos os payloads
- [ ] Heartbeat com timeout de 1 segundo funcionando
- [ ] Safety shutoff automático implementado
- [ ] LWT configurado e funcionando
- [ ] QoS correto para cada tipo de mensagem
- [ ] Telemetria sem UUID no tópico
- [ ] Error handler implementado
- [ ] Testes passando 100%

### Comando de Build e Upload
```bash
# Compilar
pio run -e esp32

# Executar testes
pio test -e native

# Upload para dispositivo
pio run -t upload -e esp32

# Monitor serial
pio device monitor
```

## 📊 Métricas de Sucesso
- ✅ 8/8 violações corrigidas
- ✅ 100% dos payloads com protocol_version
- ✅ Heartbeat timeout funcionando
- ✅ 0 configurações via MQTT
- ✅ LWT ativo
- ✅ Todos os tópicos conformes

## 🚀 Deploy
1. Testar em dispositivo de desenvolvimento
2. Validar heartbeat com Config-App
3. Testar safety shutoff
4. Deploy em dispositivos de produção via OTA

## 📝 Notas Importantes
- **CRÍTICO**: Testar exaustivamente safety shutoff
- Heartbeat é feature de segurança - não pode falhar
- Manter logs detalhados durante migração
- Considerar rollback plan se necessário

---
**Criado em**: 12/08/2025  
**Status**: Documentado  
**Estimativa**: 10-14 horas  
**Complexidade**: Alta (feature crítica de segurança)