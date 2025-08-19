#include "ScreenBase.h"
#include "Layout.h"
#include "ui/Theme.h"
#include "core/Logger.h"
#include "ui/ScreenManager.h"

extern Logger* logger;
extern ScreenManager* screenManager;

// Array de cores para bordas de debug de containers principais
lv_color_t MAIN_CONTAINER_DEBUG_COLORS[] = {
    lv_color_make(255, 255, 255),  // BRANCO - Container Principal/Root (4px)
    lv_color_make(255, 255, 0),    // AMARELO - Header
    lv_color_make(0, 255, 128),    // VERDE CLARO - Content Area
    lv_color_make(128, 255, 255),  // AZUL CLARO - Navigation Bar
    lv_color_make(255, 128, 0),    // LARANJA - Grid Container
    lv_color_make(255, 128, 255),  // ROSA CLARO - Icons Container
};

const char* MAIN_CONTAINER_COLOR_NAMES[] = {
    "BRANCO", "AMARELO", "VERDE_CLARO", "AZUL_CLARO", "LARANJA", "ROSA_CLARO"
};

enum MainContainerColorIndex {
    COLOR_IDX_ROOT = 0,          // BRANCO (4px)
    COLOR_IDX_HEADER = 1,        // AMARELO
    COLOR_IDX_CONTENT = 2,       // VERDE CLARO
    COLOR_IDX_NAVBAR = 3,        // AZUL CLARO
    COLOR_IDX_GRID = 4,          // LARANJA
    COLOR_IDX_ICONS = 5          // ROSA CLARO
};

/**
 * Aplica borda colorida para debug/identificação visual de containers principais
 * @param obj Objeto LVGL para aplicar a borda
 * @param colorIndex Índice da cor no array de cores
 * @param borderWidth Largura da borda (padrão 3px)
 * @param containerType Tipo do container para logs
 */
void applyMainContainerDebugBorder(lv_obj_t* obj, MainContainerColorIndex colorIndex, int borderWidth, const String& containerType) {
    if (!obj) return;
    
    // Aplicar borda colorida para debug
    lv_obj_set_style_border_width(obj, borderWidth, 0);
    lv_obj_set_style_border_color(obj, MAIN_CONTAINER_DEBUG_COLORS[colorIndex], 0);
    lv_obj_set_style_border_opa(obj, LV_OPA_100, 0);  // Opacidade total
    
    // Log informativo com tamanho do container
    if (logger) {
        // CORREÇÃO: Forçar atualização de layout antes de obter tamanhos
        lv_obj_update_layout(obj);
        lv_coord_t width = lv_obj_get_width(obj);
        lv_coord_t height = lv_obj_get_height(obj);
        logger->info("[MAIN CONTAINER DEBUG] " + containerType + ": Borda " + String(MAIN_CONTAINER_COLOR_NAMES[colorIndex]) + 
                    " (" + String(width) + "x" + String(height) + ")");
    }
}

ScreenBase::ScreenBase() : header(nullptr), content(nullptr), navBar(nullptr) {
    screen = lv_obj_create(NULL);
    createLayout();
}

ScreenBase::~ScreenBase() {
    delete header;
    delete content;
    delete navBar;
    
    if (screen) {
        lv_obj_del(screen);
    }
}

void ScreenBase::createLayout() {
    // Configurar tela base
    lv_obj_set_style_bg_color(screen, COLOR_BACKGROUND, 0);
    
    // ADIÇÃO DEBUG: Aplicar borda BRANCA no container principal/root (4px)
    applyMainContainerDebugBorder(screen, COLOR_IDX_ROOT, 4, "Container Principal/Root");
    
    // Criar header
    header = new Header(screen);
    
    // ADIÇÃO DEBUG: Aplicar borda AMARELA no header
    if (header && header->getObject()) {
        applyMainContainerDebugBorder(header->getObject(), COLOR_IDX_HEADER, 3, "Header Container");
    }
    
    // Criar área de conteúdo com GridContainer configurado para 3x2
    content = new GridContainer(screen);
    // CORREÇÃO: Content area deve ocupar TODA a largura e altura disponível
    content->setSize(Layout::DISPLAY_WIDTH, Layout::CONTENT_HEIGHT);
    content->setPosition(0, Layout::HEADER_HEIGHT);
    // Reduzir margins internas do content container
    content->setMargins(2); // Margem mínima de 2px
    
    // ADIÇÃO DEBUG: Aplicar borda VERDE CLARO no content area
    if (content && content->getObject()) {
        applyMainContainerDebugBorder(content->getObject(), COLOR_IDX_CONTENT, 3, "Content Area Container");
    }
    
    // Configurar grid para 3x2 explicitamente
    content->setGridSize(3, 2);
    content->setAdaptive(true); // Usar modo adaptativo por padrão
    
    if (logger) {
        logger->info("[ScreenBase] Created GridContainer with size " + 
                    String(Layout::DISPLAY_WIDTH) + "x" + String(Layout::CONTENT_HEIGHT) + 
                    " at position (0," + String(Layout::HEADER_HEIGHT) + ")");
    }
    
    // Criar barra de navegação
    navBar = new NavigationBar(screen);
    navBar->setNavigationCallback([this](NavigationDirection dir) {
        onNavigate(dir);
    });
    
    // ADIÇÃO DEBUG: Aplicar borda AZUL CLARO no navigation bar
    if (navBar && navBar->getObject()) {
        applyMainContainerDebugBorder(navBar->getObject(), COLOR_IDX_NAVBAR, 3, "Navigation Bar Container");
    }
}

void ScreenBase::build() {
    // Implementação padrão vazia - sobrescrever nas classes derivadas
}

void ScreenBase::onNavigate(NavigationDirection dir) {
    switch(dir) {
        case NAV_PREV:
            if (navState.currentPage > 0) {
                navState.currentPage--;
                rebuildContent();
                updateNavigationButtons();
            }
            break;
            
        case NAV_HOME:
            if (!navState.isHome) {
                extern ScreenManager* screenManager;
                if (screenManager) {
                    screenManager->navigateHome();
                }
            }
            break;
            
        case NAV_NEXT:
            if (navState.currentPage < navState.totalPages - 1) {
                navState.currentPage++;
                rebuildContent();
                updateNavigationButtons();
            }
            break;
    }
}

void ScreenBase::onSelect() {
    // Implementação padrão vazia - sobrescrever nas classes derivadas
}

void ScreenBase::updateNavigationButtons() {
    // Atualizar estado dos botões baseado na navegação
    navBar->setPrevEnabled(navState.currentPage > 0);
    navBar->setHomeEnabled(!navState.isHome);
    navBar->setNextEnabled(navState.currentPage < navState.totalPages - 1);
}

void ScreenBase::rebuildContent() {
    // Implementação padrão: reconstruir tudo
    // Telas específicas podem sobrescrever para otimizar
    build();
}