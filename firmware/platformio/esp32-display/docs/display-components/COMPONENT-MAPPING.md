# Component Mapping - Frontend ↔ Backend ↔ ESP32

Este documento detalha o mapeamento completo entre os componentes do frontend React, estrutura de dados do backend e implementação LVGL no ESP32-Display.

## 1. Mapeamento Geral dos Componentes

### 1.1. Tabela de Mapeamento Principal

| Frontend Component | Backend `item_type` | ESP32 LVGL Widget | Método Factory | Status |
|-------------------|---------------------|-------------------|----------------|--------|
| `<Button>` | `button` | `NavButton` | `createButton()` | ✅ Implementado |
| `<Switch>` | `switch` | `lv_switch_create()` | `createSwitch()` | 🟡 Parcial |
| `<Card>` (Display) | `display` | `lv_label_create()` | `createDisplay()` | 🟡 Parcial |
| `<Progress>` (Gauge) | `gauge` | `lv_meter_create()` | `createGauge()` | ❌ Não implementado |

### 1.2. Mapeamento de Estados

| Frontend State | Backend Field | ESP32 Storage | Update Method |
|---------------|---------------|---------------|---------------|
| `itemStates[id]` | `relay_channel.state` | `NavButton.state` | `setState()` |
| `isActive` | `is_active` | Widget visibility | `lv_obj_add_flag()` |
| `buttonVariant` | `action_payload` | Theme colors | `theme_apply_*()` |

## 2. Mapeamento Detalhado por Componente

### 2.1. Button Component

#### Frontend (React)
```jsx
<Button
  variant={buttonVariant}              // 'default', 'outline', 'destructive'
  className="col-span-1 h-20 flex flex-col gap-2"
  onClick={() => handleItemAction(item)}
>
  <IconComponent className="h-6 w-6" />
  <span className="text-xs">{item.label}</span>
  {buttonType === 'momentary' && (
    <Badge variant="outline">HOLD</Badge>
  )}
</Button>
```

#### Backend (JSON)
```json
{
  "item_type": "button",
  "name": "btn_light_main",
  "label": "Luz Principal",
  "icon": "lightbulb",
  "position": 1,
  "size_display_small": "normal",
  "action_type": "relay_toggle",
  "action_payload": "{\"toggle\": true}",
  "relay_board_id": 1,
  "relay_channel_id": 3
}
```

#### ESP32 (LVGL)
```cpp
// Implementação atual em NavButton
NavButton* btn = new NavButton(parent, label, icon, id);
btn->setButtonType(NavButton::TYPE_RELAY);
btn->setRelayConfig(device, channel, functionType);
btn->setClickCallback([](NavButton* b) {
    commandSender->sendRelayCommand(boardId, channelId, state, type);
});
```

#### Mapeamento de Propriedades

| Frontend Property | Backend Field | ESP32 Implementation |
|------------------|---------------|----------------------|
| `variant` | `action_payload.momentary` | `theme_apply_button_*()` |
| `className` spans | `size_display_small` | `calculateItemSize()` |
| `IconComponent` | `icon` | `iconManager->getIconSymbol()` |
| `onClick` | `action_type` + `relay_*_id` | `setClickCallback()` |
| `children[0]` | `icon` | `NavButton.iconLabel` |
| `children[1]` | `label` | `NavButton.textLabel` |
| `children[2]` | `action_payload.momentary` | Badge condicional |

### 2.2. Switch Component  

#### Frontend (React)
```jsx
<Card className="col-span-1 p-4">
  <div className="flex items-center justify-between">
    <div className="flex items-center gap-3">
      <IconComponent className="h-5 w-5" />
      <span className="text-sm font-medium">{item.label}</span>
    </div>
    <Switch
      checked={isActive}
      onCheckedChange={() => handleItemAction(item)}
    />
  </div>
</Card>
```

