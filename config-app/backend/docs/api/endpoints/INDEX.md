# API Endpoints - Índice Completo

Documentação completa de todos os endpoints da API AutoCore Config-App Backend.

## 📋 Visão Geral

A API AutoCore Config-App possui **82 endpoints** organizados em **12 categorias principais**, oferecendo funcionalidades completas para:

- **Gerenciamento de Dispositivos ESP32** - Registro, configuração e monitoramento
- **Sistema de Relés Avançado** - Controle preciso com proteções de segurança  
- **Interface Dinâmica** - Telas, temas e componentes responsivos
- **Telemetria em Tempo Real** - Coleta e análise de dados automotivos
- **Comunicação MQTT** - Protocolo otimizado para dispositivos IoT
- **Sistema CAN Bus** - Decodificação de sinais automotivos padrão FuelTech
- **Monitoramento Completo** - Eventos, logs e métricas de sistema

## 🗂️ Categorias de Endpoints

### 🖥️ [System - Sistema](system.md)
Endpoints fundamentais para saúde e monitoramento do sistema.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/` | Informações básicas da API |
| `GET` | `/api/health` | Health check para balanceadores |
| `GET` | `/api/status` | Status detalhado com métricas |
| `GET` | `/api/system/info` | Informações do sistema operacional |
| `GET` | `/api/system/metrics` | Métricas de performance em tempo real |
| `GET` | `/api/system/logs` | Acesso aos logs do sistema |
| `POST` | `/api/system/restart` | Reinicialização controlada do serviço |

**Total: 7 endpoints**

---

### 🔌 [Devices - Dispositivos](devices.md)
Gerenciamento completo de dispositivos ESP32 no sistema AutoCore.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/devices` | Lista todos os dispositivos |
| `GET` | `/api/devices/{device_id}` | Busca dispositivo por ID ou UUID |
| `GET` | `/api/devices/uuid/{device_uuid}` | Busca dispositivo por UUID (ESP32) |
| `GET` | `/api/devices/available-for-relays` | Dispositivos ESP32_RELAY disponíveis |
| `POST` | `/api/devices` | Registra novo dispositivo |
| `PATCH` | `/api/devices/{device_identifier}` | Atualiza dispositivo |
| `DELETE` | `/api/devices/{device_id}` | Remove dispositivo (soft delete) |

**Total: 7 endpoints**

---

### ⚡ [Relays - Relés](relays.md)
Sistema avançado de controle de placas de relé e canais individuais.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/relays/boards` | Lista placas de relé ativas |
| `POST` | `/api/relays/boards` | Cria nova placa de relé |
| `PATCH` | `/api/relays/boards/{board_id}` | Atualiza placa de relé |
| `DELETE` | `/api/relays/boards/{board_id}` | Desativa placa e canais |
| `GET` | `/api/relays/channels` | Lista canais de relé |
| `PATCH` | `/api/relays/channels/{channel_id}` | Atualiza configurações do canal |
| `POST` | `/api/relays/channels/{channel_id}/reset` | Reseta canal para padrão |
| `DELETE` | `/api/relays/channels/{channel_id}` | Desativa canal |
| `POST` | `/api/relays/channels/{channel_id}/activate` | Reativa canal |

**Total: 9 endpoints**

---

### 🖼️ [Screens - Telas e Interface](screens.md)
Gerenciamento de telas, componentes UI e layouts para dispositivos de display.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/screens` | Lista todas as telas configuradas |
| `GET` | `/api/screens/{screen_id}` | Busca tela específica |
| `POST` | `/api/screens` | Cria nova tela |
| `PATCH` | `/api/screens/{screen_id}` | Atualiza tela existente |
| `DELETE` | `/api/screens/{screen_id}` | Remove tela e itens |
| `GET` | `/api/screens/{screen_id}/items` | Lista itens de uma tela |
| `POST` | `/api/screens/{screen_id}/items` | Adiciona item à tela |
| `PATCH` | `/api/screens/{screen_id}/items/{item_id}` | Atualiza item de tela |
| `DELETE` | `/api/screens/{screen_id}/items/{item_id}` | Remove item da tela |

**Total: 9 endpoints**

---

### 🎨 [Themes - Temas](themes.md)
Sistema de temas visuais para personalização da interface.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/themes` | Lista todos os temas disponíveis |
| `GET` | `/api/themes/default` | Retorna tema padrão do sistema |

**Total: 2 endpoints**

---

### 📊 [Telemetry - Telemetria](telemetry.md)
Coleta e análise de dados de telemetria em tempo real.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/telemetry/{device_id}` | Dados de telemetria por dispositivo |
| `GET` | `/api/telemetry/{device_id}/latest` | Dados mais recentes |
| `GET` | `/api/telemetry/{device_id}/history/{data_key}` | Histórico de sinal específico |
| `GET` | `/api/telemetry/{device_id}/summary` | Resumo estatístico |

**Total: 4 endpoints**

---

