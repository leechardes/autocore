/**
 * @file ButtonStateManager.h
 * @brief Gerenciador de estado dos botões via MQTT
 * 
 * Mantém o estado real de todos os botões (relés, modos, presets, etc)
 * baseado em mensagens MQTT e atualiza a interface conforme feedback
 */

#ifndef BUTTON_STATE_MANAGER_H
#define BUTTON_STATE_MANAGER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <map>
#include "core/MQTTClient.h"

// Forward declaration
class NavButton;
class ScreenManager;

/**
 * @brief Estrutura para armazenar estado de um botão
 */
struct ButtonState {
    bool isActive;              // Estado atual (ON/OFF, ativo/inativo)
    String currentValue;        // Valor atual (para modos, presets, etc)
    unsigned long lastUpdate;   // Timestamp da última atualização
    String lastSource;          // Quem atualizou (device_id)
};

/**
 * @brief Gerenciador de estado dos botões
 * 
 * Escuta mensagens MQTT de status e atualiza a interface
 * conforme o estado real de todos os tipos de botões
 */
class ButtonStateManager {
private:
    MQTTClient* mqttClient;
    ScreenManager* screenManager;
    
    // Mapa genérico: button_id -> state
    std::map<String, ButtonState> buttonStates;
    
    // Callbacks registrados por botão
    std::map<String, NavButton*> buttonCallbacks; // key: button unique ID
    
    static ButtonStateManager* instance;
    
public:
    ButtonStateManager(MQTTClient* mqtt, ScreenManager* screen);
    
    // Singleton
    static ButtonStateManager* getInstance() { return instance; }
    
    // Inicializar e subscrever aos tópicos
    void begin();
    
    // Processar diferentes tipos de mensagens de status
    void processRelayStatus(const String& boardId, int channel, const String& state, const String& source);
    void processModeStatus(const String& mode, bool active, const String& source);
    void processPresetStatus(const String& preset, bool active, const String& source);
    void processGenericStatus(const String& buttonId, bool active, const String& value, const String& source);
    
    // Registrar botão para receber atualizações
    void registerButton(NavButton* button);
    void unregisterButton(const String& buttonId);
    
    // Obter estado atual
    ButtonState getButtonState(const String& buttonId);
    bool isButtonActive(const String& buttonId);
    
    // Gerar ID único para cada tipo de botão
    static String makeButtonId(NavButton* button);
    
    // Handler MQTT genérico (público para ser chamado pelo MQTTClient)
    void handleMQTTMessage(const String& topic, JsonDocument& payload);
    
private:
    // Atualizar estado e notificar
    void updateButtonState(const String& buttonId, bool active, const String& value, const String& source);
    
    // Notificar botão sobre mudança de estado
    void notifyButton(const String& buttonId);
};

#endif