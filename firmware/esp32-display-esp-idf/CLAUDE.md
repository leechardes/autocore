# 🤖 Instruções para Claude - ESP32 Display ESP-IDF

Este documento contém instruções específicas para assistentes IA (Claude) trabalharem com o projeto ESP32 Display Controller.

## 🎯 Contexto do Projeto

### Visão Geral
O ESP32 Display é um controlador de display de alta performance desenvolvido em C usando ESP-IDF v5.0. O projeto suporta múltiplos tipos de display e integra com o ecossistema AutoCore.

### Características Principais
- Suporte a múltiplos displays (ILI9341, ST7789, SSD1306, ILI9488)
- Integração com LVGL para gráficos avançados
- Touch controller opcional
- Conectividade WiFi/MQTT
- Otimização dual-core

## 🏗️ Arquitetura do Sistema

### Divisão de Cores
```
Core 0: Network, HTTP, MQTT, System
Core 1: Display Driver, LVGL, Touch, UI
```

### Componentes
```
firmware/esp32-display-esp-idf/
├── components/
│   ├── display_driver/     # HAL para displays
│   ├── ui_manager/         # Gerenciamento de UI
│   ├── touch_driver/       # Driver de touch
│   ├── config_manager/     # Configuração (NVS)
│   └── network/            # WiFi, HTTP, MQTT
└── main/                   # Aplicação principal
```

## ⚡ Funcionalidades Críticas

### 1. Display Driver
**IMPORTANTE**: O driver deve suportar múltiplos displays
- Abstração de hardware via HAL
- Suporte a SPI com DMA
- Buffer parcial para economia de RAM
- Rotação de tela configurável

```c
// Exemplo de inicialização
display_config_t config = {
    .width = 320,
    .height = 240,
    .mosi_gpio = 23,
    .sclk_gpio = 18,
    .cs_gpio = 5,
    .dc_gpio = 2,
    .rst_gpio = 4,
    .backlight_gpio = 15,
    .rotation = DISPLAY_ROTATION_0,
    .spi_clock_speed = 40000000
};
```

### 2. LVGL Integration
- Versão 8.x do LVGL
- Buffer duplo para smooth rendering
- Tick customizado via esp_timer
- Flush callback otimizado

### 3. Touch Controller
- Suporte XPT2046 e FT6236
- Calibração automática
- Debouncing de toque
- Gesture recognition

## 🛠️ Desenvolvimento

### Padrões de Código

```c
// Header guard padrão
#ifndef COMPONENT_NAME_H
#define COMPONENT_NAME_H

// Includes organizados
#include <stdint.h>        // Tipos padrão
#include "esp_err.h"       // Error handling
#include "driver/spi.h"    // Hardware específico

// Estruturas opacas para encapsulamento
typedef struct display_driver_s* display_handle_t;

// Sempre retornar esp_err_t
esp_err_t component_init(void);

#endif // COMPONENT_NAME_H
```

### Sistema de Logs
```c
static const char *TAG = "DISPLAY";

ESP_LOGE(TAG, "Error message");     // Erros
ESP_LOGW(TAG, "Warning");           // Avisos
ESP_LOGI(TAG, "Info");              // Informações
ESP_LOGD(TAG, "Debug");             // Debug
ESP_LOGV(TAG, "Verbose");           // Verbose
```

### Gestão de Memória
```c
// Preferir alocação estática
static uint16_t display_buffer[BUFFER_SIZE];

// Se dinâmica, sempre verificar
uint8_t* buffer = heap_caps_malloc(size, MALLOC_CAP_DMA);
if (buffer == NULL) {
    ESP_LOGE(TAG, "Failed to allocate %d bytes", size);
    return ESP_ERR_NO_MEM;
}
```

## 📡 Protocolo MQTT

### Topics
```
autocore/{device_id}/display/command  - Comandos
autocore/{device_id}/display/content  - Conteúdo
autocore/{device_id}/display/status   - Status
autocore/{device_id}/display/telemetry - Telemetria
```

### Estrutura de Comandos
```json
{
  "command": "text|rect|line|clear|image",
  "params": {
    // Parâmetros específicos do comando
  },
  "timestamp": 1234567890
}
```

## 🔒 Segurança

### Validações Obrigatórias
1. **Boundary checking** - Sempre verificar limites X/Y
2. **Buffer overflow** - Validar tamanhos de buffer
3. **Input sanitization** - Limpar strings de entrada
4. **SPI mutex** - Proteger acesso ao barramento
5. **Touch debouncing** - Evitar toques fantasma

### Exemplo de Validação
```c
esp_err_t display_draw_pixel(display_handle_t handle, 
                            int16_t x, int16_t y, 
                            uint16_t color) {
    // Validar handle
    if (handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    
    // Validar coordenadas
    if (x < 0 || x >= handle->width || 
        y < 0 || y >= handle->height) {
        return ESP_ERR_INVALID_ARG;
    }
    
    // Operação segura
    return display_set_pixel_internal(handle, x, y, color);
}
```

