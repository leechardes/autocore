# Endpoints - Telemetria

Gerenciamento de dados de telemetria em tempo real coletados dos dispositivos conectados.

## 📋 Visão Geral

Os endpoints de telemetria permitem:
- Consultar dados históricos de dispositivos
- Obter métricas em tempo real
- Filtrar por tipos de dados específicos
- Monitorar performance e status operacional

## 📊 Endpoints de Telemetria

### `GET /api/telemetry/{device_id}`

Busca dados de telemetria de um dispositivo específico.

**Parâmetros de Path:**
- `device_id` (integer): ID do dispositivo

**Parâmetros de Query:**
- `limit` (integer, opcional): Número máximo de registros (padrão: 100, máximo: 1000)
- `data_type` (string, opcional): Filtrar por tipo de dado específico
- `since` (datetime, opcional): Dados a partir de uma data específica

**Resposta:**
```json
[
  {
    "id": 1001,
    "timestamp": "2025-01-22T10:15:30.123Z",
    "data_type": "sensor",
    "data_key": "engine_temp",
    "data_value": "89.5",
    "unit": "°C"
  },
  {
    "id": 1002,
    "timestamp": "2025-01-22T10:15:30.156Z",
    "data_type": "sensor",
    "data_key": "rpm",
    "data_value": "3250",
    "unit": "RPM"
  },
  {
    "id": 1003,
    "timestamp": "2025-01-22T10:15:30.189Z",
    "data_type": "sensor",
    "data_key": "speed",
    "data_value": "45.8",
    "unit": "km/h"
  },
  {
    "id": 1004,
    "timestamp": "2025-01-22T10:15:30.212Z",
    "data_type": "system",
    "data_key": "battery_voltage",
    "data_value": "13.8",
    "unit": "V"
  }
]
```

**Códigos de Status:**
- `200` - Dados retornados com sucesso
- `404` - Dispositivo não encontrado
- `400` - Parâmetros inválidos
- `500` - Erro interno do servidor

---

### `GET /api/telemetry/{device_id}/latest`

Busca os dados mais recentes de telemetria de um dispositivo.

**Parâmetros de Path:**
- `device_id` (integer): ID do dispositivo

**Parâmetros de Query:**
- `keys` (string, opcional): Lista de chaves separadas por vírgula (ex: "rpm,speed,temp")

**Resposta:**
```json
{
  "device_id": 1,
  "timestamp": "2025-01-22T10:15:30.123Z",
  "data": {
    "rpm": {
      "value": "3250",
      "unit": "RPM",
      "timestamp": "2025-01-22T10:15:30.156Z"
    },
    "speed": {
      "value": "45.8",
      "unit": "km/h",
      "timestamp": "2025-01-22T10:15:30.189Z"
    },
    "engine_temp": {
      "value": "89.5",
      "unit": "°C",
      "timestamp": "2025-01-22T10:15:30.123Z"
    },
    "oil_pressure": {
      "value": "4.2",
      "unit": "bar",
      "timestamp": "2025-01-22T10:15:29.987Z"
    }
  }
}
```

---

### `GET /api/telemetry/{device_id}/history/{data_key}`

Busca histórico de um sinal específico para análise de tendências.

**Parâmetros de Path:**
- `device_id` (integer): ID do dispositivo
- `data_key` (string): Chave do dado específico

**Parâmetros de Query:**
- `hours` (integer, opcional): Horas de histórico (padrão: 1, máximo: 168)
- `resolution` (string, opcional): Resolução dos dados (`raw`, `minute`, `hour`) - padrão: `raw`

**Resposta:**
```json
{
  "device_id": 1,
  "data_key": "engine_temp",
  "unit": "°C",
  "resolution": "minute",
  "period": "1 hour",
  "data_points": [
    {
      "timestamp": "2025-01-22T09:15:00.000Z",
      "value": 87.2,
      "min": 86.8,
      "max": 87.8,
      "avg": 87.2
    },
    {
      "timestamp": "2025-01-22T09:16:00.000Z",
      "value": 88.1,
      "min": 87.5,
      "max": 88.6,
      "avg": 88.1
    }
  ],
  "statistics": {
    "min": 85.3,
    "max": 91.7,
    "avg": 88.4,
    "count": 60
  }
}
```

