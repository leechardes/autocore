# 📱 FASE 5: Correção do ESP32-Display-v2 - MQTT v2.2.0

## 📊 Resumo
- **Componente**: ESP32 Display v2 (Touch Interface)
- **Criticidade**: ALTA (interface principal do usuário)
- **Violações identificadas**: 15 (MAIS CRÍTICO!)
- **Esforço estimado**: 16-20 horas
- **Prioridade**: P2 (Complexo - fazer após componentes centrais)

## 🚨 AVISO CRÍTICO
Este componente usa prefixo `autotech/` em TODOS os lugares. Requer refatoração extensiva.

## 🔍 Análise de Violações

### 1. Prefixo Incorreto GLOBAL (CRÍTICO!)
**Múltiplos arquivos afetados**
- `src/core/MQTTClient.cpp`
- `src/commands/CommandSender.cpp`
- `src/communication/*.cpp`

#### Script de Correção Global:
```bash
#!/bin/bash
# fix_autotech_prefix.sh

echo "Corrigindo prefixo autotech -> autocore em ESP32-Display-v2"

# Fazer backup primeiro
cp -r firmware/esp32-display-v2 firmware/esp32-display-v2.backup

# Corrigir em todos os arquivos .cpp e .h
find firmware/esp32-display-v2 -type f \( -name "*.cpp" -o -name "*.h" \) -exec \
    sed -i 's/autotech\//autocore\//g' {} \;

# Verificar mudanças
echo "Arquivos modificados:"
grep -r "autocore/" firmware/esp32-display-v2 --include="*.cpp" --include="*.h" | head -20

echo "Verificando se ainda existe 'autotech':"
grep -r "autotech" firmware/esp32-display-v2 --include="*.cpp" --include="*.h"
```

### 2. MQTTClient.cpp - Múltiplas Violações
**Arquivo**: `firmware/esp32-display-v2/src/core/MQTTClient.cpp`

#### Atual (TOTALMENTE INCORRETO):
```cpp
// Linhas 52, 74, 238
void MQTTClient::setup() {
    String willTopic = "autotech/" + deviceId + "/status";  // ERRO!
    String willMessage = "{\"status\":\"offline\"}";  // Sem protocol_version!
    
    client.setWill(willTopic.c_str(), 0, false, willMessage.c_str());
    
    // ...
}

void MQTTClient::publishStatus() {
    String topic = "autotech/" + deviceId + "/status";  // ERRO!
    
    StaticJsonDocument<256> doc;
    doc["status"] = "online";
    doc["timestamp"] = millis();  // Não é ISO 8601!
    // Falta protocol_version!
    
    publish(topic, doc);
}

void MQTTClient::subscribeToTopics() {
    subscribe("autotech/gateway/response");  // ERRO!
    subscribe("autotech/" + deviceId + "/command");  // ERRO!
    subscribe("autotech/broadcast");  // ERRO!
}
```

