#ifndef RELAY_CHANNEL_H
#define RELAY_CHANNEL_H

#include <Arduino.h>
#include "../config/device_config.h"

class RelayChannel {
private:
    int channelId;
    RelayChannelConfig config;
    RelayChannelState state;
    
    // Validações de segurança
    bool validateTimeWindow();
    bool validateMaxOnTime();
    bool validatePassword(const String& password);
    bool validateDualAction();
    
public:
    RelayChannel(int id);
    ~RelayChannel();
    
    // Configuração
    bool configure(const RelayChannelConfig& channelConfig);
    RelayChannelConfig getConfig() { return config; }
    bool isEnabled() { return config.enabled; }
    
    // Estado
    RelayChannelState getState() { return state; }
    bool getCurrentState() { return state.current_state; }
    unsigned long getLastStateChange() { return state.last_state_change; }
    
    // Operações principais
    bool turnOn(const String& user = "", const String& password = "", bool confirmation = false);
    bool turnOff(const String& user = "");
    bool toggle(const String& user = "", const String& password = "", bool confirmation = false);
    
    // Operações momentâneas (com heartbeat)
    bool startMomentary(const String& user = "");
    bool stopMomentary();
    bool processHeartbeat(int sequence, unsigned long timestamp);
    bool isWaitingForHeartbeat() { return state.waiting_for_heartbeat; }
    
    // Proteções de segurança
    bool checkSafetyShutoff();
    void emergencyStop();
    void resetSafetyFlags();
    
    // Validações
    bool canOperate(const String& user = "", const String& password = "", bool confirmation = false);
    String getLastError() { return lastError; }
    
    // Utilitários
    void update(); // Deve ser chamado regularmente
    String getStatusJSON();
    String getTelemetryJSON();
    void printStatus();
    
    // Debug
    void setDebugMode(bool enabled) { debugEnabled = enabled; }
    bool debugEnabled = false;
    
private:
    String lastError = "";
    unsigned long lastUpdate = 0;
    
    // Métodos privados
    void setPhysicalState(bool state);
    void logStateChange(bool newState, const String& reason);
    void publishSafetyEvent(const String& event, const String& reason);
    bool isInTimeWindow();
    unsigned long getOnDuration();
};

#endif // RELAY_CHANNEL_H