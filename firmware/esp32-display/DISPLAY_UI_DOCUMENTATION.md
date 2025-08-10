# AutoCore Display 2.8" - Documentação Técnica e Visual

## 📱 Visão Geral

Este documento detalha a implementação da interface de usuário para displays touch de 2.8" (320x240px) no sistema AutoCore, utilizando ESP32 com a biblioteca gráfica LVGL (Light and Versatile Graphics Library). O design segue os princípios de neumorfismo adaptado para displays embarcados, mantendo consistência visual com o aplicativo móvel.

## 🎨 Design System para Display Embarcado

### Filosofia de Design

O design para o display 2.8" foi cuidadosamente adaptado das interfaces mobile, considerando:

1. **Limitações de Hardware**
   - Resolução: 320x240 pixels
   - Profundidade de cor: RGB565 (16-bit)
   - Taxa de atualização: 30 FPS target
   - Memória RAM: ~45KB para UI
   - CPU: ESP32 dual-core 240MHz

2. **Contexto de Uso**
   - Montado no painel do veículo
   - Visualização sob luz solar direta
   - Operação com luvas
   - Vibração constante
   - Navegação por botões físicos

3. **Princípios de UX**
   - Informação essencial sempre visível
   - Áreas de toque mínimas de 44x44px
   - Contraste alto para legibilidade
   - Feedback visual imediato
   - Navegação previsível

### Sistema de Cores Tematizável

```css
/* Tema Dark Neumorphic (Padrão) */
--primary: #007AFF;        /* Azul iOS - Elementos ativos */
--primary-dark: #0051D5;   /* Azul escuro - Estados pressed */
--secondary: #32D74B;      /* Verde - Status positivo */
--warning: #FF9500;        /* Laranja - Ações momentâneas */
--danger: #FF3B30;         /* Vermelho - Alertas/emergência */

--bg-primary: #1C1C1E;     /* Background principal */
--bg-secondary: #2C2C2E;   /* Cards e elementos elevados */
--surface: #35353A;        /* Superfícies interativas */
--surface-dark: #151517;   /* Depressões/insets */

--text-primary: #FFFFFF;   /* Texto principal */
--text-secondary: #8E8E93; /* Labels e texto secundário */
--text-tertiary: #636366;  /* Texto desabilitado/hints */
```

### Efeitos Neumórficos Adaptados

O neumorfismo foi adaptado para funcionar eficientemente no display:

```css
/* Sombras otimizadas para performance */
--shadow-raised: 4px 4px 8px rgba(0, 0, 0, 0.5), 
                -4px -4px 8px rgba(255, 255, 255, 0.03);
                
--shadow-inset: inset 2px 2px 4px rgba(0, 0, 0, 0.5),
                inset -2px -2px 4px rgba(255, 255, 255, 0.03);
                
--shadow-subtle: 2px 2px 4px rgba(0, 0, 0, 0.3);
```

**Diferenças do App Mobile:**
- Sombras menores (4px vs 8px) para economizar processamento
- Menos camadas de sombra (2 vs 3)
- Offsets reduzidos para displays menores

## 🏗️ Arquitetura da Interface

### Estrutura de Telas

```
Display Layout (320x240)
├── Status Bar (320x20)
│   ├── Left: WiFi + MQTT Status
│   ├── Center: System Name
│   └── Right: Battery Voltage + Clock
├── Content Area (320x180)
│   └── Dynamic Buttons (Configurados pelo Backend)
│       ├── Grid Layout (ex: 3x3)
│       ├── List Layout (vertical)
│       └── Custom Layout (posições absolutas)
└── Navigation Bar (320x40)
    └── Touch Buttons: [◀ Prev] [🏠 Home] [▶ Next]
```

### 1. Dashboard Screen

**Layout:** Grid 3x2 com 6 botões principais

```
┌─────────┬─────────┬─────────┐
│  Luzes  │ Guincho │ Tração  │  56px
├─────────┼─────────┼─────────┤
│ Buzina  │   12V   │ Alerta  │  56px
└─────────┴─────────┴─────────┘
   100px     100px     100px
```

**Características:**
- **Vehicle Card**: Status resumido do veículo (60px altura)
- **Control Grid**: 6 botões de acesso rápido
- **Spacing**: 4px entre elementos (otimizado)
- **Botões**: 100x56px com ícone + label

