# 🤖 Instruções para Claude - ESP32-Relay ESP-IDF

Este documento contém instruções específicas para assistentes IA (Claude) trabalharem com o projeto ESP32-Relay ESP-IDF.

## 🎯 Contexto do Projeto

### Visão Geral
O ESP32-Relay é um controlador de relés IoT de alta performance desenvolvido em C usando ESP-IDF v5.0. O projeto foi **migrado recentemente de MicroPython para ESP-IDF** para obter melhor performance e confiabilidade.

### Métricas de Performance Atuais
- **Boot time**: < 1 segundo
- **HTTP response**: < 10ms
- **MQTT latency**: < 50ms
- **RAM usage**: < 50KB
- **Flash usage**: < 1MB

## 🏗️ Arquitetura do Sistema

### Dual-Core Design
```
Core 0: WiFi, HTTP Server, System Tasks
Core 1: MQTT Client, Relay Control, Telemetry
```

### Componentes Principais
```
firmware/esp32-relay-esp-idf/
├── components/
│   ├── config_manager/     # Gestão de configuração (NVS)
│   ├── network/            # WiFi, HTTP, MQTT
│   ├── relay_control/      # Controle de relés
│   └── web_interface/      # Interface web estática
└── main/                   # Aplicação principal
```

## ⚡ Funcionalidades Críticas

### 1. Sistema de Relés Momentâneos
**IMPORTANTE**: Sistema de segurança crítico implementado em `mqtt_momentary.c`
- Heartbeat obrigatório a cada 1 segundo
- Desligamento automático se heartbeat falhar
- Thread-safe com mutexes
- Máximo 16 canais simultâneos

```c
// Estrutura do comando momentâneo
{
  "command": "on",
  "channel": 1,
  "momentary": true,  // ou "is_momentary": true
  "source": "backend",
  "user": "operator"
}
```

### 2. Protocolo MQTT AutoCore
- **Topics**: `autocore/{device_id}/command` e `autocore/{device_id}/telemetry`
- **QoS**: 1 para comandos, 0 para telemetria
- **LWT**: Online/offline status
- **Auto-registro**: Smart registration com backend

### 3. Configuração Dual-Mode
- **AP Mode**: SSID `esp32-relay-{id}`, IP 192.168.4.1
- **STA Mode**: Conecta ao WiFi configurado
- **Auto-switch**: AP apenas se WiFi falhar

## 🛠️ Desenvolvimento

### Ambiente Requerido
```bash
# Ativar ambiente ESP-IDF
source firmware/esp32-relay-esp-idf/activate.sh

# Comandos principais
make build          # Compilar
make flash         # Gravar
make monitor       # Monitor serial
make all           # Build + Flash + Monitor
```

### Padrões de Código
```c
// Use este estilo para novos componentes
static const char *TAG = "COMPONENT_NAME";

esp_err_t component_init(void) {
    ESP_LOGI(TAG, "Initializing component");
    // Sempre retornar ESP_OK ou erro específico
    return ESP_OK;
}
```

### Sistema de Logs
- `ESP_LOGE()` - Erros críticos
- `ESP_LOGW()` - Avisos importantes
- `ESP_LOGI()` - Informações gerais
- `ESP_LOGD()` - Debug (desabilitado em produção)
- `ESP_LOGV()` - Verbose (compilado out em release)

## 🔒 Segurança

### Validações Obrigatórias
1. **Sempre validar JSON** antes de processar
2. **Verificar limites de array** (máx 16 relays)
3. **Sanitizar strings** de entrada
4. **Rate limiting** em endpoints HTTP
5. **Timeout** em todas operações de rede

### Dados Sensíveis
```c
// NUNCA logar:
- WiFi passwords
- MQTT credentials  
- API tokens
- User data

// SEMPRE mascarar:
ESP_LOGI(TAG, "WiFi Password: ***");
```

## 📡 Integração MQTT

### Parser de Comandos
O parser em `mqtt_commands.c` suporta:
- Comandos de relay: on/off/toggle/all
- Comandos gerais: reset/status/reboot
- Detecção automática de formato JSON

### Telemetria
Publicada em `mqtt_telemetry.c`:
- Status changes
- Heartbeat (30s)
- Safety shutoff events
- System metrics

## 🐛 Debugging

### Problemas Comuns

#### 1. Relay Momentâneo não Funciona
```c
// Verificar ambos os campos
"momentary": true    // Formato antigo
"is_momentary": true // Formato novo
```

#### 2. WiFi não Conecta após Reboot
```c
// Verificar NVS
config->configured == true
strlen(config->wifi_ssid) > 0
```

#### 3. MQTT Desconecta Frequentemente
```c
// Aumentar keep-alive
#define MQTT_KEEPALIVE 120  // segundos
```

## 🚀 Otimizações

