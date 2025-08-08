"""
Simulador de Placa de Relé ESP32
Simula o comportamento de uma placa de relé real via MQTT
"""
import asyncio
import json
import logging
from typing import Dict, List, Optional
from datetime import datetime
import paho.mqtt.client as mqtt
from fastapi import WebSocket
import threading
from queue import Queue

logger = logging.getLogger(__name__)

class RelayBoardSimulator:
    """Simula uma placa de relé ESP32"""
    
    def __init__(self, board_id: int, device_uuid: str, total_channels: int = 16):
        self.board_id = board_id
        self.device_uuid = device_uuid
        self.total_channels = total_channels
        self.channel_states = {i: False for i in range(1, total_channels + 1)}
        self.is_connected = False
        self.mqtt_client = None
        self.websocket_clients: List[WebSocket] = []
        self.message_queue = Queue()
        
        # Heartbeat para relés momentâneos
        self.momentary_heartbeats = {}  # {channel: last_heartbeat_time}
        self.momentary_timeout = 1.0  # Timeout em segundos sem heartbeat
        self.heartbeat_tasks = {}  # Tasks de monitoramento ativo
        
        # MQTT Topics
        self.base_topic = f"autocore/devices/{device_uuid}"
        self.status_topic = f"{self.base_topic}/status"
        self.telemetry_topic = f"{self.base_topic}/telemetry"
        self.command_topic = f"{self.base_topic}/commands/+"
        self.relay_state_topic = f"{self.base_topic}/relays/state"
        self.relay_command_topic = f"{self.base_topic}/relays/set"
        
    def on_connect(self, client, userdata, flags, rc):
        """Callback quando conecta ao MQTT"""
        if rc == 0:
            logger.info(f"Simulador conectado ao MQTT: {self.device_uuid}")
            self.is_connected = True
            
            # Inscrever nos tópicos de comando
            client.subscribe(self.relay_command_topic)
            client.subscribe(f"{self.base_topic}/commands/+")
            
            # Publicar status online
            self.publish_status("online")
            
            # Publicar estado inicial
            self.publish_relay_states()
        else:
            logger.error(f"Falha na conexão MQTT: {rc}")
            self.is_connected = False
    
    def on_disconnect(self, client, userdata, rc):
        """Callback quando desconecta do MQTT"""
        self.is_connected = False
        logger.info(f"Simulador desconectado do MQTT: {self.device_uuid}")
    
    def on_message(self, client, userdata, msg):
        """Callback para mensagens MQTT recebidas"""
        try:
            topic = msg.topic
            payload = json.loads(msg.payload.decode())
            
            # Adicionar à fila para processar async
            self.message_queue.put((topic, payload))
            
        except Exception as e:
            logger.error(f"Erro processando mensagem MQTT: {e}")
    
    async def connect(self, mqtt_host: str = "localhost", mqtt_port: int = 1883):
        """Conecta ao broker MQTT"""
        try:
            self.mqtt_client = mqtt.Client(client_id=f"relay_simulator_{self.device_uuid}")
            self.mqtt_client.on_connect = self.on_connect
            self.mqtt_client.on_disconnect = self.on_disconnect
            self.mqtt_client.on_message = self.on_message
            
            # Conectar ao broker
            self.mqtt_client.connect(mqtt_host, mqtt_port, 60)
            
            # Iniciar loop em thread separada
            self.mqtt_client.loop_start()
            
            # Aguardar conexão
            await asyncio.sleep(1)
            
            return self.is_connected
            
        except Exception as e:
            logger.error(f"Erro conectando simulador: {e}")
            self.is_connected = False
            return False
    
    async def disconnect(self):
        """Desconecta do broker MQTT"""
        try:
            if self.mqtt_client:
                # Publicar status offline
                self.publish_status("offline")
                
                # Parar loop e desconectar
                self.mqtt_client.loop_stop()
                self.mqtt_client.disconnect()
                self.mqtt_client = None
                
            self.is_connected = False
            logger.info(f"Simulador desconectado: {self.device_uuid}")
        except Exception as e:
            logger.error(f"Erro desconectando simulador: {e}")
    
    def publish_status(self, status: str):
        """Publica status do dispositivo"""
        if not self.mqtt_client:
            return
            
        payload = {
            "uuid": self.device_uuid,
            "board_id": self.board_id,
            "status": status,
            "timestamp": datetime.now().isoformat(),
            "type": "esp32_relay",
            "channels": self.total_channels
        }
        
        try:
            self.mqtt_client.publish(
                self.status_topic,
                payload=json.dumps(payload),
                retain=True
            )
        except Exception as e:
            logger.error(f"Erro publicando status: {e}")
    
    def publish_relay_states(self):
        """Publica estado de todos os relés"""
        if not self.mqtt_client:
            return
            
        payload = {
            "uuid": self.device_uuid,
            "board_id": self.board_id,
            "timestamp": datetime.now().isoformat(),
            "channels": self.channel_states
        }
        
        try:
            self.mqtt_client.publish(
                self.relay_state_topic,
                payload=json.dumps(payload),
                retain=True
            )
            
            # Notificar WebSocket clients (async)
            asyncio.create_task(self.notify_websockets({"type": "state_update", "states": self.channel_states}))
            
        except Exception as e:
            logger.error(f"Erro publicando estados: {e}")
    
    async def set_relay_state(self, channel: int, state: bool, is_momentary: bool = False):
        """Define o estado de um relé"""
        if channel < 1 or channel > self.total_channels:
            logger.warning(f"Canal inválido: {channel}")
            return False
        
        # Se é momentâneo e está ligando, registra heartbeat
        if is_momentary and state:
            self.momentary_heartbeats[channel] = datetime.now()
            
            # Inicia task de monitoramento se não existir
            if channel not in self.heartbeat_tasks:
                self.heartbeat_tasks[channel] = asyncio.create_task(
                    self.monitor_heartbeat(channel)
                )
        elif is_momentary and not state:
            # Desligando momentâneo, remove do monitoramento
            if channel in self.momentary_heartbeats:
                del self.momentary_heartbeats[channel]
            if channel in self.heartbeat_tasks:
                self.heartbeat_tasks[channel].cancel()
                del self.heartbeat_tasks[channel]
        
        # Só atualiza e publica se o estado mudou
        old_state = self.channel_states[channel]
        if old_state != state:
            self.channel_states[channel] = state
            
            # Publicar estado atualizado
            self.publish_relay_states()
            
            # Publicar telemetria
            self.publish_telemetry(channel, state)
            
            logger.info(f"Relé {channel} -> {'ON' if state else 'OFF'}")
        
        return True
    
    async def toggle_relay(self, channel: int):
        """Alterna o estado de um relé"""
        if channel < 1 or channel > self.total_channels:
            return False
            
        new_state = not self.channel_states[channel]
        return await self.set_relay_state(channel, new_state)
    
    async def heartbeat_relay(self, channel: int):
        """Processa heartbeat de relé momentâneo"""
        if channel < 1 or channel > self.total_channels:
            return False
        
        # Atualiza timestamp do heartbeat
        self.momentary_heartbeats[channel] = datetime.now()
        
        # Se não está ligado, liga (mas não publica se já estava ligado)
        if not self.channel_states[channel]:
            await self.set_relay_state(channel, True, is_momentary=True)
        
        return True
    
    async def monitor_heartbeat(self, channel: int):
        """Monitora heartbeat de canal momentâneo e desliga se timeout"""
        logger.info(f"Iniciando monitoramento de heartbeat para canal {channel}")
        
        try:
            while channel in self.momentary_heartbeats:
                await asyncio.sleep(0.1)  # Verifica a cada 100ms
                
                if channel in self.momentary_heartbeats:
                    last_heartbeat = self.momentary_heartbeats[channel]
                    time_since = (datetime.now() - last_heartbeat).total_seconds()
                    
                    if time_since > self.momentary_timeout:
                        logger.warning(f"Timeout de heartbeat no canal {channel} - Desligando por segurança!")
                        
                        # Desliga o relé por segurança
                        self.channel_states[channel] = False
                        self.publish_relay_states()
                        self.publish_telemetry(channel, False)
                        
                        # Remove do monitoramento
                        if channel in self.momentary_heartbeats:
                            del self.momentary_heartbeats[channel]
                        
                        # Notificar via telemetria especial
                        safety_payload = {
                            "uuid": self.device_uuid,
                            "board_id": self.board_id,
                            "timestamp": datetime.now().isoformat(),
                            "event": "safety_shutoff",
                            "channel": channel,
                            "reason": "heartbeat_timeout",
                            "timeout": self.momentary_timeout
                        }
                        
                        if self.mqtt_client:
                            self.mqtt_client.publish(
                                self.telemetry_topic,
                                payload=json.dumps(safety_payload)
                            )
                        
                        break
                        
        except asyncio.CancelledError:
            logger.info(f"Monitoramento de heartbeat cancelado para canal {channel}")
        except Exception as e:
            logger.error(f"Erro no monitoramento de heartbeat: {e}")
    
    def publish_telemetry(self, channel: int, state: bool):
        """Publica telemetria de mudança de estado"""
        if not self.mqtt_client:
            return
            
        payload = {
            "uuid": self.device_uuid,
            "board_id": self.board_id,
            "timestamp": datetime.now().isoformat(),
            "event": "relay_change",
            "channel": channel,
            "state": state,
            "trigger": "simulator"
        }
        
        try:
            self.mqtt_client.publish(
                self.telemetry_topic,
                payload=json.dumps(payload)
            )
        except Exception as e:
            logger.error(f"Erro publicando telemetria: {e}")
    
    async def process_mqtt_messages(self):
        """Processa mensagens MQTT da fila"""
        while self.is_connected:
            try:
                # Verificar fila de mensagens
                if not self.message_queue.empty():
                    topic, payload = self.message_queue.get()
                    
                    if topic == self.relay_command_topic:
                        # Comando para definir estado de relé
                        channel = payload.get("channel")
                        state = payload.get("state")
                        
                        if channel and state is not None:
                            await self.set_relay_state(channel, state)
                            
                    elif "commands" in topic:
                        # Outros comandos
                        command = payload.get("command")
                        
                        if command == "reset":
                            # Reset todos os relés
                            for channel in self.channel_states:
                                self.channel_states[channel] = False
                            self.publish_relay_states()
                            
                        elif command == "status":
                            # Publicar status atual
                            self.publish_status("online")
                            self.publish_relay_states()
                
                await asyncio.sleep(0.1)
                
            except Exception as e:
                logger.error(f"Erro processando mensagens: {e}")
    
    async def run(self):
        """Loop principal do simulador"""
        if not self.is_connected:
            return
            
        # Processar mensagens MQTT
        await self.process_mqtt_messages()
    
    # WebSocket support
    async def add_websocket(self, websocket: WebSocket):
        """Adiciona cliente WebSocket"""
        self.websocket_clients.append(websocket)
        # Enviar estado inicial
        await websocket.send_json({
            "type": "initial_state",
            "board_id": self.board_id,
            "device_uuid": self.device_uuid,
            "states": self.channel_states,
            "total_channels": self.total_channels
        })
    
    async def remove_websocket(self, websocket: WebSocket):
        """Remove cliente WebSocket"""
        if websocket in self.websocket_clients:
            self.websocket_clients.remove(websocket)
    
    async def notify_websockets(self, data: dict):
        """Notifica todos os clientes WebSocket"""
        disconnected = []
        for ws in self.websocket_clients:
            try:
                await ws.send_json(data)
            except:
                disconnected.append(ws)
        
        # Remover clientes desconectados
        for ws in disconnected:
            self.websocket_clients.remove(ws)
    
    def get_status(self) -> dict:
        """Retorna status atual do simulador"""
        return {
            "board_id": self.board_id,
            "device_uuid": self.device_uuid,
            "is_connected": self.is_connected,
            "total_channels": self.total_channels,
            "channel_states": self.channel_states,
            "active_channels": sum(1 for state in self.channel_states.values() if state),
            "inactive_channels": sum(1 for state in self.channel_states.values() if not state)
        }


