# 🎨 FASE 2: Correção do Config-App - MQTT v2.2.0

## 📊 Resumo
- **Componente**: Config-App (Backend + Frontend)
- **Criticidade**: ALTA (interface de configuração)
- **Violações identificadas**: 5
- **Esforço estimado**: 6-8 horas
- **Prioridade**: P0 (Fazer imediatamente após Gateway)

## 🔍 Análise de Violações

### 1. Backend - Telemetria com UUID no Tópico
**Arquivo**: `config-app/backend/services/mqtt_monitor.py`
**Linhas**: 68-78

#### Atual (INCORRETO):
```python
class MQTTMonitor:
    def __init__(self):
        self.subscriptions = [
            "autocore/devices/+/status",
            "autocore/devices/+/telemetry",  # UUID no tópico
            "autocore/devices/+/relay/state",
            "autocore/discovery/+"
        ]
```

#### Correção (v2.2.0):
```python
class MQTTMonitor:
    def __init__(self):
        self.subscriptions = [
            "autocore/devices/+/status",
            "autocore/telemetry/relays/data",      # Sem UUID no tópico
            "autocore/telemetry/displays/data",    # Sem UUID no tópico
            "autocore/telemetry/sensors/+",        # Sensor específico
            "autocore/telemetry/can/+",            # Sinal CAN específico
            "autocore/devices/+/relays/state",     # Corrigido relay→relays
            "autocore/discovery/announce",         # Mais específico
            "autocore/errors/+/+",                 # Monitorar erros
            "autocore/gateway/status"              # Status do gateway
        ]
    
    def parse_telemetry(self, topic, payload):
        """
        Parser atualizado para extrair UUID do payload
        não mais do tópico
        """
        # Antes: uuid vinha do tópico
        # topic_parts = topic.split('/')
        # device_uuid = topic_parts[2]
        
        # Agora: uuid vem do payload
        data = json.loads(payload)
        
        # Validar protocol_version
        if 'protocol_version' not in data:
            logger.warning(f"Telemetria sem protocol_version: {payload}")
            return None
            
        device_uuid = data.get('uuid')
        if not device_uuid:
            logger.error(f"Telemetria sem UUID no payload: {payload}")
            return None
        
        return {
            'uuid': device_uuid,
            'timestamp': data.get('timestamp'),
            'data': data,
            'protocol_version': data.get('protocol_version')
        }
```

### 2. Backend - Falta Protocol Version nas Publicações
**Arquivo**: `config-app/backend/api/mqtt_routes.py`
**Problema**: Publicações sem versionamento

#### Atual:
```python
@router.post("/publish")
async def publish_message(topic: str, payload: dict):
    mqtt_client.publish(topic, json.dumps(payload))
    return {"status": "published"}
```

#### Correção:
```python
from datetime import datetime

@router.post("/publish")
async def publish_message(topic: str, payload: dict):
    # Adicionar protocol_version automaticamente
    if 'protocol_version' not in payload:
        payload['protocol_version'] = '2.2.0'
    
    # Adicionar timestamp se não existir
    if 'timestamp' not in payload:
        payload['timestamp'] = datetime.utcnow().isoformat() + 'Z'
    
    # Validar estrutura do tópico
    if not validate_topic_structure(topic):
        raise HTTPException(
            status_code=400,
            detail=f"Tópico não segue padrão v2.2.0: {topic}"
        )
    
    mqtt_client.publish(topic, json.dumps(payload))
    
    return {
        "status": "published",
        "topic": topic,
        "protocol_version": payload['protocol_version']
    }

def validate_topic_structure(topic: str) -> bool:
    """Valida se tópico segue padrão v2.2.0"""
    valid_patterns = [
        r"^autocore/devices/[\w-]+/(status|relays/set|relays/state|relays/heartbeat)$",
        r"^autocore/telemetry/(relays|displays|sensors|can)/[\w-]+$",
        r"^autocore/gateway/(status|commands/\w+)$",
        r"^autocore/discovery/announce$",
        r"^autocore/errors/[\w-]+/\w+$"
    ]
    
    import re
    return any(re.match(pattern, topic) for pattern in valid_patterns)
```