#### Correção (v2.2.0):
```cpp
// MQTTClient.cpp CORRIGIDO
#include "MQTTProtocol.h"  // Nova classe base

void MQTTClient::setup() {
    // Preparar LWT conforme v2.2.0
    String willTopic = "autocore/devices/" + deviceId + "/status";
    
    StaticJsonDocument<256> willDoc;
    willDoc["protocol_version"] = MQTT_PROTOCOL_VERSION;
    willDoc["uuid"] = deviceId;
    willDoc["status"] = "offline";
    willDoc["timestamp"] = getISOTimestamp();
    willDoc["reason"] = "unexpected_disconnect";
    willDoc["last_seen"] = getISOTimestamp();
    
    String willMessage;
    serializeJson(willDoc, willMessage);
    
    // QoS 1, Retain true para LWT
    client.setWill(willTopic.c_str(), 1, true, willMessage.c_str());
    
    client.setServer(MQTT_BROKER, MQTT_PORT);
    client.setCallback([this](char* topic, byte* payload, unsigned int length) {
        this->onMessage(String(topic), payload, length);
    });
    
    client.setBufferSize(1024);  // Aumentar buffer para payloads maiores
}

void MQTTClient::publishStatus() {
    String topic = "autocore/devices/" + deviceId + "/status";
    
    StaticJsonDocument<512> doc;
    doc["protocol_version"] = MQTT_PROTOCOL_VERSION;
    doc["uuid"] = deviceId;
    doc["status"] = "online";
    doc["timestamp"] = getISOTimestamp();
    doc["firmware_version"] = FIRMWARE_VERSION;
    doc["ip_address"] = WiFi.localIP().toString();
    doc["wifi_signal"] = WiFi.RSSI();
    doc["free_memory"] = ESP.getFreeHeap();
    doc["uptime"] = millis() / 1000;
    doc["display_type"] = "touch_2.4";
    doc["capabilities"]["touch"] = true;
    doc["capabilities"]["color"] = true;
    doc["capabilities"]["resolution"] = "320x240";
    
    publish(topic, doc, 1, true);  // QoS 1, Retained
}

void MQTTClient::subscribeToTopics() {
    // Tópicos corretos v2.2.0
    String deviceBase = "autocore/devices/" + deviceId;
    
    // Comandos para display
    subscribe(deviceBase + "/display/screen", 1);
    subscribe(deviceBase + "/display/config", 1);
    
    // Status de relés para exibir
    subscribe("autocore/devices/+/relays/state", 0);
    
    // Telemetria (sem UUID no tópico!)
    subscribe("autocore/telemetry/relays/data", 0);
    subscribe("autocore/telemetry/can/+", 0);
    
    // Sistema
    subscribe("autocore/system/broadcast", 0);
    subscribe("autocore/system/alert", 1);
    
    // Erros para exibir
    subscribe("autocore/errors/+/+", 1);
    
    Logger::info("MQTT", "Subscribed to v2.2.0 compliant topics");
}

// Nova função para validar protocol_version
bool MQTTClient::validateMessage(const JsonDocument& doc) {
    if (!doc.containsKey("protocol_version")) {
        Logger::warn("MQTT", "Message without protocol_version");
        publishError("ERR_008", "PROTOCOL_MISMATCH", "Missing protocol_version");
        return false;
    }
    
    String version = doc["protocol_version"];
    if (!version.startsWith("2.")) {
        Logger::error("MQTT", "Incompatible version: " + version);
        publishError("ERR_008", "PROTOCOL_MISMATCH", "Version " + version + " not supported");
        return false;
    }
    
    return true;
}
```

### 3. CommandSender.cpp - Comandos Totalmente Incorretos
**Arquivo**: `firmware/esp32-display-v2/src/commands/CommandSender.cpp`

#### Atual (MÚLTIPLOS ERROS):
```cpp
// Linhas 110, 129, 147, 185, 214
void CommandSender::sendRelayCommand(String deviceId, int channel, bool state) {
    String topic = "autotech/gateway/command";  // ERRO!
    
    StaticJsonDocument<256> doc;
    doc["type"] = "relay";
    doc["device"] = deviceId;
    doc["channel"] = channel;
    doc["state"] = state;
    doc["timestamp"] = millis();  // Não é ISO!
    // Falta protocol_version!
    
    mqttClient->publish(topic, doc);
}

void CommandSender::sendHeartbeat(String deviceId, int channel) {
    String topic = "autotech/" + deviceId + "/heartbeat";  // ERRO!
    
    StaticJsonDocument<128> doc;
    doc["channel"] = channel;
    doc["timestamp"] = millis();
    // Falta source_uuid, target_uuid, sequence!
    
    mqttClient->publish(topic, doc);
}
```

