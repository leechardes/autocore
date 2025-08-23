# Endpoints - Layouts

Sistema de layouts pré-definidos para organização automática de interfaces em diferentes tipos de display.

## 📋 Visão Geral

Os endpoints de layouts permitem:
- Obter layouts pré-configurados para diferentes dispositivos
- Otimizar distribuição de componentes automaticamente
- Adaptar interfaces conforme tamanho de tela
- Facilitar desenvolvimento de interfaces responsivas

## 📐 Endpoints de Layouts

### `GET /api/layouts`

Retorna todos os layouts disponíveis para diferentes tipos de dispositivos.

**Resposta:**
```json
[
  {
    "id": "grid_2x2",
    "name": "Grid 2x2",
    "description": "4 itens organizados em grade 2x2",
    "max_items": 4,
    "columns": 2,
    "rows": 2,
    "category": "grid",
    "supported_devices": ["esp32_display_small", "esp32_display_large"],
    "recommended_for": ["dashboard", "controls"],
    "preview_image": "/assets/layouts/grid_2x2.png",
    "item_positions": [
      {"x": 0, "y": 0, "width": 1, "height": 1},
      {"x": 1, "y": 0, "width": 1, "height": 1},
      {"x": 0, "y": 1, "width": 1, "height": 1},
      {"x": 1, "y": 1, "width": 1, "height": 1}
    ]
  },
  {
    "id": "grid_2x3",
    "name": "Grid 2x3",
    "description": "6 itens organizados em grade 2x3",
    "max_items": 6,
    "columns": 2,
    "rows": 3,
    "category": "grid",
    "supported_devices": ["esp32_display_large"],
    "recommended_for": ["dashboard", "monitoring"],
    "preview_image": "/assets/layouts/grid_2x3.png",
    "item_positions": [
      {"x": 0, "y": 0, "width": 1, "height": 1},
      {"x": 1, "y": 0, "width": 1, "height": 1},
      {"x": 0, "y": 1, "width": 1, "height": 1},
      {"x": 1, "y": 1, "width": 1, "height": 1},
      {"x": 0, "y": 2, "width": 1, "height": 1},
      {"x": 1, "y": 2, "width": 1, "height": 1}
    ]
  },
  {
    "id": "grid_3x2",
    "name": "Grid 3x2",
    "description": "6 itens organizados em grade horizontal 3x2",
    "max_items": 6,
    "columns": 3,
    "rows": 2,
    "category": "grid",
    "supported_devices": ["esp32_display_large", "web"],
    "recommended_for": ["controls", "telemetry"],
    "preview_image": "/assets/layouts/grid_3x2.png",
    "item_positions": [
      {"x": 0, "y": 0, "width": 1, "height": 1},
      {"x": 1, "y": 0, "width": 1, "height": 1},
      {"x": 2, "y": 0, "width": 1, "height": 1},
      {"x": 0, "y": 1, "width": 1, "height": 1},
      {"x": 1, "y": 1, "width": 1, "height": 1},
      {"x": 2, "y": 1, "width": 1, "height": 1}
    ]
  },
  {
    "id": "list_vertical",
    "name": "Lista Vertical",
    "description": "Lista vertical com scroll para muitos itens",
    "max_items": 20,
    "columns": 1,
    "rows": null,
    "category": "list",
    "supported_devices": ["esp32_display_small", "esp32_display_large", "mobile"],
    "recommended_for": ["menu", "settings", "selection"],
    "preview_image": "/assets/layouts/list_vertical.png",
    "scroll_enabled": true,
    "item_height": 48
  },
  {
    "id": "dashboard_mixed",
    "name": "Dashboard Misto",
    "description": "Layout otimizado para dashboards com itens de tamanhos variados",
    "max_items": 8,
    "columns": 4,
    "rows": 3,
    "category": "dashboard",
    "supported_devices": ["esp32_display_large", "web"],
    "recommended_for": ["dashboard", "monitoring"],
    "preview_image": "/assets/layouts/dashboard_mixed.png",
    "item_positions": [
      {"x": 0, "y": 0, "width": 2, "height": 2, "type": "large_gauge"},
      {"x": 2, "y": 0, "width": 1, "height": 1, "type": "button"},
      {"x": 3, "y": 0, "width": 1, "height": 1, "type": "button"},
      {"x": 2, "y": 1, "width": 2, "height": 1, "type": "display"},
      {"x": 0, "y": 2, "width": 1, "height": 1, "type": "button"},
      {"x": 1, "y": 2, "width": 1, "height": 1, "type": "button"},
      {"x": 2, "y": 2, "width": 1, "height": 1, "type": "button"},
      {"x": 3, "y": 2, "width": 1, "height": 1, "type": "button"}
    ]
  },
  {
    "id": "form",
    "name": "Formulário",
    "description": "Layout para configurações e formulários",
    "max_items": 15,
    "columns": 1,
    "rows": null,
    "category": "form",
    "supported_devices": ["esp32_display_large", "web"],
    "recommended_for": ["settings", "configuration"],
    "preview_image": "/assets/layouts/form.png",
    "scroll_enabled": true,
    "item_spacing": 8,
    "padding": {"top": 16, "bottom": 16, "left": 16, "right": 16}
  }
]
```

