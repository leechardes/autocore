# 📋 Guia de Configuração - AutoTech HMI Display v2

Este guia explica como configurar os parâmetros do dispositivo HMI Display.

## 🔧 Arquivo de Configuração

Todas as configurações estão centralizadas no arquivo:
```
include/config/DeviceConfig.h
```

**IMPORTANTE**: Modifique este arquivo ANTES de compilar e fazer upload para o ESP32.

## 📝 Configurações Principais

### 1. Identificação do Dispositivo

```cpp
#define DEVICE_ID "hmi_display_1"     // ID único do dispositivo
#define DEVICE_TYPE "hmi_display"      // Tipo (não alterar)
#define DEVICE_VERSION "2.0.0"         // Versão do firmware
```

### 2. Rede WiFi

```cpp
#define WIFI_SSID "AutoTech"           // Nome da sua rede WiFi
#define WIFI_PASSWORD "autotech2025"   // Senha da sua rede WiFi
#define WIFI_TIMEOUT 30000             // Timeout conexão (ms)
```

### 3. Servidor MQTT

```cpp
#define MQTT_BROKER "192.168.4.1"      // IP do servidor MQTT
#define MQTT_PORT 1883                 // Porta MQTT
#define MQTT_USER ""                   // Usuário (se necessário)
#define MQTT_PASSWORD ""               // Senha (se necessário)
```

### 4. Pinos de Hardware

#### Botões de Navegação:
```cpp
#define BTN_PREV_PIN 35                // Botão Anterior
#define BTN_SELECT_PIN 0               // Botão Select/OK
#define BTN_NEXT_PIN 34                // Botão Próximo
```

#### LEDs RGB:
```cpp
#define LED_R_PIN 4                    // LED Vermelho
#define LED_G_PIN 16                   // LED Verde
#define LED_B_PIN 17                   // LED Azul
```

#### Display:
```cpp
#define TFT_BACKLIGHT_PIN 21           // Backlight
#define SCREEN_WIDTH 320               // Largura
#define SCREEN_HEIGHT 240              // Altura
#define DEFAULT_BACKLIGHT 100          // Brilho (0-100)
```

### 5. Comportamento

#### Intervalos de Tempo:
```cpp
#define CONFIG_REQUEST_INTERVAL 10000   // Request config (ms)
#define STATUS_REPORT_INTERVAL 30000    // Status report (ms)
#define HEARTBEAT_INTERVAL 60000        // Heartbeat (ms)
```

#### Recursos:
```cpp
#define ENABLE_OTA true                // Atualização OTA
#define ENABLE_SOUND true              // Sons/beeps
#define DEBUG_LEVEL 2                  // 0=OFF, 1=ERROR, 2=INFO, 3=DEBUG
```

## 🚀 Como Modificar

1. **Abra o arquivo**: `include/config/DeviceConfig.h`

2. **Modifique os valores** conforme sua necessidade:
   ```cpp
   // Exemplo: Mudar para sua rede WiFi
   #define WIFI_SSID "MinhaRede"
   #define WIFI_PASSWORD "MinhaSenha123"
   
   // Exemplo: Mudar IP do servidor MQTT
   #define MQTT_BROKER "192.168.1.100"
   ```

3. **Compile e faça upload**:
   ```bash
   pio run -t upload
   ```

## 🔍 Níveis de Debug

Configure o nível de informações no Serial Monitor:

- `0` = Desativado (nenhuma mensagem)
- `1` = Apenas erros
- `2` = Erros + Informações (padrão)
- `3` = Tudo (debug completo)

```cpp
#define DEBUG_LEVEL 2  // Altere conforme necessário
```

## 🌐 Configuração de Rede

### WiFi em Modo AP (Access Point)

Se quiser que o ESP32 crie sua própria rede:

```cpp
#define WIFI_MODE_AP true              // Adicione esta linha
#define WIFI_AP_SSID "AutoTech-HMI"    // Nome da rede criada
#define WIFI_AP_PASS "12345678"        // Senha (mín 8 caracteres)
```

### IP Estático

Para usar IP fixo em vez de DHCP:

```cpp
#define USE_STATIC_IP true             // Adicione esta linha
#define STATIC_IP "192.168.1.100"      // IP desejado
#define GATEWAY_IP "192.168.1.1"       // Gateway
#define SUBNET_MASK "255.255.255.0"    // Máscara
```

## 📊 Configurações Avançadas

### Memória e Performance

```cpp
#define JSON_DOCUMENT_SIZE 4096        // Tamanho buffer JSON
#define MQTT_BUFFER_SIZE 2048          // Buffer MQTT
#define MAX_SCREENS 20                 // Máximo de telas
#define LVGL_TICK_PERIOD 5             // Update rate LVGL (ms)
```

### Tópicos MQTT Customizados

Por padrão, usa o formato: `autotech/{device_id}/{tipo}`

Para customizar:
```cpp
#define CUSTOM_STATUS_TOPIC "meu/topico/status"
#define CUSTOM_CONFIG_TOPIC "meu/topico/config"
```

## ⚠️ Validações

O sistema valida automaticamente algumas configurações:
- MQTT_BUFFER_SIZE mínimo: 1024 bytes
- JSON_DOCUMENT_SIZE mínimo: 2048 bytes

## 💡 Dicas

1. **Múltiplos Dispositivos**: Use IDs únicos para cada display
   ```cpp
   #define DEVICE_ID "hmi_display_1"  // Primeiro display
   #define DEVICE_ID "hmi_display_2"  // Segundo display
   ```

2. **Economia de Energia**: Reduza intervalos se necessário
   ```cpp
   #define STATUS_REPORT_INTERVAL 60000  // 1 minuto
   #define HEARTBEAT_INTERVAL 300000     // 5 minutos
   ```

3. **Debug em Produção**: Desative para economizar recursos
   ```cpp
   #define DEBUG_LEVEL 0  // Sem debug em produção
   ```

## 🔐 Segurança

Para ambientes de produção:

1. **Sempre use senha WiFi forte**
2. **Configure usuário/senha MQTT**:
   ```cpp
   #define MQTT_USER "usuario"
   #define MQTT_PASSWORD "senha_segura"
   ```
3. **Use TLS/SSL** (requer configuração adicional)

## 📞 Suporte

Se tiver dúvidas sobre as configurações:
1. Consulte a documentação completa
2. Verifique os logs com DEBUG_LEVEL 3
3. Teste com o Gateway Simulator primeiro