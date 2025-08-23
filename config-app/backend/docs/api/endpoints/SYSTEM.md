# Endpoints - Sistema

Endpoints fundamentais para monitoramento, health check e informações do sistema AutoCore.

## 📋 Visão Geral

Os endpoints de sistema permitem:
- Verificar saúde e disponibilidade da API
- Monitorar status geral do sistema
- Obter informações de versão e uptime
- Health checks para balanceadores de carga
- Métricas básicas de performance

## 🔍 Endpoints de Sistema

### `GET /`

Endpoint raiz que fornece informações básicas da API.

**Resposta:**
```json
{
  "message": "AutoCore Config API",
  "version": "2.0.0",
  "status": "online",
  "docs": "/docs",
  "timestamp": "2025-01-22T10:15:30.123Z",
  "environment": "production",
  "build_info": {
    "build_date": "2025-01-20T15:30:00Z",
    "git_commit": "a1b2c3d4",
    "git_branch": "main"
  }
}
```

**Códigos de Status:**
- `200` - API funcionando normalmente
- `503` - API em modo de manutenção

---

### `GET /api/health`

Health check endpoint otimizado para balanceadores de carga e monitoramento.

**Resposta:**
```json
{
  "status": "healthy",
  "service": "AutoCore Config API",
  "timestamp": "2025-01-22T10:15:30.123Z",
  "version": "2.0.0",
  "uptime": "15:30:45",
  "response_time": "2ms"
}
```

**Resposta (Unhealthy):**
```json
{
  "status": "unhealthy",
  "service": "AutoCore Config API",
  "timestamp": "2025-01-22T10:15:30.123Z",
  "errors": [
    "Database connection failed",
    "MQTT broker unreachable"
  ],
  "last_healthy": "2025-01-22T09:45:12Z"
}
```

**Códigos de Status:**
- `200` - Sistema saudável
- `503` - Sistema com problemas
- `500` - Erro interno

---

### `GET /api/status`

Status detalhado do sistema com métricas e estatísticas.

**Resposta:**
```json
{
  "status": "online",
  "version": "2.0.0",
  "database": "connected",
  "devices_online": 12,
  "timestamp": "2025-01-22T10:15:30.123Z",
  "uptime": {
    "seconds": 55845,
    "formatted": "15:30:45",
    "started_at": "2025-01-21T18:44:45Z"
  },
  "system_info": {
    "platform": "linux",
    "python_version": "3.11.5",
    "hostname": "autocore-gateway-01",
    "pid": 1234,
    "memory_usage": {
      "rss": "156MB",
      "vms": "892MB",
      "percent": 3.2
    },
    "cpu_usage": {
      "percent": 2.8,
      "cores": 4
    }
  },
  "database_info": {
    "type": "sqlite",
    "path": "/app/database/autocore.db",
    "size": "15.6MB",
    "last_backup": "2025-01-22T06:00:00Z",
    "tables": {
      "devices": 23,
      "relay_channels": 156,
      "telemetry": 45678,
      "events": 8932
    }
  },
  "mqtt_info": {
    "status": "connected",
    "broker": "10.0.10.100:1883",
    "uptime": "14:22:15",
    "messages_received": 15678,
    "messages_sent": 3421,
    "active_subscriptions": 6
  },
  "network_info": {
    "interfaces": [
      {
        "name": "eth0",
        "ip": "192.168.1.100",
        "netmask": "255.255.255.0",
        "gateway": "192.168.1.1",
        "status": "up"
      },
      {
        "name": "wlan0",
        "ip": "10.0.10.100",
        "netmask": "255.255.255.0",
        "gateway": "10.0.10.1",
        "status": "up"
      }
    ]
  },
  "services": {
    "web_server": "running",
    "mqtt_monitor": "running",
    "telemetry_processor": "running",
    "event_logger": "running",
    "backup_service": "running"
  },
  "statistics": {
    "requests_total": 45234,
    "requests_per_minute": 125.5,
    "avg_response_time": "85ms",
    "error_rate": "0.2%",
    "cache_hit_rate": "89.3%"
  }
}
```

**Códigos de Status:**
- `200` - Status obtido com sucesso
- `503` - Sistema com problemas críticos
- `500` - Erro interno do servidor