#### Correção (v2.2.0):
```cpp
// CommandSender.cpp CORRIGIDO
class CommandSender {
private:
    uint32_t heartbeatSequence[MAX_CHANNELS] = {0};
    unsigned long lastHeartbeat[MAX_CHANNELS] = {0};
    bool heartbeatActive[MAX_CHANNELS] = {false};
    
public:
    void sendRelayCommand(String targetUuid, int channel, bool state, 
                         String functionType = "toggle") {
        String topic = "autocore/devices/" + targetUuid + "/relays/set";
        
        StaticJsonDocument<384> doc;
        doc["protocol_version"] = MQTT_PROTOCOL_VERSION;
        doc["channel"] = channel;
        doc["state"] = state;
        doc["function_type"] = functionType;
        doc["user"] = "display_touch";
        doc["source_uuid"] = deviceId;  // Quem está enviando
        doc["timestamp"] = getISOTimestamp();
        
        mqttClient->publish(topic, doc, 1);  // QoS 1 para comandos
        
        Logger::info("CMD", "Sent " + functionType + " command to " + 
                    targetUuid + " ch:" + String(channel));
        
        // Se for momentâneo, iniciar heartbeat
        if (functionType == "momentary" && state == true) {
            startHeartbeat(targetUuid, channel);
        }
    }
    
    void startHeartbeat(String targetUuid, int channel) {
        if (channel < 1 || channel > MAX_CHANNELS) return;
        
        int idx = channel - 1;
        heartbeatActive[idx] = true;
        heartbeatSequence[idx] = 0;
        
        Logger::info("CMD", "Started heartbeat for channel " + String(channel));
    }
    
    void stopHeartbeat(int channel) {
        if (channel < 1 || channel > MAX_CHANNELS) return;
        
        int idx = channel - 1;
        heartbeatActive[idx] = false;
        
        Logger::info("CMD", "Stopped heartbeat for channel " + String(channel));
    }
    
    void sendHeartbeat(String targetUuid, int channel) {
        if (channel < 1 || channel > MAX_CHANNELS) return;
        
        int idx = channel - 1;
        if (!heartbeatActive[idx]) return;
        
        String topic = "autocore/devices/" + targetUuid + "/relays/heartbeat";
        
        StaticJsonDocument<384> doc;
        doc["protocol_version"] = MQTT_PROTOCOL_VERSION;
        doc["channel"] = channel;
        doc["source_uuid"] = deviceId;
        doc["target_uuid"] = targetUuid;
        doc["timestamp"] = getISOTimestamp();
        doc["sequence"] = ++heartbeatSequence[idx];
        
        mqttClient->publish(topic, doc, 1);  // QoS 1 para heartbeat
        
        lastHeartbeat[idx] = millis();
    }
    
    void processHeartbeats() {
        // Chamado no loop principal
        unsigned long now = millis();
        
        for (int i = 0; i < MAX_CHANNELS; i++) {
            if (heartbeatActive[i]) {
                if (now - lastHeartbeat[i] >= HEARTBEAT_INTERVAL_MS) {
                    // Enviar próximo heartbeat
                    sendHeartbeat(currentTargetDevice, i + 1);
                }
            }
        }
    }
    
    void sendDisplayEvent(String eventType, JsonObject eventData) {
        String topic = "autocore/devices/" + deviceId + "/display/touch";
        
        StaticJsonDocument<512> doc;
        doc["protocol_version"] = MQTT_PROTOCOL_VERSION;
        doc["uuid"] = deviceId;
        doc["event"] = eventType;
        doc["timestamp"] = getISOTimestamp();
        doc["data"] = eventData;
        
        mqttClient->publish(topic, doc, 0);  // QoS 0 para eventos
    }
};
```

### 4. Nova Classe Base MQTTProtocol
**Novo arquivo**: `firmware/esp32-display-v2/include/core/MQTTProtocol.h`

