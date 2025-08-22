/**
 * @file ComponentTemplate.h
 * @brief Template para criação de novos componentes do sistema
 * @author AutoCore System
 * @version 1.0.0
 * @date 2025-01-18
 * 
 * Este template fornece a estrutura básica para criar novos componentes
 * reutilizáveis no sistema AutoCore ESP32 Display.
 */

#ifndef COMPONENT_TEMPLATE_H
#define COMPONENT_TEMPLATE_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <functional>
#include <memory>
#include "core/Logger.h"

/**
 * @class ComponentTemplate
 * @brief Template base para novos componentes do sistema
 * 
 * Substitua "ComponentTemplate" pelo nome do seu componente (ex: SensorManager)
 * Este template fornece estrutura padrão para componentes AutoCore
 */
class ComponentTemplate {
private:
    // Identificação do componente
    String componentId;
    String componentType;
    String componentVersion;
    
    // Estado do componente
    bool isInitialized = false;
    bool isRunning = false;
    bool isEnabled = true;
    
    // Configuração
    JsonDocument config;
    String configHash;
    
    // Logging
    Logger* logger = nullptr;
    
    // Callbacks e eventos
    std::function<void(const String&)> errorCallback;
    std::function<void(const String&, JsonObject&)> eventCallback;
    std::function<void(JsonObject&)> dataCallback;
    
    // Métricas e estatísticas
    unsigned long startTime = 0;
    unsigned long lastActivity = 0;
    uint32_t operationCount = 0;
    uint32_t errorCount = 0;
    
    // Métodos privados de inicialização
    bool validateConfiguration();
    void setupDefaultConfig();
    void initializeResources();
    void setupEventHandlers();
    
    // Métodos privados de operação
    void updateMetrics();
    void handleError(const String& error);
    void emitEvent(const String& eventType, JsonObject& data);
    
    // Cleanup interno
    void releaseResources();

protected:
    /**
     * @brief Método protegido para subclasses implementarem inicialização específica
     * @return true se inicialização específica foi bem-sucedida
     */
    virtual bool doInitialize() = 0;
    
    /**
     * @brief Método protegido para subclasses implementarem cleanup específico
     */
    virtual void doCleanup() = 0;
    
    /**
     * @brief Método protegido para subclasses processarem configuração específica
     * @param config Configuração JSON
     * @return true se configuração foi processada com sucesso
     */
    virtual bool processConfiguration(JsonObject& config) = 0;
    
    /**
     * @brief Método protegido para subclasses implementarem operação principal
     * Chamado periodicamente pelo loop principal
     */
    virtual void doOperation() = 0;
    
    /**
     * @brief Método protegido para subclasses reportarem status específico
     * @param status Objeto JSON para adicionar status específico
     */
    virtual void getComponentStatus(JsonObject& status) = 0;

public:
    /**
     * @brief Construtor do componente
     * @param id ID único do componente
     * @param type Tipo do componente
     * @param version Versão do componente
     */
    ComponentTemplate(const String& id, const String& type, const String& version = "1.0.0");
    
    /**
     * @brief Destrutor virtual para cleanup adequado
     */
    virtual ~ComponentTemplate();
    
    // Métodos principais do ciclo de vida
    
    /**
     * @brief Inicializa o componente com configuração
     * @param config Configuração JSON do componente
     * @return true se inicialização foi bem-sucedida
     */
    bool initialize(JsonObject& config);
    
    /**
     * @brief Inicia operação do componente
     * @return true se início foi bem-sucedido
     */
    bool start();
    
    /**
     * @brief Para operação do componente
     */
    void stop();
    
    /**
     * @brief Reinicia o componente
     * @return true se reinício foi bem-sucedido
     */
    bool restart();
    
    /**
     * @brief Loop principal do componente - chamar periodicamente
     */
    void loop();
    
    /**
     * @brief Cleanup e liberação de recursos
     */
    void cleanup();
    
    // Métodos de configuração
    
    /**
     * @brief Atualiza configuração do componente
     * @param newConfig Nova configuração JSON
     * @return true se atualização foi bem-sucedida
     */
    bool updateConfiguration(JsonObject& newConfig);
    
    /**
     * @brief Obtém configuração atual
     * @return Referência para configuração JSON
     */
    JsonObject getConfiguration();
    
    /**
     * @brief Verifica se configuração mudou
     * @param configData Dados de configuração para verificar
     * @return true se configuração mudou
     */
    bool hasConfigurationChanged(const String& configData);
    
    /**
     * @brief Recarrega configuração de fonte externa
     * @param source Fonte da configuração (file, api, mqtt)
     * @return true se recarregamento foi bem-sucedido
     */
    bool reloadConfiguration(const String& source = "");
    
    // Métodos de status e diagnóstico
    
    /**
     * @brief Obtém status completo do componente
     * @return JSON com status detalhado
     */
    JsonDocument getStatus();
    
    /**
     * @brief Obtém métricas de performance
     * @return JSON com métricas
     */
    JsonDocument getMetrics();
    
    /**
     * @brief Executa auto-diagnóstico
     * @return JSON com resultados do diagnóstico
     */
    JsonDocument runDiagnostics();
    
