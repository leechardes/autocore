/**
 * @file DeviceUtils.h
 * @brief Utilitários para identificação e configuração do dispositivo
 * 
 * @author Sistema AutoCore
 * @version 2.0.0
 * @date 2025-08-16
 */

#ifndef DEVICE_UTILS_H
#define DEVICE_UTILS_H

#include <Arduino.h>
#include <WiFi.h>

/**
 * @class DeviceUtils
 * @brief Utilitários para gerenciamento de identificação do dispositivo
 */
class DeviceUtils {
public:
    /**
     * @brief Gera UUID único baseado no MAC address
     * @param prefix Prefixo para o UUID (ex: "esp32-display-")
     * @return String com UUID gerado
     */
    static String generateUUIDFromMAC(const String& prefix = "esp32-display-");
    
    /**
     * @brief Obtém MAC address formatado como string
     * @param upperCase Se true, usa letras maiúsculas
     * @param separator Separador entre bytes (padrão: ":")
     * @return MAC address formatado
     */
    static String getMACAddress(bool upperCase = true, const String& separator = ":");
    
    /**
     * @brief Obtém MAC address sem separadores (apenas hex)
     * @param upperCase Se true, usa letras maiúsculas
     * @return MAC address sem separadores
     */
    static String getMACAddressHex(bool upperCase = true);
    
    /**
     * @brief Obtém informações do chip ESP32
     * @return String com informações do chip
     */
    static String getChipInfo();
    
    /**
     * @brief Obtém UUID do dispositivo baseado no eFuse MAC
     * Usa ESP.getEfuseMac() para gerar UUID único e permanente
     * @return UUID do dispositivo
     */
    static String getDeviceUUID();
    
    /**
     * @brief Obtém Device ID para MQTT v2.2.0
     * Formato: hmi_display_XXXXXX onde XXXXXX são os últimos 6 caracteres do UUID
     * @return Device ID no formato MQTT v2.2.0
     */
    static String getDeviceId();
    
    /**
     * @brief Valida se um UUID tem formato válido
     * @param uuid UUID para validar
     * @return true se UUID é válido
     */
    static bool isValidUUID(const String& uuid);
    
    /**
     * @brief Gera hash simples de uma string
     * @param input String de entrada
     * @return Hash de 32 bits como string hex
     */
    static String generateHash(const String& input);
};

#endif // DEVICE_UTILS_H