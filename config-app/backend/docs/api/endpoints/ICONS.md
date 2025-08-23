# Endpoints - Ícones

Sistema de mapeamento e distribuição de ícones para diferentes plataformas e dispositivos.

## 📋 Visão Geral

Os endpoints de ícones permitem:
- Obter mapeamento de ícones otimizado por plataforma
- Buscar detalhes específicos de ícones individuais
- Suporte multi-plataforma (ESP32, Web, Mobile)
- Fallbacks automáticos para compatibilidade

## 🎨 Endpoints de Ícones

### `GET /api/icons`

Retorna mapeamento de ícones otimizado para a plataforma especificada.

**Parâmetros de Query:**
- `platform` (string, opcional): Plataforma alvo (`esp32`, `web`, `mobile`) - padrão: `esp32`

**Resposta para ESP32:**
```json
{
  "version": "1.0.0",
  "platform": "esp32",
  "icons": {
    "home": {
      "id": 1,
      "display_name": "Casa",
      "category": "navigation",
      "lvgl_symbol": "LV_SYMBOL_HOME",
      "unicode_char": "\uf015",
      "emoji": "🏠",
      "fallback": "house"
    },
    "lightbulb": {
      "id": 2,
      "display_name": "Lâmpada",
      "category": "lighting",
      "lvgl_symbol": "LV_SYMBOL_LIGHT",
      "unicode_char": "\uf0eb",
      "emoji": "💡",
      "fallback": "power"
    },
    "garage": {
      "id": 3,
      "display_name": "Garagem",
      "category": "building",
      "lvgl_symbol": "LV_SYMBOL_GARAGE",
      "unicode_char": "\uf1de",
      "emoji": "🏠",
      "fallback": "home"
    },
    "thermometer": {
      "id": 4,
      "display_name": "Termômetro",
      "category": "sensor",
      "lvgl_symbol": "LV_SYMBOL_TEMP",
      "unicode_char": "\uf2c9",
      "emoji": "🌡️",
      "fallback": "gauge"
    }
  }
}
```

**Resposta para Web:**
```json
{
  "version": "1.0.0",
  "platform": "web",
  "icons": {
    "home": {
      "id": 1,
      "display_name": "Casa",
      "lucide_name": "home",
      "material_name": "home",
      "fontawesome_name": "fa-home",
      "svg_content": null
    },
    "lightbulb": {
      "id": 2,
      "display_name": "Lâmpada",
      "lucide_name": "lightbulb",
      "material_name": "lightbulb_outline",
      "fontawesome_name": "fa-lightbulb",
      "svg_content": null
    },
    "custom_icon": {
      "id": 15,
      "display_name": "Ícone Personalizado",
      "lucide_name": null,
      "material_name": null,
      "fontawesome_name": null,
      "svg_content": "<svg viewBox=\"0 0 24 24\">...</svg>"
    }
  }
}
```

**Códigos de Status:**
- `200` - Mapeamento retornado com sucesso
- `400` - Plataforma inválida
- `500` - Erro interno do servidor

---

### `GET /api/icons/{icon_name}`

Busca detalhes completos de um ícone específico pelo nome.

**Parâmetros de Path:**
- `icon_name` (string): Nome único do ícone

**Resposta:**
```json
{
  "id": 2,
  "name": "lightbulb",
  "display_name": "Lâmpada",
  "category": "lighting",
  "svg_content": "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\"><path d=\"M9 18h6\"/><path d=\"M10 22h4\"/><path d=\"M12 2a6 6 0 0 1 6 6c0 2-1 3.5-1 3.5s.5.5.5 2.5a1.5 1.5 0 0 1-1.5 1.5h-8A1.5 1.5 0 0 1 7 14c0-2 .5-2.5.5-2.5S6 10 6 8a6 6 0 0 1 6-6Z\"/></svg>",
  "svg_viewbox": "0 0 24 24",
  "lucide_name": "lightbulb",
  "material_name": "lightbulb_outline",
  "fontawesome_name": "fa-lightbulb",
  "lvgl_symbol": "LV_SYMBOL_LIGHT",
  "unicode_char": "\\uf0eb",
  "emoji": "💡",
  "fallback": "power",
  "is_custom": false,
  "description": "Ícone de lâmpada para controles de iluminação",
  "tags": ["light", "lamp", "bulb", "illumination"]
}
```

**Códigos de Status:**
- `200` - Ícone encontrado
- `404` - Ícone não encontrado
- `500` - Erro interno do servidor

## 🎯 Categorias de Ícones

