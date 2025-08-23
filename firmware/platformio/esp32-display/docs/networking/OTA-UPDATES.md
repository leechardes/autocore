# OTA Updates - Atualizações Over-The-Air

## 🔄 Visão Geral do Sistema OTA

O sistema OTA (Over-The-Air) permite atualizações remotas do firmware ESP32 sem necessidade de conexão física, garantindo que os dispositivos sempre executem a versão mais recente e segura do software.

### Métodos OTA Suportados
- **Arduino OTA**: Atualização via rede local
- **HTTP OTA**: Download de firmware via HTTP/HTTPS
- **MQTT OTA**: Notificação e coordenação via MQTT
- **Web OTA**: Interface web para upload manual

## 🏗️ Arquitetura OTA

### Fluxo de Atualização
```
Backend System
    ↓ (notification)
MQTT Broker
    ↓ (ota/available)
ESP32 Device
    ↓ (download)
Firmware Server
    ↓ (verify & flash)
Updated Device
```

### Componentes do Sistema
```cpp
// Principais bibliotecas
#include <ArduinoOTA.h>     // OTA via rede local
#include <HTTPUpdate.h>     // OTA via HTTP
#include <Update.h>         // Sistema de update ESP32
#include <WiFiClientSecure.h> // HTTPS seguro
```

## 🔧 Arduino OTA Implementation

### Setup Básico
```cpp
void setupArduinoOTA() {
    // Configuração básica
    ArduinoOTA.setHostname(("autocore-display-" + getDeviceId()).c_str());
    ArduinoOTA.setPassword(OTA_PASSWORD);
    ArduinoOTA.setPort(3232);  // Porta padrão
    
    // Configurar callbacks
    setupOTACallbacks();
    
    // Inicializar serviço
    ArduinoOTA.begin();
    
    logger->info("Arduino OTA ready on port 3232");
}

void setupOTACallbacks() {
    ArduinoOTA.onStart([]() {
        String type = (ArduinoOTA.getCommand() == U_FLASH) ? "sketch" : "filesystem";
        logger->info("OTA Start: " + type);
        
        // Preparar para update
        prepareForOTA();
    });
    
    ArduinoOTA.onEnd([]() {
        logger->info("OTA End - Rebooting...");
        showOTAComplete();
    });
    
    ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
        int percentage = (progress / (total / 100));
        updateOTAProgress(percentage);
    });
    
    ArduinoOTA.onError([](ota_error_t error) {
        handleOTAError(error);
    });
}

void prepareForOTA() {
    // Pausar serviços críticos
    mqttClient->disconnect();
    
    // Limpar display
    lv_obj_clean(lv_scr_act());
    
    // Mostrar tela de atualização
    showOTAScreen();
    
    // Salvar configurações importantes
    configManager->saveCurrentState();
}
```

### OTA Progress Display
```cpp
void showOTAScreen() {
    lv_obj_t* screen = lv_obj_create(NULL);
    lv_scr_load(screen);
    
    // Container principal
    lv_obj_t* container = lv_obj_create(screen);
    lv_obj_set_size(container, 300, 200);
    lv_obj_center(container);
    
    // Título
    lv_obj_t* title = lv_label_create(container);
    lv_label_set_text(title, "ATUALIZANDO FIRMWARE");
    lv_obj_align(title, LV_ALIGN_TOP_MID, 0, 20);
    
    // Progress bar
    otaProgressBar = lv_bar_create(container);
    lv_obj_set_size(otaProgressBar, 250, 20);
    lv_obj_align(otaProgressBar, LV_ALIGN_CENTER, 0, 0);
    lv_bar_set_range(otaProgressBar, 0, 100);
    
    // Label de progresso
    otaProgressLabel = lv_label_create(container);
    lv_label_set_text(otaProgressLabel, "0%");
    lv_obj_align(otaProgressLabel, LV_ALIGN_BOTTOM_MID, 0, -20);
}

void updateOTAProgress(int percentage) {
    if (otaProgressBar) {
        lv_bar_set_value(otaProgressBar, percentage, LV_ANIM_ON);
    }
    
    if (otaProgressLabel) {
        lv_label_set_text_fmt(otaProgressLabel, "%d%%", percentage);
    }
    
    lv_task_handler(); // Atualizar display
    
    logger->debug("OTA Progress: " + String(percentage) + "%");
}
```

