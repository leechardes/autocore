# 🎯 Plano de Implementação - ESP32 Relay ESP-IDF v2.1

## 📋 Especialista em Sistemas Embarcados ESP32

### 🏗️ Arquitetura de Melhorias

## 1. Sistema de Registro Inteligente

### 1.1 Verificação de Registro Existente
```c
// config_manager.h - Adicionar campos
typedef struct {
    // ... campos existentes ...
    bool device_registered;        // Flag de registro no backend
    char mqtt_broker_host[64];     // Broker MQTT do backend
    uint16_t mqtt_broker_port;     // Porta MQTT do backend  
    char mqtt_username[32];        // Username MQTT
    char mqtt_password[64];        // Password MQTT
    char mqtt_topic_prefix[32];    // Prefixo dos tópicos
    uint32_t last_registration;    // Timestamp do último registro
} device_config_t;
```

### 1.2 Fluxo de Registro
```c
// mqtt_handler.c - Nova função
esp_err_t mqtt_check_registration(void) {
    // 1. Verificar flag local
    if (config->device_registered) {
        ESP_LOGI(TAG, "Device already registered");
        return ESP_OK;
    }
    
    // 2. GET /api/devices/uuid/{device_uuid}
    char url[256];
    snprintf(url, sizeof(url), "http://%s:%d/api/devices/uuid/%s",
             config->backend_ip, config->backend_port, config->device_id);
    
    // 3. Se 200 -> já existe, apenas obter config MQTT
    // 4. Se 404 -> registrar com POST
    // 5. Sempre terminar com GET /api/mqtt/config
    // 6. Salvar tudo no NVS
}
```

## 2. Obtenção de Configuração MQTT

### 2.1 Estrutura de Resposta
```c
typedef struct {
    char broker[64];
    uint16_t port;
    char username[32];
    char password[64];
    char topic_prefix[32];
} mqtt_config_response_t;
```

### 2.2 Parser JSON
```c
esp_err_t mqtt_parse_config_response(const char* response, mqtt_config_response_t* config) {
    cJSON *json = cJSON_Parse(response);
    if (json == NULL) return ESP_FAIL;
    
    cJSON *broker = cJSON_GetObjectItem(json, "broker");
    cJSON *port = cJSON_GetObjectItem(json, "port");
    cJSON *username = cJSON_GetObjectItem(json, "username");
    cJSON *password = cJSON_GetObjectItem(json, "password");
    cJSON *topic_prefix = cJSON_GetObjectItem(json, "topic_prefix");
    
    // Copiar valores para estrutura
    // Validar campos obrigatórios
    // Retornar ESP_OK ou ESP_FAIL
}
```

### 2.3 Requisição HTTP
```c
esp_err_t mqtt_fetch_config(void) {
    char url[256];
    snprintf(url, sizeof(url), "http://%s:%d/api/mqtt/config",
             config->backend_ip, config->backend_port);
    
    esp_http_client_config_t http_config = {
        .url = url,
        .method = HTTP_METHOD_GET,
        .timeout_ms = 10000,
        .buffer_size = 1024,
    };
    
    // Fazer requisição
    // Parser resposta
    // Salvar no config
    // Salvar no NVS
}
```

## 3. Comportamento de Boot Inteligente

### 3.1 Lógica de Inicialização
```c
// main.c - app_main() modificado
void app_main(void) {
    // ... inicializações ...
    
    // Novo fluxo de WiFi
    if (config->configured && strlen(config->wifi_ssid) > 0) {
        ESP_LOGI(TAG, "WiFi configured, attempting connection...");
        
        // Tentar conectar SEM ativar AP
        esp_err_t ret = wifi_manager_connect_sta_only(
            config->wifi_ssid, 
            config->wifi_password
        );
        
        if (ret == ESP_OK) {
            // Conectou - NÃO ativar AP
            ESP_LOGI(TAG, "WiFi connected successfully");
            
            // Verificar/fazer registro
            mqtt_check_registration();
            
            // Conectar MQTT com credenciais salvas
            if (config->device_registered) {
                mqtt_connect_with_saved_credentials();
            }
        } else {
            // Falhou - ativar AP para reconfiguração
            ESP_LOGW(TAG, "WiFi connection failed, starting AP mode");
            wifi_manager_start_ap_for_config();
        }
    } else {
        // Não configurado - modo AP direto
        ESP_LOGI(TAG, "Device not configured, starting AP mode");
        wifi_manager_start_ap_for_config();
    }
}
```

