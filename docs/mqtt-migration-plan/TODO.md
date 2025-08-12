# 📋 TODO - Migração MQTT v2.2.0

## 🎯 Status Geral
- **Início**: 12/08/2025
- **Versão Alvo**: MQTT Architecture v2.2.0
- **Progresso Total**: 0/47 violações corrigidas

## 📊 Dashboard de Componentes

| Componente | Violações | Status | Progresso | Responsável |
|------------|-----------|--------|-----------|-------------|
| **Gateway** | 6 | 🔴 Pendente | 0/6 | - |
| **Config-App** | 5 | 🔴 Pendente | 0/5 | - |
| **ESP32-Relay** | 8 | 🔴 Pendente | 0/8 | - |
| **ESP32-Relay-ESP-IDF** | 7 | 🔴 Pendente | 0/7 | - |
| **ESP32-Display-v2** | 15 | 🔴 Pendente | 0/15 | - |
| **ESP32-Display-ESP-IDF** | 4 | 🔴 Pendente | 0/4 | - |
| **ESP32-Display-v1** | 2 | 🔴 Pendente | 0/2 | - |

---

## 🚀 FASE 1: GATEWAY (Prioridade Alta)

### ⬜ 1.1 Correção de Tópicos
- [ ] Corrigir `relay/command` → `relays/set` em `src/core/config.py`
- [ ] Corrigir `relay/status` → `relays/state` em `src/core/config.py`
- [ ] Padronizar todos os tópicos para novo formato
- [ ] Atualizar mapeamento de rotas MQTT

### ⬜ 1.2 Protocol Version
- [ ] Adicionar validação de `protocol_version` em todos os payloads recebidos
- [ ] Incluir `protocol_version: "2.2.0"` em mensagens enviadas
- [ ] Criar middleware para validação de versão

### ⬜ 1.3 Tratamento de Erros
- [ ] Implementar códigos de erro padronizados (ERR_001-008)
- [ ] Criar handler para publicar em `autocore/errors/{uuid}/{error_type}`
- [ ] Adicionar logging estruturado de erros

### ⬜ 1.4 Melhorias
- [ ] Implementar rate limiting (100 msgs/s por dispositivo)
- [ ] Adicionar métricas de monitoramento
- [ ] Criar health check endpoint

**Arquivos a modificar:**
- `gateway/src/core/config.py`
- `gateway/src/mqtt/client.py`
- `gateway/src/handlers/relay_handler.py`
- `gateway/src/models/device.py`

---

## 🎨 FASE 2: CONFIG-APP (Prioridade Alta)

### ⬜ 2.1 Backend - Correções MQTT Monitor
- [ ] Remover UUID dos tópicos de telemetria em `backend/services/mqtt_monitor.py`
- [ ] Corrigir subscrição: `autocore/telemetry/relays/data` (sem UUID)
- [ ] Atualizar parser de mensagens para extrair UUID do payload

### ⬜ 2.2 Backend - Protocol Version
- [ ] Adicionar `protocol_version` em todas as mensagens publicadas
- [ ] Validar versão em mensagens recebidas
- [ ] Criar endpoint `/api/protocol-version` para verificação

### ⬜ 2.3 Frontend - Atualização de Tópicos
- [ ] Atualizar simulador de relays para usar novos tópicos
- [ ] Corrigir monitor MQTT para exibir nova estrutura
- [ ] Adicionar indicador de protocol version na UI

### ⬜ 2.4 Testes
- [ ] Criar testes unitários para nova estrutura
- [ ] Adicionar testes de integração com Gateway
- [ ] Validar backward compatibility

**Arquivos a modificar:**
- `config-app/backend/services/mqtt_monitor.py`
- `config-app/backend/api/mqtt_routes.py`
- `config-app/frontend/src/services/mqttService.js`
- `config-app/frontend/src/components/MQTTMonitor.jsx`

---

## 🔧 FASE 3: ESP32-RELAY (Prioridade Média)

### ⬜ 3.1 Remover Configuração via MQTT
- [ ] Deletar handler de configuração em `mqtt_handler.cpp`
- [ ] Remover subscrição do tópico `/config`
- [ ] Implementar busca de config via API REST

### ⬜ 3.2 Corrigir Heartbeat
- [ ] Implementar timeout de 1 segundo
- [ ] Configurar intervalo de 500ms
- [ ] Adicionar safety shutoff automático
- [ ] Publicar evento em `autocore/telemetry/relays/data`

### ⬜ 3.3 Padronização de Tópicos
- [ ] Trocar `relay` por `relays` em todos os tópicos
- [ ] Usar `/set` para comandos e `/state` para status
- [ ] Implementar padrão `autocore/{categoria}/{uuid}/{recurso}/{ação}`

### ⬜ 3.4 Last Will Testament
- [ ] Configurar LWT com formato correto
- [ ] QoS 1, Retain true
- [ ] Incluir reason e last_seen

