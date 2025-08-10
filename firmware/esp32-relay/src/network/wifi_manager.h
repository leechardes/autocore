#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H

#include <Arduino.h>
#include <WiFi.h>

// Classe simples para gerenciamento WiFi
class WiFiManager {
public:
    WiFiManager() {}
    
    bool begin() {
        return true;  // Placeholder
    }
    
    bool connect(const String& ssid, const String& password) {
        WiFi.begin(ssid.c_str(), password.c_str());
        
        int attempts = 0;
        while (WiFi.status() != WL_CONNECTED && attempts < 20) {
            delay(500);
            attempts++;
        }
        
        return WiFi.status() == WL_CONNECTED;
    }
    
    bool isConnected() {
        return WiFi.status() == WL_CONNECTED;
    }
    
    String getIP() {
        return WiFi.localIP().toString();
    }
    
    void disconnect() {
        WiFi.disconnect();
    }
};

// Instância global
extern WiFiManager wifiManager;

#endif // WIFI_MANAGER_H