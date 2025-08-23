# 🔧 Device Models Documentation

Documentação dos models relacionados a hardware - ESP32 devices, placas de relé e canais de controle.

## 📋 Visão Geral

Os Device Models representam a camada de abstração do hardware no AutoCore, incluindo ESP32 devices, placas de relé conectadas e canais individuais de controle.

### 🏗️ Hierarquia
```
Device (ESP32)
    └── RelayBoard (Placa 16 canais)
        └── RelayChannel (Canal individual)
```

## 🖥️ Device Model

ESP32 devices principais do sistema (relay controllers, displays, sensors, gateways).

### 📊 Schema
```python
class Device(Base):
    __tablename__ = 'devices'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    uuid = Column(String(36), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(50), nullable=False)  # device_type
    
    # Rede
    mac_address = Column(String(17), unique=True, nullable=True)
    ip_address = Column(String(15), nullable=True)
    
    # Hardware/Firmware
    firmware_version = Column(String(20), nullable=True)
    hardware_version = Column(String(20), nullable=True)
    
    # Status
    status = Column(String(20), default='offline', nullable=False)
    last_seen = Column(DateTime, nullable=True)
    
    # Configuração (JSON)
    configuration_json = Column(Text, nullable=True)
    capabilities_json = Column(Text, nullable=True)
    
    # Meta
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
```

### 🏷️ Device Types
| Type | Descrição | Capabilities |
|------|-----------|--------------|
| `esp32_relay` | Controller de relés | 1-4 placas, MQTT, WiFi |
| `esp32_display` | Display touchscreen | LVGL UI, WiFi, CAN |
| `sensor_board` | Sensores ambientais | I2C/SPI sensors, LoRa |
| `gateway` | Gateway de rede | WiFi/Ethernet bridge |

### 🔄 Device Status
| Status | Descrição | Ações Disponíveis |
|--------|-----------|-------------------|
| `online` | Device conectado | Todas as operações |
| `offline` | Device desconectado | Apenas visualização |
| `error` | Device com erro | Diagnóstico, reset |
| `maintenance` | Em manutenção | Acesso limitado |

### 📊 Configuration JSON
```json
{
    "wifi": {
        "ssid": "AutoCore_Network",
        "static_ip": "192.168.1.100"
    },
    "mqtt": {
        "broker": "192.168.1.10",
        "port": 1883,
        "topics": ["autocore/relay/+", "autocore/status"]
    },
    "hardware": {
        "relay_boards": 2,
        "display_size": "3.5inch",
        "can_enabled": true
    }
}
```

### 📊 Capabilities JSON
```json
{
    "relay_control": true,
    "display_output": true,
    "touch_input": true,
    "can_interface": true,
    "sensors": ["temperature", "humidity"],
    "max_relay_boards": 4,
    "firmware_ota": true
}
```

### 🔗 Relationships
```python
# 1:N para placas de relé
relay_boards = relationship("RelayBoard", back_populates="device", 
                           cascade="all, delete-orphan")

# 1:N para dados de telemetria
telemetry_data = relationship("TelemetryData", back_populates="device", 
                             cascade="all, delete-orphan")
```

### 📈 Índices
```python
Index('idx_devices_uuid', 'uuid')        # Busca por UUID
Index('idx_devices_type', 'type')        # Filtro por tipo
Index('idx_devices_status', 'status')    # Filtro por status
```

## 📟 RelayBoard Model

Placas de relé conectadas aos ESP32 devices (normalmente 16 canais por placa).

### 📊 Schema
```python
class RelayBoard(Base):
    __tablename__ = 'relay_boards'
    
    id = Column(Integer, primary_key=True)
    device_id = Column(Integer, ForeignKey('devices.id', ondelete='CASCADE'))
    total_channels = Column(Integer, default=16, nullable=False)
    board_model = Column(String(50), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
```

### 🔧 Board Models
| Model | Channels | Protocol | Features |
|-------|----------|----------|----------|
| `ESP32-RELAY-16` | 16 | I2C/GPIO | Opto-isolated |
| `ESP32-RELAY-8` | 8 | GPIO | Compact design |
| `ESP32-RELAY-32` | 32 | I2C Expander | High density |

### 🔗 Relationships
```python
# N:1 para device
device = relationship("Device", back_populates="relay_boards")

# 1:N para canais
channels = relationship("RelayChannel", back_populates="board", 
                       cascade="all, delete-orphan")
```

### 📈 Índices
```python
Index('idx_relay_boards_device', 'device_id')  # Busca por device
```

## ⚡ RelayChannel Model

Canais individuais de relé com controle granular e proteções.

### 📊 Schema
```python
class RelayChannel(Base):
    __tablename__ = 'relay_channels'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    board_id = Column(Integer, ForeignKey('relay_boards.id', ondelete='CASCADE'))
    channel_number = Column(Integer, nullable=False)  # 1-16
    
    # Configuração
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    function_type = Column(String(20), nullable=True)
    
    # Visual
    icon = Column(String(50), nullable=True)
    color = Column(String(7), nullable=True)  # Hex: #FF5722
    
    # Proteções
    protection_mode = Column(String(20), default='none', nullable=False)
    max_activation_time = Column(Integer, nullable=True)  # segundos
    allow_in_macro = Column(Boolean, default=True)
    
    # Meta
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
```