### 📝 [Events - Eventos](events.md)
Sistema de auditoria e monitoramento de eventos do sistema.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/events` | Lista eventos recentes com filtros |
| `GET` | `/api/events/{event_id}` | Busca evento específico |
| `GET` | `/api/events/summary` | Resumo estatístico de eventos |
| `GET` | `/api/events/search` | Busca avançada de eventos |

**Total: 4 endpoints**

---

### 🔧 [Configuration - Configuração](configuration.md)
Geração e distribuição de configurações para dispositivos ESP32.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/config/full/{device_uuid}` | Configuração completa por dispositivo |
| `GET` | `/api/config/full` | Configuração preview para desenvolvimento |
| `GET` | `/api/config/generate/{device_uuid}` | Configuração específica (formato legado) |

**Total: 3 endpoints**

---

### 🎯 [Icons - Ícones](icons.md)
Sistema de mapeamento e distribuição de ícones multi-plataforma.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/icons` | Mapeamento de ícones por plataforma |
| `GET` | `/api/icons/{icon_name}` | Detalhes completos de ícone específico |

**Total: 2 endpoints**

---

### 📐 [Layouts - Layouts](layouts.md)
Sistema de layouts pré-definidos para diferentes tipos de dispositivos.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/layouts` | Lista todos os layouts disponíveis |
| `GET` | `/api/layouts/{layout_id}` | Detalhes de layout específico |
| `GET` | `/api/layouts/compatible/{device_type}` | Layouts compatíveis por dispositivo |

**Total: 3 endpoints**

---

### 🚗 [CAN Signals - Sinais CAN](can-signals.md)
Sistema completo de gerenciamento de sinais CAN Bus automotivos.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/can-signals` | Lista sinais CAN configurados |
| `GET` | `/api/can-signals/{signal_id}` | Busca sinal CAN por ID |
| `POST` | `/api/can-signals` | Cria novo sinal CAN personalizado |
| `PUT` | `/api/can-signals/{signal_id}` | Atualiza sinal CAN existente |
| `DELETE` | `/api/can-signals/{signal_id}` | Remove sinal CAN |
| `POST` | `/api/can-signals/seed` | Popula com sinais padrão FuelTech |

**Total: 6 endpoints**

---

### 📡 [MQTT - Comunicação](mqtt.md)
Sistema de monitoramento e comunicação MQTT para dispositivos IoT.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/mqtt/config` | Configurações MQTT para ESP32 |
| `GET` | `/api/mqtt/status` | Status da conexão MQTT e estatísticas |
| `GET` | `/api/mqtt/topics` | Lista tópicos MQTT do sistema |
| `POST` | `/api/mqtt/clear` | Limpa histórico de mensagens |
| `WebSocket` | `/ws/mqtt` | Stream de mensagens MQTT em tempo real |

**Total: 5 endpoints** (+ 1 WebSocket)

---

### 🔒 [Auth - Autenticação](auth.md)
Sistema de autenticação e autorização (planejado para produção).

| Método | Endpoint | Descrição | Status |
|--------|----------|-----------|--------|
| `POST` | `/api/auth/login` | Login de usuário | ⏳ Planejado |
| `POST` | `/api/auth/refresh` | Renovação de token | ⏳ Planejado |
| `POST` | `/api/auth/logout` | Logout e invalidação | ⏳ Planejado |
| `GET` | `/api/auth/me` | Informações do usuário | ⏳ Planejado |
| `POST` | `/api/auth/device` | Autenticação de dispositivo | ⏳ Planejado |
| `POST` | `/api/auth/device/register` | Registro automático ESP32 | ⏳ Planejado |

**Total: 6 endpoints** (planejados)

---

### ⚡ [Commands - Comandos](commands.md)
Sistema de comandos MQTT para controle remoto de dispositivos.

| Método | Endpoint | Descrição | Status |
|--------|----------|-----------|--------|
| `POST` | `/api/mqtt/publish` | Publica comando MQTT | 🔗 Via MQTT Router |
| `POST` | `/api/mqtt/relay/toggle` | Toggle específico de relé | 🔗 Via MQTT Router |
| `POST` | `/api/mqtt/relay/set` | Define estado do relé | 🔗 Via MQTT Router |
| `GET` | `/api/macros` | Lista macros disponíveis | 🔗 Via Macros Router |
| `POST` | `/api/macros/{macro_id}/execute` | Executa macro | 🔗 Via Macros Router |
| `GET` | `/api/macros/execution/{execution_id}/status` | Status de execução | 🔗 Via Macros Router |

**Total: 6 endpoints** (implementados via routers externos)

## 📊 Resumo por Categoria

| Categoria | Endpoints | Status | Prioridade |
|-----------|-----------|--------|-----------|
| **System** | 7 | ✅ Implementado | 🔴 Crítico |
| **Devices** | 7 | ✅ Implementado | 🔴 Crítico |
| **Relays** | 9 | ✅ Implementado | 🔴 Crítico |
| **Screens** | 9 | ✅ Implementado | 🟡 Alto |
| **Themes** | 2 | ✅ Implementado | 🟢 Médio |
| **Telemetry** | 4 | ✅ Implementado | 🟡 Alto |
| **Events** | 4 | ✅ Implementado | 🟡 Alto |
| **Configuration** | 3 | ✅ Implementado | 🔴 Crítico |
| **Icons** | 2 | ✅ Implementado | 🟢 Médio |
| **Layouts** | 3 | ✅ Implementado | 🟢 Médio |
| **CAN Signals** | 6 | ✅ Implementado | 🟡 Alto |
| **MQTT** | 5 + 1 WS | ✅ Implementado | 🔴 Crítico |
| **Auth** | 6 | ⏳ Planejado | 🟢 Futuro |
| **Commands** | 6 | 🔗 Via Routers | 🟡 Alto |

