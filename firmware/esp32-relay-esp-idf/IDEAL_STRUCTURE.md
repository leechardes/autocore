# 🏗️ Estrutura Ideal ESP-IDF - Padrão Oficial Espressif 2024

## 📋 Estrutura Atual (Tudo em main/)
```
esp32-relay-esp-idf/
├── main/
│   ├── CMakeLists.txt
│   ├── main.c
│   ├── config_manager.c/h
│   ├── wifi_manager.c/h
│   ├── http_server.c/h
│   ├── mqtt_handler.c/h
│   └── relay_control.c/h
├── CMakeLists.txt
├── partitions.csv
└── sdkconfig
```

## ✅ Estrutura Ideal Recomendada (Componentes Modulares)

```
esp32-relay-esp-idf/
│
├── 📁 main/                          # Componente principal (mínimo código)
│   ├── CMakeLists.txt                # Apenas registra o main.c
│   ├── main.c                        # Apenas app_main() e inicialização
│   └── Kconfig.projbuild             # Configurações do projeto
│
├── 📁 components/                    # Componentes customizados do projeto
│   │
│   ├── 📁 config_manager/           # Componente de gerenciamento de configuração
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   └── config_manager.h
│   │   ├── src/
│   │   │   └── config_manager.c
│   │   ├── Kconfig                  # Opções de menu para este componente
│   │   └── idf_component.yml        # Metadados e dependências
│   │
│   ├── 📁 network/                  # Componente de rede (WiFi + HTTP + MQTT)
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   ├── wifi_manager.h
│   │   │   ├── http_server.h
│   │   │   └── mqtt_handler.h
│   │   ├── src/
│   │   │   ├── wifi_manager.c
│   │   │   ├── http_server.c
│   │   │   └── mqtt_handler.c
│   │   ├── Kconfig
│   │   └── idf_component.yml
│   │
│   ├── 📁 relay_control/            # Componente de controle de relés
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   └── relay_control.h
│   │   ├── src/
│   │   │   └── relay_control.c
│   │   ├── test/                    # Testes unitários
│   │   │   └── test_relay.c
│   │   ├── Kconfig
│   │   └── idf_component.yml
│   │
│   └── 📁 web_interface/            # Componente da interface web
│       ├── CMakeLists.txt
│       ├── include/
│       │   └── web_interface.h
│       ├── src/
│       │   └── web_interface.c
│       ├── www/                      # Arquivos HTML/CSS/JS
│       │   ├── index.html
│       │   ├── style.css
│       │   └── app.js
│       └── idf_component.yml
│
├── 📁 managed_components/           # Componentes baixados automaticamente
│   └── (componentes do IDF Component Manager)
│
├── 📁 scripts/                      # Scripts de automação
│   ├── build.py
│   ├── flash.py
│   └── monitor.py
│
├── 📁 test/                         # Testes de integração
│   └── integration_test.py
│
├── 📁 docs/                         # Documentação do projeto
│   ├── API.md
│   └── HARDWARE.md
│
├── CMakeLists.txt                   # CMake principal do projeto
├── partitions.csv                   # Tabela de partições
├── sdkconfig                        # Configuração do SDK
├── sdkconfig.defaults               # Configurações padrão
├── .gitignore
└── README.md
```

## 📝 Exemplos de CMakeLists.txt para Cada Componente

### 1️⃣ **CMakeLists.txt Principal** (raiz do projeto)
```cmake
# Versão mínima do CMake requerida
cmake_minimum_required(VERSION 3.16)

# Incluir componentes extras se necessário
set(EXTRA_COMPONENT_DIRS "components")

# Incluir ESP-IDF
include($ENV{IDF_PATH}/tools/cmake/project.cmake)

# Nome do projeto
project(esp32-relay)
```

### 2️⃣ **main/CMakeLists.txt** (simplificado)
```cmake
idf_component_register(
    SRCS "main.c"
    INCLUDE_DIRS "."
    REQUIRES 
        config_manager
        network
        relay_control
        web_interface
)
```

### 3️⃣ **components/config_manager/CMakeLists.txt**
```cmake
idf_component_register(
    SRCS 
        "src/config_manager.c"
    INCLUDE_DIRS 
        "include"
    PRIV_INCLUDE_DIRS 
        "src"
    REQUIRES 
        nvs_flash
        esp_system
    PRIV_REQUIRES
        json
)
```

### 4️⃣ **components/network/CMakeLists.txt**
```cmake
idf_component_register(
    SRCS 
        "src/wifi_manager.c"
        "src/http_server.c"
        "src/mqtt_handler.c"
    INCLUDE_DIRS 
        "include"
    PRIV_INCLUDE_DIRS 
        "src"
    REQUIRES 
        esp_wifi
        esp_http_server
        mqtt
        esp_netif
        esp_event
        config_manager
    EMBED_FILES
        "certs/ca_cert.pem"  # Se usar TLS
)
```

