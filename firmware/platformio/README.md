# PlatformIO Firmware Projects

This folder contains firmware projects developed using PlatformIO framework.

## Projects

### esp32-display
Advanced touch display interface for AutoCore system.
- ILI9341/ST7789 display support
- XPT2046 touch controller
- MQTT integration for real-time updates
- Hot reload for UI development
- Status: **Development** 🚧

## Development

All PlatformIO projects use the PlatformIO IDE or CLI.

```bash
# Install PlatformIO CLI
pip install platformio

# Build project
cd esp32-display
pio run

# Upload to device
pio run -t upload

# Monitor serial output
pio device monitor

# Run with hot reload
./dev-manager.sh
```

## Requirements
- PlatformIO Core 6.0+
- ESP32 development board
- Compatible display (ILI9341/ST7789)
- Touch controller (XPT2046)