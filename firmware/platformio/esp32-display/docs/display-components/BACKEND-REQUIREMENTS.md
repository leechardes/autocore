# Backend Requirements - Display P System

Este documento detalha a estrutura atual do backend, os campos necessários para suportar todos os componentes visuais e as mudanças necessárias para implementação completa no ESP32-Display.

## 1. Estrutura Atual do Endpoint

### 1.1. Endpoint Principal: `/api/config/full/{device_uuid}`

**Método**: GET  
**Finalidade**: Retorna configuração completa para dispositivos ESP32  
**Otimização**: Reduz número de requisições no ESP32  

### 1.2. Estrutura de Resposta Atual

```json
{
  "version": "2.0.0",
  "protocol_version": "2.2.0",
  "timestamp": "2025-08-17T10:30:00Z",
  "device": {
    "id": 1,
    "uuid": "esp32-display-001",
    "type": "esp32_display",
    "name": "Display Principal",
    "status": "online",
    "ip_address": "192.168.1.100",
    "mac_address": "AA:BB:CC:DD:EE:FF"
  },
  "system": {
    "name": "AutoCore System",
    "language": "pt-BR"
  },
  "screens": [ /* array de telas */ ],
  "devices": [ /* registry de dispositivos */ ],
  "relay_boards": [ /* placas de relé */ ],
  "theme": { /* tema padrão */ }
}
```

## 2. Estrutura das Telas (Screens)

### 2.1. Modelo Atual da Tabela `screens`

