#ifndef RELAY_CONTROLLER_H
#define RELAY_CONTROLLER_H

#include <Arduino.h>
#include <vector>
#include "../config/device_config.h"
#include "relay_channel.h"

class RelayController {
private:
    RelayChannel* channels[MAX_RELAY_CHANNELS];
    int totalChannels;
    bool initialized = false;
    
    // Estado geral
    bool emergencyStopActive = false;
    unsigned long lastTelemetryPublish = 0;
    unsigned long lastStatusUpdate = 0;
    
    // Estatísticas
    unsigned long totalOperations = 0;
    unsigned long totalErrors = 0;
    unsigned long safetyShutoffs = 0;
    
    // Configurações
    unsigned long telemetryInterval = TELEMETRY_PUBLISH_INTERVAL;
    unsigned long statusInterval = STATUS_PUBLISH_INTERVAL;
    
public:
    RelayController();
    ~RelayController();
    
    // Inicialização
    bool begin(int numChannels = 16);
    void end();
    bool isInitialized() { return initialized; }
    
    // Configuração dos canais
    bool configureChannel(int channel, const RelayChannelConfig& config);
    bool configureFromJSON(const String& configJson);
    bool loadConfigurationFromNVS();
    bool saveConfigurationToNVS();
    
    // Operações de relé
    bool setRelayState(int channel, bool state, const String& user = "", 
                      const String& password = "", bool confirmation = false);
    bool toggleRelay(int channel, const String& user = "", 
                    const String& password = "", bool confirmation = false);
    bool getRelayState(int channel);
    
    // Operações momentâneas (com heartbeat)
    bool startMomentaryOperation(int channel, const String& user = "");
    bool stopMomentaryOperation(int channel);
    bool processHeartbeat(int channel, int sequence, unsigned long timestamp);
    
    // Proteções de segurança
    void emergencyStop();
    void resetEmergencyStop();
    bool isEmergencyStopActive() { return emergencyStopActive; }
    void checkAllSafetyShutoffs();
    void resetAllSafetyFlags();
    
    // Estado e informações
    RelayChannel* getChannel(int channel);
    RelayChannelConfig getChannelConfig(int channel);
    RelayChannelState getChannelState(int channel);
    int getTotalChannels() { return totalChannels; }
    
    // Operações em lote
    bool setMultipleRelays(const std::vector<int>& channels, bool state, const String& user = "");
    bool turnOffAllRelays(const String& reason = "system");
    int getActiveRelaysCount();
    std::vector<int> getActiveRelays();
    
    // Manutenção e atualização
    void update(); // Deve ser chamado regularmente no loop
    void publishTelemetry();
    void publishStatus();
    
    // Estatísticas
    unsigned long getTotalOperations() { return totalOperations; }
    unsigned long getTotalErrors() { return totalErrors; }
    unsigned long getSafetyShutoffs() { return safetyShutoffs; }
    String getStatisticsJSON();
    void resetStatistics();
    
    // Configurações
    void setTelemetryInterval(unsigned long intervalMs) { telemetryInterval = intervalMs; }
    void setStatusInterval(unsigned long intervalMs) { statusInterval = intervalMs; }
    
    // JSON e serialização
    String getAllChannelsStatusJSON();
    String getAllChannelsTelemetryJSON();
    String getSystemStatusJSON();
    
    // Validação
    bool isValidChannel(int channel);
    bool isChannelEnabled(int channel);
    bool isChannelMomentary(int channel);
    
    // Debug e manutenção
    void printAllChannelsStatus();
    void setDebugMode(bool enabled);
    bool debugEnabled = false;
    
private:
    // Métodos privados
    void incrementOperation() { totalOperations++; }
    void incrementError() { totalErrors++; }
    void incrementSafetyShutoff() { safetyShutoffs++; }
    bool validateChannelNumber(int channel);
};

extern RelayController relayController;

#endif // RELAY_CONTROLLER_H