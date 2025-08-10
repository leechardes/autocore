# 📘 Padrões de Desenvolvimento ESP32 - AutoCore

## 🎯 Visão Geral
Este documento define os padrões e práticas para desenvolvimento de firmware ESP32 no projeto AutoCore, garantindo compatibilidade e manutenibilidade.

## 📦 Versões de Bibliotecas

### ArduinoJson
- **Versão**: 7.0.4
- **Mudanças importantes**:
  - `DynamicJsonDocument` está deprecado, usar `JsonDocument`
  - `createNestedArray()` deprecado, usar `doc[key].to<JsonArray>()`
  - `createNestedObject()` deprecado, usar `array.add<JsonObject>()`

### ESP32 Arduino Core
- **Versão**: 2.0.17
- **Notas**:
  - `String.contains()` não existe, usar `indexOf() != -1`
  - HTTPClient mudou `getResponseCode()` para `GET()` retornar o código

## 🔧 Padrões de Código

### 1. JSON Handling (ArduinoJson v7)

#### ❌ DEPRECATED (Não usar)
```cpp
// Deprecated
DynamicJsonDocument doc(512);
JsonArray array = doc.createNestedArray("items");
JsonObject obj = array.createNestedObject();
```

#### ✅ CORRETO (Usar sempre)
```cpp
// Correto para ArduinoJson v7
JsonDocument doc;  // Sem tamanho no construtor
JsonArray array = doc["items"].to<JsonArray>();
JsonObject obj = array.add<JsonObject>();
```

### 2. String Operations

#### ❌ INCORRETO
```cpp
// String.contains() não existe no ESP32 Arduino Core
if (topic.contains("/broadcast")) {
    // ...
}
```

#### ✅ CORRETO
```cpp
// Usar indexOf() para verificar substring
if (topic.indexOf("/broadcast") != -1) {
    // ...
}
```

### 3. HTTPClient

#### ❌ INCORRETO
```cpp
// getResponseCode() foi removido
int code = http.getResponseCode();
```

#### ✅ CORRETO
```cpp
// GET() retorna o código HTTP
int code = http.GET();
// ou após POST/PUT
int code = http.POST(payload);
```

### 4. Concatenação de Strings

#### ❌ INCORRETO
```cpp
// Não pode concatenar const char[] com const char*
html += "<p>Status: " + (condition ? "OK" : "Error") + "</p>";
```

#### ✅ CORRETO
```cpp
// Converter para String primeiro
html += "<p>Status: ";
html += condition ? "OK" : "Error";
html += "</p>";

// Ou usar String() explicitamente
html += String("<p>Status: ") + (condition ? "OK" : "Error") + "</p>";
```

### 5. Arquivos Ausentes

#### ❌ PROBLEMA
```cpp
#include "network/wifi_manager.h"  // Arquivo não existe
```

#### ✅ SOLUÇÃO
Criar arquivo mínimo ou comentar se não essencial:
```cpp
// WiFiManager substituído por configuração inline
// #include "network/wifi_manager.h"
```

## 📝 Checklist de Compilação

Antes de compilar, verificar:

- [ ] ArduinoJson usando `JsonDocument` em vez de `DynamicJsonDocument`
- [ ] Arrays JSON usando `.to<JsonArray>()` em vez de `createNestedArray()`
- [ ] Objetos JSON usando `.add<JsonObject>()` em vez de `createNestedObject()`
- [ ] String operations usando `indexOf()` em vez de `contains()`
- [ ] HTTPClient usando métodos corretos (GET(), POST(), etc)
- [ ] Concatenação de strings usando String() quando necessário
- [ ] Todos os arquivos de header existem

## 🚀 Configuração PlatformIO

### platformio.ini Básico
```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino

monitor_speed = 115200
upload_speed = 921600

build_flags = 
    -DCORE_DEBUG_LEVEL=3
    -DAUTOCORE_VERSION=\"1.0.0\"
    -DAUTOCORE_BUILD_DATE=\"2025-08-10\"

lib_deps = 
    PubSubClient@2.8
    bblanchon/ArduinoJson@^7.0.4  ; Especificar owner
    me-no-dev/ESP Async WebServer@^1.2.3
    me-no-dev/AsyncTCP@^1.1.1
```

## 🔨 Correções Comuns

### 1. ArduinoJson v7 Migration
```cpp
// De:
DynamicJsonDocument doc(1024);
// Para:
JsonDocument doc;
```

### 2. String Contains
```cpp
// De:
if (str.contains("text")) {}
// Para:
if (str.indexOf("text") != -1) {}
```

### 3. HTTP Response Code
```cpp
// De:
int code = http.getResponseCode();
// Para:
int code = http.GET();  // ou http.POST(), etc
```

## 📚 Referências

- [ArduinoJson v7 Migration Guide](https://arduinojson.org/v7/how-to/upgrade-from-v6/)
- [ESP32 Arduino Core Docs](https://docs.espressif.com/projects/arduino-esp32/)
- [PlatformIO ESP32 Platform](https://docs.platformio.org/en/latest/platforms/espressif32.html)

---

**Última Atualização**: 10 de Agosto de 2025  
**Maintainer**: Lee Chardes