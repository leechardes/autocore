# Breaking Changes v2.0 - AutoCore Database

Esta documentação detalha todas as mudanças que podem quebrar compatibilidade com versões anteriores após a refatoração para v2.0.

## Resumo das Mudanças

A versão 2.0 introduz **type safety** através de Enums SQLAlchemy, padronização de dados e validações mais rigorosas. Estas mudanças garantem maior consistência e robustez do sistema.

### Principais Alterações

1. **Tipos Enum**: Campos string convertidos para Enums tipados
2. **Check Constraints**: Validações no nível do banco de dados  
3. **Padronização de Dados**: Valores normalizados e consistentes
4. **Validações de Repository**: Métodos com validação automática

---

## 1. Models (SQLAlchemy)

### 1.1 Device Model

#### Campos Alterados

| Campo | Antes (v1.x) | Depois (v2.0) | Impacto |
|-------|--------------|---------------|---------|
| `type` | `String(50)` | `Enum(DeviceType)` | **BREAKING** |
| `status` | `String(20)` | `Enum(DeviceStatus)` | **BREAKING** |

#### Valores Aceitos

**Device.type**:
```python
# v1.x (String)
type = 'esp32_relay'
type = 'esp32_display' 
type = 'esp32_controls'
type = 'gateway'

# v2.0 (Enum)
type = DeviceType.ESP32_RELAY
type = DeviceType.ESP32_DISPLAY
type = DeviceType.ESP32_DISPLAY_SMALL
type = DeviceType.ESP32_DISPLAY_LARGE
```

**Device.status**:
```python
# v1.x (String)
status = 'online'
status = 'offline'

# v2.0 (Enum)
status = DeviceStatus.ONLINE
status = DeviceStatus.OFFLINE
status = DeviceStatus.ERROR
status = DeviceStatus.MAINTENANCE
```

#### Código que Precisa Mudar

```python
# ❌ v1.x - Não funciona mais
device = Device(type='esp32_relay', status='online')

# ✅ v2.0 - Novo formato
device = Device(type=DeviceType.ESP32_RELAY, status=DeviceStatus.ONLINE)

# ✅ v2.0 - Também aceita strings (conversão automática)
device = Device(type='esp32_relay', status='online')  # Convertido automaticamente
```

### 1.2 RelayChannel Model

#### Campos Alterados

| Campo | Antes (v1.x) | Depois (v2.0) | Impacto |
|-------|--------------|---------------|---------|
| `function_type` | `String(50)` | `Enum(FunctionType)` | **BREAKING** |
| `protection_mode` | `String(20)` nullable | `Enum(ProtectionMode)` not null | **BREAKING** |

#### Valores Aceitos

**RelayChannel.function_type**:
```python
# v1.x
function_type = 'toggle'
function_type = 'momentary' 
function_type = 'pulse'

# v2.0
function_type = FunctionType.TOGGLE
function_type = FunctionType.MOMENTARY
function_type = FunctionType.PULSE
```

**RelayChannel.protection_mode**:
```python
# v1.x (pode ser NULL)
protection_mode = 'none'
protection_mode = 'confirm'
protection_mode = 'password'
protection_mode = None  # Permitido

# v2.0 (obrigatório)
protection_mode = ProtectionMode.NONE     # Default
protection_mode = ProtectionMode.CONFIRM
protection_mode = ProtectionMode.PASSWORD
# protection_mode = None  # ❌ Não permitido mais
```

### 1.3 ScreenItem Model

#### Campos Alterados

| Campo | Antes (v1.x) | Depois (v2.0) | Impacto |
|-------|--------------|---------------|---------|
| `item_type` | `String(50)` | `Enum(ItemType)` | **BREAKING** |
| `action_type` | `String(50)` | `Enum(ActionType)` | **BREAKING** |

#### Valores Aceitos

**ScreenItem.item_type**:
```python
# v1.x
item_type = 'display'
item_type = 'button'
item_type = 'switch'
item_type = 'gauge'

# v2.0
item_type = ItemType.DISPLAY
item_type = ItemType.BUTTON
item_type = ItemType.SWITCH
item_type = ItemType.GAUGE
```

