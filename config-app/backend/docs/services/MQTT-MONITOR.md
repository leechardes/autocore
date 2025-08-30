# 📡 MQTT Monitor Service

## 📋 Overview
Real-time MQTT message monitoring and processing service for AutoCore Backend.

## 🎯 Purpose
Monitors all MQTT traffic, processes device communications, and maintains system state synchronization between devices and database.

## ⚙️ Configuration

### Environment Variables
```bash
# MQTT Broker Settings
MQTT_BROKER_HOST=localhost
MQTT_BROKER_PORT=1883
MQTT_USERNAME=autocore
MQTT_PASSWORD=secure_password
MQTT_KEEPALIVE=60

# Service Settings  
MQTT_MONITOR_ENABLED=true
MQTT_MONITOR_LOG_LEVEL=INFO
MQTT_MONITOR_RECONNECT_DELAY=5
```

### Topic Subscriptions
```python
MONITORED_TOPICS = [
    "autocore/+/status",           # Device status updates
    "autocore/+/telemetry",        # Sensor data
    "autocore/+/relay/+/status",   # Relay state changes
    "autocore/+/display/interaction", # User interactions
    "autocore/+/system/+",         # System messages
]
```

## 🔄 Message Processing

### Status Updates
```json
{
    "topic": "autocore/ESP32_001/status",
    "payload": {
        "device_id": "ESP32_001",
        "status": "online",
        "ip_address": "192.168.1.100",
        "firmware_version": "1.2.0",
        "uptime": 3600,
        "timestamp": "2025-01-28T10:30:00Z"
    }
}
```

### Telemetry Data
```json
{
    "topic": "autocore/ESP32_001/telemetry",
    "payload": {
        "device_id": "ESP32_001",
        "temperature": 25.6,
        "humidity": 45.2,
        "voltage": 3.28,
        "memory_free": 45120,
        "timestamp": "2025-01-28T10:30:15Z"
    }
}
```

### Relay State Changes
```json
{
    "topic": "autocore/ESP32_001/relay/0/status", 
    "payload": {
        "device_id": "ESP32_001",
        "relay_index": 0,
        "state": true,
        "triggered_by": "manual",
        "timestamp": "2025-01-28T10:30:30Z"
    }
}
```

## 📊 Database Integration

### Device Status Updates
- Update `devices.is_online` status
- Record `devices.last_seen` timestamp
- Update `devices.ip_address` if changed
- Log connectivity changes

### Relay State Sync
- Update `relays.current_state` in real-time
- Record state change history
- Trigger automation rules if configured
- Send notifications for critical relays

### Telemetry Storage
- Store sensor data in `telemetry` table
- Implement data retention policies
- Calculate moving averages
- Detect anomalies and alerts

## 🔧 Service Architecture

### Class Structure
```python
class MQTTMonitor:
    def __init__(self, config: MQTTConfig):
        self.client = mqtt.Client()
        self.db_session = get_db_session()
        self.message_handlers = {}
        
    async def start_monitoring(self):
        """Start the MQTT monitoring service"""
        
    async def stop_monitoring(self):
        """Gracefully stop the service"""
        
    def on_message(self, client, userdata, message):
        """Handle incoming MQTT messages"""
        
    async def process_device_status(self, payload):
        """Process device status updates"""
        
    async def process_telemetry(self, payload):
        """Process telemetry data"""
        
    async def process_relay_status(self, payload):
        """Process relay state changes"""
```

## 🛠️ Error Handling

### Connection Issues
- Automatic reconnection with exponential backoff
- Connection state monitoring
- Fallback to cached data during outages
- Health check endpoint reports connection status

### Message Processing Errors
- Invalid JSON payload handling
- Unknown device registration
- Database transaction rollbacks
- Dead letter queue for failed messages

### Logging Strategy
```python
# Service lifecycle events
logger.info("MQTT Monitor service starting")
logger.info("Connected to broker at {host}:{port}")

# Message processing
logger.debug("Processing message on topic: {topic}")
logger.info("Device {device_id} status updated: {status}")

# Error conditions  
logger.warning("Failed to parse message: {error}")
logger.error("Database update failed: {error}")
```

## 📈 Monitoring and Metrics

### Health Checks
```python
@app.get("/health/mqtt-monitor")
async def mqtt_monitor_health():
    return {
        "status": "healthy" if service.is_connected else "unhealthy",
        "broker_connected": service.is_connected,
        "last_message_time": service.last_message_time,
        "messages_processed": service.message_count,
        "errors_count": service.error_count
    }
```

### Performance Metrics
- Messages per second processed
- Database write latency
- Connection uptime percentage
- Error rate and patterns
- Memory usage and message queue size

## 🚀 Deployment

### Docker Configuration
```yaml
services:
  mqtt-monitor:
    build: .
    environment:
      - MQTT_BROKER_HOST=mosquitto
      - DATABASE_URL=postgresql://...
    depends_on:
      - mosquitto
      - postgres
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health/mqtt-monitor"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Scaling Considerations
- Horizontal scaling with message partitioning
- Database connection pooling
- Memory usage optimization for high-throughput
- Load balancing for multiple monitor instances

---
*Service version: 2.1.0 | Last updated: 2025-01-28*