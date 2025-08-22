# Networking - Gerenciamento de Rede

Este diretório contém toda a documentação sobre networking, conectividade e atualizações OTA do firmware ESP32.

## 🌐 Visão Geral do Sistema de Rede

### Arquitetura de Conectividade
```
Internet
    ↓
WiFi Router
    ↓
ESP32 Device
├── HTTP API Client      # Configurações e registro
├── MQTT Client         # Comandos e telemetria
├── mDNS Responder     # Descoberta local
└── OTA Updater        # Atualizações firmware
```

### Protocolos Suportados
- **WiFi 802.11 b/g/n**: Conectividade principal
- **HTTP/HTTPS**: API REST para configuração
- **MQTT**: Comunicação em tempo real
- **mDNS**: Descoberta de rede local
- **OTA**: Atualizações over-the-air

## 📋 Documentação Disponível

- [`wifi-manager.md`](wifi-manager.md) - Gerenciamento WiFi e conexão
- [`mdns-discovery.md`](mdns-discovery.md) - Descoberta via mDNS
- [`ota-updates.md`](ota-updates.md) - Sistema de atualizações OTA
- [`connection-retry.md`](connection-retry.md) - Estratégias de reconexão
- [`network-diagnostics.md`](network-diagnostics.md) - Diagnósticos de rede

## 🔧 Device Registration System

### Smart Registration Flow
```cpp
class DeviceRegistration {
public:
    static bool performSmartRegistration();
    static bool isRegistrationValid();
    static bool loadMQTTCredentials(MQTTCredentials& creds);
};
```

### Registration Sequence
1. **Device Check**: Verificar se dispositivo existe na API
2. **Registration**: Registrar novo dispositivo se necessário
3. **MQTT Config**: Obter credenciais MQTT dinâmicas
4. **Network Update**: Atualizar informações de rede
5. **Cache**: Salvar credenciais localmente (24h válido)

### API Endpoints
```
GET  /api/v1/devices/{uuid}           # Verificar se existe
POST /api/v1/devices/register         # Registrar dispositivo
GET  /api/v1/devices/{uuid}/mqtt      # Obter credenciais MQTT
PUT  /api/v1/devices/{uuid}/network   # Atualizar info de rede
```

## 📡 MQTT Credentials Management

### Dynamic Credentials
```cpp
struct MQTTCredentials {
    String broker_host;      # "mqtt.autocore.com"
    uint16_t broker_port;    # 1883 ou 8883 (TLS)
    String username;         # "device_abc123"
    String password;         # "generated_password"
    String topic_prefix;     # "autocore/devices/{uuid}"
};
```

### Credential Flow
```cpp
// 1. Tentar carregar do cache local
MQTTCredentials creds;
if (DeviceRegistration::loadMQTTCredentials(creds)) {
    // Usar credenciais cached
    mqttClient->connect(creds);
} else {
    // Executar smart registration
    if (DeviceRegistration::performSmartRegistration()) {
        DeviceRegistration::loadMQTTCredentials(creds);
        mqttClient->connect(creds);
    }
}
```

### Security Features
- **Credenciais dinâmicas**: Geradas por dispositivo
- **Rotação automática**: Renovação periódica
- **Escopo limitado**: Acesso apenas aos tópicos necessários
- **Cache local**: Válido por 24 horas

## 🔄 Connection Management

### WiFi Connection Strategy
```cpp
void setupWiFi() {
    WiFi.mode(WIFI_STA);
    WiFi.setAutoConnect(true);
    WiFi.setAutoReconnect(true);
    
    // Tentar conectar com credenciais salvas
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    
    // Aguardar conexão com timeout
    int timeout = 20; // 20 segundos
    while (WiFi.status() != WL_CONNECTED && timeout > 0) {
        delay(1000);
        timeout--;
    }
    
    if (WiFi.status() == WL_CONNECTED) {
        setupNetworkServices();
    } else {
        // Fallback para AP mode ou retry
        handleConnectionFailure();
    }
}
```

### Reconnection Logic
```cpp
void handleWiFiReconnection() {
    static unsigned long lastReconnectAttempt = 0;
    static int reconnectDelay = 5000; // Início com 5s
    
    if (WiFi.status() != WL_CONNECTED) {
        unsigned long now = millis();
        
        if (now - lastReconnectAttempt > reconnectDelay) {
            logger->warning("WiFi disconnected, attempting reconnection...");
            
            WiFi.reconnect();
            lastReconnectAttempt = now;
            
            // Backoff exponencial (máximo 60s)
            reconnectDelay = min(reconnectDelay * 2, 60000);
        }
    } else {
        // Reset delay quando conectado
        reconnectDelay = 5000;
    }
}
```