**ScreenItem.action_type**:
```python
# v1.x
action_type = 'relay'
action_type = 'relay_control'
action_type = 'relay_toggle'
action_type = 'command'

# v2.0
action_type = ActionType.RELAY_CONTROL  # Unificado
action_type = ActionType.COMMAND
action_type = ActionType.MACRO
action_type = ActionType.NAVIGATION
```

#### Check Constraints Adicionados

```sql
-- Displays e gauges não podem ter action_type
CHECK (
    (item_type IN ('DISPLAY', 'GAUGE') AND action_type IS NULL) OR 
    (item_type IN ('BUTTON', 'SWITCH') AND action_type IS NOT NULL)
)

-- relay_control deve ter relay_board_id e relay_channel_id
CHECK (
    action_type != 'RELAY_CONTROL' OR 
    (action_type = 'RELAY_CONTROL' AND relay_board_id IS NOT NULL AND relay_channel_id IS NOT NULL)
)

-- Displays e gauges devem ter data_source e data_path
CHECK (
    item_type NOT IN ('DISPLAY', 'GAUGE') OR 
    (item_type IN ('DISPLAY', 'GAUGE') AND data_source IS NOT NULL AND data_path IS NOT NULL)
)
```

---

## 2. Repository Layer

### 2.1 DeviceRepository

#### Métodos com Mudanças

**create()**:
```python
# v1.x
device_data = {'type': 'esp32_relay', 'status': 'offline'}
device = devices.create(device_data)

# v2.0 - Aceita strings ou enums
device_data = {'type': 'esp32_relay'}  # Convertido automaticamente
device = devices.create(device_data)

# v2.0 - Usando enums diretamente
device_data = {'type': DeviceType.ESP32_RELAY}
device = devices.create(device_data)
```

**update_status()**:
```python
# v1.x
devices.update_status(device_id, 'online')

# v2.0 - Aceita string ou enum
devices.update_status(device_id, 'online')  # Funciona
devices.update_status(device_id, DeviceStatus.ONLINE)  # Também funciona
```

### 2.2 ConfigRepository

#### Novos Métodos de Validação

**validate_screen_item()** (novo):
```python
# v2.0 - Validação obrigatória
item_data = {
    'item_type': 'display',
    'action_type': 'relay_control'  # ❌ Inválido para display
}

validation = config.validate_screen_item(item_data)
if not validation['valid']:
    print(validation['errors'])
    # ['display não deve ter action_type']
```

**create_screen_item()** (atualizado):
```python
# v1.x - Sem validação
item = config.create_screen_item({
    'item_type': 'display',
    'action_type': 'relay'  # Aceito sem validação
})

# v2.0 - Com validação automática
try:
    item = config.create_screen_item({
        'item_type': 'display',
        'action_type': 'relay_control'  # ❌ Lança ValueError
    })
except ValueError as e:
    print(e)  # "Dados inválidos: display não deve ter action_type"
```

---

## 3. API Changes

### 3.1 Request/Response Formats

#### Device Endpoints

**GET /api/devices**:
```json
// v1.x Response
{
  "id": 1,
  "type": "esp32_relay",
  "status": "online"
}

// v2.0 Response
{
  "id": 1,
  "type": "ESP32_RELAY",
  "status": "ONLINE"
}
```

**POST/PUT /api/devices**:
```json
// v1.x Request (ainda funciona)
{
  "type": "esp32_relay",
  "status": "offline"
}

// v2.0 Request (recomendado)
{
  "type": "ESP32_RELAY", 
  "status": "OFFLINE"
}
```

#### ScreenItem Endpoints