```cpp
// MQTTProtocol.h - Classe base para conformidade v2.2.0
#ifndef MQTT_PROTOCOL_H
#define MQTT_PROTOCOL_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <WiFi.h>
#include <time.h>

#define MQTT_PROTOCOL_VERSION "2.2.0"

// QoS Levels
#define QOS_TELEMETRY    0
#define QOS_COMMANDS     1
#define QOS_HEARTBEAT    1
#define QOS_STATUS       1

// Timeouts
#define HEARTBEAT_TIMEOUT_MS     1000
#define HEARTBEAT_INTERVAL_MS    500
#define STATUS_INTERVAL_MS       30000

// Limites
#define MAX_CHANNELS            16
#define MAX_PAYLOAD_SIZE        65536
#define MAX_MESSAGES_PER_SECOND 100

class MQTTProtocol {
protected:
    static String deviceId;
    static String deviceType;
    
public:
    static void initialize(const String& id, const String& type) {
        deviceId = id;
        deviceType = type;
        configTime(0, 0, "pool.ntp.org");  // Configurar NTP para timestamps
    }
    
    static String getISOTimestamp() {
        struct tm timeinfo;
        if (!getLocalTime(&timeinfo)) {
            // Fallback se NTP não estiver disponível
            return "2025-01-01T00:00:00Z";
        }
        
        char timestamp[30];
        strftime(timestamp, sizeof(timestamp), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
        return String(timestamp);
    }
    
    static String getDeviceUUID() {
        if (deviceId.isEmpty()) {
            // Gerar UUID baseado no MAC
            uint8_t mac[6];
            WiFi.macAddress(mac);
            char uuid[32];
            snprintf(uuid, sizeof(uuid), "esp32-display-%02x%02x%02x",
                    mac[3], mac[4], mac[5]);
            deviceId = String(uuid);
        }
        return deviceId;
    }
    
    static void addProtocolFields(JsonDocument& doc) {
        doc["protocol_version"] = MQTT_PROTOCOL_VERSION;
        doc["uuid"] = getDeviceUUID();
        doc["timestamp"] = getISOTimestamp();
    }
    
    static bool validateProtocolVersion(const JsonDocument& doc) {
        if (!doc.containsKey("protocol_version")) {
            return false;
        }
        
        String version = doc["protocol_version"];
        return version.startsWith("2.");
    }
};

// Códigos de erro
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
public:
    static const char* getErrorCode(ErrorCode code) {
        switch (code) {
            case ERR_001_COMMAND_FAILED: return "ERR_001";
            case ERR_002_INVALID_PAYLOAD: return "ERR_002";
            case ERR_003_TIMEOUT: return "ERR_003";
            case ERR_004_UNAUTHORIZED: return "ERR_004";
            case ERR_005_DEVICE_BUSY: return "ERR_005";
            case ERR_006_HARDWARE_FAULT: return "ERR_006";
            case ERR_007_NETWORK_ERROR: return "ERR_007";
            case ERR_008_PROTOCOL_MISMATCH: return "ERR_008";
            default: return "ERR_UNKNOWN";
        }
    }
    
    static const char* getErrorType(ErrorCode code) {
        switch (code) {
            case ERR_001_COMMAND_FAILED: return "command_failed";
            case ERR_002_INVALID_PAYLOAD: return "invalid_payload";
            case ERR_003_TIMEOUT: return "timeout";
            case ERR_004_UNAUTHORIZED: return "unauthorized";
            case ERR_005_DEVICE_BUSY: return "device_busy";
            case ERR_006_HARDWARE_FAULT: return "hardware_fault";
            case ERR_007_NETWORK_ERROR: return "network_error";
            case ERR_008_PROTOCOL_MISMATCH: return "protocol_mismatch";
            default: return "unknown";
        }
    }
};

#endif // MQTT_PROTOCOL_H
```

### 5. ButtonHandler - Integração com Heartbeat
**Arquivo**: `firmware/esp32-display-v2/src/navigation/ButtonHandler.cpp`

#### Correção para Suportar Momentary:
```cpp
// ButtonHandler.cpp - Suporte a botões momentâneos
void ButtonHandler::handleButtonPress(int buttonId) {
    Button* btn = getButton(buttonId);
    if (!btn) return;
    
    if (btn->functionType == "momentary") {
        // Iniciar comando e heartbeat
        commandSender->sendRelayCommand(
            btn->targetDevice,
            btn->channel,
            true,
            "momentary"
        );
        
        btn->isPressed = true;
        btn->pressStartTime = millis();
        
        Logger::info("BTN", "Momentary press started: " + btn->label);
    } else if (btn->functionType == "toggle") {
        // Toggle simples
        btn->state = !btn->state;
        
        commandSender->sendRelayCommand(
            btn->targetDevice,
            btn->channel,
            btn->state,
            "toggle"
        );
        
        updateButtonVisual(btn);
        Logger::info("BTN", "Toggle: " + btn->label + " -> " + 
                   String(btn->state ? "ON" : "OFF"));
    }
}

void ButtonHandler::handleButtonRelease(int buttonId) {
    Button* btn = getButton(buttonId);
    if (!btn) return;
    
    if (btn->functionType == "momentary" && btn->isPressed) {
        // Parar comando e heartbeat
        commandSender->sendRelayCommand(
            btn->targetDevice,
            btn->channel,
            false,
            "momentary"
        );
        
        commandSender->stopHeartbeat(btn->channel);
        
        btn->isPressed = false;
        unsigned long duration = millis() - btn->pressStartTime;
        
        Logger::info("BTN", "Momentary release: " + btn->label + 
                   " (held for " + String(duration) + "ms)");
        
        // Publicar evento
        StaticJsonDocument<256> eventDoc;
        eventDoc["button_id"] = buttonId;
        eventDoc["duration_ms"] = duration;
        commandSender->sendDisplayEvent("button_release", eventDoc.as<JsonObject>());
    }
}

void ButtonHandler::update() {
    // Verificar botões momentâneos pressionados
    for (auto& btn : buttons) {
        if (btn.functionType == "momentary" && btn.isPressed) {
            // Continuar enviando heartbeats
            commandSender->processHeartbeats();
            
            // Verificar timeout de segurança (máximo 30 segundos)
            if (millis() - btn.pressStartTime > 30000) {
                Logger::warn("BTN", "Safety release after 30s: " + btn.label);
                handleButtonRelease(btn.id);
            }
        }
    }
}
```

