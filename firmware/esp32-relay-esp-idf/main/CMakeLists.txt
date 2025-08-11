# Main component CMakeLists.txt
# ESP32 Relay ESP-IDF - Modular Structure

idf_component_register(
    SRCS 
        "main.c"
    INCLUDE_DIRS 
        "."
    REQUIRES 
        config_manager
        network
        relay_control
        web_interface
        # Core ESP-IDF components needed by main
        freertos
        esp_system
        esp_timer
        nvs_flash
        esp_netif
        esp_event
)