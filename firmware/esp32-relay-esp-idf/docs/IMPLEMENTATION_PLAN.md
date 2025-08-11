# 🚀 Plano de Implementação - Protocolo MQTT Completo

## 📅 Visão Geral

Implementação completa do protocolo MQTT para o ESP32-Relay seguindo a especificação em `MQTT_PROTOCOL.md`.

## 📊 Status Atual

### ✅ Já Implementado
- [x] Conexão MQTT básica
- [x] Publicação de estado em `/relays/state`
- [x] Subscrição em `/command` (básico)
- [x] Formato JSON correto para estado
- [x] Identificação única por Flash ID
- [x] Configuração persistente em NVS

### 🔧 A Implementar
- [ ] Parser completo de comandos JSON
- [ ] Sistema de telemetria
- [ ] Comandos de relé (on/off/toggle/all)
- [ ] Comandos gerais (reset/status/reboot)
- [ ] Status online/offline com LWT
- [ ] Relés momentâneos com heartbeat
- [ ] Métricas expandidas no status

## 📝 Tarefas de Implementação

### Fase 1: Parser de Comandos JSON (Prioridade Alta)

#### 1.1 Estrutura de Comando
```c
typedef struct {
    mqtt_cmd_type_t type;      // RELAY_CMD, GENERAL_CMD
    union {
        struct {
            int channel;        // 1-16 ou -1 para "all"
            relay_cmd_t cmd;    // ON, OFF, TOGGLE
            bool is_momentary;
            char source[32];
        } relay;
        struct {
            general_cmd_t cmd;  // RESET, STATUS, REBOOT, OTA
            int delay;
            char data[128];
        } general;
    } data;
} mqtt_command_t;
```

#### 1.2 Parser JSON
- [ ] Função `parse_relay_command()`
- [ ] Função `parse_general_command()`
- [ ] Validação de campos obrigatórios
- [ ] Tratamento de erros de parsing

### Fase 2: Processamento de Comandos de Relé

#### 2.1 Implementar Handlers
- [ ] `handle_relay_on(channel)`
- [ ] `handle_relay_off(channel)`
- [ ] `handle_relay_toggle(channel)`
- [ ] `handle_relay_all(command)`

#### 2.2 Lógica de Controle
```c
esp_err_t process_relay_command(mqtt_command_t* cmd) {
    // Validar canal
    if (cmd->data.relay.channel < 1 || 
        cmd->data.relay.channel > 16) {
        return ESP_ERR_INVALID_ARG;
    }
    
    // Executar comando
    switch(cmd->data.relay.cmd) {
        case RELAY_ON:
            relay_turn_on(cmd->data.relay.channel - 1);
            break;
        case RELAY_OFF:
            relay_turn_off(cmd->data.relay.channel - 1);
            break;
        case RELAY_TOGGLE:
            relay_toggle(cmd->data.relay.channel - 1);
            break;
    }
    
    // Publicar novo estado
    mqtt_publish_status();
    
    // Publicar telemetria
    mqtt_publish_telemetry(cmd->data.relay.channel, 
                          relay_get_state(cmd->data.relay.channel - 1),
                          cmd->data.relay.source);
    
    return ESP_OK;
}
```

### Fase 3: Sistema de Telemetria

#### 3.1 Estrutura de Telemetria
```c
typedef struct {
    char event_type[32];    // "relay_change", "safety_shutoff", etc
    int channel;
    bool state;
    char trigger[32];       // "mqtt", "web", "button", "auto"
    char source[32];        // origem do comando
    time_t timestamp;
} telemetry_event_t;
```

#### 3.2 Funções de Telemetria
- [ ] `mqtt_publish_telemetry()`
- [ ] `create_telemetry_json()`
- [ ] `log_telemetry_event()`

### Fase 4: Comandos Gerais

#### 4.1 Reset Command
- [ ] Reset todos os relés
- [ ] Reset configurações (opcional)
- [ ] Publicar estado após reset

#### 4.2 Status Command
- [ ] Coletar métricas do sistema
- [ ] Publicar status completo
- [ ] Republicar estado dos relés

#### 4.3 Reboot Command
- [ ] Implementar delay configurável
- [ ] Salvar estado antes de reiniciar
- [ ] Publicar telemetria de reboot

### Fase 5: Status Online/Offline

