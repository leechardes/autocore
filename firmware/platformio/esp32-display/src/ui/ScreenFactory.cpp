/**
 * @file ScreenFactory.cpp
 * @brief Implementation of screen factory
 */

#include "ui/ScreenFactory.h"
#include "ui/Theme.h"
#include "core/Logger.h"
#include "Layout.h"
#include "ui/Icons.h"
#include "ui/IconManager.h"
#include "ui/ScreenManager.h"
#include "commands/CommandSender.h"
#include "communication/ButtonStateManager.h"
#include "models/DeviceModels.h"
#include "ui/DataBinder.h"
#include <ArduinoJson.h>
#include <algorithm>
#include <vector>

extern Logger* logger;
extern ScreenManager* screenManager;
extern IconManager* iconManager;

// Array de cores para bordas de debug - facilita identificação visual de componentes
lv_color_t COMPONENT_DEBUG_COLORS[] = {
    lv_color_make(255, 0, 0),    // Vermelho - Botões de relay
    lv_color_make(0, 255, 0),    // Verde - Botões de navegação
    lv_color_make(0, 0, 255),    // Azul - Botões de ação
    lv_color_make(255, 255, 0),  // Amarelo - Switches
    lv_color_make(255, 0, 255),  // Magenta - Gauges
    lv_color_make(0, 255, 255),  // Ciano - Displays
    lv_color_make(255, 165, 0),  // Laranja - Mode items
    lv_color_make(128, 0, 128),  // Roxo - Display items
    lv_color_make(255, 192, 203), // Rosa - Outros
    lv_color_make(0, 128, 0)     // Verde Escuro - Fallback
};

const char* COMPONENT_COLOR_NAMES[] = {
    "VERMELHO", "VERDE", "AZUL", "AMARELO", "MAGENTA", 
    "CIANO", "LARANJA", "ROXO", "ROSA", "VERDE_ESCURO"
};

const int COMPONENT_COLORS_COUNT = sizeof(COMPONENT_DEBUG_COLORS) / sizeof(COMPONENT_DEBUG_COLORS[0]);

// Índices específicos para cada tipo de componente
enum ComponentColorIndex {
    COLOR_IDX_RELAY_BUTTON = 0,     // Vermelho
    COLOR_IDX_NAV_BUTTON = 1,       // Verde
    COLOR_IDX_ACTION_BUTTON = 2,    // Azul
    COLOR_IDX_SWITCH = 3,           // Amarelo
    COLOR_IDX_GAUGE = 4,            // Magenta
    COLOR_IDX_DISPLAY = 5,          // Ciano
    COLOR_IDX_MODE = 6,             // Laranja
    COLOR_IDX_DISPLAY_ITEM = 7,     // Roxo
    COLOR_IDX_OTHER = 8,            // Rosa
    COLOR_IDX_FALLBACK = 9          // Verde Escuro
};

/**
 * Aplica borda colorida para debug/identificação visual de componentes
 * @param obj Objeto LVGL para aplicar a borda
 * @param colorIndex Índice da cor no array de cores
 * @param componentType Tipo do componente para logs
 */
void applyComponentDebugBorder(lv_obj_t* obj, ComponentColorIndex colorIndex, const String& componentType) {
    if (!obj) return;
    
    // Garantir que não estoure o array
    int safeColorIndex = ((int)colorIndex) % COMPONENT_COLORS_COUNT;
    
    // Aplicar borda colorida para debug
    lv_obj_set_style_border_width(obj, 2, 0);  // 2px de largura
    lv_obj_set_style_border_color(obj, COMPONENT_DEBUG_COLORS[safeColorIndex], 0);
    lv_obj_set_style_border_opa(obj, LV_OPA_100, 0);  // Opacidade total
    
    // Log informativo com tamanho do componente
    if (logger) {
        // CORREÇÃO: Forçar atualização de layout antes de obter tamanhos
        lv_obj_update_layout(obj);
        lv_coord_t width = lv_obj_get_width(obj);
        lv_coord_t height = lv_obj_get_height(obj);
        logger->info("[COMPONENT DEBUG] " + componentType + ": Borda " + String(COMPONENT_COLOR_NAMES[safeColorIndex]) + 
                    " (" + String(width) + "x" + String(height) + ")");
    }
}

// Instância global do DataBinder para widgets dinâmicos
DataBinder* dataBinder = nullptr;

