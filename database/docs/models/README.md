# 🏗️ SQLAlchemy Models Documentation

Documentação completa dos models SQLAlchemy do AutoCore - definições declarativas das tabelas e relationships.

## 📋 Visão Geral

O AutoCore utiliza SQLAlchemy com Base declarativo como fonte única de verdade para estruturas de dados. Todos os models seguem padrões consistentes de nomenclatura, validação e relacionamentos.

### 🎯 Localização
- **Source**: `/src/models/models.py`
- **Base**: `declarative_base()`
- **Engine**: SQLite (migração para PostgreSQL planejada)

## 🏷️ Convenções de Nomenclatura

### Tabelas
- **Formato**: `snake_case` (plural)
- **Exemplos**: `devices`, `relay_channels`, `screen_items`

### Campos
- **Formato**: `snake_case`
- **IDs**: `id` (Integer, PK), `{table}_id` (FK)
- **Timestamps**: `created_at`, `updated_at`
- **Status**: `is_active`, `is_visible`

### Relacionamentos
- **1:N**: `back_populates` bidirecional
- **N:N**: Através de tabelas associativas
- **Self-reference**: `remote_side=[id]`

## 📊 Models Overview

| Categoria | Models | Relacionamentos |
|-----------|--------|-----------------|
| **Hardware** | Device, RelayBoard, RelayChannel | Device → RelayBoard → RelayChannel |
| **Interface** | Screen, ScreenItem | Screen → ScreenItem → RelayChannel |
| **Usuários** | User | User → EventLog |
| **Dados** | TelemetryData, EventLog | Device → TelemetryData |
| **Recursos** | Icon, Theme, Macro | Icon → Icon (fallback) |
| **Protocolos** | CANSignal | - |

## 🔗 Core Relationships Map

```
Device (1) ──→ (N) RelayBoard (1) ──→ (N) RelayChannel
   │                                         ↑
   └─→ (N) TelemetryData                     │
                                             │
Screen (1) ──→ (N) ScreenItem ──────────────┘
                      │
User (1) ──→ (N) EventLog ──→ Device

Icon ──→ Icon (fallback)
```

## 📚 Model Categories

### 🔧 [Hardware Models](./device-models.md)
- `Device` - ESP32 devices (relay/display/sensor/gateway)
- `RelayBoard` - Placas de relé (até 16 canais)
- `RelayChannel` - Canais individuais com proteções

### 🖥️ [Interface Models](./screen-models.md)  
- `Screen` - Telas da interface (dashboard/control/settings)
- `ScreenItem` - Elementos das telas (button/switch/display/gauge)

### 👥 [User Models](./user-models.md)
- `User` - Usuários com roles e permissões
- `EventLog` - Logs de ações e eventos

### 📊 Data Models
- `TelemetryData` - Dados de sensores e telemetria
- `CANSignal` - Mapeamento de sinais CAN

### 🎨 Resource Models
- `Icon` - Sistema unificado de ícones
- `Theme` - Temas visuais customizáveis
- `Macro` - Automações e sequências

## 🔍 Valid Values (Enums Substituídos)

### Device Types
```python
# device_type valores válidos
['esp32_relay', 'esp32_display', 'sensor_board', 'gateway']
```

### Device Status
```python  
# device_status valores válidos
['online', 'offline', 'error', 'maintenance']
```

### Item Types
```python
# item_type valores válidos (UPPERCASE)
['DISPLAY', 'BUTTON', 'SWITCH', 'GAUGE']
```

### Action Types
```python
# action_type valores válidos (UPPERCASE)
['RELAY_CONTROL', 'COMMAND', 'MACRO', 'NAVIGATION', 'PRESET']
```

### Function Types
```python
# function_type valores válidos
['toggle', 'momentary', 'pulse', 'timer']
```

### Protection Modes
```python
# protection_mode valores válidos  
['none', 'interlock', 'exclusive', 'timed']
```

## 🎯 Constraints & Validations

### Check Constraints
- **item_action_consistency**: DISPLAY/GAUGE não podem ter action_type
- **relay_control_requirements**: RELAY_CONTROL deve ter board_id e channel_id
- **display_data_requirements**: DISPLAY/GAUGE devem ter data_source e data_path

### Unique Constraints
- **uq_board_channel**: (board_id, channel_number) único
- **device_uuid**: UUID único por device
- **icon_name**: Nome único por ícone

## 📈 Performance Features

### Índices Otimizados
```python
# Índices principais
Index('idx_devices_uuid', 'uuid')
Index('idx_devices_status', 'status')  
Index('idx_screen_items_screen_pos', 'screen_id', 'position')
Index('idx_telemetry_timestamp', 'timestamp', 'device_id')
```

### Cascade Behaviors
```python
# Deletion cascades
relay_boards = relationship("RelayBoard", cascade="all, delete-orphan")
items = relationship("ScreenItem", cascade="all, delete-orphan")
```

## 🔧 Session Management

### Engine Creation
```python
from src.models.models import get_engine, get_session

# Engine com configurações SQLite
engine = get_engine('autocore.db')

# Session para queries
session = get_session(engine)
```

### Basic Operations
```python
# Query examples
devices = session.query(Device).filter_by(status='online').all()
relay = session.get(RelayChannel, 1)

# Create/Update
new_device = Device(uuid='...', name='ESP32-001')
session.add(new_device)
session.commit()
```

## 📋 Quick Reference

### Model Files
- [Device Models](./device-models.md) - Hardware abstraction
- [Screen Models](./screen-models.md) - UI components  
- [Relay Models](./relay-models.md) - Relay control system
- [User Models](./user-models.md) - Authentication & authorization
- [Relationships](./relationships.md) - Complete relationship map

### Key Features
- **Declarative Base**: Single source of truth
- **Auto Timestamps**: created_at, updated_at automáticos
- **Soft Deletes**: is_active flags
- **UUID Support**: Unique device identification
- **JSON Storage**: configuration_json, capabilities_json
- **Cascade Deletes**: Referential integrity

### Migration Integration
- **Alembic Autogenerate**: Models → Migrations
- **No Manual SQL**: Sempre usar SQLAlchemy
- **Version Control**: Models versionados com migrations

---

**Próximos passos**: 
1. [Relationships Map](./relationships.md) 
2. [SQLAlchemy Patterns](../api/sqlalchemy-patterns.md)
3. [Query Optimization](../performance/query-optimization.md)