#### Backend (JSON)
```json
{
  "item_type": "switch",
  "name": "sw_cabin_light",
  "label": "Luz Cabine",
  "icon": "lightbulb",
  "position": 2,
  "size_display_small": "normal",
  "action_type": "relay_toggle",
  "relay_board_id": 1,
  "relay_channel_id": 4
}
```

#### ESP32 (LVGL) - Implementação Necessária
```cpp
// Proposta de implementação
NavButton* ScreenFactory::createSwitch(lv_obj_t* parent, JsonObject& config) {
    // Container card
    lv_obj_t* card = lv_obj_create(parent);
    lv_obj_set_style_bg_color(card, COLOR_CARD_BG, 0);
    
    // Switch widget nativo
    lv_obj_t* lvSwitch = lv_switch_create(card);
    lv_obj_align(lvSwitch, LV_ALIGN_CENTER_RIGHT, -10, 0);
    
    // Ícone + Label (lado esquerdo)
    lv_obj_t* icon = lv_label_create(card);
    lv_obj_t* label = lv_label_create(card);
    
    // NavButton wrapper
    NavButton* wrapper = new NavButton(card, label, icon, id);
    wrapper->setLVGLObject(lvSwitch);
    
    return wrapper;
}
```

#### Mapeamento de Propriedades

| Frontend Property | Backend Field | ESP32 Implementation |
|------------------|---------------|----------------------|
| `Card` container | `item_type: "switch"` | `lv_obj_create()` card |
| `Switch` widget | `action_type` | `lv_switch_create()` |
| `checked` | Runtime state | `lv_obj_add_state(LV_STATE_CHECKED)` |
| `onCheckedChange` | `relay_*_id` | Event callback |
| Icon + Label | `icon` + `label` | `lv_label_create()` x2 |

### 2.3. Display Component

#### Frontend (React)
```jsx
<Card className="col-span-1 p-4 hover:shadow-lg transition-shadow">
  <div className="flex items-center justify-between">
    <div className="flex-1">
      <div className="text-xs text-muted-foreground uppercase">
        {item.label}
      </div>
      <div className="text-2xl font-bold tabular-nums">
        {displayValue.toLocaleString()} {item.data_unit}
      </div>
    </div>
    <IconComponent className="h-8 w-8 text-muted-foreground" />
  </div>
</Card>
```

#### Backend (JSON)
```json
{
  "item_type": "display",
  "name": "display_engine_temp",
  "label": "Temp. Motor",
  "icon": "thermometer",
  "position": 3,
  "size_display_small": "normal",
  "data_source": "can_signal",
  "data_path": "coolant_temperature",
  "data_format": "%.1f",
  "data_unit": "°C"
}
```

#### ESP32 (LVGL) - Implementação Melhorada
```cpp
NavButton* ScreenFactory::createDisplay(lv_obj_t* parent, JsonObject& config) {
    // Card container
    lv_obj_t* card = lv_obj_create(parent);
    
    // Title label (pequeno, cinza, topo-esquerda)
    lv_obj_t* titleLabel = lv_label_create(card);
    lv_label_set_text(titleLabel, config["label"]);
    lv_obj_set_style_text_font(titleLabel, &lv_font_montserrat_12, 0);
    lv_obj_align(titleLabel, LV_ALIGN_TOP_LEFT, 0, 0);
    
    // Value label (grande, centro)
    lv_obj_t* valueLabel = lv_label_create(card);
    lv_label_set_text(valueLabel, "0");
    lv_obj_set_style_text_font(valueLabel, &lv_font_montserrat_20, 0);
    lv_obj_align(valueLabel, LV_ALIGN_CENTER, 0, 5);
    
    // Icon (topo-direita)
    lv_obj_t* iconLabel = lv_label_create(card);
    String iconSymbol = iconManager->getIconSymbol(config["icon"]);
    lv_label_set_text(iconLabel, iconSymbol.c_str());
    lv_obj_align(iconLabel, LV_ALIGN_TOP_RIGHT, 0, 0);
    
    // NavButton wrapper
    NavButton* display = new NavButton(card, label, icon, id);
    display->setButtonType(NavButton::TYPE_DISPLAY);
    display->setValueLabel(valueLabel);
    
    return display;
}
```