**Implementação LVGL:**
```c
// Criar grid layout
lv_obj_t * grid = lv_obj_create(parent);
lv_obj_set_layout(grid, LV_LAYOUT_GRID);

static lv_coord_t col_dsc[] = {100, 100, 100, LV_GRID_TEMPLATE_LAST};
static lv_coord_t row_dsc[] = {56, 56, LV_GRID_TEMPLATE_LAST};
lv_obj_set_grid_dsc_array(grid, col_dsc, row_dsc);
lv_obj_set_style_pad_all(grid, 4, LV_PART_MAIN);
```

### 2. Lighting Screen

**Layout:** Lista vertical de switches

```
┌──────────────────────────────┐
│ 💡 Farol Alto          [===] │ 44px
├──────────────────────────────┤
│ 🔦 Farol Baixo         [===] │ 44px
├──────────────────────────────┤
│ 💠 LED Frontal         [===] │ 44px
├──────────────────────────────┤
│ 🌫️ Neblina            [===] │ 44px
└──────────────────────────────┘
```

**Switch Control Design:**
- **Height**: 44px (área de toque confortável)
- **Icon**: 28x28px com background inset
- **Label**: 11px font-size
- **Toggle**: 36x20px LVGL-style switch
- **Padding**: 8px interno

**Estados do Switch:**
```c
// Estado inativo
lv_obj_clear_state(switch_obj, LV_STATE_CHECKED);
lv_obj_set_style_bg_color(icon, theme->surface_dark, LV_PART_MAIN);

// Estado ativo
lv_obj_add_state(switch_obj, LV_STATE_CHECKED);
lv_obj_set_style_bg_color(icon, theme->primary, LV_PART_MAIN);
lv_obj_set_style_shadow_width(icon, 6, LV_PART_MAIN);
lv_obj_set_style_shadow_color(icon, theme->primary_alpha, LV_PART_MAIN);
```

### 3. Winch Screen

**Layout:** Centralizado com controles grandes

```
┌──────────────────────────────┐
│     Status: PRONTO           │
│                              │
│  ┌──────────┬──────────┐    │
│  │    ⬆️    │    ⬇️    │    │
│  │ RECOLHER │  SOLTAR  │    │
│  └──────────┴──────────┘    │
│                              │
│    ⚠️ Segure para operar     │
└──────────────────────────────┘
```

**Características Especiais:**
- **Botões Momentâneos**: Ação apenas enquanto pressionado
- **Feedback Visual**: Mudança de cor para laranja quando ativo
- **Status Display**: Texto grande (18px) e colorido
- **Warning**: Texto pequeno (9px) mas visível

**Implementação do Comportamento Momentâneo:**
```c
// Event handler para botão momentâneo
static void winch_btn_event_cb(lv_event_t * e) {
    lv_event_code_t code = lv_event_get_code(e);
    lv_obj_t * btn = lv_event_get_target(e);
    
    if(code == LV_EVENT_PRESSED) {
        // Aplicar estilo ativo
        lv_obj_set_style_bg_color(btn, 
            lv_color_hex(0xFF9500), LV_PART_MAIN);
        // Enviar comando MQTT START
        mqtt_publish("autocore/winch/command", "START");
        // Haptic feedback
        haptic_pulse(50);
    }
    else if(code == LV_EVENT_RELEASED) {
        // Restaurar estilo normal
        lv_obj_set_style_bg_color(btn, 
            theme->bg_secondary, LV_PART_MAIN);
        // Enviar comando MQTT STOP
        mqtt_publish("autocore/winch/command", "STOP");
    }
}
```

### 4. Traction Screen

**Layout:** Lista de opções exclusivas

```
┌──────────────────────────────┐
│ 🚗 4x2 | Traseira        ○  │ 48px
├──────────────────────────────┤
│ 🚙 4x4 High | Normal     ●  │ 48px
├──────────────────────────────┤
│ 🛻 4x4 Low | Reduzida    ○  │ 48px
└──────────────────────────────┘
```

**Mode Card Design:**
- **Height**: 48px
- **Icon**: 32x32px com gradiente quando ativo
- **Radio Button**: 16x16px custom
- **Typography**: 12px título / 9px subtítulo
- **Active State**: Borda azul + background gradiente sutil

## 🎮 Sistema de Navegação

### Navegação Touch com Navigation Bar

O sistema utiliza uma barra de navegação touch fixa na parte inferior da tela:

