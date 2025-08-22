# Hardware - ESP32 Display

Este diretório contém toda a documentação relacionada ao hardware do dispositivo ESP32 com display.

## 🔌 Especificações Técnicas

- **Microcontrolador**: ESP32-WROOM-32
- **Display**: ILI9341 240x320 SPI TFT
- **Touch Controller**: XPT2046 resistivo
- **Memória**: 4MB Flash, 520KB SRAM
- **Conectividade**: WiFi 802.11 b/g/n

## 📋 Documentação Disponível

- [`esp32-pinout.md`](esp32-pinout.md) - Mapeamento completo dos pinos
- [`display-specs.md`](display-specs.md) - Especificações do display ILI9341
- [`touch-controller.md`](touch-controller.md) - Configuração do controlador touch
- [`power-management.md`](power-management.md) - Gestão de energia e sleep modes
- [`peripherals.md`](peripherals.md) - Periféricos externos conectados

## ⚡ Configurações Principais

### Display SPI
- MISO: GPIO 12
- MOSI: GPIO 13  
- SCLK: GPIO 14
- CS: GPIO 15
- DC: GPIO 2
- RST: GPIO 12
- BL: GPIO 21

### Touch SPI
- CS: GPIO 33
- Outros pinos compartilhados com display

## 🛠️ Setup Inicial

Para configuração inicial do hardware, consulte o arquivo de configuração principal no PlatformIO.