**Arquivos a modificar:**
- `firmware/esp32-relay/src/mqtt/mqtt_handler.cpp`
- `firmware/esp32-relay/src/mqtt/mqtt_client.cpp`
- `firmware/esp32-relay/src/config/device_config.h`

---

## 🔧 FASE 4: ESP32-RELAY-ESP-IDF (Prioridade Média)

### ⬜ 4.1 Correção de Tópicos
- [ ] Corrigir `relay/command` → `relays/set`
- [ ] Corrigir `relay/status` → `relays/state`
- [ ] Padronizar estrutura em `mqtt_handler.c`

### ⬜ 4.2 UUID no Payload
- [ ] Adicionar UUID em todos os payloads de estado
- [ ] Incluir board_id quando aplicável
- [ ] Garantir timestamp ISO 8601

### ⬜ 4.3 Protocol Version
- [ ] Adicionar campo em todas as structs JSON
- [ ] Validar versão recebida
- [ ] Rejeitar mensagens incompatíveis

**Arquivos a modificar:**
- `firmware/esp32-relay-esp-idf/components/network/src/mqtt_handler.c`
- `firmware/esp32-relay-esp-idf/components/network/include/mqtt_protocol.h`

---

## 📱 FASE 5: ESP32-DISPLAY-V2 (Prioridade Baixa - Mais Complexo)

### ⬜ 5.1 Correção Crítica de Prefixo
- [ ] Find/Replace global: `autotech/` → `autocore/`
- [ ] Verificar TODOS os arquivos .cpp e .h
- [ ] Atualizar constantes e defines

### ⬜ 5.2 Reestruturação de Comandos
- [ ] Corrigir CommandSender para usar novos tópicos
- [ ] Implementar estrutura de payload correta
- [ ] Adicionar source_uuid e target_uuid em heartbeats

### ⬜ 5.3 Protocol Version
- [ ] Adicionar em todos os payloads
- [ ] Criar classe base para mensagens

### ⬜ 5.4 Conformidade Total
- [ ] Implementar LWT
- [ ] Corrigir QoS levels
- [ ] Adicionar tratamento de erros

**Arquivos principais:**
- `firmware/esp32-display-v2/src/core/MQTTClient.cpp`
- `firmware/esp32-display-v2/src/commands/CommandSender.cpp`
- `firmware/esp32-display-v2/src/communication/*.cpp`

---

## 📱 FASE 6: ESP32-DISPLAY-ESP-IDF (Prioridade Baixa)

### ⬜ 6.1 Implementar MQTT
- [ ] Adicionar componente MQTT
- [ ] Seguir padrão v2.2.0 desde o início
- [ ] Integrar com UI existente

### ⬜ 6.2 Sincronizar com Display v2
- [ ] Compartilhar código comum
- [ ] Manter compatibilidade

---

## 📱 FASE 7: ESP32-DISPLAY-V1 (Prioridade Baixa)

### ⬜ 7.1 Avaliar Necessidade
- [ ] Verificar se ainda é usado
- [ ] Decidir: migrar ou deprecar
- [ ] Documentar decisão

---

## 🧪 VALIDAÇÃO E TESTES

### ⬜ Scripts de Validação
- [ ] Criar script Python para validar conformidade
- [ ] Implementar CI/CD com validação automática
- [ ] Criar dashboard de conformidade

### ⬜ Testes de Integração
- [ ] Testar comunicação Gateway ↔ Config-App
- [ ] Validar fluxo de comandos completo
- [ ] Testar heartbeat e safety shutoff
- [ ] Verificar telemetria

### ⬜ Ferramentas
- [ ] Criar simulador MQTT para testes
- [ ] Implementar monitor de conformidade
- [ ] Desenvolver ferramenta de migração

---

## 📈 MÉTRICAS DE SUCESSO

- [ ] 100% dos tópicos seguindo padrão v2.2.0
- [ ] 100% dos payloads com protocol_version
- [ ] 100% dos dispositivos com LWT configurado
- [ ] 0 configurações via MQTT (tudo via API REST)
- [ ] Heartbeat funcionando em todos os momentâneos
- [ ] Rate limiting implementado
- [ ] Tratamento de erros padronizado

---

## 📝 NOTAS E OBSERVAÇÕES

### Decisões Tomadas:
- Priorizar Gateway e Config-App por serem centrais
- ESP32 Display v2 por último devido à complexidade
- Manter backward compatibility onde possível

### Riscos Identificados:
- ESP32 Display v2 pode precisar refatoração completa
- Possível incompatibilidade temporária durante migração
- Necessidade de atualizar todos os dispositivos em campo

### Próximas Reuniões:
- [ ] Review de progresso Fase 1
- [ ] Planejamento detalhado Fase 3-4
- [ ] Decisão sobre Display v1

---

## 🔄 HISTÓRICO DE ATUALIZAÇÕES

- **2025-08-12**: Documento criado, plano inicial definido
- Priorizadas Fases 1 e 2 (Gateway e Config-App)

---

**Última Atualização**: 12/08/2025  
**Responsável**: Lee Chardes  
**Versão do Plano**: 1.0.0