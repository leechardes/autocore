// MQTTProtocol.h - Classe base para conformidade MQTT v2.2.0
#ifndef MQTT_PROTOCOL_H
#define MQTT_PROTOCOL_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <WiFi.h>
#include <time.h>
#include "config/DeviceConfig.h"

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
        deviceId = id;  // Usar o ID passado como parâmetro
        deviceType = type;
        configTime(0, 0, "pool.ntp.org");  // Configurar NTP para timestamps
    }
    
    static String getISOTimestamp() {
        struct tm timeinfo;
        if (!getLocalTime(&timeinfo)) {
            // Fallback se NTP não estiver disponível
            char timestamp[30];
            sprintf(timestamp, "2025-01-01T%02d:%02d:%02dZ", 
                   (int)(millis() / 3600000) % 24,
                   (int)(millis() / 60000) % 60,
                   (int)(millis() / 1000) % 60);
            return String(timestamp);
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
        doc["protocol_version"] = PROTOCOL_VERSION;  // Usar versão do config
        doc["uuid"] = getDeviceUUID();
        doc["timestamp"] = getISOTimestamp();
    }
    
    static unsigned long getTimestamp() {
        // Retorna timestamp Unix em segundos
        return millis() / 1000;
    }
    
    static bool validateProtocolVersion(const JsonDocument& doc) {
        if (!doc["protocol_version"].is<String>()) {
            return false;
        }
        
        String version = doc["protocol_version"];
        // Aceitar versões 2.x
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