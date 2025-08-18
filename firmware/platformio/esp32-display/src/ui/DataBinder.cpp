/**
 * @file DataBinder.cpp
 * @brief Implementação do sistema de binding de dados
 */

#include "ui/DataBinder.h"
#include "ui/ScreenFactory.h"
#include "ui/Theme.h"
#include "core/Logger.h"
#include <algorithm>

extern Logger* logger;

void DataBinder::bindWidget(lv_obj_t* widget, NavButton* navBtn, JsonObject& config) {
    if (!widget || !navBtn) {
        if (logger) {
            logger->warning("DataBinder: Cannot bind null widget or NavButton");
        }
        return;
    }
    
    String dataSource = config["data_source"].as<String>();
    String dataPath = config["data_path"].as<String>();
    
    // Apenas registrar widgets que têm data_source válido
    if (dataSource.isEmpty() || dataPath.isEmpty()) {
        return;
    }
    
    BoundWidget binding;
    binding.widget = widget;
    binding.navButton = navBtn;
    binding.dataSource = dataSource;
    binding.dataPath = dataPath;
    binding.dataUnit = config["data_unit"].as<String>();
    binding.config = config;
    binding.lastValue = 0.0f;
    binding.lastUpdate = 0;
    binding.refreshInterval = getRefreshInterval(dataPath);
    
    boundWidgets.push_back(binding);
    
    if (logger) {
        logger->debug("DataBinder: Registered widget for " + dataSource + ":" + dataPath + 
                     " (refresh: " + String(binding.refreshInterval) + "ms)");
    }
}

void DataBinder::updateAll() {
    unsigned long now = millis();
    
    // Controle global de atualizações para evitar sobrecarga
    if (now - lastGlobalUpdate < GLOBAL_UPDATE_INTERVAL) {
        return;
    }
    
    lastGlobalUpdate = now;
    
    // Atualizar cada widget individualmente baseado no seu intervalo
    for (auto& binding : boundWidgets) {
        if (now - binding.lastUpdate >= binding.refreshInterval) {
            updateWidget(binding);
            binding.lastUpdate = now;
        }
    }
}

void DataBinder::forceUpdateAll() {
    for (auto& binding : boundWidgets) {
        updateWidget(binding);
        binding.lastUpdate = millis();
    }
}

void DataBinder::updateWidget(BoundWidget& binding) {
    float newValue = getDataValue(binding.dataSource, binding.dataPath);
    
    // Skip update se valor não mudou significativamente (otimização)
    if (abs(newValue - binding.lastValue) < 0.1f) {
        return;
    }
    
    binding.lastValue = newValue;
    
    // Atualizar baseado no tipo de widget
    NavButton::ButtonType buttonType = binding.navButton->getButtonType();
    
    if (buttonType == NavButton::TYPE_DISPLAY) {
        updateDisplayWidget(binding, newValue);
    } else if (buttonType == NavButton::TYPE_GAUGE) {
        updateGaugeWidget(binding, newValue);
    }
}

void DataBinder::updateDisplayWidget(BoundWidget& binding, float value) {
    // Buscar label de valor no NavButton
    lv_obj_t* valueLabel = binding.navButton->getValueLabel();
    
    if (!valueLabel) {
        // Tentar encontrar automaticamente o label de valor
        // Isso é um fallback para widgets criados antes da implementação completa
        return;
    }
    
    // Formatar valor usando o sistema do ScreenFactory
    String formattedValue = ScreenFactory::formatDisplayValue(value, binding.config);
    lv_label_set_text(valueLabel, formattedValue.c_str());
    
    // Aplicar cores condicionais
    applyConditionalColors(binding, value);
}