**Códigos de Status:**
- `200` - Layouts retornados com sucesso
- `500` - Erro interno do servidor

---

### `GET /api/layouts/{layout_id}`

Busca um layout específico com detalhes completos.

**Parâmetros de Path:**
- `layout_id` (string): ID do layout

**Resposta:**
```json
{
  "id": "grid_2x2",
  "name": "Grid 2x2",
  "description": "4 itens organizados em grade 2x2 - ideal para interfaces simples",
  "max_items": 4,
  "columns": 2,
  "rows": 2,
  "category": "grid",
  "supported_devices": ["esp32_display_small", "esp32_display_large"],
  "recommended_for": ["dashboard", "controls"],
  "preview_image": "/assets/layouts/grid_2x2.png",
  "dimensions": {
    "min_width": 240,
    "min_height": 160,
    "optimal_width": 320,
    "optimal_height": 240,
    "aspect_ratio": 1.33
  },
  "item_positions": [
    {
      "index": 0,
      "x": 0,
      "y": 0,
      "width": 1,
      "height": 1,
      "pixel_coords": {"x": 0, "y": 0, "width": 160, "height": 120},
      "suggested_types": ["button", "gauge", "display"],
      "constraints": {
        "min_size": "small",
        "max_size": "normal",
        "preferred_aspect": "square"
      }
    },
    {
      "index": 1,
      "x": 1,
      "y": 0,
      "width": 1,
      "height": 1,
      "pixel_coords": {"x": 160, "y": 0, "width": 160, "height": 120},
      "suggested_types": ["button", "gauge", "display"],
      "constraints": {
        "min_size": "small",
        "max_size": "normal",
        "preferred_aspect": "square"
      }
    },
    {
      "index": 2,
      "x": 0,
      "y": 1,
      "width": 1,
      "height": 1,
      "pixel_coords": {"x": 0, "y": 120, "width": 160, "height": 120},
      "suggested_types": ["button", "gauge", "display"],
      "constraints": {
        "min_size": "small",
        "max_size": "normal",
        "preferred_aspect": "square"
      }
    },
    {
      "index": 3,
      "x": 1,
      "y": 1,
      "width": 1,
      "height": 1,
      "pixel_coords": {"x": 160, "y": 120, "width": 160, "height": 120},
      "suggested_types": ["button", "gauge", "display"],
      "constraints": {
        "min_size": "small",
        "max_size": "normal",
        "preferred_aspect": "square"
      }
    }
  ],
  "style_properties": {
    "item_spacing": 4,
    "border_radius": 8,
    "padding": {"top": 8, "bottom": 8, "left": 8, "right": 8},
    "background_color": "transparent",
    "grid_lines": false
  },
  "responsive_behavior": {
    "scale_with_screen": true,
    "maintain_aspect_ratio": true,
    "min_item_size": {"width": 60, "height": 45},
    "max_item_size": {"width": 200, "height": 150}
  }
}
```

