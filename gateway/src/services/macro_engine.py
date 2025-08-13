"""
Macro Engine - Sistema de execução de macros e automações
"""
import asyncio
import json
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime
from enum import Enum
import sys
from pathlib import Path

# Adiciona path para importar database
sys.path.append(str(Path(__file__).parent.parent.parent.parent / "database"))

from src.models.models import get_session, Macro
from shared.repositories import events
from ..mqtt.protocol import TOPIC_MACRO_EXECUTE, TOPIC_MACRO_STOP, TOPIC_MACRO_EMERGENCY_STOP, TOPIC_MACRO_STATUS, TOPIC_MACRO_EVENTS

logger = logging.getLogger(__name__)

class MacroState(Enum):
    """Estados possíveis de uma macro"""
    IDLE = "idle"
    RUNNING = "running"
    PAUSED = "paused"
    STOPPED = "stopped"
    ERROR = "error"
    COMPLETED = "completed"

class MacroAction:
    """Tipos de ações suportadas"""
    RELAY = "relay"
    DELAY = "delay"
    LOOP = "loop"
    SAVE_STATE = "save_state"
    RESTORE_STATE = "restore_state"
    MQTT = "mqtt"
    PARALLEL = "parallel"
    CONDITION = "condition"
    LOG = "log"

