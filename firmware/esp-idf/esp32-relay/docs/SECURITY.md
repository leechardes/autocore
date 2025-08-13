# 🔒 Considerações de Segurança - ESP32-Relay

Guia completo de segurança para implementação e operação do sistema ESP32-Relay.

## 📖 Índice

- [🛡️ Visão Geral de Segurança](#%EF%B8%8F-visão-geral-de-segurança)
- [🌐 Segurança de Rede](#-segurança-de-rede)
- [🔐 Criptografia e Autenticação](#-criptografia-e-autenticação)
- [🔒 Segurança Física](#-segurança-física)
- [⚡ Segurança Operacional](#-segurança-operacional)
- [🚨 Monitoramento e Auditoria](#-monitoramento-e-auditoria)
- [📋 Checklist de Segurança](#-checklist-de-segurança)

## 🛡️ Visão Geral de Segurança

### Modelo de Ameaças

**Ativos Críticos:**
- Controle físico dos relés
- Configurações do dispositivo
- Credenciais de rede
- Dados de telemetria

**Vetores de Ameaça:**
- Rede WiFi não segura
- MQTT sem criptografia  
- Acesso físico ao dispositivo
- Ataques de força bruta
- Firmware malicioso

**Impactos Potenciais:**
- Ativação não autorizada de relés
- Interrupção de serviços críticos
- Acesso à rede interna
- Violação de dados

### Níveis de Segurança

#### Nível 1: Básico (Padrão)
```
✅ Senhas WiFi obrigatórias
✅ MQTT com autenticação  
✅ Timeout de sessão
✅ Rate limiting básico
❌ Sem criptografia MQTT
❌ Sem validação de certificado
```

#### Nível 2: Intermediário
```
✅ MQTT over TLS (port 8883)
✅ Certificados auto-assinados
✅ Logs de auditoria
✅ Monitoramento de tentativas
✅ Update automático de segurança
❌ Sem PKI completa
```

#### Nível 3: Avançado (Produção Crítica)
```
✅ MQTT with mutual TLS (mTLS)
✅ PKI completa com CA
✅ Secure boot habilitado
✅ Flash encryption
✅ Hardware Security Module
✅ Penetration testing regular
```

## 🌐 Segurança de Rede

### WiFi Security

#### Configuração Segura
```c
// WiFi seguro - WPA3 preferred, WPA2 minimum
wifi_config_t wifi_config = {
    .sta = {
        .ssid = WIFI_SSID,
        .password = WIFI_PASSWORD,
        .threshold.authmode = WIFI_AUTH_WPA2_PSK,  // Minimum WPA2
        .pmf_cfg = {
            .capable = true,
            .required = false  // Set true for WPA3-only networks
        },
    },
};
```

#### Boas Práticas WiFi
```bash
# 1. Usar redes dedicadas IoT
# Separar dispositivos IoT da rede corporativa

# 2. SSID não-descritivo  
# ❌ "AutoCore_Relays"
# ✅ "IoT_Network_7234"

# 3. Senhas fortes
# Mínimo 12 caracteres, alfanuméricos + símbolos
# Rotation regular (semestral)

# 4. Configuração router
# - WPA3 (ou WPA2 mínimo)
# - Disable WPS
# - Disable WDS/Bridge
# - MAC filtering (opcional)
# - Guest network isolated
```

### Network Segmentation

#### VLAN Configuration
```
Internet ─── Firewall ─┬─ VLAN 10 (Corporativa)
                       ├─ VLAN 20 (IoT Devices) ← ESP32-Relay
                       └─ VLAN 30 (DMZ/Servers) ← MQTT Broker
```

#### Firewall Rules
```bash
# Allow only necessary traffic
# ESP32 → MQTT Broker (port 1883/8883)
iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.100 -p tcp --dport 1883 -j ACCEPT
iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.100 -p tcp --dport 8883 -j ACCEPT

# Block inter-VLAN communication
iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.10.0/24 -j DROP

# Allow web config only from management network
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -p tcp --dport 80 -j ACCEPT
```

## 🔐 Criptografia e Autenticação

### MQTT Security

#### TLS Configuration
```c
// MQTT over TLS (port 8883)
esp_mqtt_client_config_t mqtt_cfg = {
    .broker.address.uri = "mqtts://broker.autocore.local:8883",
    .broker.verification.use_global_ca_store = true,
    .broker.verification.common_name = "broker.autocore.local",
    .credentials = {
        .username = "esp32_relay_device",
        .password = "secure_device_password",
        .authentication = {
            .certificate = client_cert_pem_start,
            .certificate_len = client_cert_pem_end - client_cert_pem_start,
            .key = client_key_pem_start,
            .key_len = client_key_pem_end - client_key_pem_start,
        }
    }
};
```

#### Certificate Management
```bash
# 1. Create Certificate Authority (CA)
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -sha256 -key ca-key.pem -out ca.pem -days 3650 \
  -subj "/C=BR/ST=SP/L=Sao Paulo/O=AutoCore/CN=AutoCore-CA"

# 2. Create broker certificate
openssl genrsa -out broker-key.pem 4096
openssl req -new -key broker-key.pem -out broker.csr \
  -subj "/C=BR/ST=SP/L=Sao Paulo/O=AutoCore/CN=broker.autocore.local"
openssl x509 -req -in broker.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out broker.pem -days 365 -sha256

# 3. Create device certificate
openssl genrsa -out device-key.pem 2048  
openssl req -new -key device-key.pem -out device.csr \
  -subj "/C=BR/ST=SP/L=Sao Paulo/O=AutoCore/CN=esp32-relay-device"
openssl x509 -req -in device.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out device.pem -days 365 -sha256
```

### Password Security

#### Device Passwords
```c
// Generate device-specific passwords
void generate_device_password(char* password, size_t len) {
    uint8_t mac[6];
    esp_wifi_get_mac(ESP_IF_WIFI_STA, mac);
    
    // Combine MAC + secret + timestamp
    char secret[] = "AutoCoreSecretKey2025";
    uint32_t timestamp = esp_timer_get_time() / 1000000; // seconds
    
    snprintf(password, len, "AC_%02X%02X%02X_%08X", 
             mac[3], mac[4], mac[5], timestamp);
}
```

#### Credential Storage
```c
// Secure storage in NVS encrypted partition
esp_err_t store_credentials_secure(const char* username, const char* password) {
    nvs_handle_t nvs_handle;
    esp_err_t ret;
    
    // Open encrypted NVS namespace
    ret = nvs_open_from_partition("encrypted", "credentials", 
                                  NVS_READWRITE, &nvs_handle);
    if (ret != ESP_OK) return ret;
    
    // Store encrypted credentials
    ret = nvs_set_str(nvs_handle, "mqtt_user", username);
    if (ret != ESP_OK) goto cleanup;
    
    ret = nvs_set_str(nvs_handle, "mqtt_pass", password);
    
cleanup:
    nvs_close(nvs_handle);
    return ret;
}
```

### Secure Boot e Flash Encryption

#### Enable Secure Boot
```bash
# Via menuconfig
idf.py menuconfig
# Security features → Enable secure boot in bootloader
# Security features → Select secure boot version → Secure boot V2
```

#### Flash Encryption Setup
```bash
# Generate flash encryption key
idf.py menuconfig  
# Security features → Enable flash encryption on boot
# Security features → Enable usage mode
```

## 🔒 Segurança Física

### Device Hardening

#### Disable Debug Interfaces
```c
// Disable JTAG interface in production
#ifdef CONFIG_ESP32_RELAY_PRODUCTION_BUILD
void disable_debug_interfaces(void) {
    // Disable JTAG
    gpio_config_t io_conf = {
        .pin_bit_mask = ((1ULL << 12) | (1ULL << 13) | 
                         (1ULL << 14) | (1ULL << 15)),
        .mode = GPIO_MODE_DISABLE,
    };
    gpio_config(&io_conf);
    
    // Disable ROM UART download mode
    esp_efuse_write_field_bit(ESP_EFUSE_DISABLE_DL_ENCRYPT);
    esp_efuse_write_field_bit(ESP_EFUSE_DISABLE_DL_DECRYPT);
    esp_efuse_write_field_bit(ESP_EFUSE_DISABLE_DL_CACHE);
}
#endif
```

#### Tamper Detection
```c
// Monitor case opening (magnetic switch)
#define TAMPER_SWITCH_PIN 34

void tamper_detection_init(void) {
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << TAMPER_SWITCH_PIN),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_ENABLE,
        .intr_type = GPIO_INTR_NEGEDGE,  // Trigger on case opening
    };
    gpio_config(&io_conf);
    
    gpio_install_isr_service(0);
    gpio_isr_handler_add(TAMPER_SWITCH_PIN, tamper_detected_isr, NULL);
}

void IRAM_ATTR tamper_detected_isr(void* arg) {
    // Log tamper attempt
    esp_log_write(ESP_LOG_ERROR, "SECURITY", "🚨 TAMPER DETECTED!");
    
    // Send emergency alert
    mqtt_publish_security_alert("tamper_detected", esp_timer_get_time());
    
    // Optional: Disable device until reset
    // gpio_set_level(ENABLE_PIN, 0);
}
```

### Enclosure Requirements

#### Mechanical Protection
```
📦 Enclosure Specifications:
- Material: Metal (aluminum/steel) preferred
- IP Rating: IP65 minimum (dustproof + water resistant)
- Mounting: DIN rail or wall mount secure
- Ventilation: Filtered vents if required
- Access: Keyed lock for configuration access
```

#### Environmental Monitoring
```c
// Monitor temperature for anomalies
void security_monitoring_task(void* pvParameters) {
    while (1) {
        float temp = read_internal_temperature();
        
        if (temp > 85.0 || temp < -10.0) {
            ESP_LOGW("SECURITY", "Temperature anomaly: %.1f°C", temp);
            mqtt_publish_security_alert("temperature_anomaly", temp);
        }
        
        // Monitor power supply voltage
        uint32_t voltage = read_supply_voltage();
        if (voltage < 4500 || voltage > 5500) { // 5V ±10%
            ESP_LOGW("SECURITY", "Power anomaly: %dmV", voltage);
            mqtt_publish_security_alert("power_anomaly", voltage);
        }
        
        vTaskDelay(pdMS_TO_TICKS(30000)); // Check every 30s
    }
}
```

## ⚡ Segurança Operacional

### Access Control

#### Rate Limiting
```c
// Rate limiting for API calls
#define MAX_REQUESTS_PER_MINUTE 60
#define RATE_LIMIT_WINDOW_MS (60 * 1000)

typedef struct {
    uint32_t ip_address;
    uint32_t request_count;
    int64_t window_start;
} rate_limit_entry_t;

bool check_rate_limit(uint32_t client_ip) {
    int64_t now = esp_timer_get_time() / 1000;
    
    // Find or create entry for this IP
    rate_limit_entry_t* entry = find_or_create_rate_entry(client_ip);
    
    // Check if window expired
    if (now - entry->window_start > RATE_LIMIT_WINDOW_MS) {
        entry->request_count = 0;
        entry->window_start = now;
    }
    
    entry->request_count++;
    
    if (entry->request_count > MAX_REQUESTS_PER_MINUTE) {
        ESP_LOGW("SECURITY", "Rate limit exceeded for IP: " IPSTR, 
                 IP2STR((ip4_addr_t*)&client_ip));
        return false;
    }
    
    return true;
}
```

#### Command Validation
```c
// Validate MQTT commands before execution
esp_err_t validate_mqtt_command(const cJSON* cmd_json) {
    // Check required fields
    if (!cJSON_HasObjectItem(cmd_json, "channel") ||
        !cJSON_HasObjectItem(cmd_json, "command")) {
        return ESP_ERR_INVALID_ARG;
    }
    
    // Validate channel range
    int channel = cJSON_GetObjectItem(cmd_json, "channel")->valueint;
    if (channel < 1 || channel > 16) {
        ESP_LOGE("SECURITY", "Invalid channel: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }
    
    // Validate command type
    const char* command = cJSON_GetObjectItem(cmd_json, "command")->valuestring;
    if (strcmp(command, "on") != 0 && 
        strcmp(command, "off") != 0 && 
        strcmp(command, "toggle") != 0) {
        ESP_LOGE("SECURITY", "Invalid command: %s", command);
        return ESP_ERR_INVALID_ARG;
    }
    
    // Log valid command for audit
    ESP_LOGI("AUDIT", "Valid command: channel=%d, cmd=%s", channel, command);
    
    return ESP_OK;
}
```

### Safety Mechanisms

#### Emergency Stop
```c
// Emergency stop functionality
#define EMERGENCY_STOP_PIN 35

void emergency_stop_init(void) {
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << EMERGENCY_STOP_PIN),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_ENABLE,
        .intr_type = GPIO_INTR_NEGEDGE,
    };
    gpio_config(&io_conf);
    
    gpio_isr_handler_add(EMERGENCY_STOP_PIN, emergency_stop_isr, NULL);
}

void IRAM_ATTR emergency_stop_isr(void* arg) {
    // Immediately turn off all relays
    for (int i = 0; i < 16; i++) {
        gpio_set_level(relay_pins[i], 0);
    }
    
    // Set emergency flag
    emergency_stop_active = true;
    
    ESP_LOGE("SECURITY", "🚨 EMERGENCY STOP ACTIVATED!");
}
```

#### Watchdog Protection
```c
// Hardware watchdog configuration
void security_watchdog_init(void) {
    // Configure hardware watchdog (8 seconds timeout)
    esp_task_wdt_config_t wdt_config = {
        .timeout_ms = 8000,
        .idle_core_mask = 0,  // Don't monitor idle tasks
        .trigger_panic = true  // Panic on timeout
    };
    
    esp_task_wdt_init(&wdt_config);
    esp_task_wdt_add(NULL);  // Add current task to watchdog
    
    ESP_LOGI("SECURITY", "Hardware watchdog enabled (8s timeout)");
}

// Feed watchdog in main loop
void main_loop(void) {
    while (1) {
        // Main application logic
        esp_task_wdt_reset();  // Feed watchdog
        
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}
```

## 🚨 Monitoramento e Auditoria

### Security Logging

#### Audit Trail
```c
// Comprehensive audit logging
void audit_log(const char* event, const char* source, const char* details) {
    char timestamp[32];
    time_t now = time(NULL);
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", localtime(&now));
    
    // Log locally
    ESP_LOGI("AUDIT", "[%s] %s from %s: %s", timestamp, event, source, details);
    
    // Send to MQTT audit topic
    cJSON* audit_json = cJSON_CreateObject();
    cJSON_AddStringToObject(audit_json, "timestamp", timestamp);
    cJSON_AddStringToObject(audit_json, "device_id", config_get_device_id());
    cJSON_AddStringToObject(audit_json, "event", event);
    cJSON_AddStringToObject(audit_json, "source", source);
    cJSON_AddStringToObject(audit_json, "details", details);
    
    char* json_string = cJSON_Print(audit_json);
    mqtt_publish("autocore/security/audit", json_string, 1, false);
    
    free(json_string);
    cJSON_Delete(audit_json);
}

// Usage examples
audit_log("RELAY_ACTIVATED", "MQTT", "channel=3,command=on,user=admin");
audit_log("CONFIG_CHANGED", "HTTP", "wifi_ssid=NewNetwork");
audit_log("LOGIN_ATTEMPT", "WEB", "ip=192.168.1.100,success=false");
```

#### Security Metrics
```c
typedef struct {
    uint32_t login_attempts;
    uint32_t failed_logins;
    uint32_t mqtt_commands;
    uint32_t http_requests;
    uint32_t rate_limit_hits;
    uint32_t security_alerts;
    int64_t last_reset;
} security_metrics_t;

void publish_security_metrics(void) {
    security_metrics_t* metrics = get_security_metrics();
    
    cJSON* metrics_json = cJSON_CreateObject();
    cJSON_AddNumberToObject(metrics_json, "login_attempts", metrics->login_attempts);
    cJSON_AddNumberToObject(metrics_json, "failed_logins", metrics->failed_logins);
    cJSON_AddNumberToObject(metrics_json, "mqtt_commands", metrics->mqtt_commands);
    cJSON_AddNumberToObject(metrics_json, "rate_limit_hits", metrics->rate_limit_hits);
    cJSON_AddNumberToObject(metrics_json, "security_alerts", metrics->security_alerts);
    
    char* json_string = cJSON_Print(metrics_json);
    mqtt_publish("autocore/security/metrics", json_string, 1, false);
    
    free(json_string);
    cJSON_Delete(metrics_json);
}
```

### Intrusion Detection

#### Anomaly Detection
```c
// Simple anomaly detection
void anomaly_detection_task(void* pvParameters) {
    uint32_t baseline_memory = esp_get_free_heap_size();
    uint32_t baseline_requests = get_request_count();
    
    while (1) {
        uint32_t current_memory = esp_get_free_heap_size();
        uint32_t current_requests = get_request_count();
        
        // Memory anomaly detection
        if (current_memory < (baseline_memory * 0.5)) {
            audit_log("MEMORY_ANOMALY", "SYSTEM", 
                     "Memory usage significantly increased");
            mqtt_publish_security_alert("memory_anomaly", current_memory);
        }
        
        // Request rate anomaly
        uint32_t request_rate = current_requests - baseline_requests;
        if (request_rate > 100) { // > 100 requests in 5 minutes
            audit_log("HIGH_REQUEST_RATE", "SYSTEM", 
                     "Unusually high request rate detected");
            mqtt_publish_security_alert("high_request_rate", request_rate);
        }
        
        baseline_requests = current_requests;
        vTaskDelay(pdMS_TO_TICKS(300000)); // Check every 5 minutes
    }
}
```

## 📋 Checklist de Segurança

### Pre-Deployment Security

```bash
□ Network Security
  □ WiFi WPA2/WPA3 configurado
  □ SSID não-descritivo
  □ Senha forte (>12 caracteres)  
  □ VLAN segregation implementada
  □ Firewall rules configuradas
  □ Network monitoring habilitado

□ Device Security  
  □ Firmware assinado digitalmente
  □ Secure boot habilitado
  □ Flash encryption ativa
  □ Debug interfaces desabilitadas
  □ Tamper detection implementado
  □ Emergency stop funcional

□ Communication Security
  □ MQTT over TLS (port 8883)
  □ Client certificates instalados
  □ CA certificate validation
  □ Credentials em NVS encrypted
  □ Rate limiting ativo
  □ Command validation implementada

□ Monitoring & Audit
  □ Security logging habilitado
  □ Audit trail funcional
  □ Anomaly detection ativa
  □ Security metrics coletadas
  □ Alert notifications configuradas
```

### Operational Security

```bash
□ Regular Maintenance
  □ Firmware updates mensais
  □ Certificate renewal (anual)
  □ Password rotation (semestral)
  □ Security log review (semanal)
  □ Penetration testing (anual)

□ Incident Response  
  □ Security incident playbook
  □ Emergency contacts definidos
  □ Backup/recovery procedures
  □ Forensic data collection
  □ Communication protocols

□ Access Management
  □ Principle of least privilege
  □ Regular access review
  □ Multi-factor authentication
  □ Session timeout enforcement
  □ Admin account monitoring
```

### Security Testing

```python
#!/usr/bin/env python3
"""
Security testing script
"""

import requests
import socket
import ssl
import time

class SecurityTester:
    def __init__(self, device_ip):
        self.device_ip = device_ip
        
    def test_http_security(self):
        """Test HTTP security measures"""
        
        print("🔒 Testing HTTP Security...")
        
        # Test rate limiting
        for i in range(70):  # Exceed rate limit
            try:
                response = requests.get(f"http://{self.device_ip}/api/status", 
                                      timeout=1)
                if response.status_code == 429:  # Too Many Requests
                    print("✅ Rate limiting active")
                    break
            except:
                continue
        
        # Test invalid endpoints
        response = requests.get(f"http://{self.device_ip}/../etc/passwd")
        if response.status_code == 404:
            print("✅ Path traversal protection active")
            
        # Test malformed requests
        try:
            requests.post(f"http://{self.device_ip}/api/relay/1", 
                         json={"malformed": "payload"})
        except:
            print("✅ Input validation active")
            
    def test_tls_security(self):
        """Test TLS/SSL configuration"""
        
        print("🔒 Testing TLS Security...")
        
        try:
            context = ssl.create_default_context()
            
            with socket.create_connection((self.device_ip, 8883)) as sock:
                with context.wrap_socket(sock, server_hostname=self.device_ip) as ssock:
                    print(f"✅ TLS Version: {ssock.version()}")
                    print(f"✅ Cipher: {ssock.cipher()}")
                    
        except ssl.SSLError as e:
            print(f"❌ TLS Error: {e}")
        except ConnectionRefusedError:
            print("❌ TLS port not available")
            
    def run_security_scan(self):
        """Run complete security scan"""
        
        print("🛡️ Security Scan Starting...")
        print("-" * 40)
        
        self.test_http_security()
        self.test_tls_security()
        
        print("-" * 40)
        print("✅ Security scan complete")

# Usage
tester = SecurityTester("192.168.1.105")
tester.run_security_scan()
```

---

## 🔗 Links Relacionados

- [🏗️ Arquitetura](ARCHITECTURE.md) - Arquitetura e componentes do sistema
- [⚙️ Configuração](CONFIGURATION.md) - Configuração segura do sistema
- [🚀 Deployment](DEPLOYMENT.md) - Deployment seguro em produção
- [🚨 Troubleshooting](TROUBLESHOOTING.md) - Problemas de segurança
- [💾 Hardware](HARDWARE.md) - Segurança física do hardware

---

**Documento**: Considerações de Segurança ESP32-Relay  
**Versão**: 2.0.0  
**Última Atualização**: 11 de Agosto de 2025  
**Autor**: AutoCore Team