### ⚙️ Function Types
| Type | Comportamento | Uso Típico |
|------|---------------|------------|
| `toggle` | Liga/Desliga alternado | Luzes, equipamentos |
| `momentary` | Liga temporariamente | Botões, sinais |
| `pulse` | Pulso definido | Triggers, resets |
| `timer` | Liga por tempo específico | Irrigação, aquecimento |

### 🛡️ Protection Modes
| Mode | Descrição | Configuração |
|------|-----------|--------------|
| `none` | Sem proteção | Operação livre |
| `interlock` | Interlocking entre canais | Grupos exclusivos |
| `exclusive` | Apenas um ativo por board | max_active=1 |
| `timed` | Tempo máximo de ativação | max_activation_time |

### 🎨 Visual Configuration
```python
# Exemplos de configuração visual
{
    "name": "Bomba Principal",
    "icon": "water-pump",  # Referência Icon model
    "color": "#2196F3",    # Material Blue
    "function_type": "toggle",
    "protection_mode": "timed",
    "max_activation_time": 3600  # 1 hora máximo
}
```

### 🔒 Macro Permissions
```python
# Controle de uso em macros
allow_in_macro = Column(Boolean, default=True)

# Exemplos
Critical Equipment:  allow_in_macro=False  # Apenas controle manual
Safety Systems:     allow_in_macro=False  # Previne automação acidental
General Lighting:   allow_in_macro=True   # Automação permitida
```

### 🔗 Relationships
```python
# N:1 para board
board = relationship("RelayBoard", back_populates="channels")

# Não há relacionamento direto com ScreenItem (via IDs)
```

### 📈 Constraints & Índices
```python
# Channel único por board
UniqueConstraint('board_id', 'channel_number', name='uq_board_channel')

# Índices
Index('idx_relay_channels_board', 'board_id')
```

## 🔄 Lifecycle Management

### Device Registration
```python
# Registrar novo ESP32
new_device = Device(
    uuid=str(uuid4()),
    name="ESP32-Relay-001",
    type="esp32_relay",
    mac_address="24:6F:28:XX:XX:XX",
    configuration_json=json.dumps({
        "wifi": {"ssid": "AutoCore"},
        "mqtt": {"broker": "192.168.1.10"}
    })
)
session.add(new_device)
```

### Board Setup
```python
# Adicionar placa de relé
relay_board = RelayBoard(
    device_id=device.id,
    total_channels=16,
    board_model="ESP32-RELAY-16"
)
session.add(relay_board)

# Criar canais automaticamente
for i in range(1, 17):
    channel = RelayChannel(
        board_id=relay_board.id,
        channel_number=i,
        name=f"Relé {i}",
        function_type="toggle"
    )
    session.add(channel)
```

### Status Updates
```python
# Atualizar status de device
device.status = 'online'
device.last_seen = datetime.now()
device.ip_address = '192.168.1.100'
session.commit()
```

## 🔍 Query Examples

### Device Queries
```python
# Devices online
online_devices = session.query(Device).filter_by(status='online').all()

# Devices por tipo
relay_controllers = session.query(Device).filter_by(type='esp32_relay').all()

# Device com boards e channels
device_full = session.query(Device).options(
    joinedload(Device.relay_boards).joinedload(RelayBoard.channels)
).filter_by(uuid='device-uuid').first()
```

### Channel Queries
```python
# Canais ativos de um device
active_channels = session.query(RelayChannel).join(RelayBoard).join(Device).filter(
    Device.uuid == 'device-uuid',
    RelayChannel.is_active == True
).all()

# Canais por função
momentary_channels = session.query(RelayChannel).filter_by(
    function_type='momentary'
).all()

# Canais com proteção
protected_channels = session.query(RelayChannel).filter(
    RelayChannel.protection_mode != 'none'
).all()
```

## 📊 Monitoring & Telemetry

### Health Checks
```python
# Verificar devices offline há mais de 5 minutos
from datetime import datetime, timedelta

offline_threshold = datetime.now() - timedelta(minutes=5)
offline_devices = session.query(Device).filter(
    Device.last_seen < offline_threshold,
    Device.status == 'online'
).all()

# Marcar como offline
for device in offline_devices:
    device.status = 'offline'
```

### Channel Statistics
```python
# Estatísticas por board
channel_stats = session.query(
    RelayBoard.id,
    func.count(RelayChannel.id).label('total_channels'),
    func.sum(case([(RelayChannel.is_active == True, 1)], else_=0)).label('active_channels')
).join(RelayChannel).group_by(RelayBoard.id).all()
```

## 🔗 Integration Points

### MQTT Topics
```python
# Tópicos baseados no modelo
device_topic = f"autocore/device/{device.uuid}"
relay_topic = f"autocore/relay/{device.uuid}/{board.id}/{channel.channel_number}"
status_topic = f"autocore/status/{device.uuid}"
```

### Screen Integration
- ScreenItem.relay_board_id → RelayBoard.id
- ScreenItem.relay_channel_id → RelayChannel.id
- Action type: 'RELAY_CONTROL'

### API Endpoints
- `GET /devices` - Lista devices
- `POST /devices/{uuid}/relay/{board}/{channel}/toggle` - Controle relé
- `GET /devices/{uuid}/status` - Status device

---

**Próximos passos**:
1. [Screen Models](./screen-models.md) - Interface layer
2. [Relationships](./relationships.md) - Complete mapping
3. [Relay Control API](../api/relay-control.md) - Integration patterns