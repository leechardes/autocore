# 🔗 Database Relationships Map

Mapeamento completo de todos os relacionamentos entre models do AutoCore com SQLAlchemy.

## 📋 Visão Geral

O AutoCore utiliza relacionamentos SQLAlchemy bem definidos para manter integridade referencial e facilitar queries complexas. Todos os relacionamentos seguem padrões consistentes com `back_populates` e cascade adequado.

### 🎯 Tipos de Relacionamentos
- **1:N** (One-to-Many) - Relacionamento pai-filhos
- **N:1** (Many-to-One) - Relacionamento filho-pai  
- **1:1** (One-to-One) - Relacionamento exclusivo
- **Self-Reference** - Relacionamento auto-referencial

## 🗺️ Relationship Overview

```
Device (1) ──┬── (N) RelayBoard ──── (1:N) ──── RelayChannel (N)
             │                                      ↑
             └── (N) TelemetryData                  │
                                                    │ (referenced by ID)
Screen (1) ──── (N) ScreenItem ────────────────────┘
     ↑                   │
     │ (self-ref)         └── (N:1) ──── User ──── (1:N) ──── EventLog
     │
     └── Screen (parent/child)

Icon ──── (self-ref) ──── Icon (fallback)

# Standalone Models
Theme, Macro, CANSignal (no relationships)
```

## 🔧 Hardware Relationships

### Device → RelayBoard (1:N)
```python
# Device Model
class Device(Base):
    relay_boards = relationship(
        "RelayBoard", 
        back_populates="device",
        cascade="all, delete-orphan"
    )

# RelayBoard Model  
class RelayBoard(Base):
    device_id = Column(Integer, ForeignKey('devices.id', ondelete='CASCADE'))
    device = relationship("Device", back_populates="relay_boards")
```

**Características:**
- **Cascade**: `all, delete-orphan` - Remove boards quando device é deletado
- **ondelete**: `CASCADE` - FK constraint no database
- **Uso**: Um ESP32 pode ter múltiplas placas de relé

### RelayBoard → RelayChannel (1:N)
```python
# RelayBoard Model
class RelayBoard(Base):
    channels = relationship(
        "RelayChannel",
        back_populates="board",
        cascade="all, delete-orphan"
    )

# RelayChannel Model
class RelayChannel(Base):
    board_id = Column(Integer, ForeignKey('relay_boards.id', ondelete='CASCADE'))
    board = relationship("RelayBoard", back_populates="channels")
```

**Características:**
- **Cascade**: `all, delete-orphan` - Remove channels quando board é deletado
- **Constraint**: `UniqueConstraint('board_id', 'channel_number')` - Canal único por board
- **Uso**: Board de 16 canais tem 16 RelayChannels

### Device → TelemetryData (1:N)
```python
# Device Model
class Device(Base):
    telemetry_data = relationship(
        "TelemetryData",
        back_populates="device",
        cascade="all, delete-orphan"
    )

# TelemetryData Model
class TelemetryData(Base):
    device_id = Column(Integer, ForeignKey('devices.id', ondelete='CASCADE'))
    device = relationship("Device", back_populates="telemetry_data")
```

**Características:**
- **Cascade**: `all, delete-orphan` - Remove telemetry quando device é deletado
- **Volume**: Relacionamento de alta cardinalidade (muitos dados por device)
- **Uso**: Sensores, status, métricas por device

## 🖥️ Interface Relationships

### Screen → ScreenItem (1:N)
```python
# Screen Model
class Screen(Base):
    items = relationship(
        "ScreenItem",
        back_populates="screen",
        cascade="all, delete-orphan"
    )

# ScreenItem Model
class ScreenItem(Base):
    screen_id = Column(Integer, ForeignKey('screens.id', ondelete='CASCADE'))
    screen = relationship("Screen", back_populates="items")
```

**Características:**
- **Cascade**: `all, delete-orphan` - Remove items quando screen é deletada
- **Order**: Items ordenados por `position`
- **Uso**: Tela dashboard com múltiplos elementos