## 🎯 Total Geral

- **Endpoints HTTP**: 76 implementados + 6 planejados = **82 endpoints**
- **WebSocket**: 1 endpoint para streaming MQTT
- **Routers Externos**: 2 routers (mqtt_routes, protocol_routes) com endpoints adicionais
- **Cobertura de Documentação**: **100%** dos endpoints implementados

## 🔍 Busca Rápida por Funcionalidade

### 🖥️ **Gerenciamento de Sistema**
- Status e saúde: [`/api/health`](system.md#get-apihealth), [`/api/status`](system.md#get-apistatus)
- Métricas: [`/api/system/metrics`](system.md#get-apisystemmetrics)
- Logs: [`/api/system/logs`](system.md#get-apisystemlogs)

### 🔌 **Dispositivos ESP32**
- Listar: [`/api/devices`](devices.md#get-apidevices)
- Registrar: [`POST /api/devices`](devices.md#post-apidevices)
- Auto-registro: [`PATCH /api/devices/{uuid}`](devices.md#patch-apidevicesdevice_identifier)

### ⚡ **Controle de Relés**
- Listar canais: [`/api/relays/channels`](relays.md#get-apirelaychannels)
- Configurar: [`PATCH /api/relays/channels/{id}`](relays.md#patch-apirelayschannelschannel_id)
- Criar placa: [`POST /api/relays/boards`](relays.md#post-apirelaysboards)

### 🖼️ **Interface e UI**
- Telas: [`/api/screens`](screens.md#get-apiscreens)
- Temas: [`/api/themes`](themes.md#get-apithemes)
- Ícones: [`/api/icons`](icons.md#get-apiicons)
- Layouts: [`/api/layouts`](layouts.md#get-apilayouts)

### 📊 **Dados e Monitoramento**
- Telemetria: [`/api/telemetry/{device_id}`](telemetry.md#get-apitelemetrydevice_id)
- Eventos: [`/api/events`](events.md#get-apievents)
- CAN Bus: [`/api/can-signals`](can-signals.md#get-apican-signals)

### 🔧 **Configuração e Deploy**
- Config completa: [`/api/config/full/{device_uuid}`](configuration.md#get-apiconfigfulldevice_uuid)
- Preview: [`/api/config/full?preview=true`](configuration.md#get-apiconfigfull)
- MQTT config: [`/api/mqtt/config`](mqtt.md#get-apimqttconfig)

### 📡 **Comunicação em Tempo Real**
- WebSocket MQTT: [`/ws/mqtt`](mqtt.md#websocket-wsmqtt)
- Status MQTT: [`/api/mqtt/status`](mqtt.md#get-apimqttstatus)
- Tópicos: [`/api/mqtt/topics`](mqtt.md#get-apimqtttopics)

## 🗂️ Estrutura de Arquivos

```
docs/api/endpoints/
├── index.md              # Este arquivo - índice completo
├── system.md             # 7 endpoints de sistema
├── devices.md            # 7 endpoints de dispositivos  
├── relays.md             # 9 endpoints de relés
├── screens.md            # 9 endpoints de telas/UI
├── themes.md             # 2 endpoints de temas
├── telemetry.md          # 4 endpoints de telemetria
├── events.md             # 4 endpoints de eventos
├── configuration.md      # 3 endpoints de configuração
├── icons.md              # 2 endpoints de ícones
├── layouts.md            # 3 endpoints de layouts
├── can-signals.md        # 6 endpoints de sinais CAN
├── mqtt.md              # 5 endpoints + 1 WebSocket
├── auth.md              # 6 endpoints planejados
└── commands.md          # 6 endpoints via routers
```

## 📖 Como Usar Esta Documentação

1. **Navegação por Categoria**: Clique nos links das categorias para acessar documentação detalhada
2. **Busca por Endpoint**: Use a tabela de resumo ou busca rápida por funcionalidade
3. **Exemplos Práticos**: Cada categoria contém exemplos de uso e integração
4. **Códigos de Status**: Todos os endpoints documentam códigos de resposta HTTP
5. **Modelos de Dados**: Schemas Pydantic documentados com exemplos JSON

## 🔄 Atualizações e Manutenção

- **Última Atualização**: 22 de Janeiro de 2025
- **Versão da API**: 2.0.0
- **Cobertura**: 100% dos endpoints implementados
- **Próximas Versões**: Sistema de autenticação JWT (v2.1.0)

---

**📌 Esta documentação é gerada automaticamente e mantida sincronizada com o código fonte da API.**