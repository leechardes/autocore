# ESP32 Relay ESP-IDF Project
# Based on AutoCore functional specification - Modular Structure
cmake_minimum_required(VERSION 3.16)

# Set target before including project.cmake
set(IDF_TARGET esp32)

# Include extra component directories
set(EXTRA_COMPONENT_DIRS "components")

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(esp32-relay)