**Códigos de Status:**
- `200` - Layout encontrado
- `404` - Layout não encontrado
- `500` - Erro interno do servidor

---

### `GET /api/layouts/compatible/{device_type}`

Retorna layouts compatíveis com um tipo de dispositivo específico.

**Parâmetros de Path:**
- `device_type` (string): Tipo do dispositivo (`esp32_display_small`, `esp32_display_large`, `web`, `mobile`)

**Parâmetros de Query:**
- `screen_type` (string, opcional): Filtrar por tipo de tela (`dashboard`, `controls`, `settings`, `menu`)
- `max_items` (integer, opcional): Máximo de itens suportados

**Resposta:**
```json
{
  "device_type": "esp32_display_small",
  "device_specs": {
    "resolution": "320x240",
    "color_depth": "16-bit",
    "touch_support": true,
    "memory_limit": "4MB"
  },
  "compatible_layouts": [
    {
      "id": "grid_2x2",
      "name": "Grid 2x2",
      "compatibility_score": 100,
      "performance_rating": "excellent",
      "recommended": true,
      "limitations": []
    },
    {
      "id": "list_vertical",
      "name": "Lista Vertical",
      "compatibility_score": 95,
      "performance_rating": "good",
      "recommended": true,
      "limitations": ["scroll_may_be_slow_with_many_items"]
    },
    {
      "id": "grid_2x3",
      "name": "Grid 2x3",
      "compatibility_score": 60,
      "performance_rating": "fair",
      "recommended": false,
      "limitations": ["items_may_be_too_small", "text_readability_issues"]
    }
  ]
}
```

## 🎯 Categorias de Layout

### Grid (`grid`)
Layouts baseados em grade fixa:
- **grid_2x2** - 4 itens em grade quadrada
- **grid_2x3** - 6 itens em grade vertical
- **grid_3x2** - 6 itens em grade horizontal
- **grid_3x3** - 9 itens em grade (displays grandes)
- **grid_4x3** - 12 itens em grade (web/tablet)

### List (`list`)
Layouts de lista com scroll:
- **list_vertical** - Lista vertical simples
- **list_horizontal** - Lista horizontal (carrossel)
- **list_grouped** - Lista com agrupamentos
- **list_cards** - Lista de cards

### Dashboard (`dashboard`)
Layouts otimizados para dashboards:
- **dashboard_mixed** - Itens de tamanhos variados
- **dashboard_telemetry** - Foco em gauges e displays
- **dashboard_controls** - Balanceado entre controles e informações
- **dashboard_compact** - Máximo de informação em espaço mínimo

### Form (`form`)
Layouts para formulários e configurações:
- **form** - Formulário linear simples
- **form_tabbed** - Formulário com abas
- **form_wizard** - Formulário passo-a-passo
- **form_grouped** - Campos agrupados por categoria

### Special (`special`)
Layouts especializados:
- **fullscreen_gauge** - Gauge único em tela cheia
- **split_screen** - Tela dividida em seções
- **carousel** - Navegação horizontal entre telas
- **overlay** - Itens sobrepostos (modals, popups)

## 📱 Compatibilidade por Dispositivo

### ESP32 Display Small (320x240)
```json
{
  "optimal_layouts": ["grid_2x2", "list_vertical"],
  "good_layouts": ["form", "dashboard_compact"],
  "limitations": {
    "max_grid_size": "2x3",
    "max_items_per_screen": 6,
    "min_item_size": "60x45px",
    "scroll_performance": "moderate"
  }
}
```

### ESP32 Display Large (480x320+)
```json
{
  "optimal_layouts": ["grid_3x2", "dashboard_mixed", "grid_2x3"],
  "good_layouts": ["grid_3x3", "form", "list_vertical"],
  "limitations": {
    "max_grid_size": "4x3",
    "max_items_per_screen": 12,
    "min_item_size": "80x60px",
    "scroll_performance": "good"
  }
}
```

