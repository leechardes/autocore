"""
Rotas MQTT com conformidade v2.2.0
"""
import json
import re
from datetime import datetime
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
from services.mqtt_monitor import mqtt_monitor

# Constante de versão do protocolo
MQTT_PROTOCOL_VERSION = "2.2.0"

router = APIRouter(prefix="/api/mqtt", tags=["mqtt"])

class PublishRequest(BaseModel):
    topic: str
    payload: Dict[str, Any]
    qos: Optional[int] = 1

class PublishResponse(BaseModel):
    status: str
    topic: str
    protocol_version: str
    timestamp: str

@router.post("/publish", response_model=PublishResponse)
async def publish_message(request: PublishRequest):
    """
    Publica mensagem MQTT com conformidade v2.2.0
    """
    # Adicionar protocol_version automaticamente
    if 'protocol_version' not in request.payload:
        request.payload['protocol_version'] = MQTT_PROTOCOL_VERSION
    
    # Adicionar timestamp se não existir
    if 'timestamp' not in request.payload:
        request.payload['timestamp'] = datetime.utcnow().isoformat() + 'Z'
    
    # Validar estrutura do tópico
    if not validate_topic_structure(request.topic):
        raise HTTPException(
            status_code=400,
            detail=f"Tópico não segue padrão v2.2.0: {request.topic}"
        )
    
    # Publicar via monitor MQTT
    payload_str = json.dumps(request.payload)
    success = await mqtt_monitor.publish(request.topic, payload_str, request.qos)
    
    if not success:
        raise HTTPException(
            status_code=500,
            detail="Erro ao publicar mensagem MQTT"
        )
    
    return PublishResponse(
        status="published",
        topic=request.topic,
        protocol_version=request.payload['protocol_version'],
        timestamp=request.payload['timestamp']
    )

@router.post("/clear")
async def clear_message_history():
    """
    Limpa histórico de mensagens
    """
    mqtt_monitor.message_history.clear()
    return {"status": "cleared", "message": "Histórico de mensagens limpo"}

@router.get("/status")
async def get_mqtt_status():
    """
    Retorna status da conexão MQTT
    """
    stats = mqtt_monitor.get_stats()
    return {
        "connected": stats["connected"],
        "broker": stats["broker"],
        "port": stats["port"],
        "websockets": stats["websockets_connected"],
        "messages": stats["messages_in_history"],
        "protocol_version": MQTT_PROTOCOL_VERSION
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