```sql
CREATE TABLE screens (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,           -- ID único da tela
    title VARCHAR(100) NOT NULL,          -- Título exibido
    icon VARCHAR(50),                     -- Ícone da tela
    screen_type VARCHAR(50),              -- dashboard, control, settings
    parent_id INTEGER,                    -- Hierarquia de telas
    position INTEGER DEFAULT 0,          -- Ordem de exibição
    
    -- Layout por dispositivo
    columns_mobile INTEGER DEFAULT 2,
    columns_display_small INTEGER DEFAULT 2,    -- ✅ Display P
    columns_display_large INTEGER DEFAULT 4,    -- ✅ Display G
    columns_web INTEGER DEFAULT 4,
    
    is_visible BOOLEAN DEFAULT TRUE,
    required_permission VARCHAR(50),
    
    -- Visibilidade por dispositivo
    show_on_mobile BOOLEAN DEFAULT TRUE,
    show_on_display_small BOOLEAN DEFAULT TRUE,     -- ✅ Display P
    show_on_display_large BOOLEAN DEFAULT TRUE,     -- ✅ Display G
    show_on_web BOOLEAN DEFAULT TRUE,
    show_on_controls BOOLEAN DEFAULT FALSE,
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 2.2. JSON Gerado para Telas

```json
{
  "id": 1,
  "name": "main_dashboard",
  "title": "Dashboard Principal",
  "icon": "gauge",
  "screen_type": "dashboard",
  "parent_id": null,
  "position": 1,
  "columns_display_small": 2,
  "columns_display_large": 3,
  "is_visible": true,
  "show_on_display_small": true,
  "show_on_display_large": true,
  "items": [ /* array de screen_items */ ]
}
```

## 3. Estrutura dos Itens (Screen Items)

### 3.1. Modelo Atual da Tabela `screen_items`

```sql
CREATE TABLE screen_items (
    id INTEGER PRIMARY KEY,
    screen_id INTEGER REFERENCES screens(id) ON DELETE CASCADE,
    
    -- Identificação e tipo
    item_type VARCHAR(50) NOT NULL,      -- button, switch, gauge, display
    name VARCHAR(100) NOT NULL,          -- ID único do item
    label VARCHAR(100) NOT NULL,         -- Texto exibido
    icon VARCHAR(50),                    -- Ícone do item
    position INTEGER NOT NULL,           -- Ordem na tela
    
    -- Tamanhos por dispositivo
    size_mobile VARCHAR(20) DEFAULT 'normal',
    size_display_small VARCHAR(20) DEFAULT 'normal',     -- ✅ Display P
    size_display_large VARCHAR(20) DEFAULT 'normal',     -- ✅ Display G  
    size_web VARCHAR(20) DEFAULT 'normal',
    
    -- Configuração de ação
    action_type VARCHAR(50),             -- relay_toggle, screen_navigate, etc
    action_target VARCHAR(200),          -- Alvo da ação
    action_payload TEXT,                 -- JSON com parâmetros
    
    -- Campos específicos para relés
    relay_board_id INTEGER REFERENCES relay_boards(id) ON DELETE SET NULL,
    relay_channel_id INTEGER REFERENCES relay_channels(id) ON DELETE SET NULL,
    
    -- Configuração de dados dinâmicos
    data_source VARCHAR(50),             -- relay_state, can_signal, telemetry
    data_path VARCHAR(200),              -- Caminho para os dados
    data_format VARCHAR(50),             -- Formato de exibição
    data_unit VARCHAR(20),               -- Unidade (°C, %, RPM, etc)
    
    is_active BOOLEAN DEFAULT TRUE
);
```

### 3.2. JSON Gerado para Itens

```json
{
  "id": 101,
  "item_type": "button",
  "name": "btn_light_main",
  "label": "Luz Principal",
  "icon": "lightbulb",
  "position": 1,
  "action_type": "relay_toggle",
  "action_target": null,
  "action_payload": "{\"toggle\": true}",
  "relay_board_id": 1,
  "relay_channel_id": 5,
  
  // Dados expandidos automaticamente
  "relay_board": {
    "id": 1,
    "device_id": 10,
    "device_uuid": "esp32-relay-001",
    "device_name": "Relé Central",
    "device_ip": "192.168.1.101",
    "device_type": "esp32_relay",
    "total_channels": 8,
    "board_model": "8CH_RELAY",
    "is_active": true
  },
  "relay_channel": {
    "id": 5,
    "board_id": 1,
    "channel_number": 1,
    "name": "Luz Principal",
    "description": "Iluminação principal da cabine",
    "function_type": "toggle",
    "icon": "lightbulb",
    "color": "#FFD700",
    "protection_mode": "standard",
    "max_activation_time": 0,
    "allow_in_macro": true,
    "is_active": true
  }
}
```

## 4. Campos Atuais vs Necessários

### 4.1. ✅ Campos Existentes e Completos

| Campo | Tipo | Finalidade | Status |
|-------|------|------------|--------|
| `item_type` | String | Tipo do componente | ✅ Completo |
| `name` | String | ID único | ✅ Completo |
| `label` | String | Texto exibido | ✅ Completo |
| `icon` | String | Ícone do item | ✅ Completo |
| `position` | Integer | Ordem na tela | ✅ Completo |
| `size_display_small` | String | Tamanho no Display P | ✅ Completo |
| `size_display_large` | String | Tamanho no Display G | ✅ Completo |
| `action_type` | String | Tipo de ação | ✅ Completo |
| `action_payload` | JSON | Parâmetros da ação | ✅ Completo |
| `relay_board_id` | Integer | ID da placa de relé | ✅ Completo |
| `relay_channel_id` | Integer | ID do canal | ✅ Completo |
| `data_source` | String | Fonte dos dados | ✅ Completo |
| `data_path` | String | Caminho dos dados | ✅ Completo |
| `data_unit` | String | Unidade de medida | ✅ Completo |
| `is_active` | Boolean | Item ativo/inativo | ✅ Completo |

### 4.2. 🟡 Campos Existentes Mas Incompletos

| Campo | Status Atual | Necessário Para | Ação Requerida |
|-------|-------------|-----------------|----------------|
| `data_format` | Existe mas pouco usado | Formatação de números | ✅ Usar campo existente |
| `action_target` | Usado só para navegação | Targets genéricos | ✅ Usar campo existente |

### 4.3. ❌ Campos Faltando (Novos)

**IMPORTANTE**: Análise mostrou que **todos os campos necessários já existem** na estrutura atual!

## 5. Tipos de Componentes Suportados

### 5.1. ✅ Suportados Completamente

#### Button (Botão)
```json
{
  "item_type": "button",
  "action_type": "relay_toggle|relay_on|relay_off|screen_navigate|macro_execute",
  "action_payload": "{\"toggle\": true}" // ou "{\"momentary\": true}"
}
```

#### Switch (Interruptor)  
```json
{
  "item_type": "switch",
  "action_type": "relay_toggle",
  "action_payload": "{\"toggle\": true}"
}
```

#### Display (Informativo)
```json
{
  "item_type": "display", 
  "data_source": "can_signal|telemetry|relay_state",
  "data_path": "rpm|temp|fuel_level",
  "data_format": "%.1f|%d|percentage",
  "data_unit": "RPM|°C|%"
}
```

### 5.2. 🟡 Parcialmente Suportados

#### Gauge (Medidor)
```json
{
  "item_type": "gauge",
  "data_source": "can_signal|telemetry", 
  "data_path": "engine_rpm|coolant_temp",
  "data_unit": "RPM|°C"
  // ❌ Falta: min_value, max_value, warning_threshold, critical_threshold
}
```

**Campos adicionais necessários** (podem ser adicionados ao `action_payload`):
```json
{
  "action_payload": "{
    \"min_value\": 0,
    \"max_value\": 6000,
    \"warning_threshold\": 4500,
    \"critical_threshold\": 5500,
    \"gauge_type\": \"circular|linear\"
  }"
}
```

## 6. Expansão Automática de Dados

### 6.1. Relay Boards e Channels

O backend já expande automaticamente:

```json
// Dados mínimos salvos
{
  "relay_board_id": 1,
  "relay_channel_id": 5  
}

