# 🔧 Especialista em Implementação ESP32-Relay ESP-IDF v2.1

## 👤 Perfil do Especialista

**Nome:** Dr. Alex Silva - Especialista em Sistemas Embarcados IoT
**Experiência:** 15 anos em desenvolvimento ESP32, protocolos MQTT, e sistemas de automação
**Especialidades:** ESP-IDF, FreeRTOS, MQTT, HTTP REST APIs, NVS Storage, WiFi Management

## 📋 Missão

Implementar melhorias críticas no sistema ESP32-Relay para torná-lo robusto, autônomo e integrado ao ecossistema AutoCore, seguindo as melhores práticas de desenvolvimento embarcado.

## 🎯 Objetivos Principais

1. **Sistema de Registro Inteligente** - Verificar existência antes de registrar
2. **Configuração MQTT Dinâmica** - Obter credenciais do backend
3. **Boot Autônomo** - Conectar WiFi sem ativar AP desnecessariamente  
4. **Persistência Robusta** - Salvar todas configurações no NVS
5. **Factory Reset Completo** - Limpar totalmente o dispositivo

## 🏗️ Arquitetura de Implementação

### Fase 1: Estrutura de Dados Aprimorada (2 horas)

#### 1.1 Atualizar config_manager.h
```c
// Adicionar à estrutura device_config_t:
typedef struct {
    // ... campos existentes ...
    
    // Novos campos MQTT do backend
    bool device_registered;           // Flag de registro no backend
    char mqtt_broker_host[64];       // Host MQTT real do backend
    uint16_t mqtt_broker_port;       // Porta MQTT real
    char mqtt_username[32];          // Username MQTT do dispositivo
    char mqtt_password[64];          // Password MQTT do dispositivo
    char mqtt_topic_prefix[32];      // Prefixo dos tópicos MQTT
    uint32_t last_registration;      // Timestamp do último registro
    uint32_t registration_attempts;  // Contador de tentativas
} device_config_t;
```

#### 1.2 Implementar Novas Funções de Configuração
```c
// config_manager.c - Adicionar:

esp_err_t config_set_registration_status(bool registered) {
    device_config_t* config = config_get();
    config->device_registered = registered;
    config->last_registration = esp_timer_get_time() / 1000000;
    return config_save();
}

esp_err_t config_save_mqtt_credentials(
    const char* broker_host,
    uint16_t broker_port,
    const char* username,
    const char* password,
    const char* topic_prefix
) {
    device_config_t* config = config_get();
    
    strncpy(config->mqtt_broker_host, broker_host, 63);
    config->mqtt_broker_port = broker_port;
    strncpy(config->mqtt_username, username, 31);
    strncpy(config->mqtt_password, password, 63);
    strncpy(config->mqtt_topic_prefix, topic_prefix, 31);
    
    return config_save();
}
```

### Fase 2: Sistema de Registro Inteligente (3 horas)

