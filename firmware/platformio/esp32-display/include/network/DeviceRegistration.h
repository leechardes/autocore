/**
 * @file DeviceRegistration.h
 * @brief Sistema de registro automático de dispositivos na API
 * 
 * @author Sistema AutoCore
 * @version 2.0.0
 * @date 2025-08-17
 */

#pragma once
#include <Arduino.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <Preferences.h>

/**
 * @struct MQTTCredentials
 * @brief Estrutura que armazena as credenciais MQTT dinâmicas obtidas da API
 */
struct MQTTCredentials {
    String broker_host;
    uint16_t broker_port;
    String username;
    String password;
    String topic_prefix;
};

/**
 * @class DeviceRegistration
 * @brief Gerencia o registro automático do dispositivo na API e obtenção de credenciais MQTT
 */
class DeviceRegistration {
public:
    /**
     * @brief Executa o smart registration completo
     * Verifica se dispositivo existe → registra se necessário → obtém credenciais MQTT
     * @return true se registro foi bem-sucedido ou já válido
     */
    static bool performSmartRegistration();
    
    /**
     * @brief Verifica se o registro ainda é válido (cache de 24 horas)
     * @return true se registro é válido e não precisa ser renovado
     */
    static bool isRegistrationValid();
    
    /**
     * @brief Carrega credenciais MQTT do cache local
     * @param creds Estrutura onde serão carregadas as credenciais
     * @return true se credenciais foram carregadas com sucesso
     */
    static bool loadMQTTCredentials(MQTTCredentials& creds);
    
private:
    /**
     * @brief Verifica se o dispositivo já existe na API
     * @param deviceId UUID do dispositivo
     * @return true se dispositivo existe
     */
    static bool checkDeviceExists(const String& deviceId);
    
    /**
     * @brief Registra um novo dispositivo na API
     * @param deviceId UUID do dispositivo
     * @return true se registro foi bem-sucedido
     */
    static bool registerDevice(const String& deviceId);
    
    /**
     * @brief Obtém configuração MQTT da API
     * @param credentials Estrutura onde serão armazenadas as credenciais
     * @return true se credenciais foram obtidas com sucesso
     */
    static bool fetchMQTTConfig(MQTTCredentials& credentials);
    
    /**
     * @brief Atualiza informações de rede do dispositivo na API
     * @param deviceId UUID do dispositivo
     * @return true se atualização foi bem-sucedida
     */
    static bool updateDeviceNetworkInfo(const String& deviceId);
    
    /**
     * @brief Salva timestamp do último registro válido
     */
    static void saveRegistrationTime();
    
    /**
     * @brief Salva credenciais MQTT no armazenamento persistente
     * @param creds Credenciais a serem salvas
     * @return true se salvamento foi bem-sucedido
     */
    static bool saveMQTTCredentials(const MQTTCredentials& creds);
    
    /**
     * @brief Constrói URL completa da API
     * @param endpoint Endpoint da API (ex: "/devices")
     * @return URL completa
     */
    static String buildApiUrl(const String& endpoint);
    
    /**
     * @brief Executa requisição HTTP com retry logic
     * @param url URL da requisição
     * @param method Método HTTP (GET, POST, PUT)
     * @param payload Dados JSON para envio (vazio para GET)
     * @param response Resposta recebida da API
     * @return true se requisição foi bem-sucedida
     */
    static bool makeHttpRequest(const String& url, const String& method, const String& payload, String& response);
};