// Dados expandidos no JSON de resposta
{
  "relay_board_id": 1,
  "relay_channel_id": 5,
  "relay_board": { /* dados completos da placa */ },
  "relay_channel": { /* dados completos do canal */ }
}
```

### 6.2. Device Registry

Inclui todos os dispositivos ativos para referência:

```json
{
  "devices": [
    {
      "id": 10,
      "uuid": "esp32-relay-001", 
      "name": "Relé Central",
      "type": "esp32_relay",
      "status": "online",
      "ip_address": "192.168.1.101",
      "is_active": true
    }
  ]
}
```

## 7. Melhorias Necessárias

### 7.1. ✅ Nenhuma Mudança Estrutural Necessária

**Conclusão**: A estrutura atual do backend é **completamente adequada** para suportar todos os componentes do Display P!

### 7.2. 🔧 Otimizações Recomendadas

#### 7.2.1. Gauge Configuration
Usar `action_payload` para configurações específicas de gauge:

```sql
-- Exemplo de uso do action_payload para gauges
UPDATE screen_items SET action_payload = '{"min_value": 0, "max_value": 6000, "warning_threshold": 4500}' 
WHERE item_type = 'gauge' AND name = 'tachometer';
```

#### 7.2.2. Color Themes
Adicionar suporte a cores customizadas via `action_payload`:

```json
{
  "action_payload": "{
    \"color_scheme\": \"blue|red|green|yellow\",
    \"custom_color\": \"#FF5722\"
  }"
}
```

#### 7.2.3. Data Refresh Rates
Configurar taxa de atualização por item:

```json
{
  "action_payload": "{
    \"refresh_rate\": 1000,
    \"data_interpolation\": true
  }"
}
```

## 8. Validações e Constraints

### 8.1. Validações Atuais no Backend

```python
# Validações existentes em main.py
def validate_screen_item(item_data):
    required_fields = ['item_type', 'name', 'label', 'position']
    
    # Validar campos obrigatórios
    for field in required_fields:
        if field not in item_data:
            raise HTTPException(400, f"Campo {field} é obrigatório")
    
    # Validar action_type para botões
    if item_data['item_type'] in ['button', 'switch']:
        if not item_data.get('action_type'):
            raise HTTPException(400, "action_type obrigatório para botões")
```

### 8.2. Validações Adicionais Recomendadas

```python
def validate_gauge_config(item_data):
    """Validar configuração específica de gauges"""
    if item_data['item_type'] == 'gauge':
        if not item_data.get('data_source'):
            raise HTTPException(400, "data_source obrigatório para gauges")
        
        # Validar action_payload se for JSON
        if item_data.get('action_payload'):
            try:
                payload = json.loads(item_data['action_payload'])
                if 'min_value' in payload and 'max_value' in payload:
                    if payload['min_value'] >= payload['max_value']:
                        raise HTTPException(400, "min_value deve ser menor que max_value")
            except json.JSONDecodeError:
                raise HTTPException(400, "action_payload deve ser JSON válido")