#### 2.1 Criar mqtt_registration.c
```c
// components/network/src/mqtt_registration.c

#include "esp_http_client.h"
#include "cJSON.h"
#include "config_manager.h"

#define MAX_RETRIES 3
#define RETRY_DELAY_MS 5000

typedef struct {
    char broker[64];
    uint16_t port;
    char username[32];
    char password[64];
    char topic_prefix[32];
} mqtt_config_t;

// Verificar se dispositivo já está registrado
static esp_err_t check_device_exists(bool* exists) {
    device_config_t* config = config_get();
    char url[256];
    
    snprintf(url, sizeof(url), 
        "http://%s:%d/api/devices/uuid/%s",
        config->backend_ip, 
        config->backend_port,
        config->device_id
    );
    
    esp_http_client_config_t http_config = {
        .url = url,
        .method = HTTP_METHOD_GET,
        .timeout_ms = 10000,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    esp_err_t ret = esp_http_client_perform(client);
    int status = esp_http_client_get_status_code(client);
    
    *exists = (ret == ESP_OK && status == 200);
    
    esp_http_client_cleanup(client);
    return ret;
}

// Obter configuração MQTT do backend
static esp_err_t fetch_mqtt_config(mqtt_config_t* mqtt_cfg) {
    device_config_t* config = config_get();
    char url[256];
    
    snprintf(url, sizeof(url),
        "http://%s:%d/api/mqtt/config",
        config->backend_ip,
        config->backend_port
    );
    
    esp_http_client_config_t http_config = {
        .url = url,
        .method = HTTP_METHOD_GET,
        .timeout_ms = 10000,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    esp_err_t ret = esp_http_client_perform(client);
    
    if (ret == ESP_OK && esp_http_client_get_status_code(client) == 200) {
        char buffer[512];
        int len = esp_http_client_read_response(client, buffer, sizeof(buffer)-1);
        buffer[len] = '\0';
        
        // Parse JSON response
        cJSON* json = cJSON_Parse(buffer);
        if (json) {
            cJSON* broker = cJSON_GetObjectItem(json, "broker");
            cJSON* port = cJSON_GetObjectItem(json, "port");
            cJSON* username = cJSON_GetObjectItem(json, "username");
            cJSON* password = cJSON_GetObjectItem(json, "password");
            cJSON* prefix = cJSON_GetObjectItem(json, "topic_prefix");
            
            if (broker) strncpy(mqtt_cfg->broker, broker->valuestring, 63);
            if (port) mqtt_cfg->port = port->valueint;
            if (username) strncpy(mqtt_cfg->username, username->valuestring, 31);
            if (password) strncpy(mqtt_cfg->password, password->valuestring, 63);
            if (prefix) strncpy(mqtt_cfg->topic_prefix, prefix->valuestring, 31);
            
            cJSON_Delete(json);
        }
    }
    
    esp_http_client_cleanup(client);
    return ret;
}

// Fluxo principal de registro
esp_err_t mqtt_smart_registration(void) {
    device_config_t* config = config_get();
    
    // 1. Verificar se já registrado localmente
    if (config->device_registered) {
        ESP_LOGI(TAG, "Device already registered locally");
        return ESP_OK;
    }
    
    // 2. Verificar no backend
    bool exists = false;
    esp_err_t ret = check_device_exists(&exists);
    
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to check device existence");
        return ret;
    }
    
    // 3. Se não existe, registrar
    if (!exists) {
        ESP_LOGI(TAG, "Device not found, registering...");
        ret = mqtt_register_device(); // Função existente
        if (ret != ESP_OK) {
            ESP_LOGE(TAG, "Registration failed");
            return ret;
        }
    } else {
        ESP_LOGI(TAG, "Device already exists in backend");
    }
    
    // 4. Obter configuração MQTT
    mqtt_config_t mqtt_cfg = {0};
    ret = fetch_mqtt_config(&mqtt_cfg);
    
    if (ret == ESP_OK) {
        // 5. Salvar credenciais
        config_save_mqtt_credentials(
            mqtt_cfg.broker,
            mqtt_cfg.port,
            mqtt_cfg.username,
            mqtt_cfg.password,
            mqtt_cfg.topic_prefix
        );
        
        // 6. Marcar como registrado
        config_set_registration_status(true);
        
        ESP_LOGI(TAG, "✅ Registration complete! MQTT: %s@%s:%d",
            mqtt_cfg.username, mqtt_cfg.broker, mqtt_cfg.port);
    }
    
    return ret;
}
```

### Fase 3: Boot Inteligente (3 horas)

#### 3.1 Modificar main.c
```c
// main/main.c - Novo fluxo de inicialização

void app_main(void) {
    // Inicializações básicas
    ESP_ERROR_CHECK(nvs_flash_init());
    ESP_ERROR_CHECK(config_manager_init());
    ESP_ERROR_CHECK(relay_control_init());
    
    device_config_t* config = config_get();
    
    // NOVO: Boot inteligente
    if (config->configured && strlen(config->wifi_ssid) > 0) {
        ESP_LOGI(TAG, "📡 WiFi configured, attempting connection...");
        
        // Tentar conectar SEM ativar AP
        esp_err_t wifi_result = wifi_manager_connect_sta_only(
            config->wifi_ssid,
            config->wifi_password,
            30000  // 30 segundos timeout
        );
        
        if (wifi_result == ESP_OK) {
            ESP_LOGI(TAG, "✅ WiFi connected successfully!");
            
            // Fazer registro inteligente
            esp_err_t reg_result = mqtt_smart_registration();
            
            if (reg_result == ESP_OK && config->device_registered) {
                // Conectar MQTT com credenciais salvas
                mqtt_connect_with_saved_credentials();
            }
            
            // Iniciar servidor web para configuração
            http_server_start_config_mode();
            
        } else {
            ESP_LOGW(TAG, "❌ WiFi connection failed, starting AP mode");
            wifi_manager_start_ap_mode();
            http_server_start_config_mode();
        }
    } else {
        ESP_LOGI(TAG, "🔧 Device not configured, starting AP mode");
        wifi_manager_start_ap_mode();
        http_server_start_config_mode();
    }
}
```

