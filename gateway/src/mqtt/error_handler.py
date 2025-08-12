"""
Tratamento de erros padronizado conforme MQTT v2.2.0
Códigos de erro padronizados e publicação em tópicos específicos
"""
import logging
from datetime import datetime
from enum import Enum
from typing import Dict, Any, Optional

from .protocol import create_error_payload, get_topic_pattern, serialize_payload

logger = logging.getLogger(__name__)

class ErrorCode(Enum):
    """Códigos de erro padronizados v2.2.0"""
    ERR_001 = "COMMAND_FAILED"
    ERR_002 = "INVALID_PAYLOAD"
    ERR_003 = "TIMEOUT"
    ERR_004 = "UNAUTHORIZED"
    ERR_005 = "DEVICE_BUSY"
    ERR_006 = "HARDWARE_FAULT"
    ERR_007 = "NETWORK_ERROR"
    ERR_008 = "PROTOCOL_MISMATCH"

class ErrorSeverity(Enum):
    """Níveis de severidade dos erros"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class ErrorHandler:
    """Handler centralizado para erros do sistema"""
    
    def __init__(self, mqtt_client, gateway_uuid: str):
        self.mqtt_client = mqtt_client
        self.gateway_uuid = gateway_uuid
        self.error_count = 0
        self.last_error_time = None
        
        # Mapeamento de códigos para severidade
        self.severity_map = {
            ErrorCode.ERR_001: ErrorSeverity.MEDIUM,    # COMMAND_FAILED
            ErrorCode.ERR_002: ErrorSeverity.MEDIUM,    # INVALID_PAYLOAD
            ErrorCode.ERR_003: ErrorSeverity.HIGH,      # TIMEOUT
            ErrorCode.ERR_004: ErrorSeverity.HIGH,      # UNAUTHORIZED
            ErrorCode.ERR_005: ErrorSeverity.MEDIUM,    # DEVICE_BUSY
            ErrorCode.ERR_006: ErrorSeverity.CRITICAL,  # HARDWARE_FAULT
            ErrorCode.ERR_007: ErrorSeverity.HIGH,      # NETWORK_ERROR
            ErrorCode.ERR_008: ErrorSeverity.HIGH,      # PROTOCOL_MISMATCH
        }
    
    async def publish_error(self, error_code: ErrorCode, message: str, 
                           device_uuid: Optional[str] = None, 
                           context: Optional[Dict[str, Any]] = None):
        """
        Publica erro padronizado no tópico correto
        """
        try:
            # Usar UUID do gateway se não fornecido
            target_uuid = device_uuid or self.gateway_uuid
            
            # Criar payload do erro
            error_payload = create_error_payload(
                device_uuid=target_uuid,
                error_code=error_code.name,
                error_type=error_code.value,
                message=message,
                context=context
            )
            
            # Adicionar informações extras
            error_payload.update({
                'severity': self.severity_map.get(error_code, ErrorSeverity.MEDIUM).value,
                'source': 'gateway',
                'error_count': self.error_count + 1
            })
            
            # Determinar tópico de publicação
            topic = get_topic_pattern(
                'errors',
                uuid=target_uuid,
                error_type=error_code.value.lower()
            )
            
            # Serializar payload
            payload_str = serialize_payload(error_payload)
            
            # Publicar erro
            success = await self.mqtt_client.publish(
                topic=topic,
                payload=payload_str,
                qos=1,  # QoS 1 para garantir entrega
                retain=False
            )
            
            if success:
                self.error_count += 1
                self.last_error_time = datetime.utcnow()
                
                # Log local também
                severity = self.severity_map.get(error_code, ErrorSeverity.MEDIUM).value
                logger.error(
                    f"Error published [{severity.upper()}]: "
                    f"{error_code.name} - {message} "
                    f"(Device: {target_uuid})"
                )
                
                # Log crítico com mais detalhes
                if self.severity_map.get(error_code) == ErrorSeverity.CRITICAL:
                    logger.critical(
                        f"CRITICAL ERROR: {error_code.value} - {message}. "
                        f"Context: {context}. Device: {target_uuid}"
                    )
                
            else:
                logger.error(f"Failed to publish error {error_code.name}: {message}")
                
        except Exception as e:
            logger.error(f"Error in error handler: {e}")
    
    async def publish_command_error(self, command_id: str, error_message: str, 
                                   device_uuid: Optional[str] = None):
        """Publica erro específico de comando"""
        context = {
            'command_id': command_id,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        
        await self.publish_error(
            error_code=ErrorCode.ERR_001,
            message=f"Command failed: {error_message}",
            device_uuid=device_uuid,
            context=context
        )
    
    async def publish_payload_error(self, topic: str, payload_excerpt: str,
                                   device_uuid: Optional[str] = None):
        """Publica erro de payload inválido"""
        context = {
            'topic': topic,
            'payload_excerpt': payload_excerpt[:100],  # Limitar tamanho
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        
        await self.publish_error(
            error_code=ErrorCode.ERR_002,
            message=f"Invalid payload received from topic {topic}",
            device_uuid=device_uuid,
            context=context
        )
    
    async def publish_timeout_error(self, operation: str, timeout_seconds: int,
                                   device_uuid: Optional[str] = None):
        """Publica erro de timeout"""
        context = {
            'operation': operation,
            'timeout_seconds': timeout_seconds,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        
        await self.publish_error(
            error_code=ErrorCode.ERR_003,
            message=f"Operation timeout: {operation} ({timeout_seconds}s)",
            device_uuid=device_uuid,
            context=context
        )
    
    async def publish_protocol_error(self, received_version: str, expected_version: str,
                                    device_uuid: Optional[str] = None):
        """Publica erro de incompatibilidade de protocolo"""
        context = {
            'received_version': received_version,
            'expected_version': expected_version,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        
        await self.publish_error(
            error_code=ErrorCode.ERR_008,
            message=f"Protocol mismatch: received {received_version}, expected {expected_version}",
            device_uuid=device_uuid,
            context=context
        )
    
    async def publish_network_error(self, error_details: str, 
                                   device_uuid: Optional[str] = None):
        """Publica erro de rede"""
        context = {
            'error_details': error_details,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        
        await self.publish_error(
            error_code=ErrorCode.ERR_007,
            message=f"Network error: {error_details}",
            device_uuid=device_uuid,
            context=context
        )
    
    async def publish_hardware_error(self, component: str, error_details: str,
                                    device_uuid: Optional[str] = None):
        """Publica erro de hardware"""
        context = {
            'component': component,
            'error_details': error_details,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        
        await self.publish_error(
            error_code=ErrorCode.ERR_006,
            message=f"Hardware fault in {component}: {error_details}",
            device_uuid=device_uuid,
            context=context
        )
    
    def get_error_stats(self) -> Dict[str, Any]:
        """Retorna estatísticas de erro"""
        return {
            'total_errors': self.error_count,
            'last_error_time': self.last_error_time.isoformat() + 'Z' if self.last_error_time else None,
            'gateway_uuid': self.gateway_uuid
        }
    
    def reset_error_count(self):
        """Reseta contador de erros (para manutenção)"""
        self.error_count = 0
        self.last_error_time = None
        logger.info("Error count reset by maintenance operation")

# Função auxiliar para uso rápido
async def quick_error(mqtt_client, gateway_uuid: str, error_code: ErrorCode, 
                     message: str, device_uuid: Optional[str] = None,
                     context: Optional[Dict[str, Any]] = None):
    """
    Função auxiliar para publicar erro rapidamente sem instanciar ErrorHandler
    """
    error_handler = ErrorHandler(mqtt_client, gateway_uuid)
    await error_handler.publish_error(error_code, message, device_uuid, context)