```

## 9. Dados Dinâmicos e Integração

### 9.1. Fontes de Dados Disponíveis

| Fonte | Descrição | Exemplos de `data_path` |
|-------|-----------|-------------------------|
| `relay_state` | Estado atual dos relés | `board_1_channel_3` |
| `can_signal` | Sinais do barramento CAN | `engine_rpm`, `coolant_temp`, `fuel_level` |
| `telemetry` | Dados de sensores | `battery_voltage`, `gps_speed` |
| `static` | Valores fixos | Usado para labels/títulos |

### 9.2. Integração MQTT

```json
// Tópicos MQTT para dados dinâmicos
{
  "telemetry": "autocore/telemetry/{device_uuid}",
  "can_signals": "autocore/can/{device_uuid}/signals", 
  "relay_states": "autocore/relays/{board_uuid}/states"
}
```

## 10. Performance e Cache

### 10.1. Otimizações Atuais

- ✅ Endpoint único reduz número de requisições
- ✅ Dados expandidos automaticamente (relay_board, relay_channel)
- ✅ Filtragem por dispositivo (show_on_display_small/large)
- ✅ Ordenação por position

### 10.2. Otimizações Recomendadas

#### 10.2.1. Cache Redis
```python
# Cache da configuração completa por device_uuid
cache_key = f"config:full:{device_uuid}"
cache_ttl = 300  # 5 minutos

if cached_config := redis.get(cache_key):
    return json.loads(cached_config)

# Gerar configuração...
redis.setex(cache_key, cache_ttl, json.dumps(config_data))
```

#### 10.2.2. Versionamento
```json
{
  "version": "2.0.0",
  "config_hash": "sha256:abc123...",  // Hash da configuração
  "last_modified": "2025-08-17T10:30:00Z"
}
```

## 11. Exemplos de Uso Completos

### 11.1. Botão de Relé Simples

```json
{
  "item_type": "button",
  "name": "btn_light_cabin", 
  "label": "Luz Cabine",
  "icon": "lightbulb",
  "position": 1,
  "size_display_small": "normal",
  "action_type": "relay_toggle",
  "relay_board_id": 1,
  "relay_channel_id": 3,
  "action_payload": "{\"toggle\": true}"
}
```

### 11.2. Gauge de RPM

```json
{
  "item_type": "gauge",
  "name": "gauge_engine_rpm",
  "label": "RPM Motor", 
  "icon": "gauge",
  "position": 2,
  "size_display_small": "large",
  "data_source": "can_signal",
  "data_path": "engine_rpm",
  "data_unit": "RPM",
  "action_payload": "{\"min_value\": 0, \"max_value\": 6000, \"warning_threshold\": 4500}"
}
```

### 11.3. Display de Temperatura

```json
{
  "item_type": "display",
  "name": "display_coolant_temp",
  "label": "Temp. Motor",
  "icon": "thermometer", 
  "position": 3,
  "size_display_small": "normal",
  "data_source": "can_signal",
  "data_path": "coolant_temperature",
  "data_format": "%.1f",
  "data_unit": "°C"
}
```

## 12. Conclusão e Próximos Passos

### 12.1. Status do Backend: ✅ COMPLETO

**Resultado da análise**: O backend atual **já suporta completamente** todos os componentes necessários para o Display P. Não são necessárias mudanças estruturais nas tabelas ou endpoints.

### 12.2. Implementação no ESP32

O foco agora deve ser na **implementação do lado ESP32**, que deve:

1. ✅ Parsear corretamente a estrutura JSON atual
2. ✅ Mapear `item_type` para widgets LVGL apropriados  
3. ✅ Implementar gauges usando `lv_meter` ou `lv_arc`
4. ✅ Suportar todos os tamanhos (`size_display_small`)
5. ✅ Conectar com sistema de dados dinâmicos via MQTT

### 12.3. Recomendações Finais

1. **Não alterar estrutura do backend** - está adequada
2. **Focar implementação LVGL** no ESP32-Display
3. **Usar `action_payload`** para configurações específicas de cada componente
4. **Implementar cache Redis** para melhor performance (opcional)
5. **Documentar mapeamentos** frontend → backend → ESP32

---

**Última atualização**: 17/08/2025