#### 3.2 Implementar wifi_manager_connect_sta_only
```c
// components/network/src/wifi_manager.c

esp_err_t wifi_manager_connect_sta_only(
    const char* ssid, 
    const char* password,
    uint32_t timeout_ms
) {
    // Configurar apenas modo STA
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    
    wifi_config_t wifi_config = {0};
    strncpy((char*)wifi_config.sta.ssid, ssid, 31);
    strncpy((char*)wifi_config.sta.password, password, 63);
    
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start());
    
    // Aguardar conexão com timeout
    EventBits_t bits = xEventGroupWaitBits(
        wifi_event_group,
        WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
        pdFALSE,
        pdFALSE,
        pdMS_TO_TICKS(timeout_ms)
    );
    
    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "Connected to WiFi: %s", ssid);
        return ESP_OK;
    } else {
        ESP_LOGW(TAG, "Failed to connect to WiFi: %s", ssid);
        esp_wifi_stop();
        return ESP_FAIL;
    }
}
```

### Fase 4: Factory Reset Completo (2 horas)

#### 4.1 Implementar Factory Reset Total
```c
// components/config_manager/src/config_manager.c

esp_err_t config_factory_reset(void) {
    ESP_LOGI(TAG, "🔄 Performing complete factory reset...");
    
    // 1. Parar todos os serviços
    mqtt_client_stop();
    http_server_stop();
    wifi_manager_stop();
    
    // 2. Limpar TODO o NVS
    nvs_handle_t handle;
    esp_err_t ret = nvs_open(CONFIG_NAMESPACE, NVS_READWRITE, &handle);
    if (ret == ESP_OK) {
        // Apagar todas as chaves
        nvs_erase_all(handle);
        nvs_commit(handle);
        nvs_close(handle);
    }
    
    // 3. Resetar configuração na RAM
    device_config_t* config = config_get();
    memset(config, 0, sizeof(device_config_t));
    
    // 4. Gerar novo device_id
    config_generate_device_id(config->device_id, sizeof(config->device_id));
    snprintf(config->device_name, sizeof(config->device_name), 
        "ESP32-Relay-%s", config->device_id);
    
    // 5. Valores padrão
    config->relay_channels = 16;
    config->backend_port = 8081;
    config->mqtt_port = 1883;
    config->configured = false;
    config->device_registered = false;
    
    // 6. Salvar defaults
    config_save();
    
    ESP_LOGI(TAG, "✅ Factory reset complete!");
    
    // 7. Reiniciar após 2 segundos
    vTaskDelay(pdMS_TO_TICKS(2000));
    esp_restart();
    
    return ESP_OK;
}
```

### Fase 5: MQTT com Credenciais Salvas (2 horas)

