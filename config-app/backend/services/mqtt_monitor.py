"""
Serviço de Monitoramento MQTT
Conecta ao broker MQTT e retransmite mensagens via WebSocket
"""
import asyncio
import json
import logging
import os
from typing import Dict, List, Set, Any, Optional
from datetime import datetime
from dataclasses import dataclass, asdict
import paho.mqtt.client as mqtt
from fastapi import WebSocket
from dotenv import load_dotenv

# Importar notificador Telegram
try:
    from services.telegram_notifier import telegram
    TELEGRAM_ENABLED = telegram.enabled
except ImportError:
    TELEGRAM_ENABLED = False
    telegram = None

# Carregar variáveis de ambiente
load_dotenv()

logger = logging.getLogger(__name__)

@dataclass
class MQTTMessage:
    """Estrutura de mensagem MQTT"""
    topic: str
    payload: str
    qos: int
    timestamp: str
    direction: str = "received"  # received/sent
    device_uuid: Optional[str] = None
    message_type: Optional[str] = None
    
    def to_dict(self) -> dict:
        return asdict(self)

class MQTTMonitor:
    """Monitor MQTT com streaming via WebSocket"""
    
    def __init__(self, broker: str = None, port: int = None):
        # Usar valores do ambiente ou defaults
        self.broker = broker or os.getenv("MQTT_BROKER", os.getenv("MQTT_HOST", "localhost"))
        self.port = port or int(os.getenv("MQTT_PORT", "1883"))
        self.username = os.getenv("MQTT_USERNAME")
        self.password = os.getenv("MQTT_PASSWORD")
        
        self.client = mqtt.Client(client_id="autocore-config-monitor")
        
        # Configurar autenticação se houver credenciais
        if self.username and self.password:
            self.client.username_pw_set(self.username, self.password)
            logger.info(f"🔐 MQTT configurado com autenticação para usuário: {self.username}")
        else:
            logger.warning("⚠️ MQTT sem autenticação - configure MQTT_USERNAME e MQTT_PASSWORD no .env")
        
        self.connected = False
        self.websockets: Set[WebSocket] = set()
        self.message_history: List[MQTTMessage] = []
        self.max_history = 1000
        self.subscriptions = [
            "autocore/devices/+/announce",
            "autocore/devices/+/status", 
            "autocore/devices/+/telemetry",
            "autocore/devices/+/command",
            "autocore/devices/+/response",
            "autocore/devices/+/relay/status",
            "autocore/devices/+/relays/state",  # Estado dos relés
            "autocore/devices/+/relays/set",    # Comandos para relés
            "autocore/devices/+/commands/+",    # Comandos gerais
            "autocore/discovery/+",
            "autocore/gateway/status",
            "autocore/#",  # Captura TUDO para debug
        ]
        
        # Configurar callbacks
        self.client.on_connect = self._on_connect
        self.client.on_disconnect = self._on_disconnect
        self.client.on_message = self._on_message
        
    def _on_connect(self, client, userdata, flags, rc):
        """Callback de conexão MQTT"""
        if rc == 0:
            self.connected = True
            logger.info(f"✅ Monitor MQTT conectado ao broker {self.broker}:{self.port}")
            
            # Subscrever aos tópicos
            for topic in self.subscriptions:
                self.client.subscribe(topic, qos=1)
                logger.debug(f"📥 Subscrito em {topic}")
                
            # Notificar WebSockets será feito quando solicitado
            logger.info("📡 Monitor MQTT pronto para receber mensagens")
        else:
            # Mesmos códigos de erro
            error_codes = {
                1: "Protocolo incorreto",
                2: "ID de cliente inválido", 
                3: "Servidor indisponível",
                4: "Credenciais inválidas",
                5: "Não autorizado",
                7: "Conexão recusada - não autorizado"
            }
            error_msg = error_codes.get(rc, f"Erro desconhecido ({rc})")
            logger.error(f"❌ Falha na conexão MQTT: {error_msg}")
            
    def _on_disconnect(self, client, userdata, rc):
        """Callback de desconexão MQTT"""
        self.connected = False
        
        # Códigos de erro MQTT
        error_codes = {
            0: "Desconexão normal",
            1: "Protocolo incorreto",
            2: "ID de cliente inválido",
            3: "Servidor indisponível",
            4: "Credenciais inválidas",
            5: "Não autorizado",
            7: "Conexão recusada - não autorizado"
        }
        
        error_msg = error_codes.get(rc, f"Erro desconhecido ({rc})")
        
        if rc == 7 or rc == 4 or rc == 5:
            # Erro de autenticação - parar reconexão automática
            logger.error(f"❌ Monitor MQTT - Erro de autenticação: {error_msg}")
            logger.warning("⚠️ Verifique MQTT_USERNAME e MQTT_PASSWORD no .env")
            logger.warning("⚠️ Ou verifique se o Mosquitto está configurado para aceitar essas credenciais")
            # Parar o loop para evitar reconexão infinita
            client.loop_stop()
        elif rc != 0:
            logger.warning(f"⚠️ Monitor MQTT desconectado: {error_msg}")
        
    def _on_message(self, client, userdata, message):
        """Callback de mensagem MQTT recebida"""
        try:
            # Criar mensagem estruturada
            mqtt_msg = self._parse_message(message)
            
            # Adicionar ao histórico
            self._add_to_history(mqtt_msg)
            
            # Log da mensagem
            logger.debug(f"📨 Mensagem recebida: {mqtt_msg.topic}")
            
            # Notificar Telegram para mensagens importantes
            if TELEGRAM_ENABLED and telegram:
                self._notify_telegram_if_important(mqtt_msg)
            
            # WebSockets serão notificados no próximo poll
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar mensagem MQTT: {e}")
            
    def _parse_message(self, message) -> MQTTMessage:
        """Parse mensagem MQTT"""
        topic = message.topic
        
        # Tentar decodificar payload
        try:
            payload = message.payload.decode('utf-8')
            # Tentar parse JSON
            try:
                payload_json = json.loads(payload)
                # Limitar tamanho do payload formatado para evitar overflow
                # Usar formato compacto sempre para evitar problemas
                payload = json.dumps(payload_json)
                if len(payload) > 1000:  # Limitar a 1KB
                    # Para payloads grandes, enviar resumo
                    summary = {
                        "truncated": True,
                        "original_size": len(payload),
                        "keys": list(payload_json.keys()) if isinstance(payload_json, dict) else "array"
                    }
                    # Incluir primeiros campos se for dict
                    if isinstance(payload_json, dict):
                        for key in list(payload_json.keys())[:3]:
                            summary[key] = payload_json[key]
                    payload = json.dumps(summary)
            except:
                # Se não for JSON, limitar tamanho da string
                if len(payload) > 1000:
                    payload = payload[:997] + "..."
        except:
            payload = str(message.payload)
            if len(payload) > 1000:
                payload = payload[:997] + "..."
            
        # Extrair device_uuid e tipo do tópico
        device_uuid = None
        message_type = None
        
        parts = topic.split('/')
        if len(parts) >= 2 and parts[0] == 'autocore':
            # Só considerar device_uuid se for realmente um dispositivo ESP32
            if parts[1] == 'devices' and len(parts) >= 4:
                # Formato: autocore/devices/{uuid}/...
                # Este é um dispositivo real (ESP32)
                device_uuid = parts[2]
                # Tratar casos especiais de relés
                if parts[3] == 'relays':
                    if len(parts) > 4 and parts[4] == 'state':
                        message_type = 'relay_state'
                    elif len(parts) > 4 and parts[4] == 'set':
                        message_type = 'relay_command'
                    else:
                        message_type = 'relays'
                elif parts[3] == 'commands':
                    message_type = 'command'
                else:
                    message_type = parts[3]
            elif parts[1] == 'relay' and len(parts) >= 4:
                # autocore/relay/{id}/command ou status
                # NÃO definir device_uuid para relés (não são dispositivos)
                message_type = f'relay_{parts[3]}'  # relay_command ou relay_status
            elif parts[1] == 'macro' and len(parts) >= 4:
                # autocore/macro/{id}/status
                # NÃO definir device_uuid para macros
                message_type = 'macro_status'
            elif parts[1] == 'state':
                # autocore/state/save ou restore
                message_type = f'state_{parts[2] if len(parts) > 2 else "unknown"}'
            elif parts[1] == 'modes':
                # autocore/modes/{mode}
                message_type = 'mode_change'
                # NÃO definir device_uuid para modos
            elif parts[1] == 'system':
                # autocore/system/{command}
                message_type = 'system_command'
                # NÃO definir device_uuid para comandos do sistema
            elif parts[1] == 'discovery':
                message_type = 'discovery'
                # Discovery pode ter device_uuid real
                if len(parts) > 2:
                    device_uuid = parts[2]
            elif parts[1] == 'gateway':
                message_type = 'gateway_status'
                
        return MQTTMessage(
            topic=topic,
            payload=payload,
            qos=message.qos,
            timestamp=datetime.now().isoformat(),
            device_uuid=device_uuid,
            message_type=message_type
        )
        
    def _add_to_history(self, message: MQTTMessage):
        """Adiciona mensagem ao histórico"""
        self.message_history.append(message)
        
        # Limitar tamanho do histórico
        if len(self.message_history) > self.max_history:
            # Manter apenas últimas 900 mensagens quando atingir 1000
            self.message_history = self.message_history[-900:]
            logger.debug(f"Histórico limpo, mantendo últimas 900 de {self.max_history}")
            
    async def _broadcast_message(self, message: MQTTMessage):
        """Envia mensagem para todos os WebSockets conectados"""
        if not self.websockets:
            return
            
        msg_data = {
            "type": "mqtt_message",
            "data": message.to_dict()
        }
        
        disconnected = set()
        for ws in self.websockets:
            try:
                await ws.send_json(msg_data)
            except Exception as e:
                logger.debug(f"WebSocket desconectado: {e}")
                disconnected.add(ws)
                
        # Remover WebSockets desconectados
        self.websockets -= disconnected
        
    async def _notify_status(self, status: str):
        """Notifica status da conexão MQTT"""
        msg_data = {
            "type": "mqtt_status",
            "data": {
                "status": status,
                "broker": self.broker,
                "port": self.port,
                "timestamp": datetime.now().isoformat()
            }
        }
        
        disconnected = set()
        for ws in self.websockets:
            try:
                await ws.send_json(msg_data)
            except:
                disconnected.add(ws)
                
        self.websockets -= disconnected
        
    async def connect(self):
        """Conecta ao broker MQTT"""
        try:
            self.client.connect(self.broker, self.port, keepalive=60)
            self.client.loop_start()
            logger.info(f"🔄 Conectando ao broker MQTT {self.broker}:{self.port}")
            return True
        except Exception as e:
            logger.error(f"❌ Erro ao conectar MQTT: {e}")
            return False
            
    async def disconnect(self):
        """Desconecta do broker MQTT"""
        try:
            self.client.loop_stop()
            self.client.disconnect()
            logger.info("📴 Monitor MQTT desconectado")
        except Exception as e:
            logger.error(f"❌ Erro ao desconectar: {e}")
            
    async def add_websocket(self, websocket: WebSocket):
        """Adiciona WebSocket para receber mensagens"""
        await websocket.accept()
        self.websockets.add(websocket)
        logger.info(f"➕ WebSocket conectado. Total: {len(self.websockets)}")
        
        # Enviar status atual
        await websocket.send_json({
            "type": "mqtt_status",
            "data": {
                "status": "connected" if self.connected else "disconnected",
                "broker": self.broker,
                "port": self.port,
                "timestamp": datetime.now().isoformat()
            }
        })
        
        # Enviar histórico recente apenas se houver poucas mensagens
        if self.message_history and len(self.message_history) <= 10:
            recent = self.message_history[-10:]
            await websocket.send_json({
                "type": "history",
                "data": [msg.to_dict() for msg in recent]
            })
        elif self.message_history:
            # Se houver muitas mensagens, enviar apenas contagem
            await websocket.send_json({
                "type": "history_info",
                "data": {
                    "count": len(self.message_history),
                    "message": f"{len(self.message_history)} mensagens no histórico. Novas mensagens serão mostradas em tempo real."
                }
            })
            
        # Iniciar task de streaming para este websocket
        asyncio.create_task(self._stream_messages_to_websocket(websocket))
            
    async def _stream_messages_to_websocket(self, websocket: WebSocket):
        """Stream contínuo de mensagens para um WebSocket específico"""
        last_index = len(self.message_history)
        
        try:
            while websocket in self.websockets:
                current_length = len(self.message_history)
                
                # Verificar se o histórico foi limpo (índice ficou maior que o tamanho)
                if last_index > current_length:
                    # Reset do índice - pegar apenas novas mensagens a partir de agora
                    logger.debug(f"Histórico foi limpo, resetando índice de {last_index} para {current_length}")
                    last_index = current_length
                
                # Verificar se há novas mensagens
                if current_length > last_index:
                    new_messages = self.message_history[last_index:]
                    last_index = current_length
                    
                    # Enviar novas mensagens
                    for msg in new_messages:
                        try:
                            await websocket.send_json({
                                "type": "mqtt_message",
                                "data": msg.to_dict()
                            })
                        except:
                            # WebSocket desconectado
                            break
                
                # Aguardar um pouco antes de verificar novamente
                await asyncio.sleep(0.1)
                
        except Exception as e:
            logger.debug(f"Stream para WebSocket encerrado: {e}")
        finally:
            self.websockets.discard(websocket)
    
    async def remove_websocket(self, websocket: WebSocket):
        """Remove WebSocket"""
        self.websockets.discard(websocket)
        logger.info(f"➖ WebSocket desconectado. Total: {len(self.websockets)}")
        
    async def publish(self, topic: str, payload: str, qos: int = 1) -> bool:
        """Publica mensagem MQTT"""
        try:
            if not self.connected:
                logger.warning("⚠️ MQTT não conectado para publicar")
                return False
                
            # Publicar mensagem
            result = self.client.publish(topic, payload, qos=qos)
            
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                # Criar mensagem para histórico
                mqtt_msg = MQTTMessage(
                    topic=topic,
                    payload=payload,
                    qos=qos,
                    timestamp=datetime.now().isoformat(),
                    direction="sent"
                )
                
                # Adicionar ao histórico
                self._add_to_history(mqtt_msg)
                
                # Broadcast para WebSockets
                await self._broadcast_message(mqtt_msg)
                
                logger.info(f"📤 Mensagem publicada: {topic}")
                return True
            else:
                logger.error(f"❌ Erro ao publicar: {result.rc}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Erro ao publicar mensagem: {e}")
            return False
            
    def _notify_telegram_if_important(self, mqtt_msg: MQTTMessage):
        """Notifica Telegram para mensagens importantes"""
        try:
            topic = mqtt_msg.topic.lower()
            
            # Mensagens de segurança/emergência
            if "safety" in topic or "emergency" in topic:
                telegram.send_alert(
                    "🚨 Segurança AutoCore",
                    f"Tópico: {mqtt_msg.topic}\nPayload: {mqtt_msg.payload}",
                    "CRITICAL"
                )
                return
            
            # Dispositivos online/offline
            if "status" in topic:
                try:
                    payload = json.loads(mqtt_msg.payload)
                    if "online" in payload or "offline" in payload:
                        status = "online" if payload.get("online", False) else "offline"
                        device = mqtt_msg.device_uuid or "Desconhecido"
                        telegram.notify_device_status(device, status)
                except:
                    pass
            
            # Ações de relé
            if "relay" in topic and ("set" in topic or "toggle" in topic):
                try:
                    payload = json.loads(mqtt_msg.payload)
                    channel = payload.get("channel", "?")
                    action = payload.get("state", "TOGGLE")
                    telegram.notify_relay_action(channel, action)
                except:
                    pass
            
            # Erros
            if "error" in topic:
                telegram.send_alert(
                    "❌ Erro no Sistema",
                    f"Tópico: {mqtt_msg.topic}\nErro: {mqtt_msg.payload}",
                    "ERROR"
                )
        except Exception as e:
            logger.debug(f"Erro ao notificar Telegram: {e}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Retorna estatísticas do monitor"""
        return {
            "connected": self.connected,
            "broker": self.broker,
            "port": self.port,
            "websockets_connected": len(self.websockets),
            "messages_in_history": len(self.message_history),
            "subscribed_topics": self.subscriptions
        }

# Instância global do monitor
mqtt_monitor = MQTTMonitor()