**POST /api/screen-items**:
```json
// v1.x - Aceito sem validação
{
  "item_type": "display",
  "action_type": "relay"
}

// v2.0 - Rejeitado com erro 400
{
  "error": "display não deve ter action_type",
  "details": ["display não deve ter action_type"]
}

// v2.0 - Formato correto para display
{
  "item_type": "DISPLAY",
  "data_source": "telemetry",
  "data_path": "speed"
}

// v2.0 - Formato correto para button
{
  "item_type": "BUTTON", 
  "action_type": "RELAY_CONTROL",
  "relay_board_id": 1,
  "relay_channel_id": 1
}
```

---

## 4. Frontend Changes

### 4.1 Form Validation

#### Device Type Selection

```javascript
// v1.x - Valores string
const deviceTypes = [
  { value: 'esp32_relay', label: 'ESP32 Relay' },
  { value: 'esp32_display', label: 'ESP32 Display' }
];

// v2.0 - Valores enum
const deviceTypes = [
  { value: 'ESP32_RELAY', label: 'ESP32 Relay' },
  { value: 'ESP32_DISPLAY', label: 'ESP32 Display' },
  { value: 'ESP32_DISPLAY_SMALL', label: 'ESP32 Display Small' },
  { value: 'ESP32_DISPLAY_LARGE', label: 'ESP32 Display Large' }
];
```

#### ScreenItem Form Validation

```javascript
// v2.0 - Validação no frontend
const validateScreenItem = (formData) => {
  const errors = [];
  
  if (['DISPLAY', 'GAUGE'].includes(formData.item_type)) {
    if (formData.action_type) {
      errors.push('Displays e gauges não devem ter action_type');
    }
    if (!formData.data_source || !formData.data_path) {
      errors.push('Displays e gauges devem ter data_source e data_path');
    }
  }
  
  if (['BUTTON', 'SWITCH'].includes(formData.item_type)) {
    if (!formData.action_type) {
      errors.push('Buttons e switches devem ter action_type');
    }
    if (formData.action_type === 'RELAY_CONTROL') {
      if (!formData.relay_board_id || !formData.relay_channel_id) {
        errors.push('relay_control deve ter relay_board_id e relay_channel_id');
      }
    }
  }
  
  return errors;
};
```

### 4.2 Estado dos Componentes

```javascript
// v1.x - Comparação string
if (device.status === 'online') {
  // ...
}

// v2.0 - Comparação enum
if (device.status === 'ONLINE') {
  // ...
}
```

---

## 5. Firmware Changes

### 5.1 MQTT Payloads

#### Device Registration

```json
// v1.x
{
  "type": "esp32_relay",
  "status": "online"
}

// v2.0 - Aceita ambos formatos
{
  "type": "esp32_relay"     // Convertido para ESP32_RELAY
}
// ou
{
  "type": "ESP32_RELAY"     // Formato preferido
}
```

#### Relay Channel Configuration

```json
// v1.x
{
  "function_type": "toggle",
  "protection_mode": null
}

// v2.0 - protection_mode obrigatório
{
  "function_type": "TOGGLE",       // ou "toggle" (convertido)
  "protection_mode": "NONE"        // Obrigatório
}
```

---

## 6. Migração de Dados

### 6.1 Migration Automática

A migration `cc3149ee98bd` converte automaticamente:

```sql
-- Devices
UPDATE devices SET status = 'OFFLINE' WHERE status = 'offline';
UPDATE devices SET status = 'ONLINE' WHERE status = 'online';

-- RelayChannels  
UPDATE relay_channels SET protection_mode = 'NONE' WHERE protection_mode IS NULL;

-- ScreenItems
UPDATE screen_items SET action_type = NULL WHERE item_type IN ('display', 'gauge');
UPDATE screen_items SET action_type = 'RELAY_CONTROL' WHERE action_type IN ('relay', 'relay_control', 'relay_toggle');
```

### 6.2 Dados que Precisam de Correção Manual

Após a migration, verifique e corrija:

