/**
 * @file IconManager.h
 * @brief Gerenciador de mapeamento de ícones para LVGL
 * 
 * Esta classe gerencia o mapeamento entre nomes de ícones e símbolos LVGL,
 * com suporte a fallbacks e carregamento automático da API.
 * 
 * @author Sistema AutoCore
 * @version 2.0.0
 * @date 2025-08-16
 */

#ifndef ICON_MANAGER_H
#define ICON_MANAGER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <map>
#include <vector>
#include <lvgl.h>

/**
 * @struct IconMapping
 * @brief Estrutura para armazenar mapeamento de um ícone
 */
struct IconMapping {
    String name;                // Nome do ícone (ex: "light", "power")
    String displayName;         // Nome para exibição (ex: "Luz", "Liga/Desliga")
    String category;            // Categoria (ex: "lighting", "control")
    String lvglSymbol;          // Símbolo LVGL (ex: "LV_SYMBOL_POWER")
    String unicodeChar;         // Caractere Unicode (ex: "\uf011")
    String emoji;               // Emoji fallback (ex: "💡")
    String fallbackIcon;        // Ícone fallback se outros falharem
    uint8_t id;                 // ID do ícone
    
    IconMapping() : id(0) {}
    
    IconMapping(uint8_t _id, const String& _name, const String& _displayName, 
                const String& _category, const String& _lvglSymbol, 
                const String& _unicodeChar, const String& _emoji, 
                const String& _fallbackIcon = "") 
        : id(_id), name(_name), displayName(_displayName), category(_category),
          lvglSymbol(_lvglSymbol), unicodeChar(_unicodeChar), emoji(_emoji),
          fallbackIcon(_fallbackIcon) {}
};

/**
 * @class IconManager
 * @brief Gerenciador de ícones com mapeamento LVGL e fallbacks
 * 
 * Funcionalidades:
 * - Carregamento automático de ícones da API
 * - Mapeamento de nomes para símbolos LVGL
 * - Sistema de fallback: LVGL → Unicode → Emoji → Fallback Icon
 * - Cache local para performance
 * - Ícones padrão para casos de falha
 */
class IconManager {
private:
    std::map<String, IconMapping> iconMappings;
    std::map<String, std::vector<String>> categorizedIcons;
    bool iconsLoaded;
    String lastError;
    
    /**
     * @brief Carrega ícones padrão (fallback se API falhar)
     */
    void loadDefaultIcons();
    
    /**
     * @brief Processa resposta da API de ícones
     * @param response JsonDocument com resposta da API
     * @return true se processamento bem-sucedido
     */
    bool processIconsResponse(const JsonDocument& response);
    
    /**
     * @brief Converte símbolo LVGL para caractere real
     * @param lvglSymbol String com símbolo LVGL (ex: "LV_SYMBOL_POWER")
     * @return Caractere Unicode correspondente
     */
    String convertLvglSymbol(const String& lvglSymbol);

public:
    /**
     * @brief Construtor da classe
     */
    IconManager();
    
    /**
     * @brief Destructor da classe
     */
    ~IconManager();
    
    /**
     * @brief Carrega ícones da API
     * @param apiClient Ponteiro para cliente API
     * @return true se carregamento bem-sucedido
     */
    bool loadFromApi(class ScreenApiClient* apiClient);
    
    /**
     * @brief Carrega ícones de configuração JSON
     * @param iconsConfig JsonObject com configuração de ícones
     * @return true se carregamento bem-sucedido
     */
    bool loadFromConfig(const JsonObject& iconsConfig);
    
    /**
     * @brief Obtém símbolo para exibição por nome do ícone
     * @param iconName Nome do ícone
     * @param preferLvgl Preferir símbolo LVGL se disponível
     * @return String com símbolo para exibição
     */
    String getIconSymbol(const String& iconName, bool preferLvgl = true);
    
    /**
     * @brief Obtém informações completas de um ícone
     * @param iconName Nome do ícone
     * @return IconMapping com informações completas (vazio se não encontrado)
     */
    IconMapping getIconMapping(const String& iconName);
    
    /**
     * @brief Verifica se um ícone existe
     * @param iconName Nome do ícone
     * @return true se ícone existe
     */
    bool hasIcon(const String& iconName);
    
    /**
     * @brief Obtém lista de ícones por categoria
     * @param category Categoria dos ícones
     * @return Vector com nomes dos ícones da categoria
     */
    std::vector<String> getIconsByCategory(const String& category);
    
    /**
     * @brief Obtém todas as categorias disponíveis
     * @return Vector com nomes das categorias
     */
    std::vector<String> getCategories();
    
    /**
     * @brief Limpa cache de ícones
     */
    void clearCache();
    
    /**
     * @brief Retorna último erro ocorrido
     * @return String com descrição do erro
     */
    String getLastError() const { return lastError; }
    
    /**
     * @brief Verifica se ícones foram carregados
     * @return true se ícones estão carregados
     */
    bool isLoaded() const { return iconsLoaded; }
    
    /**
     * @brief Obtém número de ícones carregados
     * @return Número de ícones disponíveis
     */
    size_t getIconCount() const { return iconMappings.size(); }
    
    /**
     * @brief Cria símbolo composto para botões (ícone + texto)
     * @param iconName Nome do ícone
     * @param text Texto do botão
     * @param iconFirst Se true, ícone vem antes do texto
     * @return String formatada para LVGL
     */
    String createButtonSymbol(const String& iconName, const String& text, bool iconFirst = true);
    
    /**
     * @brief Obtém cor sugerida para um ícone por categoria
     * @param iconName Nome do ícone
     * @return Código de cor em formato hex (ex: "#FF0000")
     */
    String getSuggestedColor(const String& iconName);
};

#endif // ICON_MANAGER_H