#### Mapeamento de Propriedades

| Frontend Property | Backend Field | ESP32 Implementation |
|------------------|---------------|----------------------|
| Card container | `item_type: "display"` | `lv_obj_create()` card |
| Title (small) | `label` | `titleLabel` com font pequena |
| Value (large) | Data binding | `valueLabel` com font grande |
| Unit | `data_unit` | Concatenado com valor |
| Icon | `icon` | `iconLabel` topo-direita |
| `hover:shadow-lg` | N/A | Não aplicável no ESP32 |
| `tabular-nums` | N/A | Fonte monospace se disponível |

### 2.4. Gauge Component

#### Frontend (React)
```jsx
<Card className="col-span-1 p-4">
  <div className="space-y-2">
    <div className="flex items-center justify-between">
      <span className="text-sm font-medium">{item.label}</span>
      <IconComponent className="h-4 w-4 text-muted-foreground" />
    </div>
    <div className="space-y-1">
      <Progress value={value} className="h-2" />
      <div className="flex justify-between text-xs text-muted-foreground">
        <span>0</span>
        <span className="font-medium text-foreground">
          {value}{item.data_unit || '%'}
        </span>
        <span>100</span>
      </div>
    </div>
  </div>
</Card>
```

#### Backend (JSON)
```json
{
  "item_type": "gauge",
  "name": "gauge_engine_rpm",
  "label": "RPM Motor",
  "icon": "gauge",
  "position": 4,
  "size_display_small": "large",
  "data_source": "can_signal",
  "data_path": "engine_rpm",
  "data_unit": "RPM",
  "action_payload": "{\"min_value\": 0, \"max_value\": 6000, \"warning_threshold\": 4500}"
}
```

#### ESP32 (LVGL) - Implementação Necessária
```cpp
lv_obj_t* ScreenFactory::createGauge(lv_obj_t* parent, JsonObject& config) {
    // Parse config
    float minValue = parseActionPayload(config, "min_value", 0);
    float maxValue = parseActionPayload(config, "max_value", 100);
    
    // Card container
    lv_obj_t* card = lv_obj_create(parent);
    
    // Meter widget
    lv_obj_t* meter = lv_meter_create(card);
    lv_obj_set_size(meter, 100, 100);
    lv_obj_align(meter, LV_ALIGN_TOP_MID, 0, 0);
    
    // Scale
    lv_meter_scale_t* scale = lv_meter_add_scale(meter);
    lv_meter_set_scale_ticks(meter, scale, 41, 2, 10, COLOR_BORDER);
    lv_meter_set_scale_range(meter, scale, minValue, maxValue, 240, 150);
    
    // Colored arcs (zones)
    createMeterZones(meter, scale, config);
    
    // Needle
    lv_meter_indicator_t* needle = lv_meter_add_needle_line(meter, scale, 4, COLOR_BUTTON_ON, -10);
    
    // Labels
    createGaugeLabels(card, meter, config);
    
    return meter;
}
```

#### Mapeamento de Propriedades

| Frontend Property | Backend Field | ESP32 Implementation |
|------------------|---------------|----------------------|
| `<Progress>` bar | `item_type: "gauge"` | `lv_meter_create()` |
| `value={value}` | Data binding | `lv_meter_set_indicator_value()` |
| Min/Max labels | `action_payload.*_value` | Scale configuration |
| Current value | Data binding | Center label |
| Progress color | Threshold logic | Colored arcs |
| `className="h-2"` | N/A | Meter size |

## 3. Mapeamento de Tamanhos

