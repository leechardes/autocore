/**
 * @file Icons.h
 * @brief Sistema de ícones para o AutoTech HMI Display
 */

#ifndef ICONS_H
#define ICONS_H

#include <lvgl.h>

class Icons {
public:
    /**
     * @brief Retorna o símbolo LVGL correspondente ao ID do ícone
     * @param iconId ID do ícone
     * @return Símbolo LVGL ou ícone padrão se não encontrado
     */
    static const char* getIcon(const char* iconId) {
        // Mapeamento de IDs para símbolos LVGL
        if (strcmp(iconId, "home") == 0) return LV_SYMBOL_HOME;
        if (strcmp(iconId, "settings") == 0) return LV_SYMBOL_SETTINGS;
        if (strcmp(iconId, "power") == 0) return LV_SYMBOL_POWER;
        if (strcmp(iconId, "warning") == 0) return LV_SYMBOL_WARNING;
        if (strcmp(iconId, "wifi") == 0) return LV_SYMBOL_WIFI;
        if (strcmp(iconId, "battery") == 0) return LV_SYMBOL_BATTERY_FULL;
        if (strcmp(iconId, "light") == 0) return LV_SYMBOL_EYE_OPEN;
        if (strcmp(iconId, "light_high") == 0) return LV_SYMBOL_EYE_OPEN;
        if (strcmp(iconId, "light_low") == 0) return LV_SYMBOL_EYE_CLOSE;
        if (strcmp(iconId, "up") == 0) return LV_SYMBOL_UP;
        if (strcmp(iconId, "down") == 0) return LV_SYMBOL_DOWN;
        if (strcmp(iconId, "left") == 0) return LV_SYMBOL_LEFT;
        if (strcmp(iconId, "right") == 0) return LV_SYMBOL_RIGHT;
        if (strcmp(iconId, "ok") == 0) return LV_SYMBOL_OK;
        if (strcmp(iconId, "close") == 0) return LV_SYMBOL_CLOSE;
        if (strcmp(iconId, "plus") == 0) return LV_SYMBOL_PLUS;
        if (strcmp(iconId, "minus") == 0) return LV_SYMBOL_MINUS;
        if (strcmp(iconId, "play") == 0) return LV_SYMBOL_PLAY;
        if (strcmp(iconId, "pause") == 0) return LV_SYMBOL_PAUSE;
        if (strcmp(iconId, "stop") == 0) return LV_SYMBOL_STOP;
        if (strcmp(iconId, "next") == 0) return LV_SYMBOL_NEXT;
        if (strcmp(iconId, "prev") == 0) return LV_SYMBOL_PREV;
        if (strcmp(iconId, "list") == 0) return LV_SYMBOL_LIST;
        if (strcmp(iconId, "edit") == 0) return LV_SYMBOL_EDIT;
        if (strcmp(iconId, "save") == 0) return LV_SYMBOL_SAVE;
        if (strcmp(iconId, "trash") == 0) return LV_SYMBOL_TRASH;
        if (strcmp(iconId, "upload") == 0) return LV_SYMBOL_UPLOAD;
        if (strcmp(iconId, "download") == 0) return LV_SYMBOL_DOWNLOAD;
        if (strcmp(iconId, "refresh") == 0) return LV_SYMBOL_REFRESH;
        if (strcmp(iconId, "bell") == 0) return LV_SYMBOL_BELL;
        if (strcmp(iconId, "mute") == 0) return LV_SYMBOL_MUTE;
        if (strcmp(iconId, "volume") == 0) return LV_SYMBOL_VOLUME_MAX;
        if (strcmp(iconId, "image") == 0) return LV_SYMBOL_IMAGE;
        if (strcmp(iconId, "file") == 0) return LV_SYMBOL_FILE;
        if (strcmp(iconId, "folder") == 0) return LV_SYMBOL_DIRECTORY;
        if (strcmp(iconId, "gps") == 0) return LV_SYMBOL_GPS;
        if (strcmp(iconId, "bluetooth") == 0) return LV_SYMBOL_BLUETOOTH;
        if (strcmp(iconId, "usb") == 0) return LV_SYMBOL_USB;
        if (strcmp(iconId, "sd_card") == 0) return LV_SYMBOL_SD_CARD;
        if (strcmp(iconId, "call") == 0) return LV_SYMBOL_CALL;
        if (strcmp(iconId, "backspace") == 0) return LV_SYMBOL_BACKSPACE;
        if (strcmp(iconId, "keyboard") == 0) return LV_SYMBOL_KEYBOARD;
        
        // Ícones adicionais do LVGL
        if (strcmp(iconId, "star") == 0) return LV_SYMBOL_BARS;        // Usando BARS como genérico para star/favorito
        if (strcmp(iconId, "lightning") == 0) return LV_SYMBOL_CHARGE;
        if (strcmp(iconId, "tools") == 0) return LV_SYMBOL_SETTINGS;
        if (strcmp(iconId, "emergency") == 0) return LV_SYMBOL_WARNING;
        if (strcmp(iconId, "camping") == 0) return LV_SYMBOL_HOME;      // Usando HOME como genérico para camping
        if (strcmp(iconId, "power_off") == 0) return LV_SYMBOL_POWER;
        if (strcmp(iconId, "show") == 0) return LV_SYMBOL_PLAY;        // Usando PLAY como genérico para show
        if (strcmp(iconId, "turn_left") == 0) return LV_SYMBOL_LEFT;
        if (strcmp(iconId, "turn_right") == 0) return LV_SYMBOL_RIGHT;
        if (strcmp(iconId, "reverse") == 0) return LV_SYMBOL_DOWN;      // Usando DOWN como genérico para ré
        if (strcmp(iconId, "parking") == 0) return LV_SYMBOL_PAUSE;    // Usando PAUSE como genérico para parking
        
        // Ícones específicos do AutoTech
        if (strcmp(iconId, "4x4") == 0) return LV_SYMBOL_DRIVE;        // Usando DRIVE como genérico para 4x4
        if (strcmp(iconId, "4x2") == 0) return LV_SYMBOL_DRIVE;        // Usando DRIVE como genérico para 4x2
        if (strcmp(iconId, "4x4_low") == 0) return LV_SYMBOL_DRIVE;    // Usando DRIVE como genérico para 4x4 low
        if (strcmp(iconId, "winch") == 0) return LV_SYMBOL_LOOP;       // Usando LOOP como genérico para guincho
        if (strcmp(iconId, "winch_in") == 0) return LV_SYMBOL_UPLOAD;
        if (strcmp(iconId, "winch_out") == 0) return LV_SYMBOL_DOWNLOAD;
        if (strcmp(iconId, "compressor") == 0) return LV_SYMBOL_VOLUME_MAX; // Usando VOLUME como genérico para compressor
        if (strcmp(iconId, "horn") == 0) return LV_SYMBOL_BELL;
        if (strcmp(iconId, "siren") == 0) return LV_SYMBOL_BELL;       // Usando BELL como genérico para sirene
        if (strcmp(iconId, "brake") == 0) return LV_SYMBOL_STOP;
        if (strcmp(iconId, "fog") == 0) return LV_SYMBOL_EYE_CLOSE;    // Usando EYE_CLOSE como genérico para neblina
        if (strcmp(iconId, "beacon") == 0) return LV_SYMBOL_WARNING;   // Usando WARNING como genérico para beacon
        if (strcmp(iconId, "nav") == 0) return LV_SYMBOL_GPS;
        if (strcmp(iconId, "relay") == 0) return LV_SYMBOL_SHUFFLE;    // Usando SHUFFLE como genérico para relay
        if (strcmp(iconId, "motor") == 0) return LV_SYMBOL_DRIVE;      // Usando DRIVE como genérico para motor
        if (strcmp(iconId, "lock") == 0) return LV_SYMBOL_OK;          // Usando OK como genérico para lock
        if (strcmp(iconId, "unlock") == 0) return LV_SYMBOL_CLOSE;     // Usando CLOSE como genérico para unlock
        if (strcmp(iconId, "gear") == 0) return LV_SYMBOL_SETTINGS;    // Usando SETTINGS como genérico para gear
        if (strcmp(iconId, "temp") == 0) return LV_SYMBOL_WARNING;     // Usando WARNING como genérico para temperatura
        if (strcmp(iconId, "pressure") == 0) return LV_SYMBOL_VOLUME_MID; // Usando VOLUME_MID como genérico para pressão
        if (strcmp(iconId, "fuel") == 0) return LV_SYMBOL_BATTERY_2;   // Usando BATTERY como genérico para combustível
        if (strcmp(iconId, "water") == 0) return LV_SYMBOL_TINT;       // Usando TINT (gota) para água
        if (strcmp(iconId, "oil") == 0) return LV_SYMBOL_TINT;         // Usando TINT como genérico para óleo
        if (strcmp(iconId, "air") == 0) return LV_SYMBOL_WIFI;         // Usando WIFI como genérico para ar (ondas)
        if (strcmp(iconId, "aux") == 0) return LV_SYMBOL_PLUS;         // Usando PLUS como genérico para auxiliar
        if (strcmp(iconId, "traction") == 0) return LV_SYMBOL_DRIVE;
        if (strcmp(iconId, "led_front") == 0) return LV_SYMBOL_EYE_OPEN;
        if (strcmp(iconId, "led_rear") == 0) return LV_SYMBOL_EYE_OPEN;
        if (strcmp(iconId, "led_hood") == 0) return LV_SYMBOL_EYE_OPEN;
        if (strcmp(iconId, "led_bar") == 0) return LV_SYMBOL_EYE_OPEN;
        
        // Retorna um ícone padrão se não encontrado
        return LV_SYMBOL_BULLET;
    }
};

#endif // ICONS_H