```
┌─────────────────────────────────┐
│                                  │
│      Content Area (180px)        │
│   [Botões Dinâmicos do Backend]  │
│                                  │
├─────────────────────────────────┤
│      Navigation Bar (40px)       │
│  [◀ Prev] [🏠 Home] [▶ Next]   │
└─────────────────────────────────┘
```

**Funcionalidades da Navigation Bar:**

| Botão | Função | Comportamento |
|-------|--------|---------------|
| ◀ Previous | Volta para tela anterior | Navega no histórico de telas |
| 🏠 Home | Retorna ao dashboard | Sempre volta para tela principal |
| ▶ Next | Avança para próxima tela | Navega entre telas disponíveis |

### Sistema de Configuração Web

Quando o ESP32 não está conectado a uma rede WiFi, ele entra em modo de configuração:

1. **Access Point Mode:**
   - SSID: `ESP32_Display_XXXX` (baseado no MAC)
   - IP: `192.168.4.1`
   - Página web de configuração acessível via browser

2. **Configurações Disponíveis:**
   - SSID e senha da rede WiFi
   - IP e porta do backend AutoCore
   - UUID do dispositivo (auto-gerado)
   - Nome do display (opcional)

3. **Após Configuração:**
   - ESP32 conecta na rede configurada
   - Busca configurações no backend
   - Desativa o Access Point
   - Opera em modo normal via MQTT

**Implementação da Navigation Bar:**
```c
// Criar Navigation Bar fixa
class NavigationBar {
    lv_obj_t* bar;
    lv_obj_t* btn_prev;
    lv_obj_t* btn_home;
    lv_obj_t* btn_next;
    
    void init(lv_obj_t* parent) {
        // Criar container da barra
        bar = lv_obj_create(parent);
        lv_obj_set_size(bar, 320, 40);
        lv_obj_align(bar, LV_ALIGN_BOTTOM_MID, 0, 0);
        lv_obj_set_style_bg_color(bar, lv_color_hex(0x2C2C2E), 0);
        
        // Botão Previous
        btn_prev = create_nav_button(bar, "◀", 10);
        lv_obj_add_event_cb(btn_prev, prev_clicked_cb, LV_EVENT_CLICKED, NULL);
        
        // Botão Home
        btn_home = create_nav_button(bar, "🏠", 110);
        lv_obj_add_event_cb(btn_home, home_clicked_cb, LV_EVENT_CLICKED, NULL);
        
        // Botão Next
        btn_next = create_nav_button(bar, "▶", 210);
        lv_obj_add_event_cb(btn_next, next_clicked_cb, LV_EVENT_CLICKED, NULL);
    }
    
    static void prev_clicked_cb(lv_event_t* e) {
        ScreenManager::getInstance()->previousScreen();
    }
    
    static void home_clicked_cb(lv_event_t* e) {
        ScreenManager::getInstance()->showDashboard();
    }
    
    static void next_clicked_cb(lv_event_t* e) {
        ScreenManager::getInstance()->nextScreen();
    }
};
```

### Navigation Dots

Indicador visual da tela atual:

```css
.nav-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--surface);
    transition: all 0.3s ease;
}

.nav-dot.active {
    width: 16px;
    border-radius: 3px;
    background: var(--primary);
}
```

## ⚡ Otimizações de Performance

### 1. Rendering Optimization

**Double Buffering Parcial:**
```c
// Buffer apenas para área modificada
static lv_color_t buf1[320 * 40];  // 40 linhas
static lv_color_t buf2[320 * 40];
static lv_disp_draw_buf_t draw_buf;

lv_disp_draw_buf_init(&draw_buf, buf1, buf2, 320 * 40);
```

**Dirty Region Tracking:**
```c
// Marcar apenas área modificada
lv_obj_invalidate_area(obj, &area);

// Atualizar apenas widgets alterados
if(value_changed) {
    lv_label_set_text_fmt(label, "%d", new_value);
    lv_obj_invalidate(label);  // Só redesenha o label
}
```

### 2. Memory Management

**Uso de Memória Típico:**
- LVGL Heap: 32KB
- Display Buffer: 25KB (double buffer parcial)
- Theme Storage: 2KB
- Widget Pool: 8KB
- **Total**: ~67KB RAM

**Otimizações:**
```c
// Usar memória estática quando possível
static lv_style_t style_button;
static lv_style_t style_label;

// Reutilizar styles
lv_style_init(&style_button);
lv_style_set_bg_color(&style_button, theme->bg_secondary);
lv_obj_add_style(btn1, &style_button, LV_PART_MAIN);
lv_obj_add_style(btn2, &style_button, LV_PART_MAIN);  // Reutiliza
```