### 3. Frontend - Simulador com Tópicos Incorretos
**Arquivo**: `config-app/frontend/src/services/mqttService.js`
**Problema**: Usa estrutura antiga de tópicos

#### Atual:
```javascript
class MQTTService {
    publishRelayCommand(deviceId, channel, state) {
        const topic = `autocore/devices/${deviceId}/relay/command`;
        const payload = {
            channel: channel,
            state: state,
            timestamp: new Date().toISOString()
        };
        this.client.publish(topic, JSON.stringify(payload));
    }
}
```

#### Correção:
```javascript
class MQTTService {
    publishRelayCommand(deviceId, channel, state, functionType = 'toggle') {
        const topic = `autocore/devices/${deviceId}/relays/set`;
        const payload = {
            protocol_version: '2.2.0',
            channel: channel,
            state: state,
            function_type: functionType,
            user: 'config_app',
            timestamp: new Date().toISOString()
        };
        
        // QoS 1 para comandos
        this.client.publish(topic, JSON.stringify(payload), { qos: 1 });
    }
    
    publishHeartbeat(deviceId, channel) {
        const topic = `autocore/devices/${deviceId}/relays/heartbeat`;
        const payload = {
            protocol_version: '2.2.0',
            channel: channel,
            source_uuid: 'config-app-001',
            target_uuid: deviceId,
            timestamp: new Date().toISOString(),
            sequence: this.heartbeatSequence++
        };
        
        // QoS 1 para heartbeats
        this.client.publish(topic, JSON.stringify(payload), { qos: 1 });
    }
    
    subscribeToTelemetry() {
        // Telemetria agora sem UUID no tópico
        const topics = [
            'autocore/telemetry/relays/data',
            'autocore/telemetry/displays/data',
            'autocore/errors/+/+',
            'autocore/gateway/status'
        ];
        
        topics.forEach(topic => {
            this.client.subscribe(topic, { qos: 0 }); // QoS 0 para telemetria
        });
    }
}
```

### 4. Frontend - Monitor MQTT Desatualizado
**Arquivo**: `config-app/frontend/src/components/MQTTMonitor.jsx`
**Problema**: Exibe estrutura antiga, não valida protocol_version

#### Correção:
```jsx
import React, { useState, useEffect } from 'react';
import { Badge, Alert } from 'react-bootstrap';

const MQTTMonitor = () => {
    const [messages, setMessages] = useState([]);
    const [protocolStats, setProtocolStats] = useState({
        v2_2_0: 0,
        legacy: 0,
        invalid: 0
    });
    
    useEffect(() => {
        mqttService.onMessage((topic, payload) => {
            const data = JSON.parse(payload);
            
            // Validar protocol_version
            const protocolVersion = data.protocol_version || 'legacy';
            const isValid = validateProtocolVersion(protocolVersion);
            
            const message = {
                id: Date.now(),
                topic: topic,
                payload: data,
                timestamp: new Date().toISOString(),
                protocolVersion: protocolVersion,
                isValid: isValid,
                deviceUuid: extractDeviceUuid(topic, data)
            };
            
            setMessages(prev => [message, ...prev].slice(0, 100));
            updateProtocolStats(protocolVersion, isValid);
        });
    }, []);
    
    const validateProtocolVersion = (version) => {
        if (!version) return false;
        const [major] = version.split('.');
        return major === '2';
    };
    
    const extractDeviceUuid = (topic, payload) => {
        // Para telemetria, UUID vem do payload
        if (topic.startsWith('autocore/telemetry/')) {
            return payload.uuid || 'unknown';
        }
        
        // Para dispositivos, UUID vem do tópico
        const match = topic.match(/autocore\/devices\/([\w-]+)\//);
        return match ? match[1] : 'unknown';
    };
    
    const renderProtocolBadge = (version, isValid) => {
        if (!version) {
            return <Badge bg="danger">No Version</Badge>;
        }
        if (version === '2.2.0') {
            return <Badge bg="success">v2.2.0 ✓</Badge>;
        }
        if (isValid) {
            return <Badge bg="warning">{version}</Badge>;
        }
        return <Badge bg="danger">{version} ✗</Badge>;
    };
    
    return (
        <div className="mqtt-monitor">
            <div className="protocol-stats mb-3">
                <h5>Protocol Version Stats</h5>
                <div className="d-flex gap-3">
                    <Badge bg="success">v2.2.0: {protocolStats.v2_2_0}</Badge>
                    <Badge bg="warning">Legacy: {protocolStats.legacy}</Badge>
                    <Badge bg="danger">Invalid: {protocolStats.invalid}</Badge>
                </div>
            </div>
            
            {messages.map(msg => (
                <div key={msg.id} className="message-item">
                    <div className="d-flex justify-content-between">
                        <span className="topic">{msg.topic}</span>
                        {renderProtocolBadge(msg.protocolVersion, msg.isValid)}
                    </div>
                    <div className="device-uuid">Device: {msg.deviceUuid}</div>
                    <pre className="payload">{JSON.stringify(msg.payload, null, 2)}</pre>
                </div>
            ))}
        </div>
    );
};
```

