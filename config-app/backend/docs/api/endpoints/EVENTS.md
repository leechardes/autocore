# Endpoints - Eventos

Sistema de auditoria e monitoramento de eventos do AutoCore para rastreabilidade completa.

## 📋 Visão Geral

Os endpoints de eventos permitem:
- Consultar logs de atividades do sistema
- Monitorar ações de usuários e dispositivos
- Rastrear mudanças de configuração
- Identificar problemas e falhas
- Gerar relatórios de auditoria

## 📝 Endpoints de Eventos

### `GET /api/events`

Lista eventos recentes do sistema com filtros opcionais.

**Parâmetros de Query:**
- `limit` (integer, opcional): Número máximo de eventos (padrão: 100, máximo: 1000)
- `event_type` (string, opcional): Filtrar por tipo de evento
- `source` (string, opcional): Filtrar por origem do evento
- `action` (string, opcional): Filtrar por ação específica
- `status` (string, opcional): Filtrar por status (`success`, `error`, `pending`)
- `since` (datetime, opcional): Eventos a partir de uma data específica
- `until` (datetime, opcional): Eventos até uma data específica

**Resposta:**
```json
[
  {
    "id": 1001,
    "timestamp": "2025-01-22T10:15:30.123Z",
    "event_type": "device",
    "source": "config-app",
    "target": "device_2",
    "action": "create",
    "status": "success",
    "error_message": null,
    "payload": {
      "device_uuid": "esp32-relay-001",
      "device_name": "Relé Garagem"
    }
  },
  {
    "id": 1002,
    "timestamp": "2025-01-22T10:16:45.456Z",
    "event_type": "relay",
    "source": "esp32-relay-001",
    "target": "channel_5",
    "action": "toggle",
    "status": "success",
    "error_message": null,
    "payload": {
      "channel_name": "Luz Externa",
      "previous_state": "off",
      "new_state": "on"
    }
  },
  {
    "id": 1003,
    "timestamp": "2025-01-22T10:17:12.789Z",
    "event_type": "config",
    "source": "web-interface",
    "target": "screen_1",
    "action": "update",
    "status": "success",
    "error_message": null,
    "payload": {
      "screen_name": "Dashboard Principal",
      "changes": ["title", "position"]
    }
  },
  {
    "id": 1004,
    "timestamp": "2025-01-22T10:18:33.012Z",
    "event_type": "system",
    "source": "mqtt-monitor",
    "target": "connection",
    "action": "disconnect",
    "status": "error",
    "error_message": "Connection timeout after 30 seconds",
    "payload": {
      "broker": "192.168.1.100",
      "client_id": "config-app-monitor"
    }
  }
]
```

**Códigos de Status:**
- `200` - Eventos retornados com sucesso
- `400` - Parâmetros de consulta inválidos
- `500` - Erro interno do servidor

---

### `GET /api/events/{event_id}`

Busca um evento específico por ID com detalhes completos.

**Parâmetros de Path:**
- `event_id` (integer): ID do evento

**Resposta:**
```json
{
  "id": 1001,
  "timestamp": "2025-01-22T10:15:30.123Z",
  "event_type": "relay",
  "source": "esp32-relay-001",
  "target": "channel_5",
  "action": "toggle",
  "status": "success",
  "error_message": null,
  "user_id": null,
  "session_id": "sess_abc123def456",
  "ip_address": "192.168.1.105",
  "user_agent": "AutoCore-ESP32/2.0.0",
  "payload": {
    "channel_name": "Luz Externa",
    "channel_number": 5,
    "board_id": 1,
    "previous_state": "off",
    "new_state": "on",
    "activation_time": "2025-01-22T10:15:30.123Z",
    "protection_mode": "none"
  },
  "related_events": [
    {
      "id": 999,
      "timestamp": "2025-01-22T10:15:25.100Z",
      "action": "button_press",
      "source": "web-interface"
    }
  ]
}
```

**Códigos de Status:**
- `200` - Evento encontrado
- `404` - Evento não encontrado
- `500` - Erro interno do servidor

---

### `GET /api/events/summary`

Retorna resumo estatístico dos eventos por período.

**Parâmetros de Query:**
- `period` (string, opcional): Período de análise (`1h`, `24h`, `7d`, `30d`) - padrão: `24h`
- `group_by` (string, opcional): Agrupar por (`event_type`, `source`, `action`, `status`) - padrão: `event_type`

