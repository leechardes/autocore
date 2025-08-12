# 🔌 Hardware Guide - AutoTech HMI Display v2

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Componentes Principais](#componentes-principais)
- [ESP32 DevKit Pinout](#esp32-devkit-pinout)
- [Display ILI9341](#display-ili9341)
- [Touch Screen XPT2046](#touch-screen-xpt2046)
- [Botões de Navegação](#botões-de-navegação)
- [LEDs de Status RGB](#leds-de-status-rgb)
- [Esquemático de Conexões](#esquemático-de-conexões)
- [Lista de Componentes](#lista-de-componentes)
- [Montagem e Instalação](#montagem-e-instalação)
- [Alimentação](#alimentação)
- [Troubleshooting Hardware](#troubleshooting-hardware)

## 🎯 Visão Geral

O AutoTech HMI Display v2 é baseado na placa de desenvolvimento ESP32-2432S028R, uma solução integrada que combina:

- **Processador**: ESP32-WROOM-32 (Dual Core, WiFi, Bluetooth)
- **Display**: ILI9341 TFT LCD 2.8" 320x240 pixels
- **Touch**: XPT2046 resistivo
- **Conectores**: GPIO expandidos para botões e LEDs
- **Alimentação**: 5V DC via USB-C ou pinos VIN

### Especificações Técnicas

| Especificação | Valor |
|---------------|--------|
| **Processador** | ESP32-WROOM-32 (240MHz, Dual Core) |
| **Memória Flash** | 4MB |
| **RAM** | 320KB |
| **Display** | ILI9341 2.8" 320x240 TFT |
| **Touch** | XPT2046 Resistivo |
| **Conectividade** | WiFi 802.11 b/g/n, Bluetooth 4.2 |
| **Alimentação** | 5V DC, 500mA típico |
| **Temperatura** | -10°C a +70°C |
| **Dimensões** | 95 x 56 x 13 mm |

## 🧩 Componentes Principais

### 1. **ESP32-WROOM-32 Module**
```
Características:
• Dual Core Xtensa 32-bit LX6 @ 240MHz
• 520KB SRAM + 4MB Flash
• WiFi 802.11 b/g/n (2.4GHz)
• Bluetooth Classic + BLE
• 30 pinos GPIO
• 12-bit ADC
• PWM, I2C, SPI, UART
```

### 2. **ILI9341 Display Controller**
```
Especificações:
• Resolução: 320x240 pixels
• Interface: SPI 4-wire
• Cores: 262K (18-bit)
• Backlight: LED branco controlável
• Ângulo de visão: 140°
```

### 3. **XPT2046 Touch Controller**
```
Características:
• Tipo: Resistivo 4-wire
• Resolução: 12-bit
• Interface: SPI
• Precisão: ±2 pixels
• Pressão de ativação: 150g
```

## 📌 ESP32 DevKit Pinout

### Pinagem Oficial ESP32-2432S028R

```
                     ESP32-2432S028R
                    ┌─────────────────┐
                 EN │1              30│ GPIO23 (MOSI)  → TFT_MOSI
              GPIO36 │2              29│ GPIO22
              GPIO39 │3              28│ GPIO1  (TX)
              GPIO34 │4              27│ GPIO3  (RX)
              GPIO35 │5              26│ GPIO21 → TFT_BL
              GPIO32 │6              25│ GPIO19
              GPIO33 │7              24│ GPIO18 → TFT_CLK
              GPIO25 │8              23│ GPIO5
              GPIO26 │9              22│ GPIO17
              GPIO27 │10             21│ GPIO16
              GPIO14 │11             20│ GPIO4  → TFT_RST
              GPIO12 │12             19│ GPIO2  → TFT_DC
                GND │13             18│ GPIO15 → TFT_CS
                VIN │14             17│ GPIO8
               3.3V │15             16│ GPIO7
                    └─────────────────┘
```

### Mapeamento de Pinos para o Projeto

#### Display ILI9341 (SPI)
```cpp
#define TFT_CS    15    // Chip Select
#define TFT_DC    2     // Data/Command
#define TFT_RST   12    // Reset (conectado via resistor)
#define TFT_MOSI  13    // SDA/MOSI
#define TFT_CLK   14    // SCL/SCLK
#define TFT_MISO  12    // MISO (compartilhado com RST)
#define TFT_BL    21    // Backlight (PWM)
```

#### Touch Screen XPT2046 (SPI separado)
```cpp
#define XPT2046_IRQ  36    // Interrupt (touch detect)
#define XPT2046_CS   33    // Chip Select
#define XPT2046_MOSI 32    // MOSI
#define XPT2046_MISO 39    // MISO
#define XPT2046_CLK  25    // Clock
```

#### Botões de Navegação
```cpp
#define BTN_PREV_PIN   35    // Botão Previous/Anterior
#define BTN_SELECT_PIN 0     // Botão Select/OK (BOOT)
#define BTN_NEXT_PIN   34    // Botão Next/Próximo
```

#### LEDs RGB de Status
```cpp
#define LED_R_PIN  4     // LED Vermelho
#define LED_G_PIN  16    // LED Verde  
#define LED_B_PIN  17    // LED Azul
```

#### Pinos Reservados/Especiais
```cpp
// Não usar - Reservados para Flash SPI
GPIO6, GPIO7, GPIO8, GPIO9, GPIO10, GPIO11

// Input Only - Não podem ser output
GPIO34, GPIO35, GPIO36, GPIO39

// Boot/Download Mode - Cuidado no uso
GPIO0  - BOOT button (usado como BTN_SELECT)
GPIO2  - TFT_DC (OK para uso)
GPIO15 - TFT_CS (OK para uso)
```

## 📺 Display ILI9341

### Especificações Detalhadas

```
Modelo: ILI9341 2.8" TFT LCD
┌─────────────────┐
│                 │
│     320x240     │ ← Resolução nativa
│    16-bit RGB   │ ← 65K cores
│                 │
└─────────────────┘
     Landscape Mode (rotação 1)
```

### Conexões SPI Display

| Pino Display | Pino ESP32 | Função |
|-------------|------------|---------|
| VCC | 3.3V | Alimentação |
| GND | GND | Terra |
| CS | GPIO15 | Chip Select |
| RESET | GPIO12 | Reset (via resistor) |
| DC | GPIO2 | Data/Command |
| SDI(MOSI) | GPIO13 | Dados SPI |
| SCK | GPIO14 | Clock SPI |
| LED | GPIO21 | Backlight (PWM) |
| SDO(MISO) | GPIO12 | Dados SPI (retorno) |

### Configuração do Driver
```cpp
// TFT_eSPI User_Setup personalizado
#define ILI9341_2_DRIVER      // Driver alternativo
#define TFT_WIDTH  240        // Largura após rotação
#define TFT_HEIGHT 320        // Altura após rotação
#define TFT_INVERSION_ON      // Correção cores ESP32-2432S028R
#define SPI_FREQUENCY  65000000    // 65MHz para performance
#define SPI_READ_FREQUENCY 20000000 // 20MHz para leitura
```

### Controle de Brilho (PWM)
```cpp
// Canal PWM 0, 5000Hz, 8-bit (0-255)
ledcSetup(0, 5000, 8);
ledcAttachPin(TFT_BACKLIGHT_PIN, 0);
ledcWrite(0, brightness); // 0=off, 255=máximo
```

## 👆 Touch Screen XPT2046

### Especificações

```
Tipo: Resistivo 4-wire
Resolução: 12-bit (4096 x 4096)
Interface: SPI
Velocidade: Até 2.5MHz
Alimentação: 3.3V
```

### Conexões SPI Touch

| Pino Touch | Pino ESP32 | Função |
|------------|------------|---------|
| VCC | 3.3V | Alimentação |
| GND | GND | Terra |
| CS | GPIO33 | Chip Select |
| IRQ | GPIO36 | Interrupt (opcional) |
| DIN | GPIO32 | MOSI |
| DO | GPIO39 | MISO |
| CLK | GPIO25 | Clock SPI |

### Calibração do Touch

```cpp
// Valores específicos para ESP32-2432S028R
#define TOUCH_MIN_X 200    // Valor mínimo X
#define TOUCH_MAX_X 3700   // Valor máximo X
#define TOUCH_MIN_Y 240    // Valor mínimo Y
#define TOUCH_MAX_Y 3800   // Valor máximo Y

// Mapeamento para coordenadas de tela
int mapTouchX(int touchX) {
    return map(touchX, TOUCH_MIN_X, TOUCH_MAX_X, 0, 320);
}

int mapTouchY(int touchY) {
    return map(touchY, TOUCH_MIN_Y, TOUCH_MAX_Y, 0, 240);
}
```

### Detecção de Toque
```cpp
#include <XPT2046_Touchscreen.h>

XPT2046_Touchscreen touch(XPT2046_CS, XPT2046_IRQ);

void setup() {
    touch.begin();
    touch.setRotation(1); // Mesmo que display
}

void loop() {
    if (touch.touched()) {
        TS_Point p = touch.getPoint();
        int x = mapTouchX(p.x);
        int y = mapTouchY(p.y);
        // Processar toque em (x, y)
    }
}
```

## 🔘 Botões de Navegação

### Layout Físico Recomendado

```
    [PREV] [SELECT] [NEXT]
      ←       OK       →
   GPIO35   GPIO0   GPIO34
```

### Configuração dos Botões

```cpp
// Configuração com pull-up interno
pinMode(BTN_PREV_PIN, INPUT_PULLUP);
pinMode(BTN_SELECT_PIN, INPUT_PULLUP);
pinMode(BTN_NEXT_PIN, INPUT_PULLUP);

// Leitura com lógica invertida (LOW = pressionado)
bool prevPressed = !digitalRead(BTN_PREV_PIN);
bool selectPressed = !digitalRead(BTN_SELECT_PIN);
bool nextPressed = !digitalRead(BTN_NEXT_PIN);
```

### Debounce e Long Press

```cpp
class ButtonHandler {
    unsigned long lastPress[3] = {0};
    unsigned long pressStart[3] = {0};
    bool lastState[3] = {false};
    
    static const unsigned long DEBOUNCE_DELAY = 50;
    static const unsigned long LONG_PRESS_TIME = 1000;
    
public:
    bool checkButton(int buttonIndex, int pin) {
        bool currentState = !digitalRead(pin);
        unsigned long now = millis();
        
        if (currentState != lastState[buttonIndex]) {
            lastPress[buttonIndex] = now;
            if (currentState) {
                pressStart[buttonIndex] = now;
            }
        }
        
        if (now - lastPress[buttonIndex] > DEBOUNCE_DELAY) {
            if (currentState && !lastState[buttonIndex]) {
                lastState[buttonIndex] = currentState;
                return true; // Press detectado
            }
        }
        
        lastState[buttonIndex] = currentState;
        return false;
    }
    
    bool isLongPress(int buttonIndex) {
        if (lastState[buttonIndex]) {
            return (millis() - pressStart[buttonIndex]) > LONG_PRESS_TIME;
        }
        return false;
    }
};
```

## 💡 LEDs de Status RGB

### Configuração dos LEDs

```cpp
// Configuração como saídas
pinMode(LED_R_PIN, OUTPUT);
pinMode(LED_G_PIN, OUTPUT);
pinMode(LED_B_PIN, OUTPUT);

// LEDs são Common Cathode (LOW = acende)
digitalWrite(LED_R_PIN, LOW);   // Vermelho ON
digitalWrite(LED_G_PIN, HIGH);  // Verde OFF
digitalWrite(LED_B_PIN, HIGH);  // Azul OFF
```

### Códigos de Status

| Cor | Status | Situação |
|-----|--------|----------|
| 🔴 **Vermelho** | Erro/Desconectado | Falha WiFi/MQTT |
| 🟡 **Amarelo** | Aguardando | Conectando/Config |
| 🟢 **Verde** | Operacional | Sistema OK |
| 🔵 **Azul** | Configurando | Recebendo config |
| 🟣 **Roxo** | Atualizando | OTA/Hot-reload |
| ⚪ **Branco** | Teste | Modo diagnóstico |
| ⚫ **Desligado** | Standby | Sistema inativo |

### Implementação de Cores

```cpp
enum StatusColor {
    OFF,     // 000
    RED,     // 001
    GREEN,   // 010
    BLUE,    // 100
    YELLOW,  // 011 (Red + Green)
    PURPLE,  // 101 (Red + Blue)
    CYAN,    // 110 (Green + Blue)
    WHITE    // 111 (All)
};

void setStatusLED(StatusColor color) {
    digitalWrite(LED_R_PIN, !(color & 1));
    digitalWrite(LED_G_PIN, !((color >> 1) & 1));
    digitalWrite(LED_B_PIN, !((color >> 2) & 1));
}

void setStatus(SystemStatus status) {
    switch(status) {
        case SYSTEM_ERROR:        setStatusLED(RED); break;
        case SYSTEM_CONNECTING:   setStatusLED(YELLOW); break;
        case SYSTEM_READY:        setStatusLED(GREEN); break;
        case SYSTEM_CONFIGURING:  setStatusLED(BLUE); break;
        case SYSTEM_UPDATING:     setStatusLED(PURPLE); break;
        default:                  setStatusLED(OFF);
    }
}
```

## 🔌 Esquemático de Conexões

### Diagrama Simplificado

```
                    ESP32-2432S028R
                   ┌─────────────────┐
                   │                 │
    TFT Display ───┤ 15,2,12,13,14   │
                   │                 │
    Touch XPT2046 ─┤ 33,36,32,39,25  │
                   │                 │
    Buttons ───────┤ 35,0,34         │
                   │                 │
    Status LEDs ───┤ 4,16,17         │
                   │                 │
    Backlight PWM ─┤ 21              │
                   │                 │
                   └─────────────────┘

External Connections:
┌──────────────────────────────────────┐
│ Power: USB-C 5V ou VIN/GND          │
│ Serial: GPIO1(TX), GPIO3(RX)        │
│ I2C: GPIO21(SDA), GPIO22(SCL)       │
│ Extra GPIO: 26,27,25,32 disponíveis │
└──────────────────────────────────────┘
```

### Conexões Externas Opcionais

```
Conectores Expandidos:
┌─────────────────────────────────────┐
│ J1: Botões Externos                 │
│  Pin 1: BTN_PREV (GPIO35)          │
│  Pin 2: BTN_SELECT (GPIO0)         │
│  Pin 3: BTN_NEXT (GPIO34)          │
│  Pin 4: GND                        │
├─────────────────────────────────────┤
│ J2: LEDs Externos                   │
│  Pin 1: LED_R (GPIO4)              │
│  Pin 2: LED_G (GPIO16)             │
│  Pin 3: LED_B (GPIO17)             │
│  Pin 4: GND                        │
├─────────────────────────────────────┤
│ J3: Expansão I2C                    │
│  Pin 1: 3.3V                       │
│  Pin 2: GND                        │
│  Pin 3: SDA (GPIO21)               │
│  Pin 4: SCL (GPIO22)               │
└─────────────────────────────────────┘
```

## 📦 Lista de Componentes

### Componente Principal
- **1x ESP32-2432S028R** - Placa de desenvolvimento com display integrado

### Componentes Externos (Opcionais)
```
Botões:
• 3x Push Button 6x6mm (táctil)
• 3x Resistor 10kΩ (pull-up externo se necessário)

LEDs:
• 1x LED RGB Common Cathode 5mm
• 3x Resistor 220Ω (limitador de corrente)

Conectores:
• 1x Conector USB-C (alimentação)
• 2x Header 2.54mm (expansão)
• 1x Jack DC 5.5x2.1mm (alimentação externa)

Caixa/Gabinete:
• Caixa ABS 100x60x20mm
• Parafusos M3 x 8mm (4 unidades)
• Espaçadores nylon 5mm (4 unidades)
```

### Ferramentas Necessárias
- Ferro de solda 30W
- Solda 63/37 0.6mm
- Multímetro
- Alicate desencapador
- Chaves Phillips e fenda pequenas

## 🔧 Montagem e Instalação

### 1. **Preparação da Placa**

```bash
# Verificar integridade dos componentes
1. Inspeção visual da placa
2. Teste de continuidade com multímetro
3. Verificar tensões de alimentação
4. Testar display e touch básico
```

### 2. **Conexão de Componentes Externos**

#### Botões (Se necessário)
```
Para cada botão:
┌─────────┐
│ Button  │
├─────────┤
│    ┌────┤ → GPIO Pin
│ 10kΩ    │
│    └────┤ → 3.3V (Pull-up)
└─────────┘
     │
     └────── → GND
```

#### LEDs RGB
```
LED RGB Common Cathode:
     ┌──220Ω─→ GPIO4  (Red)
LED ─┼──220Ω─→ GPIO16 (Green)
     ├──220Ω─→ GPIO17 (Blue)
     └────────→ GND   (Common)
```

### 3. **Teste de Hardware**

```cpp
// Código de teste básico
void hardware_test() {
    // Teste do display
    tft.fillScreen(TFT_RED);
    delay(500);
    tft.fillScreen(TFT_GREEN);
    delay(500);
    tft.fillScreen(TFT_BLUE);
    delay(500);
    
    // Teste do touch
    if (touch.touched()) {
        Serial.println("Touch OK");
    }
    
    // Teste dos botões
    if (!digitalRead(BTN_PREV_PIN)) Serial.println("BTN_PREV OK");
    if (!digitalRead(BTN_SELECT_PIN)) Serial.println("BTN_SELECT OK");
    if (!digitalRead(BTN_NEXT_PIN)) Serial.println("BTN_NEXT OK");
    
    // Teste dos LEDs
    setStatusLED(RED); delay(200);
    setStatusLED(GREEN); delay(200);
    setStatusLED(BLUE); delay(200);
    setStatusLED(OFF);
}
```

### 4. **Instalação no Veículo**

#### Considerações Mecânicas
- **Posição**: Alcance fácil do motorista
- **Ângulo**: Visibilidade sem reflexos
- **Fixação**: Resistente a vibrações
- **Ventilação**: Evitar superaquecimento

#### Considerações Elétricas
- **Alimentação**: 12V → 5V regulado
- **Proteção**: Fusível 1A recomendado
- **Isolamento**: Aterramento adequado
- **Interferência**: Afastar de ignição/alternador

## ⚡ Alimentação

### Especificações de Energia

```
Tensão de Entrada: 5V DC ±5%
Corrente Típica:   500mA
Corrente Máxima:   800mA (display 100% + WiFi ativo)
Potência Típica:   2.5W
Potência Máxima:   4W

Distribuição de Consumo:
• ESP32 Core:      150mA
• Display TFT:     200mA (backlight 100%)
• WiFi TX:         150mA (picos)
• LEDs RGB:        60mA (todos acesos)
• Lógica LVGL:     50mA
```

### Fontes de Alimentação Recomendadas

#### 1. **USB-C (Desenvolvimento)**
```
Entrada: USB-C 5V
Reguladores: Internos na placa
Proteção: Fusível PTC automático
Uso: Desenvolvimento e testes
```

#### 2. **Alimentação Veicular 12V**
```
12V Veicular → Regulador Buck 5V → ESP32

Componentes Necessários:
• Regulador Buck LM2596 (12V→5V, 3A)
• Fusível 2A no 12V
• Capacitor 1000µF/16V (filtro)
• Diodo Schottky 1A (proteção reversão)

Esquema:
12V(+) ─[Fusível 2A]─[LM2596]─ 5V(+) ─ VIN ESP32
12V(-) ─[─────────]─[──────]─ 5V(-) ─ GND ESP32
```

#### 3. **Alimentação External 5V**
```
5V Externo → Diodo Proteção → VIN ESP32

Proteção:
• Diodo Schottky 1A (proteção reversão)
• Fusível 1A (proteção sobrecorrente)
• Capacitor 470µF (filtro)
```

### Monitoramento de Energia

```cpp
void monitor_power() {
    // Leitura de tensão (divisor resistivo no ADC)
    int adc_value = analogRead(A0);
    float voltage = (adc_value * 3.3 / 4095) * 2; // Ajustar divisor
    
    // Monitorar corrente (sensor ACS712 opcional)
    int current_adc = analogRead(A1);
    float current = (current_adc - 2048) * 0.185; // ACS712-5A
    
    // Alertas
    if (voltage < 4.7) {
        Serial.println("WARNING: Low voltage detected!");
        setStatusLED(YELLOW);
    }
    
    if (current > 700) {
        Serial.println("WARNING: High current consumption!");
    }
}
```

## 🛠️ Troubleshooting Hardware

### Problemas Comuns

#### 1. **Display não inicializa**

```
Sintomas: Tela branca/preta, sem resposta
Causas Possíveis:
• Conexões SPI soltas
• Tensão inadequada (< 3.0V)
• Configuração incorreta de pinos
• Código de inicialização com erro

Diagnóstico:
1. Verificar continuidade dos pinos SPI
2. Medir tensões: 3.3V, 5V
3. Testar com código mínimo
4. Verificar configuração TFT_eSPI

Solução:
• Revisar conexões
• Verificar User_Setup.h
• Testar exemplo básico TFT_eSPI
```

#### 2. **Touch não responde**

```
Sintomas: Tela não responde ao toque
Causas Possíveis:
• Calibração incorreta
• Conexões SPI touch defeituosas
• Interferência elétrica
• Tela danificada

Diagnóstico:
1. Verificar pinos XPT2046
2. Testar com código de calibração
3. Verificar valores raw do touch
4. Isolar de fontes de interferência

Solução:
• Recalibrar touch screen
• Verificar/refazer conexões
• Usar resistores pull-up se necessário
• Filtrar software debounce
```

#### 3. **WiFi não conecta**

```
Sintomas: Falha na conexão WiFi
Causas Possíveis:
• Sinal WiFi fraco
• Credenciais incorretas
• Interferência 2.4GHz
• Antena ESP32 danificada

Diagnóstico:
1. Testar próximo ao roteador
2. Verificar SSID/senha
3. Usar WiFi.scanNetworks()
4. Monitorar RSSI

Solução:
• Melhorar sinal WiFi
• Verificar configuração rede
• Usar antena externa se necessário
• Implementar retry automático
```

#### 4. **Sistema trava/reinicia**

```
Sintomas: Watchdog reset, boot loops
Causas Possíveis:
• Sobrecarga de memória
• Loop infinito no código
• Alimentação instável
• Componente defeituoso

Diagnóstico:
1. Monitorar serial boot
2. Verificar uso de heap
3. Medir tensão de alimentação
4. Isolar componentes

Solução:
• Otimizar uso de memória
• Implementar watchdog
• Estabilizar alimentação
• Dividir tarefas em múltiplas
```

#### 5. **Botões não respondem**

```
Sintomas: Botões físicos sem resposta
Causas Possíveis:
• Pinos configurados incorretamente
• Falta de pull-up
• Botões defeituosos
• Interferência elétrica

Diagnóstico:
1. Verificar configuração INPUT_PULLUP
2. Testar continuidade botões
3. Medir tensão nos pinos
4. Usar lógica invertida (LOW=pressed)

Solução:
• Configurar pull-up interno
• Implementar debounce
• Substituir botões defeituosos
• Adicionar filtro RC se necessário
```

### Ferramentas de Diagnóstico

```cpp
// Função de diagnóstico completo
void hardware_diagnostic() {
    Serial.println("=== HARDWARE DIAGNOSTIC ===");
    
    // Teste de memória
    Serial.printf("Free Heap: %d bytes\n", ESP.getFreeHeap());
    Serial.printf("Heap Size: %d bytes\n", ESP.getHeapSize());
    
    // Teste de alimentação
    Serial.printf("Supply Voltage: %.2fV\n", ESP.getVcc());
    
    // Teste WiFi
    WiFi.scanNetworks();
    Serial.printf("WiFi Networks Found: %d\n", WiFi.scanComplete());
    
    // Teste GPIO
    for (int pin : {4, 16, 17, 35, 0, 34}) {
        pinMode(pin, INPUT_PULLUP);
        Serial.printf("GPIO%d: %s\n", pin, digitalRead(pin) ? "HIGH" : "LOW");
    }
    
    // Teste SPI
    SPI.begin();
    Serial.println("SPI Bus: OK");
    
    // Teste Display
    if (tft.readID() != 0) {
        Serial.println("Display: DETECTED");
    } else {
        Serial.println("Display: ERROR");
    }
    
    // Teste Touch
    if (touch.begin()) {
        Serial.println("Touch: OK");
    } else {
        Serial.println("Touch: ERROR");
    }
}
```

### Checklist de Verificação

#### Antes da Instalação
- [ ] Verificar integridade física da placa
- [ ] Testar display com código básico  
- [ ] Calibrar touch screen
- [ ] Verificar funcionamento dos botões
- [ ] Testar LEDs de status
- [ ] Confirmar conectividade WiFi
- [ ] Validar comunicação MQTT
- [ ] Testar sob diferentes tensões
- [ ] Verificar temperatura operacional
- [ ] Documentar configuração final

#### Após a Instalação
- [ ] Verificar fixação mecânica
- [ ] Confirmar alimentação estável
- [ ] Testar em diferentes condições
- [ ] Validar alcance WiFi
- [ ] Verificar ausência de interferência
- [ ] Documentar localização final
- [ ] Criar backup da configuração
- [ ] Treinar usuário final

---

**Versão**: 2.0.0  
**Última Atualização**: Janeiro 2025  
**Autor**: AutoTech Team