### 3.1. Frontend CSS Classes ↔ Backend Fields

| Frontend Class | Backend Field | ESP32 Grid Span | LVGL Size |
|---------------|---------------|------------------|-----------|
| `col-span-1` | `size_display_small: "normal"` | 1 coluna | `width/2 - gap` |
| `col-span-2` | `size_display_small: "large"` | 2 colunas | `width - gap` |
| `col-span-full` | `size_display_small: "full"` | Todas colunas | `full width` |
| `h-16` | `size_display_small: "small"` | - | `64px height` |
| `h-20` | `size_display_small: "normal"` | - | `80px height` |
| `h-24` | `size_display_small: "large"` | - | `96px height` |

### 3.2. Implementação do Cálculo

```cpp
// Frontend (CSS)
.col-span-1 { grid-column: span 1 / span 1; }
.col-span-2 { grid-column: span 2 / span 2; }
.h-16 { height: 4rem; /* 64px */ }
.h-20 { height: 5rem; /* 80px */ }

// ESP32 (C++)
lv_coord_t ScreenFactory::calculateItemSize(const String& size, bool isWidth) {
    int totalColumns = 2; // Display P
    lv_coord_t containerWidth = 480 - 40; // Screen - margins
    
    if (isWidth) {
        lv_coord_t columnWidth = containerWidth / totalColumns;
        if (size == "normal") return columnWidth - 8;      // 1 coluna
        else if (size == "large") return (columnWidth * 2) - 8; // 2 colunas
        else if (size == "full") return containerWidth - 8;     // Full width
    } else {
        if (size == "small") return 64;       // h-16
        else if (size == "normal") return 80; // h-20  
        else if (size == "large") return 96;  // h-24
    }
}
```

## 4. Mapeamento de Ícones

### 4.1. Frontend (Lucide React) ↔ ESP32 (FontAwesome)

| Frontend Icon | Backend `icon` | ESP32 Symbol | Unicode |
|--------------|----------------|---------------|---------|
| `<Home />` | `"home"` | `""` | `\uf015` |
| `<Lightbulb />` | `"lightbulb"` | `""` | `\uf0eb` |
| `<Power />` | `"power"` | `""` | `\uf011` |
| `<Gauge />` | `"gauge"` | `""` | `\uf3fd` |
| `<Thermometer />` | `"thermometer"` | `""` | `\uf2c7` |
| `<Droplets />` | `"droplets"` | `""` | `\uf043` |
| `<Wind />` | `"wind"` | `""` | `\uf72e` |
| `<Battery />` | `"battery"` | `""` | `\uf240` |
| `<Wifi />` | `"wifi"` | `""` | `\uf1eb` |
| `<Settings />` | `"settings"` | `""` | `\uf013` |

### 4.2. Sistema de Fallback

```cpp
// ESP32 IconManager implementation
String IconManager::getIconSymbol(const String& iconName) {
    // Buscar no mapa de ícones
    if (iconMap.find(iconName) != iconMap.end()) {
        return iconMap[iconName];
    }
    
    // Fallback para ícone genérico
    logger->warning("Icon not found: " + iconName + ", using fallback");
    return iconMap["circle"]; // Ícone padrão
}

// Frontend fallback
const IconComponent = iconMap[item.icon] || Circle;
```

## 5. Mapeamento de Ações

### 5.1. Frontend Handlers ↔ Backend Types ↔ ESP32 Commands

| Frontend Action | Backend `action_type` | ESP32 Method | MQTT Topic |
|----------------|----------------------|---------------|------------|
| `handleItemAction()` | `"relay_toggle"` | `sendRelayCommand()` | `autocore/commands/relay` |
| `navigateToScreen()` | `"screen_navigate"` | `screenManager->navigateTo()` | N/A |
| Toggle state | `"relay_on"/"relay_off"` | `sendRelayCommand()` | `autocore/commands/relay` |
| Macro execution | `"macro_execute"` | `sendMacroCommand()` | `autocore/commands/macro` |