void DataBinder::updateGaugeWidget(BoundWidget& binding, float value) {
    lv_obj_t* container = binding.widget;
    
    if (!container) return;
    
    // Para gauge circular: buscar meter widget e atualizar needle
    lv_obj_t* meter = lv_obj_get_child(container, 0); // Primeiro child é o meter
    
    if (meter && lv_obj_check_type(meter, &lv_meter_class)) {
        // Atualizar ponteiro
        lv_meter_indicator_t* needle = (lv_meter_indicator_t*)lv_obj_get_user_data(meter);
        if (needle) {
            lv_meter_set_indicator_value(meter, needle, value);
        }
        
        // Atualizar label de valor (buscar label no container)
        for (int i = 0; i < lv_obj_get_child_cnt(container); i++) {
            lv_obj_t* child = lv_obj_get_child(container, i);
            if (lv_obj_check_type(child, &lv_label_class)) {
                // Verificar se é o label de valor (não título ou ícone)
                const char* text = lv_label_get_text(child);
                if (text && (isdigit(text[0]) || text[0] == '-')) {
                    String formattedValue = ScreenFactory::formatDisplayValue(value, binding.config);
                    lv_label_set_text(child, formattedValue.c_str());
                    break;
                }
            }
        }
    } else {
        // Para gauge linear: buscar barra e atualizar valor
        lv_obj_t* bar = (lv_obj_t*)lv_obj_get_user_data(container);
        if (bar && lv_obj_check_type(bar, &lv_bar_class)) {
            lv_bar_set_value(bar, value, LV_ANIM_ON);
            
            // Atualizar cores da barra baseadas em thresholds
            applyBarColors(binding, bar, value);
            
            // Atualizar label de valor
            for (int i = 0; i < lv_obj_get_child_cnt(container); i++) {
                lv_obj_t* child = lv_obj_get_child(container, i);
                if (lv_obj_check_type(child, &lv_label_class)) {
                    const char* text = lv_label_get_text(child);
                    if (text && (isdigit(text[0]) || text[0] == '-')) {
                        String formattedValue = ScreenFactory::formatDisplayValue(value, binding.config);
                        lv_label_set_text(child, formattedValue.c_str());
                        break;
                    }
                }
            }
        }
    }
}

void DataBinder::applyConditionalColors(BoundWidget& binding, float value) {
    String dataPath = binding.dataPath;
    lv_obj_t* valueLabel = binding.navButton->getValueLabel();
    
    if (!valueLabel) return;
    
    lv_color_t color = COLOR_TEXT_OFF; // Padrão
    
    // Lógica específica por tipo de dado
    if (dataPath == "coolant_temp" || dataPath == "engine_temp") {
        if (value > 90) color = COLOR_GAUGE_CRITICAL;      // Vermelho - muito quente
        else if (value > 80) color = COLOR_GAUGE_WARNING;  // Laranja - quente
        else color = COLOR_GAUGE_NORMAL;                   // Verde - normal
    } else if (dataPath == "fuel_level") {
        if (value < 20) color = COLOR_GAUGE_WARNING;       // Laranja - combustível baixo
        else color = COLOR_GAUGE_NORMAL;                   // Verde - OK
    } else if (dataPath == "engine_rpm") {
        if (value > 4000) color = COLOR_GAUGE_WARNING;     // Laranja - RPM alto
        else if (value > 5000) color = COLOR_GAUGE_CRITICAL; // Vermelho - RPM muito alto
        else color = COLOR_GAUGE_NORMAL;                   // Verde - normal
    } else if (dataPath == "oil_pressure") {
        if (value < 10) color = COLOR_GAUGE_CRITICAL;      // Vermelho - pressão baixa
        else if (value < 20) color = COLOR_GAUGE_WARNING;  // Laranja - pressão baixa
        else color = COLOR_GAUGE_NORMAL;                   // Verde - normal
    }
    
    lv_obj_set_style_text_color(valueLabel, color, 0);
}

