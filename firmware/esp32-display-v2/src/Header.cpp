#include "Header.h"
#include "ui/Theme.h"
#include "Layout.h"
#include "utils/StringUtils.h"

Header::Header(lv_obj_t* parent) {
    container = lv_obj_create(parent);
    createLayout();
}

Header::~Header() {
    if (container) {
        lv_obj_del(container);
    }
}

void Header::createLayout() {
    // Container principal já foi criado no construtor
    lv_obj_set_size(container, Layout::DISPLAY_WIDTH, Layout::HEADER_HEIGHT);
    lv_obj_align(container, LV_ALIGN_TOP_MID, 0, 0);
    
    // Aplicar tema
    lv_obj_set_style_bg_color(container, COLOR_BACKGROUND, 0);
    lv_obj_set_style_border_width(container, 0, 0);
    lv_obj_set_style_pad_all(container, 10, 0);
    lv_obj_clear_flag(container, LV_OBJ_FLAG_SCROLLABLE);
    
    // Título
    titleLabel = lv_label_create(container);
    lv_label_set_text(titleLabel, "Menu Principal");
    lv_obj_align(titleLabel, LV_ALIGN_LEFT_MID, 0, 0);
    lv_obj_set_style_text_color(titleLabel, COLOR_TEXT_ON, 0);
    lv_obj_set_style_text_font(titleLabel, &lv_font_montserrat_16, 0);  // Reduzido de 20 para 16
    
    // Container de ícones
    iconsContainer = lv_obj_create(container);
    lv_obj_set_size(iconsContainer, 60, 30);
    lv_obj_align(iconsContainer, LV_ALIGN_RIGHT_MID, 0, 0);
    lv_obj_set_style_bg_opa(iconsContainer, LV_OPA_TRANSP, 0);
    lv_obj_set_style_border_width(iconsContainer, 0, 0);
    lv_obj_set_style_pad_all(iconsContainer, 0, 0);
    lv_obj_clear_flag(iconsContainer, LV_OBJ_FLAG_SCROLLABLE);
    
    // Layout flexível para ícones
    lv_obj_set_flex_flow(iconsContainer, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(iconsContainer, LV_FLEX_ALIGN_END, 
                          LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    
    // WiFi Icon
    wifiIcon = lv_label_create(iconsContainer);
    lv_label_set_text(wifiIcon, LV_SYMBOL_WIFI);
    lv_obj_set_style_text_color(wifiIcon, COLOR_TEXT_ON, 0);  // Mesma cor do título
    lv_obj_set_style_text_font(wifiIcon, &lv_font_montserrat_14, 0);  // Reduzido de 16 para 14
    
    // Espaço entre ícones
    lv_obj_t* spacer = lv_obj_create(iconsContainer);
    lv_obj_set_size(spacer, 10, 1);
    lv_obj_set_style_bg_opa(spacer, LV_OPA_TRANSP, 0);
    lv_obj_set_style_border_width(spacer, 0, 0);
    
    // MQTT Icon  
    mqttIcon = lv_label_create(iconsContainer);
    lv_label_set_text(mqttIcon, LV_SYMBOL_UPLOAD);
    lv_obj_set_style_text_color(mqttIcon, COLOR_TEXT_ON, 0);  // Mesma cor do título
    lv_obj_set_style_text_font(mqttIcon, &lv_font_montserrat_14, 0);  // Reduzido de 16 para 14
}

void Header::setTitle(const String& title) {
    // Remover acentos e limitar comprimento para não sobrepor ícones
    String cleanTitle = StringUtils::removeAccents(title);
    String displayTitle = cleanTitle;
    if (cleanTitle.length() > 20) {
        displayTitle = cleanTitle.substring(0, 17) + "...";
    }
    lv_label_set_text(titleLabel, displayTitle.c_str());
}

void Header::setWiFiStatus(WiFiState state) {
    wifiState = state;
    
    switch(state) {
        case WIFI_DISCONNECTED:
            lv_obj_set_style_text_color(wifiIcon, COLOR_ERROR, 0);
            stopBlinkAnimation(wifiIcon);
            break;
            
        case WIFI_CONNECTING:
            lv_obj_set_style_text_color(wifiIcon, COLOR_WARNING, 0);
            startBlinkAnimation(wifiIcon);
            break;
            
        case WIFI_CONNECTED:
            lv_obj_set_style_text_color(wifiIcon, COLOR_BUTTON_ON, 0);
            stopBlinkAnimation(wifiIcon);
            break;
    }
}

void Header::setMQTTStatus(MQTTState state) {
    mqttState = state;
    
    switch(state) {
        case MQTT_STATE_DISCONNECTED:
            lv_obj_set_style_text_color(mqttIcon, COLOR_ERROR, 0);
            stopBlinkAnimation(mqttIcon);
            break;
            
        case MQTT_STATE_CONNECTING:
            lv_obj_set_style_text_color(mqttIcon, COLOR_WARNING, 0);
            startBlinkAnimation(mqttIcon);
            break;
            
        case MQTT_STATE_CONNECTED:
            lv_obj_set_style_text_color(mqttIcon, COLOR_BUTTON_ON, 0);
            stopBlinkAnimation(mqttIcon);
            break;
    }
}

void Header::startConnecting(ConnectionType type) {
    if (type == CONNECTION_WIFI) {
        setWiFiStatus(WIFI_CONNECTING);
    } else {
        setMQTTStatus(MQTT_STATE_CONNECTING);
    }
}

void Header::stopConnecting(ConnectionType type) {
    if (type == CONNECTION_WIFI) {
        stopBlinkAnimation(wifiIcon);
    } else {
        stopBlinkAnimation(mqttIcon);
    }
}

void Header::updateSignalStrength(int rssi) {
    // Poderia mudar o ícone baseado na força do sinal
    // Por enquanto, apenas mantém o ícone verde quando conectado
}

void Header::onMQTTActivity() {
    // Breve flash ao enviar/receber mensagens
    // Por enquanto não implementado
}

void Header::startBlinkAnimation(lv_obj_t* icon) {
    lv_anim_t anim;
    lv_anim_init(&anim);
    lv_anim_set_var(&anim, icon);
    lv_anim_set_values(&anim, LV_OPA_100, LV_OPA_30);
    lv_anim_set_time(&anim, 500);
    lv_anim_set_repeat_count(&anim, LV_ANIM_REPEAT_INFINITE);
    lv_anim_set_playback_time(&anim, 500);
    lv_anim_set_exec_cb(&anim, [](void* obj, int32_t value) {
        lv_obj_set_style_text_opa((lv_obj_t*)obj, value, 0);
    });
    lv_anim_start(&anim);
}

void Header::stopBlinkAnimation(lv_obj_t* icon) {
    lv_anim_del(icon, nullptr);
    lv_obj_set_style_text_opa(icon, LV_OPA_100, 0);
}