### 6. StatusReporter - Telemetria Correta
**Arquivo**: `firmware/esp32-display-v2/src/communication/StatusReporter.cpp`

```cpp
// StatusReporter.cpp - Telemetria v2.2.0
void StatusReporter::publishTelemetry() {
    // UUID no payload, não no tópico!
    String topic = "autocore/telemetry/displays/data";
    
    StaticJsonDocument<1024> doc;
    MQTTProtocol::addProtocolFields(doc);  // Adiciona version, uuid, timestamp
    
    // Informações do display
    JsonObject display = doc.createNestedObject("display");
    display["type"] = "touch_2.4";
    display["backlight"] = getBacklightLevel();
    display["current_screen"] = screenManager->getCurrentScreenName();
    display["touch_enabled"] = touchHandler->isEnabled();
    
    // Métricas do sistema
    JsonObject metrics = doc.createNestedObject("metrics");
    metrics["uptime"] = millis() / 1000;
    metrics["free_heap"] = ESP.getFreeHeap();
    metrics["wifi_rssi"] = WiFi.RSSI();
    metrics["fps"] = lv_disp_get_refr_period(NULL);
    metrics["cpu_usage"] = getCPUUsage();
    
    // Estatísticas de uso
    JsonObject stats = doc.createNestedObject("usage_stats");
    stats["touches_today"] = touchCounter;
    stats["buttons_pressed"] = buttonPressCounter;
    stats["screens_viewed"] = screenViewCounter;
    stats["errors_logged"] = errorCounter;
    
    mqttClient->publish(topic, doc, QOS_TELEMETRY);
}

void StatusReporter::reportError(ErrorCode code, const String& message, 
                                JsonObject* context) {
    String topic = "autocore/errors/" + MQTTProtocol::getDeviceUUID() + 
                  "/" + ErrorHandler::getErrorType(code);
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["error_code"] = ErrorHandler::getErrorCode(code);
    doc["error_type"] = ErrorHandler::getErrorType(code);
    doc["error_message"] = message;
    
    if (context) {
        doc["context"] = *context;
    }
    
    mqttClient->publish(topic, doc, QOS_COMMANDS);
    
    errorCounter++;
    Logger::error("STATUS", String(ErrorHandler::getErrorCode(code)) + 
                 ": " + message);
}
```

### 7. ConfigReceiver - Via API REST
**Arquivo**: `firmware/esp32-display-v2/src/communication/ConfigReceiver.cpp`

```cpp
// ConfigReceiver.cpp - Buscar config via API, não MQTT
#include <HTTPClient.h>

void ConfigReceiver::fetchConfiguration() {
    HTTPClient http;
    String url = String("http://") + API_HOST + "/api/devices/" + 
                MQTTProtocol::getDeviceUUID() + "/display-config";
    
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    
    int httpCode = http.GET();
    
    if (httpCode == 200) {
        String payload = http.getString();
        
        StaticJsonDocument<4096> doc;
        DeserializationError error = deserializeJson(doc, payload);
        
        if (!error) {
            applyConfiguration(doc);
            Logger::info("CONFIG", "Configuration fetched from API");
        } else {
            Logger::error("CONFIG", "Failed to parse config: " + 
                        String(error.c_str()));
        }
    } else {
        Logger::error("CONFIG", "HTTP error: " + String(httpCode));
        
        // Tentar novamente em 30 segundos
        configRetryTimer = millis() + 30000;
    }
    
    http.end();
}

void ConfigReceiver::applyConfiguration(const JsonDocument& config) {
    // NÃO receber config via MQTT!
    
    // Validar protocol_version
    if (!MQTTProtocol::validateProtocolVersion(config)) {
        Logger::warn("CONFIG", "Config without valid protocol_version");
        return;
    }
    
    // Aplicar configuração de telas
    if (config.containsKey("screens")) {
        screenManager->updateScreens(config["screens"]);
    }
    
    // Aplicar configuração de botões
    if (config.containsKey("buttons")) {
        buttonHandler->updateButtons(config["buttons"]);
    }
    
    // Aplicar tema
    if (config.containsKey("theme")) {
        theme->apply(config["theme"]);
    }
    
    lastConfigUpdate = millis();
    Logger::info("CONFIG", "Configuration applied successfully");
}
```

