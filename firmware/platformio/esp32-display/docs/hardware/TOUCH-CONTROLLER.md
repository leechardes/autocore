# Touch Controller XPT2046

## 📱 Especificações Técnicas

### Características Gerais
- **Controlador**: XPT2046
- **Tipo**: Resistivo 4-wire
- **Resolução**: 12-bit (4096 níveis)
- **Interface**: SPI 3-wire
- **Tensão**: 2.7V - 5.25V
- **Frequência SPI**: Máximo 2.5MHz

### Precisão e Características
- **Resolução de conversão**: 12-bit
- **Precisão**: ±1 LSB
- **Taxa de conversão**: Até 125kHz
- **Resistência touch**: 300Ω - 9kΩ

## 🔧 Configuração Hardware

### Conexões SPI
```cpp
#define TOUCH_CS 33     // Chip Select dedicado
// Pinos compartilhados com display:
// MISO: GPIO 12
// MOSI: GPIO 13  
// SCLK: GPIO 14
```

### Configuração PlatformIO
```ini
lib_deps = 
    https://github.com/PaulStoffregen/XPT2046_Touchscreen.git

build_flags =
    -D TOUCH_CS=33
    -D SPI_TOUCH_FREQUENCY=2500000
```

## 👆 Configuração Software

### Inicialização
```cpp
#include <XPT2046_Touchscreen.h>

// Definir CS pin para touch
#define TOUCH_CS_PIN 33

// Criar instância do touchscreen
XPT2046_Touchscreen touch(TOUCH_CS_PIN);

void setupTouch() {
    touch.begin();
    touch.setRotation(1);  // Ajustar conforme orientação display
}
```

### Calibração
```cpp
// Valores de calibração para tela 240x320
struct TouchCalibration {
    int16_t x_min = 350;    // Valor ADC mínimo X
    int16_t x_max = 3800;   // Valor ADC máximo X  
    int16_t y_min = 350;    // Valor ADC mínimo Y
    int16_t y_max = 3800;   // Valor ADC máximo Y
};

// Converter coordenadas raw para pixels
Point convertToPixels(int16_t raw_x, int16_t raw_y) {
    Point pixel;
    pixel.x = map(raw_x, cal.x_min, cal.x_max, 0, 240);
    pixel.y = map(raw_y, cal.y_min, cal.y_max, 0, 320);
    
    // Aplicar limites
    pixel.x = constrain(pixel.x, 0, 239);
    pixel.y = constrain(pixel.y, 0, 319);
    
    return pixel;
}
```

## 🎯 Integração com LVGL

### Setup Input Device
```cpp
static lv_indev_drv_t indev_drv;

void setupLVGLTouch() {
    lv_indev_drv_init(&indev_drv);
    indev_drv.type = LV_INDEV_TYPE_POINTER;
    indev_drv.read_cb = touchpad_read;
    lv_indev_drv_register(&indev_drv);
}

// Callback de leitura para LVGL
void touchpad_read(lv_indev_drv_t* indev_driver, lv_indev_data_t* data) {
    if (touch.touched()) {
        TS_Point point = touch.getPoint();
        
        // Converter coordenadas
        Point pixel = convertToPixels(point.x, point.y);
        
        data->point.x = pixel.x;
        data->point.y = pixel.y;
        data->state = LV_INDEV_STATE_PR;
    } else {
        data->state = LV_INDEV_STATE_REL;
    }
}
```

### Filtros e Debouncing
```cpp
class TouchFilter {
private:
    static const int SAMPLES = 3;
    Point samples[SAMPLES];
    int sample_index = 0;
    unsigned long last_touch = 0;
    static const unsigned long DEBOUNCE_TIME = 50;
    
public:
    Point getFilteredPoint() {
        if (millis() - last_touch < DEBOUNCE_TIME) {
            return {-1, -1};  // Ignorar toque muito rápido
        }
        
        if (touch.touched()) {
            TS_Point raw = touch.getPoint();
            Point current = convertToPixels(raw.x, raw.y);
            
            // Adicionar à média móvel
            samples[sample_index] = current;
            sample_index = (sample_index + 1) % SAMPLES;
            
            // Calcular média
            Point avg = {0, 0};
            for (int i = 0; i < SAMPLES; i++) {
                avg.x += samples[i].x;
                avg.y += samples[i].y;
            }
            avg.x /= SAMPLES;
            avg.y /= SAMPLES;
            
            last_touch = millis();
            return avg;
        }
        
        return {-1, -1};  // Não tocado
    }
};
```