### 3.2 WiFi Manager Melhorado
```c
// wifi_manager.c - Nova função
esp_err_t wifi_manager_connect_sta_only(const char* ssid, const char* password) {
    // Conectar APENAS em modo STA
    // NÃO ativar AP em caso de falha
    // Retornar sucesso ou falha
    
    esp_wifi_set_mode(WIFI_MODE_STA);
    // ... configurar e conectar ...
    
    // Aguardar conexão com timeout
    EventBits_t bits = xEventGroupWaitBits(
        wifi_event_group,
        WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
        pdFALSE, pdFALSE,
        pdMS_TO_TICKS(30000)  // 30 segundos
    );
    
    if (bits & WIFI_CONNECTED_BIT) {
        return ESP_OK;
    }
    return ESP_FAIL;
}
```

## 4. Factory Reset Completo

### 4.1 Limpeza Total do NVS
```c
// config_manager.c
esp_err_t config_factory_reset(void) {
    ESP_LOGI(TAG, "Performing factory reset...");
    
    // 1. Apagar namespace de configuração
    nvs_handle_t handle;
    ESP_ERROR_CHECK(nvs_open(NVS_NAMESPACE, NVS_READWRITE, &handle));
    ESP_ERROR_CHECK(nvs_erase_all(handle));
    ESP_ERROR_CHECK(nvs_commit(handle));
    nvs_close(handle);
    
    // 2. Resetar config na RAM
    memset(&device_config, 0, sizeof(device_config_t));
    
    // 3. Recriar valores padrão
    config_set_defaults(&device_config);
    
    // 4. Salvar defaults
    config_save();
    
    ESP_LOGI(TAG, "Factory reset complete");
    return ESP_OK;
}
```

### 4.2 Handler HTTP para Reset
```c
// http_server_config.c - Melhorar reset_handler
static esp_err_t reset_handler(httpd_req_t *req) {
    httpd_resp_send(req, "OK", 2);
    ESP_LOGI(TAG, "Factory reset requested via HTTP");
    
    // Factory reset completo
    config_factory_reset();
    
    // Aguardar um pouco
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    // Reiniciar
    esp_restart();
    return ESP_OK;
}
```

## 5. Persistência de Dados MQTT

### 5.1 Salvar Configuração MQTT
```c
// config_manager.c - Adicionar saves
esp_err_t config_save_mqtt_settings(mqtt_config_response_t* mqtt_config) {
    nvs_handle_t handle;
    esp_err_t ret;
    
    ret = nvs_open(NVS_NAMESPACE, NVS_READWRITE, &handle);
    if (ret != ESP_OK) return ret;
    
    // Salvar cada campo
    nvs_set_str(handle, "mqtt_broker", mqtt_config->broker);
    nvs_set_u16(handle, "mqtt_port", mqtt_config->port);
    nvs_set_str(handle, "mqtt_user", mqtt_config->username);
    nvs_set_str(handle, "mqtt_pass", mqtt_config->password);
    nvs_set_str(handle, "mqtt_prefix", mqtt_config->topic_prefix);
    nvs_set_u8(handle, "registered", 1);
    
    ret = nvs_commit(handle);
    nvs_close(handle);
    
    // Atualizar config na RAM
    strncpy(config->mqtt_broker_host, mqtt_config->broker, 63);
    config->mqtt_broker_port = mqtt_config->port;
    strncpy(config->mqtt_username, mqtt_config->username, 31);
    strncpy(config->mqtt_password, mqtt_config->password, 63);
    strncpy(config->mqtt_topic_prefix, mqtt_config->topic_prefix, 31);
    config->device_registered = true;
    
    return ret;
}
```

