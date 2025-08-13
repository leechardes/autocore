"""
Executor de Macros com integração MQTT
Processa e executa ações de macros enviando comandos reais via MQTT
"""
import json
import asyncio
import paho.mqtt.client as mqtt
from typing import Dict, List, Any
from datetime import datetime
import logging

# Importar protocolo v2.2.0
from protocol import create_base_payload, MQTT_PROTOCOL_VERSION

def create_mqtt_payload(**kwargs) -> Dict[str, Any]:
    """Cria payload conforme protocolo v2.2.0"""
    payload = {
        'protocol_version': MQTT_PROTOCOL_VERSION,
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        **kwargs
    }
    return payload

logger = logging.getLogger(__name__)

class MacroExecutor:
    def __init__(self, mqtt_broker="localhost", mqtt_port=1883):
        """Inicializa o executor de macros com cliente MQTT"""
        self.mqtt_client = mqtt.Client(client_id=f"macro_executor_{datetime.now().timestamp()}")
        self.mqtt_broker = mqtt_broker
        self.mqtt_port = mqtt_port
        self.connected = False
        
        # Configurar callbacks
        self.mqtt_client.on_connect = self._on_connect
        self.mqtt_client.on_disconnect = self._on_disconnect
        
        # Conectar ao broker
        self._connect()
    
    def _connect(self):
        """Conecta ao broker MQTT"""
        try:
            self.mqtt_client.connect(self.mqtt_broker, self.mqtt_port, 60)
            self.mqtt_client.loop_start()
            logger.info(f"Conectando ao MQTT broker {self.mqtt_broker}:{self.mqtt_port}")
        except Exception as e:
            logger.error(f"Erro conectando ao MQTT: {e}")
    
    def _on_connect(self, client, userdata, flags, rc):
        """Callback de conexão MQTT"""
        if rc == 0:
            self.connected = True
            logger.info("Macro Executor conectado ao MQTT")
        else:
            logger.error(f"Falha na conexão MQTT, código: {rc}")
    
    def _on_disconnect(self, client, userdata, rc):
        """Callback de desconexão MQTT"""
        self.connected = False
        logger.warning("Macro Executor desconectado do MQTT")
        if rc != 0:
            logger.info("Tentando reconectar...")
            self._connect()
    
    async def execute_macro(self, macro_id: int, macro_data: Dict, test_mode: bool = False):
        """
        Executa uma macro processando sua sequência de ações
        """
        logger.info(f"Executando macro {macro_id}: {macro_data.get('name')}")
        
        # Publicar início da execução
        self._publish_status(macro_id, "started", macro_data.get('name'))
        
        try:
            # Processar sequência de ações
            action_sequence = macro_data.get('action_sequence', [])
            
            # Se for string JSON, fazer parse
            if isinstance(action_sequence, str):
                action_sequence = json.loads(action_sequence)
            
            # Executar cada ação
            await self._execute_actions(macro_id, action_sequence, test_mode)
            
            # Publicar conclusão
            self._publish_status(macro_id, "completed", macro_data.get('name'))
            
            return {"status": "completed", "macro_id": macro_id}
            
        except Exception as e:
            logger.error(f"Erro executando macro {macro_id}: {e}")
            self._publish_status(macro_id, "error", macro_data.get('name'), str(e))
            raise
    
    async def _execute_actions(self, macro_id: int, actions: List[Dict], test_mode: bool = False):
        """Executa lista de ações"""
        for index, action in enumerate(actions):
            logger.debug(f"Executando ação {index + 1}/{len(actions)}: {action}")
            
            action_type = action.get('type')
            
            if action_type == 'relay':
                await self._execute_relay_action(action, test_mode)
            elif action_type == 'delay':
                await self._execute_delay_action(action)
            elif action_type == 'loop':
                await self._execute_loop_action(macro_id, action, test_mode)
            elif action_type == 'save_state':
                await self._execute_save_state(action)
            elif action_type == 'restore_state':
                await self._execute_restore_state(action)
            elif action_type == 'mqtt':
                await self._execute_mqtt_action(action)
            elif action_type == 'parallel':
                await self._execute_parallel_actions(macro_id, action, test_mode)
            elif action_type == 'log':
                await self._execute_log_action(action)
            else:
                logger.warning(f"Tipo de ação desconhecido: {action_type}")
    
    async def _execute_relay_action(self, action: Dict, test_mode: bool = False):
        """Executa ação de relé"""
        target = action.get('target')
        relay_action = action.get('action', 'toggle')
        label = action.get('label', '')
        
        # Converter target para lista se necessário
        if not isinstance(target, list):
            target = [target]
        
        for relay_id in target:
            # Por enquanto usando UUID fixo do simulador
            # TODO: Buscar UUID real do banco baseado no board_id
            device_uuid = "esp32-relay-001"  # UUID do simulador/dispositivo real
            
            # Tópico correto conforme MQTT_ARCHITECTURE.md v2.1.0
            topic = f"autocore/devices/{device_uuid}/relays/set"
            
            # Converter command para state conforme padrão documentado
            state = relay_action == "on" if relay_action in ["on", "off"] else None
            if relay_action == "toggle":
                state = None  # Toggle será tratado pelo function_type
            
            # Payload conforme MQTT Architecture v2.1.0
            payload = create_mqtt_payload(
                message_type="relay_command",
                uuid=device_uuid,
                channel=relay_id,  # Número do canal (1-16)
                state=state,
                function_type="toggle" if relay_action == "toggle" else "normal",
                user="macro_executor",
                label=label,
                test_mode=test_mode
            )
            
            logger.info(f"Enviando comando de relé: {topic} -> {payload}")
            self.mqtt_client.publish(topic, json.dumps(payload), qos=1)
            
            # Pequeno delay entre comandos para evitar sobrecarga
            await asyncio.sleep(0.05)
    
    async def _execute_delay_action(self, action: Dict):
        """Executa delay"""
        delay_ms = action.get('ms', 1000)
        logger.debug(f"Aguardando {delay_ms}ms")
        await asyncio.sleep(delay_ms / 1000.0)
    
    async def _execute_loop_action(self, macro_id: int, action: Dict, test_mode: bool = False):
        """Executa loop de ações"""
        count = action.get('count', 1)
        loop_actions = action.get('actions', [])
        
        if count == -1:
            # Loop infinito - por segurança, limitar a 100 iterações
            count = 100
            logger.warning("Loop infinito detectado, limitando a 100 iterações")
        
        for i in range(count):
            logger.debug(f"Loop iteração {i + 1}/{count}")
            await self._execute_actions(macro_id, loop_actions, test_mode)
    
    async def _execute_save_state(self, action: Dict):
        """Salva estado dos relés"""
        targets = action.get('targets', [])
        scope = action.get('scope', 'specific')
        
        topic = "autocore/system/state/save"
        payload = create_mqtt_payload(
            message_type='state_save',
            uuid='system',
            source='macro_executor',
            targets=targets,
            scope=scope
        )
        
        logger.info(f"Salvando estado: {payload}")
        self.mqtt_client.publish(topic, json.dumps(payload), qos=1)
    
    async def _execute_restore_state(self, action: Dict):
        """Restaura estado dos relés"""
        targets = action.get('targets', [])
        scope = action.get('scope', 'specific')
        
        topic = "autocore/system/state/restore"
        payload = create_mqtt_payload(
            message_type='state_restore',
            uuid='system',
            source='macro_executor',
            targets=targets,
            scope=scope
        )
        
        logger.info(f"Restaurando estado: {payload}")
        self.mqtt_client.publish(topic, json.dumps(payload), qos=1)
    
    async def _execute_mqtt_action(self, action: Dict):
        """Envia mensagem MQTT customizada"""
        topic = action.get('topic', 'autocore/gateway/macros/execute')
        original_payload = action.get('payload', {})
        qos = action.get('qos', 1)
        
        # Garantir conformidade com protocolo v2.2.0
        if isinstance(original_payload, dict):
            # Adicionar campos obrigatórios do protocolo
            payload = create_mqtt_payload(
                message_type='mode_change' if 'modes' in topic else 'custom',
                uuid='system',
                source='macro_executor',
                **original_payload
            )
        else:
            # Se não for dict, manter como está (pode ser string JSON já formatada)
            payload = original_payload
        
        if isinstance(payload, dict):
            payload = json.dumps(payload)
        
        logger.info(f"Enviando MQTT: {topic} -> {payload}")
        self.mqtt_client.publish(topic, payload, qos=qos)
    
    async def _execute_log_action(self, action: Dict):
        """Executa ação de log - apenas registra no logger"""
        message = action.get('message', 'Log action executada')
        level = action.get('level', 'info').lower()
        
        # Registrar no logger apropriado
        if level == 'debug':
            logger.debug(f"[MACRO LOG] {message}")
        elif level == 'warning' or level == 'warn':
            logger.warning(f"[MACRO LOG] {message}")
        elif level == 'error':
            logger.error(f"[MACRO LOG] {message}")
        else:
            logger.info(f"[MACRO LOG] {message}")
    
    async def _execute_parallel_actions(self, macro_id: int, action: Dict, test_mode: bool = False):
        """Executa ações em paralelo"""
        parallel_actions = action.get('actions', [])
        
        # Criar tasks para execução paralela
        tasks = []
        for parallel_action in parallel_actions:
            task = self._execute_actions(macro_id, [parallel_action], test_mode)
            tasks.append(task)
        
        # Aguardar todas as tasks
        await asyncio.gather(*tasks)
    
    def _publish_status(self, macro_id: int, status: str, name: str, error: str = None):
        """Publica status da execução da macro"""
        topic = f"autocore/macros/{macro_id}/status"
        payload = create_mqtt_payload(
            uuid="gateway-main-001",
            macro_id=macro_id,
            macro_name=name,
            status=status
        )
        
        if error:
            payload["error"] = error
        
        self.mqtt_client.publish(topic, json.dumps(payload), qos=1)
    
    def stop_macro(self, macro_id: int):
        """Para execução de uma macro"""
        # Por enquanto, apenas publica status de parada
        self._publish_status(macro_id, "stopped", "")
        logger.info(f"Macro {macro_id} parada")
    
    def __del__(self):
        """Desconecta do MQTT ao destruir o objeto"""
        if hasattr(self, 'mqtt_client'):
            self.mqtt_client.loop_stop()
            self.mqtt_client.disconnect()

# Instância global do executor
macro_executor = MacroExecutor()