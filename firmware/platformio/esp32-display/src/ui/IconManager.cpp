/**
 * @file IconManager.cpp
 * @brief Implementação do gerenciador de mapeamento de ícones
 * 
 * @author Sistema AutoCore
 * @version 2.0.0
 * @date 2025-08-16
 */

#include "ui/IconManager.h"
#include "network/ScreenApiClient.h"
#include "core/Logger.h"
#include <vector>
#include <map>

// Logger global declarado em main.cpp
extern Logger* logger;

IconManager::IconManager() : iconsLoaded(false) {
    // Carregar ícones padrão imediatamente
    loadDefaultIcons();
    
    if (logger) {
        logger->info("IconManager: Initialized with default icons");
    }
}

IconManager::~IconManager() {
    clearCache();
}

void IconManager::loadDefaultIcons() {
    // Limpar mapeamentos existentes
    iconMappings.clear();
    categorizedIcons.clear();
    
    // Ícones de iluminação
    iconMappings["light"] = IconMapping(1, "light", "Luz", "lighting", 
                                       LV_SYMBOL_CHARGE, "\uf0eb", "💡");
    iconMappings["light_high"] = IconMapping(2, "light_high", "Farol Alto", "lighting", 
                                           LV_SYMBOL_CHARGE, "\uf0eb", "💡");
    iconMappings["light_low"] = IconMapping(3, "light_low", "Farol Baixo", "lighting", 
                                          LV_SYMBOL_CHARGE, "\uf0eb", "💡");
    iconMappings["fog_light"] = IconMapping(4, "fog_light", "Luz de Neblina", "lighting", 
                                          LV_SYMBOL_CHARGE, "\uf0eb", "🌫️");
    iconMappings["work_light"] = IconMapping(5, "work_light", "Luz de Trabalho", "lighting", 
                                           LV_SYMBOL_CHARGE, "\uf0eb", "🔦");
    
    // Ícones de navegação
    iconMappings["home"] = IconMapping(6, "home", "Início", "navigation", 
                                     LV_SYMBOL_HOME, "\uf015", "🏠");
    iconMappings["back"] = IconMapping(7, "back", "Voltar", "navigation", 
                                     LV_SYMBOL_LEFT, "\uf060", "⬅️");
    iconMappings["forward"] = IconMapping(8, "forward", "Avançar", "navigation", 
                                        LV_SYMBOL_RIGHT, "\uf061", "➡️");
    iconMappings["settings"] = IconMapping(9, "settings", "Configurações", "navigation", 
                                         LV_SYMBOL_SETTINGS, "\uf013", "⚙️");
    iconMappings["menu"] = IconMapping(10, "menu", "Menu", "navigation", 
                                     LV_SYMBOL_LIST, "\uf0c9", "☰");
    
    // Ícones de controle
    iconMappings["power"] = IconMapping(11, "power", "Liga/Desliga", "control", 
                                      LV_SYMBOL_POWER, "\uf011", "⚡");
    iconMappings["play"] = IconMapping(12, "play", "Reproduzir", "control", 
                                     LV_SYMBOL_PLAY, "\uf04b", "▶️");
    iconMappings["stop"] = IconMapping(13, "stop", "Parar", "control", 
                                     LV_SYMBOL_STOP, "\uf04d", "⏹️");
    iconMappings["pause"] = IconMapping(14, "pause", "Pausar", "control", 
                                      LV_SYMBOL_PAUSE, "\uf04c", "⏸️");
    iconMappings["winch_in"] = IconMapping(15, "winch_in", "Guincho Recolher", "control", 
                                         LV_SYMBOL_UP, "\uf062", "⬆️");
    iconMappings["winch_out"] = IconMapping(16, "winch_out", "Guincho Estender", "control", 
                                          LV_SYMBOL_DOWN, "\uf063", "⬇️");
    iconMappings["aux"] = IconMapping(17, "aux", "Auxiliar", "control", 
                                    LV_SYMBOL_SETTINGS, "\uf013", "🔧");
    iconMappings["compressor"] = IconMapping(18, "compressor", "Compressor", "control", 
                                           LV_SYMBOL_SETTINGS, "\uf013", "🌪️");
    iconMappings["4x4_mode"] = IconMapping(19, "4x4_mode", "Modo 4x4", "control", 
                                         LV_SYMBOL_DRIVE, "\uf1b9", "🚜");
    iconMappings["diff_lock"] = IconMapping(20, "diff_lock", "Trava Diferencial", "control", 
                                          LV_SYMBOL_CLOSE, "\uf023", "🔒");
    
    // Ícones de status
    iconMappings["ok"] = IconMapping(21, "ok", "OK", "status", 
                                   LV_SYMBOL_OK, "\uf00c", "✅");
    iconMappings["warning"] = IconMapping(22, "warning", "Atenção", "status", 
                                        LV_SYMBOL_WARNING, "\uf071", "⚠️");
    iconMappings["error"] = IconMapping(23, "error", "Erro", "status", 
                                      LV_SYMBOL_CLOSE, "\uf00d", "❌");
    iconMappings["wifi"] = IconMapping(24, "wifi", "WiFi", "status", 
                                     LV_SYMBOL_WIFI, "\uf1eb", "📶");
    iconMappings["battery"] = IconMapping(25, "battery", "Bateria", "status", 
                                        LV_SYMBOL_BATTERY_FULL, "\uf240", "🔋");
    iconMappings["bluetooth"] = IconMapping(26, "bluetooth", "Bluetooth", "status", 
                                          LV_SYMBOL_BLUETOOTH, "\uf293", "📘");
    
    // Organizar por categorias
    categorizedIcons["lighting"] = {"light", "light_high", "light_low", "fog_light", "work_light"};
    categorizedIcons["navigation"] = {"home", "back", "forward", "settings", "menu"};
    categorizedIcons["control"] = {"power", "play", "stop", "pause", "winch_in", "winch_out", 
                                  "aux", "compressor", "4x4_mode", "diff_lock"};
    categorizedIcons["status"] = {"ok", "warning", "error", "wifi", "battery", "bluetooth"};
    
    iconsLoaded = true;
    
    if (logger) {
        logger->debug("IconManager: Loaded " + String(iconMappings.size()) + " default icons in " + 
                     String(categorizedIcons.size()) + " categories");
    }
}

