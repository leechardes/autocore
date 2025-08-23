# Display ILI9341 Specifications

## 📱 Especificações Técnicas

### Características Gerais
- **Controlador**: ILI9341
- **Resolução**: 240x320 pixels
- **Interface**: SPI 4-wire
- **Cores**: 262K (18-bit) / 65K (16-bit)
- **Tensão**: 3.3V
- **Backlight**: LED controlável via PWM

### Especificações Elétricas
- **Tensão de Operação**: 2.8V - 3.3V
- **Corrente Display**: ~20mA (sem backlight)
- **Corrente Backlight**: ~100mA (máximo)
- **Frequência SPI**: Até 80MHz (65MHz recomendado)

## 🔧 Configuração do Driver

### Configurações PlatformIO
```ini
build_flags = 
    -D ILI9341_2_DRIVER=1      # Driver alternativo mais compatível
    -D TFT_WIDTH=240
    -D TFT_HEIGHT=320
    -D TFT_INVERSION_ON=1      # Correção fundo branco
    -D SPI_FREQUENCY=65000000
    -D SPI_READ_FREQUENCY=20000000
```

### Configurações TFT_eSPI
```cpp
// User_Setup.h configurações
#define ILI9341_2_DRIVER
#define TFT_WIDTH  240
#define TFT_HEIGHT 320
#define TFT_MISO 12
#define TFT_MOSI 13
#define TFT_SCLK 14
#define TFT_CS   15
#define TFT_DC   2
#define TFT_RST  12
#define TFT_BL   21
```

## 🎨 Características de Cores

### Formatos Suportados
- **RGB565**: 16-bit (padrão para ESP32)
- **RGB666**: 18-bit (qualidade superior)
- **RGB888**: 24-bit (não suportado diretamente)

### Paleta de Cores Comuns
```cpp
#define TFT_BLACK       0x0000
#define TFT_NAVY        0x000F
#define TFT_DARKGREEN   0x03E0
#define TFT_DARKCYAN    0x03EF
#define TFT_MAROON      0x7800
#define TFT_PURPLE      0x780F
#define TFT_OLIVE       0x7BE0
#define TFT_LIGHTGREY   0xC618
#define TFT_DARKGREY    0x7BEF
#define TFT_BLUE        0x001F
#define TFT_GREEN       0x07E0
#define TFT_CYAN        0x07FF
#define TFT_RED         0xF800
#define TFT_MAGENTA     0xF81F
#define TFT_YELLOW      0xFFE0
#define TFT_WHITE       0xFFFF
```

## 📐 Orientação e Rotação

### Configurações de Rotação
```cpp
tft.setRotation(0);  // Portrait (240x320)
tft.setRotation(1);  // Landscape (320x240)
tft.setRotation(2);  // Portrait invertido
tft.setRotation(3);  // Landscape invertido
```

### Configuração LVGL
```cpp
// lv_conf.h
#define LV_HOR_RES_MAX 240
#define LV_VER_RES_MAX 320
#define LV_COLOR_DEPTH 16
```

## ⚡ Controle de Backlight

### PWM Control
```cpp
// Setup PWM para backlight
#define BACKLIGHT_PWM_CHANNEL 0
#define BACKLIGHT_PWM_FREQ 5000
#define BACKLIGHT_PWM_RESOLUTION 8

void setupBacklight() {
    ledcSetup(BACKLIGHT_PWM_CHANNEL, BACKLIGHT_PWM_FREQ, BACKLIGHT_PWM_RESOLUTION);
    ledcAttachPin(TFT_BL, BACKLIGHT_PWM_CHANNEL);
}

// Controle de brilho (0-255)
void setBrightness(uint8_t brightness) {
    ledcWrite(BACKLIGHT_PWM_CHANNEL, brightness);
}
```

### Sleep Mode
```cpp
void displaySleep() {
    ledcWrite(BACKLIGHT_PWM_CHANNEL, 0);  // Desliga backlight
    tft.writecommand(0x10);               // Sleep in
}

void displayWakeup() {
    tft.writecommand(0x11);               // Sleep out
    delay(120);                           // Aguarda inicialização
    ledcWrite(BACKLIGHT_PWM_CHANNEL, 255); // Liga backlight
}
```

## 🚀 Performance e Otimização

### SPI Performance
- **Frequência Máxima**: 65MHz (estável)
- **DMA**: Habilitado para transfers grandes
- **Buffer**: Usado para operações batch

### Memory Layout
- **Frame Buffer**: 240x320x2 = 153.6KB (se usado)
- **LVGL Buffer**: Configurável (1/10 da tela recomendado)

### Otimizações Comuns
```cpp
// Otimizações de performance
#define LV_MEM_SIZE (48 * 1024U)     // 48KB para LVGL
#define LV_DISP_DEF_REFR_PERIOD 16   // 60fps refresh rate
#define LV_USE_GPU_ESP32 1           // Aceleração hardware
```

## 🔍 Troubleshooting

### Problemas Comuns

#### Fundo Branco/Cores Invertidas
```cpp
// Solução: Usar inversão de cores
#define TFT_INVERSION_ON 1
```

#### Display Não Inicializa
- Verificar conexões SPI
- Confirmar tensão 3.3V
- Testar pin RST

#### Performance Baixa
- Reduzir frequência SPI se instável
- Otimizar buffers LVGL
- Usar DMA quando possível

#### Tela Piscando
- Verificar refresh rate LVGL
- Confirmar frequência PWM backlight
- Testar alimentação estável