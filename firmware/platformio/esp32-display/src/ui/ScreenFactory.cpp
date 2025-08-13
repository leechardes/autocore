/**
 * @file ScreenFactory.cpp
 * @brief Implementation of screen factory
 */

#include "ui/ScreenFactory.h"
#include "ui/Theme.h"
#include "core/Logger.h"
#include "Layout.h"
#include "ui/Icons.h"
#include "ui/ScreenManager.h"
#include "commands/CommandSender.h"
#include "communication/ButtonStateManager.h"
#include "models/DeviceModels.h"
#include <ArduinoJson.h>
#include <algorithm>
#include <vector>

extern Logger* logger;
extern ScreenManager* screenManager;

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
            
            // Recriar itens para a página atual
            int pageSize = Layout::getMaxItemsPerPage();
            int startIdx = navState.currentPage * pageSize;
            int endIdx = std::min(startIdx + pageSize, (int)sortedItems.size());
            
            for (int i = startIdx; i < endIdx; i++) {
                JsonObject item = sortedItems[i].item;
                
                // A API retorna 'item_type' não 'type'
                String itemType = item["item_type"].as<String>();
                String actionType = item["action_type"].as<String>();
                
                // Debug log
                logger->debug("Creating item: " + itemType + " (action: " + actionType + ") - " + item["label"].as<String>());
                
                NavButton* navBtn = nullptr;
                
                // Mapear tipos da API para tipos internos
                if (itemType == "button" && actionType == "relay") {
                    navBtn = ScreenFactory::createRelayItem(content->getObject(), item);
                } else if (itemType == "button" && actionType == "navigation") {
                    navBtn = ScreenFactory::createNavigationItem(content->getObject(), item);
                } else if (itemType == "button" && actionType == "preset") {
                    navBtn = ScreenFactory::createActionItem(content->getObject(), item);
                } else if (itemType == "switch" && actionType == "relay") {
                    navBtn = ScreenFactory::createRelayItem(content->getObject(), item);
                } else if (itemType == "display") {
                    // Items de display são apenas informativos, criar como label
                    navBtn = ScreenFactory::createDisplayItem(content->getObject(), item);
                } else {
                    logger->warning("Unknown item combination: " + itemType + "/" + actionType);
                }
                
                if (navBtn) {
                    content->addChild(navBtn->getObject());
                    
                    // Registrar botão para receber status se for tipo que precisa
                    if ((itemType == "button" || itemType == "switch") && actionType == "relay") {
                        extern ButtonStateManager* buttonStateManager;
                        if (buttonStateManager) {
                            buttonStateManager->registerButton(navBtn);
                        }
                    }
                }
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
    
    // Process items from new structure (screen_items)
    if (config["screen_items"].is<JsonArray>()) {
        JsonArray items = config["screen_items"].as<JsonArray>();
        screen->setItems(items); // Armazenar todos os items
        
        // Update navigation state
        NavigationState& navState = const_cast<NavigationState&>(screen->navState);
        navState.totalItems = items.size();
        navState.totalPages = Layout::calculateTotalPages(items.size());
        
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
    
    // For navigation items in new structure, target is the screen ID
    // which might be numeric now
    auto btn = new NavButton(parent, label, icon, id);
    btn->setTarget(target);
    
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
        logger->warning("Relay board not found in registry: " + String(relay_board_id));
        // Visual de desabilitado - usar estado OFF
        btn->setState(false);
        return btn;
    }
    
    // Configurar callback para envio de comando com novo formato
    btn->setClickCallback([relay_board_id, relay_channel_id, function_type](NavButton* b) {
        extern CommandSender* commandSender;
        extern ButtonStateManager* buttonStateManager;
        
        if (commandSender) {
            // Determinar estado baseado no tipo
            bool newState = true;
            if (function_type == "toggle") {
                // Para toggle, usar estado atual do botão e inverter
                newState = !b->getState();
            }
            
            // Enviar comando com novo formato
            commandSender->sendRelayCommand(String(relay_board_id), relay_channel_id, newState ? "on" : "off", function_type);
            
            // Para toggle, atualizar estado visual imediatamente
            if (function_type == "toggle") {
                b->setState(newState);
            }
            
            // Registrar botão para receber atualizações MQTT se ainda não estiver
            if (buttonStateManager) {
                buttonStateManager->registerButton(b);
            }
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
    
    auto btn = new NavButton(parent, label, icon, id);
    btn->setButtonType(NavButton::TYPE_ACTION);
    btn->setActionConfig(actionType, preset);
    
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
    
    auto btn = new NavButton(parent, label, icon, id);
    btn->setButtonType(NavButton::TYPE_MODE);
    btn->setModeConfig(mode);
    
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
    
    // Items de display são informativos, mas ainda podem ser NavButtons
    auto btn = new NavButton(parent, label, icon, id);
    btn->setButtonType(NavButton::TYPE_DISPLAY);
    
    // Configurar dados do display
    btn->setDisplayConfig(dataSource, dataPath, dataUnit);
    
    // Items de display são read-only, sem callback de clique
    logger->debug("Created display item: " + id + " (" + dataSource + ":" + dataPath + ")");
    
    return btn;
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
    
    // Create label
    lv_obj_t* label = lv_label_create(btn);
    lv_label_set_text(label, config["label"].as<String>().c_str());
    lv_obj_center(label);
    
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