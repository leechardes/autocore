"""
Message Handler para AutoCore Gateway
Processa mensagens MQTT recebidas dos dispositivos ESP32
"""
import asyncio
import json
import logging
from typing import Dict, Any, Optional
from datetime import datetime
from dataclasses import dataclass

logger = logging.getLogger(__name__)

@dataclass
class MessageContext:
    """Contexto da mensagem recebida"""
    topic: str
    payload: str
    qos: int
    device_uuid: Optional[str] = None
    message_type: Optional[str] = None
    timestamp: Optional[datetime] = None

class MessageHandler:
    """Handler principal para mensagens MQTT"""
    
    def __init__(self, device_manager, telemetry_service):
        self.device_manager = device_manager
        self.telemetry_service = telemetry_service
        self.message_processors = {
            'announce': self._handle_device_announce,
            'status': self._handle_device_status,
            'telemetry': self._handle_telemetry_data,
            'relay': self._handle_relay_status,
            'response': self._handle_command_response,
            'discovery': self._handle_device_discovery,
        }
    
    async def handle_message(self, topic: str, payload: str, qos: int):
        """Entry point para processamento de mensagens"""
        try:
            # Criar contexto da mensagem
            context = self._create_message_context(topic, payload, qos)
            
            if not context.device_uuid and context.message_type != 'discovery':
                logger.warning(f"⚠️ UUID de dispositivo não encontrado: {topic}")
                return
            
            # Decodificar payload JSON
            try:
                data = json.loads(payload) if payload else {}
            except json.JSONDecodeError as e:
                logger.error(f"❌ JSON inválido em {topic}: {e}")
                return
            
            # Log da mensagem recebida (debug)
            logger.debug(f"📨 {context.message_type} de {context.device_uuid}: {str(data)[:200]}")
            
            # Processar mensagem
            processor = self.message_processors.get(context.message_type)
            if processor:
                await processor(context, data)
            else:
                logger.warning(f"⚠️ Tipo de mensagem desconhecido: {context.message_type}")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar mensagem {topic}: {e}")
    
    def _create_message_context(self, topic: str, payload: str, qos: int) -> MessageContext:
        """Cria contexto da mensagem com base no tópico"""
        parts = topic.split('/')
        
        # Determinar UUID do dispositivo e tipo de mensagem
        device_uuid = None
        message_type = None
        
        if len(parts) >= 4 and parts[0] == 'autocore':
            if parts[1] == 'devices':
                device_uuid = parts[2]
                if len(parts) >= 4:
                    message_type = parts[3]
                if len(parts) >= 6 and parts[4] == 'relay':
                    message_type = 'relay'
            elif parts[1] == 'discovery':
                device_uuid = parts[2] if len(parts) > 2 else None
                message_type = 'discovery'
        
        return MessageContext(
            topic=topic,
            payload=payload,
            qos=qos,
            device_uuid=device_uuid,
            message_type=message_type,
            timestamp=datetime.now()
        )
    
    async def _handle_device_announce(self, context: MessageContext, data: Dict[str, Any]):
        """Processa anúncio de novo dispositivo"""
        try:
            logger.info(f"📢 Dispositivo se anunciando: {context.device_uuid}")
            
            # Validar dados obrigatórios
            required_fields = ['device_type', 'firmware_version', 'capabilities']
            for field in required_fields:
                if field not in data:
                    logger.error(f"❌ Campo obrigatório ausente em announce: {field}")
                    return
            
            # Processar anúncio no Device Manager
            await self.device_manager.handle_device_announce(
                device_uuid=context.device_uuid,
                device_data=data,
                timestamp=context.timestamp
            )
            
            logger.info(f"✅ Dispositivo {context.device_uuid} registrado")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar announce: {e}")
    
    async def _handle_device_status(self, context: MessageContext, data: Dict[str, Any]):
        """Processa status do dispositivo"""
        try:
            logger.debug(f"📊 Status de {context.device_uuid}")
            
            # Processar status no Device Manager
            await self.device_manager.handle_device_status(
                device_uuid=context.device_uuid,
                status_data=data,
                timestamp=context.timestamp
            )
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar status: {e}")
    
    async def _handle_telemetry_data(self, context: MessageContext, data: Dict[str, Any]):
        """Processa dados de telemetria"""
        try:
            logger.debug(f"📈 Telemetria de {context.device_uuid}")
            
            # Processar telemetria no Telemetry Service
            await self.telemetry_service.process_telemetry_data(
                device_uuid=context.device_uuid,
                telemetry_data=data,
                timestamp=context.timestamp
            )
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar telemetria: {e}")
    
    async def _handle_relay_status(self, context: MessageContext, data: Dict[str, Any]):
        """Processa status de relé"""
        try:
            logger.debug(f"🔌 Status de relé de {context.device_uuid}")
            
            # Extrair informações do relé
            relay_data = {
                'device_uuid': context.device_uuid,
                'timestamp': context.timestamp.isoformat(),
                'relay_states': data.get('relays', []),
                'power_consumption': data.get('power_consumption', 0),
                'errors': data.get('errors', [])
            }
            
            # Processar no Device Manager
            await self.device_manager.handle_relay_status(
                device_uuid=context.device_uuid,
                relay_data=relay_data
            )
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar status de relé: {e}")
    
    async def _handle_command_response(self, context: MessageContext, data: Dict[str, Any]):
        """Processa resposta de comando"""
        try:
            logger.debug(f"📋 Resposta de comando de {context.device_uuid}")
            
            # Extrair informações da resposta
            command_id = data.get('command_id')
            success = data.get('success', False)
            error_message = data.get('error_message')
            
            if not command_id:
                logger.warning(f"⚠️ Resposta de comando sem ID: {context.device_uuid}")
                return
            
            # Processar resposta
            await self.device_manager.handle_command_response(
                device_uuid=context.device_uuid,
                command_id=command_id,
                success=success,
                error_message=error_message,
                response_data=data,
                timestamp=context.timestamp
            )
            
            logger.debug(f"✅ Resposta de comando processada: {command_id}")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar resposta de comando: {e}")
    
    async def _handle_device_discovery(self, context: MessageContext, data: Dict[str, Any]):
        """Processa descoberta de dispositivo"""
        try:
            logger.info(f"🔍 Descoberta de dispositivo: {context.device_uuid or 'unknown'}")
            
            # Processar descoberta
            await self.device_manager.handle_device_discovery(
                discovery_data=data,
                timestamp=context.timestamp
            )
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar descoberta: {e}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Retorna estatísticas do message handler"""
        return {
            'processors_registered': len(self.message_processors),
            'last_activity': datetime.now().isoformat()
        }