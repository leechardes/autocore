#!/bin/bash
# ESP32 Relay ESP-IDF Build Verification Script
# Verifica se o projeto está configurado corretamente

set -e

echo "🔍 ESP32 Relay ESP-IDF - Build Verification"
echo "=========================================="

# Verificar se ESP-IDF está configurado
if [ -z "$IDF_PATH" ]; then
    echo "❌ ESP-IDF environment not set. Please run:"
    echo "   source $HOME/esp/esp-idf/export.sh"
    exit 1
fi

echo "✅ ESP-IDF environment detected: $IDF_PATH"

# Verificar versão do ESP-IDF
IDF_VERSION=$(idf.py --version 2>/dev/null | head -1)
echo "✅ ESP-IDF version: $IDF_VERSION"

# Verificar se está no diretório correto
if [ ! -f "CMakeLists.txt" ] || [ ! -d "main" ]; then
    echo "❌ Not in ESP32 Relay project directory"
    exit 1
fi

echo "✅ Project structure verified"

# Verificar arquivos principais
REQUIRED_FILES=(
    "main/main.c"
    "main/config_manager.c"
    "main/wifi_manager.c"
    "main/http_server.c"
    "main/mqtt_client.c"
    "main/relay_control.c"
    "sdkconfig.defaults"
    "partitions.csv"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ Missing file: $file"
        exit 1
    fi
done

# Set target (se ainda não foi feito)
echo ""
echo "🎯 Setting ESP32 target..."
idf.py set-target esp32

# Executar build de teste (só preparação)
echo ""
echo "🔨 Testing build configuration..."
idf.py reconfigure

echo ""
echo "✅ BUILD VERIFICATION SUCCESSFUL!"
echo "🚀 Ready to build with: idf.py build"
echo "📡 Ready to flash with: idf.py flash"
echo "📊 Ready to monitor with: idf.py monitor"
echo ""
echo "💡 Quick start commands:"
echo "   idf.py build          # Build only"
echo "   idf.py flash monitor  # Flash and monitor"
echo "   idf.py menuconfig     # Configure options"