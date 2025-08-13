"""
Device Manager para AutoCore Gateway
Gerencia estado, descoberta e comandos para dispositivos ESP32
"""
import asyncio
import json
import logging
from typing import Dict, Any, Optional, List
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
from enum import Enum
import sys
from pathlib import Path

# Adicionar path do database compartilhado
sys.path.append(str(Path(__file__).parent.parent.parent.parent / "database"))

from shared.repositories import devices, events

logger = logging.getLogger(__name__)

class DeviceStatus(Enum):
    """Status possíveis do dispositivo"""
    ONLINE = "online"
    OFFLINE = "offline"
    CONNECTING = "connecting" 
    ERROR = "error"
    UPDATING = "updating"

@dataclass
class DeviceInfo:
    """Informações do dispositivo"""
    uuid: str
    device_type: str
    firmware_version: str
    capabilities: List[str]
    status: DeviceStatus
    last_seen: datetime
    ip_address: Optional[str] = None
    mac_address: Optional[str] = None
    battery_level: Optional[float] = None
    signal_strength: Optional[int] = None
    uptime: Optional[int] = None
    free_memory: Optional[int] = None
    relay_count: Optional[int] = None
    errors: Optional[List[str]] = None

class DeviceManager:
    """Gerenciador de dispositivos do Gateway"""
    
    def __init__(self):
        self.devices: Dict[str, DeviceInfo] = {}
        self.command_queue = asyncio.Queue()
        self.pending_commands: Dict[str, Dict] = {}  # command_id -> command_data
        self.device_timeout = 300  # 5 minutos
        
        # Auto-registrar o gateway como dispositivo especial
        self._register_gateway()
        
        # Carregar dispositivos do database
        asyncio.create_task(self._load_devices_from_database())
    
    def _register_gateway(self):
        """Auto-registra o gateway como dispositivo especial"""
        gateway_info = DeviceInfo(
            uuid="autocore-gateway",
            device_type="gateway",
            firmware_version="2.2.0",
            capabilities=["mqtt", "websocket", "device_management", "telemetry", "can_bus"],
            status=DeviceStatus.ONLINE,
            last_seen=datetime.now(),
            ip_address="127.0.0.1",
            mac_address=None,
            battery_level=None,
            signal_strength=None,
            uptime=0,
            free_memory=None,
            relay_count=None,
            errors=None
        )
        
        self.devices["autocore-gateway"] = gateway_info
        
        # Também registrar no banco de dados se não existir
        try:
            existing = devices.get_by_uuid("autocore-gateway")
            if not existing:
                gateway_data = {
                    "uuid": "autocore-gateway",
                    "name": "AutoCore Gateway", 
                    "type": "gateway",
                    "firmware_version": "2.2.0",
                    "ip_address": "127.0.0.1",
                    "status": "online"
                }
                devices.create(gateway_data)
                logger.info("🌐 Gateway registrado no banco de dados")
            else:
                # Atualizar status para online
                devices.update_status(
                    device_id=existing.id,
                    status="online"
                )
        except Exception as e:
            logger.warning(f"⚠️ Não foi possível registrar gateway no banco: {e}")
            logger.warning(f"=== DETALHES COMPLETOS DO ERRO ===")
            logger.warning(f"Tipo de erro: {type(e).__name__}")
            logger.warning(f"Mensagem: {str(e)}")
            logger.warning(f"Tentando criar gateway com parâmetros:")
            logger.warning(f"  uuid: 'autocore-gateway'")
            logger.warning(f"  name: 'AutoCore Gateway'")
            logger.warning(f"  type: 'gateway'")
            logger.warning(f"  firmware_version: '2.2.0'")
            logger.warning(f"  ip_address: '127.0.0.1'")
            logger.warning(f"  status: 'online'")
            logger.warning(f"==================================")
        
        logger.info("🌐 Gateway auto-registrado como dispositivo especial")
    
    async def _load_devices_from_database(self):
        """Carrega dispositivos do database na inicialização"""
        try:
            db_devices = devices.get_all()
            logger.info(f"📂 Carregando {len(db_devices)} dispositivos do database")
            
            for device in db_devices:
                # Criar DeviceInfo com base nos dados do database
                device_info = DeviceInfo(
                    uuid=device.uuid,
                    device_type=device.type,  # Corrigido: usar 'type' ao invés de 'device_type'
                    firmware_version=device.firmware_version or "unknown",
                    capabilities=device.capabilities_json.split(',') if hasattr(device, 'capabilities_json') and device.capabilities_json else [],
                    status=DeviceStatus.OFFLINE,  # Assume offline até receber heartbeat
                    last_seen=device.last_seen or datetime.now(),
                    ip_address=device.ip_address,
                    mac_address=device.mac_address,
                    battery_level=None,  # Campo não existe no modelo
                    signal_strength=None,  # Campo não existe no modelo
                    relay_count=None  # Campo não existe no modelo
                )
                
                self.devices[device.uuid] = device_info
                
            logger.info(f"✅ {len(self.devices)} dispositivos carregados em memória")
            
        except Exception as e:
            logger.error(f"❌ Erro ao carregar dispositivos: {e}")
    
    async def handle_device_announce(self, device_uuid: str, device_data: Dict[str, Any], timestamp: datetime):
        """Processa anúncio de novo dispositivo"""
        try:
            logger.info(f"📢 Processando anúncio: {device_uuid}")
            
            # Extrair dados do dispositivo
            device_type = device_data.get('device_type', 'unknown')
            firmware_version = device_data.get('firmware_version', '1.0.0')
            capabilities = device_data.get('capabilities', [])
            ip_address = device_data.get('ip_address')
            mac_address = device_data.get('mac_address')
            
            # Criar ou atualizar DeviceInfo
            if device_uuid in self.devices:
                # Atualizar dispositivo existente
                device_info = self.devices[device_uuid]
                device_info.status = DeviceStatus.ONLINE
                device_info.last_seen = timestamp
                device_info.firmware_version = firmware_version
                device_info.capabilities = capabilities
                device_info.ip_address = ip_address
                device_info.mac_address = mac_address
                logger.info(f"🔄 Dispositivo atualizado: {device_uuid}")
            else:
                # Novo dispositivo
                device_info = DeviceInfo(
                    uuid=device_uuid,
                    device_type=device_type,
                    firmware_version=firmware_version,
                    capabilities=capabilities,
                    status=DeviceStatus.ONLINE,
                    last_seen=timestamp,
                    ip_address=ip_address,
                    mac_address=mac_address,
                    relay_count=device_data.get('relay_count', 0)
                )
                self.devices[device_uuid] = device_info
                logger.info(f"🆕 Novo dispositivo: {device_uuid}")
            
            # Salvar/atualizar no database
            await self._save_device_to_database(device_info)
            
            # Log evento
            events.log(
                event_type='device',
                source=device_uuid,
                action='announce',
                payload=device_data
            )
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar anúncio {device_uuid}: {e}")
    
    async def handle_device_status(self, device_uuid: str, status_data: Dict[str, Any], timestamp: datetime):
        """Processa status do dispositivo"""
        try:
            # Ignorar gateways antigos ou o próprio gateway
            if device_uuid.startswith('gateway-') or device_uuid == 'autocore-gateway':
                logger.debug(f"Ignorando status de gateway: {device_uuid}")
                return
                
            if device_uuid not in self.devices:
                logger.warning(f"⚠️ Status de dispositivo desconhecido: {device_uuid}")
                return
            
            device_info = self.devices[device_uuid]
            device_info.status = DeviceStatus.ONLINE
            device_info.last_seen = timestamp
            
            # Atualizar dados opcionais
            if 'battery_level' in status_data:
                device_info.battery_level = status_data['battery_level']
            if 'signal_strength' in status_data:
                device_info.signal_strength = status_data['signal_strength']
            if 'uptime' in status_data:
                device_info.uptime = status_data['uptime']
            if 'free_memory' in status_data:
                device_info.free_memory = status_data['free_memory']
            if 'errors' in status_data:
                device_info.errors = status_data['errors']
            
            # Log apenas se houver erros
            if device_info.errors:
                logger.warning(f"⚠️ Dispositivo {device_uuid} com erros: {device_info.errors}")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar status {device_uuid}: {e}")
    
    async def handle_relay_status(self, device_uuid: str, relay_data: Dict[str, Any]):
        """Processa status de relé"""
        try:
            if device_uuid not in self.devices:
                logger.warning(f"⚠️ Status de relé de dispositivo desconhecido: {device_uuid}")
                return
            
            device_info = self.devices[device_uuid]
            device_info.last_seen = datetime.now()
            device_info.status = DeviceStatus.ONLINE
            
            # Log evento de relé se necessário
            relay_states = relay_data.get('relay_states', [])
            if any(state.get('state') for state in relay_states):
                events.log(
                    event_type='relay',
                    source=device_uuid,
                    action='status_update',
                    payload=relay_data
                )
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar status de relé {device_uuid}: {e}")
    
    async def handle_command_response(self, device_uuid: str, command_id: str, success: bool, 
                                    error_message: Optional[str], response_data: Dict[str, Any], 
                                    timestamp: datetime):
        """Processa resposta de comando"""
        try:
            # Remover comando da lista de pendentes
            if command_id in self.pending_commands:
                command_info = self.pending_commands.pop(command_id)
                logger.debug(f"✅ Comando {command_id} respondido por {device_uuid}")
            else:
                logger.warning(f"⚠️ Resposta de comando desconhecido: {command_id}")
                return
            
            # Atualizar status do dispositivo
            if device_uuid in self.devices:
                self.devices[device_uuid].last_seen = timestamp
                self.devices[device_uuid].status = DeviceStatus.ONLINE
            
            # Log evento de resposta
            events.log(
                event_type='command',
                source=device_uuid,
                action='response',
                payload={
                    'command_id': command_id,
                    'success': success,
                    'error_message': error_message,
                    'response_data': response_data
                }
            )
            
            if not success and error_message:
                logger.warning(f"⚠️ Comando falhou em {device_uuid}: {error_message}")
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar resposta de comando: {e}")
    
    async def handle_device_discovery(self, discovery_data: Dict[str, Any], timestamp: datetime):
        """Processa descoberta de dispositivo na rede"""
        try:
            logger.info(f"🔍 Descoberta de dispositivo: {discovery_data}")
            
            # Processar dados de descoberta
            device_uuid = discovery_data.get('device_uuid')
            if device_uuid and device_uuid not in self.devices:
                # Dispositivo desconhecido descoberto na rede
                logger.info(f"🆕 Dispositivo desconhecido descoberto: {device_uuid}")
                
                # Log evento de descoberta
                events.log(
                    event_type='discovery',
                    source='gateway',
                    action='device_found',
                    payload=discovery_data
                )
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar descoberta: {e}")
    
    async def get_devices_by_type(self, device_type: str) -> List[Dict[str, Any]]:
        """Retorna dispositivos de um tipo específico"""
        result = []
        try:
            # Buscar no database
            all_devices = devices.get_all(active_only=True)
            for device in all_devices:
                if device.type == device_type:
                    result.append({
                        'uuid': device.uuid,
                        'name': device.name,
                        'type': device.type,
                        'status': device.status,
                        'id': device.id
                    })
            
            logger.debug(f"Encontrados {len(result)} dispositivos do tipo {device_type}")
            return result
            
        except Exception as e:
            logger.error(f"❌ Erro ao buscar dispositivos por tipo: {e}")
            return []
    
    async def send_relay_command(self, device_uuid: str, channel: Any, command: str, source: str = 'gateway'):
        """Envia comando de relé para dispositivo específico (conforme MQTT Architecture v2.1.0)"""
        try:
            # Converter command (on/off) para state (true/false) conforme documentação
            state = command == 'on' if command in ['on', 'off'] else (command == 'toggle')
            
            # Preparar payload conforme documentação MQTT_ARCHITECTURE.md
            payload = {
                'protocol_version': '2.1.0',
                'channel': channel,
                'state': state,
                'function_type': 'toggle' if command == 'toggle' else 'normal',
                'user': source,
                'timestamp': datetime.now().isoformat() + 'Z'
            }
            
            # Tópico correto conforme documentação: autocore/devices/{uuid}/relays/set
            topic = f'autocore/devices/{device_uuid}/relays/set'
            
            # Publicar comando via MQTT
            if hasattr(self, 'mqtt_client'):
                await self.mqtt_client.publish(topic, json.dumps(payload), qos=1)
                logger.info(f"📤 Comando de relé enviado: {device_uuid} canal {channel} -> {command}")
            else:
                logger.error("❌ Cliente MQTT não disponível no device_manager")
            
            # Log evento
            events.log(
                event_type='relay_command',
                source='gateway',
                action='send',
                target=device_uuid,
                payload=payload
            )
            
        except Exception as e:
            logger.error(f"❌ Erro ao enviar comando de relé: {e}")
    
    async def check_offline_devices(self):
        """Verifica dispositivos que ficaram offline"""
        try:
            now = datetime.now()
            offline_count = 0
            
            for device_uuid, device_info in self.devices.items():
                if device_info.status == DeviceStatus.ONLINE:
                    # Verificar se passou do timeout
                    if (now - device_info.last_seen).total_seconds() > self.device_timeout:
                        device_info.status = DeviceStatus.OFFLINE
                        offline_count += 1
                        logger.warning(f"📴 Dispositivo offline: {device_uuid}")
                        
                        # Log evento de offline
                        events.log(
                            event_type='device',
                            source=device_uuid,
                            action='offline',
                            payload={'timeout': self.device_timeout}
                        )
            
            if offline_count > 0:
                logger.info(f"📊 {offline_count} dispositivos marcados como offline")
                
        except Exception as e:
            logger.error(f"❌ Erro ao verificar dispositivos offline: {e}")
    
    async def _save_device_to_database(self, device_info: DeviceInfo):
        """Salva dispositivo no database"""
        try:
            device_data = {
                'uuid': device_info.uuid,
                'name': f"Device {device_info.device_type}",  # Nome padrão
                'type': device_info.device_type,  # Corrigido: campo 'type' ao invés de 'device_type'
                'firmware_version': device_info.firmware_version,
                'capabilities_json': ','.join(device_info.capabilities),  # capabilities_json ao invés de capabilities
                'ip_address': device_info.ip_address,
                'mac_address': device_info.mac_address,
                'last_seen': device_info.last_seen,
                'status': 'online' if device_info.status == DeviceStatus.ONLINE else 'offline'
            }
            
            # Verificar se existe
            existing_device = devices.get_by_uuid(device_info.uuid)
            if existing_device:
                devices.update(existing_device.id, device_data)
            else:
                devices.create(device_data)
                
        except Exception as e:
            logger.error(f"❌ Erro ao salvar dispositivo no database: {e}")
    
    def get_device_info(self, device_uuid: str) -> Optional[DeviceInfo]:
        """Retorna informações do dispositivo"""
        return self.devices.get(device_uuid)
    
    def get_online_devices(self) -> List[DeviceInfo]:
        """Retorna lista de dispositivos online"""
        return [device for device in self.devices.values() 
                if device.status == DeviceStatus.ONLINE]
    
    def get_all_devices(self) -> List[DeviceInfo]:
        """Retorna todos os dispositivos"""
        return list(self.devices.values())
    
    def get_stats(self) -> Dict[str, Any]:
        """Retorna estatísticas dos dispositivos"""
        total_devices = len(self.devices)
        online_devices = len(self.get_online_devices())
        
        return {
            'total_devices': total_devices,
            'online_devices': online_devices,
            'offline_devices': total_devices - online_devices,
            'pending_commands': len(self.pending_commands),
            'device_timeout_seconds': self.device_timeout
        }