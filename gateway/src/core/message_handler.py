"""
Message Handler para AutoCore Gateway
Processa mensagens MQTT recebidas dos dispositivos ESP32
Conformidade MQTT v2.2.0
"""
import asyncio
import json
import logging
from typing import Dict, Any, Optional
from datetime import datetime
from dataclasses import dataclass

# Importações v2.2.0
from mqtt.protocol import (
    validate_protocol_version,
    parse_topic_structure,
    deserialize_payload,
    MQTT_PROTOCOL_VERSION
)

logger = logging.getLogger(__name__)

@dataclass
class MessageContext:
    """Contexto da mensagem recebida v2.2.0"""
    topic: str
    payload: str
    qos: int
    device_uuid: Optional[str] = None
    message_type: Optional[str] = None
    timestamp: Optional[datetime] = None
    # Novos campos v2.2.0
    protocol_version: Optional[str] = None
    payload_data: Optional[Dict[str, Any]] = None
    topic_structure: Optional[Dict[str, str]] = None
    is_valid_protocol: bool = False

class MessageHandler:
    """Handler principal para mensagens MQTT v2.2.0"""
    
    def __init__(self, device_manager, telemetry_service, error_handler=None):
        self.device_manager = device_manager
        self.telemetry_service = telemetry_service
        self.error_handler = error_handler  # Será definido pelo mqtt_client
        self.message_processors = {
            'announce': self._handle_device_announce,
            'status': self._handle_device_status,
            'telemetry': self._handle_telemetry_data,
            'relay': self._handle_relay_status,
            'relay_state': self._handle_relay_status,  # Alias para relay
            'response': self._handle_command_response,
            'discovery': self._handle_device_discovery,
            'relay_command': self._handle_relay_command,  # Comandos de macros
            'system_command': self._handle_system_command,  # Comandos do sistema
            'macro_status': self._handle_macro_status,  # Status de macros
            'error': self._handle_error_message,  # Mensagens de erro
            'mode_change': self._handle_mode_change,  # Mudança de modo (parking, driving, etc)
        }
    
    async def handle_message(self, topic: str, payload: str, qos: int):
        """Entry point para processamento de mensagens v2.2.0"""
        try:
            # Log detalhado apenas para debug
            logger.debug(f"=== MENSAGEM MQTT RECEBIDA ===")
            logger.debug(f"Tópico: {topic}")
            logger.debug(f"QoS: {qos}")
            logger.debug(f"Payload: {payload[:500] if len(payload) > 500 else payload}")
            logger.debug(f"==============================")
            
            # Criar contexto da mensagem com validação v2.2.0
            context = self._create_message_context_v2(topic, payload, qos)
            
            # Log do contexto criado
            logger.debug(f"Contexto criado - UUID: {context.device_uuid}, Type: {context.message_type}")
            
            if not context.device_uuid and context.message_type not in ['discovery', 'gateway_status', 'mode_change']:
                logger.warning(f"⚠️ UUID de dispositivo não encontrado: {topic}")
                return
            
            # Usar payload já deserializado do contexto
            data = context.payload_data or {}
            
            # Validar protocol version se disponível
            if not context.is_valid_protocol and data:
                logger.warning(f"⚠️ Protocol version incompatível: {topic}")
                
                # Publicar erro se temos error_handler
                if self.error_handler and context.device_uuid:
                    from mqtt.error_handler import ErrorCode
                    await self.error_handler.publish_error(
                        error_code=ErrorCode.ERR_008,
                        message=f"Protocol version mismatch in topic {topic}",
                        device_uuid=context.device_uuid,
                        context={
                            'topic': topic,
                            'received_version': context.protocol_version,
                            'expected_version': MQTT_PROTOCOL_VERSION
                        }
                    )
                
                # Continuar processando para backward compatibility
            
            # Log da mensagem recebida (debug)
            logger.debug(f"📨 {context.message_type} de {context.device_uuid}: {str(data)[:200]}")
            
            # Processar mensagem
            processor = self.message_processors.get(context.message_type)
            if processor:
                await processor(context, data)
            else:
                logger.warning(f"⚠️ Tipo de mensagem desconhecido: {context.message_type}")
                logger.warning(f"=== DETALHES COMPLETOS DA MENSAGEM ===")
                logger.warning(f"Tópico: {topic}")
                logger.warning(f"QoS: {qos}")
                logger.warning(f"Payload completo: {payload}")
                logger.warning(f"Contexto: UUID={context.device_uuid}, Type={context.message_type}")
                logger.warning(f"Estrutura do tópico: {context.topic_structure}")
                logger.warning(f"====================================")
                
                # Publicar erro de payload inválido
                if self.error_handler and context.device_uuid:
                    from mqtt.error_handler import ErrorCode
                    await self.error_handler.publish_error(
                        error_code=ErrorCode.ERR_002,
                        message=f"Unknown message type: {context.message_type}",
                        device_uuid=context.device_uuid,
                        context={'topic': topic, 'message_type': context.message_type}
                    )
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar mensagem: {e}")
            logger.error(f"=== DETALHES COMPLETOS DO ERRO ===")
            logger.error(f"Tópico: {topic}")
            logger.error(f"QoS: {qos}")
            logger.error(f"Payload completo: {payload}")
            logger.error(f"Tipo de erro: {type(e).__name__}")
            logger.error(f"Detalhes do erro: {str(e)}")
            logger.error(f"==================================")
            
            # Publicar erro genérico se possível
            if self.error_handler:
                from mqtt.error_handler import ErrorCode
                # Tentar extrair UUID do tópico para erro
                try:
                    from mqtt.protocol import extract_device_uuid_from_topic
                    device_uuid = extract_device_uuid_from_topic(topic)
                    await self.error_handler.publish_error(
                        error_code=ErrorCode.ERR_002,
                        message=f"Message processing failed: {str(e)}",
                        device_uuid=device_uuid,
                        context={'topic': topic, 'error': str(e)}
                    )
                except:
                    pass  # Se não conseguir, apenas loga
    
    def _create_message_context_v2(self, topic: str, payload: str, qos: int) -> MessageContext:
        """Cria contexto da mensagem v2.2.0 com validação completa"""
        try:
            # Analisar estrutura do tópico usando v2.2.0
            topic_structure = parse_topic_structure(topic)
            
            # Tentar deserializar payload
            payload_data = {}
            if payload:
                try:
                    payload_data = deserialize_payload(payload)
                except Exception as e:
                    logger.debug(f"Não foi possível deserializar payload: {e}")
            
            # Validar protocol version
            is_valid_protocol = False
            protocol_version = None
            if payload_data:
                is_valid_protocol = validate_protocol_version(payload_data)
                protocol_version = payload_data.get('protocol_version')
            
            # Determinar message_type - preferir do payload se disponível
            message_type = topic_structure.get('message_type')
            if not message_type and payload_data:
                # Tentar obter do payload se não conseguiu determinar pelo tópico
                message_type = payload_data.get('message_type')
                if message_type:
                    logger.debug(f"Usando message_type do payload: {message_type}")
            
            return MessageContext(
                topic=topic,
                payload=payload,
                qos=qos,
                device_uuid=topic_structure.get('uuid') or payload_data.get('uuid'),
                message_type=message_type,
                timestamp=datetime.utcnow(),
                protocol_version=protocol_version,
                payload_data=payload_data,
                topic_structure=topic_structure,
                is_valid_protocol=is_valid_protocol
            )
            
        except Exception as e:
            logger.error(f"Erro ao criar contexto v2.2.0 para {topic}: {e}")
            # Fallback para método antigo
            return self._create_message_context(topic, payload, qos)
    
    def set_error_handler(self, error_handler):
        """Define o error handler (chamado pelo mqtt_client após inicialização)"""
        self.error_handler = error_handler
    
    def _create_message_context(self, topic: str, payload: str, qos: int) -> MessageContext:
        """Cria contexto da mensagem com base no tópico"""
        parts = topic.split('/')
        
        # Determinar UUID do dispositivo e tipo de mensagem
        device_uuid = None
        message_type = None
        
        if len(parts) >= 2 and parts[0] == 'autocore':
            if parts[1] == 'devices':
                device_uuid = parts[2] if len(parts) > 2 else None
                if len(parts) >= 4:
                    message_type = parts[3]
                if len(parts) >= 6 and parts[4] == 'relays':
                    if parts[5] == 'state':
                        message_type = 'relay_state'
                    elif parts[5] == 'set':
                        message_type = 'relay_command'
                    else:
                        message_type = 'relay'
            elif parts[1] == 'discovery':
                device_uuid = parts[2] if len(parts) > 2 else None
                message_type = 'discovery'
            elif parts[1] == 'relay' and len(parts) >= 4 and parts[3] == 'command':
                # autocore/devices/{uuid}/relays/command - Comandos de macros para relés
                device_uuid = parts[2]  # ID do relé ou "all"
                message_type = 'relay_command'
            elif parts[1] == 'system':
                # autocore/system/{command} - Comandos do sistema
                device_uuid = 'system'
                message_type = 'system_command'
            elif parts[1] == 'macro' and len(parts) >= 4 and parts[3] == 'status':
                # autocore/macro/{id}/status - Status de macros
                device_uuid = parts[2]  # ID da macro
                message_type = 'macro_status'
        
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
    
    async def _handle_relay_command(self, context: MessageContext, data: Dict[str, Any]):
        """Processa comando de relé vindo de macros"""
        try:
            relay_id = context.device_uuid  # UUID do dispositivo (relay_board_1)
            channel = data.get('channel')  # Canal específico do relé (1-16)
            command = data.get('command', 'toggle')
            source = data.get('source', 'unknown')
            
            logger.info(f"⚡ Comando de relé recebido: dispositivo={relay_id}, canal={channel}, comando={command} (de {source})")
            
            # Se for comando para todos os relés
            if relay_id == 'all':
                # Obter todos os dispositivos de relé
                relay_devices = await self.device_manager.get_devices_by_type('esp32_relay')
                for device in relay_devices:
                    # Enviar comando para cada dispositivo
                    await self.device_manager.send_relay_command(
                        device_uuid=device['uuid'],
                        channel='all',
                        command=command,
                        source=source
                    )
                logger.info(f"✅ Comando enviado para {len(relay_devices)} placas de relé")
            else:
                # Comando para relé específico
                # Por enquanto, vamos assumir que temos apenas uma placa
                relay_devices = await self.device_manager.get_devices_by_type('esp32_relay')
                if relay_devices:
                    device = relay_devices[0]  # Primeira placa encontrada
                    
                    # Usar o channel do payload, não o relay_id
                    if channel is not None:
                        await self.device_manager.send_relay_command(
                            device_uuid=device['uuid'],
                            channel=channel,  # Usar o channel correto do payload
                            command=command,
                            source=source
                        )
                        logger.info(f"✅ Comando enviado para dispositivo {relay_id}, canal {channel}")
                    else:
                        logger.warning(f"⚠️ Canal não especificado no comando para {relay_id}")
                else:
                    logger.warning(f"⚠️ Nenhuma placa de relé encontrada para processar comando")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar comando de relé: {e}")
    
    async def _handle_system_command(self, context: MessageContext, data: Dict[str, Any]):
        """Processa comando do sistema"""
        try:
            logger.info(f"🔧 Comando do sistema recebido: {context.topic}")
            
            # Por enquanto, apenas logar
            # Futuramente, processar comandos como shutdown, restart, etc.
            logger.debug(f"Payload do sistema: {data}")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar comando do sistema: {e}")
    
    async def _handle_macro_status(self, context: MessageContext, data: Dict[str, Any]):
        """Processa status de macro"""
        try:
            macro_id = context.device_uuid
            status = data.get('status')
            name = data.get('name', 'Unknown')
            
            logger.info(f"📊 Status de macro {macro_id} ({name}): {status}")
            
            # Por enquanto, apenas logar
            # Futuramente, pode-se armazenar histórico ou notificar UI
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar status de macro: {e}")
    
    async def _handle_error_message(self, context: MessageContext, data: Dict[str, Any]):
        """Processa mensagens de erro (não deve processar próprios erros)"""
        try:
            # Log apenas se for erro de dispositivo externo
            if context.device_uuid and context.device_uuid != 'gateway':
                error_code = data.get('error_code', 'UNKNOWN')
                error_message = data.get('message', 'No message')
                
                logger.warning(f"🚨 Erro reportado por {context.device_uuid}: {error_code} - {error_message}")
                
                # Apenas logar, não reprocessar ou reenviar
            else:
                # Ignorar erros do próprio gateway para evitar loop
                logger.debug(f"🔇 Ignorando erro próprio: {context.topic}")
                
        except Exception as e:
            logger.error(f"❌ Erro ao processar mensagem de erro: {e}")
    
    async def _handle_mode_change(self, context: MessageContext, data: Dict[str, Any]):
        """Processa mudança de modo (parking, driving, etc)"""
        try:
            # Extrair modo do contexto ou payload
            mode = context.topic_structure.get('mode') or data.get('mode')
            status = data.get('status', 'active')
            source = data.get('source', 'unknown')
            
            logger.info(f"🚗 Mudança de modo recebida: {mode}")
            logger.info(f"   Status: {status}")
            logger.info(f"   Fonte: {source}")
            
            # Por enquanto, apenas logar e repassar para o device manager
            # Futuramente, pode ativar configurações específicas do modo
            if self.device_manager:
                # Verificar se device_manager tem o método
                if hasattr(self.device_manager, 'handle_mode_change'):
                    await self.device_manager.handle_mode_change(
                        mode=mode,
                        status=status,
                        source=source,
                        timestamp=context.timestamp
                    )
                else:
                    logger.debug(f"Device manager não possui handler para mode_change")
            
            # Publicar evento de telemetria sobre mudança de modo
            if self.telemetry_service:
                await self.telemetry_service.process_telemetry_data(
                    device_uuid='system',
                    telemetry_data={
                        'event': 'mode_change',
                        'mode': mode,
                        'status': status,
                        'source': source
                    },
                    timestamp=context.timestamp
                )
            
            logger.info(f"✅ Modo {mode} processado com sucesso")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar mudança de modo: {e}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Retorna estatísticas do message handler"""
        return {
            'processors_registered': len(self.message_processors),
            'last_activity': datetime.now().isoformat()
        }