---

### `GET /api/telemetry/{device_id}/summary`

Retorna resumo estatístico dos dados de telemetria de um dispositivo.

**Parâmetros de Path:**
- `device_id` (integer): ID do dispositivo

**Parâmetros de Query:**
- `period` (string, opcional): Período de análise (`1h`, `24h`, `7d`, `30d`) - padrão: `1h`

**Resposta:**
```json
{
  "device_id": 1,
  "period": "1h",
  "generated_at": "2025-01-22T10:15:30.123Z",
  "signals": {
    "engine_temp": {
      "unit": "°C",
      "current": 89.5,
      "min": 85.3,
      "max": 91.7,
      "avg": 88.4,
      "samples": 120,
      "trend": "stable"
    },
    "rpm": {
      "unit": "RPM",
      "current": 3250,
      "min": 800,
      "max": 6500,
      "avg": 2850,
      "samples": 120,
      "trend": "increasing"
    },
    "speed": {
      "unit": "km/h",
      "current": 45.8,
      "min": 0,
      "max": 78.5,
      "avg": 32.1,
      "samples": 120,
      "trend": "decreasing"
    }
  },
  "health_score": 95.2,
  "alerts": [
    {
      "level": "warning",
      "signal": "engine_temp",
      "message": "Temperatura próxima do limite máximo",
      "threshold": 90.0,
      "current": 89.5
    }
  ]
}
```

## 🔄 Tipos de Dados

### Sensor Data (`sensor`)
Dados coletados de sensores físicos:
- `engine_temp` - Temperatura do motor (°C)
- `oil_pressure` - Pressão do óleo (bar)
- `fuel_level` - Nível de combustível (%)
- `rpm` - Rotação do motor (RPM)
- `speed` - Velocidade (km/h)
- `throttle_position` - Posição do acelerador (%)

### System Data (`system`)
Dados do sistema e infraestrutura:
- `battery_voltage` - Voltagem da bateria (V)
- `cpu_temp` - Temperatura do processador (°C)
- `memory_usage` - Uso de memória (%)
- `wifi_signal` - Força do sinal Wi-Fi (dBm)
- `uptime` - Tempo de funcionamento (segundos)

### Performance Data (`performance`)
Métricas de performance calculadas:
- `fuel_efficiency` - Eficiência combustível (km/L)
- `engine_load` - Carga do motor (%)
- `power_output` - Potência estimada (HP)
- `acceleration` - Aceleração (m/s²)

### Environmental Data (`environmental`)
Dados ambientais:
- `ambient_temp` - Temperatura ambiente (°C)
- `humidity` - Umidade relativa (%)
- `atmospheric_pressure` - Pressão atmosférica (hPa)
- `altitude` - Altitude (m)

## 📈 Análise de Tendências

### Tipos de Tendência
- `stable` - Valores estáveis dentro da normalidade
- `increasing` - Tendência de crescimento
- `decreasing` - Tendência de decréscimo  
- `volatile` - Valores muito variáveis
- `anomalous` - Padrão anômalo detectado

### Cálculo de Health Score
```python
def calculate_health_score(signals):
    score = 100.0
    
    for signal, data in signals.items():
        # Verificar se está dentro dos limites normais
        if is_outside_normal_range(signal, data['current']):
            score -= 10.0
        
        # Penalizar tendências negativas
        if data['trend'] in ['anomalous', 'volatile']:
            score -= 5.0
        
        # Verificar variabilidade excessiva
        if data['max'] - data['min'] > get_normal_variance(signal):
            score -= 3.0
    
    return max(0.0, score)
```

## ⏱️ Resolução de Dados

### Raw Data
- Todos os pontos coletados
- Ideal para: análise detalhada, debug
- Período máximo: 6 horas

### Minute Resolution
- Agregação por minuto (min, max, avg)
- Ideal para: análise horária, gráficos
- Período máximo: 48 horas