#### 5.1 Conectar com Credenciais Persistentes
```c
// components/network/src/mqtt_handler.c

esp_err_t mqtt_connect_with_saved_credentials(void) {
    device_config_t* config = config_get();
    
    if (!config->device_registered) {
        ESP_LOGE(TAG, "Device not registered, cannot connect");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Usar credenciais salvas do backend
    char mqtt_uri[256];
    snprintf(mqtt_uri, sizeof(mqtt_uri), "mqtt://%s:%d",
        config->mqtt_broker_host,  // Host salvo do backend
        config->mqtt_broker_port   // Porta salva do backend
    );
    
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker = {
            .address = {
                .uri = mqtt_uri,
            },
        },
        .credentials = {
            .client_id = config->device_id,
            .username = config->mqtt_username,    // Username salvo
            .authentication = {
                .password = config->mqtt_password, // Password salvo
            },
        },
        .session = {
            .keepalive = 60,
            .disable_clean_session = false,
        },
    };
    
    // Destruir cliente anterior se existir
    if (mqtt_client_handle != NULL) {
        esp_mqtt_client_destroy(mqtt_client_handle);
    }
    
    // Criar novo cliente
    mqtt_client_handle = esp_mqtt_client_init(&mqtt_cfg);
    esp_mqtt_client_register_event(mqtt_client_handle, 
        ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    
    ESP_LOGI(TAG, "🔌 Connecting to MQTT with saved credentials");
    ESP_LOGI(TAG, "Broker: %s:%d", 
        config->mqtt_broker_host, config->mqtt_broker_port);
    ESP_LOGI(TAG, "Username: %s", config->mqtt_username);
    
    return esp_mqtt_client_start(mqtt_client_handle);
}
```

### Fase 6: Persistência no NVS (2 horas)

#### 6.1 Salvar Configurações MQTT
```c
// components/config_manager/src/config_manager.c

esp_err_t config_save(void) {
    nvs_handle_t handle;
    esp_err_t ret = nvs_open(CONFIG_NAMESPACE, NVS_READWRITE, &handle);
    
    if (ret != ESP_OK) return ret;
    
    device_config_t* config = config_get();
    
    // Salvar configurações básicas (existentes)
    nvs_set_str(handle, "device_id", config->device_id);
    nvs_set_str(handle, "device_name", config->device_name);
    nvs_set_u8(handle, "relay_channels", config->relay_channels);
    nvs_set_u8(handle, "configured", config->configured ? 1 : 0);
    
    // Salvar WiFi
    nvs_set_str(handle, "wifi_ssid", config->wifi_ssid);
    nvs_set_str(handle, "wifi_password", config->wifi_password);
    
    // Salvar Backend
    nvs_set_str(handle, "backend_ip", config->backend_ip);
    nvs_set_u16(handle, "backend_port", config->backend_port);
    
    // NOVO: Salvar MQTT do backend
    nvs_set_u8(handle, "device_registered", config->device_registered ? 1 : 0);
    nvs_set_str(handle, "mqtt_broker_host", config->mqtt_broker_host);
    nvs_set_u16(handle, "mqtt_broker_port", config->mqtt_broker_port);
    nvs_set_str(handle, "mqtt_username", config->mqtt_username);
    nvs_set_str(handle, "mqtt_password", config->mqtt_password);
    nvs_set_str(handle, "mqtt_topic_prefix", config->mqtt_topic_prefix);
    nvs_set_u32(handle, "last_registration", config->last_registration);
    
    ret = nvs_commit(handle);
    nvs_close(handle);
    
    ESP_LOGI(TAG, "💾 Configuration saved to NVS");
    return ret;
}

esp_err_t config_load(void) {
    nvs_handle_t handle;
    esp_err_t ret = nvs_open(CONFIG_NAMESPACE, NVS_READWRITE, &handle);
    
    if (ret != ESP_OK) return ret;
    
    device_config_t* config = config_get();
    size_t length;
    
    // Carregar configurações básicas (existentes)
    length = CONFIG_DEVICE_ID_MAX_LEN;
    nvs_get_str(handle, "device_id", config->device_id, &length);
    
    // NOVO: Carregar status de registro
    uint8_t registered = 0;
    nvs_get_u8(handle, "device_registered", &registered);
    config->device_registered = (registered == 1);
    
    // NOVO: Carregar MQTT do backend
    length = 64;
    nvs_get_str(handle, "mqtt_broker_host", config->mqtt_broker_host, &length);
    nvs_get_u16(handle, "mqtt_broker_port", &config->mqtt_broker_port);
    
    length = 32;
    nvs_get_str(handle, "mqtt_username", config->mqtt_username, &length);
    
    length = 64;
    nvs_get_str(handle, "mqtt_password", config->mqtt_password, &length);
    
    length = 32;
    nvs_get_str(handle, "mqtt_topic_prefix", config->mqtt_topic_prefix, &length);
    
    nvs_get_u32(handle, "last_registration", &config->last_registration);
    
    nvs_close(handle);
    
    ESP_LOGI(TAG, "📂 Configuration loaded from NVS");
    if (config->device_registered) {
        ESP_LOGI(TAG, "Device is registered with backend");
    }
    
    return ESP_OK;
}
```