### 5.2 Carregar na Inicialização
```c
// config_manager.c - Modificar config_load()
esp_err_t config_load(void) {
    // ... código existente ...
    
    // Carregar configurações MQTT
    size_t length = 64;
    nvs_get_str(handle, "mqtt_broker", config->mqtt_broker_host, &length);
    
    nvs_get_u16(handle, "mqtt_port", &config->mqtt_broker_port);
    
    length = 32;
    nvs_get_str(handle, "mqtt_user", config->mqtt_username, &length);
    
    length = 64;
    nvs_get_str(handle, "mqtt_pass", config->mqtt_password, &length);
    
    length = 32;
    nvs_get_str(handle, "mqtt_prefix", config->mqtt_topic_prefix, &length);
    
    uint8_t registered = 0;
    nvs_get_u8(handle, "registered", &registered);
    config->device_registered = (registered == 1);
    
    // ... resto do código ...
}
```

## 6. MQTT com Credenciais Salvas

### 6.1 Conexão com Config Salvo
```c
// mqtt_handler.c
esp_err_t mqtt_connect_with_saved_credentials(void) {
    device_config_t* config = config_get();
    
    if (!config->device_registered) {
        ESP_LOGE(TAG, "Device not registered");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Construir URI com credenciais salvas
    char mqtt_uri[256];
    snprintf(mqtt_uri, sizeof(mqtt_uri), "mqtt://%s:%d",
             config->mqtt_broker_host,
             config->mqtt_broker_port);
    
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker = {
            .address = {
                .uri = mqtt_uri,
            },
        },
        .credentials = {
            .client_id = config->device_id,
            .username = config->mqtt_username,
            .authentication = {
                .password = config->mqtt_password,
            },
        },
        // ... resto da config ...
    };
    
    // Inicializar e conectar
    mqtt_client_handle = esp_mqtt_client_init(&mqtt_cfg);
    return esp_mqtt_client_start(mqtt_client_handle);
}
```

## 7. Tópicos MQTT Dinâmicos

### 7.1 Construção de Tópicos
```c
// mqtt_handler.c
void mqtt_build_topics(void) {
    device_config_t* config = config_get();
    
    // Tópico de telemetria
    snprintf(telemetry_topic, sizeof(telemetry_topic),
             "%s/devices/%s/telemetry",
             config->mqtt_topic_prefix,
             config->device_id);
    
    // Tópico de comandos
    snprintf(command_topic, sizeof(command_topic),
             "%s/devices/%s/command",
             config->mqtt_topic_prefix,
             config->device_id);
    
    // Tópico de status
    snprintf(status_topic, sizeof(status_topic),
             "%s/devices/%s/status",
             config->mqtt_topic_prefix,
             config->device_id);
}
```

## 8. Página de Status Melhorada

### 8.1 Mostrar Estado de Registro
```html
<!-- Adicionar na página HTML -->
<div class='status-item'>
    <span class='status-label'>Registro</span>
    <span class='status-value %s'>%s</span>
</div>
<div class='status-item'>
    <span class='status-label'>MQTT</span>
    <span class='status-value %s'>%s</span>
</div>
```

### 8.2 Endpoint de Status Completo
```c
// http_server_config.c
static esp_err_t status_handler(httpd_req_t *req) {
    device_config_t* config = config_get();
    
    cJSON *json = cJSON_CreateObject();
    cJSON_AddBoolToObject(json, "registered", config->device_registered);
    cJSON_AddStringToObject(json, "mqtt_broker", config->mqtt_broker_host);
    cJSON_AddNumberToObject(json, "mqtt_port", config->mqtt_broker_port);
    cJSON_AddBoolToObject(json, "mqtt_connected", mqtt_client_is_connected());
    cJSON_AddStringToObject(json, "wifi_ssid", config->wifi_ssid);
    cJSON_AddBoolToObject(json, "wifi_connected", wifi_manager_is_connected());
    
    char *response = cJSON_Print(json);
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    
    free(response);
    cJSON_Delete(json);
    return ESP_OK;
}
```