## 📝 Implementação Passo a Passo

### Passo 1: Executar Script de Correção Global
```bash
cd firmware/esp32-display-v2
chmod +x fix_autotech_prefix.sh
./fix_autotech_prefix.sh
```

### Passo 2: Criar Classe Base MQTTProtocol
1. Criar `include/core/MQTTProtocol.h`
2. Implementar funções auxiliares
3. Adicionar validação de versão

### Passo 3: Refatorar MQTTClient
1. Implementar LWT correto
2. Corrigir todos os tópicos
3. Adicionar protocol_version

### Passo 4: Refatorar CommandSender
1. Implementar heartbeat correto
2. Adicionar sequência e UUIDs
3. Suportar comandos momentâneos

### Passo 5: Atualizar ButtonHandler
1. Integrar com heartbeat
2. Suportar press & hold
3. Implementar safety timeout

### Passo 6: Configuração via API
1. Remover handler MQTT de config
2. Implementar fetch HTTP
3. Adicionar retry logic

### Passo 7: Testes Completos
```cpp
// test/test_mqtt_v2.cpp
void test_protocol_version() {
    StaticJsonDocument<256> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    TEST_ASSERT_TRUE(doc.containsKey("protocol_version"));
    TEST_ASSERT_EQUAL_STRING("2.2.0", doc["protocol_version"]);
}

void test_heartbeat_sequence() {
    CommandSender sender;
    
    sender.startHeartbeat("esp32-relay-001", 1);
    delay(100);
    sender.processHeartbeats();
    
    // Verificar se heartbeat foi enviado
    TEST_ASSERT_TRUE(mqttClient.wasPublishedTo(
        "autocore/devices/esp32-relay-001/relays/heartbeat"
    ));
}

void test_momentary_button() {
    ButtonHandler handler;
    
    // Simular press
    handler.handleButtonPress(1);
    TEST_ASSERT_TRUE(handler.getButton(1)->isPressed);
    
    // Esperar e verificar heartbeats
    delay(600);
    handler.update();
    
    // Simular release
    handler.handleButtonRelease(1);
    TEST_ASSERT_FALSE(handler.getButton(1)->isPressed);
}
```

## 🧪 Validação

### Build e Upload
```bash
# Limpar build anterior
pio run -t clean

# Compilar
pio run -e esp32-2432S028R

# Upload
pio run -t upload -e esp32-2432S028R

# Monitor
pio device monitor -b 115200
```

### Checklist Crítico
- [ ] TODOS os "autotech/" substituídos por "autocore/"
- [ ] Protocol version em TODOS os payloads
- [ ] Heartbeat funcionando para momentâneos
- [ ] LWT configurado corretamente
- [ ] Telemetria sem UUID no tópico
- [ ] Configuração APENAS via API REST
- [ ] Touch events publicados corretamente
- [ ] Timestamps em ISO 8601

## 📊 Métricas de Sucesso
- ✅ 15/15 violações corrigidas
- ✅ 0 ocorrências de "autotech"
- ✅ 100% payloads com v2.2.0
- ✅ Heartbeat testado e funcional
- ✅ Display totalmente conforme

## 🚨 Riscos e Mitigação
- **Alto risco**: Muitas mudanças simultâneas
- **Mitigação**: Testar incrementalmente
- **Backup**: Manter versão antiga disponível
- **Rollback**: Via OTA se necessário

## 📝 Notas Importantes
- **CRÍTICO**: Este é o componente com mais violações
- Testar EXAUSTIVAMENTE antes de deploy
- Considerar deploy gradual (1 dispositivo primeiro)
- Monitorar logs intensivamente após deploy
- Ter plano de rollback pronto

---
**Criado em**: 12/08/2025  
**Status**: Documentado  
**Estimativa**: 16-20 horas  
**Complexidade**: MUITO ALTA  
**Risco**: ALTO (interface principal do usuário)