## 🐛 Debugging

### Problemas Comuns

#### 1. Display em Branco
```c
// Verificar:
- Backlight GPIO e nível
- Reset sequence timing
- SPI clock speed (reduzir para 10MHz para teste)
- Power supply (3.3V estável)
```

#### 2. Cores Incorretas
```c
// Verificar:
- Color mode (RGB565 vs RGB666)
- Byte swap (CONFIG_LV_COLOR_16_SWAP)
- Endianness
```

#### 3. Touch Não Responde
```c
// Verificar:
- Touch CS separado do display CS
- Interrupt pin configurado
- Calibração necessária
```

## 🚀 Otimizações

### Performance
1. **Use DMA** para transferências SPI
2. **Buffer parcial** para economizar RAM
3. **Dual-core** - Display no Core 1
4. **Cache SPI** comandos frequentes
5. **Batch updates** - Agrupar desenhos

### Exemplo de Otimização
```c
// Ruim - Múltiplas transações
for (int i = 0; i < 100; i++) {
    display_draw_pixel(handle, x[i], y[i], color);
}

// Bom - Transação única
display_draw_points(handle, points, 100, color);
```

## 📋 Checklist para Modificações

### Novo Display Driver
- [ ] Criar arquivos em `components/display_driver/src/`
- [ ] Implementar interface HAL completa
- [ ] Adicionar ao Kconfig
- [ ] Testar rotações (0°, 90°, 180°, 270°)
- [ ] Validar com LVGL
- [ ] Documentar pinout e configuração

### Nova Feature UI
- [ ] Design no LVGL Simulator primeiro
- [ ] Implementar em `ui_manager`
- [ ] Adicionar comandos MQTT se aplicável
- [ ] Testar responsividade
- [ ] Verificar memory leaks

## 🔄 Workflow Git

### Branches
```
main       - Produção
develop    - Desenvolvimento
feature/*  - Novas funcionalidades
display/*  - Drivers de display
ui/*       - Interface updates
```

### Commit Format
```bash
tipo(escopo): descrição

# Exemplos
feat(ili9341): adiciona suporte a 18-bit color
fix(touch): corrige calibração XPT2046
perf(spi): otimiza DMA transfers
docs(api): atualiza endpoints HTTP
```

## 📊 Métricas de Qualidade

### Performance Targets
- **FPS**: > 30 (60 ideal)
- **Touch latency**: < 20ms
- **Boot time**: < 3s
- **RAM usage**: < 100KB
- **SPI clock**: 40MHz (máx 80MHz)

### Medição de FPS
```c
static uint32_t frame_count = 0;
static int64_t last_time = 0;

void measure_fps(void) {
    frame_count++;
    int64_t now = esp_timer_get_time();
    if (now - last_time > 1000000) { // 1 segundo
        ESP_LOGI(TAG, "FPS: %lu", frame_count);
        frame_count = 0;
        last_time = now;
    }
}
```

## ⚠️ Avisos Importantes

### NÃO FAZER
- ❌ Acessar SPI sem mutex
- ❌ Alocar buffers grandes na stack
- ❌ Ignorar limites de coordenadas
- ❌ Usar delays no display task
- ❌ Misturar lógica de UI com drivers

### SEMPRE FAZER
- ✅ Validar todos os parâmetros
- ✅ Usar DMA para transferências grandes
- ✅ Implementar timeout em operações
- ✅ Testar com displays reais
- ✅ Documentar configuração de pinos

## 🎯 Prioridades do Projeto

1. **Compatibilidade** - Suportar múltiplos displays
2. **Performance** - 60 FPS quando possível
3. **Modularidade** - Componentes independentes
4. **Usabilidade** - Interface intuitiva
5. **Documentação** - Clara e completa

## 💡 Dicas para Claude

### Ao Implementar Novo Display
1. Estudar datasheet do controller
2. Verificar comandos de inicialização
3. Implementar funções básicas primeiro
4. Testar com padrões simples
5. Otimizar depois de funcionar

### Ao Debugar Display
1. Reduzir SPI speed para 10MHz
2. Adicionar logs verbose
3. Verificar sinais com osciloscópio/analisador lógico
4. Testar comandos individuais
5. Comparar com código de referência

### Ao Otimizar
1. Perfil com esp_timer
2. Identificar gargalos
3. Usar DMA quando possível
4. Minimizar cópias de memória
5. Batch operations

## 📝 Notas Finais

Este projeto faz parte do ecossistema **AutoCore** e deve manter compatibilidade com:
- Backend AutoCore (Node.js)
- Config App (Next.js)
- Mobile App (Flutter)
- ESP32-Relay (Dispositivo irmão)

**Versão atual**: 1.0.0
**ESP-IDF**: v5.0+
**LVGL**: v8.3+

---

*"A good display driver is invisible - users only notice when it doesn't work."*