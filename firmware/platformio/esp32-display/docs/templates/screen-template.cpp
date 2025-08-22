/**
 * @file ScreenTemplate.cpp
 * @brief Implementação do template para novas telas LVGL
 * @author AutoCore System
 * @version 1.0.0
 * @date 2025-01-18
 */

#include "ScreenTemplate.h"
#include "ui/ScreenFactory.h"
#include "ui/Theme.h"
#include "core/Logger.h"

// Logger global externo
extern Logger* logger;

ScreenTemplate::ScreenTemplate(const String& screenId, JsonObject& config) 
    : ScreenBase(screenId, config) {
    logger = Logger::getInstance();
    logger->info("Creating ScreenTemplate: " + screenId);
    
    // Processar configuração específica
    if (config.containsKey("title")) {
        setTitle(config["title"].as<String>());
    }
    
    if (config.containsKey("background_color")) {
        String colorStr = config["background_color"];
        setBackgroundColor(Theme::parseColor(colorStr));
    }
}

ScreenTemplate::~ScreenTemplate() {
    logger->info("Destroying ScreenTemplate: " + getId());
    cleanup();
}

bool ScreenTemplate::initialize() {
    if (isInitialized) {
        logger->warning("ScreenTemplate already initialized: " + getId());
        return true;
    }
    
    logger->info("Initializing ScreenTemplate: " + getId());
    
    try {
        // Criar layout principal
        createLayout();
        
        // Criar seções da tela
        createHeader();
        createContent();
        createFooter();
        
        // Configurar event handlers
        setupEventHandlers();
        
        // Aplicar tema
        applyTheme();
        
        isInitialized = true;
        logger->info("ScreenTemplate initialized successfully: " + getId());
        
        return true;
        
    } catch (const std::exception& e) {
        logger->error("Failed to initialize ScreenTemplate: " + String(e.what()));
        cleanup();
        return false;
    }
}