### 5. Backend - Endpoint de Validação
**Novo arquivo**: `config-app/backend/api/protocol_routes.py`

```python
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, List, Optional

router = APIRouter(prefix="/api/protocol", tags=["protocol"])

class ProtocolValidation(BaseModel):
    topic: str
    payload: Dict
    
class ValidationResult(BaseModel):
    valid: bool
    version: Optional[str]
    errors: List[str]
    warnings: List[str]

@router.post("/validate", response_model=ValidationResult)
async def validate_mqtt_message(data: ProtocolValidation):
    """
    Valida se mensagem MQTT está conforme v2.2.0
    """
    errors = []
    warnings = []
    
    # Validar protocol_version
    version = data.payload.get('protocol_version')
    if not version:
        errors.append("Missing protocol_version in payload")
    elif not version.startswith('2.'):
        errors.append(f"Incompatible protocol version: {version}")
    elif version != '2.2.0':
        warnings.append(f"Using older v2 version: {version}")
    
    # Validar estrutura do tópico
    if not validate_topic_structure(data.topic):
        errors.append(f"Invalid topic structure: {data.topic}")
    
    # Validar timestamp
    if 'timestamp' not in data.payload:
        errors.append("Missing timestamp in payload")
    else:
        # Validar formato ISO 8601
        import re
        iso_pattern = r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z?$'
        if not re.match(iso_pattern, data.payload['timestamp']):
            errors.append("Timestamp not in ISO 8601 format")
    
    # Validar UUID para telemetria
    if 'telemetry' in data.topic and 'uuid' not in data.payload:
        errors.append("Telemetry payload missing UUID")
    
    return ValidationResult(
        valid=len(errors) == 0,
        version=version,
        errors=errors,
        warnings=warnings
    )

@router.get("/stats")
async def get_protocol_stats():
    """
    Retorna estatísticas de conformidade
    """
    # Implementar coleta de métricas
    return {
        "total_messages": 1000,
        "v2_2_0_compliant": 850,
        "legacy_messages": 100,
        "invalid_messages": 50,
        "compliance_rate": 0.85
    }
```

## 📝 Implementação Passo a Passo

### Passo 1: Backend - Atualizar MQTT Monitor
```bash
cd config-app/backend
# Backup
cp services/mqtt_monitor.py services/mqtt_monitor.py.backup
# Implementar correções
```

### Passo 2: Backend - Adicionar Validação
1. Criar `api/protocol_routes.py`
2. Adicionar rotas ao FastAPI
3. Implementar validação em mqtt_routes.py