```sql
-- 1. ScreenItems sem data_source/data_path
SELECT id, item_type, data_source, data_path 
FROM screen_items 
WHERE item_type IN ('DISPLAY', 'GAUGE') 
  AND (data_source IS NULL OR data_path IS NULL);

-- Corrigir:
UPDATE screen_items 
SET data_source = 'telemetry', data_path = 'default_value'
WHERE item_type IN ('DISPLAY', 'GAUGE') 
  AND (data_source IS NULL OR data_path IS NULL);

-- 2. Buttons/Switches sem relay info
SELECT id, item_type, action_type, relay_board_id, relay_channel_id
FROM screen_items 
WHERE item_type IN ('BUTTON', 'SWITCH') 
  AND action_type = 'RELAY_CONTROL'
  AND (relay_board_id IS NULL OR relay_channel_id IS NULL);

-- Corrigir:
UPDATE screen_items 
SET relay_board_id = 1, relay_channel_id = 1
WHERE item_type IN ('BUTTON', 'SWITCH') 
  AND action_type = 'RELAY_CONTROL'
  AND (relay_board_id IS NULL OR relay_channel_id IS NULL);
```

---

## 7. Testing Changes

### 7.1 Unit Tests

```python
# v1.x Tests
def test_create_device():
    device = devices.create({
        'type': 'esp32_relay',
        'status': 'offline'
    })
    assert device.type == 'esp32_relay'

# v2.0 Tests - Atualizar assertions
def test_create_device():
    device = devices.create({
        'type': 'esp32_relay'  # Ainda funciona
    })
    assert device.type == DeviceType.ESP32_RELAY  # Novo assertion
    assert device.status == DeviceStatus.OFFLINE  # Padrão
```

### 7.2 Integration Tests

```python
# v2.0 - Testar validações
def test_screen_item_validation():
    with pytest.raises(ValueError, match="display não deve ter action_type"):
        config.create_screen_item({
            'item_type': 'display',
            'action_type': 'relay_control'
        })
```

---

## 8. Rollback Plan

### 8.1 Se Precisar Voltar

```bash
# 1. Backup atual
cp autocore.db autocore_v2_backup.db

# 2. Voltar migration
python3 -m alembic downgrade -1

# 3. Verificar dados
sqlite3 autocore.db "SELECT type, status FROM devices LIMIT 5;"
```

### 8.2 Scripts de Conversão de Volta

```sql
-- Se necessário converter enums de volta para strings
UPDATE devices SET status = lower(status);
UPDATE relay_channels SET protection_mode = CASE 
    WHEN protection_mode = 'NONE' THEN NULL 
    ELSE lower(protection_mode) 
END;
```

---

## 9. Checklist de Migração

### Backend
- [ ] Atualizar imports para incluir Enums
- [ ] Substituir comparações string por Enum
- [ ] Adicionar validação nos endpoints
- [ ] Atualizar testes unitários
- [ ] Verificar serialização JSON

### Frontend
- [ ] Atualizar forms com novos valores
- [ ] Implementar validação client-side
- [ ] Atualizar comparações de estado
- [ ] Testar submissão de formulários
- [ ] Verificar exibição de dados

### Firmware
- [ ] Testar registration payload
- [ ] Verificar configuração de canais
- [ ] Validar MQTT messages
- [ ] Testar status updates

### Database
- [ ] Aplicar migrations
- [ ] Verificar dados convertidos
- [ ] Testar constraints
- [ ] Validar performance

---

## 10. Suporte

### Logs Úteis

```bash
# Verificar migration status
python3 -m alembic current

# Ver erros de constraint
tail -f logs/autocore.log | grep -i constraint

# Testar validações
python -c "
from shared.repositories import config
try:
    config.validate_screen_item({'item_type': 'display', 'action_type': 'relay'})
except Exception as e:
    print(f'Erro: {e}')
"
```

### Contato

Para dúvidas sobre migration:
1. Consultar `docs/guides/MIGRATIONS.md`
2. Verificar logs do sistema
3. Revisar esta documentação
4. Abrir issue no repositório

---

**Versão**: 2.0.0  
**Data**: 17 de Agosto, 2025  
**Autor**: Sistema AutoCore