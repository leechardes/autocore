# 🚀 FASE 1: Correção do Gateway - MQTT v2.2.0

## 📊 Resumo
- **Componente**: AutoCore Gateway
- **Criticidade**: ALTA (componente central)
- **Violações identificadas**: 6
- **Esforço estimado**: 8-12 horas
- **Prioridade**: P0 (Fazer imediatamente)

## 🔍 Análise de Violações

### 1. Tópicos Incorretos
**Arquivo**: `gateway/src/core/config.py`
**Linhas**: 68-69, 90

#### Atual (INCORRETO):
```python
MQTT_TOPICS = {
    'relay_command': 'autocore/devices/+/relay/command',
    'relay_status': 'autocore/devices/+/relay/status',
    'telemetry': 'autocore/devices/+/telemetry',
    'discovery': 'autocore/discovery/+'
}
```

#### Correção (v2.2.0):
```python
MQTT_TOPICS = {
    'relay_command': 'autocore/devices/+/relays/set',
    'relay_status': 'autocore/devices/+/relays/state',
    'telemetry': 'autocore/telemetry/relays/data',  # Sem UUID no tópico
    'discovery': 'autocore/discovery/announce',
    'errors': 'autocore/errors/+/+',
    'gateway_commands': 'autocore/gateway/commands/+',
    'gateway_status': 'autocore/gateway/status'
}
```

### 2. Falta Protocol Version
**Arquivo**: `gateway/src/mqtt/client.py`
**Problema**: Payloads sem versionamento

#### Atual:
```python
def publish_status(self):
    payload = {
        'uuid': self.gateway_uuid,
        'status': 'online',
        'timestamp': datetime.utcnow().isoformat() + 'Z'
    }
```

#### Correção:
```python
def publish_status(self):
    payload = {
        'protocol_version': '2.2.0',
        'uuid': self.gateway_uuid,
        'status': 'online',
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'uptime': self.get_uptime(),
        'connected_devices': len(self.devices),
        'messages_processed': self.stats['messages_processed']
    }
```

### 3. Falta Validação de Protocol Version
**Arquivo**: `gateway/src/handlers/relay_handler.py`
**Problema**: Não valida versão das mensagens recebidas

#### Implementação Nova:
```python
def validate_protocol_version(payload):
    """
    Valida a versão do protocolo no payload
    Retorna True se compatível, False caso contrário
    """
    if 'protocol_version' not in payload:
        logger.warning("Payload sem protocol_version, assumindo v1.0.0")
        return False
    
    version = payload.get('protocol_version')
    major = int(version.split('.')[0])
    
    # Aceita v2.x.x
    if major != 2:
        logger.error(f"Versão incompatível: {version}")
        publish_error('ERR_008', 'PROTOCOL_MISMATCH', 
                     f"Expected v2.x.x, got {version}")
        return False
    
    return True

def handle_relay_command(self, topic, payload):
    if not validate_protocol_version(payload):
        return
    
    # Processar comando...
```

### 4. Falta Tratamento de Erros Padronizado
**Novo arquivo**: `gateway/src/mqtt/error_handler.py`

```python
"""
Tratamento de erros padronizado conforme MQTT v2.2.0
"""
from datetime import datetime
from enum import Enum

class ErrorCode(Enum):
    ERR_001 = "COMMAND_FAILED"
    ERR_002 = "INVALID_PAYLOAD"
    ERR_003 = "TIMEOUT"
    ERR_004 = "UNAUTHORIZED"
    ERR_005 = "DEVICE_BUSY"
    ERR_006 = "HARDWARE_FAULT"
    ERR_007 = "NETWORK_ERROR"
    ERR_008 = "PROTOCOL_MISMATCH"

class ErrorHandler:
    def __init__(self, mqtt_client, gateway_uuid):
        self.mqtt_client = mqtt_client
        self.gateway_uuid = gateway_uuid
    
    def publish_error(self, error_code: ErrorCode, message: str, context: dict = None):
        """Publica erro padronizado no tópico correto"""
        
        error_payload = {
            'protocol_version': '2.2.0',
            'uuid': self.gateway_uuid,
            'error_code': error_code.name,
            'error_type': error_code.value,
            'error_message': message,
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'context': context or {}
        }
        
        topic = f"autocore/errors/{self.gateway_uuid}/{error_code.value.lower()}"
        self.mqtt_client.publish(topic, error_payload)
        
        # Log localmente também
        logger.error(f"Error published: {error_code.name} - {message}")
```

### 5. Falta Last Will Testament (LWT)
**Arquivo**: `gateway/src/mqtt/client.py`
**Linha**: Conexão MQTT

#### Atual:
```python
def connect(self):
    self.client.connect(self.broker_host, self.broker_port)
```

#### Correção:
```python
def connect(self):
    # Configurar Last Will Testament
    lwt_payload = {
        'protocol_version': '2.2.0',
        'uuid': self.gateway_uuid,
        'status': 'offline',
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'reason': 'unexpected_disconnect',
        'last_seen': datetime.utcnow().isoformat() + 'Z'
    }
    
    lwt_topic = f"autocore/devices/{self.gateway_uuid}/status"
    
    self.client.will_set(
        lwt_topic,
        payload=json.dumps(lwt_payload),
        qos=1,
        retain=True
    )
    
    self.client.connect(self.broker_host, self.broker_port)
```