### Passo 3: Frontend - Atualizar Service
```bash
cd config-app/frontend
# Backup
cp src/services/mqttService.js src/services/mqttService.js.backup
# Implementar correções
```

### Passo 4: Frontend - Atualizar Monitor
1. Modificar MQTTMonitor.jsx
2. Adicionar indicadores de protocol version
3. Implementar filtros por versão

### Passo 5: Testes
```javascript
// test/mqttService.test.js
describe('MQTT Service v2.2.0 Compliance', () => {
    test('should include protocol_version in all payloads', () => {
        const service = new MQTTService();
        const spy = jest.spyOn(service.client, 'publish');
        
        service.publishRelayCommand('esp32-relay-001', 1, true);
        
        const payload = JSON.parse(spy.mock.calls[0][1]);
        expect(payload.protocol_version).toBe('2.2.0');
    });
    
    test('should use correct topic structure', () => {
        const service = new MQTTService();
        const spy = jest.spyOn(service.client, 'publish');
        
        service.publishRelayCommand('esp32-relay-001', 1, true);
        
        const topic = spy.mock.calls[0][0];
        expect(topic).toBe('autocore/devices/esp32-relay-001/relays/set');
    });
    
    test('should extract UUID from payload for telemetry', () => {
        const telemetryPayload = {
            protocol_version: '2.2.0',
            uuid: 'esp32-relay-001',
            event: 'relay_change'
        };
        
        const uuid = service.extractDeviceUuid(
            'autocore/telemetry/relays/data',
            telemetryPayload
        );
        
        expect(uuid).toBe('esp32-relay-001');
    });
});
```

## 🧪 Validação

### Checklist de Validação
- [ ] Backend subscreve tópicos corretos (sem UUID em telemetria)
- [ ] Frontend envia protocol_version em todos os payloads
- [ ] Monitor exibe indicador de versão do protocolo
- [ ] Endpoint de validação funcionando
- [ ] Tópicos seguem padrão v2.2.0
- [ ] QoS correto para cada tipo de mensagem

### Script de Teste
```python
# scripts/test_config_app_mqtt.py
import requests
import json

def test_protocol_validation():
    """Testa endpoint de validação"""
    
    # Payload válido
    valid_payload = {
        "topic": "autocore/devices/esp32-relay-001/relays/set",
        "payload": {
            "protocol_version": "2.2.0",
            "channel": 1,
            "state": True,
            "timestamp": "2025-08-12T10:30:00Z"
        }
    }
    
    response = requests.post(
        "http://localhost:8000/api/protocol/validate",
        json=valid_payload
    )
    
    assert response.json()["valid"] == True
    
    # Payload inválido (sem version)
    invalid_payload = {
        "topic": "autocore/devices/esp32-relay-001/relay/command",
        "payload": {
            "channel": 1,
            "state": True
        }
    }
    
    response = requests.post(
        "http://localhost:8000/api/protocol/validate",
        json=invalid_payload
    )
    
    result = response.json()
    assert result["valid"] == False
    assert "Missing protocol_version" in result["errors"]
    assert "Invalid topic structure" in result["errors"]

if __name__ == "__main__":
    test_protocol_validation()
    print("✅ Todos os testes passaram!")
```

## 📊 Métricas de Sucesso
- ✅ 5/5 violações corrigidas
- ✅ 100% dos payloads com protocol_version
- ✅ Telemetria sem UUID no tópico
- ✅ Monitor mostra conformidade
- ✅ Validação automática funcionando

## 🚀 Deploy
1. Deploy backend primeiro
2. Testar com Gateway
3. Deploy frontend
4. Validar integração completa

## 📝 Notas
- Config-App é interface principal - UX importante
- Manter compatibilidade temporária para migração suave
- Monitor deve ajudar a identificar dispositivos não conformes

---
**Criado em**: 12/08/2025  
**Status**: Pronto para implementação  
**Estimativa**: 6-8 horas