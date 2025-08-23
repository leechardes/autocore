# 🖥️ Screen Models Documentation

Documentação dos models relacionados à interface do usuário - telas e elementos interativos do AutoCore.

## 📋 Visão Geral

Os Screen Models representam a camada de interface do AutoCore, definindo como os elements visuais são organizados e como interagem com os dispositivos hardware.

### 🏗️ Hierarquia
```
Screen (Tela principal)
    └── ScreenItem (Elementos)
        └── RelayChannel (Controle hardware)
```

## 🖥️ Screen Model

Telas da interface que organizam elementos visuais em layouts responsivos.

### 📊 Schema
```python
class Screen(Base):
    __tablename__ = 'screens'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)        # screen_home
    title = Column(String(100), nullable=False)       # "Painel Principal"
    icon = Column(String(50), nullable=True)          # "dashboard"
    screen_type = Column(String(50), nullable=True)   # dashboard/control/settings
    
    # Hierarquia
    parent_id = Column(Integer, ForeignKey('screens.id'), nullable=True)
    position = Column(Integer, default=0, nullable=False)
    
    # Layout Responsivo
    columns_mobile = Column(Integer, default=2)       # Celular
    columns_display_small = Column(Integer, default=2) # Display pequeno
    columns_display_large = Column(Integer, default=4) # Display grande
    columns_web = Column(Integer, default=4)          # Navegador
    
    # Visibilidade
    is_visible = Column(Boolean, default=True)
    required_permission = Column(String(50), nullable=True)
    
    # Visibilidade por Dispositivo
    show_on_mobile = Column(Boolean, default=True)
    show_on_display_small = Column(Boolean, default=True)
    show_on_display_large = Column(Boolean, default=True)
    show_on_web = Column(Boolean, default=True)
    show_on_controls = Column(Boolean, default=False)  # Painel de controles
    
    created_at = Column(DateTime, default=func.now())
```

### 🏷️ Screen Types
| Type | Descrição | Uso Típico |
|------|-----------|------------|
| `dashboard` | Painel de visualização | Status geral, métricas |
| `control` | Painel de controle | Botões, switches, comandos |
| `settings` | Configurações | Parâmetros, ajustes |

### 📱 Layout Responsivo
| Device | Columns | Screen Size | Orientation |
|--------|---------|-------------|-------------|
| Mobile | 2 | 360-600px | Portrait |
| Display Small | 2 | 480x320px | Landscape |
| Display Large | 4 | 800x480px | Landscape |
| Web | 4 | 1024px+ | Any |

### 🔐 Permissions
```python
# Exemplos de permissões requeridas
required_permission = 'admin'      # Apenas administradores
required_permission = 'operator'   # Operadores e acima
required_permission = None         # Acesso público
```

### 🔗 Relationships
```python
# 1:N para itens da tela
items = relationship("ScreenItem", back_populates="screen", 
                    cascade="all, delete-orphan")
```

### 📈 Índices
```python
Index('idx_screens_parent', 'parent_id')     # Navegação hierárquica
Index('idx_screens_position', 'position')    # Ordenação
```

## 🎛️ ScreenItem Model

Elementos visuais das telas com diferentes tipos e ações configuráveis.

### 📊 Schema
```python
class ScreenItem(Base):
    __tablename__ = 'screen_items'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    screen_id = Column(Integer, ForeignKey('screens.id', ondelete='CASCADE'))
    item_type = Column(String(20), nullable=False)    # BUTTON/SWITCH/DISPLAY/GAUGE
    name = Column(String(100), nullable=False)        # item_relay_01
    label = Column(String(100), nullable=False)       # "Bomba Principal"
    icon = Column(String(50), nullable=True)          # "water-pump"
    position = Column(Integer, nullable=False)        # Ordem na tela
    
    # Tamanhos por Dispositivo
    size_mobile = Column(String(20), default='normal')
    size_display_small = Column(String(20), default='normal')
    size_display_large = Column(String(20), default='normal')
    size_web = Column(String(20), default='normal')
    
    # Configuração de Ação
    action_type = Column(String(30), nullable=True)   # RELAY_CONTROL/COMMAND/MACRO/etc
    action_target = Column(String(200), nullable=True)
    action_payload = Column(Text, nullable=True)      # JSON
    
    # Campos para Relés
    relay_board_id = Column(Integer, ForeignKey('relay_boards.id', ondelete='SET NULL'))
    relay_channel_id = Column(Integer, ForeignKey('relay_channels.id', ondelete='SET NULL'))
    
    # Configuração de Dados (Display/Gauge)
    data_source = Column(String(50), nullable=True)    # 'mqtt', 'api', 'sensor'
    data_path = Column(String(200), nullable=True)     # Topic MQTT ou endpoint
    data_format = Column(String(50), nullable=True)    # 'number', 'boolean', 'string'
    data_unit = Column(String(20), nullable=True)      # '°C', '%', 'V'
    
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
```

