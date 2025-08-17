/**
 * @file ScreenApiClient.h
 * @brief Cliente API REST para carregamento de configurações de telas
 * 
 * Esta classe substitui o carregamento de configurações via MQTT por API REST,
 * proporcionando maior performance e flexibilidade para configurações grandes.
 * 
 * @author Sistema AutoCore
 * @version 2.0.0
 * @date 2025-08-12
 */

#ifndef SCREEN_API_CLIENT_H
#define SCREEN_API_CLIENT_H

#include <Arduino.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "../config/DeviceConfig.h"

/**
 * @class ScreenApiClient
 * @brief Cliente HTTP para carregar configurações de telas via API REST
 * 
 * Funcionalidades:
 * - Carregamento de configurações via HTTP
 * - Cache inteligente com TTL configurável
 * - Retry automático com backoff exponencial  
 * - Suporte a autenticação Bearer Token
 * - Validação de conexão e error handling
 */
class ScreenApiClient {
private:
    HTTPClient httpClient;
    String baseUrl;
    String cachedConfig;
    unsigned long cacheTimestamp;
    unsigned long cacheTimeout;
    int lastHttpCode;
    String lastError;
    
    /**
     * @brief Constrói URL completa do endpoint
     * @param endpoint Endpoint da API (ex: "/screens")
     * @return URL completa formatada
     */
    String buildUrl(const String& endpoint);
    
    /**
     * @brief Faz parsing da resposta de screens
     * @param response JSON string da resposta
     * @param doc JsonDocument para armazenar o resultado
     * @return true se o parsing foi bem-sucedido
     */
    bool parseScreensResponse(const String& response, JsonDocument& doc);
    
    /**
     * @brief Faz parsing da resposta de items de uma tela
     * @param response JSON string da resposta
     * @param items JsonArray para armazenar os itens
     * @return true se o parsing foi bem-sucedido
     */
    bool parseItemsResponse(const String& response, JsonArray& items);
    
    /**
     * @brief Executa requisição HTTP com retry e error handling
     * @param endpoint Endpoint para requisição
     * @param response String para armazenar resposta
     * @return true se requisição bem-sucedida
     */
    bool makeHttpRequest(const String& endpoint, String& response);
    
public:
    /**
     * @brief Construtor da classe
     */
    ScreenApiClient();
    
    /**
     * @brief Destructor da classe
     */
    ~ScreenApiClient();
    
    /**
     * @brief Inicializa o cliente HTTP
     * @return true se inicialização bem-sucedida
     */
    bool begin();
    
    /**
     * @brief Carrega configuração completa das telas
     * @param config JsonDocument para armazenar configuração
     * @return true se carregamento bem-sucedido
     */
    bool loadConfiguration(JsonDocument& config);
    
    /**
     * @brief Carrega lista de telas disponíveis
     * @param screens JsonArray para armazenar telas
     * @return true se carregamento bem-sucedido
     */
    bool getScreens(JsonArray& screens);
    
    /**
     * @brief Carrega itens de uma tela específica
     * @param screenId ID da tela
     * @param items JsonArray para armazenar itens
     * @return true se carregamento bem-sucedido
     */
    bool getScreenItems(int screenId, JsonArray& items);
    
    /**
     * @brief Testa conectividade com a API
     * @return true se API está acessível
     */
    bool testConnection();
    
    /**
     * @brief Verifica se o cache ainda é válido
     * @return true se cache é válido
     */
    bool isCacheValid();
    
    /**
     * @brief Limpa o cache forçando nova requisição
     */
    void clearCache();
    
    /**
     * @brief Retorna último erro ocorrido
     * @return String com descrição do erro
     */
    String getLastError() const { return lastError; }
    
    /**
     * @brief Retorna último código HTTP
     * @return Código HTTP da última requisição
     */
    int getLastHttpCode() const { return lastHttpCode; }
    
    /**
     * @brief Define timeout customizado para requisições
     * @param timeout Timeout em milissegundos
     */
    void setTimeout(unsigned long timeout);
    
    /**
     * @brief Define TTL customizado para cache
     * @param ttl TTL em milissegundos
     */
    void setCacheTTL(unsigned long ttl);
    
    /**
     * @brief Carrega lista de devices disponíveis
     * @param devices JsonArray para armazenar devices
     * @return true se carregamento bem-sucedido
     */
    bool getDevices(JsonArray& devices);
    
    /**
     * @brief Carrega lista de relay boards disponíveis
     * @param boards JsonArray para armazenar relay boards
     * @return true se carregamento bem-sucedido
     */
    bool getRelayBoards(JsonArray& boards);
    
    /**
     * @brief Carrega configuração completa incluindo devices e relay boards
     * @param config JsonDocument para armazenar configuração completa
     * @return true se carregamento bem-sucedido
     */
    bool loadFullConfiguration(JsonDocument& config);

    /**
     * @brief Carrega mapeamento de ícones para plataforma ESP32
     * @param icons JsonDocument para armazenar ícones
     * @return true se carregamento bem-sucedido
     */
    bool getIcons(JsonDocument& icons);

    /**
     * @brief Carrega temas disponíveis
     * @param themes JsonDocument para armazenar temas
     * @return true se carregamento bem-sucedido
     */
    bool getThemes(JsonDocument& themes);

private:
    /**
     * @brief Processa resposta unificada do endpoint /api/config/full
     * @param response JsonDocument com resposta unificada
     * @param config JsonDocument para armazenar configuração processada
     * @return true se processamento bem-sucedido
     */
    bool processUnifiedResponse(const JsonDocument& response, JsonDocument& config);

    /**
     * @brief Carrega configuração usando múltiplas requisições (fallback)
     * @param config JsonDocument para armazenar configuração
     * @return true se carregamento bem-sucedido
     */
    bool loadLegacyConfiguration(JsonDocument& config);
};

#endif // SCREEN_API_CLIENT_H