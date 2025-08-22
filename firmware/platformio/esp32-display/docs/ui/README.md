# UI System - LVGL Interface

Este diretório contém toda a documentação sobre o sistema de interface de usuário baseado em LVGL.

## 🎨 Visão Geral do Sistema UI

### LVGL Version
- **Version**: 8.3.11
- **Color Depth**: 16-bit (RGB565)
- **Resolution**: 240x320 pixels
- **Memory**: 64KB para LVGL
- **Refresh Rate**: 30ms (33 FPS)

### Arquitetura UI
```
ScreenManager
├── ScreenBase (classe base)
├── HomeScreen (tela principal)
├── ScreenFactory (criação dinâmica)
└── NavButton (componentes interativos)
```

## 📋 Documentação Disponível

- [`screen-layouts.md`](screen-layouts.md) - Layouts e estrutura de telas
- [`nav-buttons.md`](nav-buttons.md) - Sistema NavButton detalhado
- [`animations.md`](animations.md) - Animações e transições
- [`themes.md`](themes.md) - Sistema de temas e cores
- [`lvgl-configuration.md`](lvgl-configuration.md) - Configuração LVGL

## 🖥️ Componentes Principais

### Screen Types
- **HomeScreen**: Tela principal com controles
- **SettingsScreen**: Configurações do sistema
- **StatusScreen**: Informações de status
- **Custom Screens**: Telas criadas dinamicamente

### NavButton Types
- **Navigation**: Navegação entre telas
- **Relay**: Controle de relays
- **Action**: Ações específicas
- **Mode**: Seleção de modo
- **Display**: Exibição de dados
- **Switch**: Switches nativos LVGL
- **Gauge**: Medidores e indicadores

### Layout System
- **Container**: Sistema de containers flexível
- **GridContainer**: Layout em grade
- **Header**: Cabeçalho das telas
- **NavigationBar**: Barra de navegação

## 🎯 Sistema de Factory

### ScreenFactory
Cria telas dinamicamente a partir de configuração JSON:

```cpp
// Criar tela a partir de JSON
std::unique_ptr<ScreenBase> screen = ScreenFactory::createScreen(config);

// Criar componentes específicos
NavButton* relay = ScreenFactory::createRelayItem(parent, config);
NavButton* action = ScreenFactory::createActionItem(parent, config);
```

### JSON Configuration Format
```json
{
  "screen_id": "home",
  "title": "Home Control",
  "layout": {
    "type": "grid",
    "columns": 2,
    "rows": 3
  },
  "items": [
    {
      "type": "relay",
      "id": "relay_1",
      "label": "Sala",
      "icon": "light",
      "device_id": "relay_board_1",
      "channel": 1,
      "mode": "toggle"
    }
  ]
}
```

## 🎨 Sistema de Temas

### Theme Configuration
```cpp
// Cores principais
#define THEME_PRIMARY_COLOR 0x2196F3    // Azul Material
#define THEME_SECONDARY_COLOR 0x4CAF50  // Verde Material
#define THEME_BACKGROUND_COLOR 0x263238 // Cinza escuro
#define THEME_TEXT_COLOR 0xFFFFFF       // Branco
```

### Dynamic Theming
- Modo claro/escuro
- Cores personalizáveis
- Ajuste de brilho automático
- Temas por contexto

## 📱 Touch Interaction

### Touch Events
- **Press**: Botão pressionado
- **Release**: Botão liberado  
- **Long Press**: Pressão longa
- **Gesture**: Gestos especiais

### Calibration
```cpp
// Calibração automática do touch
TouchHandler::calibrate();

// Valores típicos para 240x320
touch_cal_x1 = 300;   // Borda esquerda
touch_cal_x2 = 3700;  // Borda direita
touch_cal_y1 = 300;   // Borda superior
touch_cal_y2 = 3700;  // Borda inferior
```

## 🔧 Performance

### Memory Management
- **LVGL Memory**: 64KB heap dedicado
- **Buffer Strategy**: 1/10 da tela (7.6KB)
- **Double Buffering**: Habilitado para fluidez
- **Memory Pools**: Reutilização de objetos

### Optimization
```cpp
// Configurações de performance
#define LV_DISP_DEF_REFR_PERIOD 30      // 30ms refresh
#define LV_INDEV_DEF_READ_PERIOD 50     // 50ms input read
#define LV_MEM_SIZE (64U * 1024U)       // 64KB memory
#define LV_COLOR_DEPTH 16               // 16-bit colors
```

## 🎛️ Widget Types

### Standard Widgets
- **Button**: Botões básicos
- **Switch**: Interruptores
- **Slider**: Controles deslizantes
- **Label**: Textos
- **Image**: Imagens

### Custom Widgets
- **NavButton**: Botão de navegação personalizado
- **StatusIndicator**: Indicadores de status
- **GaugeDisplay**: Medidores circulares
- **DataPanel**: Painéis de dados

### Advanced Features
- **Icon Manager**: Gestão de ícones
- **Data Binding**: Vinculação de dados
- **Animation System**: Sistema de animações
- **Event Handling**: Tratamento de eventos