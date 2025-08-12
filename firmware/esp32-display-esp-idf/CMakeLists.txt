# ESP32 Display ESP-IDF Project
# High-performance display controller for AutoCore ecosystem

cmake_minimum_required(VERSION 3.16)

# Set project name and version
set(PROJECT_VER "1.0.0")

# Include ESP-IDF project
include($ENV{IDF_PATH}/tools/cmake/project.cmake)

# Define the project
project(esp32-display)