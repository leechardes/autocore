# Arduino Firmware Projects

This folder contains firmware projects developed using the Arduino framework.

## Projects

Currently no active Arduino projects. Previous Arduino projects have been migrated to ESP-IDF or PlatformIO for better performance and features.

## Legacy Projects (Archived)
- esp32-display (migrated to PlatformIO)
- esp32-relay (migrated to ESP-IDF)

## Development

For new Arduino projects:

```bash
# Using Arduino IDE
1. Open .ino file in Arduino IDE
2. Select board: ESP32 Dev Module
3. Configure settings
4. Upload to board

# Using Arduino CLI
arduino-cli compile --fqbn esp32:esp32:esp32
arduino-cli upload -p /dev/ttyUSB0 --fqbn esp32:esp32:esp32
```

## Note
We recommend using ESP-IDF or PlatformIO for new projects due to:
- Better performance
- More control over hardware
- Advanced features
- Professional development tools