void ScreenTemplate::createLayout() {
    // Criar container principal
    container = lv_obj_create(NULL);
    lv_obj_set_size(container, LV_HOR_RES, LV_VER_RES);
    lv_obj_clear_flag(container, LV_OBJ_FLAG_SCROLLABLE);
    
    // Configurar layout flexível
    lv_obj_set_flex_flow(container, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_flex_align(container, LV_FLEX_ALIGN_START, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    
    logger->debug("Layout container created");
}

void ScreenTemplate::createHeader() {
    // Criar área do header (80px altura)
    header = lv_obj_create(container);
    lv_obj_set_size(header, LV_PCT(100), 80);
    lv_obj_set_style_pad_all(header, 10, 0);
    
    // Container flexível para elementos do header
    lv_obj_set_flex_flow(header, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(header, LV_FLEX_ALIGN_SPACE_BETWEEN, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    
    // Botão de voltar
    JsonObject backBtnConfig;
    backBtnConfig["type"] = "navigation";
    backBtnConfig["id"] = "back_button";
    backBtnConfig["label"] = "Voltar";
    backBtnConfig["icon"] = "arrow_left";
    backBtnConfig["target"] = "home";
    
    NavButton* backBtn = ScreenFactory::createNavigationItem(header, backBtnConfig);
    backBtn->setClickCallback(backButtonCallback);
    buttons.push_back(backBtn);
    
    // Título da tela
    titleLabel = lv_label_create(header);
    lv_label_set_text(titleLabel, "Screen Title");
    lv_obj_set_style_text_font(titleLabel, &lv_font_montserrat_24, 0);
    
    // Botão de menu (opcional)
    JsonObject menuBtnConfig;
    menuBtnConfig["type"] = "action";
    menuBtnConfig["id"] = "menu_button";
    menuBtnConfig["label"] = "Menu";
    menuBtnConfig["icon"] = "menu";
    
    NavButton* menuBtn = ScreenFactory::createActionItem(header, menuBtnConfig);
    menuBtn->setClickCallback(menuButtonCallback);
    buttons.push_back(menuBtn);
    
    logger->debug("Header created with navigation buttons");
}

void ScreenTemplate::createContent() {
    // Criar área de conteúdo (flexível)
    content = lv_obj_create(container);
    lv_obj_set_size(content, LV_PCT(100), LV_SIZE_CONTENT);
    lv_obj_set_flex_grow(content, 1); // Ocupar espaço restante
    lv_obj_set_style_pad_all(content, 15, 0);
    
    // Configurar scroll se necessário
    lv_obj_set_scroll_dir(content, LV_DIR_VER);
    
    // Grid layout para conteúdo (2 colunas)
    lv_obj_set_layout(content, LV_LAYOUT_GRID);
    
    static lv_coord_t col_dsc[] = {LV_GRID_FR(1), LV_GRID_FR(1), LV_GRID_TEMPLATE_LAST};
    static lv_coord_t row_dsc[] = {LV_GRID_CONTENT, LV_GRID_CONTENT, LV_GRID_CONTENT, LV_GRID_TEMPLATE_LAST};
    
    lv_obj_set_grid_dsc_array(content, col_dsc, row_dsc);
    
    // Exemplo: Adicionar widgets de conteúdo
    createContentWidgets();
    
    logger->debug("Content area created with grid layout");
}

void ScreenTemplate::createContentWidgets() {
    // Exemplo de widgets de conteúdo - customizar conforme necessário
    
    // Widget de status
    lv_obj_t* statusContainer = lv_obj_create(content);
    lv_obj_set_grid_cell(statusContainer, LV_GRID_ALIGN_STRETCH, 0, 2, LV_GRID_ALIGN_CENTER, 0, 1);
    
    statusLabel = lv_label_create(statusContainer);
    lv_label_set_text(statusLabel, "Status: Ready");
    lv_obj_center(statusLabel);
    
    // Widget de dados - exemplo
    lv_obj_t* dataContainer = lv_obj_create(content);
    lv_obj_set_grid_cell(dataContainer, LV_GRID_ALIGN_STRETCH, 0, 1, LV_GRID_ALIGN_CENTER, 1, 1);
    
    lv_obj_t* dataLabel = lv_label_create(dataContainer);
    lv_label_set_text(dataLabel, "Data Display");
    lv_obj_center(dataLabel);
    
    // Botão customizado - exemplo
    JsonObject customBtnConfig;
    customBtnConfig["type"] = "action";
    customBtnConfig["id"] = "custom_action";
    customBtnConfig["label"] = "Custom Action";
    customBtnConfig["icon"] = "gear";
    
    NavButton* customBtn = ScreenFactory::createActionItem(content, customBtnConfig);
    lv_obj_set_grid_cell(customBtn->getObject(), LV_GRID_ALIGN_STRETCH, 1, 1, LV_GRID_ALIGN_CENTER, 1, 1);
    customBtn->setClickCallback(customButtonCallback);
    buttons.push_back(customBtn);
}

void ScreenTemplate::createFooter() {
    // Criar área do footer (60px altura)
    footer = lv_obj_create(container);
    lv_obj_set_size(footer, LV_PCT(100), 60);
    lv_obj_set_style_pad_all(footer, 10, 0);
    
    // Layout flexível para footer
    lv_obj_set_flex_flow(footer, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(footer, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    
    // Informações do footer (versão, conexão, etc.)
    lv_obj_t* infoLabel = lv_label_create(footer);
    lv_label_set_text_fmt(infoLabel, "v%s | WiFi: Connected", FIRMWARE_VERSION);
    lv_obj_set_style_text_color(infoLabel, lv_color_hex(0x808080), 0);
    
    logger->debug("Footer created with info label");
}

void ScreenTemplate::setupEventHandlers() {
    // Configurar event handlers específicos da tela
    
    // Event handler para touch/gestures
    lv_obj_add_event_cb(container, [](lv_event_t* e) {
        ScreenTemplate* screen = (ScreenTemplate*)lv_event_get_user_data(e);
        lv_event_code_t code = lv_event_get_code(e);
        
        switch (code) {
            case LV_EVENT_GESTURE:
                screen->handleGesture(e);
                break;
            case LV_EVENT_KEY:
                screen->handleKeyPress(e);
                break;
            default:
                break;
        }
    }, LV_EVENT_ALL, this);
    
    logger->debug("Event handlers configured");
}

void ScreenTemplate::applyTheme() {
    // Aplicar tema padrão do sistema
    Theme::applyToContainer(container);
    Theme::applyToHeader(header);
    Theme::applyToContent(content);
    Theme::applyToFooter(footer);
    
    logger->debug("Theme applied to screen components");
}

void ScreenTemplate::show() {
    if (!isInitialized) {
        logger->warning("Cannot show uninitialized screen: " + getId());
        return;
    }
    
    logger->info("Showing ScreenTemplate: " + getId());
    
    // Carregar tela ativa
    lv_scr_load(container);
    
    // Atualizar dados se necessário
    updateDisplayData();
    
    // Marcar como ativa
    setActive(true);
}

void ScreenTemplate::hide() {
    logger->info("Hiding ScreenTemplate: " + getId());
    
    // Marcar como inativa
    setActive(false);
    
    // Salvar estado se necessário
    saveScreenState();
}

void ScreenTemplate::update(JsonObject& data) {
    if (!isInitialized) {
        logger->warning("Cannot update uninitialized screen: " + getId());
        return;
    }
    
    logger->debug("Updating ScreenTemplate data: " + getId());
    
    // Processar atualizações de dados específicas
    if (data.containsKey("status")) {
        String newStatus = data["status"];
        updateStatus(newStatus);
    }
    
    if (data.containsKey("title")) {
        String newTitle = data["title"];
        setTitle(newTitle);
    }
    
    // Atualizar estado dos botões
    refreshButtonStates();
    
    // Forçar redesenho
    lv_obj_invalidate(container);
}

void ScreenTemplate::cleanup() {
    logger->info("Cleaning up ScreenTemplate: " + getId());
    
    // Limpar botões
    for (auto& button : buttons) {
        delete button;
    }
    buttons.clear();
    
    // Limpar objetos LVGL
    if (container) {
        lv_obj_del(container);
        container = nullptr;
    }
    
    // Reset flags
    isInitialized = false;
    setActive(false);
    
    logger->debug("ScreenTemplate cleanup completed");
}

bool ScreenTemplate::isActive() {
    return (container && lv_scr_act() == container);
}

String ScreenTemplate::getId() {
    return getScreenId();
}

// Métodos específicos da tela

void ScreenTemplate::setTitle(const String& title) {
    if (titleLabel) {
        lv_label_set_text(titleLabel, title.c_str());
        logger->debug("Title updated: " + title);
    }
}

void ScreenTemplate::updateStatus(const String& status, lv_color_t color) {
    if (statusLabel) {
        lv_label_set_text_fmt(statusLabel, "Status: %s", status.c_str());
        lv_obj_set_style_text_color(statusLabel, color, 0);
        logger->debug("Status updated: " + status);
    }
}

NavButton* ScreenTemplate::addCustomButton(JsonObject& buttonConfig) {
    if (!content) {
        logger->error("Cannot add button - content area not initialized");
        return nullptr;
    }
    
    String buttonType = buttonConfig["type"];
    NavButton* button = nullptr;
    
    if (buttonType == "relay") {
        button = ScreenFactory::createRelayItem(content, buttonConfig);
    } else if (buttonType == "action") {
        button = ScreenFactory::createActionItem(content, buttonConfig);
    } else if (buttonType == "navigation") {
        button = ScreenFactory::createNavigationItem(content, buttonConfig);
    }
    
    if (button) {
        buttons.push_back(button);
        logger->info("Custom button added: " + buttonConfig["id"].as<String>());
    }
    
    return button;
}

bool ScreenTemplate::processCommand(JsonObject& command) {
    String cmdType = command["type"];
    
    if (cmdType == "update_status") {
        String status = command["status"];
        updateStatus(status);
        return true;
    } else if (cmdType == "refresh") {
        updateDisplayData();
        return true;
    } else if (cmdType == "navigate") {
        String target = command["target"];
        // Implementar navegação
        return true;
    }
    
    logger->warning("Unknown command type: " + cmdType);
    return false;
}

// Event handlers estáticos

void ScreenTemplate::backButtonCallback(NavButton* button) {
    logger->info("Back button pressed");
    // Implementar navegação de volta
    // screenManager->navigateBack();
}

void ScreenTemplate::menuButtonCallback(NavButton* button) {
    logger->info("Menu button pressed");
    // Implementar ação de menu
    // screenManager->showMenu();
}

void ScreenTemplate::customButtonCallback(NavButton* button) {
    logger->info("Custom button pressed: " + button->getId());
    // Implementar ação customizada
}

// Métodos auxiliares privados

void ScreenTemplate::updateDisplayData() {
    // Implementar atualização de dados específica da tela
    logger->debug("Updating display data for: " + getId());
    
    // Exemplo: atualizar informações de sistema
    updateStatus("Updated at " + String(millis()));
}

void ScreenTemplate::refreshButtonStates() {
    // Atualizar estado de todos os botões
    for (auto& button : buttons) {
        // Implementar lógica específica de atualização
        button->updateStyle();
    }
}

void ScreenTemplate::handleGesture(lv_event_t* e) {
    lv_dir_t dir = lv_indev_get_gesture_dir(lv_indev_get_act());
    
    switch (dir) {
        case LV_DIR_LEFT:
            logger->debug("Gesture: swipe left");
            // Implementar ação para swipe left
            break;
        case LV_DIR_RIGHT:
            logger->debug("Gesture: swipe right");
            // Implementar ação para swipe right
            break;
        case LV_DIR_TOP:
            logger->debug("Gesture: swipe up");
            break;
        case LV_DIR_BOTTOM:
            logger->debug("Gesture: swipe down");
            break;
    }
}

void ScreenTemplate::handleKeyPress(lv_event_t* e) {
    uint32_t key = lv_event_get_key(e);
    logger->debug("Key pressed: " + String(key));
    
    // Implementar handling de teclas se necessário
}

void ScreenTemplate::saveScreenState() {
    // Implementar salvamento de estado da tela
    logger->debug("Saving screen state for: " + getId());
}