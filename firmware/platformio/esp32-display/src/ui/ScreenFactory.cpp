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
                    String sizeStr = item["size_display_small"] | "normal";
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
                
                // Verificar quantos slots este componente precisa
                String sizeStr = item["size_display_small"] | "normal";
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
                
                // Debug log melhorado
                logger->debug("=== Creating item ===");
                logger->debug("  Type: " + itemType + " | Action: " + actionType);
                logger->debug("  Label: " + item["label"].as<String>());
                logger->debug("  Size: " + sizeStr + " (slots needed: " + String(slotsNeeded) + ")");
                logger->debug("  Position: " + String(item["position"] | 0));
                
                NavButton* navBtn = nullptr;
                
                // Mapear tipos da API para tipos internos
                if (itemType == "button" && (actionType == "relay" || actionType == "relay_toggle")) {
                    logger->debug("  -> Creating RelayItem (button for relay control)");
                    navBtn = ScreenFactory::createRelayItem(content->getObject(), item);
                } else if (itemType == "button" && actionType == "navigation") {
                    logger->debug("  -> Creating NavigationItem (button for screen navigation)");
                    navBtn = ScreenFactory::createNavigationItem(content->getObject(), item);
                } else if (itemType == "button" && actionType == "preset") {
                    logger->debug("  -> Creating ActionItem (button for preset actions)");
                    navBtn = ScreenFactory::createActionItem(content->getObject(), item);
                } else if (itemType == "switch") {
                    logger->debug("  -> Creating SwitchItem (native LVGL switch widget)");
                    // Switches nativos LVGL para melhor UX
                    navBtn = ScreenFactory::createSwitchItem(content->getObject(), item);
                } else if (itemType == "gauge") {
                    logger->debug("  -> Creating GaugeItem (gauge/meter widget)");
                    // Gauges/meters nativos LVGL
                    navBtn = ScreenFactory::createGaugeItem(content->getObject(), item);
                } else if (itemType == "display") {
                    logger->debug("  -> Creating DisplayItem (read-only data display)");
                    // Items de display são apenas informativos, criar como label
                    navBtn = ScreenFactory::createDisplayItem(content->getObject(), item);
                } else {
                    logger->warning("  -> UNKNOWN item combination: " + itemType + "/" + actionType);
                    logger->warning("     Available combinations:");
                    logger->warning("     - button/relay_toggle, button/navigation, button/preset");
                    logger->warning("     - switch (with action_type), gauge, display");
                }
                
                if (navBtn) {
                    lv_obj_t* btnObj = navBtn->getObject();
                    
                    // Debug: verificar o objeto antes de adicionar
                    logger->debug("Adding NavButton object to content container");
                    logger->debug("  Button object: " + String((long)btnObj, HEX));
                    logger->debug("  Button parent: " + String((long)lv_obj_get_parent(btnObj), HEX)); 
                    logger->debug("  Content object: " + String((long)content->getObject(), HEX));
                    
                    // Adicionar ao container
                    content->addChild(btnObj);
                    
                    // Debug: verificar após adicionar
                    logger->debug("  Added to container. Total children: " + String(content->getChildCount()));
                    
                    // Contar slots utilizados
                    currentPageSlots += slotsNeeded;
                    
                    // Registrar botão para receber status se for tipo que precisa
                    if ((itemType == "button" || itemType == "switch") && actionType == "relay") {
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
            String sizeStr = item["size_display_small"] | "normal";
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
    navBtn->setValueLabel(valueLabel); // Armazenar referência para atualizações
    
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

NavButton* ScreenFactory::createGaugeItem(lv_obj_t* parent, JsonObject& config) {
    String label = config["label"].as<String>();
    String icon = config["icon"].as<String>();
    String id = config["name"].as<String>();
    String dataSource = config["data_source"].as<String>();
    String dataPath = config["data_path"].as<String>();
    String dataUnit = config["data_unit"].as<String>();
    
    // Parse configurações específicas do gauge do action_payload
    float minValue = parseActionPayload(config, "min_value", 0);
    float maxValue = parseActionPayload(config, "max_value", 100);
    float warningThreshold = parseActionPayload(config, "warning_threshold", maxValue * 0.8f);
    float criticalThreshold = parseActionPayload(config, "critical_threshold", maxValue * 0.95f);
    
    // Tipo de gauge (circular ou linear)
    String gaugeType = "circular"; // default
    if (config["action_payload"].is<String>()) {
        JsonDocument payloadDoc;
        if (deserializeJson(payloadDoc, config["action_payload"].as<String>()) == DeserializationError::Ok) {
            JsonObject payload = payloadDoc.as<JsonObject>();
            gaugeType = payload["gauge_type"] | "circular";
        }
    }
    
    if (logger) {
        logger->debug("Creating gauge: " + label + " (" + gaugeType + ") range: " + 
                     String(minValue) + "-" + String(maxValue));
    }
    
    // Criar widget gauge baseado no tipo
    lv_obj_t* gauge = nullptr;
    if (gaugeType == "circular") {
        gauge = createCircularGauge(parent, config, minValue, maxValue);
    } else {
        gauge = createLinearGauge(parent, config, minValue, maxValue);
    }
    
    if (!gauge) {
        logger->error("Failed to create gauge widget");
        return nullptr;
    }
    
    // Criar NavButton wrapper para compatibilidade
    auto navBtn = new NavButton(gauge, label, icon, id);
    navBtn->setButtonType(NavButton::TYPE_GAUGE);
    navBtn->setDisplayConfig(dataSource, dataPath, dataUnit);
    navBtn->setLVGLObject(gauge);
    
    // Registrar no DataBinder para atualizações automáticas
    if (!dataBinder) {
        dataBinder = new DataBinder();
        if (logger) {
            logger->info("DataBinder: Initialized global instance");
        }
    }
    
    // Apenas registrar se tem dados válidos para binding
    if (!dataSource.isEmpty() && !dataPath.isEmpty()) {
        dataBinder->bindWidget(gauge, navBtn, config);
    }
    
    return navBtn;
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

NavButton* ScreenFactory::createSwitchItem(lv_obj_t* parent, JsonObject& config) {
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
    
    // Criar NavButton wrapper para manter compatibilidade
    auto navBtn = new NavButton(container, label, icon, id);
    navBtn->setButtonType(NavButton::TYPE_SWITCH);
    navBtn->setLVGLObject(lvSwitch); // Associar widget switch
    
    // Configurar relay se válido
    if (relay_board_id > 0 && relay_channel_id > 0) {
        String device = "relay_board_" + String(relay_board_id);
        navBtn->setRelayConfig(device, relay_channel_id, "toggle");
        
        // Verificar se relay board existe
        if (!DeviceRegistry::getInstance()->hasRelayBoard(relay_board_id)) {
            logger->warning("Switch relay board not found: " + String(relay_board_id));
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
        NavButton* btn = (NavButton*)lv_obj_get_user_data(sw);
        
        if (btn && lv_event_get_code(e) == LV_EVENT_VALUE_CHANGED) {
            bool isChecked = lv_obj_has_state(sw, LV_STATE_CHECKED);
            btn->setState(isChecked);
            
            // Executar comando de relay
            extern CommandSender* commandSender;
            extern ButtonStateManager* buttonStateManager;
            
            if (commandSender && btn->getChannel() > 0) {
                // Debounce check
                if (btn->canSendCommand()) {
                    String boardId = btn->getDeviceId();
                    if (boardId.startsWith("relay_board_")) {
                        boardId = boardId.substring(12); // Remove "relay_board_" prefix
                    }
                    
                    commandSender->sendRelayCommand(boardId, btn->getChannel(), 
                                                  isChecked ? "on" : "off", "toggle");
                    
                    if (logger) {
                        logger->debug("Switch command sent: " + boardId + ":" + 
                                    String(btn->getChannel()) + " = " + (isChecked ? "ON" : "OFF"));
                    }
                }
                
                // Registrar para receber atualizações MQTT
                if (buttonStateManager) {
                    buttonStateManager->registerButton(btn);
                }
            }
        }
    }, LV_EVENT_VALUE_CHANGED, navBtn);
    
    // Armazenar referência do NavButton no switch para o callback
    lv_obj_set_user_data(lvSwitch, navBtn);
    
    return navBtn;
}