std::unique_ptr<ScreenBase> ScreenFactory::createScreen(JsonObject& config) {
    // Convert id to string if it's a number
    String screenId;
    if (config["id"].is<int>()) {
        screenId = String(config["id"].as<int>());
    } else {
        screenId = config["id"].as<String>();
    }
    
    String title = config["title"].as<String>();
    String type = config["type"].as<String>();
    
    // Create custom screen class that stores items
    class CustomScreen : public ScreenBase {
    private:
        JsonDocument itemsDoc;
        JsonArray storedItems;
        
    public:
        CustomScreen() : ScreenBase() {}
        
        void setItems(JsonArray items) {
            // Copiar items para armazenamento interno
            itemsDoc.clear();
            for (JsonVariant item : items) {
                itemsDoc.add(item);
            }
            storedItems = itemsDoc.as<JsonArray>();
        }
        
        void rebuildContent() override {
            // Limpar conteúdo atual
            content->clearChildren();
            
            // Sort items by order_index before displaying
            struct ItemWithOrder {
                JsonObject item;
                int order;
            };
            
            std::vector<ItemWithOrder> sortedItems;
            
            logger->debug("Processing " + String(storedItems.size()) + " items for screen");
            
            // Sort by position (API usa 'position' não 'order_index')
            for (JsonObject item : storedItems) {
                ItemWithOrder iwo;
                iwo.item = item;
                iwo.order = item["position"] | 999;
                sortedItems.push_back(iwo);
            }
            
            // Sort by position
            std::sort(sortedItems.begin(), sortedItems.end(), 
                [](const ItemWithOrder& a, const ItemWithOrder& b) {
                    return a.order < b.order;
                });
            
            // Recriar itens para a página atual usando paginação inteligente baseada em slots
            int currentPageSlots = 0;
            int maxSlotsPerPage = Layout::getMaxSlotsPerPage();
            int startIdx = 0;
            
            // Calcular startIdx baseado na página atual e slots ocupados
            if (navState.currentPage > 0) {
                int slotsCount = 0;
                int pageCount = 0;
                
                for (int j = 0; j < (int)sortedItems.size(); j++) {
                    JsonObject item = sortedItems[j].item;
                    // CORREÇÃO: Verificar múltiplos campos de size em ordem de prioridade
                    String sizeStr = "";
                    
                    // 1. Tentar campo "size" (backend já corrigido retorna o correto)
                    if (item["size"].is<JsonVariant>()) {
                        sizeStr = item["size"].as<String>();
                    }
                    
                    // 2. Se não encontrou, tentar "size_display_small" (campo específico)
                    if (sizeStr.isEmpty() && item["size_display_small"].is<JsonVariant>()) {
                        sizeStr = item["size_display_small"].as<String>();
                    }
                    
                    // 3. Default se ainda estiver vazio
                    if (sizeStr.isEmpty()) {
                        sizeStr = "normal";
                    }
                    ComponentSize size = Layout::parseComponentSize(sizeStr);
                    int slotsNeeded = Layout::getSlotsForSize(size);
                    
                    if (!Layout::canFitInPage(slotsCount, slotsNeeded)) {
                        pageCount++;
                        slotsCount = 0;
                        
                        if (pageCount == navState.currentPage) {
                            startIdx = j;
                            break;
                        }
                    }
                    
                    slotsCount += slotsNeeded;
                }
            }
            
            logger->debug("Page " + String(navState.currentPage) + " starts at item " + String(startIdx));
            
            // Adicionar itens à página atual até atingir limite de slots
            for (int i = startIdx; i < (int)sortedItems.size(); i++) {
                JsonObject item = sortedItems[i].item;
                
                // ADAPTADOR: Converter formato antigo para novo formato da API
                // Detectar formato antigo (type="relay" com device/channel)
                if (item["type"].is<JsonVariant>()) {
                    String oldType = item["type"].as<String>();
                    
                    if (oldType == "relay") {
                        // Converter formato antigo para novo
                        item["item_type"] = "button";
                        item["action_type"] = "relay_control";
                        
                        // Converter device para relay_board_id
                        if (item["device"].is<JsonVariant>()) {
                            String device = item["device"].as<String>();
                            // Extrair número do device (relay_board_1 → 1)
                            if (device.startsWith("relay_board_")) {
                                int boardId = device.substring(12).toInt();
                                item["relay_board_id"] = boardId;
                            }
                        }
                        
                        // Converter channel para relay_channel_id
                        if (item["channel"].is<JsonVariant>()) {
                            item["relay_channel_id"] = item["channel"].as<int>();
                        }
                        
                        // Converter mode para action_payload
                        if (item["mode"].is<JsonVariant>()) {
                            String mode = item["mode"].as<String>();
                            JsonObject payload = item.createNestedObject("action_payload");
                            payload["momentary"] = (mode == "momentary");
                        }
                        
                        // Converter id para name se necessário
                        if (item["id"].is<JsonVariant>() && !item["name"].is<JsonVariant>()) {
                            item["name"] = item["id"].as<String>();
                        }
                        
                        logger->info("[ADAPTER] Converted old relay format to new API format for: " + item["label"].as<String>());
                    } else if (oldType == "navigation") {
                        // Converter navegação
                        item["item_type"] = "button";
                        item["action_type"] = "navigation";
                        
                        // Converter id para name
                        if (item["id"].is<JsonVariant>() && !item["name"].is<JsonVariant>()) {
                            item["name"] = item["id"].as<String>();
                        }
                        
                        logger->info("[ADAPTER] Converted old navigation format to new API format for: " + item["label"].as<String>());
                    } else if (oldType == "action" || oldType == "preset") {
                        // Converter action/preset
                        item["item_type"] = "button";
                        item["action_type"] = (oldType == "preset") ? "macro" : "command";
                        
                        // Converter id para name
                        if (item["id"].is<JsonVariant>() && !item["name"].is<JsonVariant>()) {
                            item["name"] = item["id"].as<String>();
                        }
                        
                        logger->info("[ADAPTER] Converted old " + oldType + " format to new API format for: " + item["label"].as<String>());
                    }
                }
                
                // CORREÇÃO: Verificar múltiplos campos de size em ordem de prioridade  
                String sizeStr = "";
                
                // 1. Tentar campo "size" (backend já corrigido retorna o correto)
                if (item["size"].is<JsonVariant>()) {
                    sizeStr = item["size"].as<String>();
                }
                
                // 2. Se não encontrou, tentar "size_display_small" (campo específico)
                if (sizeStr.isEmpty() && item["size_display_small"].is<JsonVariant>()) {
                    sizeStr = item["size_display_small"].as<String>();
                }
                
                // 3. Default se ainda estiver vazio
                if (sizeStr.isEmpty()) {
                    sizeStr = "normal";
                }
                ComponentSize size = Layout::parseComponentSize(sizeStr);
                int slotsNeeded = Layout::getSlotsForSize(size);
                
                // Verificar se cabe na página atual
                if (!Layout::canFitInPage(currentPageSlots, slotsNeeded)) {
                    logger->debug("Item " + String(i) + " doesn't fit in page (needs " + 
                                String(slotsNeeded) + " slots, have " + String(currentPageSlots) + "/" + 
                                String(maxSlotsPerPage) + ")");
                    break; // Vai para próxima página
                }
                
                // A API retorna 'item_type' não 'type'
                String itemType = item["item_type"].as<String>();
                String actionType = item["action_type"].as<String>();
                
                // CORREÇÃO: Converter para lowercase para compatibilidade
                // Converter para lowercase
                if (!itemType.isEmpty()) {
                    itemType.toLowerCase();
                }
                if (!actionType.isEmpty()) {
                    actionType.toLowerCase();
                }
                
                // LOG COMPLETO COM INFORMAÇÕES DE DEBUG
                String itemName = item["name"].as<String>();
                String itemLabel = item["label"].as<String>();
                String itemIcon = item["icon"].as<String>();
                
                logger->info("[COMPONENT CREATE] Type:" + itemType + "/" + actionType + " Name:'" + itemName + "' Label:'" + itemLabel + "' Icon:'" + itemIcon + "' Size:'" + sizeStr + "'");
                
                // LOG DE CONFIGURAÇÃO DE TAMANHO
                Size componentSize = Layout::calculateComponentSize(size, {86, 72});
                logger->info("[SIZE CONFIG] '" + itemName + "' (" + itemLabel + "): size_display_small='" + sizeStr + "' → " +
                           String(componentSize.width) + "x" + String(componentSize.height) + " pixels");
                
                logger->debug("  Size: " + sizeStr + " (slots needed: " + String(slotsNeeded) + ")");
                logger->debug("  Position: " + String(item["position"] | 0));
                logger->debug("  Data Source: " + item["data_source"].as<String>());
                logger->debug("  Data Path: " + item["data_path"].as<String>());
                
                NavButton* navBtn = nullptr;
                
                // Mapear tipos da API para tipos internos (NOVOS ENUMS LOWERCASE)
                if (itemType == "button" && actionType == "relay_control") {
                    logger->info("[CREATE] RelayItem - name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "', size:'" + sizeStr + "'");
                    navBtn = ScreenFactory::createRelayItem(content->getObject(), item);
                    if (navBtn && navBtn->getObject()) {
                        // DEBUG REMOVIDO: Bordas coloridas desabilitadas
                        // applyNavButtonDebugBorder(navBtn->getObject(), NAVBUTTON_COLOR_IDX_BUTTON, "RelayItem", itemName, itemLabel, itemIcon, sizeStr);
                    }
                } else if (itemType == "button" && actionType == "navigation") {
                    logger->info("[CREATE] NavigationItem - name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "', size:'" + sizeStr + "'");
                    navBtn = ScreenFactory::createNavigationItem(content->getObject(), item);
                    if (navBtn && navBtn->getObject()) {
                        // DEBUG REMOVIDO: Bordas coloridas desabilitadas
                        // applyNavButtonDebugBorder(navBtn->getObject(), NAVBUTTON_COLOR_IDX_BUTTON, "NavigationItem", itemName, itemLabel, itemIcon, sizeStr);
                    }
                } else if (itemType == "button" && (actionType == "command" || actionType == "macro")) {
                    logger->info("[CREATE] ActionItem - name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "', size:'" + sizeStr + "'");
                    navBtn = ScreenFactory::createActionItem(content->getObject(), item);
                    if (navBtn && navBtn->getObject()) {
                        // DEBUG REMOVIDO: Bordas coloridas desabilitadas
                        // applyNavButtonDebugBorder(navBtn->getObject(), NAVBUTTON_COLOR_IDX_BUTTON, "ActionItem", itemName, itemLabel, itemIcon, sizeStr);
                    }
                } else if (itemType == "switch" && actionType == "relay_control") {
                    logger->info("[CREATE] SwitchItem - name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "', size:'" + sizeStr + "'");
                    // CORREÇÃO: Switches são tratados como objetos diretos, não NavButtons
                    lv_obj_t* switchObj = ScreenFactory::createSwitchDirectly(content->getObject(), item);
                    if (switchObj) {
                        // Armazenar ComponentSize no user_data
                        ComponentSize compSize = Layout::parseComponentSize(sizeStr);
                        lv_obj_set_user_data(switchObj, (void*)(intptr_t)compSize);
                        logger->debug("[ScreenFactory] Switch user_data set to ComponentSize: " + String((int)compSize));
                        
                        // Removido: borda aplicada somente pelo GridContainer
                        // applyComponentDebugBorder(switchObj, COLOR_IDX_SWITCH, "Item switch relay [size: " + sizeStr + "]");
                        content->addChild(switchObj);
                        currentPageSlots += slotsNeeded;
                    }
                    continue; // Pular o resto do loop, switch já foi adicionado
                } else if (itemType == "gauge") {
                    logger->info("[CREATE] GaugeItem - name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "', size:'" + sizeStr + "'");
                    // SOLUÇÃO: Criar gauge diretamente sem NavButton wrapper
                    lv_obj_t* gaugeObj = ScreenFactory::createGaugeDirectly(content->getObject(), item);
                    if (gaugeObj) {
                        // Armazenar ComponentSize no user_data
                        ComponentSize compSize = Layout::parseComponentSize(sizeStr);
                        lv_obj_set_user_data(gaugeObj, (void*)(intptr_t)compSize);
                        logger->debug("[ScreenFactory] Gauge user_data set to ComponentSize: " + String((int)compSize));
                        
                        // Removido: borda aplicada somente pelo GridContainer
                        // applyComponentDebugBorder(gaugeObj, COLOR_IDX_GAUGE, "Item gauge [size: " + sizeStr + "]");
                        content->addChild(gaugeObj);
                        currentPageSlots += slotsNeeded;
                    }
                    continue; // Pular o resto do loop, gauge já foi adicionado
                } else if (itemType == "display") {
                    // CORREÇÃO: Items com type="display" devem criar GAUGES, não display simples
                    String dataSource = item["data_source"].as<String>();
                    String dataPath = item["data_path"].as<String>();
                    
                    if (!dataSource.isEmpty() && !dataPath.isEmpty()) {
                        logger->info("[CREATE] GaugeItem (display) - name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "', size:'" + sizeStr + "'");
                        // SOLUÇÃO: Criar gauge diretamente sem NavButton wrapper
                        lv_obj_t* gaugeObj = ScreenFactory::createGaugeDirectly(content->getObject(), item);
                        if (gaugeObj) {
                            // Armazenar ComponentSize no user_data
                            ComponentSize compSize = Layout::parseComponentSize(sizeStr);
                            lv_obj_set_user_data(gaugeObj, (void*)(intptr_t)compSize);
                            logger->debug("[ScreenFactory] Display(gauge) user_data set to ComponentSize: " + String((int)compSize));
                            
                            // Removido: borda aplicada somente pelo GridContainer
                            // applyComponentDebugBorder(gaugeObj, COLOR_IDX_DISPLAY, "Item display com dados [size: " + sizeStr + "]");
                            content->addChild(gaugeObj);
                            currentPageSlots += slotsNeeded;
                        }
                        continue; // Pular o resto do loop, gauge já foi adicionado
                    } else {
                        logger->info("[CREATE] DisplayItem - name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "', size:'" + sizeStr + "'");
                        navBtn = ScreenFactory::createDisplayItem(content->getObject(), item);
                        if (navBtn && navBtn->getObject()) {
                            // DEBUG REMOVIDO: Bordas coloridas desabilitadas
                            // applyNavButtonDebugBorder(navBtn->getObject(), NAVBUTTON_COLOR_IDX_BUTTON, "DisplayItem", itemName, itemLabel, itemIcon, sizeStr);
                        }
                    }
                } else {
                    logger->warning("[CREATE] UNKNOWN item combination: " + itemType + "/" + actionType + " for name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "'");
                    logger->warning("     Valid combinations (BACKEND FORMAT - case insensitive):");
                    logger->warning("     - button/relay_control, button/navigation, button/command, button/macro");
                    logger->warning("     - switch/relay_control, gauge (null action), display (data visualization)");
                    
                    // Fallback: Tentar criar pelo menos um botão simples
                    logger->info("[CREATE] FallbackItem - name:'" + itemName + "', label:'" + itemLabel + "', icon:'" + itemIcon + "', size:'" + sizeStr + "'");
                    navBtn = ScreenFactory::createActionItem(content->getObject(), item);
                    if (navBtn && navBtn->getObject()) {
                        // DEBUG REMOVIDO: Bordas coloridas desabilitadas
                        // applyNavButtonDebugBorder(navBtn->getObject(), NAVBUTTON_COLOR_IDX_BUTTON, "FallbackItem", itemName, itemLabel, itemIcon, sizeStr);
                    }
                }
                
                if (navBtn) {
                    lv_obj_t* btnObj = navBtn->getObject();
                    
                    // CORREÇÃO: Aplicar tamanho correto baseado em size_display_small
                    ComponentSize compSize = Layout::parseComponentSize(sizeStr);
                    Size cellSize = {86, 72}; // Tamanho base
                    Size componentSize = Layout::calculateComponentSize(compSize, cellSize);
                    
                    // Aplicar tamanho ao botão
                    lv_obj_set_size(btnObj, componentSize.width, componentSize.height);
                    
                    // IMPORTANTE: Armazenar o ComponentSize no user_data para o GridContainer usar
                    lv_obj_set_user_data(btnObj, (void*)(intptr_t)compSize);
                    logger->debug("[ScreenFactory] Component user_data set to ComponentSize: " + String((int)compSize));
                    
                    // Debug: verificar o objeto antes de adicionar
                    logger->debug("Adding NavButton object to content container");
                    logger->debug("  Button object: " + String((long)btnObj, HEX));
                    logger->debug("  Button size: " + String(componentSize.width) + "x" + String(componentSize.height));
                    logger->debug("  Size string: " + sizeStr);
                    logger->debug("  Content object: " + String((long)content->getObject(), HEX));
                    
                    // Adicionar ao container
                    content->addChild(btnObj);
                    
                    // Debug: verificar após adicionar
                    logger->debug("  Added to container. Total children: " + String(content->getChildCount()));
                    
                    // Contar slots utilizados
                    currentPageSlots += slotsNeeded;
                    
                    // Registrar botão para receber status se for tipo que precisa
                    if ((itemType == "button" || itemType == "switch") && actionType == "relay_control") {
                        extern ButtonStateManager* buttonStateManager;
                        if (buttonStateManager) {
                            buttonStateManager->registerButton(navBtn);
                        }
                    }
                } else {
                    logger->error("Failed to create NavButton for item: " + itemType + "/" + actionType);
                }
                
                logger->debug("Page slots used: " + String(currentPageSlots) + "/" + String(maxSlotsPerPage));
            }
        }
    };
    
    // Create custom screen
    auto screen = std::unique_ptr<CustomScreen>(new CustomScreen());
    screen->setScreenId(screenId);
    
    // Regular screens are never home (only the special HomeScreen is)
    screen->setIsHome(false);
    
    // Set title in header
    screen->getHeader()->setTitle(title);
    
    // Add debug logs to verify API structure
    if (logger) {
        logger->debug("ScreenFactory: Processing screen config");
        if (config["items"].is<JsonArray>()) {
            logger->debug("ScreenFactory: Found items array with " + String(config["items"].as<JsonArray>().size()) + " items");
        }
        if (config["screen_items"].is<JsonArray>()) {
            logger->warning("ScreenFactory: Found deprecated screen_items field - should use 'items' instead");
        }
    }
    
    // Process items from API structure (items) with backwards compatibility
    JsonArray items;
    if (config["items"].is<JsonArray>()) {
        // New API format uses 'items'
        items = config["items"].as<JsonArray>();
    } else if (config["screen_items"].is<JsonArray>()) {
        // Legacy format uses 'screen_items' 
        items = config["screen_items"].as<JsonArray>();
        if (logger) {
            logger->warning("ScreenFactory: Using deprecated 'screen_items' field");
        }
    }
    
    if (!items.isNull()) {
        screen->setItems(items); // Armazenar todos os items
        
        // Update navigation state using slot-based pagination
        NavigationState& navState = const_cast<NavigationState&>(screen->navState);
        navState.totalItems = items.size();
        
        // Calcular totalPages baseado em slots ocupados
        int totalSlots = 0;
        for (JsonObject item : items) {
            // CORREÇÃO: Usar campo "size" primeiro, depois "size_display_small"
            String sizeStr = item["size"].as<String>();
            if (sizeStr.isEmpty()) {
                sizeStr = item["size_display_small"] | "normal";
            }
            if (sizeStr.isEmpty()) {
                sizeStr = "normal"; // default
            }
            ComponentSize size = Layout::parseComponentSize(sizeStr);
            totalSlots += Layout::getSlotsForSize(size);
        }
        
        navState.totalPages = Layout::calculateTotalPagesSlots(totalSlots);
        
        logger->debug("Screen has " + String(items.size()) + " items using " + 
                     String(totalSlots) + " slots across " + String(navState.totalPages) + " pages");
        
        // Build initial page
        screen->rebuildContent();
        screen->updateNavigationButtons();
    }
    
    return screen;
}

NavButton* ScreenFactory::createNavigationItem(lv_obj_t* parent, JsonObject& config) {
    String label = config["label"].as<String>();
    String icon = config["icon"].as<String>();
    String target = config["action_target"].as<String>();
    String id = config["name"].as<String>(); // API usa 'name' não 'id'
    
    // IMPORTANTE: Ler o tamanho configurado
    String sizeStr = "";
    if (config["size"].is<JsonVariant>()) {
        sizeStr = config["size"].as<String>();
    }
    if (sizeStr.isEmpty() && config["size_display_small"].is<JsonVariant>()) {
        sizeStr = config["size_display_small"].as<String>();
    }
    if (sizeStr.isEmpty()) {
        sizeStr = "normal";
    }
    
    // For navigation items in new structure, target is the screen ID
    // which might be numeric now
    auto btn = new NavButton(parent, label, icon, id);
    btn->setTarget(target);
    
    // IMPORTANTE: Armazenar ComponentSize no user_data do objeto LVGL interno
    ComponentSize compSize = Layout::parseComponentSize(sizeStr);
    lv_obj_t* btnObj = btn->getObject();
    if (btnObj) {
        lv_obj_set_user_data(btnObj, (void*)(intptr_t)compSize);
        
        if (logger) {
            logger->debug("[ScreenFactory] Navigation button '" + label + "' size set to: " + sizeStr + 
                        " (ComponentSize: " + String((int)compSize) + ")");
        }
    }
    
    // Adicionar callback de navegação
    if (!target.isEmpty()) {
        btn->setClickCallback([target](NavButton* b) {
            if (screenManager) {
                logger->info("Navigation button clicked - target: " + target);
                screenManager->navigateTo(target);
            }
        });
    }
    
    return btn;
}

NavButton* ScreenFactory::createRelayItem(lv_obj_t* parent, JsonObject& config) {
    String label = config["label"].as<String>();
    String icon = config["icon"].as<String>();
    String id = config["name"].as<String>(); // API usa 'name' não 'id'
    
    // IMPORTANTE: Ler o tamanho configurado
    String sizeStr = "";
    if (config["size"].is<JsonVariant>()) {
        sizeStr = config["size"].as<String>();
    }
    if (sizeStr.isEmpty() && config["size_display_small"].is<JsonVariant>()) {
        sizeStr = config["size_display_small"].as<String>();
    }
    if (sizeStr.isEmpty()) {
        sizeStr = "normal";
    }
    
    // Extrair informações do relay
    uint8_t relay_board_id = config["relay_board_id"] | 0;
    uint8_t relay_channel_id = config["relay_channel_id"] | 0;
    JsonObject action_payload = config["action_payload"];
    
    // Determinar function_type
    String function_type = "toggle"; // default
    if (action_payload["momentary"].is<bool>() && action_payload["momentary"]) {
        function_type = "momentary";
    }
    
    auto btn = new NavButton(parent, label, icon, id);
    btn->setButtonType(NavButton::TYPE_RELAY);
    
    // IMPORTANTE: Armazenar ComponentSize no user_data do objeto LVGL interno
    ComponentSize compSize = Layout::parseComponentSize(sizeStr);
    lv_obj_t* btnObj = btn->getObject();
    if (btnObj) {
        lv_obj_set_user_data(btnObj, (void*)(intptr_t)compSize);
        
        if (logger) {
            logger->debug("[ScreenFactory] Relay button '" + label + "' size set to: " + sizeStr + 
                        " (ComponentSize: " + String((int)compSize) + ")");
        }
    }
    
    // Manter compatibilidade com formato antigo
    String device = "relay_board_" + String(relay_board_id);
    btn->setRelayConfig(device, relay_channel_id, function_type);
    
    // Verificar se tem relay_board_id válido
    if (relay_board_id == 0 || relay_channel_id == 0) {
        logger->warning("Button without valid relay config: " + String(config["name"].as<const char*>()));
        // Visual de desabilitado - usar estado OFF 
        btn->setState(false);
        return btn;
    }
    
    // Verificar se relay board existe no registry
    if (!DeviceRegistry::getInstance()->hasRelayBoard(relay_board_id)) {
        logger->warning("Relay board not found in registry: " + String(relay_board_id) + 
                       " for button: " + config["name"].as<String>() + " (" + label + ")");
        logger->info("Available relay boards in registry:");
        // TODO: Adicionar método para listar boards disponíveis
        // Visual de desabilitado - usar estado OFF 
        btn->setState(false);
        return btn;
    }
    
    // Configurar callback para envio de comando com novo formato
    btn->setClickCallback([relay_board_id, relay_channel_id, function_type, label](NavButton* b) {
        extern CommandSender* commandSender;
        extern ButtonStateManager* buttonStateManager;
        
        logger->info("=== BUTTON CLICK DEBUG ===");
        logger->info("Button: " + label);
        logger->info("Type: " + function_type);
        logger->info("Relay Board ID: " + String(relay_board_id));
        logger->info("Channel ID: " + String(relay_channel_id));
        
        if (!commandSender) {
            logger->error("CommandSender is NULL!");
            return;
        }
        
        // Verificar DeviceRegistry
        logger->info("DeviceRegistry has " + String(DeviceRegistry::getInstance()->getRelayBoardCount()) + " relay boards");
        
        // Resolver relay_board_id para UUID
        String targetUuid = DeviceRegistry::getInstance()->resolveRelayBoardToUuid(relay_board_id);
        
        if (targetUuid.isEmpty()) {
            logger->error("Failed to resolve UUID for relay_board_id: " + String(relay_board_id));
            logger->error("Check if DeviceRegistry was populated from config");
            return;
        }
        
        logger->info("Resolved UUID: " + targetUuid);
        
        // Determinar estado baseado no tipo
        bool newState = true;
        if (function_type == "toggle") {
            // Para toggle, usar estado atual do botão e inverter
            bool currentState = b->getState();
            newState = !currentState;
            logger->info("Toggle: current=" + String(currentState) + " new=" + String(newState));
        } else if (function_type == "momentary") {
            // Para momentary, usar o estado pressed do botão
            newState = b->getIsPressed();
            logger->info(String("Momentary button ") + (newState ? "PRESSED" : "RELEASED") + 
                       " - channel " + String(relay_channel_id));
        }
        
        String stateStr = newState ? "on" : "off";
        logger->info("Sending command: UUID=" + targetUuid + " ch=" + String(relay_channel_id) + 
                    " state=" + stateStr + " type=" + function_type);
        
        // Enviar comando com UUID correto
        bool sent = commandSender->sendRelayCommand(targetUuid, relay_channel_id, stateStr, function_type);
        
        if (sent) {
            logger->info("Command sent successfully!");
        } else {
            logger->error("Failed to send command!");
        }
        logger->info("========================");
        
        // Para toggle, atualizar estado visual imediatamente
        if (function_type == "toggle") {
            b->setState(newState);
        }
        
        // Registrar botão para receber atualizações MQTT se ainda não estiver
        if (buttonStateManager) {
            buttonStateManager->registerButton(b);
        }
    });
    
    return btn;
}

NavButton* ScreenFactory::createActionItem(lv_obj_t* parent, JsonObject& config) {
    String label = config["label"].as<String>();
    String icon = config["icon"].as<String>();
    String id = config["name"].as<String>(); // API usa 'name' não 'id'
    String actionType = config["action_type"].as<String>();
    String preset = config["action_payload"].as<String>(); // API usa 'action_payload'
    
    // IMPORTANTE: Ler o tamanho configurado
    String sizeStr = "";
    if (config["size"].is<JsonVariant>()) {
        sizeStr = config["size"].as<String>();
    }
    if (sizeStr.isEmpty() && config["size_display_small"].is<JsonVariant>()) {
        sizeStr = config["size_display_small"].as<String>();
    }
    if (sizeStr.isEmpty()) {
        sizeStr = "normal";
    }
    
    auto btn = new NavButton(parent, label, icon, id);
    btn->setButtonType(NavButton::TYPE_ACTION);
    btn->setActionConfig(actionType, preset);
    
    // IMPORTANTE: Armazenar ComponentSize no user_data do objeto LVGL interno
    ComponentSize compSize = Layout::parseComponentSize(sizeStr);
    lv_obj_t* btnObj = btn->getObject();
    if (btnObj) {
        lv_obj_set_user_data(btnObj, (void*)(intptr_t)compSize);
        
        if (logger) {
            logger->debug("[ScreenFactory] Action button '" + label + "' size set to: " + sizeStr + 
                        " (ComponentSize: " + String((int)compSize) + ")");
        }
    }
    
    // Configurar callback para envio de comando MQTT
    btn->setClickCallback([](NavButton* b) {
        extern CommandSender* commandSender;
        extern ButtonStateManager* buttonStateManager;
        
        if (commandSender) {
            commandSender->sendCommand(b);
            
            // Registrar para atualizações
            if (buttonStateManager) {
                buttonStateManager->registerButton(b);
            }
        }
    });
    
    return btn;
}

NavButton* ScreenFactory::createModeItem(lv_obj_t* parent, JsonObject& config) {
    String label = config["label"].as<String>();
    String icon = config["icon"].as<String>();
    String id = config["name"].as<String>(); // API usa 'name' não 'id'
    String mode = config["action_payload"].as<String>(); // API usa 'action_payload'
    
    // IMPORTANTE: Ler o tamanho configurado
    String sizeStr = "";
    if (config["size"].is<JsonVariant>()) {
        sizeStr = config["size"].as<String>();
    }
    if (sizeStr.isEmpty() && config["size_display_small"].is<JsonVariant>()) {
        sizeStr = config["size_display_small"].as<String>();
    }
    if (sizeStr.isEmpty()) {
        sizeStr = "normal";
    }
    
    auto btn = new NavButton(parent, label, icon, id);
    btn->setButtonType(NavButton::TYPE_MODE);
    btn->setModeConfig(mode);
    
    // IMPORTANTE: Armazenar ComponentSize no user_data do objeto LVGL interno
    ComponentSize compSize = Layout::parseComponentSize(sizeStr);
    lv_obj_t* btnObj = btn->getObject();
    if (btnObj) {
        lv_obj_set_user_data(btnObj, (void*)(intptr_t)compSize);
        
        if (logger) {
            logger->debug("[ScreenFactory] Mode button '" + label + "' size set to: " + sizeStr + 
                        " (ComponentSize: " + String((int)compSize) + ")");
        }
    }
    
    // Configurar callback para envio de comando MQTT
    btn->setClickCallback([](NavButton* b) {
        extern CommandSender* commandSender;
        extern ButtonStateManager* buttonStateManager;
        
        if (commandSender) {
            commandSender->sendCommand(b);
            
            // Registrar para atualizações
            if (buttonStateManager) {
                buttonStateManager->registerButton(b);
            }
        }
    });
    
    return btn;
}

NavButton* ScreenFactory::createDisplayItem(lv_obj_t* parent, JsonObject& config) {
    String label = config["label"].as<String>();
    String icon = config["icon"].as<String>();
    String id = config["name"].as<String>();
    String dataSource = config["data_source"].as<String>();
    String dataPath = config["data_path"].as<String>();
    String dataUnit = config["data_unit"].as<String>();
    String itemSize = config["size_display_small"].as<String>();
    
    if (logger) {
        logger->debug("Creating enhanced display: " + label + " (" + dataSource + ":" + dataPath + ")");
    }
    
    // Criar container no estilo card
    lv_obj_t* container = lv_obj_create(parent);
    theme_apply_card(container);
    
    // Determinar padding baseado no tamanho
    lv_coord_t padding = (itemSize == "large") ? 16 : (itemSize == "small") ? 8 : 12;
    lv_obj_set_style_pad_all(container, padding, 0);
    
    // Label do título (pequeno, topo-esquerda)
    lv_obj_t* titleLabel = lv_label_create(container);
    lv_label_set_text(titleLabel, label.c_str());
    lv_obj_align(titleLabel, LV_ALIGN_TOP_LEFT, 0, 0);
    theme_apply_label_small(titleLabel);
    
    // Fonte ainda menor para títulos em displays pequenos
    if (itemSize == "small") {
        lv_obj_set_style_text_font(titleLabel, &lv_font_montserrat_10, 0);
    }
    
    // Ícone (canto superior direito)
    if (iconManager && !icon.isEmpty() && iconManager->hasIcon(icon)) {
        lv_obj_t* iconLabel = lv_label_create(container);
        String iconSymbol = iconManager->getIconSymbol(icon);
        lv_label_set_text(iconLabel, iconSymbol.c_str());
        lv_obj_align(iconLabel, LV_ALIGN_TOP_RIGHT, 0, 0);
        theme_apply_icon(iconLabel);
        
        // Ícone menor para displays pequenos
        if (itemSize == "small") {
            lv_obj_set_style_text_font(iconLabel, &lv_font_montserrat_12, 0);
        }
    }
    
    // Label do valor (grande, centro)
    lv_obj_t* valueLabel = lv_label_create(container);
    lv_label_set_text(valueLabel, "---"); // Placeholder até receber dados
    lv_obj_align(valueLabel, LV_ALIGN_CENTER, 0, 5);
    theme_apply_label(valueLabel);
    
    // Fonte do valor baseada no tamanho do display
    if (itemSize == "large") {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_20, 0); // Maior fonte disponível
    } else if (itemSize == "small") {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_14, 0);
    } else {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_16, 0);
    }
    
    // Criar NavButton wrapper
    auto navBtn = new NavButton(container, label, icon, id);
    navBtn->setButtonType(NavButton::TYPE_DISPLAY);
    navBtn->setDisplayConfig(dataSource, dataPath, dataUnit);
    navBtn->setValueLabel(valueLabel);
    
    // IMPORTANTE: Armazenar ComponentSize no user_data do container LVGL
    ComponentSize compSize = Layout::parseComponentSize(itemSize);
    lv_obj_set_user_data(container, (void*)(intptr_t)compSize);
    
    if (logger) {
        logger->debug("[ScreenFactory] Display item '" + label + "' size set to: " + itemSize + 
                    " (ComponentSize: " + String((int)compSize) + ")");
    }
    
    // Registrar no DataBinder para atualizações automáticas se tem dados válidos
    if (!dataBinder) {
        dataBinder = new DataBinder();
        if (logger) {
            logger->info("DataBinder: Initialized global instance");
        }
    }
    
    if (!dataSource.isEmpty() && !dataPath.isEmpty()) {
        dataBinder->bindWidget(container, navBtn, config);
    }
    
    return navBtn;
}

// Legacy implementation - rename original to Legacy
lv_obj_t* ScreenFactory::createScreenLegacy(JsonObject& config) {
    String screenId = config["id"].as<String>();
    String title = config["title"].as<String>();
    
    // Create screen
    lv_obj_t* screen = lv_obj_create(NULL);
    
    // Apply theme to screen
    theme_apply_screen(screen);
    
    // Override background color if specified
    if (config["background"].is<JsonVariant>()) {
        lv_obj_set_style_bg_color(screen, parseColor(config["background"]), 0);
    }
    
    // Create title label
    if (!title.isEmpty()) {
        lv_obj_t* titleLabel = lv_label_create(screen);
        lv_label_set_text(titleLabel, title.c_str());
        lv_obj_align(titleLabel, LV_ALIGN_TOP_MID, 0, 10);
        
        // Apply title style
        theme_apply_title(titleLabel);
    }
    
    // Create items
    if (config["items"].is<JsonVariant>() && config["items"].is<JsonArray>()) {
        JsonArray items = config["items"].as<JsonArray>();
        int yOffset = 50; // Start below title
        
        logger->info("Found " + String(items.size()) + " items to create");
        
        for (JsonObject item : items) {
            String type = item["type"].as<String>();
            String label = item["label"].as<String>();
            lv_obj_t* element = nullptr;
            
            logger->debug("Creating item: " + type + " - " + label);
            
            if (type == "button") {
                element = createButton(screen, item);
            } else if (type == "navigation") {
                // Navigation items are buttons that navigate to other screens
                element = createButton(screen, item);
            } else if (type == "label") {
                element = createLabel(screen, item);
            } else if (type == "switch") {
                element = createSwitch(screen, item);
            } else if (type == "slider") {
                element = createSlider(screen, item);
            } else if (type == "gauge") {
                element = createGauge(screen, item);
            } else if (type == "list") {
                element = createList(screen, item);
            } else {
                logger->warning("Unknown item type: " + type);
            }
            
            if (element != nullptr) {
                // Position element
                if (!item["x"].is<JsonVariant>() && !item["y"].is<JsonVariant>()) {
                    // Auto position vertically
                    lv_obj_align(element, LV_ALIGN_TOP_MID, 0, yOffset);
                    yOffset += lv_obj_get_height(element) + 10;
                } else {
                    positionElement(element, item);
                }
            }
        }
    } else {
        logger->warning("No items found or items not in array format for screen: " + screenId);
    }
    
    return screen;
}

lv_obj_t* ScreenFactory::createButton(lv_obj_t* parent, JsonObject& config) {
    lv_obj_t* btn = lv_btn_create(parent);
    
    // Set size
    if (config["width"].is<int>() && config["height"].is<int>()) {
        lv_obj_set_size(btn, config["width"], config["height"]);
    } else {
        lv_obj_set_size(btn, BUTTON_WIDTH, BUTTON_HEIGHT);
    }
    
    // Create label with icon support
    lv_obj_t* label = lv_label_create(btn);
    
    // Build label text with icon if available
    String labelText = config["label"].as<String>();
    String iconName = config["icon"].as<String>();
    
    if (iconManager && !iconName.isEmpty() && iconManager->hasIcon(iconName)) {
        // Use IconManager to create button text with icon
        String buttonText = iconManager->createButtonSymbol(iconName, labelText, true);
        lv_label_set_text(label, buttonText.c_str());
        
        if (logger) {
            logger->debug("ScreenFactory: Button created with icon '" + iconName + "' and text '" + labelText + "'");
        }
    } else {
        // Fallback to text only
        lv_label_set_text(label, labelText.c_str());
        
        if (!iconName.isEmpty() && logger) {
            logger->warning("ScreenFactory: Icon '" + iconName + "' not found, using text only");
        }
    }
    
    lv_obj_center(label);
    
    // Apply suggested color from IconManager if available
    if (iconManager && !iconName.isEmpty() && iconManager->hasIcon(iconName)) {
        String suggestedColor = iconManager->getSuggestedColor(iconName);
        // Convert hex color to LVGL color and apply
        // For now, we'll use the theme color but log the suggestion
        if (logger) {
            logger->debug("ScreenFactory: Suggested color for '" + iconName + "': " + suggestedColor);
        }
    }
    
    // Apply theme button style (default OFF)
    theme_apply_button_off(btn);
    
    // Apply custom styles if specified
    applyCommonStyles(btn, config);
    
    // Add action data if present
    if (config["action"].is<JsonVariant>()) {
        // TODO: Store action data for later handling
    }
    
    return btn;
}

lv_obj_t* ScreenFactory::createLabel(lv_obj_t* parent, JsonObject& config) {
    lv_obj_t* label = lv_label_create(parent);
    
    lv_label_set_text(label, config["label"].as<String>().c_str());
    
    // Text alignment
    if (config["align"].is<JsonVariant>()) {
        String align = config["align"].as<String>();
        if (align == "center") {
            lv_obj_set_style_text_align(label, LV_TEXT_ALIGN_CENTER, 0);
        } else if (align == "right") {
            lv_obj_set_style_text_align(label, LV_TEXT_ALIGN_RIGHT, 0);
        }
    }
    
    // Apply theme label style
    theme_apply_label(label);
    
    // Apply custom styles if specified
    applyCommonStyles(label, config);
    
    return label;
}

lv_obj_t* ScreenFactory::createSwitch(lv_obj_t* parent, JsonObject& config) {
    lv_obj_t* sw = lv_switch_create(parent);
    
    // Set initial state
    if (config["checked"].is<JsonVariant>() && config["checked"].as<bool>()) {
        lv_obj_add_state(sw, LV_STATE_CHECKED);
    }
    
    // Create label if present
    if (config["label"].is<JsonVariant>()) {
        lv_obj_t* label = lv_label_create(parent);
        lv_label_set_text(label, config["label"].as<String>().c_str());
        lv_obj_align_to(label, sw, LV_ALIGN_OUT_LEFT_MID, -10, 0);
        theme_apply_label(label);
    }
    
    // Apply styles
    applyCommonStyles(sw, config);
    
    return sw;
}

lv_obj_t* ScreenFactory::createSlider(lv_obj_t* parent, JsonObject& config) {
    lv_obj_t* slider = lv_slider_create(parent);
    
    // Set range
    if (config["min"].is<JsonVariant>() && config["max"].is<JsonVariant>()) {
        lv_slider_set_range(slider, config["min"], config["max"]);
    }
    
    // Set value
    if (config["value"].is<JsonVariant>()) {
        lv_slider_set_value(slider, config["value"], LV_ANIM_OFF);
    }
    
    // Set size
    if (config["width"].is<JsonVariant>()) {
        lv_obj_set_width(slider, config["width"]);
    } else {
        lv_obj_set_width(slider, 200);
    }
    
    // Create label if present
    if (config["label"].is<JsonVariant>()) {
        lv_obj_t* label = lv_label_create(parent);
        lv_label_set_text(label, config["label"].as<String>().c_str());
        lv_obj_align_to(label, slider, LV_ALIGN_OUT_TOP_MID, 0, -5);
        theme_apply_label(label);
    }
    
    // Apply styles
    applyCommonStyles(slider, config);
    
    return slider;
}

lv_obj_t* ScreenFactory::createGauge(lv_obj_t* parent, JsonObject& config) {
    lv_obj_t* meter = lv_meter_create(parent);
    
    // Set size
    if (config["size"].is<JsonVariant>()) {
        lv_obj_set_size(meter, config["size"], config["size"]);
    } else {
        lv_obj_set_size(meter, 150, 150);
    }
    
    // Add scale with theme colors
    lv_meter_scale_t* scale = lv_meter_add_scale(meter);
    lv_meter_set_scale_ticks(meter, scale, 41, 2, 10, COLOR_BORDER);
    lv_meter_set_scale_major_ticks(meter, scale, 8, 4, 15, COLOR_TEXT_OFF, 10);
    
    // Add needle with theme color
    lv_meter_indicator_t* indic = lv_meter_add_needle_line(meter, scale, 4, 
                                    COLOR_BUTTON_ON, -10);
    
    // Set value
    if (config["value"].is<JsonVariant>()) {
        lv_meter_set_indicator_value(meter, indic, config["value"]);
    }
    
    // Create label if present
    if (config["label"].is<JsonVariant>()) {
        lv_obj_t* label = lv_label_create(parent);
        lv_label_set_text(label, config["label"].as<String>().c_str());
        lv_obj_align_to(label, meter, LV_ALIGN_OUT_BOTTOM_MID, 0, 5);
        theme_apply_label(label);
    }
    
    return meter;
}

lv_obj_t* ScreenFactory::createList(lv_obj_t* parent, JsonObject& config) {
    lv_obj_t* list = lv_list_create(parent);
    
    // Set size
    if (config["width"].is<JsonVariant>() && config["height"].is<JsonVariant>()) {
        lv_obj_set_size(list, config["width"], config["height"]);
    } else {
        lv_obj_set_size(list, 280, 150);
    }
    
    // Apply theme styles to list
    lv_obj_set_style_bg_color(list, COLOR_BUTTON_OFF, 0);
    lv_obj_set_style_border_color(list, COLOR_BORDER, 0);
    lv_obj_set_style_border_width(list, 1, 0);
    lv_obj_set_style_radius(list, BUTTON_RADIUS, 0);
    
    // Add items
    if (config["options"].is<JsonVariant>() && config["options"].is<JsonArray>()) {
        JsonArray options = config["options"].as<JsonArray>();
        
        for (JsonVariant option : options) {
            String text = option.as<String>();
            lv_obj_t* btn = lv_list_add_btn(list, NULL, text.c_str());
            lv_obj_set_style_bg_color(btn, COLOR_BUTTON_OFF, 0);
            lv_obj_set_style_text_color(btn, COLOR_TEXT_OFF, 0);
        }
    }
    
    return list;
}

void ScreenFactory::applyCommonStyles(lv_obj_t* obj, JsonObject& config) {
    // Text color
    if (config["color"].is<JsonVariant>()) {
        lv_obj_set_style_text_color(obj, parseColor(config["color"]), 0);
    }
    
    // Background color
    if (config["bg_color"].is<JsonVariant>()) {
        lv_obj_set_style_bg_color(obj, parseColor(config["bg_color"]), 0);
    }
    
    // Font size
    if (config["font_size"].is<JsonVariant>()) {
        int size = config["font_size"];
        if (size <= 12) {
            lv_obj_set_style_text_font(obj, &lv_font_montserrat_12, 0);
        } else if (size <= 16) {
            lv_obj_set_style_text_font(obj, &lv_font_montserrat_16, 0);
        } else {
            lv_obj_set_style_text_font(obj, &lv_font_montserrat_20, 0);
        }
    }
}

void ScreenFactory::positionElement(lv_obj_t* obj, JsonObject& config) {
    if (config["x"].is<JsonVariant>() && config["y"].is<JsonVariant>()) {
        lv_obj_set_pos(obj, config["x"], config["y"]);
    }
}

lv_color_t ScreenFactory::parseColor(const String& colorStr) {
    // Parse hex color string
    if (colorStr.startsWith("#") && colorStr.length() == 7) {
        long color = strtol(colorStr.substring(1).c_str(), NULL, 16);
        uint8_t r = (color >> 16) & 0xFF;
        uint8_t g = (color >> 8) & 0xFF;
        uint8_t b = color & 0xFF;
        return lv_color_make(r, g, b);
    }
    
    // Default to theme text color
    return COLOR_TEXT_OFF;
}

float ScreenFactory::parseActionPayload(JsonObject& config, const String& key, float defaultValue) {
    if (!config["action_payload"].is<String>()) {
        return defaultValue;
    }
    
    String payloadStr = config["action_payload"].as<String>();
    if (payloadStr.isEmpty()) {
        return defaultValue;
    }
    
    JsonDocument payloadDoc;
    DeserializationError error = deserializeJson(payloadDoc, payloadStr);
    
    if (error) {
        if (logger) {
            logger->warning("Failed to parse action_payload JSON: " + String(error.c_str()));
        }
        return defaultValue;
    }
    
    JsonObject payload = payloadDoc.as<JsonObject>();
    return payload[key] | defaultValue;
}

// Nova função para criar display digital ao invés de gauge analógico
lv_obj_t* ScreenFactory::createGaugeDirectly(lv_obj_t* parent, JsonObject& config) {
    String label = config["label"].as<String>();
    String icon = config["icon"].as<String>();
    String id = config["name"].as<String>();
    String dataSource = config["data_source"].as<String>();
    String dataPath = config["data_path"].as<String>();
    String dataUnit = config["data_unit"].as<String>();
    
    // CORREÇÃO: Criar display digital ao invés de gauge analógico
    // Criar container principal com tamanho correto baseado em size_display_small
    lv_obj_t* container = lv_obj_create(parent);
    
    // CORREÇÃO: Usar campo "size" primeiro, depois "size_display_small"
    String itemSize = config["size"].as<String>();
    if (itemSize.isEmpty()) {
        itemSize = config["size_display_small"] | "normal";
    }
    if (itemSize.isEmpty()) {
        itemSize = "normal"; // default
    }
    lv_coord_t width = 86;
    lv_coord_t height = 72;
    
    // LOG DETALHADO: Configuração recebida
    if (logger) {
        logger->info("[SIZE DEBUG] createGaugeDirectly - Item: " + label);
        logger->info("[SIZE DEBUG]   Config size_display_small: '" + itemSize + "'");
    }
    
    if (itemSize == "small") {
        width = 86;  // Um slot apenas, sem texto
        height = 72;
    } else if (itemSize == "normal") {
        width = 86;  // Um slot, texto embaixo
        height = 72;
    } else if (itemSize == "large") {
        width = 202;  // CORREÇÃO: 2 slots (96*2 + 10 gap), texto à esquerda
        height = 75;
    } else if (itemSize == "full") {
        width = 308;  // CORREÇÃO: 3 slots (96*3 + 20 gaps), texto à esquerda
        height = 75;
    }
    
    if (logger) {
        logger->info("[SIZE DEBUG]   Calculated dimensions: " + String(width) + "x" + String(height));
        logger->debug("Creating digital display with size_display_small: " + itemSize + 
                     " -> " + String(width) + "x" + String(height));
    }
    
    // Configurar container
    lv_obj_set_size(container, width, height);
    theme_apply_card(container);
    lv_obj_clear_flag(container, LV_OBJ_FLAG_SCROLLABLE);
    
    // Configurar layout baseado no tamanho
    if (itemSize == "small") {
        // SMALL: Apenas valor, sem texto
        lv_obj_set_flex_flow(container, LV_FLEX_FLOW_COLUMN);
        lv_obj_set_flex_align(container, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
        
        // Valor grande centralizado
        lv_obj_t* valueLabel = lv_label_create(container);
        lv_label_set_text(valueLabel, "---");
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_20, 0);
        lv_obj_set_style_text_color(valueLabel, COLOR_GAUGE_NORMAL, 0);
        
        // Armazenar referência do valueLabel
        lv_obj_set_user_data(container, valueLabel);
        
    } else if (itemSize == "normal") {
        // NORMAL: Valor com texto embaixo
        lv_obj_set_flex_flow(container, LV_FLEX_FLOW_COLUMN);
        lv_obj_set_flex_align(container, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
        
        // Valor no centro
        lv_obj_t* valueLabel = lv_label_create(container);
        lv_label_set_text(valueLabel, "---");
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_20, 0);
        lv_obj_set_style_text_color(valueLabel, COLOR_GAUGE_NORMAL, 0);
        
        // Unidade pequena (se houver)
        if (!dataUnit.isEmpty()) {
            lv_obj_t* unitLabel = lv_label_create(container);
            lv_label_set_text(unitLabel, dataUnit.c_str());
            lv_obj_set_style_text_font(unitLabel, &lv_font_montserrat_10, 0);
            theme_apply_label_small(unitLabel);
        }
        
        // Label embaixo
        lv_obj_t* titleLabel = lv_label_create(container);
        lv_label_set_text(titleLabel, label.c_str());
        lv_obj_set_style_text_font(titleLabel, &lv_font_montserrat_10, 0);
        theme_apply_label_small(titleLabel);
        
        // Armazenar referência do valueLabel
        lv_obj_set_user_data(container, valueLabel);
        
    } else if (itemSize == "large" || itemSize == "full") {
        // LARGE/FULL: Texto à esquerda, valor à direita
        lv_obj_set_flex_flow(container, LV_FLEX_FLOW_ROW);
        lv_obj_set_flex_align(container, LV_FLEX_ALIGN_SPACE_BETWEEN, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
        lv_obj_set_style_pad_left(container, 10, 0);
        lv_obj_set_style_pad_right(container, 10, 0);
        
        // Container esquerdo para label e ícone
        lv_obj_t* leftContainer = lv_obj_create(container);
        lv_obj_set_size(leftContainer, LV_SIZE_CONTENT, LV_SIZE_CONTENT);
        lv_obj_set_style_bg_opa(leftContainer, LV_OPA_TRANSP, 0);
        lv_obj_set_style_border_width(leftContainer, 0, 0);
        lv_obj_set_style_pad_all(leftContainer, 0, 0);
        lv_obj_set_flex_flow(leftContainer, LV_FLEX_FLOW_ROW);
        lv_obj_set_flex_align(leftContainer, LV_FLEX_ALIGN_START, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
        
        // Ícone (se houver)
        if (iconManager && !icon.isEmpty()) {
            lv_obj_t* iconLabel = lv_label_create(leftContainer);
            String iconSymbol = iconManager->getIconSymbol(icon);
            lv_label_set_text(iconLabel, iconSymbol.c_str());
            lv_obj_set_style_text_font(iconLabel, &lv_font_montserrat_16, 0);
            theme_apply_label_small(iconLabel);
            lv_obj_set_style_pad_right(iconLabel, 5, 0);
        }
        
        // Label/título
        lv_obj_t* titleLabel = lv_label_create(leftContainer);
        lv_label_set_text(titleLabel, label.c_str());
        lv_obj_set_style_text_font(titleLabel, &lv_font_montserrat_14, 0);
        theme_apply_label_small(titleLabel);
        
        // Container direito para valor e unidade
        lv_obj_t* rightContainer = lv_obj_create(container);
        lv_obj_set_size(rightContainer, LV_SIZE_CONTENT, LV_SIZE_CONTENT);
        lv_obj_set_style_bg_opa(rightContainer, LV_OPA_TRANSP, 0);
        lv_obj_set_style_border_width(rightContainer, 0, 0);
        lv_obj_set_style_pad_all(rightContainer, 0, 0);
        lv_obj_set_flex_flow(rightContainer, LV_FLEX_FLOW_ROW);
        lv_obj_set_flex_align(rightContainer, LV_FLEX_ALIGN_END, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
        
        // Valor grande
        lv_obj_t* valueLabel = lv_label_create(rightContainer);
        lv_label_set_text(valueLabel, "---");
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_20, 0);
        lv_obj_set_style_text_color(valueLabel, COLOR_GAUGE_NORMAL, 0);
        
        // Unidade (se houver)
        if (!dataUnit.isEmpty()) {
            lv_obj_t* unitLabel = lv_label_create(rightContainer);
            lv_label_set_text(unitLabel, (" " + dataUnit).c_str());
            lv_obj_set_style_text_font(unitLabel, &lv_font_montserrat_12, 0);
            theme_apply_label_small(unitLabel);
        }
        
        // Armazenar referência do valueLabel
        lv_obj_set_user_data(container, valueLabel);
    }
    
    // Não precisa armazenar valueLabel aqui, já foi feito nos blocos acima
    
    // Registrar no DataBinder para atualizações automáticas se necessário
    if (!dataSource.isEmpty() && !dataPath.isEmpty()) {
        if (!dataBinder) {
            dataBinder = new DataBinder();
            if (logger) {
                logger->info("DataBinder: Initialized global instance");
            }
        }
        // Por enquanto não registrar no databinder sem NavButton
        // dataBinder->bindWidget(container, nullptr, config);
    }
    
    if (logger) {
        logger->debug("Created digital display: " + label + " size: " + String(width) + "x" + String(height));
    }
    
    return container; // Retornar o display digital
}

// Função original createGaugeItem - mantida para compatibilidade
NavButton* ScreenFactory::createGaugeItem(lv_obj_t* parent, JsonObject& config) {
    // Por compatibilidade, criar o gauge e retornar nullptr
    lv_obj_t* gauge = createGaugeDirectly(parent, config);
    return nullptr; // Não criar NavButton wrapper
}

lv_obj_t* ScreenFactory::createCircularGauge(lv_obj_t* parent, JsonObject& config, float minVal, float maxVal) {
    // Criar container principal
    lv_obj_t* container = lv_obj_create(parent);
    theme_apply_card(container);
    
    // Determinar tamanho baseado no size_display_small
    String itemSize = config["size_display_small"].as<String>();
    lv_coord_t meterSize = GAUGE_SIZE_NORMAL;
    if (itemSize == "small") {
        meterSize = GAUGE_SIZE_SMALL;
    } else if (itemSize == "large") {
        meterSize = GAUGE_SIZE_LARGE;
    }
    
    // Criar meter LVGL
    lv_obj_t* meter = lv_meter_create(container);
    lv_obj_set_size(meter, meterSize, meterSize);
    lv_obj_align(meter, LV_ALIGN_TOP_MID, 0, 0);
    
    // Criar escala principal
    lv_meter_scale_t* scale = lv_meter_add_scale(meter);
    lv_meter_set_scale_ticks(meter, scale, 41, 2, 10, COLOR_BORDER);
    lv_meter_set_scale_major_ticks(meter, scale, 8, 4, 15, COLOR_TEXT_OFF, 10);
    lv_meter_set_scale_range(meter, scale, minVal, maxVal, 240, 150);
    
    // Calcular thresholds para zonas de cores
    float warningStart = parseActionPayload(const_cast<JsonObject&>(config), "warning_threshold", maxVal * 0.8f);
    float criticalStart = parseActionPayload(const_cast<JsonObject&>(config), "critical_threshold", maxVal * 0.95f);
    
    // Zona normal (verde)
    lv_meter_indicator_t* indic_normal = lv_meter_add_arc(meter, scale, 3, COLOR_GAUGE_NORMAL, 0);
    lv_meter_set_indicator_start_value(meter, indic_normal, minVal);
    lv_meter_set_indicator_end_value(meter, indic_normal, warningStart);
    
    // Zona warning (laranja)
    if (warningStart < maxVal) {
        lv_meter_indicator_t* indic_warning = lv_meter_add_arc(meter, scale, 3, COLOR_GAUGE_WARNING, 0);
        lv_meter_set_indicator_start_value(meter, indic_warning, warningStart);
        lv_meter_set_indicator_end_value(meter, indic_warning, criticalStart);
    }
    
    // Zona crítica (vermelho)
    if (criticalStart < maxVal) {
        lv_meter_indicator_t* indic_critical = lv_meter_add_arc(meter, scale, 3, COLOR_GAUGE_CRITICAL, 0);
        lv_meter_set_indicator_start_value(meter, indic_critical, criticalStart);
        lv_meter_set_indicator_end_value(meter, indic_critical, maxVal);
    }
    
    // Adicionar ponteiro (needle)
    lv_meter_indicator_t* needle = lv_meter_add_needle_line(meter, scale, 4, COLOR_BUTTON_ON, -10);
    lv_meter_set_indicator_value(meter, needle, minVal); // Valor inicial
    
    // Armazenar referência do needle no user_data para atualizações
    lv_obj_set_user_data(meter, needle);
    
    // Label do valor (centro, abaixo do ponteiro)
    lv_obj_t* valueLabel = lv_label_create(container);
    lv_label_set_text(valueLabel, "0");
    lv_obj_align_to(valueLabel, meter, LV_ALIGN_OUT_BOTTOM_MID, 0, 5);
    theme_apply_label(valueLabel);
    
    // Fonte maior para o valor se gauge for grande
    if (meterSize >= GAUGE_SIZE_LARGE) {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_20, 0);
    } else if (meterSize >= GAUGE_SIZE_NORMAL) {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_16, 0);
    } else {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_14, 0);
    }
    
    // Label do título (pequeno, abaixo do valor)
    lv_obj_t* titleLabel = lv_label_create(container);
    lv_label_set_text(titleLabel, config["label"].as<String>().c_str());
    lv_obj_align_to(titleLabel, valueLabel, LV_ALIGN_OUT_BOTTOM_MID, 0, 2);
    theme_apply_label_small(titleLabel);
    
    // Ícone (canto superior direito do container)
    if (iconManager && !config["icon"].as<String>().isEmpty()) {
        lv_obj_t* iconLabel = lv_label_create(container);
        String iconSymbol = iconManager->getIconSymbol(config["icon"].as<String>());
        lv_label_set_text(iconLabel, iconSymbol.c_str());
        lv_obj_align(iconLabel, LV_ALIGN_TOP_RIGHT, -5, 5);
        theme_apply_icon(iconLabel);
    }
    
    return container; // Retorna container, não o meter diretamente
}

lv_obj_t* ScreenFactory::createLinearGauge(lv_obj_t* parent, JsonObject& config, float minVal, float maxVal) {
    // Criar container principal
    lv_obj_t* container = lv_obj_create(parent);
    theme_apply_card(container);
    
    // Determinar tamanho baseado no size_display_small
    String itemSize = config["size_display_small"].as<String>();
    lv_coord_t width = 150, height = 20;
    
    if (itemSize == "large") {
        width = 200; 
        height = 25;
    } else if (itemSize == "small") {
        width = 100; 
        height = 15;
    }
    
    // Label do título (topo)
    lv_obj_t* titleLabel = lv_label_create(container);
    lv_label_set_text(titleLabel, config["label"].as<String>().c_str());
    lv_obj_align(titleLabel, LV_ALIGN_TOP_LEFT, 0, 0);
    theme_apply_label_small(titleLabel);
    
    // Ícone (canto superior direito)
    if (iconManager && !config["icon"].as<String>().isEmpty()) {
        lv_obj_t* iconLabel = lv_label_create(container);
        String iconSymbol = iconManager->getIconSymbol(config["icon"].as<String>());
        lv_label_set_text(iconLabel, iconSymbol.c_str());
        lv_obj_align(iconLabel, LV_ALIGN_TOP_RIGHT, 0, 0);
        theme_apply_icon(iconLabel);
    }
    
    // Criar barra de progresso LVGL
    lv_obj_t* bar = lv_bar_create(container);
    lv_obj_set_size(bar, width, height);
    lv_obj_align_to(bar, titleLabel, LV_ALIGN_OUT_BOTTOM_LEFT, 0, 8);
    
    // Configurar range da barra
    lv_bar_set_range(bar, minVal, maxVal);
    lv_bar_set_value(bar, minVal, LV_ANIM_OFF);
    
    // Estilo da barra de fundo
    lv_obj_set_style_bg_color(bar, COLOR_BUTTON_OFF, 0);
    lv_obj_set_style_border_color(bar, COLOR_BORDER, 0);
    lv_obj_set_style_border_width(bar, 1, 0);
    lv_obj_set_style_radius(bar, 5, 0);
    
    // Estilo do indicador (parte preenchida) - com cores condicionais
    lv_obj_set_style_bg_color(bar, COLOR_GAUGE_NORMAL, LV_PART_INDICATOR);
    lv_obj_set_style_radius(bar, 3, LV_PART_INDICATOR);
    
    // Armazenar referência da barra no user_data para atualizações
    lv_obj_set_user_data(container, bar);
    
    // Labels dos valores min/max (pequenos, nas extremidades)
    lv_obj_t* minLabel = lv_label_create(container);
    lv_label_set_text(minLabel, String((int)minVal).c_str());
    lv_obj_align_to(minLabel, bar, LV_ALIGN_OUT_BOTTOM_LEFT, 0, 3);
    theme_apply_label_small(minLabel);
    
    lv_obj_t* maxLabel = lv_label_create(container);
    lv_label_set_text(maxLabel, String((int)maxVal).c_str());
    lv_obj_align_to(maxLabel, bar, LV_ALIGN_OUT_BOTTOM_RIGHT, 0, 3);
    theme_apply_label_small(maxLabel);
    
    // Label do valor atual (centro, abaixo da barra)
    lv_obj_t* valueLabel = lv_label_create(container);
    lv_label_set_text(valueLabel, "0");
    lv_obj_align_to(valueLabel, bar, LV_ALIGN_OUT_BOTTOM_MID, 0, 3);
    theme_apply_label(valueLabel);
    
    // Fonte baseada no tamanho
    if (itemSize == "large") {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_16, 0);
    } else if (itemSize == "small") {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_12, 0);
    } else {
        lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_14, 0);
    }
    
    return container;
}

String ScreenFactory::formatDisplayValue(float value, JsonObject& config) {
    String format = config["data_format"].as<String>();
    String unit = config["data_unit"].as<String>();
    
    char buffer[32];
    
    // Formatos predefinidos específicos
    if (format == "percentage") {
        snprintf(buffer, sizeof(buffer), "%.0f%%", value);
    } else if (format == "temperature") {
        snprintf(buffer, sizeof(buffer), "%.1f°C", value);
    } else if (format == "rpm") {
        snprintf(buffer, sizeof(buffer), "%.0f RPM", value);
    } else if (format == "voltage") {
        snprintf(buffer, sizeof(buffer), "%.2fV", value);
    } else if (format == "pressure") {
        snprintf(buffer, sizeof(buffer), "%.1f PSI", value);
    } else if (format.startsWith("%.")) {
        // Formato printf personalizado
        String formatStr = format;
        if (!unit.isEmpty()) {
            formatStr += " " + unit;
        }
        snprintf(buffer, sizeof(buffer), formatStr.c_str(), value);
    } else {
        // Formato automático baseado na magnitude do valor
        if (value >= 1000) {
            if (unit.isEmpty()) {
                snprintf(buffer, sizeof(buffer), "%.1fk", value/1000.0);
            } else {
                snprintf(buffer, sizeof(buffer), "%.1fk %s", value/1000.0, unit.c_str());
            }
        } else if (value >= 100) {
            if (unit.isEmpty()) {
                snprintf(buffer, sizeof(buffer), "%.0f", value);
            } else {
                snprintf(buffer, sizeof(buffer), "%.0f %s", value, unit.c_str());
            }
        } else {
            if (unit.isEmpty()) {
                snprintf(buffer, sizeof(buffer), "%.1f", value);
            } else {
                snprintf(buffer, sizeof(buffer), "%.1f %s", value, unit.c_str());
            }
        }
    }
    
    return String(buffer);
}

void ScreenFactory::applyDynamicColors(lv_obj_t* obj, JsonObject& config, float value) {
    String dataPath = config["data_path"].as<String>();
    
    lv_color_t color = COLOR_TEXT_OFF; // Padrão
    
    // Lógica específica por tipo de dado
    if (dataPath == "coolant_temp" || dataPath == "engine_temp") {
        if (value > 90) color = COLOR_GAUGE_CRITICAL;      // Vermelho
        else if (value > 80) color = COLOR_GAUGE_WARNING;  // Laranja
        else color = COLOR_GAUGE_NORMAL;                   // Verde
    } else if (dataPath == "fuel_level") {
        if (value < 20) color = COLOR_GAUGE_WARNING;       // Laranja
        else color = COLOR_GAUGE_NORMAL;                   // Verde
    } else if (dataPath == "engine_rpm") {
        if (value > 5000) color = COLOR_GAUGE_CRITICAL;    // Vermelho - RPM muito alto
        else if (value > 4000) color = COLOR_GAUGE_WARNING; // Laranja - RPM alto
        else color = COLOR_GAUGE_NORMAL;                   // Verde
    } else if (dataPath == "oil_pressure") {
        if (value < 10) color = COLOR_GAUGE_CRITICAL;      // Vermelho - pressão muito baixa
        else if (value < 20) color = COLOR_GAUGE_WARNING;  // Laranja - pressão baixa
        else color = COLOR_GAUGE_NORMAL;                   // Verde
    } else if (dataPath == "battery_voltage") {
        if (value < 12.0f) color = COLOR_GAUGE_CRITICAL;   // Vermelho - bateria baixa
        else if (value < 12.5f) color = COLOR_GAUGE_WARNING; // Laranja - voltagem baixa
        else color = COLOR_GAUGE_NORMAL;                   // Verde
    }
    
    // Aplicar cor no primeiro label encontrado (assume ser o label de valor)
    lv_obj_t* valueLabel = lv_obj_get_child(obj, 1); // Segundo filho geralmente é o valor
    if (valueLabel && lv_obj_check_type(valueLabel, &lv_label_class)) {
        lv_obj_set_style_text_color(valueLabel, color, 0);
    }
}

lv_coord_t ScreenFactory::calculateItemSize(const String& size, bool isWidth) {
    // Configuração do display P (2 colunas por padrão)
    int totalColumns = 2;
    lv_coord_t containerWidth = 480 - 40; // Assumindo tela 480px - margens
    lv_coord_t containerHeight = 320 - 80; // Assumindo tela 320px - header/footer
    
    if (isWidth) {
        lv_coord_t columnWidth = containerWidth / totalColumns;
        lv_coord_t gap = 8;
        
        if (size == "small" || size == "normal") {
            return columnWidth - gap;
        } else if (size == "large") {
            return (columnWidth * 2) - gap; // Span 2 colunas
        } else if (size == "full") {
            return containerWidth - gap;
        }
        return columnWidth - gap; // default
    } else {
        // Height
        if (size == "small") return 64;
        else if (size == "normal") return 80;
        else if (size == "large") return 96;
        return 80; // default
    }
}

lv_obj_t* ScreenFactory::createSwitchDirectly(lv_obj_t* parent, JsonObject& config) {
    String label = config["label"].as<String>();
    String icon = config["icon"].as<String>();
    String id = config["name"].as<String>();
    String actionType = config["action_type"].as<String>();
    
    // Extrair informações do relay para switches
    uint8_t relay_board_id = config["relay_board_id"] | 0;
    uint8_t relay_channel_id = config["relay_channel_id"] | 0;
    
    if (logger) {
        logger->debug("Creating native switch: " + label + " (relay: " + 
                     String(relay_board_id) + ":" + String(relay_channel_id) + ")");
    }
    
    // Criar container customizado para switch no estilo card
    lv_obj_t* container = lv_obj_create(parent);
    theme_apply_card(container);
    
    // CORREÇÃO: Usar campo "size" primeiro, depois "size_display_small" 
    String itemSize = config["size"].as<String>();
    if (itemSize.isEmpty()) {
        itemSize = config["size_display_small"] | "normal";
    }
    if (itemSize.isEmpty()) {
        itemSize = "normal"; // default
    }
    lv_coord_t width = 86;
    lv_coord_t height = 72;
    
    if (itemSize == "small") {
        width = 70;
        height = 60;
    } else if (itemSize == "large") {
        width = 140;
        height = 90;
    }
    
    lv_obj_set_size(container, width, height);
    
    if (logger) {
        logger->debug("Creating switch with size_display_small: " + itemSize + 
                     " -> " + String(width) + "x" + String(height));
    }
    
    // Layout horizontal: [Icon] [Label] -------- [Switch]
    
    // Ícone (lado esquerdo)
    lv_obj_t* iconLabel = nullptr;
    lv_coord_t iconWidth = 0;
    if (iconManager && !icon.isEmpty() && iconManager->hasIcon(icon)) {
        iconLabel = lv_label_create(container);
        String iconSymbol = iconManager->getIconSymbol(icon);
        lv_label_set_text(iconLabel, iconSymbol.c_str());
        lv_obj_align(iconLabel, LV_ALIGN_LEFT_MID, 8, 0);
        theme_apply_icon(iconLabel);
        iconWidth = 25; // Espaço para o ícone
    }
    
    // Label de texto (centro-esquerda)
    lv_obj_t* textLabel = lv_label_create(container);
    lv_label_set_text(textLabel, label.c_str());
    if (iconLabel) {
        lv_obj_align_to(textLabel, iconLabel, LV_ALIGN_OUT_RIGHT_MID, 8, 0);
    } else {
        lv_obj_align(textLabel, LV_ALIGN_LEFT_MID, 8, 0);
    }
    theme_apply_label(textLabel);
    
    // Switch widget LVGL nativo (lado direito)
    lv_obj_t* lvSwitch = lv_switch_create(container);
    lv_obj_align(lvSwitch, LV_ALIGN_RIGHT_MID, -8, 0);
    
    // Aplicar cores do tema ao switch
    lv_obj_set_style_bg_color(lvSwitch, COLOR_BUTTON_OFF, 0);
    lv_obj_set_style_bg_color(lvSwitch, COLOR_GAUGE_NORMAL, LV_STATE_CHECKED);
    lv_obj_set_style_border_color(lvSwitch, COLOR_BORDER, 0);
    lv_obj_set_style_border_width(lvSwitch, 1, 0);
    
    // Knob do switch
    lv_obj_set_style_bg_color(lvSwitch, COLOR_TEXT_OFF, LV_PART_KNOB);
    lv_obj_set_style_bg_color(lvSwitch, COLOR_TEXT_ON, LV_PART_KNOB | LV_STATE_CHECKED);
    
    // CORREÇÃO: Retornar container diretamente como um pseudo-NavButton
    // Para switches, não usamos NavButton wrapper - criamos pseudo-objeto
    
    // Armazenar informações necessárias no user_data do container para compatibilidade
    struct SwitchInfo {
        uint8_t relay_board_id;
        uint8_t relay_channel_id;
        String label;
        String id;
    };
    
    SwitchInfo* switchInfo = new SwitchInfo();
    switchInfo->relay_board_id = relay_board_id;
    switchInfo->relay_channel_id = relay_channel_id;
    switchInfo->label = label;
    switchInfo->id = id;
    
    lv_obj_set_user_data(container, switchInfo);
    
    // Verificar se relay board existe
    if (relay_board_id > 0 && relay_channel_id > 0) {
        if (!DeviceRegistry::getInstance()->hasRelayBoard(relay_board_id)) {
            logger->warning("Switch relay board not found: " + String(relay_board_id) + 
                           " for switch: " + id + " (" + label + ")");
            // Desabilitar switch visualmente
            lv_obj_add_state(lvSwitch, LV_STATE_DISABLED);
        }
    } else {
        logger->warning("Switch without valid relay config: " + id);
        lv_obj_add_state(lvSwitch, LV_STATE_DISABLED);
    }
    
    // Callback do switch nativo
    lv_obj_add_event_cb(lvSwitch, [](lv_event_t* e) {
        lv_obj_t* sw = lv_event_get_target(e);
        SwitchInfo* switchInfo = (SwitchInfo*)lv_obj_get_user_data(sw);
        
        if (switchInfo && lv_event_get_code(e) == LV_EVENT_VALUE_CHANGED) {
            bool isChecked = lv_obj_has_state(sw, LV_STATE_CHECKED);
            
            // Executar comando de relay
            extern CommandSender* commandSender;
            
            if (commandSender && switchInfo->relay_channel_id > 0) {
                // Debounce simples
                static unsigned long lastSwitchTime = 0;
                unsigned long now = millis();
                if (now - lastSwitchTime > 500) { // 500ms debounce
                    lastSwitchTime = now;
                    
                    String boardId = String(switchInfo->relay_board_id);
                    
                    commandSender->sendRelayCommand(boardId, switchInfo->relay_channel_id, 
                                                  isChecked ? "on" : "off", "toggle");
                    
                    if (logger) {
                        logger->debug("Switch command sent: " + boardId + ":" + 
                                    String(switchInfo->relay_channel_id) + " = " + (isChecked ? "ON" : "OFF"));
                    }
                }
            }
        }
    }, LV_EVENT_VALUE_CHANGED, switchInfo);
    
    // Armazenar referência do switchInfo no switch para o callback
    lv_obj_set_user_data(lvSwitch, switchInfo);
    
    return container; // CORREÇÃO: Retornar container ao invés de NavButton
}