### 5.2. Payload Mapping

#### Frontend State Management
```javascript
// Toggle relay
setItemStates(prev => ({
  ...prev,
  [item.id]: !prev[item.id]
}))

// Momentary action
setItemStates(prev => ({ ...prev, [item.id]: true }))
setTimeout(() => {
  setItemStates(prev => ({ ...prev, [item.id]: false }))
}, 500)
```

#### Backend Payload Structure
```json
{
  "action_payload": "{\"toggle\": true}",           // Toggle relay
  "action_payload": "{\"momentary\": true}",        // Momentary action
  "action_payload": "{\"pulse\": true}",            // Pulse action
  "action_payload": "{\"duration\": 5000}"          // Timed action
}
```

#### ESP32 Command Generation
```cpp
void CommandSender::sendRelayCommand(String boardId, int channelId, String action, String type) {
    JsonDocument doc;
    doc["device_id"] = boardId;
    doc["channel"] = channelId;
    doc["action"] = action;
    doc["type"] = type;
    
    String topic = "autocore/commands/relay/" + boardId;
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic.c_str(), payload.c_str());
}
```

## 6. Mapeamento de Dados Dinâmicos

### 6.1. Frontend Simulation ↔ Backend Sources ↔ ESP32 MQTT

| Frontend Simulation | Backend `data_source` | Backend `data_path` | ESP32 MQTT Topic |
|-------------------|----------------------|-------------------|------------------|
| `Math.random() * 100` | `"can_signal"` | `"engine_rpm"` | `autocore/telemetry/can/engine_rpm` |
| Temperature simulation | `"can_signal"` | `"coolant_temp"` | `autocore/telemetry/can/coolant_temp` |
| Fuel simulation | `"telemetry"` | `"fuel_level"` | `autocore/telemetry/sensors/fuel_level` |
| Relay state | `"relay_state"` | `"board_1_channel_3"` | `autocore/status/relay/1/3` |

### 6.2. Data Flow

```
[CAN Bus] → [Gateway] → [MQTT Broker] → [ESP32 Display]
    ↓             ↓            ↓              ↓
[Signals] → [Processing] → [Topics] → [DataBinder.updateAll()]
```

#### Frontend Data Binding
```javascript
// Simulated values for preview
const value = itemStates[item.id] || Math.floor(Math.random() * 100)

// Color logic
let valueColor = ''
if (item.name === 'temp' && value > 90) valueColor = 'text-red-500'
```

#### ESP32 Data Binding
```cpp
class DataBinder {
    void updateWidget(BoundWidget& binding) {
        float value = getDataValue(binding.dataSource, binding.dataPath);
        
        if (binding.navButton->getButtonType() == NavButton::TYPE_DISPLAY) {
            String formatted = ScreenFactory::formatDisplayValue(value, binding.config);
            lv_label_set_text(binding.navButton->getValueLabel(), formatted.c_str());
            
            // Apply conditional colors
            applyDynamicColors(binding.widget, binding.config, value);
        }
    }
}
```

## 7. Mapeamento de Temas e Cores

### 7.1. Frontend CSS Variables ↔ ESP32 Theme Constants

| Frontend CSS Variable | ESP32 Theme Constant | LVGL Color | Usage |
|----------------------|----------------------|-------------|--------|
| `--primary` | `COLOR_BUTTON_ON` | `lv_color_make(0, 120, 215)` | Active buttons |
| `--secondary` | `COLOR_BUTTON_OFF` | `lv_color_make(240, 240, 240)` | Inactive buttons |
| `--border` | `COLOR_BORDER` | `lv_color_make(200, 200, 200)` | Borders |
| `--muted-foreground` | `COLOR_TEXT_MUTED` | `lv_color_make(140, 140, 140)` | Secondary text |
| `--foreground` | `COLOR_TEXT_OFF` | `lv_color_make(20, 20, 20)` | Primary text |