---

### `GET /api/system/info`

Informações detalhadas do sistema operacional e ambiente.

**Resposta:**
```json
{
  "system": {
    "os": "Linux",
    "os_version": "Ubuntu 22.04.3 LTS",
    "kernel": "5.15.0-91-generic",
    "architecture": "x86_64",
    "hostname": "autocore-gateway-01",
    "boot_time": "2025-01-21T12:00:00Z",
    "timezone": "America/Sao_Paulo"
  },
  "hardware": {
    "cpu": {
      "model": "ARM Cortex-A72",
      "cores": 4,
      "frequency": "1.5GHz",
      "temperature": 45.2,
      "load_average": [0.15, 0.18, 0.12]
    },
    "memory": {
      "total": "4GB",
      "available": "2.1GB", 
      "used": "1.9GB",
      "cached": "512MB",
      "swap_total": "2GB",
      "swap_used": "0MB"
    },
    "storage": [
      {
        "device": "/dev/sda1",
        "mount": "/",
        "filesystem": "ext4",
        "total": "32GB",
        "used": "8.5GB",
        "available": "22GB",
        "usage_percent": 27.2
      },
      {
        "device": "/dev/sda2",
        "mount": "/data",
        "filesystem": "ext4",
        "total": "64GB",
        "used": "12.3GB",
        "available": "48.2GB",
        "usage_percent": 20.3
      }
    ]
  },
  "network": {
    "interfaces": [
      {
        "name": "eth0",
        "mac": "b8:27:eb:12:34:56",
        "ip4": "192.168.1.100",
        "netmask4": "255.255.255.0",
        "broadcast4": "192.168.1.255",
        "gateway4": "192.168.1.1",
        "mtu": 1500,
        "speed": "100Mbps",
        "duplex": "full",
        "status": "up"
      }
    ],
    "dns_servers": ["8.8.8.8", "8.8.4.4"],
    "default_gateway": "192.168.1.1"
  },
  "processes": {
    "total": 156,
    "running": 3,
    "sleeping": 148,
    "stopped": 0,
    "zombie": 0
  }
}
```

---

### `GET /api/system/metrics`

Métricas de performance em tempo real para monitoramento.

**Parâmetros de Query:**
- `interval` (string, opcional): Intervalo de coleta (`1m`, `5m`, `15m`, `1h`) - padrão: `5m`
- `metrics` (string, opcional): Métricas específicas separadas por vírgula

**Resposta:**
```json
{
  "timestamp": "2025-01-22T10:15:30Z",
  "interval": "5m",
  "metrics": {
    "cpu": {
      "usage_percent": 12.5,
      "user_percent": 8.2,
      "system_percent": 4.3,
      "idle_percent": 87.5,
      "iowait_percent": 0.8,
      "load_1m": 0.15,
      "load_5m": 0.18,
      "load_15m": 0.12,
      "temperature": 45.2
    },
    "memory": {
      "total_bytes": 4294967296,
      "used_bytes": 2040109465,
      "free_bytes": 2254857831,
      "cached_bytes": 536870912,
      "buffers_bytes": 134217728,
      "usage_percent": 47.5,
      "swap_total_bytes": 2147483648,
      "swap_used_bytes": 0,
      "swap_percent": 0.0
    },
    "disk": {
      "read_bytes_sec": 1048576,
      "write_bytes_sec": 524288,
      "read_iops": 25,
      "write_iops": 12,
      "usage_percent": 27.2,
      "free_space_gb": 22.1
    },
    "network": {
      "bytes_sent_sec": 2048,
      "bytes_recv_sec": 8192,
      "packets_sent_sec": 15,
      "packets_recv_sec": 45,
      "errors_in": 0,
      "errors_out": 0,
      "drops_in": 0,
      "drops_out": 0
    },
    "api": {
      "requests_per_second": 2.1,
      "avg_response_time_ms": 85,
      "error_rate_percent": 0.2,
      "active_connections": 12,
      "cache_hit_rate_percent": 89.3
    },
    "mqtt": {
      "messages_per_second": 8.5,
      "bytes_per_second": 1024,
      "active_clients": 15,
      "subscription_count": 42
    },
    "database": {
      "query_time_avg_ms": 15,
      "active_connections": 5,
      "queries_per_second": 12.3,
      "cache_hit_rate_percent": 95.2
    }
  },
  "alerts": [
    {
      "level": "warning",
      "metric": "cpu.temperature",
      "current": 45.2,
      "threshold": 45.0,
      "message": "CPU temperature above warning threshold"
    }
  ],
  "historical": {
    "1h_ago": {
      "cpu_usage": 8.2,
      "memory_usage": 42.1,
      "disk_usage": 27.0
    },
    "24h_ago": {
      "cpu_usage": 11.5,
      "memory_usage": 38.7,
      "disk_usage": 26.8
    }
  }
}
```