### Screen → Screen (Self-Reference)
```python
# Screen Model  
class Screen(Base):
    parent_id = Column(Integer, ForeignKey('screens.id'), nullable=True)
    
    # Não implementado como relationship (apenas FK)
    # Para evitar complexidade em queries
```

**Características:**
- **Tipo**: Self-reference opcional para hierarquia
- **Implementação**: Apenas FK, sem relationship object
- **Uso**: Submenus, telas aninhadas

## 🔗 Cross-Domain References

### ScreenItem ⟷ RelayChannel (Reference by ID)
```python
# ScreenItem Model - NÃO é relationship, apenas IDs
class ScreenItem(Base):
    relay_board_id = Column(Integer, ForeignKey('relay_boards.id', ondelete='SET NULL'))
    relay_channel_id = Column(Integer, ForeignKey('relay_channels.id', ondelete='SET NULL'))
    
    # SEM relationship objects - queries manual quando necessário
```

**Características:**
- **Tipo**: Reference by ID (não SQLAlchemy relationship)
- **ondelete**: `SET NULL` - Preserva ScreenItem se relé for removido
- **Validação**: Check constraint garante consistência
- **Uso**: Botão controla relé específico

### EventLog → User (N:1)
```python
# EventLog Model
class EventLog(Base):
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    user = relationship("User")

# User Model - SEM back_populates para performance
class User(Base):
    # Não declara relationship para events
    pass
```

**Características:**
- **Tipo**: Unidirecional (EventLog → User)
- **Nullable**: True - eventos de system não têm user
- **Performance**: Evita carregar milhares de logs por user
- **Uso**: Auditoria e rastreamento de ações

## 🎨 Resource Relationships

### Icon → Icon (Self-Reference)
```python
# Icon Model
class Icon(Base):
    fallback_icon_id = Column(Integer, ForeignKey('icons.id', ondelete='SET NULL'))
    fallback_icon = relationship("Icon", remote_side=[id])
```

**Características:**
- **Tipo**: Self-reference opcional para fallback
- **remote_side**: `[id]` - Define direção do relationship
- **ondelete**: `SET NULL` - Remove referência se fallback é deletado
- **Uso**: Ícone específico → ícone genérico

## 📊 Relationship Patterns

### Cascade Strategies

#### `all, delete-orphan`
```python
# Usado em relacionamentos "ownership"
Device → RelayBoard → RelayChannel
Screen → ScreenItem
```
- **Quando**: Parent "possui" completamente os children
- **Comportamento**: Remove children quando parent é deletado
- **Uso**: Estruturas hierárquicas fortes

#### `SET NULL`
```python
# Usado em referências opcionais
ScreenItem.relay_channel_id → RelayChannel.id
Icon.fallback_icon_id → Icon.id
```
- **Quando**: Referência pode existir independentemente
- **Comportamento**: Limpa referência, preserva records
- **Uso**: Cross-domain references

### Query Patterns

#### Eager Loading (joinedload)
```python
# Carregar device com todos os boards e channels
device_full = session.query(Device).options(
    joinedload(Device.relay_boards).joinedload(RelayBoard.channels)
).filter_by(uuid='device-uuid').first()

# Carregar screen com todos os items
screen_full = session.query(Screen).options(
    joinedload(Screen.items)
).filter_by(name='dashboard_main').first()
```

#### Lazy Loading (default)
```python
# Lazy loading automático quando acessado
device = session.get(Device, 1)
boards = device.relay_boards  # Query executada aqui
```

#### Subqueries para Counts
```python
# Count de channels por board sem carregar dados
board_stats = session.query(
    RelayBoard.id,
    func.count(RelayChannel.id).label('channel_count')
).outerjoin(RelayChannel).group_by(RelayBoard.id).all()
```

## 🔍 Cross-Reference Queries

### ScreenItem → Relay Resolution
```python
def get_relay_channel_for_item(screen_item: ScreenItem) -> RelayChannel:
    """Resolve relay channel para screen item"""
    if screen_item.relay_channel_id:
        return session.get(RelayChannel, screen_item.relay_channel_id)
    return None

def get_screen_items_for_relay(relay_channel_id: int) -> List[ScreenItem]:
    """Encontra screen items que controlam este relé"""
    return session.query(ScreenItem).filter_by(
        relay_channel_id=relay_channel_id
    ).all()
```

