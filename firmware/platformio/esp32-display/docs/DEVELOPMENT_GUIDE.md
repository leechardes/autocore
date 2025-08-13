# 🛠️ Development Guide - AutoTech HMI Display v2

## 📋 Índice

- [Ambiente de Desenvolvimento](#ambiente-de-desenvolvimento)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Build e Deploy](#build-e-deploy)
- [Debugging](#debugging)
- [Testes](#testes)
- [Convenções de Código](#convenções-de-código)
- [Contribuindo](#contribuindo)
- [CI/CD](#cicd)
- [Troubleshooting](#troubleshooting)

## 💻 Ambiente de Desenvolvimento

### Pré-requisitos
- **PlatformIO** (VS Code Extension ou CLI)
- **Git** 2.20+
- **Python** 3.8+ (para scripts auxiliares)
- **Node.js** 16+ (para ferramentas de build)
- **Mosquitto** (broker MQTT local)

### Setup Inicial

#### 1. Clone do Repositório
```bash
git clone https://github.com/autocore/firmware-hmi-display-v2.git
cd firmware-hmi-display-v2
```

#### 2. Configuração do PlatformIO
```bash
# Instalar PlatformIO CLI (opcional)
pip install platformio

# Inicializar projeto
pio project init

# Instalar dependências
pio lib install
```

#### 3. Configuração do VS Code
```json
// .vscode/settings.json
{
    "platformio-ide.autoRebuildAutocompleteIndex": true,
    "platformio-ide.forceUploadAndMonitor": false,
    "C_Cpp.intelliSenseEngine": "PlatformIO",
    "files.associations": {
        "*.h": "cpp",
        "*.cpp": "cpp"
    }
}
```

#### 4. Configuração Local
```bash
# Copiar configuração exemplo
cp include/config/DeviceConfig.example.h include/config/DeviceConfig.h

# Editar configurações locais
nano include/config/DeviceConfig.h
```

### Ferramentas Recomendadas

#### VS Code Extensions
- PlatformIO IDE
- C/C++ IntelliSense
- GitLens
- Bracket Pair Colorizer
- JSON Tools
- MQTT Explorer

#### Software Auxiliar
- **MQTT Explorer**: GUI para debug MQTT
- **Serial Monitor**: Monitoramento da porta serial
- **JSON Validator**: Validação de configurações
- **Postman**: Testes de API (se aplicável)

## 📁 Estrutura do Projeto

```
autotech_hmi_display_v2/
├── docs/                      # Documentação completa
│   ├── ARCHITECTURE.md
│   ├── API_REFERENCE.md
│   └── ...
├── include/                   # Headers (.h)
│   ├── config/               # Configurações
│   │   ├── DeviceConfig.h    # Config principal
│   │   └── DeviceConfig.example.h
│   ├── core/                 # Núcleo do sistema
│   │   ├── Logger.h
│   │   ├── MQTTClient.h
│   │   └── ConfigManager.h
│   ├── ui/                   # Interface de usuário
│   │   ├── ScreenManager.h
│   │   ├── ScreenFactory.h
│   │   └── Theme.h
│   ├── communication/        # Comunicação MQTT
│   ├── navigation/           # Sistema de navegação
│   └── input/               # Entrada (touch, botões)
├── src/                      # Implementações (.cpp)
│   ├── main.cpp             # Ponto de entrada
│   ├── core/
│   ├── ui/
│   └── ...
├── lib/                      # Bibliotecas locais
├── test/                     # Testes unitários
├── tools/                    # Scripts e ferramentas
├── data/                     # Dados do filesystem
├── platformio.ini           # Configuração PlatformIO
├── dev-manager.sh          # Script de desenvolvimento
└── README.md
```

### Módulos Principais

#### Core System
- **Logger**: Sistema de logging configurável
- **MQTTClient**: Cliente MQTT otimizado
- **ConfigManager**: Gerenciamento de configurações

#### User Interface  
- **ScreenManager**: Gerencia todas as telas
- **ScreenFactory**: Cria telas dinamicamente
- **Navigator**: Sistema de navegação
- **Theme**: Sistema de temas visuais

#### Communication
- **ConfigReceiver**: Recebe configurações via MQTT
- **StatusReporter**: Envia status para o sistema
- **CommandSender**: Envia comandos para dispositivos

## 🔨 Build e Deploy

### Comandos Básicos

#### Build
```bash
# Build completo
pio run

# Build específico para ambiente
pio run -e esp32-tft-display

# Build com verbose
pio run -v

# Clean build
pio run -t clean
```

#### Upload
```bash
# Upload via USB
pio run -t upload

# Upload e monitor
pio run -t upload -t monitor

# Upload específico para porta
pio run -t upload --upload-port /dev/cu.usbserial-2110
```

#### Monitor
```bash
# Monitor serial padrão
pio device monitor

# Monitor com filtro
pio device monitor | grep "ERROR"

# Monitor com script personalizado
python tools/monitor_serial.py
```

### Script de Desenvolvimento

#### dev-manager.sh
```bash
# Tornar executável
chmod +x dev-manager.sh

# Comandos disponíveis
./dev-manager.sh build     # Build completo
./dev-manager.sh upload    # Upload firmware
./dev-manager.sh monitor   # Monitor serial
./dev-manager.sh test      # Executar testes
./dev-manager.sh clean     # Limpeza completa
./dev-manager.sh format    # Formatar código
```

### Configurações de Build

#### platformio.ini Customizado
```ini
[platformio]
default_envs = esp32-tft-display

[env:esp32-tft-display]
platform = espressif32
board = esp32dev
framework = arduino

# Bibliotecas
lib_deps = 
    bodmer/TFT_eSPI@^2.5.0
    lvgl/lvgl@^8.3.11
    bblanchon/ArduinoJson@^7.0.2
    knolleary/PubSubClient@^2.8

# Build flags
build_flags = 
    -D DEBUG_LEVEL=2
    -D USER_SETUP_LOADED=1
    -D ILI9341_2_DRIVER=1
    -D TFT_WIDTH=240
    -D TFT_HEIGHT=320
    -D LVGL_TICK_PERIOD=5
    -I include

# Upload settings
upload_speed = 115200
upload_port = /dev/cu.usbserial-*
monitor_speed = 115200
monitor_port = /dev/cu.usbserial-*
```

### Configurações por Ambiente

#### Development
```ini
[env:development]
build_flags = 
    ${env:esp32-tft-display.build_flags}
    -D DEBUG_LEVEL=3
    -D ENABLE_DEBUG_MQTT=1
    -D ENABLE_SERIAL_LOGGING=1
```

#### Production
```ini
[env:production]
build_flags = 
    ${env:esp32-tft-display.build_flags}
    -D DEBUG_LEVEL=1
    -D ENABLE_DEBUG_MQTT=0
    -O2
```

## 🐛 Debugging

### Serial Debugging

#### Logger Configuration
```cpp
// DeviceConfig.h
#define DEBUG_LEVEL 3  // 0=OFF, 1=ERROR, 2=INFO, 3=DEBUG
#define SERIAL_BAUD_RATE 115200

// Uso no código
logger->debug("Config received: %d bytes", configSize);
logger->info("MQTT connected to %s", broker);
logger->error("Failed to initialize display");
```

#### Output Filtering
```bash
# Apenas erros
pio device monitor | grep "ERROR"

# Apenas MQTT
pio device monitor | grep "MQTT"

# Excluir debug verbose
pio device monitor | grep -v "DEBUG"
```

### MQTT Debugging

#### Monitor MQTT Traffic
```bash
# Instalar mosquitto clients
sudo apt install mosquitto-clients

# Monitor todos os tópicos
mosquitto_sub -h localhost -t "autocore/#" -v

# Monitor específico
mosquitto_sub -h localhost -t "autocore/hmi_display_1/status" -v
```

#### Test MQTT Messages
```bash
# Simular configuração
mosquitto_pub -h localhost \
  -t "autocore/gateway/config/response" \
  -f test_config.json

# Simular comando
mosquitto_pub -h localhost \
  -t "autocore/hmi_display_1/command" \
  -m '{"type":"system","action":"ping"}'
```

### Memory Debugging

#### Heap Monitor
```cpp
void monitor_memory() {
    Serial.printf("Free Heap: %d bytes\n", ESP.getFreeHeap());
    Serial.printf("Max Alloc: %d bytes\n", ESP.getMaxAllocHeap());
    Serial.printf("Heap Size: %d bytes\n", ESP.getHeapSize());
    
    // Stack usage por task
    Serial.printf("Main Stack: %d bytes free\n", 
        uxTaskGetStackHighWaterMark(NULL));
}
```

#### Memory Leaks
```cpp
// Detectar vazamentos
size_t heap_before = ESP.getFreeHeap();
// ... código a testar ...
size_t heap_after = ESP.getFreeHeap();

if (heap_after < heap_before) {
    Serial.printf("Possible memory leak: %d bytes\n", 
        heap_before - heap_after);
}
```

### Performance Profiling

#### Timing Measurements
```cpp
class PerformanceTimer {
    unsigned long start_time;
    String operation;
public:
    PerformanceTimer(const String& op) : operation(op) {
        start_time = millis();
    }
    
    ~PerformanceTimer() {
        unsigned long elapsed = millis() - start_time;
        Serial.printf("[PERF] %s took %lu ms\n", 
            operation.c_str(), elapsed);
    }
};

// Uso
{
    PerformanceTimer timer("Config parsing");
    parseConfiguration(jsonStr);
} // Timer destruído automaticamente
```

## 🧪 Testes

### Testes Unitários

#### Estrutura de Testes
```
test/
├── test_main.cpp           # Runner principal
├── test_config_manager/    # Testes ConfigManager
│   └── test_config_manager.cpp
├── test_mqtt_client/       # Testes MQTTClient
│   └── test_mqtt_client.cpp
└── test_screen_factory/    # Testes ScreenFactory
    └── test_screen_factory.cpp
```

#### Exemplo de Teste
```cpp
// test/test_config_manager/test_config_manager.cpp
#include <unity.h>
#include "core/ConfigManager.h"

void test_config_loading() {
    ConfigManager config;
    String jsonStr = R"({
        "version": "2.0.0",
        "system": {"name": "Test"}
    })";
    
    TEST_ASSERT_TRUE(config.loadConfig(jsonStr));
    TEST_ASSERT_TRUE(config.hasConfig());
    TEST_ASSERT_EQUAL_STRING("2.0.0", config.getVersion().c_str());
}

void test_invalid_config() {
    ConfigManager config;
    String invalidJson = "{ invalid json }";
    
    TEST_ASSERT_FALSE(config.loadConfig(invalidJson));
    TEST_ASSERT_FALSE(config.hasConfig());
}

int main() {
    UNITY_BEGIN();
    RUN_TEST(test_config_loading);
    RUN_TEST(test_invalid_config);
    return UNITY_END();
}
```

#### Executar Testes
```bash
# Executar todos os testes
pio test

# Executar teste específico
pio test -f "test_config_manager"

# Teste com verbose
pio test -v
```

### Testes de Integração

#### Mock MQTT Broker
```cpp
class MockMQTTClient : public MQTTClient {
public:
    std::vector<String> published_messages;
    
    bool publish(const String& topic, const String& payload) override {
        published_messages.push_back(topic + ": " + payload);
        return true;
    }
    
    bool isConnected() override { return true; }
};
```

#### Teste de Fluxo Completo
```cpp
void test_config_hot_reload() {
    MockMQTTClient* mockMqtt = new MockMQTTClient();
    ConfigManager config;
    ConfigReceiver receiver(mockMqtt, &config);
    
    // Simular recebimento de configuração
    String newConfig = "...";
    receiver.handleConfigMessage(newConfig);
    
    // Verificar se foi aplicada
    TEST_ASSERT_TRUE(config.hasConfig());
    
    // Verificar se status foi enviado
    TEST_ASSERT_TRUE(mockMqtt->published_messages.size() > 0);
}
```

### Testes no Hardware

#### Teste Automatizado
```cpp
void hardware_test_sequence() {
    Serial.println("=== HARDWARE TEST SEQUENCE ===");
    
    // Teste display
    tft.fillScreen(TFT_RED);   delay(500);
    tft.fillScreen(TFT_GREEN); delay(500);
    tft.fillScreen(TFT_BLUE);  delay(500);
    Serial.println("Display: OK");
    
    // Teste touch
    if (touch.touched()) {
        Serial.println("Touch: OK");
    }
    
    // Teste botões
    for (int i = 0; i < 3; i++) {
        if (!digitalRead(button_pins[i])) {
            Serial.printf("Button %d: OK\n", i);
        }
    }
    
    // Teste LEDs
    for (auto color : {RED, GREEN, BLUE}) {
        setStatusLED(color);
        delay(200);
    }
    Serial.println("LEDs: OK");
}
```

## 📝 Convenções de Código

### C++ Style Guide

#### Naming Conventions
```cpp
// Classes: PascalCase
class ConfigManager { };
class MQTTClient { };

// Variáveis: camelCase
int configSize;
String deviceId;
bool isConnected;

// Constantes: UPPER_SNAKE_CASE
#define MAX_CONFIG_SIZE 20480
const int BUTTON_COUNT = 3;

// Arquivos: PascalCase.h/cpp
// ConfigManager.h, MQTTClient.cpp

// Funções: camelCase
void initializeSystem();
bool loadConfiguration();
```

#### Code Structure
```cpp
// Header guards
#ifndef CONFIG_MANAGER_H
#define CONFIG_MANAGER_H

// Includes
#include <Arduino.h>
#include <ArduinoJson.h>

// Forward declarations
class Logger;

// Class definition
class ConfigManager {
private:
    // Private members first
    JsonDocument config;
    bool hasValidConfig;
    
    // Private methods
    bool validateConfig();
    
public:
    // Constructors
    ConfigManager();
    
    // Public methods
    bool loadConfig(const String& jsonStr);
    bool hasConfig() const;
    
    // Destructor
    ~ConfigManager();
};

#endif // CONFIG_MANAGER_H
```

#### Comments and Documentation
```cpp
/**
 * @brief Gerencia configurações recebidas via MQTT
 * 
 * Esta classe é responsável por receber, validar e gerenciar
 * as configurações dinâmicas do sistema.
 */
class ConfigManager {
public:
    /**
     * @brief Carrega configuração a partir de string JSON
     * @param jsonStr String contendo JSON válido
     * @return true se carregamento bem-sucedido
     */
    bool loadConfig(const String& jsonStr);
    
    /// Verifica se existe configuração válida carregada
    bool hasConfig() const { return hasValidConfig; }
};
```

### Error Handling

#### Return Values
```cpp
// Use bool para operações simples
bool initializeDisplay() {
    if (!tft.begin()) {
        logger->error("Failed to initialize display");
        return false;
    }
    return true;
}

// Use enums para múltiplos estados
enum class ConfigResult {
    SUCCESS,
    INVALID_JSON,
    VALIDATION_FAILED,
    TOO_LARGE
};

ConfigResult loadConfig(const String& json) {
    if (json.length() > MAX_CONFIG_SIZE) {
        return ConfigResult::TOO_LARGE;
    }
    // ...
}
```

#### Exception Handling
```cpp
// Evite exceções no ESP32 - use códigos de retorno
// ❌ Evitar
try {
    parseJson(data);
} catch (const std::exception& e) {
    // ...
}

// ✅ Preferir
if (!parseJson(data)) {
    logger->error("Failed to parse JSON");
    return false;
}
```

### Resource Management

#### Memory Management
```cpp
// Use RAII sempre que possível
class ScreenManager {
private:
    std::vector<std::unique_ptr<ScreenBase>> screens;
    
public:
    void addScreen(std::unique_ptr<ScreenBase> screen) {
        screens.push_back(std::move(screen));
    }
}; // Destruição automática

// Para recursos do ESP32
class SPILock {
private:
    bool locked;
public:
    SPILock() : locked(false) {
        SPI.beginTransaction(SPISettings());
        locked = true;
    }
    
    ~SPILock() {
        if (locked) {
            SPI.endTransaction();
        }
    }
};
```

## 🤝 Contribuindo

### Git Workflow

#### Branch Strategy
```bash
main              # Produção estável
├── develop       # Desenvolvimento
├── feature/*     # Novas funcionalidades
├── hotfix/*      # Correções urgentes
└── release/*     # Preparação para release
```

#### Commit Convention
```bash
# Formato: tipo(escopo): descrição

feat(ui): adiciona suporte a temas customizados
fix(mqtt): corrige reconexão automática
docs(api): atualiza documentação MQTT
style(ui): ajusta layout do header
refactor(core): simplifica ConfigManager
test(mqtt): adiciona testes unitários
chore(build): atualiza dependências
```

#### Pull Request Process
1. Create feature branch from `develop`
2. Implement changes with tests
3. Update documentation if needed
4. Create PR with detailed description
5. Request review from maintainers
6. Address review feedback
7. Merge after approval

### Code Review Checklist

#### Functionality
- [ ] Código compila sem warnings
- [ ] Funcionalidade implementada corretamente
- [ ] Casos edge tratados adequadamente
- [ ] Error handling implementado
- [ ] Performance aceitável

#### Code Quality
- [ ] Segue convenções de nomenclatura
- [ ] Código bem documentado
- [ ] Sem duplicação de código
- [ ] Funções com responsabilidade única
- [ ] Headers incluídos corretamente

#### Testing
- [ ] Testes unitários implementados
- [ ] Testes passam localmente
- [ ] Coverage adequado
- [ ] Testes de hardware realizados
- [ ] Documentação atualizada

## 🚀 CI/CD

### GitHub Actions

#### Build Workflow
```yaml
# .github/workflows/build.yml
name: Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    
    - name: Install PlatformIO
      run: |
        python -m pip install --upgrade pip
        pip install platformio
    
    - name: Build firmware
      run: pio run
    
    - name: Run tests
      run: pio test
```

#### Release Workflow
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build release
      run: pio run -e production
    
    - name: Create Release
      uses: actions/create-release@v1
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        body: |
          Changes in this Release:
          - Feature updates
          - Bug fixes
        draft: false
        prerelease: false
```

### Quality Gates

#### Pre-commit Hooks
```bash
# Install pre-commit
pip install pre-commit

# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: build-check
        name: Build Check
        entry: pio run
        language: system
        pass_filenames: false
      
      - id: format-check
        name: Format Check
        entry: clang-format --dry-run --Werror
        language: system
        files: \.(cpp|h)$
```

## 🔧 Troubleshooting

### Problemas Comuns

#### Build Errors
```bash
# Erro: Library not found
# Solução: Limpar e reinstalar
pio lib uninstall --all
pio lib install

# Erro: Include path not found
# Verificar platformio.ini build_flags
build_flags = -I include

# Erro: Upload failed
# Verificar porta e permissões
sudo chmod 666 /dev/ttyUSB0
```

#### Runtime Issues
```bash
# Watchdog Reset
# Causa: Loop infinito ou task bloqueante
# Solução: Adicionar yield() ou taskYIELD()

# Memory Issues
# Causa: Heap overflow
# Solução: Reduzir uso de memória, verificar leaks

# MQTT Connection Failed
# Causa: Network/config issues
# Solução: Verificar credenciais e conectividade
```

#### Development Environment
```bash
# VS Code IntelliSense não funciona
# Solução: Rebuild index
Ctrl+Shift+P -> "PlatformIO: Rebuild IntelliSense Index"

# PlatformIO não encontrado
# Solução: Reinstalar extension
# Desinstalar > Reiniciar VS Code > Instalar

# Serial Monitor não conecta
# Solução: Verificar permissões e porta
sudo usermod -a -G dialout $USER
# Logout/Login necessário
```

### Scripts de Diagnóstico

#### System Health Check
```bash
#!/bin/bash
# tools/health_check.sh

echo "=== AutoTech HMI Development Health Check ==="

# Check PlatformIO
if command -v pio &> /dev/null; then
    echo "✓ PlatformIO installed: $(pio --version)"
else
    echo "✗ PlatformIO not found"
fi

# Check Python
if command -v python &> /dev/null; then
    echo "✓ Python installed: $(python --version)"
else
    echo "✗ Python not found"
fi

# Check USB devices
echo "USB devices:"
ls -la /dev/cu.usbserial* 2>/dev/null || echo "No USB serial devices found"

# Check MQTT broker
if command -v mosquitto &> /dev/null; then
    echo "✓ Mosquitto installed"
    if pgrep mosquitto > /dev/null; then
        echo "✓ Mosquitto running"
    else
        echo "! Mosquitto not running"
    fi
else
    echo "✗ Mosquitto not installed"
fi
```

---

**Versão**: 2.0.0  
**Última Atualização**: Janeiro 2025  
**Autor**: AutoTech Team