---

### `POST /api/system/restart`

Reinicia o serviço da API (requer autenticação admin).

**Body (JSON):**
```json
{
  "reason": "Configuration update",
  "graceful": true,
  "delay_seconds": 5
}
```

**Resposta:**
```json
{
  "message": "System restart scheduled",
  "restart_time": "2025-01-22T10:16:00Z",
  "graceful": true,
  "reason": "Configuration update",
  "pid": 1234
}
```

**Códigos de Status:**
- `202` - Restart agendado com sucesso
- `401` - Não autorizado
- `403` - Permissão insuficiente
- `400` - Parâmetros inválidos

---

### `GET /api/system/logs`

Acesso aos logs do sistema (últimas entradas).

**Parâmetros de Query:**
- `level` (string, opcional): Nível de log (`DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`)
- `limit` (integer, opcional): Número máximo de linhas (padrão: 100, máximo: 1000)
- `since` (datetime, opcional): Logs a partir de uma data/hora
- `component` (string, opcional): Filtrar por componente específico

**Resposta:**
```json
{
  "logs": [
    {
      "timestamp": "2025-01-22T10:15:30.123Z",
      "level": "INFO",
      "component": "api.devices",
      "message": "Device esp32-relay-001 updated successfully",
      "metadata": {
        "device_id": 2,
        "device_uuid": "esp32-relay-001",
        "changes": ["ip_address"]
      }
    },
    {
      "timestamp": "2025-01-22T10:15:25.456Z",
      "level": "WARNING",
      "component": "mqtt.monitor",
      "message": "MQTT connection unstable - reconnecting",
      "metadata": {
        "broker": "10.0.10.100:1883",
        "retry_count": 2
      }
    },
    {
      "timestamp": "2025-01-22T10:15:20.789Z",
      "level": "ERROR",
      "component": "telemetry.processor",
      "message": "Failed to decode CAN signal",
      "metadata": {
        "can_id": "0x5F0",
        "signal_name": "rpm",
        "error": "Invalid data format"
      }
    }
  ],
  "total_count": 8932,
  "filtered_count": 3,
  "log_levels": {
    "DEBUG": 1245,
    "INFO": 6523,
    "WARNING": 987,
    "ERROR": 156,
    "CRITICAL": 21
  },
  "components": [
    "api.devices",
    "api.relays", 
    "mqtt.monitor",
    "telemetry.processor",
    "event.logger"
  ]
}
```

## 📊 Casos de Uso

### Health Check para Load Balancer
```yaml
# Docker Compose health check
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8081/api/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Monitoramento com Prometheus
```python
# Exportar métricas para Prometheus
from prometheus_client import Counter, Histogram, Gauge, generate_latest

# Métricas customizadas
request_counter = Counter('api_requests_total', 'Total API requests', ['method', 'endpoint'])
response_time = Histogram('api_response_time_seconds', 'Response time')
active_devices = Gauge('active_devices', 'Number of active devices')

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start_time = time.time()
    
    response = await call_next(request)
    
    # Registrar métricas
    request_counter.labels(method=request.method, endpoint=request.url.path).inc()
    response_time.observe(time.time() - start_time)
    
    return response

@app.get("/metrics")
async def metrics():
    # Atualizar gauges
    devices = devices_repo.get_all(active_only=True)
    active_devices.set(len(devices))
    
    return Response(generate_latest(), media_type="text/plain")