## 🔧 Implementação no TouchHandler

### Análise do Código Atual
```cpp
// De: include/input/TouchHandler.h
class TouchHandler {
private:
    XPT2046_Touchscreen* touchscreen;
    Logger* logger;
    lv_indev_t* indev_touchpad;
    
    // Calibração
    int16_t touch_cal_x1, touch_cal_x2;
    int16_t touch_cal_y1, touch_cal_y2;
    
public:
    void init();
    void calibrate();
    static void touchpad_read(lv_indev_drv_t* drv, lv_indev_data_t* data);
};
```

### Configurações de Calibração
```cpp
// Valores típicos para calibração
void TouchHandler::setCalibration() {
    // Cantos da tela para calibração
    touch_cal_x1 = 300;   // Borda esquerda (ADC)
    touch_cal_x2 = 3700;  // Borda direita (ADC)
    touch_cal_y1 = 300;   // Borda superior (ADC)
    touch_cal_y2 = 3700;  // Borda inferior (ADC)
}

// Converter coordenadas com rotação
Point TouchHandler::screenToTouch(int16_t x, int16_t y) {
    Point result;
    
    // Aplicar rotação conforme display
    switch (rotation) {
        case 0: // Portrait
            result.x = map(x, 0, 240, touch_cal_x1, touch_cal_x2);
            result.y = map(y, 0, 320, touch_cal_y1, touch_cal_y2);
            break;
        case 1: // Landscape
            result.x = map(y, 0, 240, touch_cal_x1, touch_cal_x2);
            result.y = map(320-x, 0, 320, touch_cal_y1, touch_cal_y2);
            break;
        // Adicionar outras rotações conforme necessário
    }
    
    return result;
}
```

## 🚀 Performance e Otimização

### Configurações SPI
```cpp
// Configuração otimizada do SPI para touch
void TouchHandler::setupSPI() {
    // Frequência reduzida para estabilidade
    // XPT2046 máximo: 2.5MHz
    SPI.beginTransaction(SPISettings(2500000, MSBFIRST, SPI_MODE0));
}
```

### Gerenciamento de Interrupts
```cpp
// Opção: usar interrupt para detecção de toque
#define TOUCH_IRQ_PIN 4  // Pin opcional para IRQ

volatile bool touch_detected = false;

void IRAM_ATTR touchISR() {
    touch_detected = true;
}

void setupTouchInterrupt() {
    pinMode(TOUCH_IRQ_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(TOUCH_IRQ_PIN), touchISR, FALLING);
}
```

## 🔍 Troubleshooting

### Problemas Comuns

#### Touch Não Responde
1. Verificar conexões SPI
2. Confirmar CS pin (GPIO 33)
3. Testar frequência SPI (reduzir se necessário)
4. Verificar alimentação 3.3V

#### Coordenadas Erradas
1. Executar calibração
2. Verificar rotação do display
3. Ajustar valores de mapeamento
4. Confirmar orientação touch vs display

#### Sensibilidade Inadequada
```cpp
// Ajustar threshold de pressão
#define TOUCH_THRESHOLD 350  // Valor mínimo para toque válido

bool TouchHandler::isTouchValid(TS_Point point) {
    return (point.z > TOUCH_THRESHOLD);
}
```

#### Ruído/Instabilidade
1. Adicionar filtro de média móvel
2. Implementar debouncing
3. Usar multiple sampling
4. Verificar blindagem EMI

### Diagnósticos
```cpp
void TouchHandler::printDiagnostics() {
    if (touch.touched()) {
        TS_Point p = touch.getPoint();
        logger->debug("Touch Raw: X=" + String(p.x) + 
                     " Y=" + String(p.y) + 
                     " Z=" + String(p.z));
        
        Point pixel = convertToPixels(p.x, p.y);
        logger->debug("Touch Pixel: X=" + String(pixel.x) + 
                     " Y=" + String(pixel.y));
    }
}
```