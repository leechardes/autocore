#!/bin/bash

# ESP32 Display ESP-IDF Environment Activation Script
# This script sets up the ESP-IDF environment for the project

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🖥️  ESP32 Display ESP-IDF Environment Setup${NC}"
echo -e "${BLUE}============================================${NC}"

# Check if ESP-IDF is installed
if [ -z "$IDF_PATH" ]; then
    # Try common installation paths
    if [ -d "$HOME/esp/esp-idf" ]; then
        export IDF_PATH="$HOME/esp/esp-idf"
    elif [ -d "/opt/esp-idf" ]; then
        export IDF_PATH="/opt/esp-idf"
    else
        echo -e "${RED}❌ ESP-IDF not found!${NC}"
        echo -e "${YELLOW}Please install ESP-IDF or set IDF_PATH environment variable${NC}"
        echo -e "${YELLOW}Visit: https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/${NC}"
        exit 1
    fi
fi

# Source ESP-IDF export script
if [ -f "$IDF_PATH/export.sh" ]; then
    echo -e "${GREEN}✓ Found ESP-IDF at: $IDF_PATH${NC}"
    source "$IDF_PATH/export.sh" > /dev/null 2>&1
    echo -e "${GREEN}✓ ESP-IDF environment loaded${NC}"
else
    echo -e "${RED}❌ ESP-IDF export.sh not found at $IDF_PATH${NC}"
    exit 1
fi

# Check ESP-IDF version
IDF_VERSION=$(idf.py --version 2>/dev/null | grep -oE "v[0-9]+\.[0-9]+" | head -1)
echo -e "${GREEN}✓ ESP-IDF Version: $IDF_VERSION${NC}"

# Set project-specific environment variables
export PROJECT_NAME="esp32-display"
export PROJECT_PATH="$(pwd)"

# Check for required tools
echo -e "\n${BLUE}Checking required tools...${NC}"

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | grep -oE "[0-9]+\.[0-9]+")
    echo -e "${GREEN}✓ Python: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}❌ Python3 not found${NC}"
fi

# Check for serial port tools
if python3 -c "import serial" 2>/dev/null; then
    echo -e "${GREEN}✓ PySerial installed${NC}"
else
    echo -e "${YELLOW}⚠ PySerial not installed (optional)${NC}"
    echo -e "${YELLOW}  Install with: pip install pyserial${NC}"
fi

# Display available commands
echo -e "\n${BLUE}Available commands:${NC}"
echo -e "${GREEN}  make help${NC}          - Show all available commands"
echo -e "${GREEN}  make build${NC}         - Build the project"
echo -e "${GREEN}  make flash${NC}         - Flash to ESP32"
echo -e "${GREEN}  make monitor${NC}       - Monitor serial output"
echo -e "${GREEN}  make menuconfig${NC}    - Configure project"
echo -e "${GREEN}  make all${NC}           - Build, flash and monitor"

# Display project info
echo -e "\n${BLUE}Project Information:${NC}"
echo -e "  Name: ${GREEN}$PROJECT_NAME${NC}"
echo -e "  Path: ${GREEN}$PROJECT_PATH${NC}"
echo -e "  Target: ${GREEN}ESP32${NC}"

# Create alias for quick commands
alias idf='idf.py'
alias build='make build'
alias flash='make flash'
alias monitor='make monitor'
alias menuconfig='make menuconfig'

echo -e "\n${GREEN}✅ Environment ready! You can now build the project.${NC}"
echo -e "${BLUE}============================================${NC}"

# Keep the shell active
exec $SHELL