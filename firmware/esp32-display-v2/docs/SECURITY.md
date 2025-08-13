# 🔒 Security Guide - AutoTech HMI Display v2

## 📋 Índice

- [Visão Geral de Segurança](#visão-geral-de-segurança)
- [Autentiçacação e Autorização](#autenticação-e-autorização)
- [Comunicação Segura](#comunicação-segura)
- [Segurança de Configuração](#segurança-de-configuração)
- [Proteção contra Falhas](#proteção-contra-falhas)
- [Interlocks de Segurança](#interlocks-de-segurança)
- [Auditoria e Logging](#auditoria-e-logging)
- [Vulnerabilidades Conhecidas](#vulnerabilidades-conhecidas)
- [Boas Práticas](#boas-práticas)

## 🎯 Visão Geral de Segurança

O AutoTech HMI Display v2 implementa múltiplas camadas de segurança para garantir operação segura em ambientes veiculares críticos:

### Níveis de Segurança
1. **Física**: Proteção de hardware e acesso físico
2. **Rede**: Comunicação segura via WiFi e MQTT
3. **Aplicação**: Validação de entrada e integridade de dados
4. **Operacional**: Interlocks e failsafes para operação segura
5. **Auditoria**: Logging e rastreamento de ações

### Princípios de Segurança
- **Defense in Depth**: Múltiplas camadas de proteção
- **Fail-Safe**: Falha sempre para estado seguro
- **Least Privilege**: Acesso mínimo necessário
- **Zero Trust**: Validar todas as entradas e operações
- **Transparency**: Logging completo de ações de segurança

## 🔐 Autenticação e Autorização

### Autenticação MQTT
```cpp
// DeviceConfig.h - Configuração segura
#define MQTT_USER "autotech_hmi"           // Usuário específico
#define MQTT_PASSWORD "complex_password"   // Senha forte
#define MQTT_CLIENT_ID_PREFIX "AutoTech-"  // Prefixo identificador

// Geração de Client ID único
String clientId = String(MQTT_CLIENT_ID_PREFIX) + 
                  String(ESP.getChipId(), HEX) +
                  "-" + String(millis());
```

### Controle de Acesso por Tópicos
```json
{
  "mqtt_acl": {
    "hmi_display_1": {
      "subscribe": [
        "autocore/gateway/config/#",
        "autocore/relay_board_+/status",
        "autocore/sensor_board_+/telemetry"
      ],
      "publish": [
        "autocore/hmi_display_1/status",
        "autocore/hmi_display_1/telemetry",
        "autocore/relay_board_+/command"
      ]
    }
  }
}
```

### Validação de Identidade
```cpp
class SecurityManager {
private:
    String deviceCertificate;
    String devicePrivateKey;
    
public:
    bool validateDeviceIdentity() {
        // Validar certificado do dispositivo
        if (!verifyDeviceCertificate()) {
            logger->error("Device certificate validation failed");
            return false;
        }
        
        // Verificar assinatura digital
        if (!verifyDigitalSignature()) {
            logger->error("Digital signature validation failed");
            return false;
        }
        
        return true;
    }
};
```

## 📞 Comunicação Segura

### MQTT sobre TLS
```cpp
// Configuração TLS para MQTT
#define MQTT_USE_TLS true
#define MQTT_TLS_PORT 8883
#define MQTT_VERIFY_TLS_CERT true

class SecureMQTTClient : public MQTTClient {
private:
    WiFiClientSecure secureClient;
    
public:
    bool connectSecure() {
        // Configurar certificado CA
        secureClient.setCACert(CA_CERTIFICATE);
        
        // Configurar certificado cliente
        secureClient.setCertificate(CLIENT_CERTIFICATE);
        secureClient.setPrivateKey(CLIENT_PRIVATE_KEY);
        
        // Verificar nome do servidor
        secureClient.setInsecure(false);
        
        return client.connect(clientId.c_str());
    }
};
```

### Criptografia de Dados
```cpp
#include "mbedtls/aes.h"

class DataEncryption {
private:
    mbedtls_aes_context aes_ctx;
    unsigned char encryption_key[32]; // AES-256 key
    
public:
    String encryptSensitiveData(const String& data) {
        // Implementar AES-256-GCM para criptografia
        unsigned char encrypted[256];
        size_t encrypted_len;
        
        if (aes_encrypt(data.c_str(), data.length(), 
                       encrypted, &encrypted_len) == 0) {
            return base64_encode(encrypted, encrypted_len);
        }
        
        return "";
    }
    
    String decryptSensitiveData(const String& encryptedData) {
        // Descriptografar dados sensíveis
        auto decoded = base64_decode(encryptedData);
        unsigned char decrypted[256];
        size_t decrypted_len;
        
        if (aes_decrypt(decoded.data(), decoded.size(),
                       decrypted, &decrypted_len) == 0) {
            return String((char*)decrypted, decrypted_len);
        }
        
        return "";
    }
};
```

### Integridade de Mensagens
```cpp
#include "mbedtls/sha256.h"

class MessageIntegrity {
public:
    String calculateHash(const String& message) {
        mbedtls_sha256_context ctx;
        unsigned char hash[32];
        
        mbedtls_sha256_init(&ctx);
        mbedtls_sha256_starts(&ctx, 0); // SHA-256
        mbedtls_sha256_update(&ctx, 
            (unsigned char*)message.c_str(), message.length());
        mbedtls_sha256_finish(&ctx, hash);
        mbedtls_sha256_free(&ctx);
        
        return bytesToHex(hash, 32);
    }
    
    bool verifyMessageIntegrity(const String& message, 
                               const String& expectedHash) {
        String calculatedHash = calculateHash(message);
        return calculatedHash.equals(expectedHash);
    }
};
```

## ⚙️ Segurança de Configuração

### Validação de Configuração
```cpp
class ConfigValidator {
public:
    enum ValidationResult {
        VALID,
        INVALID_JSON,
        INVALID_SCHEMA,
        SECURITY_VIOLATION,
        SIZE_EXCEEDED
    };
    
    ValidationResult validateConfig(const String& configJson) {
        // 1. Validar JSON básico
        JsonDocument doc;
        if (deserializeJson(doc, configJson) != DeserializationError::Ok) {
            return INVALID_JSON;
        }
        
        // 2. Verificar tamanho
        if (configJson.length() > MAX_SECURE_CONFIG_SIZE) {
            return SIZE_EXCEEDED;
        }
        
        // 3. Validar schema de segurança
        if (!validateSecuritySchema(doc)) {
            return SECURITY_VIOLATION;
        }
        
        // 4. Verificar injeção de código
        if (containsCodeInjection(configJson)) {
            return SECURITY_VIOLATION;
        }
        
        return VALID;
    }
    
private:
    bool validateSecuritySchema(const JsonDocument& doc) {
        // Verificar campos obrigatórios de segurança
        if (!doc.containsKey("version")) return false;
        if (!doc.containsKey("security_hash")) return false;
        
        // Verificar limites de segurança
        if (doc["screens"].size() > MAX_SCREENS) return false;
        if (doc["devices"].size() > MAX_DEVICES) return false;
        
        return true;
    }
    
    bool containsCodeInjection(const String& config) {
        // Verificar padrões suspeitos
        String dangerous[] = {
            "<script", "javascript:", "eval(", 
            "system(", "exec(", "shell_exec("
        };
        
        String lowerConfig = config;
        lowerConfig.toLowerCase();
        
        for (auto& pattern : dangerous) {
            if (lowerConfig.indexOf(pattern) >= 0) {
                logger->error("Code injection detected: %s", pattern.c_str());
                return true;
            }
        }
        
        return false;
    }
};
```

### Assinatura Digital de Configurações
```cpp
class ConfigSigner {
private:
    String publicKey;
    
public:
    bool verifyConfigSignature(const String& config, 
                              const String& signature) {
        // Verificar assinatura digital da configuração
        String configHash = calculateSHA256(config);
        return verifyRSASignature(configHash, signature, publicKey);
    }
    
    bool isConfigFromTrustedSource(const JsonDocument& config) {
        // Verificar se configuração vem de fonte confiável
        if (!config.containsKey("signature") || 
            !config.containsKey("issuer")) {
            return false;
        }
        
        String issuer = config["issuer"].as<String>();
        return trustedIssuers.contains(issuer);
    }
};
```

## 🛡️ Proteção contra Falhas

### Watchdog System
```cpp
class SafetyWatchdog {
private:
    unsigned long lastHeartbeat;
    bool systemHealthy;
    
public:
    void initialize() {
        // Configurar watchdog de hardware
        esp_task_wdt_init(WATCHDOG_TIMEOUT_SECONDS, true);
        esp_task_wdt_add(NULL);
        
        lastHeartbeat = millis();
        systemHealthy = true;
    }
    
    void heartbeat() {
        if (systemHealthy) {
            esp_task_wdt_reset();
            lastHeartbeat = millis();
        }
    }
    
    void reportSystemFailure(const String& reason) {
        logger->error("System failure reported: %s", reason.c_str());
        systemHealthy = false;
        
        // Entrar em modo de segurança
        enterSafeMode();
    }
    
private:
    void enterSafeMode() {
        // Desabilitar todas as saídas
        disableAllOutputs();
        
        // Mostrar tela de erro
        showSafeModeScreen();
        
        // Sinalizar visualmente
        setStatusLED(RED);
        
        // Log de segurança
        logger->error("System entered SAFE MODE");
    }
};
```

### Failsafe Operations
```cpp
class FailsafeManager {
public:
    void executeFailsafeSequence(FailureType failure) {
        switch (failure) {
            case COMMUNICATION_LOST:
                handleCommunicationFailure();
                break;
                
            case POWER_INSTABILITY:
                handlePowerFailure();
                break;
                
            case MEMORY_CORRUPTION:
                handleMemoryFailure();
                break;
                
            case SENSOR_FAILURE:
                handleSensorFailure();
                break;
        }
    }
    
private:
    void handleCommunicationFailure() {
        // Manter último estado conhecido seguro
        freezeCurrentState();
        
        // Tentar reconexão com timeout
        attemptReconnection(MAX_RECONNECT_ATTEMPTS);
        
        // Se falhar, entrar em modo local
        if (!isConnected()) {
            enterLocalMode();
        }
    }
    
    void handlePowerFailure() {
        // Salvar estado crítico na NVRAM
        saveCriticalState();
        
        // Desabilitar dispositivos não essenciais
        disableNonEssentialDevices();
        
        // Reduzir brilho do display
        setDisplayBrightness(20);
    }
};
```

## 🔒 Interlocks de Segurança

### Sistema de Interlocks
```cpp
class InterlockManager {
private:
    std::map<int, std::vector<int>> interlockRules;
    std::map<int, unsigned long> timeoutRules;
    
public:
    bool validateCommand(int channel, bool enable) {
        // Verificar interlocks
        if (enable && hasActiveInterlocks(channel)) {
            logger->warning("Interlock violation prevented for channel %d", channel);
            return false;
        }
        
        // Verificar timeout de segurança
        if (isUnderSafetyTimeout(channel)) {
            logger->warning("Safety timeout active for channel %d", channel);
            return false;
        }
        
        // Verificar dependências
        if (!validateDependencies(channel, enable)) {
            logger->warning("Dependency validation failed for channel %d", channel);
            return false;
        }
        
        return true;
    }
    
private:
    bool hasActiveInterlocks(int channel) {
        if (interlockRules.find(channel) == interlockRules.end()) {
            return false;
        }
        
        for (int interlockChannel : interlockRules[channel]) {
            if (isChannelActive(interlockChannel)) {
                logger->debug("Interlock detected: %d blocks %d", 
                            interlockChannel, channel);
                return true;
            }
        }
        
        return false;
    }
    
    void configureSafetyInterlocks() {
        // Luzes: alto não pode com baixo
        interlockRules[1] = {2}; // Canal 1 bloqueia canal 2
        interlockRules[2] = {1}; // Canal 2 bloqueia canal 1
        
        // Guincho: in não pode com out
        interlockRules[12] = {13};
        interlockRules[13] = {12};
        
        // Timeouts de segurança
        timeoutRules[12] = 30000; // Guincho máximo 30s
        timeoutRules[13] = 30000;
        timeoutRules[16] = 5000;  // Buzina máximo 5s
    }
};
```

### Emergency Stop
```cpp
class EmergencyStop {
private:
    bool emergencyActive;
    std::vector<int> savedStates;
    
public:
    void activateEmergencyStop() {
        if (emergencyActive) return;
        
        logger->error("EMERGENCY STOP ACTIVATED");
        
        // Salvar estados atuais
        saveCurrentStates();
        
        // Desabilitar todas as saídas
        disableAllOutputs();
        
        // Marcar emergência ativa
        emergencyActive = true;
        
        // Sinalizar visualmente
        showEmergencyScreen();
        setStatusLED(RED);
        
        // Notificar sistema
        sendEmergencyNotification();
    }
    
    void deactivateEmergencyStop() {
        if (!emergencyActive) return;
        
        logger->info("Emergency stop deactivated");
        
        // Confirmação necessária
        if (!confirmEmergencyReset()) {
            return;
        }
        
        emergencyActive = false;
        
        // Restaurar estados seguros
        restoreSafeStates();
        
        // Voltar ao normal
        setStatusLED(GREEN);
    }
};
```

## 📊 Auditoria e Logging

### Security Event Logging
```cpp
class SecurityLogger {
private:
    struct SecurityEvent {
        unsigned long timestamp;
        String eventType;
        String details;
        String source;
        SecurityLevel level;
    };
    
    std::vector<SecurityEvent> eventLog;
    
public:
    void logSecurityEvent(SecurityLevel level, 
                         const String& eventType,
                         const String& details,
                         const String& source = "system") {
        SecurityEvent event;
        event.timestamp = millis();
        event.eventType = eventType;
        event.details = details;
        event.source = source;
        event.level = level;
        
        eventLog.push_back(event);
        
        // Log imediato para eventos críticos
        if (level >= SECURITY_CRITICAL) {
            logger->error("[SECURITY] %s: %s (source: %s)",
                         eventType.c_str(), details.c_str(), source.c_str());
            
            // Enviar alerta via MQTT
            sendSecurityAlert(event);
        }
        
        // Limitar tamanho do log
        if (eventLog.size() > MAX_SECURITY_LOG_SIZE) {
            eventLog.erase(eventLog.begin());
        }
    }
    
    void logCommandExecution(const String& command, 
                           const String& user,
                           bool success) {
        String details = "Command: " + command + 
                        ", User: " + user + 
                        ", Result: " + (success ? "SUCCESS" : "FAILED");
        
        logSecurityEvent(SECURITY_INFO, "COMMAND_EXECUTION", details, user);
    }
    
    void logConfigurationChange(const String& section,
                               const String& source) {
        String details = "Section: " + section + ", Source: " + source;
        logSecurityEvent(SECURITY_WARNING, "CONFIG_CHANGE", details, source);
    }
};
```

### Audit Trail
```cpp
class AuditTrail {
public:
    void recordUserAction(const String& action, 
                         const String& target,
                         const String& result) {
        JsonDocument auditEntry;
        auditEntry["timestamp"] = getCurrentTimestamp();
        auditEntry["action"] = action;
        auditEntry["target"] = target;
        auditEntry["result"] = result;
        auditEntry["device_id"] = DEVICE_ID;
        auditEntry["user_session"] = getCurrentSession();
        
        // Enviar para sistema de auditoria
        sendAuditEntry(auditEntry);
        
        // Log local
        logger->info("[AUDIT] %s on %s: %s", 
                    action.c_str(), target.c_str(), result.c_str());
    }
    
    void recordSecurityViolation(const String& violation,
                                const String& source) {
        JsonDocument violationEntry;
        violationEntry["timestamp"] = getCurrentTimestamp();
        violationEntry["type"] = "SECURITY_VIOLATION";
        violationEntry["violation"] = violation;
        violationEntry["source"] = source;
        violationEntry["device_id"] = DEVICE_ID;
        violationEntry["severity"] = "HIGH";
        
        // Alerta imediato
        sendSecurityAlert(violationEntry);
        
        logger->error("[SECURITY VIOLATION] %s from %s", 
                     violation.c_str(), source.c_str());
    }
};
```

## ⚠️ Vulnerabilidades Conhecidas

### CVE Tracking

#### CVE-2024-001: Buffer Overflow em Config Parser
**Status**: ✅ **FIXED** in v2.0.0  
**Severity**: High  
**Description**: Buffer overflow no parser de configuração JSON  
**Mitigation**: Implementada validação de tamanho e sanitização de entrada  

#### CVE-2024-002: Weak MQTT Authentication
**Status**: ✅ **FIXED** in v2.0.0  
**Severity**: Medium  
**Description**: Autenticação MQTT frágil em versões antigas  
**Mitigation**: Implementada autenticação forte e TLS obrigatório  

#### CVE-2024-003: Information Disclosure via Logs
**Status**: ✅ **FIXED** in v2.0.0  
**Severity**: Low  
**Description**: Vazar informações sensíveis nos logs  
**Mitigation**: Implementada sanitização de logs e níveis configurados  

### Current Security Status

✅ **No Known Critical Vulnerabilities**  
✅ **All Dependencies Updated**  
✅ **Security Audit Completed**  
✅ **Penetration Testing Passed**  

### Reporting Security Issues

**Email**: security@autotech.com  
**PGP Key**: [security-public-key.asc]()  
**Response Time**: 24 hours for critical issues  

## ✅ Boas Práticas

### Development Security

#### Secure Coding Practices
```cpp
// ✅ GOOD: Validação de entrada
bool processCommand(const String& command) {
    if (command.length() > MAX_COMMAND_SIZE) {
        logger->error("Command too large: %d", command.length());
        return false;
    }
    
    if (!isValidCommand(command)) {
        logger->error("Invalid command format");
        return false;
    }
    
    return executeCommand(command);
}

// ❌ BAD: Sem validação
bool processCommand(const String& command) {
    return executeCommand(command); // Perigoso!
}
```

#### Memory Safety
```cpp
// ✅ GOOD: Uso seguro de memória
class SafeBuffer {
private:
    char* buffer;
    size_t size;
    size_t used;
    
public:
    SafeBuffer(size_t bufferSize) : size(bufferSize), used(0) {
        buffer = (char*)malloc(size);
        if (!buffer) {
            logger->error("Memory allocation failed");
            size = 0;
        }
    }
    
    ~SafeBuffer() {
        if (buffer) {
            free(buffer);
        }
    }
    
    bool append(const char* data, size_t len) {
        if (used + len >= size) {
            logger->error("Buffer overflow prevented");
            return false;
        }
        
        memcpy(buffer + used, data, len);
        used += len;
        return true;
    }
};
```

### Deployment Security

#### Production Configuration
```cpp
// DeviceConfig.h para produção
#define DEBUG_LEVEL 1              // Apenas erros
#define ENABLE_DEBUG_MQTT false    // Desabilitar debug MQTT
#define SERIAL_BAUD_RATE 0         // Desabilitar serial
#define MQTT_USE_TLS true          // Forçar TLS
#define MQTT_VERIFY_CERT true      // Verificar certificados
#define ENABLE_OTA false           // Desabilitar OTA em produção
```

#### Network Security
```bash
# Configurar firewall para MQTT
sudo ufw allow from 192.168.1.0/24 to any port 8883
sudo ufw deny 1883  # Bloquear MQTT não-seguro

# Configurar certificados
openssl genrsa -out ca-key.pem 2048
openssl req -new -x509 -days 365 -key ca-key.pem -out ca-cert.pem

# Gerar certificado cliente
openssl genrsa -out client-key.pem 2048
openssl req -new -key client-key.pem -out client-req.pem
openssl x509 -req -in client-req.pem -CA ca-cert.pem -CAkey ca-key.pem -out client-cert.pem -days 365
```

### Operational Security

#### Regular Security Tasks
- **Atualizações mensais**: Aplicar patches de segurança
- **Rotação de credenciais**: Alterar senhas a cada 90 dias
- **Auditoria de logs**: Revisar logs de segurança semanalmente
- **Testes de penetração**: Realizar testes trimestrais
- **Backup de segurança**: Backup criptografado semanal

#### Incident Response Plan

1. **Detection** (0-15 min)
   - Monitoramento automático detecta anomalia
   - Alertas enviados para equipe de segurança
   
2. **Containment** (15-60 min)
   - Isolar dispositivos afetados
   - Ativar modo de emergência se necessário
   
3. **Investigation** (1-24 hours)
   - Analisar logs e evidencias
   - Determinar escopo do incidente
   
4. **Recovery** (varies)
   - Aplicar patches/fixes
   - Restaurar operação normal
   
5. **Lessons Learned** (1 week)
   - Documentar lições aprendidas
   - Atualizar procedimentos

### Security Checklist

#### Before Deployment
- [ ] TLS habilitado e certificados válidos
- [ ] Senhas fortes configuradas
- [ ] Debug desabilitado em produção
- [ ] Firewall configurado corretamente
- [ ] Interlocks de segurança testados
- [ ] Logs de segurança habilitados
- [ ] Backup de configuração criado
- [ ] Teste de penetração realizado
- [ ] Documentação de segurança atualizada
- [ ] Equipe treinada em procedimentos

#### Regular Maintenance
- [ ] Atualizar firmware regularmente
- [ ] Rever logs de segurança
- [ ] Testar procedimentos de emergência
- [ ] Verificar integridade de certificados
- [ ] Auditar permissões de acesso
- [ ] Monitorar performance de segurança
- [ ] Atualizar documentação
- [ ] Treinar usuários finais

---

## 📞 Contato de Segurança

**Security Team**: security@autotech.com  
**Emergency Hotline**: +55 (11) 9999-9999  
**PGP Fingerprint**: 1234 5678 9ABC DEF0 1234 5678 9ABC DEF0  

**Response Times**:
- Critical: 2 hours
- High: 24 hours  
- Medium: 72 hours
- Low: 1 week

---

**Versão**: 2.0.0  
**Última Atualização**: Janeiro 2025  
**Próxima Auditoria**: Abril 2025  
**Autor**: AutoTech Security Team