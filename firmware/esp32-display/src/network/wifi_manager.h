/**
 * AutoCore ESP32 Display - WiFi Manager
 * 
 * Gerencia conexões WiFi, modo AP e reconexão automática
 * Baseado no padrão do firmware de relé
 */

#pragma once

#include <Arduino.h>
#include <WiFi.h>
#include <DNSServer.h>
#include "../config/device_config.h"

/**
 * Estados da conexão WiFi
 */
enum WiFiState {
    WIFI_DISCONNECTED = 0,
    WIFI_CONNECTING = 1,
    WIFI_CONNECTED = 2,
    WIFI_AP_MODE = 3,
    WIFI_ERROR = 4,
    WIFI_RECONNECTING = 5
};

/**
 * Gerenciador de conectividade WiFi
 * Responsável por conexões, modo AP e monitoramento
 */
class WiFiManager {
private:
    WiFiState currentState;
    unsigned long stateChangeTime;
    unsigned long lastConnectionAttempt;
    unsigned long lastReconnectAttempt;
    int connectionAttempts;
    
    // Access Point
    DNSServer* dnsServer;
    bool apModeActive;
    String apSSID;
    String apPassword;
    IPAddress apIP;
    
    // Configurações
    static constexpr int MAX_CONNECTION_ATTEMPTS = 20;
    static constexpr unsigned long CONNECTION_TIMEOUT = 30000;  // 30 segundos
    static constexpr unsigned long RECONNECT_INTERVAL = 10000;  // 10 segundos
    static constexpr unsigned long STATE_TIMEOUT = 60000;       // 60 segundos
    
    // Callbacks
    std::function<void(WiFiState)> stateChangeCallback;
    std::function<void(IPAddress)> connectedCallback;
    std::function<void()> disconnectedCallback;
    
    // Métodos internos
    void changeState(WiFiState newState);
    bool startAccessPoint();
    void stopAccessPoint();
    String generateAPName();
    
public:
    WiFiManager();
    ~WiFiManager();
    
    // Inicialização
    bool begin();
    bool isInitialized() const { return true; }
    
    // Estado
    WiFiState getState() const { return currentState; }
    bool isConnected() const { return currentState == WIFI_CONNECTED; }
    bool isAPMode() const { return currentState == WIFI_AP_MODE; }
    String getStateString() const;
    
    // Conexão
    bool connect(const String& ssid, const String& password);
    bool disconnect();
    bool reconnect();
    
    // Access Point
    bool enableAPMode();
    bool disableAPMode();
    String getAPName() const { return apSSID; }
    IPAddress getAPIP() const { return apIP; }
    
    // Informações da rede
    String getSSID() const;
    IPAddress getLocalIP() const;
    int getSignalStrength() const;
    String getSignalQuality() const;
    String getMacAddress() const;
    
    // Monitoramento
    void update();
    void handleReconnection();
    
    // Callbacks
    void onStateChange(std::function<void(WiFiState)> callback) { stateChangeCallback = callback; }
    void onConnected(std::function<void(IPAddress)> callback) { connectedCallback = callback; }
    void onDisconnected(std::function<void()> callback) { disconnectedCallback = callback; }
    
    // Scan de redes
    int scanNetworks();
    String getScannedSSID(int index);
    int getScannedRSSI(int index);
    String getScannedSecurity(int index);
    
    // Status e diagnóstico
    void printStatus() const;
    void printNetworkInfo() const;
    String getStatusJSON() const;
    
    // Utilitários
    static String signalStrengthToQuality(int rssi);
    static String encryptionTypeToString(wifi_auth_mode_t type);
    
    // Debug
    bool debugEnabled = true;
};

// Instância global
extern WiFiManager wifiManager;