### Navigation (`navigation`)
Ícones para navegação e localização:
- `home` - Casa/início
- `back` - Voltar
- `forward` - Avançar
- `up` - Para cima
- `down` - Para baixo
- `menu` - Menu
- `close` - Fechar

### Lighting (`lighting`)
Ícones para controle de iluminação:
- `lightbulb` - Lâmpada comum
- `lightbulb-on` - Lâmpada acesa
- `lightbulb-off` - Lâmpada apagada
- `sun` - Luz solar/clara
- `moon` - Luz noturna/escura
- `flashlight` - Lanterna

### Climate (`climate`)
Ícones para controle climático:
- `thermometer` - Termômetro
- `temperature-hot` - Quente
- `temperature-cold` - Frio
- `fan` - Ventilador
- `air-conditioning` - Ar condicionado
- `heater` - Aquecedor

### Security (`security`)
Ícones de segurança:
- `lock` - Trancado
- `unlock` - Destrancado
- `key` - Chave
- `shield` - Proteção
- `camera` - Câmera
- `alarm` - Alarme

### Automotive (`automotive`)
Ícones específicos automotivos:
- `car` - Carro
- `engine` - Motor
- `fuel` - Combustível
- `oil` - Óleo
- `battery` - Bateria
- `tire` - Pneu
- `speedometer` - Velocímetro

### Controls (`controls`)
Ícones de controle:
- `power` - Ligar/desligar
- `play` - Reproduzir
- `pause` - Pausar
- `stop` - Parar
- `volume-up` - Volume alto
- `volume-down` - Volume baixo
- `settings` - Configurações

### Status (`status`)
Ícones de status:
- `check` - Confirmado/OK
- `alert-triangle` - Atenção
- `alert-circle` - Alerta
- `info` - Informação
- `help` - Ajuda
- `error` - Erro

## 🔧 Plataformas Suportadas

### ESP32 (LVGL)
```json
{
  "platform": "esp32",
  "icon_system": "LVGL Symbols",
  "format": "unicode_char",
  "fallback_strategy": "emoji_then_symbol",
  "max_icons": 256,
  "memory_usage": "low"
}
```

### Web (Lucide/Material/FontAwesome)
```json
{
  "platform": "web",
  "icon_systems": ["lucide", "material", "fontawesome", "custom_svg"],
  "format": "svg_or_font",
  "fallback_strategy": "svg_then_font",
  "max_icons": "unlimited",
  "memory_usage": "moderate"
}
```

### Mobile (Native)
```json
{
  "platform": "mobile",
  "icon_systems": ["system_native", "material", "ionicons"],
  "format": "vector_or_bitmap",
  "fallback_strategy": "system_then_material",
  "max_icons": "unlimited",
  "memory_usage": "optimized"
}
```

## 📱 Uso por Dispositivo

### ESP32 Display
```cpp
// ESP32 - Usar símbolos LVGL
void createButton(const char* icon_name) {
    // Buscar símbolo LVGL
    String lvgl_symbol = getIconSymbol(icon_name);
    
    // Criar botão com símbolo
    lv_obj_t* btn = lv_btn_create(parent, NULL);
    lv_obj_t* label = lv_label_create(btn, NULL);
    lv_label_set_text(label, lvgl_symbol.c_str());
}

// Fallback para emoji se símbolo não disponível
String getIconSymbol(String icon_name) {
    auto icon = icons_map.find(icon_name);
    if (icon != icons_map.end()) {
        if (!icon->second.lvgl_symbol.empty()) {
            return icon->second.lvgl_symbol;
        } else if (!icon->second.emoji.empty()) {
            return icon->second.emoji;
        }
    }
    return "?"; // Fallback final
}
```

### Interface Web
```javascript
// Web - Usar Lucide Icons
function createIcon(iconName, size = 24) {
    const iconData = getIconData(iconName);
    
    if (iconData.svg_content) {
        // Usar SVG customizado
        return createSVGIcon(iconData.svg_content, size);
    } else if (iconData.lucide_name) {
        // Usar Lucide
        return `<i class="lucide-${iconData.lucide_name}" style="width:${size}px;height:${size}px"></i>`;
    } else if (iconData.material_name) {
        // Fallback para Material Icons
        return `<i class="material-icons" style="font-size:${size}px">${iconData.material_name}</i>`;
    }
    
    // Fallback final - emoji
    return `<span style="font-size:${size}px">${iconData.emoji || '❓'}</span>`;
}
```