### Network Status Monitoring
```cpp
void monitorNetworkStatus() {
    static unsigned long lastCheck = 0;
    
    if (millis() - lastCheck > 10000) { // Check a cada 10s
        NetworkStatus status;
        status.wifi_connected = (WiFi.status() == WL_CONNECTED);
        status.ip_address = WiFi.localIP().toString();
        status.rssi = WiFi.RSSI();
        status.mqtt_connected = mqttClient->isConnected();
        status.api_reachable = pingAPI();
        
        // Reportar status se mudou
        if (hasStatusChanged(status)) {
            reportNetworkStatus(status);
        }
        
        lastCheck = millis();
    }
}
```

## 🔍 mDNS Discovery

### Service Advertisement
```cpp
#include <ESPmDNS.h>

void setupMDNS() {
    String hostname = "autocore-display-" + getDeviceId();
    
    if (MDNS.begin(hostname.c_str())) {
        // Anunciar serviços
        MDNS.addService("http", "tcp", 80);
        MDNS.addService("autocore", "tcp", 1883);
        
        // Adicionar TXT records
        MDNS.addServiceTxt("autocore", "tcp", "version", FIRMWARE_VERSION);
        MDNS.addServiceTxt("autocore", "tcp", "type", "display");
        MDNS.addServiceTxt("autocore", "tcp", "uuid", getDeviceUUID());
        MDNS.addServiceTxt("autocore", "tcp", "capabilities", "touch,display,relay");
        
        logger->info("mDNS responder started: " + hostname + ".local");
    }
}
```

### Service Discovery
```cpp
void discoverAutoCoreSevices() {
    int n = MDNS.queryService("autocore", "tcp");
    
    for (int i = 0; i < n; ++i) {
        String hostname = MDNS.hostname(i);
        IPAddress ip = MDNS.IP(i);
        uint16_t port = MDNS.port(i);
        
        // Verificar TXT records
        String deviceType = MDNS.txt(i, "type");
        String capabilities = MDNS.txt(i, "capabilities");
        
        logger->info("Found device: " + hostname + " (" + ip.toString() + 
                    ") type=" + deviceType + " capabilities=" + capabilities);
    }
}
```

## 🔄 OTA Updates

### OTA Configuration
```cpp
#include <ArduinoOTA.h>

void setupOTA() {
    ArduinoOTA.setHostname(("autocore-display-" + getDeviceId()).c_str());
    ArduinoOTA.setPassword(OTA_PASSWORD);
    
    // Callbacks para monitoramento
    ArduinoOTA.onStart([]() {
        String type = (ArduinoOTA.getCommand() == U_FLASH) ? "sketch" : "filesystem";
        logger->info("OTA Update started: " + type);
        
        // Desabilitar outros serviços
        mqttClient->disconnect();
        lv_obj_clean(lv_scr_act()); // Limpar tela
        
        // Mostrar progresso na tela
        showOTAProgress(0);
    });
    
    ArduinoOTA.onEnd([]() {
        logger->info("OTA Update completed");
        showOTAProgress(100);
    });
    
    ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
        int percentage = (progress / (total / 100));
        showOTAProgress(percentage);
    });
    
    ArduinoOTA.onError([](ota_error_t error) {
        String errorMsg = "OTA Error: ";
        switch (error) {
            case OTA_AUTH_ERROR: errorMsg += "Auth Failed"; break;
            case OTA_BEGIN_ERROR: errorMsg += "Begin Failed"; break;
            case OTA_CONNECT_ERROR: errorMsg += "Connect Failed"; break;
            case OTA_RECEIVE_ERROR: errorMsg += "Receive Failed"; break;
            case OTA_END_ERROR: errorMsg += "End Failed"; break;
        }
        logger->error(errorMsg);
        showOTAError(errorMsg);
    });
    
    ArduinoOTA.begin();
}
```

### HTTP OTA Updates
```cpp
#include <HTTPUpdate.h>

bool performHTTPOTA(const String& firmwareUrl) {
    logger->info("Starting HTTP OTA update from: " + firmwareUrl);
    
    // Configurar cliente HTTP
    WiFiClient client;
    HTTPUpdate httpUpdate;
    
    // Configurar callbacks
    httpUpdate.onStart([]() {
        logger->info("HTTP OTA started");
        showOTAProgress(0);
    });
    
    httpUpdate.onEnd([]() {
        logger->info("HTTP OTA completed");
        showOTAProgress(100);
    });
    
    httpUpdate.onProgress([](int current, int total) {
        int percentage = (current * 100) / total;
        showOTAProgress(percentage);
    });
    
    httpUpdate.onError([](int error) {
        logger->error("HTTP OTA error: " + String(error));
        showOTAError("Update failed: " + String(error));
    });
    
    // Executar update
    t_httpUpdate_return result = httpUpdate.update(client, firmwareUrl);
    
    switch (result) {
        case HTTP_UPDATE_FAILED:
            logger->error("HTTP OTA failed: " + httpUpdate.getLastErrorString());
            return false;
            
        case HTTP_UPDATE_NO_UPDATES:
            logger->info("No updates available");
            return true;
            
        case HTTP_UPDATE_OK:
            logger->info("HTTP OTA successful - rebooting");
            ESP.restart();
            break;
    }
    
    return true;
}
```