### 5️⃣ **components/relay_control/CMakeLists.txt**
```cmake
idf_component_register(
    SRCS 
        "src/relay_control.c"
    INCLUDE_DIRS 
        "include"
    PRIV_INCLUDE_DIRS 
        "src"
    REQUIRES 
        driver
        config_manager
    TEST_REQUIRES
        unity
)
```

### 6️⃣ **components/web_interface/CMakeLists.txt**
```cmake
idf_component_register(
    SRCS 
        "src/web_interface.c"
    INCLUDE_DIRS 
        "include"
    REQUIRES 
        esp_http_server
        network
    EMBED_FILES 
        "www/index.html"
        "www/style.css"
        "www/app.js"
)
```

## 📦 Arquivo idf_component.yml (para cada componente)

### Exemplo: components/network/idf_component.yml
```yaml
description: "Network management component for ESP32 Relay"
version: "2.0.0"
url: "https://github.com/seu-usuario/esp32-relay"
dependencies:
  idf: ">=5.0"
  espressif/mdns: "^1.2.0"  # Dependência externa exemplo
```

## 🎯 Arquivo Kconfig (para cada componente)

### Exemplo: components/relay_control/Kconfig
```kconfig
menu "Relay Control Configuration"

    config RELAY_MAX_CHANNELS
        int "Maximum number of relay channels"
        default 8
        range 1 16
        help
            Set the maximum number of relay channels supported.

    config RELAY_DEFAULT_STATE
        bool "Default relay state on boot"
        default n
        help
            Set the default state of relays when the device boots.
            
    config RELAY_INVERT_LOGIC
        bool "Invert relay logic"
        default n
        help
            If enabled, HIGH = OFF and LOW = ON.

endmenu
```

## 🚀 Vantagens da Estrutura Modular

### ✅ **Benefícios Imediatos**
1. **Separação de responsabilidades** - Cada componente tem uma função clara
2. **Reutilização** - Componentes podem ser usados em outros projetos
3. **Manutenção facilitada** - Mudanças isoladas não afetam outros módulos
4. **Testes unitários** - Cada componente pode ser testado independentemente
5. **Build incremental** - Apenas componentes modificados são recompilados

### 🔧 **Configuração Dinâmica**
- Use `menuconfig` para configurar opções sem recompilar
- Kconfig permite criar menus personalizados
- Valores configuráveis via sdkconfig

### 📊 **Gestão de Dependências**
- IDF Component Manager baixa automaticamente dependências
- Versioning semântico para componentes
- Componentes podem ser publicados no registro ESP

## 🔄 Como Migrar da Estrutura Atual

### Passo 1: Criar estrutura de diretórios
```bash
mkdir -p components/{config_manager,network,relay_control,web_interface}/{src,include}
```

### Passo 2: Mover arquivos
```bash
# Config Manager
mv main/config_manager.c components/config_manager/src/
mv main/config_manager.h components/config_manager/include/

# Network
mv main/wifi_manager.c components/network/src/
mv main/wifi_manager.h components/network/include/
mv main/http_server.c components/network/src/
mv main/http_server.h components/network/include/
mv main/mqtt_handler.c components/network/src/
mv main/mqtt_handler.h components/network/include/

# Relay Control
mv main/relay_control.c components/relay_control/src/
mv main/relay_control.h components/relay_control/include/
```

### Passo 3: Criar CMakeLists.txt para cada componente

### Passo 4: Atualizar includes nos arquivos .c
```c
// Antes
#include "config_manager.h"

// Depois (de qualquer componente)
#include "config_manager.h"  // Funciona igual devido ao INCLUDE_DIRS
```

### Passo 5: Rebuild do projeto
```bash
idf.py fullclean
idf.py build
```

## 📚 Recursos Adicionais

- [ESP-IDF Build System](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/build-system.html)
- [Creating ESP-IDF Components](https://developer.espressif.com/blog/2024/12/how-to-create-an-esp-idf-component/)
- [IDF Component Manager](https://docs.espressif.com/projects/idf-component-manager/en/latest/)

## 🎓 Comandos Úteis

```bash
# Criar novo componente automaticamente
idf.py create-component my_component

# Adicionar dependência externa
idf.py add-dependency "espressif/mdns^1.2.0"

# Listar componentes
idf.py list-components

# Build apenas um componente
idf.py build-component network
```

---

**Nota:** Esta estrutura segue as recomendações oficiais da Espressif para 2024, promovendo modularidade, reutilização e manutenibilidade do código.