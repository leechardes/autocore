# 🖥️ ESP32 Display Controller

[![ESP-IDF](https://img.shields.io/badge/ESP--IDF-v5.0-blue)](https://github.com/espressif/esp-idf)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![AutoCore](https://img.shields.io/badge/AutoCore-Compatible-orange)](https://github.com/leechardes/autocore)

High-performance display controller for ESP32 with multiple display support, LVGL integration, and AutoCore ecosystem compatibility.

## ✨ Features

- 🎨 **Multiple Display Support**
  - ILI9341 (320x240 TFT)
  - ST7789 (240x240/240x320 TFT)
  - SSD1306 (128x64 OLED)
  - ILI9488 (480x320 TFT)

- 🚀 **High Performance**
  - Dual-core optimization
  - Hardware SPI acceleration
  - DMA transfers
  - 60+ FPS capability

- 📡 **Connectivity**
  - WiFi AP/STA modes
  - MQTT with AutoCore protocol
  - HTTP REST API
  - WebSocket support
  - OTA updates

- 🎮 **User Interface**
  - LVGL graphics library
  - Touch controller support
  - Custom widgets
  - Smooth animations

- 🔧 **Developer Friendly**
  - Modular architecture
  - Extensive configuration
  - Debug logging
  - Performance metrics

## 🚀 Quick Start

### Prerequisites

- ESP-IDF v5.0+
- ESP32 development board
- Compatible display module
- USB cable

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/leechardes/autocore.git
cd autocore/firmware/esp32-display-esp-idf
```

2. **Set up ESP-IDF environment**
```bash
source activate.sh
```

3. **Configure the project**
```bash
make menuconfig
# Navigate to "ESP32 Display Configuration"
# Select your display type and configure pins
```

4. **Build and flash**
```bash
make all
```

## 📌 Hardware Setup

### Pin Configuration (Default)

| Function | GPIO | Description |
|----------|------|-------------|
| MOSI | 23 | SPI Data |
| SCLK | 18 | SPI Clock |
| CS | 5 | Chip Select |
| DC | 2 | Data/Command |
| RST | 4 | Reset |
| BL | 15 | Backlight |

### Touch Controller (Optional)

| Function | GPIO | Description |
|----------|------|-------------|
| T_CS | 21 | Touch Chip Select |
| T_IRQ | 22 | Touch Interrupt |

## 🛠️ Configuration

### Display Selection

Edit configuration via `make menuconfig`:

```
ESP32 Display Configuration → Display Hardware Configuration → Display Type
```

### Network Configuration

```json
{
  "wifi_ssid": "your-ssid",
  "wifi_password": "your-password",
  "mqtt_broker": "broker.hivemq.com",
  "mqtt_port": 1883,
  "device_name": "esp32-display-01"
}
```

## 📡 API Reference

### HTTP Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/status` | Get display status |
| POST | `/clear` | Clear display |
| POST | `/text` | Display text |
| POST | `/image` | Display image |
| GET | `/config` | Get configuration |
| POST | `/config` | Update configuration |

### MQTT Topics

**Subscribe:**
- `autocore/{device_id}/display/command` - Display commands
- `autocore/{device_id}/display/content` - Content updates

**Publish:**
- `autocore/{device_id}/display/status` - Status updates
- `autocore/{device_id}/display/telemetry` - Telemetry data

### Example Commands

**Display Text:**
```json
{
  "command": "text",
  "x": 10,
  "y": 20,
  "text": "Hello World",
  "color": "0xFFFF",
  "size": 2
}
```

**Draw Rectangle:**
```json
{
  "command": "rect",
  "x": 50,
  "y": 50,
  "width": 100,
  "height": 80,
  "color": "0xF800",
  "filled": true
}
```

## 🏗️ Architecture

```
ESP32 Display Architecture
├── Core 0: Network & System
│   ├── WiFi Management
│   ├── MQTT Client
│   └── HTTP Server
└── Core 1: Display & UI
    ├── Display Driver
    ├── LVGL Rendering
    └── Touch Processing
```

## 📊 Performance

| Metric | Value |
|--------|-------|
| Boot Time | < 2s |
| Frame Rate | 60+ FPS |
| Touch Response | < 10ms |
| Network Latency | < 50ms |
| RAM Usage | < 80KB |
| Flash Usage | < 1.5MB |

## 🧪 Testing

Run built-in tests:
```bash
make test
```

Monitor performance:
```bash
make monitor
# Press 'p' for performance stats
```

## 📦 Components

- **display_driver** - Hardware abstraction layer
- **ui_manager** - User interface management
- **touch_driver** - Touch input handling
- **config_manager** - Configuration storage
- **network** - WiFi and MQTT connectivity

## 🔧 Development

### Building Components

```bash
# Create new component
make create-component NAME=my_component

# Build specific component
idf.py build -C components/my_component
```

### Debugging

```bash
# Enable verbose logging
make menuconfig
# Component config → Log output → Default log verbosity → Verbose

# Monitor with colors
make monitor
```

## 📈 Monitoring

### Serial Commands

While monitoring, press:
- `Ctrl+]` - Exit monitor
- `Ctrl+T` → `Ctrl+R` - Reset device
- `Ctrl+T` → `Ctrl+P` - Performance stats
- `Ctrl+T` → `Ctrl+H` - Help

### Telemetry Data

The device publishes telemetry every 30 seconds:
```json
{
  "uptime": 3600,
  "fps": 60,
  "free_heap": 120000,
  "temperature": 45,
  "brightness": 80,
  "touch_events": 152
}
```

## 🚀 Deployment

### OTA Updates

```bash
# Via network
make ota IP=192.168.1.100

# Via USB
make flash
```

### Mass Production

```bash
# Generate factory binary
idf.py build
python merge_bin.py

# Flash factory binary
esptool.py write_flash 0x0 factory.bin
```

## 🐛 Troubleshooting

### Common Issues

**Display not working:**
- Check pin connections
- Verify power supply (3.3V)
- Confirm SPI configuration

**Low FPS:**
- Reduce display buffer size
- Increase SPI clock speed
- Disable debug logging

**Touch not responding:**
- Calibrate touch screen
- Check interrupt pin
- Verify touch controller type

## 📚 Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Hardware Guide](docs/HARDWARE.md)
- [Development Guide](docs/DEVELOPMENT.md)

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file.

## 👥 Credits

- **Lee Chardes** - Project Lead
- **AutoCore Team** - Framework Development
- **ESP-IDF** - SDK Framework
- **LVGL** - Graphics Library

## 📞 Support

- GitHub Issues: [Report a bug](https://github.com/leechardes/autocore/issues)
- Documentation: [Wiki](https://github.com/leechardes/autocore/wiki)
- Email: lee@autocore.io

---

Part of the [AutoCore](https://github.com/leechardes/autocore) IoT ecosystem.