## 🌐 HTTP OTA Implementation

### HTTP OTA Client
```cpp
class HTTPOTAClient {
private:
    WiFiClientSecure client;
    String firmwareUrl;
    String currentVersion;
    
public:
    bool checkForUpdates();
    bool downloadAndInstall(const String& url);
    bool verifyFirmware(const String& url);
    void setCredentials(const String& url, const String& fingerprint);
};

bool HTTPOTAClient::checkForUpdates() {
    HTTPClient http;
    http.begin(client, API_BASE_URL + "/ota/check");
    http.addHeader("Authorization", "Bearer " + getAuthToken());
    http.addHeader("X-Device-Version", FIRMWARE_VERSION);
    http.addHeader("X-Device-UUID", getDeviceUUID());
    
    int httpCode = http.GET();
    
    if (httpCode == HTTP_CODE_OK) {
        String response = http.getString();
        JsonDocument doc;
        deserializeJson(doc, response);
        
        if (doc["update_available"].as<bool>()) {
            String newVersion = doc["version"];
            String downloadUrl = doc["download_url"];
            String checksum = doc["checksum"];
            bool mandatory = doc["mandatory"].as<bool>();
            
            logger->info("Update available: " + newVersion + " (current: " + currentVersion + ")");
            
            if (mandatory || shouldAutoUpdate()) {
                return downloadAndInstall(downloadUrl);
            } else {
                notifyUpdateAvailable(newVersion, downloadUrl);
            }
        }
    }
    
    http.end();
    return false;
}

bool HTTPOTAClient::downloadAndInstall(const String& url) {
    logger->info("Starting HTTP OTA from: " + url);
    
    // Preparar para update
    prepareForOTA();
    
    // Configurar HTTP Update
    HTTPUpdate httpUpdate;
    httpUpdate.setLedPin(LED_BUILTIN, LOW);
    
    // Configurar callbacks
    httpUpdate.onStart([]() {
        logger->info("HTTP OTA started");
    });
    
    httpUpdate.onEnd([]() {
        logger->info("HTTP OTA completed successfully");
    });
    
    httpUpdate.onProgress([](int current, int total) {
        int percentage = (current * 100) / total;
        updateOTAProgress(percentage);
    });
    
    httpUpdate.onError([](int error) {
        String errorMsg = "HTTP OTA Error: " + String(error);
        logger->error(errorMsg);
        showOTAError(errorMsg);
    });
    
    // Executar update
    t_httpUpdate_return result = httpUpdate.update(client, url);
    
    switch (result) {
        case HTTP_UPDATE_FAILED:
            logger->error("HTTP OTA failed: " + httpUpdate.getLastErrorString());
            showOTAError("Update failed");
            return false;
            
        case HTTP_UPDATE_NO_UPDATES:
            logger->info("No updates found");
            return true;
            
        case HTTP_UPDATE_OK:
            logger->info("HTTP OTA successful - device will reboot");
            showOTAComplete();
            delay(1000);
            ESP.restart();
            break;
    }
    
    return true;
}
```

