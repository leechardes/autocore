"""
Constantes e helpers do protocolo MQTT v2.2.0 para AutoCore
Centraliza definições de protocolo e funções auxiliares
"""
import json
import logging
from datetime import datetime
from typing import Dict, Any, Optional
from enum import Enum

logger = logging.getLogger(__name__)

# Constantes do protocolo MQTT v2.2.0
MQTT_PROTOCOL_VERSION = "2.2.0"

class MessageType(Enum):
    """Tipos de mensagem suportados no protocolo v2.2.0"""
    DEVICE_ANNOUNCE = "announce"
    DEVICE_STATUS = "status"
    TELEMETRY = "telemetry"
    RELAY_STATE = "relay_state"
    RELAY_COMMAND = "relay_command"
    COMMAND_RESPONSE = "response"
    DISCOVERY = "discovery"
    ERROR = "error"
    GATEWAY_STATUS = "gateway_status"

class QoSLevel(Enum):
    """Níveis de QoS recomendados por tipo de mensagem"""
    TELEMETRY = 0      # Fire and forget
    STATUS = 1         # At least once
    COMMAND = 2        # Exactly once
    ERROR = 1          # At least once

def create_base_payload(device_uuid: str, message_type: str, **kwargs) -> Dict[str, Any]:
    """
    Cria payload base conforme protocolo v2.2.0
    Todos os payloads devem incluir protocol_version
    """
    payload = {
        'protocol_version': MQTT_PROTOCOL_VERSION,
        'uuid': device_uuid,
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'message_type': message_type,
        **kwargs
    }
    
    return payload

def create_gateway_status_payload(gateway_uuid: str, **kwargs) -> Dict[str, Any]:
    """Cria payload de status do gateway conforme v2.2.0"""
    return create_base_payload(
        device_uuid=gateway_uuid,
        message_type=MessageType.GATEWAY_STATUS.value,
        status='online',
        component_type='gateway',
        **kwargs
    )

def create_lwt_payload(gateway_uuid: str, reason: str = 'unexpected_disconnect') -> Dict[str, Any]:
    """Cria payload de Last Will Testament conforme v2.2.0"""
    return create_base_payload(
        device_uuid=gateway_uuid,
        message_type=MessageType.GATEWAY_STATUS.value,
        status='offline',
        component_type='gateway',
        reason=reason,
        last_seen=datetime.utcnow().isoformat() + 'Z'
    )