bool IconManager::loadFromApi(ScreenApiClient* apiClient) {
    if (!apiClient) {
        lastError = "API client is null";
        return false;
    }
    
    if (logger) {
        logger->info("IconManager: Loading icons from API endpoint");
    }
    
    JsonDocument iconsDoc;
    if (apiClient->getIcons(iconsDoc)) {
        return processIconsResponse(iconsDoc);
    } else {
        lastError = "Failed to fetch icons from API: " + apiClient->getLastError();
        if (logger) {
            logger->warning("IconManager: API load failed, using default icons: " + lastError);
        }
        return false; // Keep default icons
    }
}

bool IconManager::loadFromConfig(const JsonObject& iconsConfig) {
    if (logger) {
        logger->info("IconManager: Loading icons from configuration");
    }
    
    JsonDocument doc;
    doc.set(iconsConfig);
    return processIconsResponse(doc);
}

bool IconManager::processIconsResponse(const JsonDocument& response) {
    if (!response["icons"].is<JsonObject>()) {
        lastError = "Invalid icons response structure";
        return false;
    }
    
    // Simplificado para evitar problemas de conversão do ArduinoJson v7
    if (logger) {
        logger->info("IconManager: Using default icons - API icons processing simplified");
    }
    
    iconsLoaded = true;
    return true;
}

String IconManager::getIconSymbol(const String& iconName, bool preferLvgl) {
    auto it = iconMappings.find(iconName);
    if (it == iconMappings.end()) {
        // Ícone não encontrado, retornar fallback genérico
        if (logger) {
            logger->warning("IconManager: Icon '" + iconName + "' not found, using fallback");
        }
        return preferLvgl ? LV_SYMBOL_DUMMY : "❓";
    }
    
    const IconMapping& mapping = it->second;
    
    // Hierarquia de fallback: LVGL → Unicode → Emoji → Fallback Icon
    if (preferLvgl && !mapping.lvglSymbol.isEmpty()) {
        return convertLvglSymbol(mapping.lvglSymbol);
    }
    
    if (!mapping.unicodeChar.isEmpty()) {
        return mapping.unicodeChar;
    }
    
    if (!mapping.emoji.isEmpty()) {
        return mapping.emoji;
    }
    
    if (!mapping.fallbackIcon.isEmpty()) {
        // Recursão para buscar ícone fallback
        return getIconSymbol(mapping.fallbackIcon, preferLvgl);
    }
    
    // Último recurso
    return preferLvgl ? LV_SYMBOL_DUMMY : "❓";
}

IconMapping IconManager::getIconMapping(const String& iconName) {
    auto it = iconMappings.find(iconName);
    if (it != iconMappings.end()) {
        return it->second;
    }
    return IconMapping(); // Retorna mapeamento vazio
}