### Performance Tips
1. **Use tarefas em cores diferentes** para paralelismo
2. **Minimize alocações dinâmicas** - use buffers estáticos
3. **Cache configurações** em RAM após ler da NVS
4. **Batch telemetria** quando possível

### Memória
```c
// Monitorar heap
uint32_t free_heap = esp_get_free_heap_size();
if (free_heap < 10240) {
    ESP_LOGW(TAG, "Low memory: %lu bytes", free_heap);
}
```

## 📋 Checklist para Modificações

### Antes de Commitar
- [ ] Código compila sem warnings
- [ ] `make check` passa todos os testes
- [ ] Documentação atualizada
- [ ] Version bump em `version.h`
- [ ] CHANGELOG.md atualizado
- [ ] Testado com relay físico

### Ao Adicionar Novo Componente
1. Criar em `components/{nome}/`
2. Adicionar `CMakeLists.txt` e `Kconfig`
3. Incluir em `main/main.c`
4. Documentar em `ARCHITECTURE.md`
5. Adicionar testes em `test/`

## 🔄 Workflow Git

### Branches
- `main` - Produção estável
- `develop` - Desenvolvimento
- `feature/*` - Novas funcionalidades
- `fix/*` - Correções

### Commits
```bash
# Formato
tipo(escopo): descrição

# Exemplos
feat(mqtt): adiciona suporte a TLS
fix(relay): corrige timeout momentâneo
docs(api): atualiza endpoints HTTP
```

## 📊 Métricas de Qualidade

### Targets Obrigatórios
- **Code coverage**: > 80%
- **Cyclomatic complexity**: < 10
- **Build time**: < 30 segundos
- **Binary size**: < 1MB
- **Boot time**: < 1 segundo

### Performance Benchmarks
```c
// Medir tempo de execução
int64_t start = esp_timer_get_time();
// ... código ...
int64_t elapsed = esp_timer_get_time() - start;
ESP_LOGI(TAG, "Operation took %lld us", elapsed);
```

## 🆘 Recursos Úteis

### Documentação Interna
- `README.md` - Visão geral e quick start
- `ARCHITECTURE.md` - Arquitetura técnica
- `API.md` - Referência de APIs
- `TROUBLESHOOTING.md` - Solução de problemas
- `MQTT_PROTOCOL.md` - Protocolo MQTT detalhado

### Scripts de Automação
```bash
scripts/
├── check_port.py      # Verifica porta serial
├── device_status.py   # Status do dispositivo
├── list_ports.py      # Lista portas disponíveis
└── ota_update.py      # Update OTA
```

### Comandos Make Úteis
```bash
make help           # Lista todos os comandos
make list-ports     # Lista portas USB
make menuconfig     # Configuração do SDK
make size          # Análise de tamanho
make erase         # Apaga flash completo
```

## ⚠️ Avisos Importantes

### NÃO FAZER
- ❌ Alocar memória sem verificar retorno
- ❌ Usar delays longos no loop principal
- ❌ Ignorar valores de retorno de `esp_err_t`
- ❌ Commitar credenciais ou secrets
- ❌ Desabilitar watchdog sem razão

### SEMPRE FAZER
- ✅ Verificar NULL pointers
- ✅ Usar `ESP_ERROR_CHECK()` para erros críticos
- ✅ Liberar recursos (mutex, memória, handles)
- ✅ Testar em hardware real
- ✅ Documentar mudanças breaking

## 🎯 Prioridades do Projeto

1. **Confiabilidade** - Sistema deve ser estável 24/7
2. **Segurança** - Especialmente relés momentâneos
3. **Performance** - Manter métricas atuais ou melhorar
4. **Manutenibilidade** - Código limpo e documentado
5. **Compatibilidade** - Manter protocolo AutoCore

## 💡 Dicas para Claude

### Ao Analisar Código
1. Verificar includes e dependências
2. Checar gestão de memória
3. Validar thread safety
4. Conferir tratamento de erros
5. Avaliar performance impact

### Ao Modificar
1. Manter estilo consistente
2. Adicionar logs apropriados
3. Atualizar documentação inline
4. Considerar backward compatibility
5. Testar edge cases

### Ao Debugar
1. Começar com logs verbose
2. Verificar monitor serial
3. Usar breakpoints via JTAG se necessário
4. Checar heap e stack usage
5. Validar configurações NVS

## 📝 Notas Finais

Este projeto é parte do ecossistema **AutoCore** e deve manter compatibilidade com:
- Backend AutoCore (Node.js/Express)
- Config App (Next.js)
- Mobile App (Flutter)
- Outros dispositivos ESP32

**Última atualização**: Janeiro 2025
**Versão do firmware**: 2.0.0
**Protocolo MQTT**: v1.1.0

---

*"Performance matters, but reliability matters more."*