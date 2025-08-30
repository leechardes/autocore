# 🔗 Integrações - AutoCore Gateway

## 📋 Visão Geral

Esta seção documenta integrações do AutoCore Gateway com sistemas externos e componentes do ecossistema AutoCore.

## 🏗️ Arquitetura de Integração

```
┌─────────────────────────────────────────────────────┐
│                 AutoCore Ecosystem                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────┐    ┌─────────────────┐    ┌───────┐│
│  │ Config App  │◄──►│ Gateway (Hub)   │◄──►│  DB   ││
│  │ React/FastAPI│    │ MQTT/WS/HTTP   │    │SQLite ││
│  └─────────────┘    └─────────────────┘    └───────┘│
│                            │                       │
└────────────────────────────┼───────────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
    ┌───────▼──────┐  ┌──────▼─────┐  ┌──────▼─────┐
    │ ESP32 Devices│  │External    │  │Third-party │
    │ MQTT Clients │  │MQTT Broker │  │APIs/WebHooks│
    └──────────────┘  └────────────┘  └────────────┘
```

## 🔄 Tipos de Integração

### 1. **Integração Interna (AutoCore)**
- **Config App**: API REST + Database compartilhado
- **Database**: SQLAlchemy ORM compartilhado
- **ESP32 Devices**: MQTT protocolo proprietário

### 2. **Integração Externa**
- **MQTT Brokers**: Mosquitto, EMQ X, HiveMQ
- **Databases**: PostgreSQL, MySQL (futuro)
- **APIs**: REST/GraphQL de terceiros
- **Message Queues**: Redis, RabbitMQ (futuro)

### 3. **Integração de Monitoramento**
- **Prometheus**: Métricas via HTTP
- **Grafana**: Dashboards de telemetria
- **Logs**: ELK Stack, Loki (futuro)

## 🔧 Config App Integration

### Database Compartilhado
```python
# Gateway acessa repositories compartilhados
from shared.repositories import devices, telemetry, events

# Sincronização automática
device = devices.get_by_uuid("esp32-001")
telemetry.save(device_uuid, telemetry_data)
events.log("system", "gateway", "device_connected")
```

### API Communication
```python
# Gateway não faz calls HTTP diretas para Config App
# Toda comunicação via Database compartilhado
# Config App poll database para mudanças
```

### Real-time Updates
```javascript
// Config App se conecta via WebSocket
const ws = new WebSocket('ws://gateway:8080/ws');

// Gateway push eventos em tempo real
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  if (data.type === 'device_connected') {
    updateDeviceStatus(data.data.device_uuid, 'online');
  }
};
```

## 📡 MQTT Broker Integration

### Broker Support
```yaml
# Testado com:
mosquitto: "2.0+"     # Recomendado
emqx: "4.4+"         # Produção
hivemq: "4.7+"       # Enterprise
```

### Configuration
```bash
# .env
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_USERNAME=gateway  # opcional
MQTT_PASSWORD=secret   # opcional
MQTT_TLS_ENABLED=false # true para produção
```

### Advanced Features
```python
# Last Will Testament
client.will_set(
    topic="autocore/gateway/gateway-001/status",
    payload='{"status":"offline","reason":"disconnect"}',
    qos=1,
    retain=True
)

# Persistent Sessions
client.connect(broker, port, keepalive=60, clean_session=False)
```

## 🔌 External APIs

### Webhook Integration
```python
# Gateway envia eventos para APIs externas
webhook_config = {
    "url": "https://external-api.com/webhook",
    "events": ["device_connected", "alert"],
    "headers": {
        "Authorization": "Bearer api_key",
        "Content-Type": "application/json"
    }
}

# Payload enviado
{
    "event_type": "device_connected",
    "timestamp": "2025-01-27T10:30:00Z",
    "source": "autocore_gateway",
    "data": { ... }
}
```

### HTTP Polling
```python
# Para sistemas que não suportam webhooks
# Gateway expõe endpoints REST para polling
GET /api/v1/events?since=timestamp
GET /api/v1/devices/changes?since=timestamp
```

## 📊 Monitoring Integration