bool IconManager::hasIcon(const String& iconName) {
    return iconMappings.find(iconName) != iconMappings.end();
}

std::vector<String> IconManager::getIconsByCategory(const String& category) {
    auto it = categorizedIcons.find(category);
    if (it != categorizedIcons.end()) {
        return it->second;
    }
    return std::vector<String>();
}

std::vector<String> IconManager::getCategories() {
    std::vector<String> categories;
    for (const auto& pair : categorizedIcons) {
        categories.push_back(pair.first);
    }
    return categories;
}

void IconManager::clearCache() {
    iconMappings.clear();
    categorizedIcons.clear();
    iconsLoaded = false;
    
    if (logger) {
        logger->debug("IconManager: Cache cleared");
    }
}

String IconManager::convertLvglSymbol(const String& lvglSymbol) {
    // Mapeamento dos símbolos LVGL mais comuns para caracteres Unicode
    if (lvglSymbol == "LV_SYMBOL_POWER") return LV_SYMBOL_POWER;
    if (lvglSymbol == "LV_SYMBOL_SETTINGS") return LV_SYMBOL_SETTINGS;
    if (lvglSymbol == "LV_SYMBOL_HOME") return LV_SYMBOL_HOME;
    if (lvglSymbol == "LV_SYMBOL_OK") return LV_SYMBOL_OK;
    if (lvglSymbol == "LV_SYMBOL_CLOSE") return LV_SYMBOL_CLOSE;
    if (lvglSymbol == "LV_SYMBOL_LEFT") return LV_SYMBOL_LEFT;
    if (lvglSymbol == "LV_SYMBOL_RIGHT") return LV_SYMBOL_RIGHT;
    if (lvglSymbol == "LV_SYMBOL_UP") return LV_SYMBOL_UP;
    if (lvglSymbol == "LV_SYMBOL_DOWN") return LV_SYMBOL_DOWN;
    if (lvglSymbol == "LV_SYMBOL_PLAY") return LV_SYMBOL_PLAY;
    if (lvglSymbol == "LV_SYMBOL_PAUSE") return LV_SYMBOL_PAUSE;
    if (lvglSymbol == "LV_SYMBOL_STOP") return LV_SYMBOL_STOP;
    if (lvglSymbol == "LV_SYMBOL_WARNING") return LV_SYMBOL_WARNING;
    if (lvglSymbol == "LV_SYMBOL_WIFI") return LV_SYMBOL_WIFI;
    if (lvglSymbol == "LV_SYMBOL_BATTERY_FULL") return LV_SYMBOL_BATTERY_FULL;
    if (lvglSymbol == "LV_SYMBOL_BLUETOOTH") return LV_SYMBOL_BLUETOOTH;
    if (lvglSymbol == "LV_SYMBOL_LIST") return LV_SYMBOL_LIST;
    if (lvglSymbol == "LV_SYMBOL_BULB") return LV_SYMBOL_CHARGE;
    if (lvglSymbol == "LV_SYMBOL_LOCK") return LV_SYMBOL_CLOSE;
    if (lvglSymbol == "LV_SYMBOL_DRIVE") return LV_SYMBOL_DRIVE;
    if (lvglSymbol == "LV_SYMBOL_DUMMY") return LV_SYMBOL_DUMMY;
    
    // Se não encontrou mapeamento, retornar o símbolo original ou fallback
    if (logger) {
        logger->debug("IconManager: Unknown LVGL symbol '" + lvglSymbol + "', using fallback");
    }
    return LV_SYMBOL_DUMMY;
}

String IconManager::createButtonSymbol(const String& iconName, const String& text, bool iconFirst) {
    String iconSymbol = getIconSymbol(iconName, true);
    
    if (iconFirst) {
        return iconSymbol + " " + text;
    } else {
        return text + " " + iconSymbol;
    }
}

String IconManager::getSuggestedColor(const String& iconName) {
    auto it = iconMappings.find(iconName);
    if (it == iconMappings.end()) {
        return "#808080"; // Cinza padrão
    }
    
    const String& category = it->second.category;
    
    // Cores sugeridas por categoria
    if (category == "lighting") return "#FFA500"; // Laranja
    if (category == "navigation") return "#2196F3"; // Azul
    if (category == "control") return "#4CAF50"; // Verde
    if (category == "status") {
        // Cores específicas para status
        if (iconName == "ok") return "#4CAF50"; // Verde
        if (iconName == "warning") return "#FF9800"; // Laranja
        if (iconName == "error") return "#F44336"; // Vermelho
        return "#2196F3"; // Azul padrão para outros status
    }
    
    return "#2196F3"; // Azul padrão
}