#ifndef HEADER_H
#define HEADER_H

#include <lvgl.h>
#include <Arduino.h>

enum WiFiState {
    WIFI_DISCONNECTED,
    WIFI_CONNECTING,
    WIFI_CONNECTED
};

enum MQTTState {
    MQTT_STATE_DISCONNECTED,
    MQTT_STATE_CONNECTING,
    MQTT_STATE_CONNECTED
};

enum ConnectionType {
    CONNECTION_WIFI,
    CONNECTION_MQTT
};

class Header {
private:
    lv_obj_t* container;
    lv_obj_t* titleLabel;
    lv_obj_t* wifiIcon;
    lv_obj_t* mqttIcon;
    lv_obj_t* iconsContainer;
    
    WiFiState wifiState = WIFI_DISCONNECTED;
    MQTTState mqttState = MQTT_STATE_DISCONNECTED;
    
    void createLayout();
    void updateIcon(lv_obj_t* icon, bool connected, bool connecting);
    void startBlinkAnimation(lv_obj_t* icon);
    void stopBlinkAnimation(lv_obj_t* icon);
    
public:
    Header(lv_obj_t* parent);
    ~Header();
    
    void setTitle(const String& title);
    void setWiFiStatus(WiFiState state);
    void setMQTTStatus(MQTTState state);
    
    void startConnecting(ConnectionType type);
    void stopConnecting(ConnectionType type);
    
    void updateSignalStrength(int rssi);
    void onMQTTActivity();
    
    lv_obj_t* getObject() { return container; }
};

#endif