### Web Interface
```json
{
  "optimal_layouts": ["dashboard_mixed", "grid_4x3", "form_tabbed"],
  "good_layouts": ["all_layouts"],
  "limitations": {
    "max_grid_size": "unlimited",
    "max_items_per_screen": "unlimited",
    "responsive": true,
    "scroll_performance": "excellent"
  }
}
```

### Mobile Apps
```json
{
  "optimal_layouts": ["list_vertical", "form", "carousel"],
  "good_layouts": ["grid_2x2", "dashboard_compact"],
  "limitations": {
    "touch_friendly": true,
    "portrait_optimized": true,
    "swipe_gestures": true,
    "scroll_performance": "excellent"
  }
}
```

## 🎨 Propriedades de Layout

### Posicionamento
```json
{
  "position": {
    "x": 0,
    "y": 1,
    "width": 2,
    "height": 1,
    "z_index": 1
  },
  "alignment": {
    "horizontal": "center",
    "vertical": "middle"
  },
  "anchoring": {
    "anchor_left": true,
    "anchor_top": true,
    "anchor_right": false,
    "anchor_bottom": false
  }
}
```

### Espaçamento
```json
{
  "spacing": {
    "item_spacing": 8,
    "row_spacing": 8,
    "column_spacing": 8
  },
  "padding": {
    "top": 16,
    "bottom": 16,
    "left": 12,
    "right": 12
  },
  "margin": {
    "top": 0,
    "bottom": 0,
    "left": 0,
    "right": 0
  }
}
```

### Responsividade
```json
{
  "responsive": {
    "scale_with_screen": true,
    "maintain_aspect_ratio": true,
    "breakpoints": {
      "small": {"max_width": 320, "columns": 2},
      "medium": {"max_width": 480, "columns": 3},
      "large": {"max_width": 768, "columns": 4}
    }
  }
}
```

## 🔧 Uso em Desenvolvimento

### ESP32 - Aplicar Layout
```cpp
// ESP32 - Aplicar layout grid_2x2
void applyGridLayout(lv_obj_t* container, int rows, int cols) {
    lv_obj_set_layout(container, LV_LAYOUT_GRID);
    
    // Configurar grid
    static lv_coord_t col_dsc[] = {LV_GRID_FR(1), LV_GRID_FR(1), LV_GRID_TEMPLATE_LAST};
    static lv_coord_t row_dsc[] = {LV_GRID_FR(1), LV_GRID_FR(1), LV_GRID_TEMPLATE_LAST};
    
    lv_obj_set_grid_dsc_array(container, col_dsc, row_dsc);
}

// Posicionar item na grid
void positionItemInGrid(lv_obj_t* item, int x, int y, int width, int height) {
    lv_obj_set_grid_cell(item, LV_GRID_ALIGN_STRETCH, x, width,
                               LV_GRID_ALIGN_STRETCH, y, height);
}
```

### Web - CSS Grid
```css
/* CSS para layout grid_2x2 */
.layout-grid-2x2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-template-rows: 1fr 1fr;
  gap: 8px;
  padding: 8px;
  width: 100%;
  height: 100%;
}

.layout-item {
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 60px;
}

/* Responsive behavior */
@media (max-width: 320px) {
  .layout-grid-2x2 {
    grid-template-columns: 1fr;
    grid-template-rows: repeat(4, 1fr);
  }
}
```

### JavaScript - Layout Engine
```javascript
// Layout Engine para aplicação dinâmica
class LayoutEngine {
  constructor() {
    this.layouts = new Map();
    this.loadLayouts();
  }

  async loadLayouts() {
    const response = await fetch('/api/layouts');
    const layouts = await response.json();
    
    layouts.forEach(layout => {
      this.layouts.set(layout.id, layout);
    });
  }

  applyLayout(containerId, layoutId, items) {
    const container = document.getElementById(containerId);
    const layout = this.layouts.get(layoutId);
    
    if (!layout) {
      console.error(`Layout ${layoutId} not found`);
      return;
    }

    // Limpar container
    container.innerHTML = '';
    
    // Aplicar CSS do layout
    container.className = `layout-${layoutId}`;
    
    // Posicionar itens
    items.forEach((item, index) => {
      if (index < layout.max_items) {
        const position = layout.item_positions[index];
        const element = this.createItemElement(item, position);
        container.appendChild(element);
      }
    });
  }

  createItemElement(item, position) {
    const element = document.createElement('div');
    element.className = 'layout-item';
    
    // Aplicar posicionamento se necessário
    if (position && position.pixel_coords) {
      element.style.gridArea = `${position.y + 1} / ${position.x + 1} / 
                               ${position.y + position.height + 1} / 
                               ${position.x + position.width + 1}`;
    }
    
    return element;
  }
}
```