### 6. Falta Rate Limiting
**Novo arquivo**: `gateway/src/mqtt/rate_limiter.py`

```python
"""
Rate limiting para conformidade com MQTT v2.2.0
Limite: 100 msgs/segundo por dispositivo
"""
from collections import defaultdict
from time import time
import threading

class RateLimiter:
    def __init__(self, max_messages_per_second=100):
        self.max_rate = max_messages_per_second
        self.devices = defaultdict(list)
        self.lock = threading.Lock()
    
    def check_rate(self, device_uuid):
        """
        Verifica se dispositivo pode enviar mensagem
        Retorna True se permitido, False se excedeu limite
        """
        current_time = time()
        
        with self.lock:
            # Limpar timestamps antigos (> 1 segundo)
            self.devices[device_uuid] = [
                ts for ts in self.devices[device_uuid] 
                if current_time - ts < 1.0
            ]
            
            # Verificar limite
            if len(self.devices[device_uuid]) >= self.max_rate:
                return False
            
            # Adicionar timestamp atual
            self.devices[device_uuid].append(current_time)
            return True
    
    def get_device_rate(self, device_uuid):
        """Retorna taxa atual de mensagens do dispositivo"""
        with self.lock:
            current_time = time()
            timestamps = [
                ts for ts in self.devices[device_uuid] 
                if current_time - ts < 1.0
            ]
            return len(timestamps)
```

## 📝 Implementação Passo a Passo

### Passo 1: Backup e Branch
```bash
cd gateway
git checkout -b fix/mqtt-v2.2.0-gateway
cp -r src src.backup
```

### Passo 2: Atualizar Configuração
1. Editar `src/core/config.py`
2. Corrigir todos os tópicos MQTT
3. Adicionar novos tópicos necessários

### Passo 3: Implementar Protocol Version
1. Criar classe base para payloads
2. Adicionar validação em todos os handlers
3. Incluir version em todas as publicações

### Passo 4: Adicionar Error Handler
1. Criar `src/mqtt/error_handler.py`
2. Integrar com handlers existentes
3. Substituir logs genéricos por erros padronizados

### Passo 5: Configurar LWT
1. Modificar conexão MQTT
2. Adicionar payload de LWT
3. Testar desconexão inesperada

### Passo 6: Implementar Rate Limiting
1. Criar `src/mqtt/rate_limiter.py`
2. Integrar no handler de mensagens
3. Adicionar métricas de rate

### Passo 7: Testes
```python
# test_mqtt_conformance.py
import pytest
from gateway.src.mqtt.client import MQTTClient

def test_protocol_version_in_payload():
    """Verifica se todos os payloads incluem protocol_version"""
    client = MQTTClient()
    payload = client._create_status_payload()
    assert 'protocol_version' in payload
    assert payload['protocol_version'] == '2.2.0'

def test_topic_structure():
    """Valida estrutura de tópicos v2.2.0"""
    from gateway.src.core.config import MQTT_TOPICS
    
    assert MQTT_TOPICS['relay_command'] == 'autocore/devices/+/relays/set'
    assert MQTT_TOPICS['relay_status'] == 'autocore/devices/+/relays/state'
    assert 'uuid' not in MQTT_TOPICS['telemetry']  # UUID só no payload

def test_lwt_configured():
    """Verifica configuração de Last Will Testament"""
    client = MQTTClient()
    # Verificar se LWT está configurado
    assert client.client._will is not None
    assert client.client._will_qos == 1
    assert client.client._will_retain == True

def test_rate_limiting():
    """Testa rate limiting de 100 msgs/segundo"""
    from gateway.src.mqtt.rate_limiter import RateLimiter
    
    limiter = RateLimiter(max_messages_per_second=100)
    device_uuid = 'esp32-relay-001'
    
    # Deve permitir 100 mensagens
    for i in range(100):
        assert limiter.check_rate(device_uuid) == True
    
    # Deve bloquear a 101ª
    assert limiter.check_rate(device_uuid) == False
```

## 🧪 Validação

### Checklist de Validação
- [ ] Todos os tópicos seguem padrão `autocore/{categoria}/{uuid}/{recurso}/{ação}`
- [ ] Todos os payloads incluem `protocol_version: "2.2.0"`
- [ ] LWT configurado com formato correto
- [ ] Rate limiting funcionando (100 msgs/s)
- [ ] Erros publicados em tópico padronizado
- [ ] Validação de protocol version em mensagens recebidas
- [ ] Testes passando 100%

### Comando de Validação
```bash
# Script para validar conformidade
python3 scripts/validate_mqtt_conformance.py --component gateway
```

## 📊 Métricas de Sucesso
- ✅ 6/6 violações corrigidas
- ✅ 100% dos payloads com protocol_version
- ✅ LWT funcionando
- ✅ Rate limiting ativo
- ✅ 0 tópicos com estrutura antiga

## 🚀 Deploy
1. Executar testes locais
2. Deploy em ambiente de teste
3. Validar com outros componentes
4. Deploy em produção

## 📝 Notas
- Gateway é componente crítico - testar exaustivamente
- Manter backward compatibility temporária se necessário
- Monitorar logs após deploy para detectar issues

---
**Criado em**: 12/08/2025  
**Status**: Pronto para implementação  
**Estimativa**: 8-12 horas