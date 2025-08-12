"""
Cliente MQTT Assíncrono para AutoCore Gateway
Gerencia conexão e comunicação MQTT com dispositivos ESP32
Conformidade MQTT v2.2.0
"""
import asyncio
import json
import logging
from typing import Callable, Dict, Any, Optional
from datetime import datetime

import paho.mqtt.client as mqtt
from paho.mqtt.properties import Properties
from paho.mqtt.packettypes import PacketTypes

# Importações para v2.2.0
from ..mqtt.protocol import (
    MQTT_PROTOCOL_VERSION,
    create_gateway_status_payload,
    create_lwt_payload,
    serialize_payload,
    get_topic_pattern
)
from ..mqtt.error_handler import ErrorHandler
from ..mqtt.rate_limiter import RateLimiter

logger = logging.getLogger(__name__)

class MQTTClient:
    """Cliente MQTT assíncrono para comunicação com dispositivos"""
    
    def __init__(self, config, message_handler):
        self.config = config
        self.message_handler = message_handler
        self.client = None
        self.connected = False
        self.reconnect_attempts = 0
        self.max_reconnect_attempts = 10
        self.message_queue = asyncio.Queue()
        self.loop = None  # Referência ao event loop principal
        
        # UUID do gateway para identificação
        self.gateway_uuid = self.config.MQTT_CLIENT_ID
        
        # Componentes v2.2.0
        self.error_handler = None  # Será inicializado após conectar
        self.rate_limiter = RateLimiter(max_messages_per_second=100)
        
        # Estatísticas expandidas
        self.stats = {
            'messages_received': 0,
            'messages_sent': 0,
            'messages_blocked': 0,
            'connection_time': None,
            'last_message_time': None,
            'protocol_version': MQTT_PROTOCOL_VERSION,
            'uptime_start': datetime.utcnow()
        }
    
    async def connect(self):
        """Conecta ao broker MQTT"""
        try:
            logger.info(f"🔗 Conectando ao broker MQTT {self.config.MQTT_BROKER}:{self.config.MQTT_PORT}")
            
            # Guardar referência ao event loop atual
            try:
                self.loop = asyncio.get_running_loop()
            except RuntimeError:
                self.loop = asyncio.get_event_loop()
            
            # Criar cliente MQTT
            self.client = mqtt.Client(
                client_id=self.config.MQTT_CLIENT_ID,
                protocol=mqtt.MQTTv5
            )
            
            # Configurar callbacks
            self.client.on_connect = self._on_connect
            self.client.on_disconnect = self._on_disconnect
            self.client.on_message = self._on_message
            self.client.on_publish = self._on_publish
            self.client.on_subscribe = self._on_subscribe
            
            # Configurar autenticação se habilitada
            if self.config.MQTT_USERNAME and self.config.MQTT_PASSWORD:
                self.client.username_pw_set(
                    self.config.MQTT_USERNAME,
                    self.config.MQTT_PASSWORD
                )
            
            # Configurar Last Will Testament v2.2.0
            lwt_payload = create_lwt_payload(
                gateway_uuid=self.gateway_uuid,
                reason='unexpected_disconnect'
            )
            lwt_topic = get_topic_pattern('gateway_status')
            
            self.client.will_set(
                topic=lwt_topic,
                payload=serialize_payload(lwt_payload),
                qos=1,
                retain=True
            )
            
            # Conectar (bloqueante)
            result = self.client.connect(
                self.config.MQTT_BROKER,
                self.config.MQTT_PORT,
                self.config.MQTT_KEEPALIVE
            )
            
            if result != mqtt.MQTT_ERR_SUCCESS:
                raise ConnectionError(f"Falha na conexão MQTT: {result}")
            
            # Iniciar loop em thread separada
            self.client.loop_start()
            
            # Aguardar conexão
            await self._wait_for_connection()
            
            logger.info("✅ Conectado ao broker MQTT")
            
        except Exception as e:
            logger.error(f"❌ Erro ao conectar MQTT: {e}")
            raise
    
    async def _wait_for_connection(self, timeout: int = 10):
        """Aguarda conexão ser estabelecida"""
        for _ in range(timeout * 10):
            if self.connected:
                return
            await asyncio.sleep(0.1)
        
        raise TimeoutError("Timeout na conexão MQTT")
    
    def _on_connect(self, client, userdata, flags, rc, properties=None):
        """Callback de conexão"""
        if rc == 0:
            self.connected = True
            self.reconnect_attempts = 0
            self.stats['connection_time'] = datetime.utcnow()
            
            # Inicializar error handler após conexão
            self.error_handler = ErrorHandler(self, self.gateway_uuid)
            
            # Definir error_handler no message_handler se possível
            if hasattr(self.message_handler, 'set_error_handler'):
                self.message_handler.set_error_handler(self.error_handler)
            
            logger.info("✅ MQTT conectado com sucesso")
            
            # Subscrever tópicos diretamente (não precisa ser async)
            for topic in self.config.SUBSCRIPTION_TOPICS:
                self.client.subscribe(topic, qos=1)
                logger.debug(f"📥 Subscrito em {topic}")
            
            logger.info("📡 Subscrito em todos os tópicos")
            
            # Publicar status online v2.2.0
            self._publish_online_status()
            
        else:
            logger.error(f"❌ Falha conexão MQTT: {rc}")
    
    def _on_disconnect(self, client, userdata, rc, properties=None):
        """Callback de desconexão"""
        self.connected = False
        logger.warning(f"⚠️ MQTT desconectado: {rc}")
        
        # Reconexão será tratada pelo paho-mqtt automaticamente
        if rc != 0:
            self.reconnect_attempts += 1
            logger.info(f"🔄 Tentando reconectar... (tentativa {self.reconnect_attempts})")
    
    def _on_message(self, client, userdata, message):
        """Callback de mensagem recebida - roda em thread do Paho MQTT"""
        try:
            self.stats['messages_received'] += 1
            self.stats['last_message_time'] = datetime.utcnow()
            
            # Decodificar payload
            try:
                payload = message.payload.decode('utf-8')
            except UnicodeDecodeError:
                logger.error(f"❌ Erro decodificação mensagem: {message.topic}")
                return
            
            # Log simples para debug
            logger.debug(f"📨 Mensagem recebida: {message.topic}")
            
            # Processar mensagem usando o loop principal se disponível
            if self.loop:
                try:
                    # run_coroutine_threadsafe é a forma correta quando em thread diferente
                    future = asyncio.run_coroutine_threadsafe(
                        self._handle_message_with_validation(message.topic, payload, message.qos),
                        self.loop
                    )
                    # Não precisamos esperar o resultado
                except Exception as e:
                    logger.debug(f"Não foi possível usar loop principal: {e}")
                    # Processar de forma síncrona se necessário
                    self._handle_message_sync(message.topic, payload, message.qos)
            else:
                # Se não há loop, processar de forma síncrona
                self._handle_message_sync(message.topic, payload, message.qos)
            
        except Exception as e:
            logger.error(f"❌ Erro processar mensagem: {e}")
    
    def _publish_online_status(self):
        """Publica status online inicial do gateway"""
        try:
            uptime_seconds = (datetime.utcnow() - self.stats['uptime_start']).total_seconds()
            
            status_payload = create_gateway_status_payload(
                gateway_uuid=self.gateway_uuid,
                uptime=uptime_seconds,
                connected_devices=0,  # Será atualizado pelo device_manager
                messages_processed=self.stats['messages_received']
            )
            
            topic = get_topic_pattern('gateway_status')
            
            result = self.client.publish(
                topic=topic,
                payload=serialize_payload(status_payload),
                qos=1,
                retain=True
            )
            
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                logger.info("📡 Status online publicado")
            else:
                logger.error(f"❌ Erro ao publicar status online: {result.rc}")
                
        except Exception as e:
            logger.error(f"❌ Erro ao publicar status online: {e}")
    
    async def _handle_message_with_validation(self, topic: str, payload: str, qos: int):
        """Processa mensagem com validação v2.2.0"""
        try:
            # Importar aqui para evitar importação circular
            from ..mqtt.protocol import extract_device_uuid_from_topic, deserialize_payload, validate_protocol_version
            
            # Extrair UUID do dispositivo do tópico
            device_uuid = extract_device_uuid_from_topic(topic)
            
            # Aplicar rate limiting se temos UUID do dispositivo
            if device_uuid:
                allowed = await self.rate_limiter.check_rate(device_uuid)
                if not allowed:
                    self.stats['messages_blocked'] += 1
                    logger.warning(f"⛔ Mensagem bloqueada por rate limit: {device_uuid}")
                    
                    # Publicar erro de rate limit
                    if self.error_handler:
                        await self.error_handler.publish_error(
                            error_code=self.error_handler.ErrorCode.ERR_005,  # DEVICE_BUSY
                            message=f"Rate limit exceeded for device {device_uuid}",
                            device_uuid=device_uuid,
                            context={'topic': topic, 'current_rate': self.rate_limiter.get_device_rate(device_uuid)}
                        )
                    
                    return
            
            # Tentar deserializar payload para validação
            try:
                payload_data = deserialize_payload(payload)
            except Exception:
                # Se não conseguir deserializar, passa adiante (pode ser payload simples)
                payload_data = {}
            
            # Validar protocol version se disponível
            if payload_data and not validate_protocol_version(payload_data):
                logger.warning(f"⚠️ Protocol version incompatível: {topic}")
                
                # Publicar erro de protocolo
                if self.error_handler:
                    received_version = payload_data.get('protocol_version', 'unknown')
                    await self.error_handler.publish_protocol_error(
                        received_version=received_version,
                        expected_version=MQTT_PROTOCOL_VERSION,
                        device_uuid=device_uuid
                    )
                
                # Ainda processa a mensagem para backward compatibility
                # mas logga o problema
            
            # Validar tópico
            if not self.config.is_valid_device_topic(topic):
                logger.warning(f"⚠️ Tópico inválido: {topic}")
                return
            
            # Log da mensagem (debug)
            logger.debug(f"📨 Validado: {topic} | {payload[:100]}")
            
            # Enviar para handler específico
            await self.message_handler.handle_message(topic, payload, qos)
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar mensagem validada {topic}: {e}")
            
            # Publicar erro se possível
            if self.error_handler:
                await self.error_handler.publish_error(
                    error_code=self.error_handler.ErrorCode.ERR_002,  # INVALID_PAYLOAD
                    message=f"Message processing error: {str(e)}",
                    device_uuid=device_uuid,
                    context={'topic': topic, 'error': str(e)}
                )
    
    def _handle_message_sync(self, topic: str, payload: str, qos: int):
        """Processa mensagem de forma síncrona (fallback)"""
        try:
            # Validar tópico
            if not self.config.is_valid_device_topic(topic):
                logger.warning(f"⚠️ Tópico inválido: {topic}")
                return
            
            # Log da mensagem (debug)
            logger.debug(f"📨 [Sync] Recebido: {topic} | {payload[:100]}")
            
            # Por enquanto, apenas logar a mensagem
            # O processamento real seria feito de forma assíncrona
            logger.info(f"📥 Mensagem processada (sync): {topic}")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar mensagem sync {topic}: {e}")
    
    async def _handle_message(self, topic: str, payload: str, qos: int):
        """Processa mensagem de forma assíncrona"""
        try:
            # Validar tópico
            if not self.config.is_valid_device_topic(topic):
                logger.warning(f"⚠️ Tópico inválido: {topic}")
                return
            
            # Log da mensagem (debug)
            logger.debug(f"📨 Recebido: {topic} | {payload[:100]}")
            
            # Enviar para handler específico
            await self.message_handler.handle_message(topic, payload, qos)
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar mensagem {topic}: {e}")
    
    def _on_publish(self, client, userdata, mid):
        """Callback de mensagem publicada"""
        self.stats['messages_sent'] += 1
        logger.debug(f"📤 Mensagem publicada: {mid}")
    
    def _on_subscribe(self, client, userdata, mid, granted_qos, properties=None):
        """Callback de subscrição"""
        logger.debug(f"📝 Subscrito: {mid} | QoS: {granted_qos}")
    
    # Método removido - subscrição agora é feita diretamente no _on_connect
    # async def _subscribe_to_topics(self):
    #     """Subscreve aos tópicos necessários"""
    #     topics = [
    #         # Device management
    #         (self.config.mqtt_topics['device_announce'], 1),
    #         (self.config.mqtt_topics['device_status'], 1),
    #         
    #         # Telemetry
    #         (self.config.mqtt_topics['telemetry_data'], 0),
    #         
    #         # Relay status
    #         (self.config.mqtt_topics['relay_status'], 1),
    #         
    #         # Discovery
    #         (self.config.mqtt_topics['device_discovery'], 1),
    #     ]
    #     
    #     for topic, qos in topics:
    #         result = self.client.subscribe(topic, qos)
    #         if result[0] != mqtt.MQTT_ERR_SUCCESS:
    #             logger.error(f"❌ Erro ao subscrever {topic}: {result[0]}")
    #         else:
    #             logger.info(f"📝 Subscrito: {topic}")
    
    async def publish(self, topic: str, payload: str, qos: int = 0, retain: bool = False):
        """Publica mensagem"""
        if not self.connected:
            logger.warning(f"⚠️ MQTT desconectado - mensagem não enviada: {topic}")
            return False
        
        try:
            result = self.client.publish(topic, payload, qos, retain)
            
            if result.rc != mqtt.MQTT_ERR_SUCCESS:
                logger.error(f"❌ Erro ao publicar {topic}: {result.rc}")
                return False
            
            logger.debug(f"📤 Publicado: {topic}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro publish {topic}: {e}")
            return False
    
    async def send_command_to_device(self, device_uuid: str, command: Dict[str, Any]) -> bool:
        """Envia comando para dispositivo específico v2.2.0"""
        from ..mqtt.protocol import create_base_payload, get_message_qos, MessageType
        
        topic = self.config.get_device_topic(device_uuid, 'command')
        
        # Criar payload v2.2.0
        payload_data = create_base_payload(
            device_uuid=self.gateway_uuid,  # Comando vem do gateway
            message_type=MessageType.COMMAND_RESPONSE.value,
            target_device=device_uuid,
            command=command
        )
        
        payload = serialize_payload(payload_data)
        qos = get_message_qos(MessageType.COMMAND_RESPONSE.value)
        
        return await self.publish(topic, payload, qos=qos)
    
    async def broadcast_message(self, message: Dict[str, Any]) -> bool:
        """Envia mensagem broadcast para todos os dispositivos v2.2.0"""
        from ..mqtt.protocol import create_base_payload
        
        topic = self.config.mqtt_topics['system_broadcast']
        
        # Criar payload v2.2.0
        payload_data = create_base_payload(
            device_uuid=self.gateway_uuid,
            message_type='system_broadcast',
            broadcast_message=message
        )
        
        payload = serialize_payload(payload_data)
        
        return await self.publish(topic, payload, qos=1, retain=True)
    
    async def _reconnect(self):
        """Tenta reconectar ao broker"""
        if self.reconnect_attempts >= self.max_reconnect_attempts:
            logger.error("❌ Máximo de tentativas de reconexão atingido")
            return
        
        self.reconnect_attempts += 1
        wait_time = min(60, 2 ** self.reconnect_attempts)  # Exponential backoff
        
        logger.info(f"🔄 Tentativa reconexão {self.reconnect_attempts}/{self.max_reconnect_attempts} em {wait_time}s")
        
        await asyncio.sleep(wait_time)
        
        try:
            await self.connect()
        except Exception as e:
            logger.error(f"❌ Falha na reconexão: {e}")
            asyncio.create_task(self._reconnect())
    
    async def disconnect(self):
        """Desconecta do broker"""
        if self.client:
            logger.info("📴 Desconectando MQTT...")
            self.client.loop_stop()
            self.client.disconnect()
            self.connected = False
    
    def get_stats(self) -> Dict[str, Any]:
        """Retorna estatísticas do cliente MQTT v2.2.0"""
        uptime_seconds = (datetime.utcnow() - self.stats['uptime_start']).total_seconds()
        
        base_stats = {
            **self.stats,
            'connected': self.connected,
            'reconnect_attempts': self.reconnect_attempts,
            'uptime_seconds': uptime_seconds,
            'gateway_uuid': self.gateway_uuid
        }
        
        # Adicionar stats do rate limiter se disponível
        if self.rate_limiter:
            base_stats['rate_limiter'] = self.rate_limiter.get_global_stats()
        
        # Adicionar stats do error handler se disponível
        if self.error_handler:
            base_stats['error_handler'] = self.error_handler.get_error_stats()
        
        return base_stats
    
    async def publish_gateway_status(self):
        """Publica status atualizado do gateway"""
        try:
            uptime_seconds = (datetime.utcnow() - self.stats['uptime_start']).total_seconds()
            
            status_payload = create_gateway_status_payload(
                gateway_uuid=self.gateway_uuid,
                uptime=uptime_seconds,
                connected_devices=0,  # Atualizado externamente
                messages_processed=self.stats['messages_received'],
                messages_sent=self.stats['messages_sent'],
                messages_blocked=self.stats['messages_blocked']
            )
            
            topic = get_topic_pattern('gateway_status')
            
            return await self.publish(
                topic=topic,
                payload=serialize_payload(status_payload),
                qos=1,
                retain=True
            )
            
        except Exception as e:
            logger.error(f"❌ Erro ao publicar status do gateway: {e}")
            return False