class MacroEngine:
    """Motor de execução de macros"""
    
    def __init__(self, mqtt_client=None):
        self.mqtt_client = mqtt_client
        self.running_macros: Dict[int, Dict] = {}  # {macro_id: state_info}
        self.saved_states: Dict[str, Dict] = {}  # Estados salvos para restauração
        self.heartbeat_tasks: Dict[int, asyncio.Task] = {}
        self.session = get_session()
        self._setup_mqtt_subscriptions()
    
    def _setup_mqtt_subscriptions(self):
        """Configura subscrições MQTT para comandos de macro"""
        if not self.mqtt_client:
            return
            
        # Subscrever aos tópicos de comando de macro
        topics = [
            TOPIC_MACRO_EXECUTE,
            TOPIC_MACRO_STOP,
            TOPIC_MACRO_EMERGENCY_STOP
        ]
        
        for topic in topics:
            self.mqtt_client.subscribe(topic, self._handle_mqtt_message)
            logger.info(f"Subscrito ao tópico: {topic}")
    
    async def _handle_mqtt_message(self, topic: str, payload: Dict):
        """Processa mensagens MQTT recebidas"""
        try:
            if topic == TOPIC_MACRO_EXECUTE:
                macro_id = payload.get('macro_id')
                if macro_id:
                    result = await self.start_macro(macro_id, payload)
                    logger.info(f"Comando execute para macro {macro_id}: {result}")
            
            elif topic == TOPIC_MACRO_STOP:
                macro_id = payload.get('macro_id')
                if macro_id:
                    result = await self.stop_macro(macro_id)
                    logger.info(f"Comando stop para macro {macro_id}: {result}")
            
            elif topic == TOPIC_MACRO_EMERGENCY_STOP:
                result = await self.handle_emergency_stop(payload)
                logger.warning(f"Comando emergency stop executado: {result}")
            
            else:
                logger.warning(f"Tópico MQTT não reconhecido: {topic}")
                
        except Exception as e:
            logger.error(f"Erro processando mensagem MQTT {topic}: {e}")
        
    async def start_macro(self, macro_id: int, context: Dict = None) -> Dict:
        """Inicia execução de uma macro"""
        try:
            # Buscar macro do banco
            macro = self.session.query(Macro).filter_by(id=macro_id, is_active=True).first()
            if not macro:
                raise ValueError(f"Macro {macro_id} não encontrada ou inativa")
            
            # Verificar se já está rodando
            if macro_id in self.running_macros:
                state = self.running_macros[macro_id]["state"]
                if state == MacroState.RUNNING:
                    return {"error": "Macro já está em execução"}
            
            # Preparar estado da macro
            macro_state = {
                "id": macro_id,
                "name": macro.name,
                "state": MacroState.RUNNING,
                "started_at": datetime.now(),
                "context": context or {},
                "current_action": 0,
                "preserve_state": False,
                "requires_heartbeat": False,
                "saved_state_key": f"macro_{macro_id}_{datetime.now().timestamp()}"
            }
            
            # Parsear configurações
            trigger_config = json.loads(macro.trigger_config or "{}")
            macro_state["preserve_state"] = trigger_config.get("preserve_state", False)
            macro_state["requires_heartbeat"] = trigger_config.get("requires_heartbeat", False)
            
            # Registrar estado
            self.running_macros[macro_id] = macro_state
            
            # Parsear ações
            actions = json.loads(macro.action_sequence)
            
            # Se deve preservar estado, salvar antes
            if macro_state["preserve_state"]:
                await self._save_current_state(macro_state["saved_state_key"], actions)
            
            # Iniciar heartbeat se necessário
            if macro_state["requires_heartbeat"]:
                self.heartbeat_tasks[macro_id] = asyncio.create_task(
                    self._monitor_heartbeat(macro_id)
                )
            
            # Executar ações
            asyncio.create_task(self._execute_actions(macro_id, actions))
            
            # Atualizar banco
            macro.last_executed = datetime.now()
            macro.execution_count += 1
            self.session.commit()
            
            # Publicar status via MQTT
            await self._publish_status(macro_id, "started")
            
            logger.info(f"Macro '{macro.name}' iniciada")
            return {"status": "started", "macro_id": macro_id}
            
        except Exception as e:
            logger.error(f"Erro iniciando macro {macro_id}: {e}")
            return {"error": str(e)}
    
    async def stop_macro(self, macro_id: int, restore_state: bool = True, reason: str = "user_requested") -> Dict:
        """Para execução de uma macro"""
        try:
            if macro_id not in self.running_macros:
                return {"error": "Macro não está em execução"}
            
            macro_state = self.running_macros[macro_id]
            
            # Parar heartbeat se existir
            if macro_id in self.heartbeat_tasks:
                self.heartbeat_tasks[macro_id].cancel()
                del self.heartbeat_tasks[macro_id]
            
            # Restaurar estado se configurado
            if restore_state and macro_state.get("preserve_state"):
                saved_key = macro_state.get("saved_state_key")
                if saved_key and saved_key in self.saved_states:
                    await self._restore_saved_state(saved_key)
            
            # Atualizar estado
            macro_state["state"] = MacroState.STOPPED
            macro_state["stopped_at"] = datetime.now()
            macro_state["stop_reason"] = reason
            
            # Publicar status
            await self._publish_status(macro_id, "stopped")
            
            # Remover dos ativos
            del self.running_macros[macro_id]
            
            logger.info(f"Macro {macro_id} parada (motivo: {reason})")
            return {"status": "stopped", "macro_id": macro_id, "reason": reason}
            
        except Exception as e:
            logger.error(f"Erro parando macro {macro_id}: {e}")
            return {"error": str(e)}
    
    async def heartbeat_macro(self, macro_id: int) -> Dict:
        """Recebe heartbeat de uma macro"""
        if macro_id not in self.running_macros:
            return {"error": "Macro não está em execução"}
        
        macro_state = self.running_macros[macro_id]
        macro_state["last_heartbeat"] = datetime.now()
        
        return {"status": "heartbeat_received"}
    
    async def _execute_actions(self, macro_id: int, actions: List[Dict]):
        """Executa sequência de ações de uma macro"""
        try:
            macro_state = self.running_macros[macro_id]
            
            for i, action in enumerate(actions):
                # Verificar se ainda deve executar
                if macro_state["state"] != MacroState.RUNNING:
                    break
                
                macro_state["current_action"] = i
                
                # Executar ação baseado no tipo
                action_type = action.get("type")
                
                if action_type == MacroAction.RELAY:
                    await self._execute_relay_action(action)
                    
                elif action_type == MacroAction.DELAY:
                    delay_ms = action.get("ms", 1000)
                    await asyncio.sleep(delay_ms / 1000)
                    
                elif action_type == MacroAction.LOOP:
                    count = action.get("count", 1)
                    loop_actions = action.get("actions", [])
                    for _ in range(count):
                        if macro_state["state"] != MacroState.RUNNING:
                            break
                        await self._execute_actions(macro_id, loop_actions)
                    
                elif action_type == MacroAction.SAVE_STATE:
                    targets = action.get("targets", [])
                    scope = action.get("scope", "specific")
                    await self._save_current_state(f"action_{i}", targets, scope)
                    
                elif action_type == MacroAction.RESTORE_STATE:
                    key = action.get("key", f"action_{i}")
                    await self._restore_saved_state(key)
                    
                elif action_type == MacroAction.MQTT:
                    topic = action.get("topic")
                    payload = action.get("payload")
                    await self._publish_mqtt(topic, payload)
                    
                elif action_type == MacroAction.PARALLEL:
                    parallel_actions = action.get("actions", [])
                    tasks = [
                        self._execute_actions(macro_id, [a]) 
                        for a in parallel_actions
                    ]
                    await asyncio.gather(*tasks)
                    
                elif action_type == MacroAction.LOG:
                    message = action.get("message", "")
                    logger.info(f"Macro {macro_id} log: {message}")
                    
                else:
                    logger.warning(f"Tipo de ação desconhecido: {action_type}")
            
            # Macro completada
            if macro_state["state"] == MacroState.RUNNING:
                macro_state["state"] = MacroState.COMPLETED
                macro_state["completed_at"] = datetime.now()
                
                # Restaurar estado se configurado
                if macro_state.get("preserve_state"):
                    saved_key = macro_state.get("saved_state_key")
                    if saved_key and saved_key in self.saved_states:
                        await self._restore_saved_state(saved_key)
                
                await self._publish_status(macro_id, "completed")
                
                # Limpar
                if macro_id in self.running_macros:
                    del self.running_macros[macro_id]
                
        except Exception as e:
            logger.error(f"Erro executando macro {macro_id}: {e}")
            macro_state["state"] = MacroState.ERROR
            macro_state["error"] = str(e)
            await self._publish_status(macro_id, "error", str(e))
    
    async def _execute_relay_action(self, action: Dict):
        """Executa ação de relé"""
        target = action.get("target")
        relay_action = action.get("action")  # on, off, toggle
        
        # Determinar canais alvo
        channels = []
        if target == "all":
            channels = list(range(1, 17))  # Assumindo 16 canais
        elif isinstance(target, list):
            channels = target
        else:
            channels = [int(target)]
        
        # Publicar comando para cada canal
        for channel in channels:
            payload = {
                "channel": channel,
                "state": relay_action == "on",
                "source": "macro_engine"
            }
            
            if relay_action == "toggle":
                # Para toggle, precisamos saber o estado atual
                # Por hora, apenas alterna
                payload["action"] = "toggle"
            
            topic = f"autocore/devices/esp32-relay-001/relays/set"
            await self._publish_mqtt(topic, payload)
            
            # Pequeno delay entre comandos
            await asyncio.sleep(0.05)
    
    async def _save_current_state(self, key: str, targets: List = None, scope: str = "specific"):
        """Salva estado atual dos dispositivos"""
        state_data = {
            "timestamp": datetime.now().isoformat(),
            "relays": {}
        }
        
        # TODO: Implementar leitura do estado atual via MQTT
        # Por hora, apenas registra
        logger.info(f"Estado salvo com chave: {key}")
        self.saved_states[key] = state_data
    
    async def _restore_saved_state(self, key: str):
        """Restaura estado salvo anteriormente"""
        if key not in self.saved_states:
            logger.warning(f"Estado {key} não encontrado")
            return
        
        state_data = self.saved_states[key]
        
        # TODO: Implementar restauração via MQTT
        logger.info(f"Estado {key} restaurado")
        
        # Limpar estado salvo
        del self.saved_states[key]
    
    async def _publish_mqtt(self, topic: str, payload: Any):
        """Publica mensagem MQTT"""
        if not self.mqtt_client:
            logger.warning("Cliente MQTT não configurado")
            return
        
        # Garantir conformidade com protocolo v2.2.0
        if isinstance(payload, dict):
            payload['protocol_version'] = '2.2.0'
            payload['uuid'] = 'gateway-main-001'
            payload['timestamp'] = datetime.now().isoformat() + 'Z'
            payload = json.dumps(payload)
        
        self.mqtt_client.publish(topic, payload)
        logger.debug(f"MQTT publicado: {topic}")
    
    async def _publish_status(self, macro_id: int, status: str, error: str = None):
        """Publica status da macro via MQTT"""
        payload = {
            "macro_id": macro_id,
            "status": status,
        }
        
        if error:
            payload["error"] = error
        
        if macro_id in self.running_macros:
            macro_state = self.running_macros[macro_id]
            payload["name"] = macro_state["name"]
            payload["current_action"] = macro_state.get("current_action", 0)
            payload["started_at"] = macro_state["started_at"].isoformat() + 'Z'
            
            # Calcular total de ações se disponível
            if status in ["running", "completed"]:
                try:
                    macro = self.session.query(Macro).filter_by(id=macro_id).first()
                    if macro:
                        actions = json.loads(macro.action_sequence)
                        payload["total_actions"] = len(actions)
                except Exception as e:
                    logger.warning(f"Erro ao obter total de ações para macro {macro_id}: {e}")
        
        # Usar tópico correto conforme MQTT_ARCHITECTURE.md
        topic = TOPIC_MACRO_STATUS.format(macro_id)
        await self._publish_mqtt(topic, payload)
        
        # Registrar evento
        events.create_event(
            event_type="macro_status",
            description=f"Macro {macro_id} - {status}",
            data=json.dumps(payload)
        )
    
    async def _monitor_heartbeat(self, macro_id: int):
        """Monitora heartbeat de uma macro crítica"""
        timeout = 5.0  # 5 segundos sem heartbeat
        
        try:
            while macro_id in self.running_macros:
                await asyncio.sleep(1)
                
                macro_state = self.running_macros[macro_id]
                last_heartbeat = macro_state.get("last_heartbeat")
                
                if last_heartbeat:
                    elapsed = (datetime.now() - last_heartbeat).total_seconds()
                    if elapsed > timeout:
                        logger.warning(f"Timeout de heartbeat na macro {macro_id}")
                        await self.stop_macro(macro_id, restore_state=True)
                        break
                        
        except asyncio.CancelledError:
            logger.info(f"Monitor de heartbeat cancelado para macro {macro_id}")
    
    def get_running_macros(self) -> List[Dict]:
        """Retorna lista de macros em execução"""
        return [
            {
                "id": macro_id,
                "name": state["name"],
                "state": state["state"].value,
                "started_at": state["started_at"].isoformat(),
                "current_action": state.get("current_action", 0)
            }
            for macro_id, state in self.running_macros.items()
        ]
    
    def get_macro_state(self, macro_id: int) -> Optional[Dict]:
        """Retorna estado de uma macro específica"""
        if macro_id not in self.running_macros:
            return None
        
        state = self.running_macros[macro_id]
        return {
            "id": macro_id,
            "name": state["name"],
            "state": state["state"].value,
            "started_at": state["started_at"].isoformat(),
            "current_action": state.get("current_action", 0),
            "requires_heartbeat": state.get("requires_heartbeat", False),
            "preserve_state": state.get("preserve_state", False)
        }
    
    async def handle_emergency_stop(self, payload: Dict = None):
        """Para todas as macros em execução imediatamente"""
        logger.warning("EMERGENCY STOP - Parando todas as macros")
        
        # Contar macros ativas antes de parar
        macros_count = len(self.running_macros)
        active_macro_ids = list(self.running_macros.keys())
        
        # Parar todas as macros em execução
        for macro_id in active_macro_ids:
            await self.stop_macro(macro_id, reason="emergency_stop")
        
        # Parar todos os heartbeat tasks
        for macro_id, task in list(self.heartbeat_tasks.items()):
            task.cancel()
            del self.heartbeat_tasks[macro_id]
        
        # Publicar evento de emergency stop
        event = {
            "event": "emergency_stop_executed",
            "macros_stopped": macros_count,
            "stopped_macro_ids": active_macro_ids,
            "reason": payload.get("reason", "user_requested") if payload else "user_requested"
        }
        
        await self._publish_mqtt(TOPIC_MACRO_EVENTS, event)
        
        logger.info(f"Emergency stop executado - {macros_count} macros paradas")
        return {"status": "emergency_stop_executed", "macros_stopped": macros_count}

# Instância global
macro_engine = MacroEngine()