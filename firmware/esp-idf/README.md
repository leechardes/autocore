# ESP-IDF Firmware Projects

This folder contains firmware projects developed using the ESP-IDF framework (Espressif IoT Development Framework).

## Projects

### esp32-relay
High-performance relay controller with MQTT v2.2.0 support.
- 16/32 channel relay control
- Momentary relay safety system with heartbeat
- Smart HTTP registration with backend
- Status: **Active** ✅

## Development

All ESP-IDF projects use ESP-IDF v5.0 or later.

```bash
# Activate ESP-IDF environment
source /path/to/esp-idf/export.sh

# Build project
cd esp32-relay
make build

# Flash to device
make flash

# Monitor output
make monitor
```

## Requirements
- ESP-IDF v5.0+
- ESP32/ESP32-S3 development board
- USB-to-Serial adapter or built-in USB