class RelaySimulatorManager:
    """Gerencia múltiplos simuladores de placa de relé"""
    
    def __init__(self, mqtt_host: str = "localhost", mqtt_port: int = 1883):
        self.mqtt_host = mqtt_host
        self.mqtt_port = mqtt_port
        self.simulators: Dict[int, RelayBoardSimulator] = {}
        self.running = False
        
    async def create_simulator(self, board_id: int, device_uuid: str, total_channels: int = 16) -> RelayBoardSimulator:
        """Cria um novo simulador"""
        if board_id in self.simulators:
            logger.warning(f"Simulador já existe para board_id: {board_id}")
            return self.simulators[board_id]
        
        simulator = RelayBoardSimulator(board_id, device_uuid, total_channels)
        if await simulator.connect(self.mqtt_host, self.mqtt_port):
            self.simulators[board_id] = simulator
            
            # Iniciar loop do simulador
            asyncio.create_task(simulator.run())
            
            return simulator
        return None
    
    async def remove_simulator(self, board_id: int):
        """Remove um simulador"""
        if board_id in self.simulators:
            simulator = self.simulators[board_id]
            await simulator.disconnect()
            del self.simulators[board_id]
    
    async def get_simulator(self, board_id: int) -> Optional[RelayBoardSimulator]:
        """Obtém um simulador específico"""
        return self.simulators.get(board_id)
    
    async def list_simulators(self) -> List[dict]:
        """Lista todos os simuladores ativos"""
        return [sim.get_status() for sim in self.simulators.values()]
    
    async def shutdown(self):
        """Desliga todos os simuladores"""
        for simulator in list(self.simulators.values()):
            await simulator.disconnect()
        self.simulators.clear()

# Instância global do manager
simulator_manager = RelaySimulatorManager()