### Hour Resolution
- Agregação por hora
- Ideal para: relatórios diários, trends
- Período máximo: 30 dias

## 🚨 Sistema de Alertas

### Níveis de Alerta
```json
{
  "info": {
    "color": "#2196F3",
    "priority": 1,
    "description": "Informação geral"
  },
  "warning": {
    "color": "#FF9800",
    "priority": 2,
    "description": "Atenção necessária"
  },
  "critical": {
    "color": "#F44336",
    "priority": 3,
    "description": "Intervenção imediata"
  }
}
```

### Thresholds Configuráveis
```json
{
  "engine_temp": {
    "warning": 85.0,
    "critical": 95.0,
    "unit": "°C"
  },
  "oil_pressure": {
    "warning": 2.0,
    "critical": 1.0,
    "unit": "bar"
  },
  "rpm": {
    "warning": 6000,
    "critical": 7000,
    "unit": "RPM"
  }
}
```

## 🔧 Integração com Dispositivos

### Configuração ESP32
```cpp
// ESP32 - Envio de telemetria via MQTT
void sendTelemetry() {
    JsonDocument doc;
    doc["timestamp"] = getCurrentTimestamp();
    doc["device_id"] = device_uuid;
    doc["data"] = {
        {"engine_temp", readEngineTemp()},
        {"rpm", readRPM()},
        {"oil_pressure", readOilPressure()}
    };
    
    String payload;
    serializeJson(doc, payload);
    mqtt.publish("autocore/telemetry", payload);
}
```

### Processamento Backend
```python
# Backend - Processamento de dados recebidos
async def process_telemetry_data(device_id, raw_data):
    for key, value in raw_data.items():
        # Validar e normalizar dados
        normalized_value = normalize_sensor_data(key, value)
        
        # Salvar no banco
        telemetry.save_data_point(
            device_id=device_id,
            data_key=key,
            data_value=normalized_value,
            timestamp=datetime.now()
        )
        
        # Verificar alertas
        check_alert_thresholds(device_id, key, normalized_value)
```

## 📊 Casos de Uso

### Dashboard em Tempo Real
```javascript
// Frontend - Atualização em tempo real
async function updateDashboard() {
    const latest = await fetch(`/api/telemetry/1/latest`).then(r => r.json());
    
    updateGauges(latest.data);
    updateAlerts(latest.alerts);
    
    setTimeout(updateDashboard, 1000); // Atualizar a cada segundo
}
```

### Análise Histórica
```python
# Análise - Detectar padrões
def analyze_driving_patterns(device_id, days=7):
    history = get_telemetry_history(device_id, days)
    
    patterns = {
        'peak_hours': find_peak_usage_hours(history),
        'avg_speed': calculate_average_speed(history),
        'fuel_efficiency': calculate_fuel_efficiency(history),
        'maintenance_alerts': check_maintenance_needs(history)
    }
    
    return patterns
```

### Relatórios Automatizados
```python
# Relatórios - Geração automática
def generate_weekly_report(device_id):
    summary = get_telemetry_summary(device_id, period='7d')
    
    report = {
        'title': f'Relatório Semanal - Dispositivo {device_id}',
        'period': '7 dias',
        'highlights': extract_highlights(summary),
        'recommendations': generate_recommendations(summary),
        'charts': generate_chart_data(summary)
    }
    
    return report
```

## ⚠️ Considerações

### Performance
- Dados mais antigos que 30 dias são arquivados
- Consultas de histórico extenso podem ser lentas
- Use paginação para grandes volumes de dados

### Armazenamento
- Dados raw: retenção de 7 dias
- Dados agregados (hora): retenção de 90 dias
- Dados agregados (dia): retenção de 2 anos

### Precisão
- Timestamps em UTC para consistência
- Valores são validados antes do armazenamento
- Outliers extremos são filtrados automaticamente

### Segurança
- Acesso por dispositivo requer autenticação
- Dados sensíveis podem ser mascarados
- Logs de acesso são mantidos para auditoria