### 7.2. Dynamic Color Mapping

```javascript
// Frontend conditional colors
let valueColor = ''
if (item.name === 'temp' && displayValue > 90) valueColor = 'text-red-500'
else if (item.name === 'fuel' && displayValue < 20) valueColor = 'text-orange-500'
```

```cpp
// ESP32 equivalent
void ScreenFactory::applyDynamicColors(lv_obj_t* obj, JsonObject& config, float value) {
    String dataPath = config["data_path"].as<String>();
    lv_color_t color = COLOR_TEXT_OFF;
    
    if (dataPath == "coolant_temp") {
        if (value > 90) color = lv_color_make(255, 0, 0);        // Red
        else if (value > 80) color = lv_color_make(255, 150, 0); // Orange
        else color = lv_color_make(0, 150, 0);                    // Green
    }
    
    lv_obj_set_style_text_color(obj, color, 0);
}
```

## 8. Grid Layout Mapping

### 8.1. Frontend Grid ↔ ESP32 Positioning

#### Frontend CSS Grid
```css
.grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr); /* Display P: 2 columns */
  gap: 0.75rem; /* 12px gap */
}
```

#### ESP32 Manual Positioning
```cpp
void CustomScreen::rebuildContent() {
    int totalColumns = 2; // Display P
    lv_coord_t containerWidth = 480 - 40; // Screen width - margins
    lv_coord_t itemGap = 12;
    lv_coord_t columnWidth = containerWidth / totalColumns;
    
    int currentRow = 0, currentCol = 0;
    lv_coord_t yOffset = 10;
    
    for (auto& item : sortedItems) {
        String size = item["size_display_small"];
        int colSpan = (size == "large") ? 2 : 1;
        
        // Check if fits in current row
        if (currentCol + colSpan > totalColumns) {
            currentRow++;
            currentCol = 0;
            yOffset += calculateItemSize(size, false) + itemGap;
        }
        
        // Position item
        lv_coord_t xOffset = currentCol * columnWidth;
        lv_obj_set_pos(widget, xOffset, yOffset);
        
        currentCol += colSpan;
    }
}
```

## 9. API Response Mapping

### 9.1. Backend JSON ↔ ESP32 Parsing

#### Backend Response Structure
```json
{
  "screens": [
    {
      "id": 1,
      "name": "main_dashboard",
      "title": "Dashboard Principal", 
      "columns_display_small": 2,
      "items": [
        {
          "id": 101,
          "item_type": "button",
          "name": "btn_light_main",
          "label": "Luz Principal",
          "icon": "lightbulb",
          "position": 1,
          "size_display_small": "normal",
          "action_type": "relay_toggle",
          "relay_board_id": 1,
          "relay_channel_id": 3,
          "relay_board": { /* expanded data */ },
          "relay_channel": { /* expanded data */ }
        }
      ]
    }
  ]
}
```

#### ESP32 JSON Processing
```cpp
std::unique_ptr<ScreenBase> ScreenFactory::createScreen(JsonObject& config) {
    String screenId = config["id"].as<String>();
    String title = config["title"].as<String>();
    int columns = config["columns_display_small"] | 2;
    
    auto screen = std::unique_ptr<CustomScreen>(new CustomScreen());
    screen->setScreenId(screenId);
    screen->getHeader()->setTitle(title);
    screen->setColumns(columns);
    
    JsonArray items = config["items"].as<JsonArray>();
    if (!items.isNull()) {
        screen->setItems(items);
        screen->rebuildContent();
    }
    
    return screen;
}
```

## 10. Error Handling and Fallbacks

### 10.1. Frontend Error States ↔ ESP32 Fallbacks

