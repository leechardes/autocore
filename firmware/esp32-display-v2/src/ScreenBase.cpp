#include "ScreenBase.h"
#include "Layout.h"
#include "ui/Theme.h"
#include "core/Logger.h"
#include "ui/ScreenManager.h"

extern Logger* logger;
extern ScreenManager* screenManager;

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
    
    // Criar header
    header = new Header(screen);
    
    // Criar área de conteúdo
    content = new GridContainer(screen);
    content->setSize(Layout::DISPLAY_WIDTH, Layout::CONTENT_HEIGHT);
    content->setPosition(0, Layout::HEADER_HEIGHT);
    
    // Criar barra de navegação
    navBar = new NavigationBar(screen);
    navBar->setNavigationCallback([this](NavigationDirection dir) {
        onNavigate(dir);
    });
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