### Mobile App
```dart
// Flutter - Usar ícones apropriados
Widget buildIcon(String iconName, {double size = 24}) {
  final iconData = getIconData(iconName);
  
  // Preferir ícones Material
  if (iconData.materialName != null) {
    return Icon(
      getMaterialIcon(iconData.materialName),
      size: size,
    );
  }
  
  // Fallback para emoji
  return Text(
    iconData.emoji ?? '❓',
    style: TextStyle(fontSize: size),
  );
}
```

## 🔄 Sistema de Fallback

### Ordem de Prioridade (ESP32)
1. **LVGL Symbol** - Melhor performance
2. **Unicode Character** - Compatibilidade
3. **Emoji** - Fallback visual
4. **Texto** - Último recurso

### Ordem de Prioridade (Web)
1. **Custom SVG** - Máxima personalização
2. **Lucide Icon** - Padrão moderno
3. **Material Icon** - Compatibilidade
4. **FontAwesome** - Ampla cobertura
5. **Emoji** - Fallback universal

### Ordem de Prioridade (Mobile)
1. **System Native** - Consistência com OS
2. **Material Icons** - Padrão Android
3. **Ionicons** - Padrão iOS
4. **Emoji** - Fallback universal

## 🎨 Ícones Customizados

### Criar Ícone SVG
```json
{
  "name": "custom_logo",
  "display_name": "Logo Customizado",
  "category": "branding",
  "is_custom": true,
  "svg_content": "<svg viewBox=\"0 0 100 100\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"#1976D2\"/><text x=\"50\" y=\"55\" text-anchor=\"middle\" fill=\"white\" font-size=\"20\">AC</text></svg>",
  "svg_viewbox": "0 0 100 100",
  "description": "Logo personalizado do AutoCore",
  "tags": ["logo", "brand", "autocore"]
}
```

### Otimização para ESP32
```cpp
// ESP32 - Converter SVG para bitmap se necessário
void loadCustomIcon(String svg_content) {
    // Para ícones muito complexos, converter para bitmap
    if (svg_complexity(svg_content) > MAX_COMPLEXITY) {
        auto bitmap = svg_to_bitmap(svg_content, 32, 32);
        store_bitmap_in_flash(bitmap);
    } else {
        // Usar símbolo unicode simples
        store_unicode_fallback(svg_content);
    }
}
```

## 📊 Casos de Uso

### Interface Dinâmica
```javascript
// Frontend - Construir interface baseada em configuração
function buildScreenFromConfig(screenConfig) {
    const container = document.createElement('div');
    
    screenConfig.items.forEach(item => {
        const element = document.createElement('button');
        
        // Adicionar ícone baseado na configuração
        const icon = createIcon(item.icon, 24);
        element.innerHTML = `${icon} ${item.label}`;
        
        container.appendChild(element);
    });
    
    return container;
}
```

### Validação de Ícones
```python
# Backend - Validar se ícones existem
def validate_screen_icons(screen_data):
    errors = []
    
    for item in screen_data.get('items', []):
        icon_name = item.get('icon')
        if icon_name and not icons.icon_exists(icon_name):
            errors.append(f"Ícone '{icon_name}' não encontrado para item '{item.get('name')}'")
    
    return errors
```

### Cache de Ícones
```javascript
// Frontend - Cache inteligente de ícones
class IconCache {
    constructor() {
        this.cache = new Map();
        this.loadIconSet();
    }
    
    async loadIconSet(platform = 'web') {
        const response = await fetch(`/api/icons?platform=${platform}`);
        const iconSet = await response.json();
        
        // Cache do mapeamento completo
        this.cache.set('iconSet', iconSet);
        
        // Pre-load ícones mais usados
        this.preloadCommonIcons(iconSet.icons);
    }
    
    getIcon(name) {
        const iconSet = this.cache.get('iconSet');
        return iconSet?.icons[name] || null;
    }
}
```

## ⚠️ Considerações

### Performance ESP32
- Limite de 256 ícones simultâneos na memória
- SVGs complexos devem ser convertidos para bitmaps
- Preferir símbolos LVGL para melhor performance
- Cache de ícones usados frequentemente

### Compatibilidade
- Nem todos os ícones estão disponíveis em todas as plataformas
- Sistema de fallback garante que sempre há uma representação visual
- Testes em diferentes dispositivos são essenciais

### Personalização
- Ícones customizados devem seguir guidelines de design
- SVGs devem ser otimizados para diferentes tamanhos
- Considerar contraste e legibilidade em temas escuros/claros

### Manutenção
- Adicionar novos ícones requer atualização em todas as plataformas
- Versionamento de ícones para compatibilidade retroativa
- Backup de ícones customizados importante para restauração