void DataBinder::applyBarColors(BoundWidget& binding, lv_obj_t* bar, float value) {
    // Parse thresholds do action_payload
    float maxValue = ScreenFactory::parseActionPayload(binding.config, "max_value", 100);
    float warningThreshold = ScreenFactory::parseActionPayload(binding.config, "warning_threshold", maxValue * 0.8f);
    float criticalThreshold = ScreenFactory::parseActionPayload(binding.config, "critical_threshold", maxValue * 0.95f);
    
    lv_color_t barColor = COLOR_GAUGE_NORMAL;
    
    if (value >= criticalThreshold) {
        barColor = COLOR_GAUGE_CRITICAL;
    } else if (value >= warningThreshold) {
        barColor = COLOR_GAUGE_WARNING;
    }
    
    lv_obj_set_style_bg_color(bar, barColor, LV_PART_INDICATOR);
}

float DataBinder::getDataValue(const String& source, const String& path) {
    // TODO: Integrar com sistema MQTT real para obter dados reais
    // Por enquanto, gerar valores simulados realistas para demonstração
    
    if (source == "can_signal") {
        if (path == "engine_rpm") {
            // Simular RPM do motor (800-5500 RPM)
            static float rpmBase = 800;
            rpmBase += random(-50, 50);
            if (rpmBase < 800) rpmBase = 800;
            if (rpmBase > 5500) rpmBase = 5500;
            return rpmBase;
        }
        else if (path == "coolant_temp" || path == "engine_temp") {
            // Simular temperatura do motor (70-95°C)
            static float tempBase = 82;
            tempBase += random(-1, 2) * 0.5f;
            if (tempBase < 70) tempBase = 70;
            if (tempBase > 95) tempBase = 95;
            return tempBase;
        }
        else if (path == "fuel_level") {
            // Simular nível de combustível (diminuindo lentamente)
            static float fuelLevel = 85;
            fuelLevel -= 0.01f; // Diminui 0.01% por ciclo
            if (fuelLevel < 0) fuelLevel = 100; // Reset quando esvaziar
            return fuelLevel;
        }
        else if (path == "oil_pressure") {
            // Simular pressão do óleo (15-45 PSI)
            static float pressureBase = 30;
            pressureBase += random(-2, 2);
            if (pressureBase < 15) pressureBase = 15;
            if (pressureBase > 45) pressureBase = 45;
            return pressureBase;
        }
        else if (path == "battery_voltage") {
            // Simular voltagem da bateria (11.8-14.4V)
            static float voltageBase = 12.6f;
            voltageBase += random(-10, 10) * 0.01f;
            if (voltageBase < 11.8f) voltageBase = 11.8f;
            if (voltageBase > 14.4f) voltageBase = 14.4f;
            return voltageBase;
        }
    }
    else if (source == "telemetry") {
        if (path == "speed") {
            // Simular velocidade (0-120 km/h)
            static float speedBase = 45;
            speedBase += random(-5, 5);
            if (speedBase < 0) speedBase = 0;
            if (speedBase > 120) speedBase = 120;
            return speedBase;
        }
    }
    
    // Fallback: valor aleatório entre 0-100
    return random(0, 100);
}

unsigned long DataBinder::getRefreshInterval(const String& dataPath) {
    // Dados críticos - refresh mais rápido
    if (dataPath == "coolant_temp" || dataPath == "engine_temp" || 
        dataPath == "oil_pressure" || dataPath == "brake_pressure") {
        return REFRESH_CRITICAL;
    }
    
    // Dados informativos - refresh mais lento
    if (dataPath == "fuel_level" || dataPath == "battery_voltage") {
        return REFRESH_INFO;
    }
    
    // Dados normais - refresh padrão
    return REFRESH_NORMAL;
}

void DataBinder::unbindWidget(NavButton* navBtn) {
    auto it = std::remove_if(boundWidgets.begin(), boundWidgets.end(),
        [navBtn](const BoundWidget& binding) {
            return binding.navButton == navBtn;
        });
    
    if (it != boundWidgets.end()) {
        boundWidgets.erase(it, boundWidgets.end());
        if (logger) {
            logger->debug("DataBinder: Unbound widget");
        }
    }
}

void DataBinder::clear() {
    boundWidgets.clear();
    if (logger) {
        logger->debug("DataBinder: Cleared all bindings");
    }
}