    /**
     * @brief Verifica saúde do componente
     * @return true se componente está saudável
     */
    bool isHealthy();
    
    // Métodos de callback e eventos
    
    /**
     * @brief Configura callback de erro
     * @param callback Função a ser chamada em caso de erro
     */
    void setErrorCallback(std::function<void(const String&)> callback);
    
    /**
     * @brief Configura callback de evento
     * @param callback Função a ser chamada para eventos
     */
    void setEventCallback(std::function<void(const String&, JsonObject&)> callback);
    
    /**
     * @brief Configura callback de dados
     * @param callback Função a ser chamada para novos dados
     */
    void setDataCallback(std::function<void(JsonObject&)> callback);
    
    /**
     * @brief Envia comando para o componente
     * @param command Comando JSON
     * @return true se comando foi processado
     */
    virtual bool processCommand(JsonObject& command);
    
    /**
     * @brief Processa dados externos
     * @param data Dados JSON recebidos
     */
    virtual void processData(JsonObject& data);
    
    // Getters
    String getId() const { return componentId; }
    String getType() const { return componentType; }
    String getVersion() const { return componentVersion; }
    bool getIsInitialized() const { return isInitialized; }
    bool getIsRunning() const { return isRunning; }
    bool getIsEnabled() const { return isEnabled; }
    unsigned long getUptime() const { return millis() - startTime; }
    unsigned long getLastActivity() const { return lastActivity; }
    uint32_t getOperationCount() const { return operationCount; }
    uint32_t getErrorCount() const { return errorCount; }
    
    // Setters
    void setEnabled(bool enabled) { isEnabled = enabled; }
    void setComponentVersion(const String& version) { componentVersion = version; }
    
    // Métodos estáticos utilitários
    
    /**
     * @brief Cria hash MD5 de string
     * @param data String para gerar hash
     * @return Hash MD5 em formato hex
     */
    static String createHash(const String& data);
    
    /**
     * @brief Valida formato JSON
     * @param jsonString String JSON para validar
     * @return true se JSON é válido
     */
    static bool isValidJson(const String& jsonString);
    
    /**
     * @brief Merge de dois objetos JSON
     * @param base Objeto base
     * @param overlay Objeto para sobrepor
     * @return Objeto merged
     */
    static JsonDocument mergeJsonObjects(JsonObject& base, JsonObject& overlay);
    
    /**
     * @brief Converte millis para string de tempo legível
     * @param milliseconds Tempo em milissegundos
     * @return String formatada (ex: "2d 3h 45m")
     */
    static String formatUptime(unsigned long milliseconds);
};

/**
 * @brief Factory para criação de componentes
 */
class ComponentFactory {
public:
    /**
     * @brief Cria componente pelo tipo
     * @param type Tipo do componente
     * @param id ID único
     * @param config Configuração inicial
     * @return Ponteiro único para componente criado
     */
    static std::unique_ptr<ComponentTemplate> createComponent(
        const String& type, 
        const String& id, 
        JsonObject& config
    );
    
    /**
     * @brief Registra novo tipo de componente
     * @param type Tipo do componente
     * @param factory Função factory para criar o componente
     */
    static void registerComponentType(
        const String& type,
        std::function<std::unique_ptr<ComponentTemplate>(const String&, JsonObject&)> factory
    );
    
    /**
     * @brief Lista tipos de componentes registrados
     * @return Array com tipos disponíveis
     */
    static std::vector<String> getRegisteredTypes();
};

/**
 * @brief Manager para gerenciar múltiplos componentes
 */
class ComponentManager {
private:
    std::vector<std::unique_ptr<ComponentTemplate>> components;
    Logger* logger;
    
public:
    ComponentManager();
    ~ComponentManager();
    
    /**
     * @brief Adiciona componente ao manager
     * @param component Componente a ser gerenciado
     */
    void addComponent(std::unique_ptr<ComponentTemplate> component);
    
    /**
     * @brief Remove componente do manager
     * @param componentId ID do componente a remover
     */
    void removeComponent(const String& componentId);
    
    /**
     * @brief Obtém componente pelo ID
     * @param componentId ID do componente
     * @return Ponteiro para componente ou nullptr
     */
    ComponentTemplate* getComponent(const String& componentId);
    
    /**
     * @brief Inicializa todos os componentes
     * @return true se todos foram inicializados com sucesso
     */
    bool initializeAll();
    
    /**
     * @brief Inicia todos os componentes
     * @return true se todos foram iniciados com sucesso
     */
    bool startAll();
    
    /**
     * @brief Para todos os componentes
     */
    void stopAll();
    
    /**
     * @brief Loop de todos os componentes
     */
    void loopAll();
    
    /**
     * @brief Cleanup de todos os componentes
     */
    void cleanupAll();
    
    /**
     * @brief Obtém status de todos os componentes
     * @return JSON com status consolidado
     */
    JsonDocument getAllStatus();
    
    /**
     * @brief Obtém contagem de componentes
     * @return Número de componentes gerenciados
     */
    size_t getComponentCount() const { return components.size(); }
};

#endif // COMPONENT_TEMPLATE_H