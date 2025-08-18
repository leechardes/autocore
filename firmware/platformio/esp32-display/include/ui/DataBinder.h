/**
 * @file DataBinder.h
 * @brief Sistema de binding de dados para widgets LVGL dinâmicos
 */

#ifndef DATA_BINDER_H
#define DATA_BINDER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <lvgl.h>
#include <vector>
#include "NavButton.h"

/**
 * @brief Estrutura para armazenar binding de widgets com dados
 */
struct BoundWidget {
    lv_obj_t* widget;               // Widget LVGL principal
    NavButton* navButton;           // NavButton wrapper
    String dataSource;              // Fonte dos dados (can_signal, telemetry, etc)
    String dataPath;                // Caminho específico do dado
    String dataUnit;                // Unidade de medida
    JsonObject config;              // Configuração original do item
    float lastValue;                // Último valor aplicado
    unsigned long lastUpdate;       // Timestamp da última atualização
    unsigned long refreshInterval;  // Intervalo de refresh em ms
};

/**
 * @brief Gerenciador de binding de dados para widgets dinâmicos
 */
class DataBinder {
private:
    std::vector<BoundWidget> boundWidgets;
    unsigned long lastGlobalUpdate = 0;
    static const unsigned long GLOBAL_UPDATE_INTERVAL = 500; // 500ms entre atualizações globais
    
    // Intervalos por tipo de dado (ms)
    static const unsigned long REFRESH_CRITICAL = 500;   // Dados críticos (temp, pressure)
    static const unsigned long REFRESH_NORMAL = 1000;    // Dados normais (RPM, speed)
    static const unsigned long REFRESH_INFO = 2000;      // Dados informativos (fuel, voltage)
    
    /**
     * @brief Atualiza um widget específico com novo valor
     */
    void updateWidget(BoundWidget& binding);
    
    /**
     * @brief Obtém valor atual do dado especificado
     * @param source Fonte do dado
     * @param path Caminho do dado
     * @return Valor float atual (ou simulado)
     */
    float getDataValue(const String& source, const String& path);
    
    /**
     * @brief Determina intervalo de refresh baseado no tipo de dado
     */
    unsigned long getRefreshInterval(const String& dataPath);
    
    /**
     * @brief Aplica cores dinâmicas baseadas no valor e thresholds
     */
    void applyConditionalColors(BoundWidget& binding, float value);
    
    /**
     * @brief Atualiza widget do tipo display com novo valor
     */
    void updateDisplayWidget(BoundWidget& binding, float value);
    
    /**
     * @brief Atualiza widget do tipo gauge com novo valor
     */
    void updateGaugeWidget(BoundWidget& binding, float value);
    
    /**
     * @brief Aplica cores na barra de progresso baseadas em thresholds
     */
    void applyBarColors(BoundWidget& binding, lv_obj_t* bar, float value);

public:
    DataBinder() = default;
    ~DataBinder() = default;
    
    /**
     * @brief Registra widget para receber atualizações de dados
     * @param widget Widget LVGL principal
     * @param navBtn NavButton wrapper
     * @param config Configuração JSON do item
     */
    void bindWidget(lv_obj_t* widget, NavButton* navBtn, JsonObject& config);
    
    /**
     * @brief Atualiza todos os widgets registrados (chamado no loop principal)
     */
    void updateAll();
    
    /**
     * @brief Força atualização imediata de todos os widgets
     */
    void forceUpdateAll();
    
    /**
     * @brief Remove widget do sistema de binding
     * @param navBtn NavButton a ser removido
     */
    void unbindWidget(NavButton* navBtn);
    
    /**
     * @brief Limpa todos os bindings
     */
    void clear();
    
    /**
     * @brief Retorna número de widgets atualmente registrados
     */
    size_t getWidgetCount() const { return boundWidgets.size(); }
};

#endif // DATA_BINDER_H