### Secure HTTPS OTA
```cpp
void setupSecureOTA() {
    // Configurar certificado CA
    client.setCACert(ROOT_CA_CERT);
    
    // Ou usar fingerprint (menos seguro)
    // client.setFingerprint(SERVER_FINGERPRINT);
    
    // Verificar hostname
    client.setVerify(true);
    
    // Timeout para downloads grandes
    client.setTimeout(60000); // 60 segundos
}

// Verificação de integridade
bool verifyFirmwareChecksum(const String& firmwareData, const String& expectedChecksum) {
    // Calcular SHA256 do firmware
    char hash[65];
    mbedtls_md_context_t ctx;
    mbedtls_md_type_t md_type = MBEDTLS_MD_SHA256;
    
    mbedtls_md_init(&ctx);
    mbedtls_md_setup(&ctx, mbedtls_md_info_from_type(md_type), 0);
    mbedtls_md_starts(&ctx);
    mbedtls_md_update(&ctx, (const unsigned char*)firmwareData.c_str(), firmwareData.length());
    
    unsigned char output[32];
    mbedtls_md_finish(&ctx, output);
    mbedtls_md_free(&ctx);
    
    // Converter para hex string
    for (int i = 0; i < 32; i++) {
        sprintf(&hash[i*2], "%02x", output[i]);
    }
    
    String calculatedChecksum = String(hash);
    bool valid = (calculatedChecksum == expectedChecksum);
    
    logger->info("Firmware checksum: " + calculatedChecksum);
    logger->info("Expected checksum: " + expectedChecksum);
    logger->info("Verification: " + String(valid ? "PASS" : "FAIL"));
    
    return valid;
}
```

## 📡 MQTT OTA Coordination

### OTA Notification Handler
```cpp
void setupMQTTOTA() {
    // Subscrever em tópicos OTA
    mqttClient->subscribe("autocore/devices/" + getDeviceUUID() + "/ota/available", 1, [](char* topic, byte* payload, unsigned int length) {
        String message = String((char*)payload, length);
        handleOTANotification(message);
    });
    
    mqttClient->subscribe("autocore/ota/broadcast", 1, [](char* topic, byte* payload, unsigned int length) {
        String message = String((char*)payload, length);
        handleOTABroadcast(message);
    });
}

void handleOTANotification(const String& message) {
    JsonDocument doc;
    deserializeJson(doc, message);
    
    if (!MQTTProtocol::validateProtocolVersion(doc)) {
        logger->warning("OTA notification with invalid protocol version");
        return;
    }
    
    String version = doc["version"];
    String downloadUrl = doc["download_url"];
    String checksum = doc["checksum"];
    bool mandatory = doc["mandatory"].as<bool>();
    String releaseNotes = doc["release_notes"];
    
    logger->info("OTA notification received - Version: " + version);
    
    // Verificar se é uma versão mais nova
    if (isNewerVersion(version, FIRMWARE_VERSION)) {
        if (mandatory) {
            logger->info("Mandatory update - starting immediately");
            performOTAUpdate(downloadUrl, checksum);
        } else {
            logger->info("Optional update available - user confirmation needed");
            showUpdatePrompt(version, releaseNotes, downloadUrl, checksum);
        }
    }
}

void performOTAUpdate(const String& url, const String& checksum) {
    // Notificar backend que update iniciou
    JsonDocument statusDoc;
    MQTTProtocol::addProtocolFields(statusDoc);
    statusDoc["status"] = "updating";
    statusDoc["firmware_url"] = url;
    
    mqttClient->publish("autocore/devices/" + getDeviceUUID() + "/ota/status", statusDoc);
    
    // Executar update
    HTTPOTAClient otaClient;
    bool success = otaClient.downloadAndInstall(url);
    
    // Notificar resultado
    statusDoc["status"] = success ? "success" : "failed";
    statusDoc["timestamp"] = MQTTProtocol::getISOTimestamp();
    
    mqttClient->publish("autocore/devices/" + getDeviceUUID() + "/ota/status", statusDoc);
}
```

### OTA Status Reporting
```cpp
void reportOTAStatus(const String& status, const String& details = "") {
    JsonDocument doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["status"] = status;
    doc["current_version"] = FIRMWARE_VERSION;
    doc["free_heap"] = ESP.getFreeHeap();
    doc["uptime"] = millis() / 1000;
    
    if (!details.isEmpty()) {
        doc["details"] = details;
    }
    
    if (status == "updating") {
        doc["progress"] = currentOTAProgress;
    }
    
    String topic = "autocore/devices/" + getDeviceUUID() + "/ota/status";
    mqttClient->publish(topic, doc, 1); // QoS 1 para garantir entrega
}

// Estados possíveis de OTA
enum OTAStatus {
    OTA_IDLE,           // Aguardando
    OTA_CHECKING,       // Verificando updates
    OTA_DOWNLOADING,    // Baixando firmware
    OTA_VERIFYING,      // Verificando integridade
    OTA_INSTALLING,     // Instalando update
    OTA_SUCCESS,        // Sucesso
    OTA_FAILED          // Falha
};

void updateOTAStatus(OTAStatus status) {
    String statusStr;
    
    switch (status) {
        case OTA_IDLE: statusStr = "idle"; break;
        case OTA_CHECKING: statusStr = "checking"; break;
        case OTA_DOWNLOADING: statusStr = "downloading"; break;
        case OTA_VERIFYING: statusStr = "verifying"; break;
        case OTA_INSTALLING: statusStr = "installing"; break;
        case OTA_SUCCESS: statusStr = "success"; break;
        case OTA_FAILED: statusStr = "failed"; break;
    }
    
    reportOTAStatus(statusStr);
}
```

