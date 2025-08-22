/**
 * @file ScreenTemplate.h
 * @brief Template para criação de novas telas LVGL
 * @author AutoCore System
 * @version 1.0.0
 * @date 2025-01-18
 * 
 * Este template fornece a estrutura básica para criar novas telas
 * no sistema AutoCore ESP32 Display.
 */

#ifndef SCREEN_TEMPLATE_H
#define SCREEN_TEMPLATE_H

#include <Arduino.h>
#include <lvgl.h>
#include <ArduinoJson.h>
#include "ScreenBase.h"
#include "NavButton.h"
#include "core/Logger.h"

/**
 * @class ScreenTemplate
 * @brief Template base para nova tela do sistema
 * 
 * Substitua "ScreenTemplate" pelo nome da sua tela (ex: SettingsScreen)
 * Implemente todos os métodos virtuais da classe base ScreenBase
 */
class ScreenTemplate : public ScreenBase {
private:
    // Componentes LVGL da tela
    lv_obj_t* container = nullptr;
    lv_obj_t* header = nullptr;
    lv_obj_t* content = nullptr;
    lv_obj_t* footer = nullptr;
    
    // Botões e widgets específicos
    std::vector<NavButton*> buttons;
    lv_obj_t* titleLabel = nullptr;
    lv_obj_t* statusLabel = nullptr;
    
    // Estado da tela
    bool isInitialized = false;
    String currentData = "";
    
    // Logger
    Logger* logger = nullptr;
    
    // Métodos privados de inicialização
    void createLayout();
    void createHeader();
    void createContent();
    void createFooter();
    void setupEventHandlers();
    void applyTheme();
    
    // Métodos de atualização de dados
    void updateDisplayData();
    void refreshButtonStates();
    
    // Event handlers
    static void backButtonCallback(NavButton* button);
    static void menuButtonCallback(NavButton* button);
    static void customButtonCallback(NavButton* button);

public:
    /**
     * @brief Construtor da tela
     * @param screenId ID único da tela
     * @param config Configuração JSON da tela
     */
    ScreenTemplate(const String& screenId, JsonObject& config);
    
    /**
     * @brief Destrutor - cleanup de recursos
     */
    virtual ~ScreenTemplate();
    
    // Métodos virtuais obrigatórios do ScreenBase
    
    /**
     * @brief Inicializa a tela e seus componentes
     * @return true se inicialização foi bem-sucedida
     */
    virtual bool initialize() override;
    
    /**
     * @brief Mostra a tela (torna ativa)
     */
    virtual void show() override;
    
    /**
     * @brief Esconde a tela
     */
    virtual void hide() override;
    
    /**
     * @brief Atualiza dados da tela
     * @param data Novos dados JSON
     */
    virtual void update(JsonObject& data) override;
    
    /**
     * @brief Cleanup e liberação de recursos
     */
    virtual void cleanup() override;
    
    /**
     * @brief Verifica se tela está ativa
     * @return true se tela está sendo exibida
     */
    virtual bool isActive() override;
    
    /**
     * @brief Obtém ID da tela
     * @return String com ID único
     */
    virtual String getId() override;
    
    // Métodos específicos da tela
    
    /**
     * @brief Configura dados específicos da tela
     * @param data Dados JSON com configurações
     */
    void setScreenData(JsonObject& data);
    
    /**
     * @brief Adiciona botão customizado à tela
     * @param buttonConfig Configuração JSON do botão
     * @return Ponteiro para NavButton criado
     */
    NavButton* addCustomButton(JsonObject& buttonConfig);
    
    /**
     * @brief Remove botão da tela
     * @param buttonId ID do botão a ser removido
     */
    void removeButton(const String& buttonId);
    
    /**
     * @brief Atualiza status mostrado na tela
     * @param status Novo status a ser exibido
     * @param color Cor do status (opcional)
     */
    void updateStatus(const String& status, lv_color_t color = lv_color_white());
    
    /**
     * @brief Processa comando recebido
     * @param command Comando JSON recebido
     * @return true se comando foi processado
     */
    bool processCommand(JsonObject& command);
    
    /**
     * @brief Configura callback personalizado
     * @param eventType Tipo do evento
     * @param callback Função callback
     */
    void setCustomCallback(const String& eventType, std::function<void()> callback);
    
    // Getters
    lv_obj_t* getContainer() const { return container; }
    lv_obj_t* getContentArea() const { return content; }
    bool getIsInitialized() const { return isInitialized; }
    size_t getButtonCount() const { return buttons.size(); }
    
    // Setters
    void setTitle(const String& title);
    void setBackgroundColor(lv_color_t color);
    void setVisible(bool visible);
};

#endif // SCREEN_TEMPLATE_H