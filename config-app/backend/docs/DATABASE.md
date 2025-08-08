# 🗄️ AutoCore Config App - Database Documentation

<div align="center">

![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)
![Schema](https://img.shields.io/badge/Schema-Optimized-green?style=for-the-badge)

**Estrutura Completa do Banco de Dados**

[Schema Diagram](#-diagrama-do-schema) • [Tables Reference](#-tabelas-principais) • [Queries](#-queries-otimizadas) • [Performance](#-performance-e-índices)

</div>

---

## 📋 Visão Geral

O banco de dados do AutoCore foi projetado para ser completamente modular e configurável, permitindo parametrização total do sistema sem necessidade de alteração de código. Utiliza SQLite para máxima performance em hardware limitado (Raspberry Pi Zero 2W).

### Características Principais

- 🎯 **Design Modular** - Cada funcionalidade isolada em tabelas específicas
- 🔧 **Configuração Dinâmica** - Uso extensivo de campos JSON para flexibilidade
- ⚡ **Performance Otimizada** - Índices estratégicos para queries comuns
- 📊 **Escalabilidade** - Suporte a crescimento sem modificação estrutural
- 🛡️ **Integridade** - Constraints e relacionamentos bem definidos
- 📱 **Multi-dispositivo** - Configurações específicas por tipo de dispositivo

---

## 📊 Diagrama do Schema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    devices      │    │   relay_boards  │    │  relay_channels │
│                 │    │                 │    │                 │
│ • id (PK)       │◄───┤ • device_id (FK)│◄───┤ • board_id (FK) │
│ • uuid (UNIQUE) │    │ • name          │    │ • channel_number│
│ • name          │    │ • total_channels│    │ • name          │
│ • type          │    │ • location      │    │ • function_type │
│ • mac_address   │    └─────────────────┘    │ • current_state │
│ • ip_address    │                           │ • protection    │
│ • status        │                           └─────────────────┘
│ • config_json   │
└─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    screens      │    │  screen_items   │    │  quick_actions  │
│                 │    │                 │    │                 │
│ • id (PK)       │◄───┤ • screen_id (FK)│    │ • id (PK)       │
│ • name          │    │ • item_type     │    │ • name          │
│ • title         │    │ • position      │    │ • label         │
│ • screen_type   │    │ • action_type   │    │ • icon          │
│ • parent_id     │    │ • size_mobile   │    │ • action_seq    │
│ • columns_*     │    │ • size_display  │    └─────────────────┘
│ • show_on_*     │    │ • visibility    │
└─────────────────┘    └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   can_signals   │    │  can_commands   │    │  mqtt_topics    │
│                 │    │                 │    │                 │
│ • signal_name   │    │ • command_name  │    │ • topic_pattern │
│ • can_id        │    │ • can_id        │    │ • topic_type    │
│ • start_bit     │    │ • payload_templ │    │ • direction     │
│ • length_bits   │    │ • description   │    │ • qos           │
│ • scale_factor  │    │ • requires_conf │    └─────────────────┘
│ • unit          │    └─────────────────┘
└─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     users       │    │  permissions    │    │    themes      │
│                 │    │                 │    │                 │
│ • id (PK)       │    │ • role          │    │ • id (PK)       │
│ • username      │    │ • resource      │    │ • name          │
│ • password_hash │    │ • action        │    │ • primary_color │
│ • role          │    │ • is_allowed    │    │ • background    │
│ • pin_code      │    └─────────────────┘    │ • text_colors   │
└─────────────────┘                           └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   event_logs    │    │ telemetry_data  │    │     macros      │
│                 │    │                 │    │                 │
│ • id (PK)       │    │ • id (PK)       │    │ • id (PK)       │
│ • timestamp     │    │ • timestamp     │    │ • name          │
│ • event_type    │    │ • device_id (FK)│    │ • trigger_type  │
│ • source        │    │ • data_type     │    │ • action_seq    │
│ • action        │    │ • data_key      │    │ • condition     │
│ • user_id (FK)  │    │ • data_value    │    └─────────────────┘
└─────────────────┘    └─────────────────┘
```

---

## 🏗️ Tabelas Principais

### 1. Core System (Sistema Principal)

#### `devices`
Registra todos os dispositivos conectados ao sistema.

```sql
CREATE TABLE devices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL, -- app_mobile, esp32_display, esp32_relay, esp32_can, esp32_control, multimedia
    mac_address VARCHAR(17) UNIQUE,
    ip_address VARCHAR(15),
    firmware_version VARCHAR(20),
    hardware_version VARCHAR(20),
    status VARCHAR(20) DEFAULT 'offline', -- online, offline, error
    last_seen TIMESTAMP,
    configuration_json TEXT, -- Configuração específica do dispositivo
    capabilities_json TEXT,  -- Capacidades do dispositivo
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE UNIQUE INDEX idx_devices_uuid ON devices(uuid);
CREATE INDEX idx_devices_type ON devices(type);
CREATE INDEX idx_devices_status ON devices(status);
CREATE INDEX idx_devices_mac ON devices(mac_address);
```

**Exemplo de dados:**
```json
{
  "id": 1,
  "uuid": "550e8400-e29b-41d4-a716-446655440001",
  "name": "Display Principal",
  "type": "esp32_display",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "ip_address": "192.168.1.100",
  "configuration": {
    "brightness": 80,
    "sleep_timeout": 300,
    "orientation": "landscape",
    "theme_id": 1
  },
  "capabilities": {
    "touch": true,
    "wifi": true,
    "bluetooth": false,
    "resolution": "320x240"
  }
}
```

#### `relay_boards` e `relay_channels`
Gerencia placas de relés e seus canais individuais.

```sql
CREATE TABLE relay_boards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    device_id INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    total_channels INTEGER NOT NULL DEFAULT 16,
    board_model VARCHAR(50),
    location VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_relay_boards_device ON relay_boards(device_id);

CREATE TABLE relay_channels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    board_id INTEGER NOT NULL REFERENCES relay_boards(id) ON DELETE CASCADE,
    channel_number INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    function_type VARCHAR(50), -- toggle, momentary, pulse
    default_state BOOLEAN DEFAULT FALSE,
    current_state BOOLEAN DEFAULT FALSE,
    icon VARCHAR(50),
    color VARCHAR(7), -- Hex color
    protection_mode VARCHAR(20), -- none, confirm, password
    max_activation_time INTEGER, -- Segundos - para proteção
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_relay_channels_board_channel ON relay_channels(board_id, channel_number);
CREATE INDEX idx_relay_channels_active ON relay_channels(is_active);
```

### 2. UI Configuration (Interface do Usuário)

#### `screens`
Define as telas disponíveis no sistema com configuração específica por tipo de dispositivo.

```sql
CREATE TABLE screens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    title VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    screen_type VARCHAR(50), -- dashboard, control, settings, diagnostic
    parent_id INTEGER REFERENCES screens(id),
    position INTEGER NOT NULL DEFAULT 0,
    
    -- Layout Configuration per Device Type
    columns_mobile INTEGER DEFAULT 2,
    columns_display_small INTEGER DEFAULT 2,
    columns_display_large INTEGER DEFAULT 4,
    columns_web INTEGER DEFAULT 4,
    
    is_visible BOOLEAN DEFAULT TRUE,
    required_permission VARCHAR(50),
    
    -- Device Type Visibility
    show_on_mobile BOOLEAN DEFAULT TRUE,
    show_on_display_small BOOLEAN DEFAULT TRUE,
    show_on_display_large BOOLEAN DEFAULT TRUE,
    show_on_web BOOLEAN DEFAULT TRUE,
    show_on_controls BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_screens_parent ON screens(parent_id);
CREATE INDEX idx_screens_position ON screens(position);
CREATE INDEX idx_screens_type ON screens(screen_type);
```

#### `screen_items`
Elementos individuais em cada tela com configuração específica por dispositivo.

```sql
CREATE TABLE screen_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    screen_id INTEGER NOT NULL REFERENCES screens(id) ON DELETE CASCADE,
    item_type VARCHAR(50) NOT NULL, -- button, switch, gauge, display, slider, group
    name VARCHAR(100) NOT NULL,
    label VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    position INTEGER NOT NULL,
    
    -- Size Configuration per Device Type
    size_mobile VARCHAR(20) DEFAULT 'normal', -- small, normal, large, full-width
    size_display_small VARCHAR(20) DEFAULT 'normal',
    size_display_large VARCHAR(20) DEFAULT 'normal',
    size_web VARCHAR(20) DEFAULT 'normal',
    
    -- Position Override per Device Type
    position_mobile INTEGER,
    position_display_small INTEGER,
    position_display_large INTEGER,
    position_web INTEGER,
    
    -- Device Type Visibility
    show_on_mobile BOOLEAN DEFAULT TRUE,
    show_on_display_small BOOLEAN DEFAULT TRUE,
    show_on_display_large BOOLEAN DEFAULT TRUE,
    show_on_web BOOLEAN DEFAULT TRUE,
    show_on_controls BOOLEAN DEFAULT FALSE,
    
    -- Visual Configuration
    color_active VARCHAR(7),
    color_inactive VARCHAR(7),
    show_status BOOLEAN DEFAULT TRUE,
    
    -- Visual Override per Device Type
    icon_mobile VARCHAR(50),
    icon_display VARCHAR(50),
    label_short VARCHAR(50), -- Label curto para displays pequenos
    
    -- Action Configuration
    action_type VARCHAR(50), -- relay, can_command, mqtt_publish, navigate, macro
    action_target VARCHAR(200),
    action_payload TEXT, -- JSON
    
    -- Behavior Configuration
    behavior_type VARCHAR(50), -- toggle, momentary, timer, value
    confirm_action BOOLEAN DEFAULT FALSE,
    confirm_message TEXT,
    
    -- Behavior Override per Device Type
    confirm_on_mobile BOOLEAN,
    confirm_on_display BOOLEAN,
    
    -- Data Configuration (for displays)
    data_source VARCHAR(50), -- can_signal, mqtt_topic, calculation
    data_path VARCHAR(200),
    data_format VARCHAR(50), -- number, text, percentage, temperature
    data_unit VARCHAR(20),
    
    -- Display Format Override
    data_format_mobile VARCHAR(50),
    data_format_display VARCHAR(50),
    
    -- Visibility Conditions
    visibility_condition TEXT, -- JSON
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_screen_items_screen_position ON screen_items(screen_id, position);
CREATE INDEX idx_screen_items_mobile ON screen_items(show_on_mobile);
CREATE INDEX idx_screen_items_display_small ON screen_items(show_on_display_small);
CREATE INDEX idx_screen_items_action_type ON screen_items(action_type);
```

### 3. CAN Configuration (FuelTech)

#### `can_signals`
Define sinais CAN para leitura de dados.

```sql
CREATE TABLE can_signals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    signal_name VARCHAR(100) NOT NULL UNIQUE,
    can_id VARCHAR(8) NOT NULL, -- CAN ID em hex
    start_bit INTEGER NOT NULL,
    length_bits INTEGER NOT NULL,
    byte_order VARCHAR(20), -- little_endian, big_endian
    data_type VARCHAR(20), -- uint8, uint16, int16, float
    scale_factor REAL DEFAULT 1.0,
    offset REAL DEFAULT 0.0,
    unit VARCHAR(20),
    min_value REAL,
    max_value REAL,
    description TEXT,
    category VARCHAR(50), -- engine, transmission, sensors
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_can_signals_name ON can_signals(signal_name);
CREATE INDEX idx_can_signals_id ON can_signals(can_id);
CREATE INDEX idx_can_signals_category ON can_signals(category);
```

#### `can_commands`
Comandos enviáveis via CAN Bus.

```sql
CREATE TABLE can_commands (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    command_name VARCHAR(100) NOT NULL UNIQUE,
    can_id VARCHAR(8) NOT NULL,
    payload_template TEXT NOT NULL, -- Template do payload em hex
    description TEXT,
    category VARCHAR(50),
    requires_confirmation BOOLEAN DEFAULT TRUE,
    timeout_ms INTEGER DEFAULT 1000,
    retry_count INTEGER DEFAULT 3,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_can_commands_name ON can_commands(command_name);
```

### 4. Device Specific Configurations

#### `device_display_configs`
Configurações específicas por tipo de dispositivo.

```sql
CREATE TABLE device_display_configs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    device_type VARCHAR(50) NOT NULL UNIQUE, -- mobile, display_small, display_large, web, controls
    
    -- Display Capabilities
    screen_width INTEGER,
    screen_height INTEGER,
    touch_enabled BOOLEAN DEFAULT TRUE,
    color_depth INTEGER,
    
    -- UI Preferences
    default_theme_id INTEGER REFERENCES themes(id),
    default_font_size VARCHAR(20) DEFAULT 'normal', -- small, normal, large
    show_animations BOOLEAN DEFAULT TRUE,
    haptic_feedback BOOLEAN DEFAULT TRUE,
    sound_feedback BOOLEAN DEFAULT FALSE,
    
    -- Layout Defaults
    default_columns INTEGER DEFAULT 2,
    max_columns INTEGER DEFAULT 4,
    min_button_height INTEGER DEFAULT 48,
    item_spacing INTEGER DEFAULT 8,
    
    -- Feature Availability
    can_show_gauges BOOLEAN DEFAULT TRUE,
    can_show_graphs BOOLEAN DEFAULT TRUE,
    can_show_camera BOOLEAN DEFAULT FALSE,
    can_play_audio BOOLEAN DEFAULT FALSE,
    supports_multi_touch BOOLEAN DEFAULT TRUE,
    
    -- Navigation
    navigation_type VARCHAR(50), -- bottom_nav, side_menu, top_tabs, hardware_buttons
    show_back_button BOOLEAN DEFAULT TRUE,
    show_home_button BOOLEAN DEFAULT TRUE,
    
    -- Performance
    max_fps INTEGER DEFAULT 60,
    cache_size_mb INTEGER DEFAULT 50,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE UNIQUE INDEX idx_device_display_configs_type ON device_display_configs(device_type);
```

### 5. Themes & Customization

#### `themes`
Temas visuais personalizáveis.

```sql
CREATE TABLE themes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    
    -- Cores Principais
    primary_color VARCHAR(7) NOT NULL,
    secondary_color VARCHAR(7) NOT NULL,
    background_color VARCHAR(7) NOT NULL,
    surface_color VARCHAR(7) NOT NULL,
    
    -- Cores de Estado
    success_color VARCHAR(7) NOT NULL,
    warning_color VARCHAR(7) NOT NULL,
    error_color VARCHAR(7) NOT NULL,
    info_color VARCHAR(7) NOT NULL,
    
    -- Texto
    text_primary VARCHAR(7) NOT NULL,
    text_secondary VARCHAR(7) NOT NULL,
    
    -- Configurações Adicionais
    border_radius INTEGER DEFAULT 12,
    shadow_style VARCHAR(50) DEFAULT 'neumorphic',
    font_family VARCHAR(100),
    
    is_active BOOLEAN DEFAULT TRUE,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_themes_name ON themes(name);
```

### 6. User Management

#### `users`
Gerenciamento de usuários e permissões.

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    role VARCHAR(50) NOT NULL DEFAULT 'operator', -- admin, technician, operator, viewer
    pin_code VARCHAR(10), -- PIN para ações rápidas
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_username ON users(username);
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

#### `permissions`
Sistema de permissões granular.

```sql
CREATE TABLE permissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    role VARCHAR(50) NOT NULL,
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL, -- create, read, update, delete, execute
    is_allowed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_permissions_role_resource_action ON permissions(role, resource, action);
```

### 7. Logging & Monitoring

#### `event_logs`
Log completo de todas as ações do sistema.

```sql
CREATE TABLE event_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(50) NOT NULL, -- command, status_change, error, warning, info
    source VARCHAR(100) NOT NULL, -- Device UUID ou sistema
    target VARCHAR(100),
    action VARCHAR(100),
    payload TEXT, -- JSON
    user_id INTEGER REFERENCES users(id),
    ip_address VARCHAR(15),
    status VARCHAR(20), -- success, failed, pending
    error_message TEXT,
    duration_ms INTEGER
);

CREATE INDEX idx_event_logs_timestamp ON event_logs(timestamp);
CREATE INDEX idx_event_logs_type ON event_logs(event_type);
CREATE INDEX idx_event_logs_source ON event_logs(source);
CREATE INDEX idx_event_logs_user ON event_logs(user_id);
```

#### `telemetry_data`
Dados de telemetria dos dispositivos.

```sql
CREATE TABLE telemetry_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    device_id INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    data_type VARCHAR(50) NOT NULL,
    data_key VARCHAR(100) NOT NULL,
    data_value TEXT NOT NULL,
    unit VARCHAR(20)
);

CREATE INDEX idx_telemetry_timestamp_device ON telemetry_data(timestamp, device_id);
CREATE INDEX idx_telemetry_type ON telemetry_data(data_type);
CREATE INDEX idx_telemetry_key ON telemetry_data(data_key);
```

---

## 🚀 Queries Otimizadas

### Queries Frequentes

#### 1. Buscar relés ativos de uma placa
```sql
SELECT 
    rc.id,
    rc.channel_number,
    rc.name,
    rc.description,
    rc.function_type,
    rc.current_state,
    rc.icon,
    rc.color,
    rc.protection_mode
FROM relay_channels rc
JOIN relay_boards rb ON rc.board_id = rb.id
WHERE rb.device_id = ? 
    AND rc.is_active = TRUE
ORDER BY rc.channel_number;
```

#### 2. Buscar layout de tela para dispositivo específico
```sql
SELECT 
    si.id,
    si.item_type,
    si.name,
    si.label,
    COALESCE(si.icon_mobile, si.icon) as icon,
    COALESCE(si.position_mobile, si.position) as position,
    COALESCE(si.size_mobile, 'normal') as size,
    si.action_type,
    si.action_target,
    si.color_active,
    si.color_inactive,
    si.confirm_action OR si.confirm_on_mobile as requires_confirm,
    si.confirm_message
FROM screen_items si
WHERE si.screen_id = ? 
    AND si.is_active = TRUE
    AND si.show_on_mobile = TRUE
ORDER BY COALESCE(si.position_mobile, si.position);
```

#### 3. Buscar dados CAN em tempo real
```sql
SELECT 
    cs.signal_name,
    cs.unit,
    cs.scale_factor,
    cs.offset,
    cs.min_value,
    cs.max_value,
    td.data_value,
    td.timestamp
FROM can_signals cs
LEFT JOIN telemetry_data td ON td.data_key = cs.signal_name
    AND td.timestamp = (
        SELECT MAX(timestamp) 
        FROM telemetry_data td2 
        WHERE td2.data_key = cs.signal_name
    )
WHERE cs.is_active = TRUE
ORDER BY cs.signal_name;
```

#### 4. Buscar configuração completa de dispositivo
```sql
SELECT 
    d.*,
    rb.id as board_id,
    rb.name as board_name,
    rb.total_channels,
    COUNT(rc.id) as active_channels
FROM devices d
LEFT JOIN relay_boards rb ON rb.device_id = d.id AND rb.is_active = TRUE
LEFT JOIN relay_channels rc ON rc.board_id = rb.id AND rc.is_active = TRUE
WHERE d.uuid = ?
GROUP BY d.id, rb.id;
```

#### 5. Logs de eventos recentes
```sql
SELECT 
    el.*,
    u.username,
    u.full_name
FROM event_logs el
LEFT JOIN users u ON el.user_id = u.id
WHERE el.timestamp > datetime('now', '-1 day')
ORDER BY el.timestamp DESC
LIMIT 100;
```

### Views Úteis

#### 1. View de Status dos Dispositivos
```sql
CREATE VIEW device_status AS
SELECT 
    d.id,
    d.uuid,
    d.name,
    d.type,
    d.status,
    d.last_seen,
    julianday('now') - julianday(d.last_seen) as days_since_seen,
    CASE 
        WHEN d.status = 'online' AND d.last_seen > datetime('now', '-5 minutes') THEN 'healthy'
        WHEN d.status = 'online' AND d.last_seen > datetime('now', '-30 minutes') THEN 'warning'
        ELSE 'critical'
    END as health_status
FROM devices d
WHERE d.is_active = TRUE;
```

#### 2. View de Resumo de Relés
```sql
CREATE VIEW relay_summary AS
SELECT 
    rb.device_id,
    d.name as device_name,
    rb.name as board_name,
    COUNT(rc.id) as total_channels,
    SUM(CASE WHEN rc.current_state = TRUE THEN 1 ELSE 0 END) as active_channels,
    SUM(CASE WHEN rc.protection_mode != 'none' THEN 1 ELSE 0 END) as protected_channels
FROM relay_boards rb
JOIN devices d ON rb.device_id = d.id
LEFT JOIN relay_channels rc ON rc.board_id = rb.id AND rc.is_active = TRUE
WHERE rb.is_active = TRUE
GROUP BY rb.id;
```

### Triggers para Auditoria

#### 1. Trigger para updated_at automático
```sql
CREATE TRIGGER update_devices_timestamp 
AFTER UPDATE ON devices
BEGIN
    UPDATE devices SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_users_timestamp 
AFTER UPDATE ON users
BEGIN
    UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
```

#### 2. Trigger para log de mudanças em relés
```sql
CREATE TRIGGER relay_state_change_log
AFTER UPDATE OF current_state ON relay_channels
WHEN NEW.current_state != OLD.current_state
BEGIN
    INSERT INTO event_logs (
        event_type, source, target, action, payload, status
    ) VALUES (
        'status_change',
        'system',
        'relay_channel_' || NEW.id,
        'state_change',
        json_object('previous_state', OLD.current_state, 'new_state', NEW.current_state),
        'success'
    );
END;
```

---

## ⚡ Performance e Índices

### Índices Estratégicos

#### Principais Índices de Performance
```sql
-- Dispositivos
CREATE INDEX idx_devices_uuid_status ON devices(uuid, status);
CREATE INDEX idx_devices_type_active ON devices(type, is_active);

-- Relés
CREATE INDEX idx_relay_channels_board_state ON relay_channels(board_id, current_state);
CREATE INDEX idx_relay_channels_active_protection ON relay_channels(is_active, protection_mode);

-- Telas
CREATE INDEX idx_screen_items_screen_active ON screen_items(screen_id, is_active);
CREATE INDEX idx_screen_items_action_target ON screen_items(action_type, action_target);

-- Logs (com particionamento temporal)
CREATE INDEX idx_event_logs_date_type ON event_logs(date(timestamp), event_type);
CREATE INDEX idx_event_logs_source_timestamp ON event_logs(source, timestamp DESC);

-- Telemetria
CREATE INDEX idx_telemetry_device_time ON telemetry_data(device_id, timestamp DESC);
CREATE INDEX idx_telemetry_key_time ON telemetry_data(data_key, timestamp DESC);
```

### Otimizações para Raspberry Pi

#### 1. Configurações SQLite
```sql
-- Configurações de performance para Pi Zero 2W
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = 10000;
PRAGMA temp_store = MEMORY;
PRAGMA mmap_size = 268435456; -- 256MB
```

#### 2. Limpeza Automática de Dados Antigos
```sql
-- Limpar logs antigos (manter apenas 30 dias)
DELETE FROM event_logs 
WHERE timestamp < datetime('now', '-30 days');

-- Limpar telemetria antiga (manter apenas 7 dias de dados detalhados)
DELETE FROM telemetry_data 
WHERE timestamp < datetime('now', '-7 days')
    AND data_type != 'daily_summary';
```

### Estimativa de Volumetria

| Tabela | Registros Esperados | Tamanho Médio | Total Estimado |
|--------|-------------------|---------------|----------------|
| devices | 10-20 | 2KB | 40KB |
| relay_channels | 50-200 | 1KB | 200KB |
| screens | 10-20 | 1KB | 20KB |
| screen_items | 100-500 | 2KB | 1MB |
| event_logs | 1000/dia | 1KB | 30MB/mês |
| telemetry_data | 10000/dia | 500B | 150MB/mês |
| **Total Estimado** | | | **~200MB/mês** |

---

## 🔧 Scripts de Manutenção

### 1. Backup e Restore
```bash
#!/bin/bash
# backup_database.sh

DB_PATH="database/autocore.db"
BACKUP_DIR="backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Criar backup
sqlite3 $DB_PATH ".backup $BACKUP_DIR/autocore_$TIMESTAMP.db"

# Compactar
gzip "$BACKUP_DIR/autocore_$TIMESTAMP.db"

echo "Backup criado: autocore_$TIMESTAMP.db.gz"

# Limpar backups antigos (manter apenas 7 dias)
find $BACKUP_DIR -name "autocore_*.db.gz" -mtime +7 -delete
```

### 2. Otimização e Limpeza
```bash
#!/bin/bash
# optimize_database.sh

DB_PATH="database/autocore.db"

echo "Iniciando otimização do banco..."

# Limpar dados antigos
sqlite3 $DB_PATH "DELETE FROM event_logs WHERE timestamp < datetime('now', '-30 days');"
sqlite3 $DB_PATH "DELETE FROM telemetry_data WHERE timestamp < datetime('now', '-7 days');"

# Otimizar banco
sqlite3 $DB_PATH "VACUUM;"
sqlite3 $DB_PATH "ANALYZE;"

echo "Otimização concluída."
```

### 3. Verificação de Integridade
```sql
-- integrity_check.sql
PRAGMA integrity_check;
PRAGMA foreign_key_check;

-- Verificar dados órfãos
SELECT COUNT(*) as orphaned_relay_channels 
FROM relay_channels rc 
LEFT JOIN relay_boards rb ON rc.board_id = rb.id 
WHERE rb.id IS NULL;

SELECT COUNT(*) as orphaned_screen_items 
FROM screen_items si 
LEFT JOIN screens s ON si.screen_id = s.id 
WHERE s.id IS NULL;
```

---

## 📊 Monitoramento e Métricas

### Queries de Monitoramento

#### 1. Status Geral do Sistema
```sql
SELECT 
    'devices' as table_name,
    COUNT(*) as total_records,
    SUM(CASE WHEN status = 'online' THEN 1 ELSE 0 END) as online_devices,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) as active_records
