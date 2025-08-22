# 📚 API dos Repositories

## DeviceRepository

Gerencia dispositivos ESP32 no sistema.

### Métodos

#### `get_all() -> List[Dict]`
Retorna todos os dispositivos cadastrados.

#### `get_by_id(device_id: int) -> Optional[Dict]`
Busca dispositivo por ID.

#### `get_by_uuid(uuid: str) -> Optional[Dict]`
Busca dispositivo por UUID.

#### `get_by_type(device_type: str) -> List[Dict]`
Lista dispositivos de um tipo específico.

#### `update_status(device_id: int, status: str, ip_address: str = None)`
Atualiza status do dispositivo.

#### `create(data: Dict) -> int`
Cria novo dispositivo.

#### `update(device_id: int, data: Dict) -> bool`
Atualiza dados do dispositivo.

#### `delete(device_id: int) -> bool`
Remove dispositivo.

### Exemplo de Uso

```python
from shared.repositories import devices

# Listar todos
all_devices = devices.get_all()

# Buscar específico
device = devices.get_by_uuid('abc-123')

# Atualizar status
devices.update_status(1, 'online', '192.168.1.100')
```

## RelayRepository

Gerencia placas e canais de relé.

### Métodos

#### `get_boards() -> List[Dict]`
Lista todas as placas de relé.

#### `get_channels(board_id: int = None) -> List[Dict]`
Lista canais de relé.

#### `get_channel(channel_id: int) -> Optional[Dict]`
Busca canal específico.

#### `update_channel_state(channel_id: int, state: bool)`
Atualiza estado do canal.

#### `create_board(data: Dict) -> int`
Cria nova placa.

#### `create_channel(data: Dict) -> int`
Cria novo canal.

### Exemplo de Uso

```python
from shared.repositories import relays

# Listar placas
boards = relays.get_boards()

# Listar canais de uma placa
channels = relays.get_channels(board_id=1)

# Atualizar estado
relays.update_channel_state(5, True)
```

## TelemetryRepository

Gerencia dados de telemetria.

### Métodos

#### `save(device_id: int, data_type: str, key: str, value: Any, unit: str = None)`
Salva dados de telemetria.

#### `get_latest(device_id: int, key: str = None, limit: int = 100) -> List[Dict]`
Busca dados mais recentes.

#### `get_by_range(device_id: int, start_date: datetime, end_date: datetime) -> List[Dict]`
Busca dados por período.

#### `get_aggregated(device_id: int, key: str, interval: str = 'hour') -> List[Dict]`
Dados agregados por intervalo.

#### `cleanup_old(days: int = 7) -> int`
Remove dados antigos.

### Exemplo de Uso

```python
from shared.repositories import telemetry
from datetime import datetime, timedelta

# Salvar telemetria
telemetry.save(1, 'sensor', 'temperature', 25.5, '°C')

# Buscar últimos dados
latest = telemetry.get_latest(1, 'temperature', limit=10)

# Buscar por período
start = datetime.now() - timedelta(days=1)
end = datetime.now()
data = telemetry.get_by_range(1, start, end)
```

## EventRepository

Gerencia logs de eventos.

### Métodos

#### `log(event_type: str, source: str, action: str = None, **kwargs)`
Registra evento.

#### `get_recent(limit: int = 100) -> List[Dict]`
Busca eventos recentes.

#### `get_by_type(event_type: str, limit: int = 100) -> List[Dict]`
Busca por tipo.

#### `get_by_source(source: str, limit: int = 100) -> List[Dict]`
Busca por origem.

#### `cleanup_old(days: int = 30) -> int`
Remove eventos antigos.

### Exemplo de Uso

```python
from shared.repositories import events

# Registrar evento
events.log(
    'device_status',
    'gateway',
    'status_change',
    target='device_1',
    payload={'old': 'offline', 'new': 'online'}
)

# Buscar eventos recentes
recent = events.get_recent(50)

# Buscar por tipo
errors = events.get_by_type('error', 20)
```

## ConfigRepository

Gerencia configurações da interface.

### Métodos

#### `get_screens() -> List[Dict]`
Lista todas as telas.

#### `get_screen_items(screen_id: int) -> List[Dict]`
Itens de uma tela.

#### `get_themes() -> List[Dict]`
Lista temas disponíveis.

#### `get_default_theme() -> Optional[Dict]`
Tema padrão.

#### `get_macros() -> List[Dict]`
Lista macros.

### Exemplo de Uso

```python
from shared.repositories import config

# Buscar telas
screens = config.get_screens()

# Buscar itens de tela
items = config.get_screen_items(1)

# Buscar tema padrão
theme = config.get_default_theme()
```