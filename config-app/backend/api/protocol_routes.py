"""
Endpoint de validação de conformidade MQTT v2.2.0
"""
import re
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, List, Optional
from services.mqtt_monitor import mqtt_monitor

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
        iso_pattern = r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z?$'
        if not re.match(iso_pattern, data.payload['timestamp']):
            errors.append("Timestamp not in ISO 8601 format")
    
    # Validar UUID para telemetria
    if 'telemetry' in data.topic and 'uuid' not in data.payload:
        errors.append("Telemetry payload missing UUID")
    
    # Validar campos obrigatórios para comandos de relé
    if '/relays/set' in data.topic:
        required_fields = ['channel', 'state', 'function_type', 'user']
        for field in required_fields:
            if field not in data.payload:
                errors.append(f"Relay command missing required field: {field}")
    
    # Validar campos obrigatórios para heartbeat
    if '/relays/heartbeat' in data.topic:
        required_fields = ['channel', 'source_uuid', 'target_uuid', 'sequence']
        for field in required_fields:
            if field not in data.payload:
                errors.append(f"Heartbeat missing required field: {field}")
    
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
    # Analisar histórico de mensagens para gerar estatísticas
    messages = mqtt_monitor.message_history
    
    total_messages = len(messages)
    v2_2_0_compliant = 0
    legacy_messages = 0
    invalid_messages = 0
    
    for msg in messages:
        if hasattr(msg, 'protocol_version') and msg.protocol_version:
            if msg.protocol_version == '2.2.0':
                v2_2_0_compliant += 1
            elif msg.protocol_version.startswith('2.'):
                legacy_messages += 1
            else:
                invalid_messages += 1
        else:
            invalid_messages += 1
    
    compliance_rate = v2_2_0_compliant / total_messages if total_messages > 0 else 0
    
    return {
        "total_messages": total_messages,
        "v2_2_0_compliant": v2_2_0_compliant,
        "legacy_messages": legacy_messages,
        "invalid_messages": invalid_messages,
        "compliance_rate": round(compliance_rate, 3),
        "compliance_percentage": round(compliance_rate * 100, 1)
    }

def validate_topic_structure(topic: str) -> bool:
    """Valida se tópico segue padrão v2.2.0"""
    valid_patterns = [
        r"^autocore/devices/[\w-]+/(status|relays/set|relays/state|relays/heartbeat)$",
        r"^autocore/telemetry/(relays|displays|sensors|can)/data$",
        r"^autocore/telemetry/(sensors|can)/[\w-]+$",
        r"^autocore/gateway/(status|commands/\w+)$",
        r"^autocore/discovery/announce$",
        r"^autocore/errors/[\w-]+/\w+$"
    ]
    
    return any(re.match(pattern, topic) for pattern in valid_patterns)