def create_telemetry_payload(device_uuid: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """Cria payload de telemetria conforme v2.2.0"""
    return create_base_payload(
        device_uuid=device_uuid,
        message_type=MessageType.TELEMETRY.value,
        data=data
    )

def create_error_payload(device_uuid: str, error_code: str, error_type: str, 
                        message: str, context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Cria payload de erro conforme v2.2.0"""
    return create_base_payload(
        device_uuid=device_uuid,
        message_type=MessageType.ERROR.value,
        error_code=error_code,
        error_type=error_type,
        error_message=message,
        context=context or {}
    )

def validate_protocol_version(payload: Dict[str, Any]) -> bool:
    """
    Valida a versão do protocolo no payload
    Retorna True se compatível, False caso contrário
    Aceita todas as versões v2.x.x
    """
    if 'protocol_version' not in payload:
        logger.warning("Payload sem protocol_version, assumindo v1.0.0")
        return False
    
    try:
        version = payload.get('protocol_version', '1.0.0')
        major_version = int(version.split('.')[0])
        
        # Aceita v2.x.x
        if major_version != 2:
            logger.error(f"Versão incompatível: {version}. Esperado v2.x.x")
            return False
        
        return True
        
    except (ValueError, IndexError) as e:
        logger.error(f"Formato de versão inválido: {payload.get('protocol_version')} - {e}")
        return False

def extract_device_uuid_from_topic(topic: str) -> Optional[str]:
    """
    Extrai UUID do dispositivo do tópico MQTT
    Formato esperado: autocore/{categoria}/{uuid}/{recurso}/{ação}
    """
    parts = topic.split('/')
    
    if len(parts) < 3 or parts[0] != 'autocore':
        return None
    
    # Para tópicos de dispositivos: autocore/devices/{uuid}/...
    if parts[1] == 'devices' and len(parts) > 2:
        return parts[2]
    
    # Para outros tópicos que podem ter UUID na terceira posição
    if len(parts) > 2:
        # Verificar se parece com UUID (simples verificação)
        potential_uuid = parts[2]
        if len(potential_uuid) > 8 and '-' in potential_uuid:
            return potential_uuid
    
    return None

def get_message_qos(message_type: str) -> int:
    """Retorna QoS recomendado para tipo de mensagem"""
    qos_map = {
        MessageType.TELEMETRY.value: QoSLevel.TELEMETRY.value,
        MessageType.DEVICE_STATUS.value: QoSLevel.STATUS.value,
        MessageType.RELAY_STATE.value: QoSLevel.STATUS.value,
        MessageType.RELAY_COMMAND.value: QoSLevel.COMMAND.value,
        MessageType.COMMAND_RESPONSE.value: QoSLevel.STATUS.value,
        MessageType.ERROR.value: QoSLevel.ERROR.value,
        MessageType.GATEWAY_STATUS.value: QoSLevel.STATUS.value,
    }
    
    return qos_map.get(message_type, QoSLevel.STATUS.value)

def parse_topic_structure(topic: str) -> Dict[str, str]:
    """
    Analisa estrutura do tópico e retorna informações
    Formato v2.2.0: autocore/{categoria}/{uuid}/{recurso}/{ação}
    """
    parts = topic.split('/')
    result = {
        'valid': False,
        'category': None,
        'uuid': None,
        'resource': None,
        'action': None,
        'message_type': None
    }
    
    if len(parts) < 2 or parts[0] != 'autocore':
        return result
    
    result['valid'] = True
    result['category'] = parts[1]
    
    if len(parts) > 2:
        result['uuid'] = parts[2]
    if len(parts) > 3:
        result['resource'] = parts[3]
    if len(parts) > 4:
        result['action'] = parts[4]
    
    # Determinar tipo de mensagem com base na estrutura
    if result['category'] == 'devices':
        if result['resource'] == 'relays' and result['action'] == 'state':
            result['message_type'] = MessageType.RELAY_STATE.value
        elif result['resource'] == 'relays' and result['action'] == 'set':
            result['message_type'] = MessageType.RELAY_COMMAND.value
        elif result['resource'] == 'status':
            result['message_type'] = MessageType.DEVICE_STATUS.value
        elif result['resource'] == 'announce':
            result['message_type'] = MessageType.DEVICE_ANNOUNCE.value
        elif result['resource'] == 'telemetry':
            result['message_type'] = MessageType.TELEMETRY.value
        elif result['resource'] == 'response':
            result['message_type'] = MessageType.COMMAND_RESPONSE.value
    elif result['category'] == 'discovery':
        result['message_type'] = MessageType.DISCOVERY.value
    elif result['category'] == 'errors':
        result['message_type'] = MessageType.ERROR.value
    elif result['category'] == 'gateway':
        result['message_type'] = MessageType.GATEWAY_STATUS.value
    
    return result

def serialize_payload(payload: Dict[str, Any]) -> str:
    """Serializa payload para JSON com formatação padrão"""
    try:
        return json.dumps(payload, ensure_ascii=False, separators=(',', ':'))
    except Exception as e:
        logger.error(f"Erro ao serializar payload: {e}")
        return "{}"

def deserialize_payload(payload_str: str) -> Dict[str, Any]:
    """Deserializa payload JSON com tratamento de erro"""
    try:
        return json.loads(payload_str)
    except json.JSONDecodeError as e:
        logger.error(f"Erro ao deserializar payload: {e}")
        return {}

# Constantes de tópicos v2.2.0
TOPIC_PATTERNS = {
    'device_status': 'autocore/devices/{uuid}/status',
    'device_command': 'autocore/devices/{uuid}/command',
    'relay_state': 'autocore/devices/{uuid}/relays/state',
    'relay_command': 'autocore/devices/{uuid}/relays/set',
    'telemetry': 'autocore/telemetry/relays/data',
    'gateway_status': 'autocore/gateway/status',
    'gateway_commands': 'autocore/gateway/commands/{command}',
    'errors': 'autocore/errors/{uuid}/{error_type}',
    'discovery': 'autocore/discovery/announce'
}

def get_topic_pattern(topic_type: str, **kwargs) -> str:
    """Retorna padrão de tópico formatado"""
    pattern = TOPIC_PATTERNS.get(topic_type)
    if not pattern:
        raise ValueError(f"Tipo de tópico desconhecido: {topic_type}")
    
    try:
        return pattern.format(**kwargs)
    except KeyError as e:
        raise ValueError(f"Parâmetro obrigatório não fornecido para {topic_type}: {e}")