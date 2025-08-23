# A03 - API Endpoint Documentation Audit

## 📋 Objetivo
Verificar todos os endpoints implementados no backend e atualizar a documentação de API completa

## 🎯 Tarefas
1. Analisar main.py e identificar TODOS os endpoints implementados
2. Verificar documentação existente em /docs/api/endpoints/
3. Criar documentação completa para endpoints não documentados
4. Atualizar openapi.yaml com especificações corretas
5. Garantir consistência entre código e documentação

## 🔧 Comandos
```bash
# Verificar endpoints implementados
grep -n "@app\." main.py | grep -E "(get|post|put|patch|delete|websocket)"

# Verificar documentação existente
ls -la docs/api/endpoints/

# Gerar relatório de cobertura
python3 scripts/audit_endpoints.py
```

## ✅ Checklist de Validação
- [ ] Todos os endpoints do main.py estão documentados
- [ ] Documentação inclui: método, rota, parâmetros, resposta
- [ ] OpenAPI spec está atualizada
- [ ] Exemplos de uso para cada endpoint
- [ ] Códigos de erro documentados

## 📊 Resultado Esperado
Documentação 100% completa e sincronizada com a implementação atual da API

## 🔍 Análise de Endpoints Implementados

### Endpoints Identificados no main.py:

#### System & Health
- GET `/` - Root endpoint
- GET `/api/health` - Health check
- GET `/api/status` - System status

#### Devices
- GET `/api/devices` - Lista todos dispositivos
- GET `/api/devices/available-for-relays` - Dispositivos disponíveis para relés
- GET `/api/devices/{device_id}` - Busca por ID ou UUID
- GET `/api/devices/uuid/{device_uuid}` - Busca por UUID
- POST `/api/devices` - Cria dispositivo
- PATCH `/api/devices/{device_identifier}` - Atualiza dispositivo
- DELETE `/api/devices/{device_id}` - Remove dispositivo

#### Relays
- GET `/api/relays/boards` - Lista placas de relé
- GET `/api/relays/channels` - Lista canais
- PATCH `/api/relays/channels/{channel_id}` - Atualiza canal
- POST `/api/relays/channels/{channel_id}/reset` - Reset canal
- DELETE `/api/relays/channels/{channel_id}` - Desativa canal
- POST `/api/relays/channels/{channel_id}/activate` - Ativa canal
- POST `/api/relays/boards` - Cria placa
- PATCH `/api/relays/boards/{board_id}` - Atualiza placa
- DELETE `/api/relays/boards/{board_id}` - Desativa placa

#### Screens & UI
- GET `/api/screens` - Lista telas
- POST `/api/screens` - Cria tela
- PATCH `/api/screens/{screen_id}` - Atualiza tela
- DELETE `/api/screens/{screen_id}` - Remove tela
- GET `/api/screens/{screen_id}` - Busca tela por ID
- GET `/api/screens/{screen_id}/items` - Lista itens da tela
- POST `/api/screens/{screen_id}/items` - Cria item
- PATCH `/api/screens/{screen_id}/items/{item_id}` - Atualiza item
- DELETE `/api/screens/{screen_id}/items/{item_id}` - Remove item

#### Themes
- GET `/api/themes` - Lista temas
- GET `/api/themes/default` - Tema padrão

#### Telemetry
- GET `/api/telemetry/{device_id}` - Telemetria do dispositivo

#### Events
- GET `/api/events` - Lista eventos

#### Configuration
- GET `/api/config/full/{device_uuid}` - Config completa
- GET `/api/config/full` - Config completa (preview)
- GET `/api/config/generate/{device_uuid}` - Gera config

#### Icons
- GET `/api/icons` - Lista ícones
- GET `/api/icons/{icon_name}` - Busca ícone

#### Layouts
- GET `/api/layouts` - Lista layouts

#### CAN Signals
- GET `/api/can-signals` - Lista sinais CAN
- GET `/api/can-signals/{signal_id}` - Busca sinal
- POST `/api/can-signals` - Cria sinal
- PUT `/api/can-signals/{signal_id}` - Atualiza sinal
- DELETE `/api/can-signals/{signal_id}` - Remove sinal
- POST `/api/can-signals/seed` - Popula sinais padrão

#### MQTT
- WS `/ws/mqtt` - WebSocket MQTT
- GET `/api/mqtt/config` - Config MQTT
- GET `/api/mqtt/status` - Status MQTT
- POST `/api/mqtt/clear` - Limpa histórico
- GET `/api/mqtt/topics` - Lista tópicos

#### Routers Incluídos
- `simulators.router` - Endpoints de simulação
- `macros.router` - Endpoints de macros
- `mqtt_routes.router` - Endpoints MQTT adicionais
- `protocol_routes.router` - Endpoints de protocolo

## 📝 Documentação Faltante

A documentação existente em `/docs/api/endpoints/` possui apenas:
- auth.md
- commands.md
- devices.md
- screens.md

**Faltam documentar:**
- Relays (boards e channels)
- Themes
- Telemetry
- Events
- Configuration
- Icons
- Layouts
- CAN Signals
- MQTT
- System/Health
- Routers adicionais (simulators, macros, protocol)

## 🚀 Próximos Passos

1. Criar documentação completa para cada grupo de endpoints
2. Atualizar openapi.yaml com todas as rotas
3. Adicionar exemplos de requisição/resposta
4. Documentar códigos de erro específicos
5. Criar Postman collection para testes