### 3. Animation Performance

**Animações Otimizadas:**
```c
// Animação simples de fade
lv_anim_t a;
lv_anim_init(&a);
lv_anim_set_var(&a, obj);
lv_anim_set_values(&a, 0, 255);
lv_anim_set_time(&a, 200);  // 200ms - rápido
lv_anim_set_exec_cb(&a, (lv_anim_exec_xcb_t)lv_obj_set_style_opa);
lv_anim_start(&a);
```

**Frame Rate Target:**
- 30 FPS constante
- 33ms por frame máximo
- Redraw apenas áreas modificadas

## 🔄 Integração com Sistema

### Comunicação MQTT

**Tópicos Principais:**
```
# Receber configuração de tema
autocore/display/theme

# Receber configuração de telas
autocore/display/screens

# Publicar eventos de interação
autocore/display/events

# Receber atualizações de estado
autocore/relays/+/state
autocore/can/data
```

**Payload de Configuração de Tema:**
```json
{
  "theme": {
    "name": "dark_neumorphic",
    "colors": {
      "primary": "#007AFF",
      "secondary": "#32D74B",
      "background": "#1C1C1E",
      "surface": "#2C2C2E",
      "text_primary": "#FFFFFF",
      "text_secondary": "#8E8E93"
    },
    "style": {
      "border_radius": 10,
      "shadow_enabled": true,
      "animation_speed": 200,
      "font_size_base": 11
    }
  }
}
```

### Configuração Dinâmica de Telas

O display busca sua configuração completa do backend ao iniciar, permitindo customização total sem reprogramação:

**Endpoint de Configuração:**
```
GET http://{backend_ip}:{port}/api/config/generate/{display_uuid}
```

**Estrutura JSON Completa:**
```json
{
  "device": {
    "uuid": "esp32-display-001",
    "name": "Display Principal",
    "type": "display_touch"
  },
  "mqtt": {
    "broker": "localhost",
    "port": 1883,
    "username": "autocore",
    "password": "generated_password",
    "topics": {
      "config": "autocore/display/{uuid}/config",
      "events": "autocore/display/{uuid}/events",
      "heartbeat": "autocore/display/{uuid}/heartbeat",
      "telemetry": "autocore/display/{uuid}/telemetry"
    }
  },
  "screens": [
    {
      "id": "dashboard",
      "title": "Principal",
      "layout": {
        "type": "grid",
        "cols": 3,
        "rows": 3,
        "spacing": 4
      },
      "buttons": [
        {
          "id": "btn_headlight",
          "label": "Farol",
          "icon": "💡",
          "type": "toggle",
          "position": {"col": 0, "row": 0},
          "action": {
            "type": "relay",
            "channel": 1
          },
          "style": {
            "color_active": "#007AFF",
            "color_inactive": "#2C2C2E"
          }
        },
        {
          "id": "btn_starter",
          "label": "Partida",
          "icon": "🔑",
          "type": "momentary",
          "position": {"col": 1, "row": 0},
          "action": {
            "type": "relay",
            "channel": 2,
            "requires_heartbeat": true,
            "heartbeat_interval": 500,
            "timeout": 1000
          },
          "protection": {
            "type": "confirmation",
            "message": "Segurar para partida"
          },
          "style": {
            "color_active": "#FF9500",
            "color_inactive": "#2C2C2E"
          }
        }
      ]
    },
    {
      "id": "lighting",
      "title": "Iluminação",
      "layout": {
        "type": "list",
        "item_height": 44
      },
      "buttons": [
        {
          "id": "sw_high_beam",
          "label": "Farol Alto",
          "icon": "💡",
          "type": "switch",
          "action": {
            "type": "relay",
            "channel": 3
          }
        }
      ]
    }
  ],
  "theme": {
    "mode": "dark",
    "colors": {
      "primary": "#007AFF",
      "secondary": "#32D74B",
      "warning": "#FF9500",
      "danger": "#FF3B30",
      "background": "#1C1C1E",
      "surface": "#2C2C2E",
      "text_primary": "#FFFFFF",
      "text_secondary": "#8E8E93"
    },
    "fonts": {
      "size_small": 9,
      "size_normal": 11,
      "size_large": 14
    }
  }
}
```

### Sincronização de Estado