**Resposta:**
```json
{
  "period": "24h",
  "total_events": 1247,
  "period_start": "2025-01-21T10:15:30.000Z",
  "period_end": "2025-01-22T10:15:30.000Z",
  "grouped_by": "event_type",
  "summary": {
    "device": {
      "total": 45,
      "success": 42,
      "error": 3,
      "most_common_action": "update",
      "error_rate": 6.7
    },
    "relay": {
      "total": 856,
      "success": 854,
      "error": 2,
      "most_common_action": "toggle",
      "error_rate": 0.2
    },
    "config": {
      "total": 23,
      "success": 23,
      "error": 0,
      "most_common_action": "update",
      "error_rate": 0.0
    },
    "system": {
      "total": 323,
      "success": 298,
      "error": 25,
      "most_common_action": "heartbeat",
      "error_rate": 7.7
    }
  },
  "trends": {
    "hourly_distribution": [
      {"hour": 0, "count": 15},
      {"hour": 1, "count": 8},
      {"hour": 2, "count": 12}
    ],
    "top_sources": [
      {"source": "esp32-relay-001", "count": 234},
      {"source": "config-app", "count": 198},
      {"source": "web-interface", "count": 156}
    ],
    "error_patterns": [
      {
        "pattern": "Connection timeout",
        "count": 15,
        "sources": ["mqtt-monitor", "gateway"]
      }
    ]
  }
}
```

---

### `GET /api/events/search`

Busca avançada de eventos com múltiplos critérios.

**Parâmetros de Query:**
- `query` (string): Termo de busca livre
- `event_types` (string): Tipos separados por vírgula
- `sources` (string): Origens separadas por vírgula
- `actions` (string): Ações separadas por vírgula
- `status` (string): Status do evento
- `has_error` (boolean): Apenas eventos com erro
- `target_contains` (string): Target que contém o termo
- `from_date` (datetime): Data inicial
- `to_date` (datetime): Data final
- `limit` (integer): Máximo de resultados
- `offset` (integer): Offset para paginação

**Resposta:**
```json
{
  "query": "relay toggle",
  "total_results": 856,
  "page": 1,
  "per_page": 50,
  "results": [
    {
      "id": 1002,
      "timestamp": "2025-01-22T10:16:45.456Z",
      "event_type": "relay",
      "source": "esp32-relay-001",
      "target": "channel_5",
      "action": "toggle",
      "status": "success",
      "match_score": 0.95,
      "match_fields": ["action", "event_type"]
    }
  ],
  "facets": {
    "event_types": {
      "relay": 734,
      "device": 89,
      "config": 33
    },
    "sources": {
      "esp32-relay-001": 234,
      "esp32-relay-002": 189,
      "web-interface": 145
    },
    "actions": {
      "toggle": 645,
      "update": 123,
      "create": 45
    }
  }
}
```

## 🏷️ Tipos de Eventos

### Device Events (`device`)
Eventos relacionados a dispositivos ESP32:
- `create` - Registro de novo dispositivo
- `update` - Atualização de configuração
- `connect` - Dispositivo conectou
- `disconnect` - Dispositivo desconectou
- `heartbeat` - Sinal de vida periódico
- `firmware_update` - Atualização de firmware

### Relay Events (`relay`)
Eventos de controle de relés:
- `toggle` - Alternar estado do relé
- `turn_on` - Ligar relé
- `turn_off` - Desligar relé
- `create_board` - Criação de nova placa
- `update_config` - Atualização de configuração
- `reset_config` - Reset para padrão

### Config Events (`config`)
Eventos de configuração do sistema:
- `create_screen` - Nova tela criada
- `update_screen` - Tela modificada
- `delete_screen` - Tela removida
- `create_item` - Novo item de tela
- `update_item` - Item modificado
- `theme_change` - Alteração de tema

### System Events (`system`)
Eventos do sistema:
- `startup` - Inicialização do sistema
- `shutdown` - Desligamento programado
- `backup` - Backup realizado
- `maintenance` - Manutenção programada
- `alert` - Alerta gerado
- `error` - Erro crítico

### Security Events (`security`)
Eventos de segurança:
- `login_attempt` - Tentativa de login
- `access_denied` - Acesso negado
- `permission_change` - Alteração de permissão
- `suspicious_activity` - Atividade suspeita
- `password_change` - Alteração de senha

### Telemetry Events (`telemetry`)
Eventos de dados:
- `data_received` - Dados recebidos
- `threshold_exceeded` - Limite excedido
- `sensor_failure` - Falha de sensor
- `calibration` - Calibração realizada
- `data_export` - Exportação de dados

## 📊 Status de Eventos

### `success`
- Evento executado com sucesso
- Nenhum erro reportado
- Resultado conforme esperado

### `error`
- Evento falhou na execução
- `error_message` contém detalhes
- Pode requerer intervenção

### `pending`
- Evento ainda em processamento
- Aguardando confirmação
- Status temporário

### `warning`
- Evento executado com avisos
- Possível problema identificado
- Monitoramento recomendado

## 🔍 Campos de Payload

### Device Events
```json
{
  "device_uuid": "esp32-relay-001",
  "device_name": "Relé Garagem",
  "device_type": "esp32_relay",
  "ip_address": "192.168.1.105",
  "firmware_version": "2.1.0",
  "previous_status": "offline",
  "new_status": "online"
}
```

### Relay Events
```json
{
  "board_id": 1,
  "channel_id": 5,
  "channel_name": "Luz Externa",
  "channel_number": 5,
  "previous_state": "off",
  "new_state": "on",
  "protection_mode": "none",
  "activation_time": 1000,
  "triggered_by": "web_interface"
}
```