### 🎨 Item Types

#### BUTTON - Botões de Ação
```python
item_type = 'BUTTON'
action_type = 'RELAY_CONTROL'  # Liga/desliga relé
action_type = 'COMMAND'        # Executa comando
action_type = 'MACRO'          # Executa macro
action_type = 'NAVIGATION'     # Navega para tela
```

#### SWITCH - Switches Toggle
```python
item_type = 'SWITCH'
action_type = 'RELAY_CONTROL'  # Controle direto do relé
# Mostra estado atual do relé
```

#### DISPLAY - Exibição de Dados
```python
item_type = 'DISPLAY'
action_type = None             # Sem ação (apenas exibição)
data_source = 'mqtt'           # Fonte dos dados
data_path = 'sensors/temp/01'  # Tópico ou path
data_format = 'number'         # Formato do valor
data_unit = '°C'               # Unidade
```

#### GAUGE - Medidores Visuais
```python
item_type = 'GAUGE'
action_type = None             # Sem ação
data_source = 'api'
data_path = '/api/tank/level'
data_format = 'percentage'
data_unit = '%'
```

### ⚙️ Action Types

| Action Type | Descrição | Required Fields |
|-------------|-----------|----------------|
| `RELAY_CONTROL` | Controla relé | relay_board_id, relay_channel_id |
| `COMMAND` | Executa comando | action_target (command) |
| `MACRO` | Executa macro | action_target (macro_id) |
| `NAVIGATION` | Navega para tela | action_target (screen_id) |
| `PRESET` | Aplica preset | action_payload (JSON config) |

### 📏 Size Options
| Size | Mobile | Display | Web | Uso |
|------|--------|---------|-----|-----|
| `small` | 1x1 | 1x1 | 1x1 | Indicadores |
| `normal` | 1x1 | 1x1 | 1x1 | Botões padrão |
| `large` | 2x1 | 2x1 | 2x1 | Destaque |
| `wide` | 2x1 | 2x1 | 3x1 | Informações |

### 🔗 Relationships
```python
# N:1 para screen
screen = relationship("Screen", back_populates="items")

# Não há relacionamento direto para relay (via IDs)
```

### 📊 Check Constraints

#### Item-Action Consistency
```sql
-- DISPLAY/GAUGE não podem ter action_type
(item_type IN ('DISPLAY', 'GAUGE') AND action_type IS NULL) OR 
(item_type IN ('BUTTON', 'SWITCH') AND action_type IS NOT NULL)
```

#### Relay Control Requirements
```sql
-- RELAY_CONTROL deve ter board_id e channel_id
action_type != 'RELAY_CONTROL' OR 
(action_type = 'RELAY_CONTROL' AND relay_board_id IS NOT NULL AND relay_channel_id IS NOT NULL)
```

#### Display Data Requirements
```sql
-- DISPLAY/GAUGE devem ter data_source e data_path
item_type NOT IN ('DISPLAY', 'GAUGE') OR 
(item_type IN ('DISPLAY', 'GAUGE') AND data_source IS NOT NULL AND data_path IS NOT NULL)
```

### 📈 Índices
```python
Index('idx_screen_items_screen_pos', 'screen_id', 'position')
```

## 🎯 Configuration Examples

### Dashboard Screen
```python
# Tela principal com métricas
dashboard = Screen(
    name='dashboard_main',
    title='Painel Principal',
    icon='dashboard',
    screen_type='dashboard',
    columns_mobile=2,
    columns_display_large=4,
    show_on_mobile=True,
    show_on_display_large=True
)
```

### Control Panel
```python
# Painel de controle de relés
control_panel = Screen(
    name='control_relays',
    title='Controle de Relés',
    icon='toggle-switch',
    screen_type='control',
    columns_display_large=4,
    show_on_controls=True,
    required_permission='operator'
)
```

### Screen Items Examples

#### Relay Switch
```python
relay_switch = ScreenItem(
    screen_id=control_panel.id,
    item_type='SWITCH',
    name='relay_pump_main',
    label='Bomba Principal',
    icon='water-pump',
    position=1,
    action_type='RELAY_CONTROL',
    relay_board_id=1,
    relay_channel_id=5,
    size_display_large='normal'
)
```

