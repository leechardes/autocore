# ESP32 Pinout Configuration

## 🔌 Pin Mapping

### Display (ILI9341) - SPI Interface
| Função | ESP32 GPIO | Descrição |
|--------|------------|-----------|
| MISO   | GPIO 12    | Master In Slave Out |
| MOSI   | GPIO 13    | Master Out Slave In |
| SCLK   | GPIO 14    | Serial Clock |
| CS     | GPIO 15    | Chip Select |
| DC     | GPIO 2     | Data/Command |
| RST    | GPIO 12    | Reset (compartilhado com MISO) |
| BL     | GPIO 21    | Backlight Control |

### Touch Controller (XPT2046) - SPI Interface
| Função | ESP32 GPIO | Descrição |
|--------|------------|-----------|
| CS     | GPIO 33    | Chip Select Touch |
| MISO   | GPIO 12    | Compartilhado com display |
| MOSI   | GPIO 13    | Compartilhado com display |
| SCLK   | GPIO 14    | Compartilhado com display |

### Configurações SPI
```cpp
// Display SPI Configuration
#define TFT_MISO 12
#define TFT_MOSI 13
#define TFT_SCLK 14
#define TFT_CS   15
#define TFT_DC   2
#define TFT_RST  12
#define TFT_BL   21

// Touch SPI Configuration  
#define TOUCH_CS 33
#define USE_HSPI_PORT  // Usa HSPI em vez de VSPI
```

### Frequências SPI
- Display: 65 MHz (alta performance)
- Touch: 2.5 MHz (estabilidade)
- Leitura: 20 MHz

## 🔧 Pinos Livres Disponíveis

### Digitais Disponíveis
- GPIO 0, 4, 5, 16, 17, 18, 19, 22, 23, 25, 26, 27, 32

### ADC Disponíveis  
- ADC1: GPIO 32, 33, 34, 35, 36, 37, 38, 39
- ADC2: GPIO 0, 2, 4, 12, 13, 14, 15, 25, 26, 27

### PWM Disponíveis
Todos os pinos digitais suportam PWM via LEDC

## ⚠️ Considerações Importantes

### Pinos com Restrições
- **GPIO 0**: Boot mode (pull-up necessário)
- **GPIO 2**: Deve estar LOW durante boot
- **GPIO 12**: Compartilhado RST/MISO (cuidado com conflitos)
- **GPIO 15**: CS display (pull-up interno)

### Pinos Apenas Input
- GPIO 34, 35, 36, 37, 38, 39 (sem pull-up/pull-down interno)

### Pinos Strapping
- GPIO 0, 2, 5, 12, 15 são usados durante boot

## 🔌 Expansão de Hardware

### I2C Recomendado
- SDA: GPIO 22
- SCL: GPIO 23

### UART Adicional
- TX: GPIO 17
- RX: GPIO 16

### Relay Control (exemplo)
- Relay 1: GPIO 25
- Relay 2: GPIO 26  
- Relay 3: GPIO 27
- Relay 4: GPIO 32