### Prometheus Metrics
```python
# Gateway expõe métricas via /metrics
from prometheus_client import Counter, Gauge, Histogram

devices_online = Gauge('autocore_devices_online', 'Number of online devices')
messages_processed = Counter('autocore_messages_total', 'Total messages processed')
response_time = Histogram('autocore_response_time', 'Response time in seconds')

# Auto-update
devices_online.set(len(device_manager.get_online_devices()))
```

### Grafana Dashboard
```json
// Exemplo de query
{
  "targets": [
    {
      "expr": "autocore_devices_online",
      "legendFormat": "Devices Online"
    },
    {
      "expr": "rate(autocore_messages_total[5m])",
      "legendFormat": "Messages/sec"
    }
  ]
}
```

### Log Aggregation
```python
# Structured logging para ELK/Loki
import structlog

logger = structlog.get_logger()
logger.info(
    "device_connected",
    device_uuid="esp32-001",
    device_type="display",
    ip_address="192.168.1.100"
)
```

## 🔐 Security Integration

### JWT Token Provider
```python
# Gateway valida tokens do Config App
from jwt import decode

def validate_token(token):
    try:
        payload = decode(token, SECRET_KEY, algorithms=["HS256"])
        return payload.get("user_id")
    except Exception:
        return None
```

### Certificate Management
```python
# TLS certificates para MQTT e HTTP
ssl_context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
ssl_context.load_cert_chain("/etc/ssl/certs/gateway.crt", 
                           "/etc/ssl/private/gateway.key")
```

## 💾 Data Integration

### Time Series Databases
```python
# Futuro: Integração com InfluxDB
from influxdb_client import InfluxDBClient

def save_telemetry_to_influx(device_uuid, telemetry_data):
    point = Point("telemetry") \
        .tag("device_uuid", device_uuid) \
        .field("rpm", telemetry_data["can_data"]["RPM"]["value"]) \
        .time(telemetry_data["timestamp"])
    
    client.write_api().write("autocore", point)
```

### Message Queues
```python
# Futuro: Integração com Redis/RabbitMQ
import redis

redis_client = redis.Redis(host='localhost', port=6379)

def publish_event(event_type, data):
    redis_client.publish(
        f"autocore.events.{event_type}",
        json.dumps(data)
    )
```

## 🚀 Deploy Integration

### Docker Compose
```yaml
version: '3.8'
services:
  gateway:
    image: autocore/gateway:latest
    environment:
      - MQTT_BROKER=mosquitto
      - DATABASE_PATH=/data/autocore.db
    depends_on:
      - mosquitto
      - database
    volumes:
      - gateway_data:/data
  
  mosquitto:
    image: eclipse-mosquitto:2.0
    volumes:
      - ./mosquitto.conf:/mosquitto/config/mosquitto.conf
  
  config-app:
    image: autocore/config-app:latest
    depends_on:
      - gateway
      - database
```

### Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: autocore-gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      app: autocore-gateway
  template:
    spec:
      containers:
      - name: gateway
        image: autocore/gateway:latest
        env:
        - name: MQTT_BROKER
          value: mosquitto-service
        - name: DATABASE_PATH
          value: /data/autocore.db
        volumeMounts:
        - name: data-volume
          mountPath: /data
```

## 🔧 Development Integration

### Local Development
```bash
# Docker Compose para desenvolvimento
make dev-stack      # Inicia todos serviços
make dev-gateway    # Apenas Gateway
make dev-broker     # Apenas MQTT broker
```

### Testing Integration
```python
# Testes de integração
import pytest
from testcontainers import DockerContainer

@pytest.fixture
def mqtt_broker():
    with DockerContainer("eclipse-mosquitto:2.0") as container:
        container.with_exposed_ports(1883)
        container.start()
        yield container

def test_gateway_mqtt_integration(mqtt_broker):
    broker_host = mqtt_broker.get_container_host_ip()
    broker_port = mqtt_broker.get_exposed_port(1883)
    
    # Test connection
    gateway = AutoCoreGateway()
    gateway.config.MQTT_BROKER = broker_host
    gateway.config.MQTT_PORT = int(broker_port)
    
    assert gateway.mqtt_client.connect() == True
```

## 📚 Integration Examples

Consulte os subdiretórios desta seção para exemplos específicos:
- `config-app/` - Integração com Config App
- `external-apis/` - Integrações com APIs externas
- `monitoring/` - Setup de monitoramento
- `deployment/` - Configurações de deploy

---

**Última atualização**: 2025-01-27