## 9. Tratamento de Erros Robusto

### 9.1 Retry Logic
```c
#define MAX_RETRIES 3
#define RETRY_DELAY_MS 5000

esp_err_t http_request_with_retry(const char* url, 
                                  http_method_t method,
                                  const char* payload,
                                  char* response,
                                  size_t max_response_len) {
    esp_err_t ret = ESP_FAIL;
    
    for (int i = 0; i < MAX_RETRIES; i++) {
        ret = http_request(url, method, payload, response, max_response_len);
        
        if (ret == ESP_OK) {
            break;
        }
        
        ESP_LOGW(TAG, "Request failed, retry %d/%d", i+1, MAX_RETRIES);
        vTaskDelay(pdMS_TO_TICKS(RETRY_DELAY_MS));
    }
    
    return ret;
}
```

## 10. Sequência de Implementação

### Fase 1: Estrutura de Dados (2h)
- [ ] Atualizar `device_config_t` com novos campos
- [ ] Modificar `config_save()` e `config_load()`
- [ ] Adicionar funções de persistência MQTT

### Fase 2: Verificação de Registro (3h)
- [ ] Implementar `mqtt_check_registration()`
- [ ] Adicionar GET `/api/devices/uuid/{id}`
- [ ] Implementar lógica de decisão

### Fase 3: Obtenção de Config MQTT (2h)
- [ ] Implementar `mqtt_fetch_config()`
- [ ] Parser JSON para resposta
- [ ] Salvar no NVS

### Fase 4: Boot Inteligente (3h)
- [ ] Modificar `app_main()`
- [ ] Criar `wifi_manager_connect_sta_only()`
- [ ] Lógica condicional de AP

### Fase 5: Factory Reset (1h)
- [ ] Implementar `config_factory_reset()`
- [ ] Melhorar handler HTTP

### Fase 6: MQTT Dinâmico (2h)
- [ ] Usar credenciais salvas
- [ ] Construir tópicos dinamicamente
- [ ] Testar conexão

### Fase 7: Interface e Status (2h)
- [ ] Atualizar página HTML
- [ ] Adicionar endpoint `/status`
- [ ] Mostrar estado completo

### Fase 8: Testes e Validação (3h)
- [ ] Testar fluxo completo
- [ ] Validar persistência
- [ ] Testar factory reset
- [ ] Documentar

## 📚 Recursos Necessários

### Bibliotecas
- ESP-IDF v5.0+
- cJSON (já incluído)
- esp_http_client
- nvs_flash
- esp_mqtt_client

### Hardware
- ESP32-WROOM-32
- 16 canais de relé
- Fonte 5V/3A

### Backend
- AutoCore API rodando
- Mosquitto MQTT Broker
- Endpoints implementados:
  - GET `/api/devices/uuid/{id}`
  - POST `/api/devices`
  - GET `/api/mqtt/config`

## 🎯 Critérios de Sucesso

1. ✅ Boot sem AP quando WiFi conecta
2. ✅ Registro único no backend
3. ✅ Credenciais MQTT obtidas dinamicamente
4. ✅ Persistência completa de configurações
5. ✅ Factory reset limpa tudo
6. ✅ Reconexão automática MQTT
7. ✅ Interface mostra status real
8. ✅ Sistema robusto a falhas

## 🚀 Comando para Implementar

```bash
# Ativar ambiente
source activate.sh

# Compilar
idf.py build

# Flash
idf.py -p /dev/cu.usbserial-0001 flash

# Monitor
idf.py -p /dev/cu.usbserial-0001 monitor

# Test Factory Reset
curl -X POST http://192.168.4.1/reset
```

---

**Especialista Pronto!** 🎓

Este plano detalhado permite implementar todas as melhorias necessárias de forma organizada e testável. Cada seção pode ser implementada independentemente, facilitando o desenvolvimento incremental e testes.