## 🧪 Plano de Testes

### Teste 1: Primeiro Boot (Device Novo)
1. Flash firmware limpo
2. Verificar AP mode ativo
3. Configurar WiFi e backend
4. Verificar registro automático
5. Confirmar MQTT conectado

### Teste 2: Reboot com WiFi Configurado
1. Reiniciar dispositivo
2. Verificar que NÃO ativa AP
3. Confirmar conexão WiFi automática
4. Verificar MQTT com credenciais salvas

### Teste 3: Factory Reset
1. Clicar em "Restaurar Padrões"
2. Verificar limpeza total do NVS
3. Confirmar novo device_id gerado
4. Verificar AP mode ativo novamente

### Teste 4: Falha de WiFi
1. Desligar roteador WiFi
2. Reiniciar dispositivo
3. Verificar ativação do AP após timeout
4. Religar roteador
5. Reconfigurar e testar

## 📊 Métricas de Sucesso

- ✅ Boot sem AP: < 5 segundos quando WiFi disponível
- ✅ Registro único: Sem duplicatas no backend
- ✅ Persistência 100%: Todas configs sobrevivem reboot
- ✅ Factory reset total: Limpa 100% das configurações
- ✅ Reconexão MQTT: < 10 segundos após WiFi conectar

## 🛠️ Ferramentas de Debug

### Comandos Úteis
```bash
# Monitor com cores
idf.py -p /dev/cu.usbserial-0001 monitor

# Limpar NVS
idf.py -p /dev/cu.usbserial-0001 erase-flash

# Build e flash
idf.py build && idf.py -p /dev/cu.usbserial-0001 flash

# Testar endpoints
curl http://192.168.4.1/config
curl -X POST http://192.168.4.1/reset
curl http://10.0.10.11:8081/api/devices/uuid/ESP32-ABCD1234
curl http://10.0.10.11:8081/api/mqtt/config
```

### Logs Importantes
```
I (1234) WIFI: Connected to WiFi: MyNetwork
I (2345) MQTT: Device already registered locally
I (3456) MQTT: Connected with saved credentials
W (4567) WIFI: Connection failed, starting AP mode
I (5678) CONFIG: Factory reset complete!
```

## 🚨 Problemas Comuns e Soluções

### 1. Stack Overflow
**Sintoma:** Guru Meditation Error
**Solução:** Aumentar stacks no sdkconfig.defaults

### 2. MQTT "No scheme found"
**Sintoma:** Erro de conexão MQTT
**Solução:** Usar formato URI completo: mqtt://host:port

### 3. HTTP 500 no registro
**Sintoma:** Backend retorna erro 500
**Solução:** Verificar se device já existe antes de POST

### 4. AP não aparece
**Sintoma:** SSID não visível
**Solução:** Verificar WiFi event handlers separados

## 📅 Cronograma de Implementação

| Fase | Tarefa | Tempo | Status |
|------|--------|-------|--------|
| 1 | Estrutura de dados | 2h | ⏳ |
| 2 | Registro inteligente | 3h | ⏳ |
| 3 | Boot autônomo | 3h | ⏳ |
| 4 | Factory reset | 2h | ⏳ |
| 5 | MQTT persistente | 2h | ⏳ |
| 6 | Testes completos | 3h | ⏳ |
| **Total** | **15 horas** | | |

## 🎓 Conclusão do Especialista

Este plano fornece uma implementação completa e robusta para o ESP32-Relay. Seguindo estas instruções passo a passo, o sistema será:

1. **Autônomo** - Conecta e opera sem intervenção
2. **Inteligente** - Verifica antes de registrar
3. **Persistente** - Mantém configurações após reboot
4. **Robusto** - Trata falhas graciosamente
5. **Integrado** - Funciona perfeitamente com AutoCore

**Assinatura:** Dr. Alex Silva
**Data:** 11/08/2025
**Versão:** 2.1 Production Ready

---

*"Um sistema embarcado bem projetado é invisível ao usuário final"*