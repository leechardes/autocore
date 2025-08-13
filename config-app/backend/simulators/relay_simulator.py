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

# Importar protocolo v2.2.0
from protocol import create_relay_payload

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
            
            # Inscrever nos tópicos de comando (conforme MQTT Architecture v2.1.0)
            relay_set_topic = f"{self.base_topic}/relays/set"
            client.subscribe(relay_set_topic)
            client.subscribe(f"{self.base_topic}/commands/+")
            logger.info(f"📡 Inscrito em: {relay_set_topic}")
            
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
    
    async def connect(self, mqtt_host: str = "localhost", mqtt_port: int = 1883, username: str = None, password: str = None):
        """Conecta ao broker MQTT"""
        logger.info(f"RelayBoardSimulator.connect chamado para {self.device_uuid}")
        logger.info(f"  Host: {mqtt_host}, Port: {mqtt_port}")
        
        try:
            logger.info("Criando cliente MQTT...")
            client_id = f"relay_simulator_{self.device_uuid}"
            self.mqtt_client = mqtt.Client(client_id=client_id)
            logger.info(f"Cliente criado com ID: {client_id}")
            
            # Configurar autenticação se fornecida
            if username and password:
                self.mqtt_client.username_pw_set(username, password)
                logger.info(f"Autenticação configurada para usuário: {username}")
            
            self.mqtt_client.on_connect = self.on_connect
            self.mqtt_client.on_disconnect = self.on_disconnect
            self.mqtt_client.on_message = self.on_message
            logger.info("Callbacks configurados")
            
            # Conectar ao broker
            logger.info(f"Conectando ao broker MQTT em {mqtt_host}:{mqtt_port}...")
            self.mqtt_client.connect(mqtt_host, mqtt_port, 60)
            logger.info("Comando connect executado")
            
            # Iniciar loop em thread separada
            self.mqtt_client.loop_start()
            logger.info("Loop MQTT iniciado")
            
            # Aguardar conexão
            logger.info("Aguardando conexão (1 segundo)...")
            await asyncio.sleep(1)
            
            logger.info(f"Status de conexão: {self.is_connected}")
            return self.is_connected
            
        except OSError as e:
            logger.error(f"❌ Erro de rede conectando ao MQTT: {e}")
            logger.error(f"   Verifique se o Mosquitto está instalado e rodando")
            logger.error(f"   Comando para verificar: sudo systemctl status mosquitto")
            self.is_connected = False
            return False
        except Exception as e:
            logger.error(f"❌ Erro inesperado conectando simulador: {e}")
            import traceback
            logger.error(traceback.format_exc())
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
        """Publica status do dispositivo conforme v2.2.0"""
        if not self.mqtt_client:
            return
            
        payload = create_relay_payload(
            device_uuid=self.device_uuid,
            board_id=self.board_id,
            status=status,
            channels=self.total_channels
        )
        
        try:
            self.mqtt_client.publish(
                self.status_topic,
                payload=json.dumps(payload),
                retain=True
            )
        except Exception as e:
            logger.error(f"Erro publicando status: {e}")
    
    def publish_relay_states(self):
        """Publica estado de todos os relés conforme v2.2.0"""
        if not self.mqtt_client:
            return
            
        payload = create_relay_payload(
            device_uuid=self.device_uuid,
            board_id=self.board_id,
            channels=self.channel_states
        )
        
        try:
            self.mqtt_client.publish(
                self.relay_state_topic,
                payload=json.dumps(payload),
                retain=True
            )
            
            # Notificar WebSocket clients se houver loop rodando
            try:
                loop = asyncio.get_running_loop()
                loop.create_task(self.notify_websockets({"type": "state_update", "states": self.channel_states}))
            except RuntimeError:
                # Não há loop assíncrono rodando, ignorar notificação WebSocket
                pass
            
        except Exception as e:
            logger.error(f"Erro publicando estados: {e}")
    
    async def set_relay_state(self, channel: int, state: bool, is_momentary: bool = False):
        """Define o estado de um relé"""
        logger.info(f"🔧 set_relay_state chamado: canal={channel}, state={state}, momentary={is_momentary}")
        
        if channel < 1 or channel > self.total_channels:
            logger.warning(f"Canal inválido: {channel} (range: 1-{self.total_channels})")
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
        logger.info(f"📊 Estado atual do canal {channel}: {old_state} -> Novo estado: {state}")
        
        if old_state != state:
            self.channel_states[channel] = state
            logger.info(f"✅ Estado alterado! Canal {channel}: {old_state} -> {state}")
            logger.info(f"📌 Estados atuais de todos os canais: {self.channel_states}")
            
            # Publicar estado atualizado
            self.publish_relay_states()
            
            # Publicar telemetria
            self.publish_telemetry(channel, state)
            
            logger.info(f"⚡ Relé {channel} -> {'ON' if state else 'OFF'}")
        else:
            logger.info(f"⏸️ Estado não mudou, canal {channel} já está {'ON' if state else 'OFF'}")
        
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
                        
                        # Notificar via telemetria especial conforme v2.2.0
                        safety_payload = create_relay_payload(
                            device_uuid=self.device_uuid,
                            board_id=self.board_id,
                            event="safety_shutoff",
                            channel=channel,
                            reason="heartbeat_timeout",
                            timeout=self.momentary_timeout
                        )
                        
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
        """Publica telemetria de mudança de estado conforme v2.2.0"""
        if not self.mqtt_client:
            return
            
        payload = create_relay_payload(
            device_uuid=self.device_uuid,
            board_id=self.board_id,
            event="relay_change",
            channel=channel,
            state=state,
            trigger="simulator"
        )
        
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
                    
                    logger.info(f"📨 Processando comando: {topic}")
                    logger.debug(f"Payload: {payload}")
                    
                    if topic.endswith("/relays/set"):
                        # Comando de relé conforme MQTT Architecture v2.1.0
                        channel = payload.get("channel")
                        state = payload.get("state")  # true/false ao invés de on/off
                        function_type = payload.get("function_type", "normal")
                        source = payload.get("user", "unknown")
                        
                        # Converter state (true/false) para command (on/off) para compatibilidade
                        command = "on" if state else "off"
                        
                        logger.info(f"⚡ Comando de relé recebido:")
                        logger.info(f"   📍 Canal: {channel} (tipo: {type(channel)})")
                        logger.info(f"   📍 Comando: {command}")
                        logger.info(f"   📍 Fonte: {source}")
                        logger.info(f"   📍 Payload completo: {payload}")
                        
                        if channel == "all":
                            # Comando para todos os relés
                            state = command == "on"
                            for ch in self.channel_states:
                                self.channel_states[ch] = state
                            logger.info(f"📌 Todos os relés -> {'ON' if state else 'OFF'}")
                        elif channel is not None:
                            # Comando para canal específico
                            # Converter para int se for string numérica
                            try:
                                ch = int(channel)
                                logger.info(f"🔢 Canal convertido para int: {ch}")
                            except (ValueError, TypeError):
                                logger.warning(f"❌ Canal inválido (não numérico): {channel}")
                                ch = None
                            
                            if ch and ch in self.channel_states:
                                logger.info(f"🎯 Canal {ch} encontrado nos estados. Executando comando: {command}")
                                if command == "on":
                                    logger.info(f"💡 Ligando canal {ch}")
                                    await self.set_relay_state(ch, True)
                                elif command == "off":
                                    logger.info(f"🔌 Desligando canal {ch}")
                                    await self.set_relay_state(ch, False)
                                elif command == "toggle":
                                    logger.info(f"🔄 Alternando canal {ch}")
                                    await self.toggle_relay(ch)
                                else:
                                    logger.warning(f"⚠️ Comando desconhecido: {command}")
                                logger.info(f"✅ Comando processado para canal {ch}")
                            else:
                                logger.warning(f"❌ Canal inválido ou fora do range: {ch}")
                                logger.warning(f"   Estados disponíveis: {list(self.channel_states.keys())}")
                        else:
                            logger.warning(f"⚠️ Canal é None no payload")
                        
                        # Sempre publicar estado após comando
                        logger.info("📡 Publicando estados atualizados...")
                        self.publish_relay_states()
                            
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
    
    def __init__(self, mqtt_host: str = None, mqtt_port: int = None):
        import os
        from dotenv import load_dotenv
        
        # Carregar variáveis de ambiente
        load_dotenv()
        
        # Usar valores do ambiente ou defaults
        self.mqtt_host = mqtt_host or os.getenv("MQTT_BROKER", "localhost")
        self.mqtt_port = mqtt_port or int(os.getenv("MQTT_PORT", "1883"))
        self.mqtt_username = os.getenv("MQTT_USERNAME")
        self.mqtt_password = os.getenv("MQTT_PASSWORD")
        
        self.simulators: Dict[int, RelayBoardSimulator] = {}
        self.running = False
        
        logger.info(f"RelaySimulatorManager configurado: {self.mqtt_host}:{self.mqtt_port}")
        
    async def create_simulator(self, board_id: int, device_uuid: str, total_channels: int = 16) -> RelayBoardSimulator:
        """Cria um novo simulador"""
        logger.info(f"RelaySimulatorManager.create_simulator chamado:")
        logger.info(f"  board_id: {board_id}")
        logger.info(f"  device_uuid: {device_uuid}")
        logger.info(f"  total_channels: {total_channels}")
        logger.info(f"  mqtt_host: {self.mqtt_host}")
        logger.info(f"  mqtt_port: {self.mqtt_port}")
        
        if board_id in self.simulators:
            logger.warning(f"Simulador já existe para board_id: {board_id}")
            return self.simulators[board_id]
        
        try:
            logger.info("Criando instância do RelayBoardSimulator...")
            simulator = RelayBoardSimulator(board_id, device_uuid, total_channels)
            logger.info("Instância criada com sucesso")
            
            logger.info(f"Tentando conectar ao MQTT em {self.mqtt_host}:{self.mqtt_port}...")
            connected = await simulator.connect(
                self.mqtt_host, 
                self.mqtt_port,
                self.mqtt_username,
                self.mqtt_password
            )
            
            if connected:
                logger.info("✅ Simulador conectado ao MQTT com sucesso!")
                self.simulators[board_id] = simulator
                
                # Iniciar loop do simulador
                logger.info("Iniciando loop do simulador...")
                asyncio.create_task(simulator.run())
                
                logger.info(f"Simulador adicionado à lista. Total de simuladores: {len(self.simulators)}")
                return simulator
            else:
                logger.error("❌ Falha ao conectar simulador ao MQTT")
                logger.error(f"   Verifique se o Mosquitto está rodando no host {self.mqtt_host}:{self.mqtt_port}")
                return None
                
        except Exception as e:
            logger.error(f"❌ Erro criando simulador: {e}")
            import traceback
            logger.error(traceback.format_exc())
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