# 🛠️ Troubleshooting Guide - AutoTech HMI Display v2

## 📋 Índice

- [Problemas de Inicialização](#problemas-de-inicialização)
- [Problemas de Conectividade](#problemas-de-conectividade)
- [Problemas de Display](#problemas-de-display)
- [Problemas de Configuração](#problemas-de-configuração)
- [Problemas de Performance](#problemas-de-performance)
- [Códigos de Erro](#códigos-de-erro)
- [Logs e Diagnósticos](#logs-e-diagnósticos)
- [FAQ Técnico](#faq-técnico)
- [Suporte e Contato](#suporte-e-contato)

## 🚀 Problemas de Inicialização

### Sistema não Liga
**Sintomas**: Display completamente escuro, sem resposta
**Possíveis Causas**:
- Alimentação inadequada (< 4.5V)
- Componente hardware danificado
- Firmware corrompido
- Curto-circuito

**Diagnóstico**:
```bash
# 1. Verificar alimentação
multímetro: medir tensão no VIN (deve ser 4.7V-5.3V)

# 2. Verificar corrente de consumo
multímetro: medir corrente (deve ser ~500mA)

# 3. Verificar serial
monitor serial: 115200 baud, deve mostrar boot messages
```

**Soluções**:
1. **Alimentação**: Usar fonte regulada 5V/1A mínimo
2. **Hardware**: Verificar soldas e conexões
3. **Firmware**: Re-flash usando esptool
4. **Reset**: Segurar BOOT + RST, soltar RST, soltar BOOT

### Bootloop Contínuo
**Sintomas**: Sistema reinicia constantemente
**Logs Típicos**:
```
rst:0x8 (TG1WDT_SYS_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
E (1234) esp_image: Image length exceeds partition
```

**Soluções**:
1. **Partition Scheme**: Usar `huge_app.csv` no platformio.ini
2. **Memory**: Reduzir uso de FLASH/RAM
3. **Watchdog**: Adicionar `esp_task_wdt_reset()` em loops longos
4. **Config Reset**: Apagar NVRAM com esptool

## 🌐 Problemas de Conectividade

### WiFi Não Conecta
**Sintomas**: LED vermelho, "Conectando WiFi..." infinito

**Diagnóstico Passo-a-Passo**:
```cpp
// 1. Verificar configuração
Serial.println(WIFI_SSID);
Serial.println(strlen(WIFI_PASSWORD));

// 2. Scan de redes
WiFi.scanNetworks();
for(int i = 0; i < n; i++) {
    Serial.printf("%d: %s (%d dBm)\n", i, 
        WiFi.SSID(i).c_str(), WiFi.RSSI(i));
}

// 3. Verificar RSSI
Serial.printf("RSSI: %d dBm\n", WiFi.RSSI());
```

**Soluções por Cenário**:
- **SSID não encontrado**: Verificar nome exato (case-sensitive)
- **Senha incorreta**: Re-digitar senha, verificar caracteres especiais
- **Sinal fraco** (< -80 dBm): Aproximar do roteador, usar antena externa
- **Canal congestionado**: Mudar canal do roteador (1, 6, 11)
- **Modo 5GHz**: ESP32 só suporta 2.4GHz

### MQTT Não Conecta
**Sintomas**: WiFi OK, LED amarelo, "Conectando MQTT..."

**Diagnóstico**:
```bash
# 1. Testar conectividade básica
ping 10.0.10.100
telnet 10.0.10.100 1883

# 2. Verificar broker MQTT
mosquitto_sub -h 10.0.10.100 -t "test"

# 3. Verificar credenciais
mosquitto_pub -h 10.0.10.100 -u autocore -P senha -t "test" -m "hello"
```

**Códigos de Erro MQTT**:
| Código | Significado | Solução |
|--------|-------------|----------|
| -4 | Connection timeout | Verificar IP/porta |
| -3 | Connection lost | Rede instável |
| -2 | Connect failed | Broker offline |
| 1 | Bad protocol | Versão MQTT incompatível |
| 2 | Bad client ID | ID já em uso |
| 4 | Bad credentials | Usuário/senha incorretos |
| 5 | Not authorized | Permissões insuficientes |

## 🖥️ Problemas de Display

### Tela Branca/Preta
**Sintomas**: Display liga mas não mostra conteúdo

**Verificações Hardware**:
```cpp
// Teste básico do display
void test_display() {
    if (tft.readID() == 0x9341) {
        Serial.println("ILI9341 detected");
    } else {
        Serial.println("Display not detected");
    }
    
    // Teste de cores
    tft.fillScreen(TFT_RED);   delay(1000);
    tft.fillScreen(TFT_GREEN); delay(1000);
    tft.fillScreen(TFT_BLUE);  delay(1000);
}
```

**Problemas Comuns**:
- **Inversão de cores**: Adicionar `TFT_INVERSION_ON` no User_Setup
- **Rotação incorreta**: `tft.setRotation(1)` para landscape
- **SPI speed**: Reduzir `SPI_FREQUENCY` para 40MHz
- **Conexões soltas**: Verificar continuidade dos pinos SPI

### Touch Não Responde
**Sintomas**: Display OK, touch sem resposta

**Teste Touch**:
```cpp
void test_touch() {
    if (touch.touched()) {
        TS_Point p = touch.getPoint();
        Serial.printf("Touch: X=%d, Y=%d, Z=%d\n", p.x, p.y, p.z);
        
        // Valores esperados (ESP32-2432S028R):
        // X: 200-3700, Y: 240-3800
    } else {
        Serial.println("No touch detected");
    }
}
```

**Soluções**:
- **Calibração**: Ajustar `TOUCH_MIN_X/Y` e `TOUCH_MAX_X/Y`
- **SPI conflito**: Usar SPI separado para touch
- **IRQ pin**: Verificar conexão do pino de interrupção
- **Pressão**: Touch resistivo precisa pressão adequada

### Backlight Não Funciona
**Sintomas**: Tela muito escura, conteúdo visível apenas com luz forte

**Verificação**:
```cpp
// Teste PWM do backlight
ledcSetup(0, 5000, 8);           // Canal 0, 5kHz, 8-bit
ledcAttachPin(TFT_BACKLIGHT_PIN, 0);
ledcWrite(0, 255);               // 100% brilho
```

**Problemas**:
- **Pino incorreto**: Verificar `TFT_BACKLIGHT_PIN`
- **PWM não configurado**: Configurar LEDC antes de usar
- **Hardware**: LED queimado (usar multímetro)

## ⚙️ Problemas de Configuração

### Configuração Não Carrega
**Sintomas**: "Aguardando configuração..." permanente

**Debug MQTT Config**:
```bash
# Monitor topic de configuração
mosquitto_sub -h localhost -t "autotech/gateway/config/#" -v

# Simular request manual
mosquitto_pub -h localhost \
  -t "autotech/gateway/config/request" \
  -m '{"device_id":"hmi_display_1","type":"config_request"}'
```

**Verificações**:
1. **Gateway online**: Verificar se gateway está rodando
2. **Topics corretos**: Confirmar estrutura de tópicos MQTT
3. **JSON válido**: Usar JSON validator online
4. **Tamanho**: Configuração < 20KB (limite do buffer)
5. **Timeout**: Aguardar pelo menos 30 segundos

### Hot-Reload Falha
**Sintomas**: Configuração enviada mas não aplicada

**Logs de Debug**:
```
[ERROR] Config validation failed: Invalid JSON
[WARNING] Config too large: 25000 bytes (max: 20480)
[INFO] Hot reload successful, UI rebuilt
```

**Soluções**:
- **JSON inválido**: Usar ferramenta de validação
- **Tamanho excessivo**: Reduzir número de telas/itens
- **Referências circulares**: Verificar targets de navegação
- **Memory leak**: Reiniciar ESP32 se memória insuficiente

### Interface Quebrada
**Sintomas**: Telas sem componentes, layout desorganizado

**Debug Interface**:
```cpp
void debug_screens() {
    auto screens = screenManager->getScreenIds();
    Serial.printf("Total screens: %d\n", screens.size());
    
    for (const auto& screenId : screens) {
        Serial.printf("Screen: %s\n", screenId.c_str());
    }
}
```

**Verificações**:
- **Estrutura JSON**: Array "items" presente e válido
- **IDs únicos**: Não pode haver IDs duplicados
- **Tipos válidos**: Usar apenas tipos suportados
- **Propriedades obrigatórias**: id, type, label, icon

## 📈 Problemas de Performance

### Interface Lenta
**Sintomas**: Transições lentas, resposta demorada ao toque

**Profiling Performance**:
```cpp
class PerfTimer {
    unsigned long start;
    String name;
public:
    PerfTimer(String n) : name(n), start(millis()) {}
    ~PerfTimer() {
        Serial.printf("[PERF] %s: %lu ms\n", 
            name.c_str(), millis() - start);
    }
};

// Uso
{
    PerfTimer t("Screen transition");
    navigator->navigateToScreen("lighting");
}
```

**Otimizações**:
- **LVGL buffer**: Aumentar `LVGL_BUFFER_SIZE` se houver RAM
- **SPI speed**: Aumentar `SPI_FREQUENCY` gradualmente
- **Animações**: Reduzir ou desabilitar animações
- **Refresh rate**: Reduzir `lv_task_handler()` frequency
- **Memory**: Verificar fragmentação do heap

### Alto Consumo de Memória
**Sintomas**: Reinicializações frequentes, out of memory

**Monitor Memória**:
```cpp
void memory_report() {
    Serial.printf("Free Heap: %d bytes\n", ESP.getFreeHeap());
    Serial.printf("Min Free: %d bytes\n", ESP.getMinFreeHeap());
    Serial.printf("Heap Size: %d bytes\n", ESP.getHeapSize());
    Serial.printf("Max Alloc: %d bytes\n", ESP.getMaxAllocHeap());
    
    // Fragmentação
    float fragmentation = 1.0f - (float)ESP.getMaxAllocHeap() / ESP.getFreeHeap();
    Serial.printf("Fragmentation: %.1f%%\n", fragmentation * 100);
}
```

**Soluções**:
- **Config size**: Reduzir tamanho das configurações
- **Screens cache**: Limitar número de telas em cache
- **String usage**: Usar String sparingly, preferir char[]
- **JSON docs**: Usar ArduinoJson com tamanho adequado
- **LVGL objects**: Destruir objetos não utilizados

## 🚨 Códigos de Erro

### Categorias de Erro

#### System Errors (1xxx)
| Código | Descrição | Ação |
|--------|-----------|-------|
| 1001 | Initialization failed | Verificar hardware |
| 1002 | Memory allocation error | Reduzir uso de RAM |
| 1003 | Watchdog timeout | Otimizar loops |
| 1004 | Stack overflow | Reduzir recursão |

#### Display Errors (2xxx)
| Código | Descrição | Ação |
|--------|-----------|-------|
| 2001 | Display not detected | Verificar conexões SPI |
| 2002 | Touch initialization failed | Verificar XPT2046 |
| 2003 | LVGL initialization failed | Verificar configuração |
| 2004 | Screen creation failed | Verificar memória |

#### Communication Errors (3xxx)
| Código | Descrição | Ação |
|--------|-----------|-------|
| 3001 | WiFi connection failed | Verificar credenciais |
| 3002 | MQTT connection failed | Verificar broker |
| 3003 | Config timeout | Verificar gateway |
| 3004 | Message too large | Reduzir config |

#### Configuration Errors (4xxx)
| Código | Descrição | Ação |
|--------|-----------|-------|
| 4001 | Invalid JSON | Validar JSON |
| 4002 | Schema validation failed | Verificar estrutura |
| 4003 | Missing required fields | Adicionar campos |
| 4004 | Circular reference | Verificar targets |

## 📊 Logs e Diagnósticos

### Níveis de Log
```cpp
// DeviceConfig.h
#define DEBUG_LEVEL 3  // 0=OFF, 1=ERROR, 2=INFO, 3=DEBUG

// Uso no código
logger->debug("Touch event: x=%d, y=%d", x, y);
logger->info("Screen changed to: %s", screenId.c_str());
logger->error("Failed to parse config: %s", error.c_str());
```

### Filtros de Log
```bash
# Apenas erros
pio device monitor | grep "ERROR"

# Apenas MQTT
pio device monitor | grep "MQTT"

# Performance
pio device monitor | grep "PERF"

# Excluir debug verbose
pio device monitor | grep -v "DEBUG"
```

### Diagnostic Mode
**Ativação**: Segurar todos os botões por 5 segundos

**Informações Exibidas**:
```
=== DIAGNOSTIC MODE ===
Firmware: v2.0.0
Uptime: 00:45:32
Free Heap: 180KB
WiFi RSSI: -65 dBm
MQTT: Connected
Current Screen: lighting
Touch Events: 145
Button Presses: 23
Config Version: 2.0.1
Last Error: None
```

## ❓ FAQ Técnico

### Perguntas Frequentes

**Q: O display mostra cores invertidas**
**A**: Adicione `#define TFT_INVERSION_ON` no User_Setup.h da biblioteca TFT_eSPI

**Q: Touch muito sensível ou insensível**
**A**: Ajuste os valores de calibração em DeviceConfig.h:
```cpp
#define TOUCH_MIN_X 200    // Aumentar = menos sensível
#define TOUCH_MAX_X 3700   // Diminuir = menos sensível
```

**Q: Botões físicos não respondem**
**A**: Verifique se estão configurados com INPUT_PULLUP e lógica invertida (LOW = pressionado)

**Q: Sistema trava ao receber configuração grande**
**A**: Aumente o MQTT_BUFFER_SIZE ou reduza o tamanho da configuração JSON

**Q: Hot-reload não funciona**
**A**: Verifique se o callback está registrado e a configuração é válida:
```cpp
configReceiver->enableHotReload([]() {
    // Callback de reload
});
```

**Q: LEDs de status não funcionam**
**A**: Verifique se são common cathode (LOW = acende) e os pinos estão corretos

**Q: Performance ruim com muitas telas**
**A**: Limite o cache de telas ou implemente lazy loading:
```cpp
#define MAX_CACHED_SCREENS 5
```

**Q: Problemas com caracteres acentuados**
**A**: Verifique se LVGL está configurado para UTF-8 e as fontes suportam acentos

**Q: Reset constante em operação**
**A**: Pode ser watchdog timeout. Adicione:
```cpp
esp_task_wdt_reset();  // Em loops longos
vTaskDelay(1);          // Em loops tight
```

**Q: MQTT desconecta frequentemente**
**A**: Ajuste keep-alive e implemente reconexão automática:
```cpp
#define MQTT_KEEPALIVE_SECONDS 60
```

### Comandos Úteis de Diagnóstico

```bash
# Reset completo ESP32
esptool.py --chip esp32 erase_flash

# Monitor com timestamp
pio device monitor | ts '[%Y-%m-%d %H:%M:%S]'

# Capturar logs em arquivo
pio device monitor > debug.log 2>&1

# Teste MQTT basic
mosquitto_pub -h localhost -t "test" -m "hello"
mosquitto_sub -h localhost -t "test"

# Verificar partições ESP32
esptool.py --chip esp32 read_flash 0x8000 0x1000 partition_table.bin
python $IDF_PATH/components/partition_table/gen_esp32part.py partition_table.bin
```

## 📞 Suporte e Contato

### Canais de Suporte

**GitHub Issues**: [github.com/autotech/firmware-hmi-display-v2/issues]()
- Bug reports
- Feature requests  
- Discussões técnicas

**Email Técnico**: support@autotech.com
- Suporte personalizado
- Problemas críticos
- Instalação em campo

**Documentação**: [docs.autotech.com]()
- Guias completos
- API Reference
- Tutorials

### Informações para Suporte

Ao relatar problemas, inclua:

1. **Versão do Firmware**: Encontrar em logs ou diagnostic mode
2. **Hardware**: Modelo ESP32, versão da placa
3. **Configuração**: Arquivo JSON (remover dados sensíveis)
4. **Logs**: Saída serial completa do erro
5. **Passos**: Sequência para reproduzir o problema
6. **Ambiente**: Rede, broker MQTT, gateway

### Template de Bug Report

```markdown
## Bug Report

**Versão**: v2.0.0
**Hardware**: ESP32-2432S028R
**Ambiente**: Development/Production

### Descrição
Descrição clara do problema...

### Passos para Reproduzir
1. Passo 1
2. Passo 2
3. Erro ocorre

### Comportamento Esperado
O que deveria acontecer...

### Logs
```
[Colar logs aqui]
```

### Configuração
```json
{
  "version": "2.0.0",
  "system": {...}
}
```

### Informações Adicionais
- Frequência do problema
- Condições específicas
- Workarounds conhecidos
```

---

**Versão**: 2.0.0  
**Última Atualização**: Janeiro 2025  
**Autor**: AutoTech Team