## 🔒 OTA Security

### Firmware Signature Verification
```cpp
#include "mbedtls/pk.h"
#include "mbedtls/entropy.h"
#include "mbedtls/ctr_drbg.h"

bool verifyFirmwareSignature(const String& firmwareData, const String& signature) {
    mbedtls_pk_context pk;
    mbedtls_entropy_context entropy;
    mbedtls_ctr_drbg_context ctr_drbg;
    
    // Inicializar contextos
    mbedtls_pk_init(&pk);
    mbedtls_entropy_init(&entropy);
    mbedtls_ctr_drbg_init(&ctr_drbg);
    
    // Seed RNG
    const char* pers = "ota_verify";
    mbedtls_ctr_drbg_seed(&ctr_drbg, mbedtls_entropy_func, &entropy,
                          (const unsigned char*)pers, strlen(pers));
    
    // Carregar chave pública
    int ret = mbedtls_pk_parse_public_key(&pk, 
                                         (const unsigned char*)PUBLIC_KEY_PEM, 
                                         strlen(PUBLIC_KEY_PEM) + 1);
    
    if (ret != 0) {
        logger->error("Failed to parse public key");
        return false;
    }
    
    // Calcular hash do firmware
    unsigned char hash[32];
    mbedtls_md_context_t md_ctx;
    mbedtls_md_init(&md_ctx);
    mbedtls_md_setup(&md_ctx, mbedtls_md_info_from_type(MBEDTLS_MD_SHA256), 0);
    mbedtls_md_starts(&md_ctx);
    mbedtls_md_update(&md_ctx, (const unsigned char*)firmwareData.c_str(), firmwareData.length());
    mbedtls_md_finish(&md_ctx, hash);
    mbedtls_md_free(&md_ctx);
    
    // Decodificar assinatura base64
    size_t sig_len;
    unsigned char sig_buf[256];
    mbedtls_base64_decode(sig_buf, sizeof(sig_buf), &sig_len,
                          (const unsigned char*)signature.c_str(), signature.length());
    
    // Verificar assinatura
    ret = mbedtls_pk_verify(&pk, MBEDTLS_MD_SHA256, hash, 32, sig_buf, sig_len);
    
    // Cleanup
    mbedtls_pk_free(&pk);
    mbedtls_entropy_free(&entropy);
    mbedtls_ctr_drbg_free(&ctr_drbg);
    
    bool valid = (ret == 0);
    logger->info("Firmware signature verification: " + String(valid ? "VALID" : "INVALID"));
    
    return valid;
}
```

### Rollback Protection
```cpp
void saveCurrentFirmwareInfo() {
    Preferences prefs;
    prefs.begin("firmware", false);
    
    prefs.putString("version", FIRMWARE_VERSION);
    prefs.putULong("timestamp", millis());
    prefs.putBool("verified", true);
    
    prefs.end();
}

bool shouldAllowRollback(const String& targetVersion) {
    Preferences prefs;
    prefs.begin("firmware", true);
    
    String currentVersion = prefs.getString("version", "");
    unsigned long lastUpdate = prefs.getULong("timestamp", 0);
    bool wasVerified = prefs.getBool("verified", false);
    
    prefs.end();
    
    // Não permitir rollback para versão mais antiga
    if (isOlderVersion(targetVersion, currentVersion)) {
        logger->warning("Rollback blocked - target version is older");
        return false;
    }
    
    // Não permitir rollback se última atualização foi recente
    if (millis() - lastUpdate < 3600000) { // 1 hora
        logger->warning("Rollback blocked - recent update");
        return false;
    }
    
    return true;
}
```