### OTA Security
```cpp
// Verificação de assinatura
bool verifyFirmwareSignature(const String& firmwareUrl, const String& signatureUrl) {
    // Download signature
    HTTPClient http;
    http.begin(signatureUrl);
    int httpCode = http.GET();
    
    if (httpCode == HTTP_CODE_OK) {
        String signature = http.getString();
        
        // Verificar assinatura com chave pública
        return crypto_verify_signature(firmwareUrl, signature, PUBLIC_KEY);
    }
    
    return false;
}

// OTA com verificação
bool secureOTAUpdate(const String& firmwareUrl, const String& signatureUrl) {
    if (!verifyFirmwareSignature(firmwareUrl, signatureUrl)) {
        logger->error("Firmware signature verification failed");
        return false;
    }
    
    return performHTTPOTA(firmwareUrl);
}
```

## 🔒 Network Security

### TLS Configuration
```cpp
#include <WiFiClientSecure.h>

WiFiClientSecure secureClient;

void setupTLS() {
    // Configurar certificado CA
    secureClient.setCACert(CA_CERT);
    
    // Ou usar fingerprint
    secureClient.setFingerprint(API_FINGERPRINT);
    
    // Verificação relaxada para desenvolvimento
    // secureClient.setInsecure(); // APENAS PARA DEBUG
}
```

### API Authentication
```cpp
String getAuthToken() {
    // Token JWT baseado em device UUID
    String payload = "{\"device_uuid\":\"" + getDeviceUUID() + "\",\"timestamp\":" + String(millis()) + "}";
    String signature = hmac_sha256(payload, DEVICE_SECRET);
    
    return base64_encode(payload + "." + signature);
}

bool authenticatedAPICall(const String& endpoint, const String& method, const String& data) {
    HTTPClient http;
    http.begin(secureClient, API_BASE_URL + endpoint);
    
    // Adicionar headers de autenticação
    http.addHeader("Authorization", "Bearer " + getAuthToken());
    http.addHeader("Content-Type", "application/json");
    http.addHeader("User-Agent", "AutoCore-ESP32/" + String(FIRMWARE_VERSION));
    
    int httpCode;
    if (method == "GET") {
        httpCode = http.GET();
    } else if (method == "POST") {
        httpCode = http.POST(data);
    }
    
    return (httpCode == HTTP_CODE_OK);
}
```

## 📊 Network Diagnostics

### Connection Diagnostics
```cpp
struct NetworkDiagnostics {
    bool wifi_connected;
    String wifi_ssid;
    int32_t wifi_rssi;
    IPAddress local_ip;
    IPAddress gateway_ip;
    IPAddress dns_ip;
    bool internet_reachable;
    bool api_reachable;
    bool mqtt_reachable;
    unsigned long ping_time_ms;
};

NetworkDiagnostics runNetworkDiagnostics() {
    NetworkDiagnostics diag;
    
    // WiFi status
    diag.wifi_connected = (WiFi.status() == WL_CONNECTED);
    diag.wifi_ssid = WiFi.SSID();
    diag.wifi_rssi = WiFi.RSSI();
    diag.local_ip = WiFi.localIP();
    diag.gateway_ip = WiFi.gatewayIP();
    diag.dns_ip = WiFi.dnsIP();
    
    // Internet connectivity
    diag.internet_reachable = ping("8.8.8.8");
    diag.api_reachable = ping(API_HOST);
    diag.mqtt_reachable = ping(MQTT_BROKER);
    
    // Latency test
    unsigned long start = millis();
    if (ping(API_HOST)) {
        diag.ping_time_ms = millis() - start;
    } else {
        diag.ping_time_ms = 0;
    }
    
    return diag;
}
```

### Performance Monitoring
```cpp
void monitorNetworkPerformance() {
    static NetworkMetrics metrics;
    
    // Contar requests
    metrics.api_requests_total++;
    if (lastAPICallSuccess) {
        metrics.api_requests_success++;
    } else {
        metrics.api_requests_failed++;
    }
    
    // Medir latência MQTT
    unsigned long mqtt_start = millis();
    mqttClient->publish("test/ping", "ping");
    // Aguardar response... (implementar callback)
    
    // Calcular taxa de sucesso
    metrics.api_success_rate = (float)metrics.api_requests_success / metrics.api_requests_total;
    
    // Reportar métricas periodicamente
    if (millis() - metrics.last_report > 300000) { // 5 minutos
        reportNetworkMetrics(metrics);
        metrics.last_report = millis();
    }
}
```