## 📊 Casos de Uso

### Auto Layout
```python
# Backend - Sugerir layout baseado no conteúdo
def suggest_optimal_layout(items, device_type, screen_size):
    item_count = len(items)
    item_types = [item['type'] for item in items]
    
    # Análise de conteúdo
    has_gauges = any(t == 'gauge' for t in item_types)
    has_buttons = any(t == 'button' for t in item_types)
    has_displays = any(t == 'display' for t in item_types)
    
    # Regras de sugestão
    if item_count <= 4 and device_type == 'esp32_display_small':
        return 'grid_2x2'
    elif has_gauges and item_count <= 6:
        return 'dashboard_mixed'
    elif item_count > 10:
        return 'list_vertical'
    else:
        return find_best_grid_layout(item_count, screen_size)
```

### Performance Optimization
```cpp
// ESP32 - Otimizar performance baseado no layout
void optimizeForLayout(String layout_id) {
    if (layout_id == "list_vertical") {
        // Habilitar virtual scrolling para listas longas
        lv_obj_add_flag(list_container, LV_OBJ_FLAG_SCROLL_ELASTIC);
        lv_obj_set_scroll_snap_y(list_container, LV_SCROLL_SNAP_CENTER);
        
        // Renderização lazy para itens fora da tela
        enableLazyRendering(true);
        
    } else if (layout_id.startsWith("grid_")) {
        // Otimizar para layouts de grid
        disableScrolling();
        preloadAllItems();
        
        // Cache de renderização para grids fixas
        enableRenderCache(true);
    }
}
```

### Adaptive Layouts
```javascript
// Frontend - Layout adaptativo baseado no dispositivo
class AdaptiveLayoutManager {
  constructor() {
    this.currentLayout = null;
    this.breakpoints = {
      mobile: 768,
      tablet: 1024,
      desktop: 1440
    };
  }

  selectOptimalLayout(items, screenWidth, deviceType) {
    let selectedLayout;

    if (screenWidth <= this.breakpoints.mobile) {
      // Mobile: preferir listas e grids simples
      selectedLayout = items.length <= 4 ? 'grid_2x2' : 'list_vertical';
    } else if (screenWidth <= this.breakpoints.tablet) {
      // Tablet: grids maiores
      selectedLayout = items.length <= 6 ? 'grid_2x3' : 'dashboard_mixed';
    } else {
      // Desktop: máxima flexibilidade
      selectedLayout = this.selectDesktopLayout(items);
    }

    return selectedLayout;
  }

  handleResize() {
    const newWidth = window.innerWidth;
    const optimalLayout = this.selectOptimalLayout(
      this.currentItems, 
      newWidth, 
      this.deviceType
    );

    if (optimalLayout !== this.currentLayout) {
      this.transitionToLayout(optimalLayout);
    }
  }
}
```

## ⚠️ Considerações

### Performance
- Layouts complexos podem impactar performance em ESP32
- Grids fixas são mais rápidas que listas com scroll
- Número de itens afeta diretamente o consumo de memória

### Design
- Manter consistência visual entre layouts
- Considerar legibilidade em diferentes tamanhos de tela
- Testar layouts em dispositivos reais

### Responsividade
- Web interfaces devem adaptar-se automaticamente
- ESP32 tem limitações de processamento para layouts dinâmicos
- Breakpoints devem ser bem definidos

### Usabilidade
- Layouts devem ser intuitivos para o usuário final
- Elementos importantes devem ter posição privilegiada
- Considerar fluxo de navegação entre telas