FROM devices
UNION ALL
SELECT 
    'relay_channels',
    COUNT(*),
    SUM(CASE WHEN current_state = TRUE THEN 1 ELSE 0 END),
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END)
FROM relay_channels;
```

#### 2. Performance de Queries
```sql
-- Ativar logging de queries lentas
PRAGMA optimize;

-- Verificar uso de índices
EXPLAIN QUERY PLAN 
SELECT * FROM screen_items 
WHERE screen_id = 1 AND is_active = TRUE 
ORDER BY position;
```

### Dashboard SQL para Admin

```sql
-- dashboard_stats.sql
WITH stats AS (
    SELECT 
        (SELECT COUNT(*) FROM devices WHERE is_active = TRUE) as total_devices,
        (SELECT COUNT(*) FROM devices WHERE status = 'online') as online_devices,
        (SELECT COUNT(*) FROM relay_channels WHERE is_active = TRUE) as total_relays,
        (SELECT COUNT(*) FROM relay_channels WHERE current_state = TRUE) as active_relays,
        (SELECT COUNT(*) FROM screens WHERE is_visible = TRUE) as total_screens,
        (SELECT COUNT(*) FROM screen_items WHERE is_active = TRUE) as total_items,
        (SELECT COUNT(*) FROM event_logs WHERE timestamp > datetime('now', '-24 hours')) as events_24h,
        (SELECT COUNT(*) FROM telemetry_data WHERE timestamp > datetime('now', '-1 hour')) as telemetry_1h
)
SELECT 
    json_object(
        'devices', json_object(
            'total', total_devices,
            'online', online_devices,
            'percentage', ROUND(online_devices * 100.0 / total_devices, 1)
        ),
        'relays', json_object(
            'total', total_relays,
            'active', active_relays,
            'percentage', ROUND(active_relays * 100.0 / total_relays, 1)
        ),
        'interface', json_object(
            'screens', total_screens,
            'items', total_items
        ),
        'activity', json_object(
            'events_24h', events_24h,
            'telemetry_1h', telemetry_1h
        )
    ) as dashboard_data