| Frontend Error | Backend Issue | ESP32 Fallback |
|---------------|---------------|----------------|
| Icon not found | Invalid `icon` field | Use default circle icon |
| Action fails | Network/MQTT error | Visual feedback only |
| Data not available | Invalid `data_path` | Show "---" or last value |
| Layout overflow | Too many large items | Auto-resize or scroll |

### 10.2. Validation Mapping

```javascript
// Frontend validation
if (!item.action_type && item.item_type === 'button') {
  console.warn('Button without action_type:', item.name);
}
```

```cpp
// ESP32 validation
NavButton* ScreenFactory::createButton(lv_obj_t* parent, JsonObject& config) {
    if (!config["action_type"].is<String>()) {
        logger->warning("Button without action_type: " + config["name"].as<String>());
        // Create disabled button
        auto btn = new NavButton(parent, label, icon, id);
        btn->setEnabled(false);
        return btn;
    }
    // ... normal creation
}
```

## 11. Performance Considerations

### 11.1. Frontend Performance ↔ ESP32 Optimizations

| Frontend Optimization | ESP32 Equivalent |
|----------------------|------------------|
| React.memo() | Widget object pooling |
| useState batching | Batch LVGL updates |
| CSS transitions | LVGL animations |
| Virtual scrolling | Pagination |
| Lazy loading | On-demand widget creation |

### 11.2. Memory Mapping

```javascript
// Frontend: Lightweight virtual DOM
const itemStates = {}; // ~100 bytes per screen

// ESP32: Physical widgets in RAM
// NavButton: ~200 bytes
// lv_meter: ~800 bytes  
// lv_switch: ~400 bytes
// Total per screen: ~3-5KB
```

## 12. Development Workflow Mapping

### 12.1. Frontend Development ↔ ESP32 Development

| Frontend Step | ESP32 Equivalent |
|--------------|------------------|
| 1. Design component in browser | 1. Plan LVGL widget layout |
| 2. Add to ScreenPreview.jsx | 2. Add to ScreenFactory.cpp |
| 3. Test with mock data | 3. Test with simulated values |
| 4. Connect to API | 4. Connect to MQTT data |
| 5. Style with CSS | 5. Apply LVGL themes |

### 12.2. Testing Strategy

```javascript
// Frontend testing
it('should render gauge with correct value', () => {
  const item = { item_type: 'gauge', data_unit: 'RPM' };
  render(<GaugeComponent item={item} value={3000} />);
  expect(screen.getByText('3000 RPM')).toBeInTheDocument();
});
```

```cpp
// ESP32 testing
void testGaugeCreation() {
    JsonDocument doc;
    doc["item_type"] = "gauge";
    doc["data_unit"] = "RPM";
    
    lv_obj_t* gauge = ScreenFactory::createGauge(testParent, doc.as<JsonObject>());
    assert(gauge != nullptr);
    assert(lv_obj_check_type(gauge, &lv_meter_class));
}
```

## 13. Conclusão do Mapeamento

### 13.1. Compatibilidade Total

✅ **Frontend → Backend**: 100% compatível  
✅ **Backend → ESP32**: 90% compatível (falta Gauge)  
🟡 **Funcionalidades**: Switch e Display precisam melhorias  

### 13.2. Gaps Identificados

1. **ESP32 Gauge**: Não implementado - widget mais crítico
2. **ESP32 Switch**: Implementado como NavButton - precisa widget nativo
3. **Data Formatting**: Básico - precisa printf-style formatting
4. **Dynamic Colors**: Não implementado - precisa threshold logic

### 13.3. Prioridades de Implementação

1. 🔴 **Alta**: Gauge implementation
2. 🟡 **Média**: Switch nativo + Display formatting  
3. 🟢 **Baixa**: Cores dinâmicas + animações

---

**Status**: Mapeamento completo documentado  
**Próximo passo**: Implementar componentes faltantes conforme ESP32-IMPLEMENTATION-PLAN.md  
**Última atualização**: 17/08/2025