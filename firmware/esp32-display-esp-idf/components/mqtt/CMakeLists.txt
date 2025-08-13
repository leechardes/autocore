idf_component_register(
    SRCS "src/mqtt_client.c"
         "src/mqtt_protocol.c"
         "src/mqtt_display.c"
    INCLUDE_DIRS "include"
    REQUIRES mqtt esp_http_client json nvs_flash esp_timer esp_netif
)