#### 5.1 Last Will Testament (LWT)
```c
// Na conexão MQTT
esp_mqtt_client_config_t mqtt_cfg = {
    .uri = mqtt_uri,
    .client_id = device_id,
    .lwt_topic = "autocore/devices/{uuid}/status",
    .lwt_msg = "{\"uuid\":\"...\",\"status\":\"offline\"}",
    .lwt_qos = 1,
    .lwt_retain = true
};
```

#### 5.2 Status Expandido
- [ ] Adicionar firmware_version
- [ ] Adicionar IP address
- [ ] Adicionar WiFi RSSI
- [ ] Adicionar uptime
- [ ] Adicionar free memory

### Fase 6: Relés Momentâneos (Opcional)

#### 6.1 Sistema de Heartbeat
```c
typedef struct {
    bool active;
    int channel;
    time_t last_heartbeat;
    float timeout;
    TimerHandle_t timer;
} momentary_relay_t;

// Array para todos os canais
momentary_relay_t momentary_relays[16];
```

#### 6.2 Monitor de Heartbeat
- [ ] Timer para verificação periódica
- [ ] Auto-desligamento em timeout
- [ ] Publicar safety_shutoff
- [ ] Limpar estado momentâneo

### Fase 7: Otimizações e Melhorias

#### 7.1 Performance
- [ ] Cache de JSON strings frequentes
- [ ] Buffer pool para mensagens MQTT
- [ ] Batch de publicações quando possível

#### 7.2 Confiabilidade
- [ ] Retry logic para publicações críticas
- [ ] Queue de comandos pendentes
- [ ] Persistência de estado em NVS

#### 7.3 Segurança
- [ ] Validação de tamanho de payloads
- [ ] Rate limiting de comandos
- [ ] Autenticação de comandos (futuro)

## 📦 Estrutura de Arquivos

```
components/network/
├── include/
│   ├── mqtt_handler.h       (existente)
│   ├── mqtt_protocol.h      (novo)
│   └── mqtt_telemetry.h     (novo)
├── src/
│   ├── mqtt_handler.c       (existente)
│   ├── mqtt_commands.c      (novo)
│   └── mqtt_telemetry.c     (novo)
```

## 🧪 Testes Necessários

### Testes Unitários
- [ ] Parser JSON com payloads válidos
- [ ] Parser JSON com payloads inválidos
- [ ] Comandos de relé individuais
- [ ] Comando "all" para todos os relés
- [ ] Geração de telemetria

### Testes de Integração
- [ ] Conexão e reconexão MQTT
- [ ] Recepção e processamento de comandos
- [ ] Publicação de estados e telemetria
- [ ] Sistema de heartbeat
- [ ] LWT funcionando

### Testes de Stress
- [ ] Múltiplos comandos simultâneos
- [ ] Comandos durante reconexão
- [ ] Memória após longos períodos
- [ ] Performance com 16 relés ativos

## 📈 Métricas de Sucesso

- ✅ 100% compatibilidade com simulador Python
- ✅ Latência comando → ação < 100ms
- ✅ Zero crashes em 24h de operação
- ✅ Memória estável (sem leaks)
- ✅ Reconexão automática funcional

## 🗓️ Cronograma Estimado

| Fase | Tempo Estimado | Prioridade |
|------|---------------|------------|
| Fase 1: Parser JSON | 2 horas | Alta |
| Fase 2: Comandos Relé | 2 horas | Alta |
| Fase 3: Telemetria | 1 hora | Alta |
| Fase 4: Comandos Gerais | 2 horas | Média |
| Fase 5: Status Online/Offline | 1 hora | Média |
| Fase 6: Relés Momentâneos | 3 horas | Baixa |
| Fase 7: Otimizações | 2 horas | Baixa |

**Total Estimado:** 13 horas de desenvolvimento

## 🚀 Próximos Passos Imediatos

1. **Criar arquivo `mqtt_protocol.h`** com definições de estruturas
2. **Implementar parser de comandos JSON** em `mqtt_commands.c`
3. **Adicionar handlers de comandos** no mqtt_handler.c
4. **Testar com simulador Python** para validação

---

**Última Atualização:** 11 de Agosto de 2025  
**Status:** Pronto para Implementação  
**Maintainer:** AutoCore Team