```c
// Subscriber MQTT para atualização de estado
void mqtt_callback(char* topic, byte* payload, unsigned int length) {
    if(strcmp(topic, "autocore/relays/1/state") == 0) {
        bool state = parse_bool(payload);
        
        // Atualizar UI
        lv_obj_t * switch_obj = find_widget_by_id("relay_1");
        if(state) {
            lv_obj_add_state(switch_obj, LV_STATE_CHECKED);
        } else {
            lv_obj_clear_state(switch_obj, LV_STATE_CHECKED);
        }
    }
}
```

## 📊 Métricas e Monitoramento

### Performance Metrics

```c
typedef struct {
    uint32_t fps_current;
    uint32_t fps_min;
    uint32_t fps_max;
    uint32_t frame_time_ms;
    uint32_t cpu_usage;
    uint32_t memory_used;
    uint32_t memory_free;
} display_metrics_t;

void update_metrics() {
    metrics.fps_current = lv_disp_get_fps(NULL);
    metrics.memory_used = lv_mem_monitor_get_used();
    metrics.memory_free = lv_mem_monitor_get_free();
    
    // Publicar métricas via MQTT
    publish_metrics(&metrics);
}
```

### Debug e Troubleshooting

**Log Levels:**
```c
LV_LOG_LEVEL_TRACE  // Desenvolvimento
LV_LOG_LEVEL_INFO   // Produção
LV_LOG_LEVEL_WARN   // Avisos
LV_LOG_LEVEL_ERROR  // Erros críticos
```

**Monitoramento em Tempo Real:**
- FPS Counter no canto superior direito
- RAM Usage indicator
- MQTT connection status
- Touch/Button input visualization

## 🎯 Guidelines de Implementação

### Do's ✅

1. **Use estilos reutilizáveis** ao invés de configurar cada widget
2. **Minimize animações** - máximo 200ms de duração
3. **Implemente dirty region tracking** para todas as atualizações
4. **Cache recursos** como ícones e fontes
5. **Use event-driven updates** ao invés de polling
6. **Teste sob luz solar** para validar contraste
7. **Implemente timeout** para ações críticas
8. **Mantenha hierarquia visual** clara

### Don'ts ❌

1. **Não use transparências complexas** - muito custoso
2. **Não anime múltiplos elementos** simultaneamente
3. **Não use fontes menores que 9px** - ilegível
4. **Não crie widgets dinamicamente** em runtime frequente
5. **Não ignore feedback háptico** - essencial para UX
6. **Não use gradientes complexos** - prefira cores sólidas
7. **Não bloqueie a UI thread** - use tasks assíncronas

## 🔧 Hardware Recomendado

### Display
- **Modelo**: ILI9341 ou ST7789
- **Resolução**: 320x240 pixels
- **Interface**: SPI (40MHz+)
- **Touch**: XPT2046 ou FT6236

### ESP32
- **Modelo**: ESP32-WROOM-32D ou superior
- **Flash**: 4MB mínimo
- **PSRAM**: Recomendado 4MB
- **Frequência**: 240MHz

### Pinos Recomendados
```c
#define TFT_CS   15
#define TFT_DC   2
#define TFT_RST  4
#define TFT_MOSI 23
#define TFT_CLK  18
#define TFT_MISO 19

#define TOUCH_CS  5
#define TOUCH_IRQ 27

#define BTN_PREV  32
#define BTN_SELECT 33
#define BTN_NEXT  25
```

## 📈 Evolução Futura

### Próximas Features

1. **Gesture Support** - Swipe para navegação
2. **Multi-language** - Português/Inglês/Espanhol
3. **Night Mode** - Tema automático por horário
4. **Voice Feedback** - TTS para acessibilidade
5. **OTA Updates** - Atualização remota da UI
6. **Custom Widgets** - Gauge, gráficos, compass
7. **Notification System** - Alertas visuais
8. **Data Logging** - Gráficos de telemetria

### Escalabilidade

- **Display 3.5"** (480x320) - Layout adaptativo
- **Display 5"** (800x480) - Mais informações
- **E-ink** - Modo ultra low power
- **OLED** - Alto contraste

## 📚 Referências

- [LVGL Documentation](https://docs.lvgl.io/)
- [ESP32 Display Drivers](https://github.com/lovyan03/LovyanGFX)
- [Material Design for Embedded](https://material.io/design/platform-guidance/android-automotive.html)
- [Tesla UI Guidelines](https://www.tesla.com/support/software)

---

*Este documento é parte do sistema AutoCore e deve ser mantido atualizado com cada iteração do desenvolvimento.*