FROM stats;
```

---

## 🛠️ Comandos Úteis

### SQLite CLI Commands
```bash
# Conectar ao banco
sqlite3 database/autocore.db

# Backup
.backup backup.db

# Importar dados
.read schema.sql

# Exportar para CSV
.headers on
.mode csv
.output devices.csv
SELECT * FROM devices;
.output stdout

# Verificar schema
.schema devices

# Tamanho do banco
.dbinfo

# Analisar performance
.eqp on
SELECT * FROM devices WHERE type = 'esp32_display';
```

### Python Scripts
```python
# database_utils.py
import sqlite3
import json
from datetime import datetime, timedelta

class DatabaseUtils:
    def __init__(self, db_path="database/autocore.db"):
        self.db_path = db_path
    
    def get_system_stats(self):
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT 
                    (SELECT COUNT(*) FROM devices WHERE is_active = TRUE) as total_devices,
                    (SELECT COUNT(*) FROM devices WHERE status = 'online') as online_devices,
                    (SELECT COUNT(*) FROM relay_channels WHERE current_state = TRUE) as active_relays
            """)
            return dict(zip(['total_devices', 'online_devices', 'active_relays'], cursor.fetchone()))
    
    def cleanup_old_data(self, days=30):
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            
            # Limpar logs antigos
            cursor.execute("""
                DELETE FROM event_logs 
                WHERE timestamp < datetime('now', '-{} days')
            """.format(days))
            
            # Limpar telemetria antiga
            cursor.execute("""
                DELETE FROM telemetry_data 
                WHERE timestamp < datetime('now', '-{} days')
            """.format(days // 4))  # Manter telemetria por menos tempo
            
            conn.commit()
            return cursor.rowcount
```

---

## 📚 Referências e Recursos

### Documentação SQLite
- [SQLite Official Documentation](https://sqlite.org/docs.html)
- [SQLite Performance Tuning](https://sqlite.org/optoverview.html)
- [SQLite on Raspberry Pi](https://www.sqlite.org/draft/raspberrypi.html)

### Tools Recomendadas
- **DB Browser for SQLite** - Interface gráfica
- **SQLite Studio** - Editor avançado
- **dbml-cli** - Gerador de schema visual
- **sqlfluff** - Linter SQL

### Scripts de Migração
```python
# migrations/001_initial_schema.py
def upgrade():
    # Criar tabelas principais
    pass

def downgrade():
    # Reverter mudanças
    pass
```

---

<div align="center">

**Database projetado com ❤️ para máxima performance e flexibilidade**

[↑ Voltar ao topo](#-autocore-config-app---database-documentation)

</div>