```

### Dashboard de Sistema
```javascript
// Frontend - Dashboard de métricas
class SystemDashboard {
    constructor() {
        this.updateInterval = 30000; // 30s
        this.startUpdates();
    }

    async updateMetrics() {
        try {
            const [status, metrics] = await Promise.all([
                fetch('/api/status').then(r => r.json()),
                fetch('/api/system/metrics').then(r => r.json())
            ]);

            this.updateSystemStatus(status);
            this.updatePerformanceCharts(metrics);
            this.updateAlerts(metrics.alerts);
            
        } catch (error) {
            console.error('Failed to update metrics:', error);
            this.showConnectionError();
        }
    }

    updateSystemStatus(status) {
        document.getElementById('system-status').textContent = status.status;
        document.getElementById('uptime').textContent = status.uptime.formatted;
        document.getElementById('devices-count').textContent = status.devices_online;
        
        // Status indicators
        const indicators = {
            database: status.database === 'connected',
            mqtt: status.mqtt_info.status === 'connected',
            services: Object.values(status.services).every(s => s === 'running')
        };
        
        Object.entries(indicators).forEach(([service, healthy]) => {
            const element = document.getElementById(`${service}-status`);
            element.className = `status-indicator ${healthy ? 'healthy' : 'unhealthy'}`;
        });
    }

    startUpdates() {
        this.updateMetrics();
        setInterval(() => this.updateMetrics(), this.updateInterval);
    }
}

// Inicializar dashboard
const dashboard = new SystemDashboard();
```

### Alertas Automáticos
```python
# Sistema de alertas baseado em métricas
class SystemAlerts:
    def __init__(self):
        self.thresholds = {
            'cpu_usage': 80.0,
            'memory_usage': 85.0,
            'disk_usage': 90.0,
            'error_rate': 5.0,
            'response_time': 1000.0  # ms
        }
        
    def check_metrics(self, metrics):
        alerts = []
        
        # CPU usage
        if metrics['cpu']['usage_percent'] > self.thresholds['cpu_usage']:
            alerts.append({
                'level': 'warning',
                'metric': 'cpu_usage',
                'current': metrics['cpu']['usage_percent'],
                'threshold': self.thresholds['cpu_usage'],
                'message': f"High CPU usage: {metrics['cpu']['usage_percent']:.1f}%"
            })
        
        # Memory usage
        if metrics['memory']['usage_percent'] > self.thresholds['memory_usage']:
            alerts.append({
                'level': 'critical',
                'metric': 'memory_usage', 
                'current': metrics['memory']['usage_percent'],
                'threshold': self.thresholds['memory_usage'],
                'message': f"High memory usage: {metrics['memory']['usage_percent']:.1f}%"
            })
        
        # Response time
        if metrics['api']['avg_response_time_ms'] > self.thresholds['response_time']:
            alerts.append({
                'level': 'warning',
                'metric': 'response_time',
                'current': metrics['api']['avg_response_time_ms'],
                'threshold': self.thresholds['response_time'],
                'message': f"Slow API response: {metrics['api']['avg_response_time_ms']:.0f}ms"
            })
        
        return alerts

    def send_notifications(self, alerts):
        for alert in alerts:
            if alert['level'] == 'critical':
                self.send_critical_alert(alert)
            elif alert['level'] == 'warning':
                self.send_warning_alert(alert)
```

## ⚠️ Considerações

### Segurança
- Endpoints de sistema sensíveis devem ser protegidos por autenticação
- Limitar acesso aos logs apenas para administradores
- Mascarar informações sensíveis em métricas públicas
- Rate limiting para prevenir abuso

### Performance
- Cache de métricas para reduzir overhead
- Coleta assíncrona de dados do sistema
- Limitação de histórico de logs em memória
- Otimização de queries de status

### Monitoramento
- Integração com ferramentas de monitoramento externas
- Alertas automáticos para condições críticas
- Logs estruturados para facilitar análise
- Métricas exportadas em formatos padrão (Prometheus)

### Manutenibilidade
- Logs rotativos para economizar espaço
- Cleanup automático de dados antigos
- Backup regular de configurações do sistema
- Documentação de troubleshooting