## 🔧 OTA Configuration

### Build Configuration
```ini
; platformio.ini
[env:esp32-ota]
platform = espressif32
board = esp32dev
framework = arduino

; OTA Settings
upload_protocol = espota
upload_port = autocore-display-abc123.local
upload_flags = 
    --port=3232
    --auth=OTA_PASSWORD

; Partitioning for OTA
board_build.partitions = min_spiffs.csv

build_flags = 
    -D OTA_ENABLED=1
    -D OTA_PASSWORD=\"your_ota_password\"
    -D FIRMWARE_VERSION=\"1.2.3\"
```

### Partition Table
```
# Name,   Type, SubType, Offset,  Size,     Flags
nvs,      data, nvs,     0x9000,  0x5000,
otadata,  data, ota,     0xe000,  0x2000,
app0,     app,  ota_0,   0x10000, 0x180000,
app1,     app,  ota_1,   0x190000,0x180000,
spiffs,   data, spiffs,  0x310000,0xF0000,
```

## 🔍 OTA Troubleshooting

### Error Handling
```cpp
void handleOTAError(ota_error_t error) {
    String errorMsg;
    
    switch (error) {
        case OTA_AUTH_ERROR:
            errorMsg = "Authentication Failed";
            break;
        case OTA_BEGIN_ERROR:
            errorMsg = "Begin Failed - Check partition space";
            break;
        case OTA_CONNECT_ERROR:
            errorMsg = "Connection Failed - Check network";
            break;
        case OTA_RECEIVE_ERROR:
            errorMsg = "Receive Failed - Data corruption";
            break;
        case OTA_END_ERROR:
            errorMsg = "End Failed - Verification error";
            break;
        default:
            errorMsg = "Unknown Error: " + String(error);
    }
    
    logger->error("OTA Error: " + errorMsg);
    showOTAError(errorMsg);
    
    // Tentar recovery
    attemptOTARecovery(error);
}

void attemptOTARecovery(ota_error_t error) {
    switch (error) {
        case OTA_CONNECT_ERROR:
            // Tentar reconectar WiFi
            WiFi.reconnect();
            break;
            
        case OTA_RECEIVE_ERROR:
            // Tentar download novamente
            retryOTADownload();
            break;
            
        case OTA_BEGIN_ERROR:
            // Limpar partição OTA
            clearOTAPartition();
            break;
            
        default:
            // Reset para estado seguro
            ESP.restart();
    }
}
```

### Diagnostic Tools
```cpp
void printOTADiagnostics() {
    logger->info("=== OTA Diagnostics ===");
    
    // Informações de partição
    esp_partition_t* running = esp_ota_get_running_partition();
    esp_partition_t* boot = esp_ota_get_boot_partition();
    
    logger->info("Running partition: " + String(running->label));
    logger->info("Boot partition: " + String(boot->label));
    logger->info("Free heap: " + String(ESP.getFreeHeap()));
    logger->info("Flash size: " + String(ESP.getFlashChipSize()));
    
    // Estado OTA
    esp_ota_img_states_t state;
    esp_ota_get_state_partition(running, &state);
    
    String stateStr;
    switch (state) {
        case ESP_OTA_IMG_NEW: stateStr = "NEW"; break;
        case ESP_OTA_IMG_PENDING_VERIFY: stateStr = "PENDING_VERIFY"; break;
        case ESP_OTA_IMG_VALID: stateStr = "VALID"; break;
        case ESP_OTA_IMG_INVALID: stateStr = "INVALID"; break;
        case ESP_OTA_IMG_ABORTED: stateStr = "ABORTED"; break;
        default: stateStr = "UNDEFINED";
    }
    
    logger->info("OTA state: " + stateStr);
    logger->info("Firmware version: " + String(FIRMWARE_VERSION));
    logger->info("===================");
}
```