### Event Correlation
```python
def get_device_events(device: Device) -> List[EventLog]:
    """Eventos relacionados a um device"""
    return session.query(EventLog).filter(
        or_(
            EventLog.source == device.uuid,
            EventLog.target == str(device.id)
        )
    ).order_by(EventLog.timestamp.desc()).all()

def get_relay_control_events(relay_channel_id: int) -> List[EventLog]:
    """Eventos de controle de um relé específico"""
    return session.query(EventLog).filter(
        EventLog.event_type == 'relay_control',
        EventLog.target == str(relay_channel_id)
    ).order_by(EventLog.timestamp.desc()).all()
```

## 📈 Performance Considerations

### Index Strategy por Relationship
```python
# FKs sempre indexadas automaticamente
# Índices adicionais para performance

# Device relationships
Index('idx_devices_uuid', 'uuid')           # Device lookup
Index('idx_relay_boards_device', 'device_id')  # Board → Device

# Screen relationships  
Index('idx_screen_items_screen_pos', 'screen_id', 'position')  # Ordered items

# Event relationships
Index('idx_events_timestamp', 'timestamp')   # Time-based queries
Index('idx_telemetry_timestamp', 'timestamp', 'device_id')  # Device telemetry
```

### Query Optimization
```python
# N+1 Query Problem - EVITAR
screens = session.query(Screen).all()
for screen in screens:
    items = screen.items  # Query por screen = N+1

# SOLUÇÃO: Eager loading
screens = session.query(Screen).options(
    joinedload(Screen.items)
).all()
for screen in screens:
    items = screen.items  # Dados já carregados
```

## 🔧 Relationship Maintenance

### Referential Integrity
```python
# Verificar integridade após mudanças
def check_referential_integrity():
    # ScreenItems órfãos
    orphaned_items = session.query(ScreenItem).outerjoin(Screen).filter(
        Screen.id.is_(None)
    ).count()
    
    # Channels órfãos
    orphaned_channels = session.query(RelayChannel).outerjoin(RelayBoard).filter(
        RelayBoard.id.is_(None)
    ).count()
    
    return {
        'orphaned_screen_items': orphaned_items,
        'orphaned_channels': orphaned_channels
    }
```

### Cleanup Operations
```python
# Limpar dados orfãos (caso cascade falhe)
def cleanup_orphaned_data():
    # Remove screen items sem screen
    session.query(ScreenItem).filter(
        ScreenItem.screen_id.notin_(
            session.query(Screen.id)
        )
    ).delete(synchronize_session=False)
    
    # Remove telemetry antiga (>30 dias)
    old_date = datetime.now() - timedelta(days=30)
    session.query(TelemetryData).filter(
        TelemetryData.timestamp < old_date
    ).delete(synchronize_session=False)
    
    session.commit()
```

## 🎯 Best Practices

### Relationship Definition
- ✅ Sempre usar `back_populates` para clareza
- ✅ Definir cascade apropriado (`all, delete-orphan` vs `SET NULL`)
- ✅ Usar `ondelete` constraint no database
- ✅ Indexes automáticos em FKs

### Query Patterns
- ✅ Usar `joinedload` para related data conhecida
- ✅ Usar `selectinload` para collections grandes
- ✅ Evitar N+1 queries com eager loading
- ✅ Subqueries para counts e aggregations

### Cross-References
- ⚠️ IDs diretos para relacionamentos fracos
- ⚠️ Check constraints para validação
- ⚠️ Queries manuais quando necessário
- ⚠️ Cuidado com circular references

---

**Próximos passos**:
1. [Query Optimization](../performance/query-optimization.md) - Performance patterns
2. [Migration Relationships](../migrations/relationship-changes.md) - Altering relationships
3. [SQLAlchemy Patterns](../api/sqlalchemy-patterns.md) - Advanced usage