#### Temperature Display
```python
temp_display = ScreenItem(
    screen_id=dashboard.id,
    item_type='DISPLAY',
    name='sensor_temp_ambient',
    label='Temperatura Ambiente',
    icon='thermometer',
    position=2,
    data_source='mqtt',
    data_path='sensors/temp/ambient',
    data_format='number',
    data_unit='°C',
    size_mobile='large'
)
```

#### Emergency Button
```python
emergency_btn = ScreenItem(
    screen_id=control_panel.id,
    item_type='BUTTON',
    name='emergency_stop',
    label='PARADA DE EMERGÊNCIA',
    icon='alert-triangle',
    position=0,  # Primeiro item
    action_type='MACRO',
    action_target='emergency_shutdown_macro',
    size_display_large='wide'
)
```

#### Tank Level Gauge
```python
tank_gauge = ScreenItem(
    screen_id=dashboard.id,
    item_type='GAUGE',
    name='tank_level_main',
    label='Nível do Tanque',
    icon='gauge',
    position=3,
    data_source='api',
    data_path='/api/tank/main/level',
    data_format='percentage',
    data_unit='%',
    size_display_large='large'
)
```

## 🔄 Screen Lifecycle

### Screen Creation
```python
# Criar nova tela
new_screen = Screen(
    name='production_line_1',
    title='Linha de Produção 1',
    icon='factory',
    screen_type='control',
    columns_display_large=3,
    required_permission='operator'
)
session.add(new_screen)
session.commit()
```

### Adding Items
```python
# Adicionar itens sequencialmente
items_config = [
    {'type': 'BUTTON', 'label': 'Iniciar Linha', 'action': 'MACRO'},
    {'type': 'SWITCH', 'label': 'Conveyor 1', 'action': 'RELAY_CONTROL'},
    {'type': 'DISPLAY', 'label': 'Peças/Min', 'data_source': 'mqtt'},
    {'type': 'GAUGE', 'label': 'Eficiência', 'data_source': 'api'}
]

for i, config in enumerate(items_config):
    item = ScreenItem(
        screen_id=new_screen.id,
        position=i,
        **config
    )
    session.add(item)
```

## 🔍 Query Examples

### Screen Queries
```python
# Telas visíveis para mobile
mobile_screens = session.query(Screen).filter_by(
    show_on_mobile=True,
    is_visible=True
).order_by(Screen.position).all()

# Telas de controle
control_screens = session.query(Screen).filter_by(
    screen_type='control'
).all()

# Tela com todos os itens
screen_full = session.query(Screen).options(
    joinedload(Screen.items)
).filter_by(name='dashboard_main').first()
```

### Item Queries
```python
# Itens de uma tela ordenados
screen_items = session.query(ScreenItem).filter_by(
    screen_id=screen.id
).order_by(ScreenItem.position).all()

# Botões com ação de relé
relay_buttons = session.query(ScreenItem).filter_by(
    action_type='RELAY_CONTROL'
).all()

# Displays que mostram dados MQTT
mqtt_displays = session.query(ScreenItem).filter(
    ScreenItem.item_type.in_(['DISPLAY', 'GAUGE']),
    ScreenItem.data_source == 'mqtt'
).all()
```

## 📱 Multi-Platform Support

### Responsive Layout
```python
# Layout automático baseado no device
def get_screen_layout(screen, device_type):
    if device_type == 'mobile':
        return {
            'columns': screen.columns_mobile,
            'visible': screen.show_on_mobile
        }
    elif device_type == 'display_large':
        return {
            'columns': screen.columns_display_large,
            'visible': screen.show_on_display_large
        }
    # ... outros devices
```

### Item Sizing
```python
# Tamanho baseado no device
def get_item_size(item, device_type):
    size_map = {
        'mobile': item.size_mobile,
        'display_small': item.size_display_small,
        'display_large': item.size_display_large,
        'web': item.size_web
    }
    return size_map.get(device_type, 'normal')
```

## 🔗 Integration Points

### Hardware Integration
- ScreenItem → RelayChannel (via relay_channel_id)
- Action execution via MQTT/API calls
- Real-time status updates

### Data Sources
- **MQTT**: Sensor data, status updates
- **API**: Calculated values, external data
- **Database**: Historical data, configurations

### Frontend Frameworks
- **Flutter**: Mobile app rendering
- **LVGL**: ESP32 display rendering
- **Web**: Browser-based interface

---

**Próximos passos**:
1. [User Models](./user-models.md) - Authentication layer
2. [Relationships](./relationships.md) - Complete mapping
3. [UI Integration](../api/ui-rendering.md) - Frontend patterns