### Config Events
```json
{
  "object_type": "screen",
  "object_id": 1,
  "object_name": "Dashboard Principal",
  "changes": {
    "title": {
      "from": "Dashboard",
      "to": "Dashboard Principal"
    },
    "position": {
      "from": 2,
      "to": 1
    }
  },
  "user_id": 123,
  "session_id": "sess_abc123"
}
```

### System Events
```json
{
  "component": "mqtt-monitor",
  "operation": "connection_check",
  "duration_ms": 1500,
  "resource_usage": {
    "cpu_percent": 15.3,
    "memory_mb": 128.5
  },
  "network": {
    "bytes_sent": 2048,
    "bytes_received": 4096
  }
}
```

## 🚨 Eventos de Erro

### Categorias de Erro
```json
{
  "network": {
    "description": "Problemas de conectividade",
    "examples": ["timeout", "connection_refused", "dns_failure"]
  },
  "device": {
    "description": "Falhas de dispositivos",
    "examples": ["sensor_failure", "memory_error", "hardware_fault"]
  },
  "config": {
    "description": "Erros de configuração",
    "examples": ["invalid_parameter", "missing_required_field", "constraint_violation"]
  },
  "permission": {
    "description": "Problemas de autorização",
    "examples": ["access_denied", "invalid_token", "insufficient_privileges"]
  }
}
```

### Estrutura de Error Message
```json
{
  "error_code": "RELAY_TOGGLE_FAILED",
  "error_message": "Failed to toggle relay channel 5: Connection timeout",
  "error_details": {
    "channel_id": 5,
    "board_id": 1,
    "device_uuid": "esp32-relay-001",
    "timeout_duration": 5000,
    "retry_count": 3,
    "last_response": null
  },
  "suggested_action": "Check device connectivity and retry operation"
}
```

## 📈 Casos de Uso

### Monitoramento em Tempo Real
```javascript
// Frontend - Monitorar eventos em tempo real
async function monitorEvents() {
    const events = await fetch('/api/events?limit=10').then(r => r.json());
    
    // Filtrar eventos críticos
    const criticalEvents = events.filter(e => 
        e.status === 'error' || e.event_type === 'security'
    );
    
    // Atualizar interface
    updateEventsFeed(events);
    updateAlerts(criticalEvents);
}

setInterval(monitorEvents, 5000);
```

### Análise de Falhas
```python
# Backend - Identificar padrões de falha
def analyze_failure_patterns(hours=24):
    error_events = events.search(
        status='error',
        since=datetime.now() - timedelta(hours=hours)
    )
    
    patterns = {}
    for event in error_events:
        key = f"{event.source}_{event.action}"
        if key not in patterns:
            patterns[key] = []
        patterns[key].append(event)
    
    # Identificar padrões recorrentes
    recurring_failures = {
        k: v for k, v in patterns.items() 
        if len(v) >= 3
    }
    
    return recurring_failures
```

### Relatórios de Auditoria
```python
# Relatórios - Gerar relatório de atividades
def generate_audit_report(user_id=None, days=30):
    events = events.search(
        since=datetime.now() - timedelta(days=days),
        user_id=user_id
    )
    
    report = {
        'period': f'{days} days',
        'total_events': len(events),
        'by_type': group_by_field(events, 'event_type'),
        'by_action': group_by_field(events, 'action'),
        'error_rate': calculate_error_rate(events),
        'timeline': generate_timeline(events),
        'recommendations': generate_recommendations(events)
    }
    
    return report
```

### Alertas Automatizados
```python
# Alertas - Sistema de notificações
class EventAlertSystem:
    def __init__(self):
        self.rules = [
            {
                'name': 'High Error Rate',
                'condition': lambda events: calculate_error_rate(events) > 5.0,
                'severity': 'critical',
                'notification': 'slack'
            },
            {
                'name': 'Device Offline',
                'condition': lambda events: any(
                    e.action == 'disconnect' and e.event_type == 'device'
                    for e in events
                ),
                'severity': 'warning',
                'notification': 'email'
            }
        ]
    
    def check_rules(self, events):
        alerts = []
        for rule in self.rules:
            if rule['condition'](events):
                alerts.append({
                    'rule': rule['name'],
                    'severity': rule['severity'],
                    'timestamp': datetime.now(),
                    'events_count': len(events)
                })
        return alerts
```

## ⚠️ Considerações

### Retenção de Dados
- Eventos são mantidos por 90 dias por padrão
- Eventos críticos podem ser arquivados permanentemente
- Dados antigos são comprimidos para otimizar espaço

### Performance
- Índices otimizados para consultas por timestamp e tipo
- Consultas complexas podem ser lentas com grande volume
- Use paginação para resultados extensos

### Privacidade
- Dados sensíveis são mascarados no payload
- IPs podem ser anonimizados conforme configuração
- Logs de acesso seguem regulamentações de privacidade

### Integridade
- Eventos não podem ser editados após criação
- Checksums garantem integridade dos dados
- Tentativas de alteração são registradas como eventos de segurança