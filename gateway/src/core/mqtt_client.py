"""
Cliente MQTT Assíncrono para AutoCore Gateway
Gerencia conexão e comunicação MQTT com dispositivos ESP32
"""
import asyncio
import json
import logging
from typing import Callable, Dict, Any, Optional
from datetime import datetime

import paho.mqtt.client as mqtt
from paho.mqtt.properties import Properties
from paho.mqtt.packettypes import PacketTypes

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
        
        # Estatísticas
        self.stats = {
            'messages_received': 0,
            'messages_sent': 0,
            'connection_time': None,
            'last_message_time': None
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
            
            # Configurar Last Will Testament
            self.client.will_set(
                topic='autocore/gateway/status',
                payload=json.dumps({
                    'timestamp': datetime.now().isoformat(),
                    'status': 'offline',
                    'reason': 'unexpected_disconnect'
                }),
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
            self.stats['connection_time'] = datetime.now()
            
            logger.info("✅ MQTT conectado com sucesso")
            
            # Subscrever tópicos diretamente (não precisa ser async)
            for topic in self.config.SUBSCRIPTION_TOPICS:
                self.client.subscribe(topic, qos=1)
                logger.debug(f"📥 Subscrito em {topic}")
            
            logger.info("📡 Subscrito em todos os tópicos")
            
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
            self.stats['last_message_time'] = datetime.now()
            
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
                        self._handle_message(message.topic, payload, message.qos),
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
        """Envia comando para dispositivo específico"""
        topic = self.config.get_device_topic(device_uuid, 'command')
        payload = json.dumps({
            **command,
            'timestamp': datetime.now().isoformat(),
            'gateway_id': self.config.MQTT_CLIENT_ID
        })
        
        return await self.publish(topic, payload, qos=2)  # QoS 2 para comandos
    
    async def broadcast_message(self, message: Dict[str, Any]) -> bool:
        """Envia mensagem broadcast para todos os dispositivos"""
        topic = self.config.mqtt_topics['system_broadcast']
        payload = json.dumps({
            **message,
            'timestamp': datetime.now().isoformat(),
            'gateway_id': self.config.MQTT_CLIENT_ID
        })
        
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
        """Retorna estatísticas do cliente MQTT"""
        return {
            **self.stats,
            'connected': self.connected,
            'reconnect_attempts': self.reconnect_attempts
        }