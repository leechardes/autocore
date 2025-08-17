/**
 * @file DeviceUtils.cpp
 * @brief Implementação dos utilitários para identificação do dispositivo
 * 
 * @author Sistema AutoCore
 * @version 2.0.0
 * @date 2025-08-16
 */

#include "utils/DeviceUtils.h"
#include "config/DeviceConfig.h"
#include "core/Logger.h"
#include <esp_system.h>

// Logger global declarado em main.cpp
extern Logger* logger;

String DeviceUtils::generateUUIDFromMAC(const String& prefix) {
    String macHex = getMACAddressHex(true);
    String uuid = prefix + macHex;
    
    if (logger) {
        logger->debug("DeviceUtils: Generated UUID from MAC: " + uuid);
    }
    
    return uuid;
}

String DeviceUtils::getMACAddress(bool upperCase, const String& separator) {
    uint8_t mac[6];
    WiFi.macAddress(mac);
    
    String macStr = "";
    for (int i = 0; i < 6; i++) {
        if (i > 0) macStr += separator;
        
        String byteStr = String(mac[i], HEX);
        if (byteStr.length() == 1) byteStr = "0" + byteStr;
        
        if (upperCase) {
            byteStr.toUpperCase();
        } else {
            byteStr.toLowerCase();
        }
        macStr += byteStr;
    }
    
    return macStr;
}

String DeviceUtils::getMACAddressHex(bool upperCase) {
    uint8_t mac[6];
    WiFi.macAddress(mac);
    
    String macHex = "";
    for (int i = 0; i < 6; i++) {
        String byteStr = String(mac[i], HEX);
        if (byteStr.length() == 1) byteStr = "0" + byteStr;
        if (upperCase) {
            byteStr.toUpperCase();
        } else {
            byteStr.toLowerCase();
        }
        macHex += byteStr;
    }
    
    return macHex;
}

String DeviceUtils::getChipInfo() {
    esp_chip_info_t chip_info;
    esp_chip_info(&chip_info);
    
    String info = "ESP32 ";
    info += "Rev " + String(chip_info.revision) + " ";
    info += "Cores: " + String(chip_info.cores) + " ";
    info += "Flash: " + String(spi_flash_get_chip_size() / (1024 * 1024)) + "MB ";
    
    if (chip_info.features & CHIP_FEATURE_WIFI_BGN) {
        info += "WiFi ";
    }
    if (chip_info.features & CHIP_FEATURE_BT) {
        info += "BT ";
    }
    if (chip_info.features & CHIP_FEATURE_BLE) {
        info += "BLE ";
    }
    
    return info;
}

String DeviceUtils::getDeviceUUID() {
    // Usar eFuse MAC que é único e permanente para cada chip ESP32
    uint64_t chipId = ESP.getEfuseMac();
    
    // Converter para string hexadecimal
    String chipIdHex = String((uint32_t)(chipId >> 32), HEX) + String((uint32_t)chipId, HEX);
    chipIdHex.toUpperCase();
    
    // Garantir 12 caracteres (adicionar zeros à esquerda se necessário)
    while (chipIdHex.length() < 12) {
        chipIdHex = "0" + chipIdHex;
    }
    
    String uuid = String(DEVICE_UUID_PREFIX) + chipIdHex;
    
    if (logger) {
        logger->debug("DeviceUtils: Generated UUID from eFuse MAC: " + uuid);
    }
    
    return uuid;
}

String DeviceUtils::getDeviceId() {
    // Obter UUID completo
    String uuid = getDeviceUUID();
    
    // Extrair últimos 6 caracteres do UUID (parte única do MAC)
    String uniquePart = uuid.substring(uuid.length() - 6);
    uniquePart.toLowerCase(); // MQTT v2.2.0 usa lowercase
    
    // Formato: hmi_display_XXXXXX
    String deviceId = String(DEVICE_TYPE) + "_" + uniquePart;
    
    if (logger) {
        logger->debug("DeviceUtils: Generated Device ID for MQTT v2.2.0: " + deviceId);
    }
    
    return deviceId;
}

bool DeviceUtils::isValidUUID(const String& uuid) {
    // Validação básica de UUID
    if (uuid.length() < 10) return false;
    if (uuid.indexOf("-") == -1) return false;
    
    // Verificar se contém apenas caracteres válidos
    for (int i = 0; i < uuid.length(); i++) {
        char c = uuid.charAt(i);
        if (!isAlphaNumeric(c) && c != '-' && c != '_') {
            return false;
        }
    }
    
    return true;
}

String DeviceUtils::generateHash(const String& input) {
    // Hash simples baseado em djb2
    unsigned long hash = 5381;
    
    for (int i = 0; i < input.length(); i++) {
        hash = ((hash << 5) + hash) + input.charAt(i);
    }
    
    // Converter para hex de 8 dígitos
    String hashStr = String(hash, HEX);
    hashStr.toUpperCase();
    
    // Garantir 8 dígitos
    while (hashStr.length() < 8) {
        hashStr = "0" + hashStr;
    }
    
    return hashStr;
}