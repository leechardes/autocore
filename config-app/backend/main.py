#!/usr/bin/env python3
"""
Config-App Backend - AutoCore
API para configuração e gerenciamento do sistema AutoCore
"""
import sys
from pathlib import Path
from typing import List, Optional
from contextlib import asynccontextmanager

# Adiciona path para importar database
sys.path.append(str(Path(__file__).parent.parent.parent / "database"))

from fastapi import FastAPI, HTTPException, Depends, status, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from datetime import datetime
import asyncio
import os
import logging
from dotenv import load_dotenv

# Configurar logger
logger = logging.getLogger(__name__)

# Carregar variáveis de ambiente
load_dotenv()

# Import repositories do database
from shared.repositories import devices, relays, telemetry, events, config

# Import MQTT Monitor
from services.mqtt_monitor import mqtt_monitor

# Import Routes  
from api.routes import simulators, macros
from api import mqtt_routes, protocol_routes

# ====================================
# CONFIGURAÇÃO
# ====================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Gerencia ciclo de vida da aplicação"""
    # Startup
    print("🚀 Config-App Backend iniciando...")
    print("📊 Conectado ao database AutoCore")
    
    # Conectar ao MQTT
    await mqtt_monitor.connect()
    print("📡 Monitor MQTT conectado")
    
    yield
    
    # Shutdown
    await mqtt_monitor.disconnect()
    print("👋 Config-App Backend encerrando...")

app = FastAPI(
    title="AutoCore Config API",
    description="API para configuração e gerenciamento do sistema AutoCore",
    version="2.0.0",
    lifespan=lifespan
)

# ====================================
# CORS
# ====================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especificar origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ====================================
# MODELOS PYDANTIC
# ====================================

class DeviceBase(BaseModel):
    """Modelo base para dispositivo"""
    uuid: str = Field(..., description="UUID único do dispositivo")
    name: str = Field(..., description="Nome do dispositivo")
    type: str = Field(..., description="Tipo do dispositivo")
    mac_address: Optional[str] = None
    ip_address: Optional[str] = None
    firmware_version: Optional[str] = None
    hardware_version: Optional[str] = None

class DeviceResponse(DeviceBase):
    """Resposta com dados do dispositivo"""
    id: int
    status: str = "offline"
    last_seen: Optional[datetime] = None
    location: Optional[str] = None  # Extraído do configuration_json
    configuration_json: Optional[str] = None  # JSON completo de configurações
    capabilities_json: Optional[str] = None  # JSON completo de capacidades
    is_active: bool = True
    created_at: datetime
    updated_at: datetime

class DeviceUpdate(BaseModel):
    """Modelo para atualização de dispositivo"""
    name: Optional[str] = None
    type: Optional[str] = None
    ip_address: Optional[str] = None
    mac_address: Optional[str] = None
    location: Optional[str] = None
    is_active: Optional[bool] = None
    configuration: Optional[dict] = None
    capabilities: Optional[dict] = None  # Para atualizar capabilities_json

class RelayChannelResponse(BaseModel):
    """Resposta com dados de canal de relé"""
    id: int
    board_id: int
    channel_number: int
    name: str
    description: Optional[str] = None
    function_type: str = "toggle"
    icon: Optional[str] = None
    color: Optional[str] = None
    protection_mode: str = "none"

class ScreenResponse(BaseModel):
    """Resposta com dados de tela"""
    id: int
    name: str
    title: str
    icon: Optional[str] = None
    screen_type: str
    position: int
    is_visible: bool = True
    items_count: Optional[int] = 0

class ThemeResponse(BaseModel):
    """Resposta com dados de tema"""
    id: int
    name: str
    description: Optional[str] = None
    primary_color: str
    secondary_color: str
    background_color: str
    is_default: bool = False

class StatusResponse(BaseModel):
    """Resposta de status do sistema"""
    status: str = "online"
    version: str = "2.0.0"
    database: str = "connected"
    devices_online: int = 0
    timestamp: datetime

class MQTTConfigResponse(BaseModel):
    """Configurações MQTT para dispositivos ESP32"""
    broker: str = "localhost"  # IP será sempre localhost (mesmo IP do backend)
    port: int = 1883
    username: Optional[str] = None
    password: Optional[str] = None
    topic_prefix: str = "autocore"

# ====================================
# ENDPOINTS - ROOT
# ====================================

@app.get("/", tags=["Root"])
async def root():
    """Endpoint raiz - verifica se API está funcionando"""
    return {
        "message": "AutoCore Config API",
        "version": "2.0.0",
        "status": "online",
        "docs": "/docs",
        "timestamp": datetime.now()
    }

@app.get("/api/health", tags=["System"])
async def health_check():
    """Health check endpoint para teste de conexão"""
    return {
        "status": "healthy",
        "service": "AutoCore Config API",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/status", response_model=StatusResponse, tags=["System"])
async def get_status():
    """Retorna status do sistema"""
    try:
        online_devices = devices.get_online_devices()
        return StatusResponse(
            status="online",
            version="2.0.0",
            database="connected",
            devices_online=len(online_devices),
            timestamp=datetime.now()
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ====================================
# ENDPOINTS - DEVICES
# ====================================

@app.get("/api/devices", response_model=List[DeviceResponse], tags=["Devices"])
async def get_devices():
    """Lista todos os dispositivos"""
    try:
        import json
        all_devices = devices.get_all()
        device_responses = []
        
        for d in all_devices:
            # Extrair location do configuration_json
            location = None
            if d.configuration_json:
                try:
                    config = json.loads(d.configuration_json)
                    location = config.get('location')
                except:
                    pass
            
            device_responses.append(DeviceResponse(
                id=d.id,
                uuid=d.uuid,
                name=d.name,
                type=d.type,
                mac_address=d.mac_address,
                ip_address=d.ip_address,
                firmware_version=d.firmware_version,
                hardware_version=d.hardware_version,
                status=d.status,
                last_seen=d.last_seen,
                location=location,
                configuration_json=d.configuration_json,
                capabilities_json=d.capabilities_json,
                is_active=d.is_active,
                created_at=d.created_at,
                updated_at=d.updated_at
            ))
        
        return device_responses
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/devices/available-for-relays", tags=["Devices"])
async def get_available_relay_devices():
    """Lista dispositivos ESP32_RELAY disponíveis (sem placa cadastrada)"""
    try:
        # Buscar todos os dispositivos ESP32_RELAY ativos
        all_devices = devices.get_all(active_only=True)
        relay_devices = [d for d in all_devices if d.type == 'esp32_relay' and d.is_active]
        
        # Buscar device_ids que já têm placas de relé
        existing_boards = relays.get_boards(active_only=True)
        used_device_ids = {board.device_id for board in existing_boards}
        
        # Filtrar apenas dispositivos disponíveis
        available_devices = [
            {
                "id": d.id,
                "uuid": d.uuid,
                "name": d.name,
                "type": d.type,
                "status": d.status
            }
            for d in relay_devices 
            if d.id not in used_device_ids
        ]
        
        return available_devices
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/devices/{device_id}", response_model=DeviceResponse, tags=["Devices"])
async def get_device(device_id: int):
    """Busca dispositivo por ID"""
    try:
        device = devices.get_by_id(device_id)
        if not device:
            raise HTTPException(status_code=404, detail="Dispositivo não encontrado")
        
        # Extrair location do configuration_json
        import json
        location = None
        if device.configuration_json:
            try:
                config = json.loads(device.configuration_json)
                location = config.get('location')
            except:
                pass
        
        return DeviceResponse(
            id=device.id,
            uuid=device.uuid,
            name=device.name,
            type=device.type,
            mac_address=device.mac_address,
            ip_address=device.ip_address,
            firmware_version=device.firmware_version,
            hardware_version=device.hardware_version,
            status=device.status,
            last_seen=device.last_seen,
            location=location,
            configuration_json=device.configuration_json,
            capabilities_json=device.capabilities_json,
            is_active=device.is_active,
            created_at=device.created_at,
            updated_at=device.updated_at
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/devices/uuid/{device_uuid}", response_model=DeviceResponse, tags=["Devices"])
async def get_device_by_uuid(device_uuid: str):
    """Busca dispositivo por UUID - usado pelo ESP32 para auto-registro"""
    try:
        device = devices.get_by_uuid(device_uuid)
        if not device:
            raise HTTPException(status_code=404, detail="Dispositivo não encontrado")
        
        # Extrair location do configuration_json
        import json
        location = None
        if device.configuration_json:
            try:
                config = json.loads(device.configuration_json)
                location = config.get('location')
            except:
                pass
        
        return DeviceResponse(
            id=device.id,
            uuid=device.uuid,
            name=device.name,
            type=device.type,
            mac_address=device.mac_address,
            ip_address=device.ip_address,
            firmware_version=device.firmware_version,
            hardware_version=device.hardware_version,
            status=device.status,
            last_seen=device.last_seen,
            location=location,
            configuration_json=device.configuration_json,
            capabilities_json=device.capabilities_json,
            is_active=device.is_active,
            created_at=device.created_at,
            updated_at=device.updated_at
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/devices", response_model=DeviceResponse, tags=["Devices"])
async def create_device(device: DeviceBase):
    """Cria novo dispositivo"""
    try:
        new_device = devices.create(device.model_dump())
        
        # Registra evento
        events.log(
            event_type="device",
            source="config-app",
            action="create",
            target=f"device_{new_device.id}",
            payload={"device_uuid": new_device.uuid}
        )
        
        return DeviceResponse(
            id=new_device.id,
            uuid=new_device.uuid,
            name=new_device.name,
            type=new_device.type,
            mac_address=new_device.mac_address,
            ip_address=new_device.ip_address,
            firmware_version=new_device.firmware_version,
            hardware_version=new_device.hardware_version,
            status=new_device.status,
            last_seen=new_device.last_seen,
            is_active=new_device.is_active,
            created_at=new_device.created_at,
            updated_at=new_device.updated_at
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.patch("/api/devices/{device_identifier}", response_model=DeviceResponse, tags=["Devices"])
async def update_device(device_identifier: str, update: DeviceUpdate):
    """Atualiza dispositivo - aceita ID numérico ou UUID"""
    try:
        # Log para debug do registro ESP32
        logger.info(f"📡 PATCH /api/devices/{device_identifier}")
        logger.info(f"   Payload recebido: {update.model_dump(exclude_none=True)}")
        
        # Tentar primeiro como ID numérico
        device = None
        device_id = None
        
        try:
            device_id = int(device_identifier)
            device = devices.get_by_id(device_id)
            logger.info(f"   Identificado como ID numérico: {device_id}")
        except ValueError:
            # Não é um número, tentar como UUID
            logger.info(f"   Identificado como UUID: {device_identifier}")
            device = devices.get_by_uuid(device_identifier)
            if device:
                device_id = device.id
                logger.info(f"   Device encontrado com ID: {device_id}")
        
        if not device:
            logger.warning(f"⚠️ Dispositivo não encontrado: {device_identifier}")
            raise HTTPException(status_code=404, detail=f"Dispositivo não encontrado: {device_identifier}")
        
        logger.info(f"   Device atual - Status: {device.status}, IP: {device.ip_address}")
        
        # Preparar configuração atualizada
        import json
        current_config = {}
        if device.configuration_json:
            try:
                current_config = json.loads(device.configuration_json)
            except Exception as e:
                logger.warning(f"   Erro ao parsear configuration_json existente: {e}")
                current_config = {}
        
        # Atualizar campos no configuration_json
        if update.location is not None:
            logger.info(f"   Atualizando location: {update.location}")
            current_config['location'] = update.location
        if update.type is not None:
            logger.info(f"   Atualizando type: {update.type}")
            current_config['device_type'] = update.type
            
        # Adicionar outros campos de configuração
        if update.configuration:
            logger.info(f"   Atualizando configuration: {update.configuration}")
            current_config.update(update.configuration)
        
        # Salvar configuração atualizada
        if current_config:
            logger.info(f"   Salvando configuration_json atualizado...")
            devices.update_config(device_id, current_config)
            logger.info(f"   ✅ Configuração salva")
        
        # Processar e salvar capacidades se fornecidas
        if update.capabilities is not None:
            logger.info(f"   Atualizando capabilities: {update.capabilities}")
            devices.update_capabilities(device_id, update.capabilities)
            logger.info(f"   ✅ Capacidades atualizadas")
        
        # Atualizar campos diretos na tabela
        if update.name:
            logger.info(f"   Atualizando nome: {update.name}")
            # TODO: Adicionar método update_name no repository
            pass
            
        if update.ip_address:
            logger.info(f"   Atualizando IP: {update.ip_address} e status: {device.status}")
            devices.update_status(device_id, device.status, update.ip_address)
            logger.info(f"   ✅ Status/IP atualizado")
        
        if update.is_active is not None:
            logger.info(f"   Atualizando is_active: {update.is_active}")
            # TODO: Adicionar método update_active no repository
            pass
        
        # Busca dispositivo atualizado
        device = devices.get_by_id(device_id)
        
        # Extrair location atualizada
        location = None
        if device.configuration_json:
            try:
                config = json.loads(device.configuration_json)
                location = config.get('location')
            except:
                pass
        
        logger.info(f"   ✅ Device {device_identifier} atualizado com sucesso")
        
        return DeviceResponse(
            id=device.id,
            uuid=device.uuid,
            name=device.name,
            type=device.type,
            mac_address=device.mac_address,
            ip_address=device.ip_address,
            firmware_version=device.firmware_version,
            hardware_version=device.hardware_version,
            status=device.status,
            last_seen=device.last_seen,
            location=location,
            configuration_json=device.configuration_json,
            capabilities_json=device.capabilities_json,
            is_active=device.is_active,
            created_at=device.created_at,
            updated_at=device.updated_at
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Erro ao atualizar device {device_identifier}: {e}")
        logger.error(f"   Tipo de erro: {type(e).__name__}")
        logger.error(f"   Detalhes: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/devices/{device_id}", tags=["Devices"])
async def delete_device(device_id: int):
    """Remove dispositivo (soft delete)"""
    try:
        device = devices.get_by_id(device_id)
        if not device:
            raise HTTPException(status_code=404, detail="Dispositivo não encontrado")
        
        devices.delete(device_id)
        
        return {"message": "Dispositivo removido com sucesso"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ====================================
# ENDPOINTS - RELAYS
# ====================================

@app.get("/api/relays/boards", tags=["Relays"])
async def get_relay_boards():
    """Lista todas as placas de relé ativas"""
    try:
        # Explicitamente buscar apenas placas ativas
        boards = relays.get_boards(active_only=True)
        # Filtrar placas que pertencem a dispositivos ativos
        active_device_ids = {d.id for d in devices.get_all(active_only=True)}
        active_boards = [b for b in boards if b.device_id in active_device_ids]
        
        # Buscar informações dos dispositivos para obter o nome
        all_devices = {d.id: d for d in devices.get_all()}
        
        return [
            {
                "id": b.id,
                "device_id": b.device_id,
                "name": all_devices.get(b.device_id).name if b.device_id in all_devices else f"Dispositivo {b.device_id}",
                "total_channels": b.total_channels,
                "board_model": b.board_model,
                "is_active": b.is_active
            }
            for b in active_boards
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/relays/channels", response_model=List[RelayChannelResponse], tags=["Relays"])
async def get_relay_channels(board_id: Optional[int] = None):
    """Lista canais de relé de placas e dispositivos ativos"""
    try:
        # Buscar canais
        channels = relays.get_channels(board_id)
        
        # Buscar placas ativas
        active_boards = relays.get_boards(active_only=True)
        active_board_ids = {b.id for b in active_boards}
        
        # Buscar dispositivos ativos
        active_devices = devices.get_all(active_only=True)
        active_device_ids = {d.id for d in active_devices}
        
        # Mapear board_id para device_id
        board_to_device = {b.id: b.device_id for b in active_boards}
        
        # Filtrar apenas canais de placas ativas que pertencem a dispositivos ativos
        active_channels = [
            c for c in channels 
            if c.board_id in active_board_ids 
            and board_to_device.get(c.board_id) in active_device_ids
        ]
        
        return [
            RelayChannelResponse(
                id=c.id,
                board_id=c.board_id,
                channel_number=c.channel_number,
                name=c.name,
                description=c.description,
                function_type=c.function_type,
                icon=c.icon,
                color=c.color,
                protection_mode=c.protection_mode
            )
            for c in active_channels
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Endpoints de toggle e set_state removidos - controle de estado será feito pelo gateway/dispositivos

@app.patch("/api/relays/channels/{channel_id}", tags=["Relays"])
async def update_relay_channel(channel_id: int, channel_data: dict):
    """Atualiza configurações de um canal de relé"""
    try:
        # Busca canal existente
        channel = relays.get_channel(channel_id)
        if not channel:
            raise HTTPException(status_code=404, detail="Canal não encontrado")
        
        # Atualiza apenas campos fornecidos
        result = relays.update_channel_config(channel_id, channel_data)
        if not result:
            raise HTTPException(status_code=400, detail="Erro ao atualizar canal")
        
        # Registra evento
        events.log(
            event_type="relay",
            source="config-app",
            action="update_config",
            target=f"channel_{channel_id}",
            payload=channel_data
        )
        
        # Retorna canal atualizado
        updated_channel = relays.get_channel(channel_id)
        return {
            "id": updated_channel.id,
            "board_id": updated_channel.board_id,
            "channel_number": updated_channel.channel_number,
            "name": updated_channel.name,
            "description": updated_channel.description,
            "function_type": updated_channel.function_type,
            "icon": updated_channel.icon,
            "color": updated_channel.color,
            "protection_mode": updated_channel.protection_mode
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/relays/channels/{channel_id}/reset", tags=["Relays"])
async def reset_relay_channel(channel_id: int):
    """Reseta configurações de um canal para valores padrão"""
    try:
        result = relays.reset_channel_config(channel_id)
        if not result:
            raise HTTPException(status_code=404, detail="Canal não encontrado")
        
        # Registra evento
        events.log(
            event_type="relay",
            source="config-app",
            action="reset_config",
            target=f"channel_{channel_id}"
        )
        
        # Retorna canal resetado
        updated_channel = relays.get_channel(channel_id)
        return {
            "id": updated_channel.id,
            "board_id": updated_channel.board_id,
            "channel_number": updated_channel.channel_number,
            "name": updated_channel.name,
            "description": updated_channel.description,
            "function_type": updated_channel.function_type,
            "icon": updated_channel.icon,
            "color": updated_channel.color,
            "protection_mode": updated_channel.protection_mode
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/relays/channels/{channel_id}", tags=["Relays"])
async def deactivate_relay_channel(channel_id: int):
    """Desativa um canal de relé (soft delete)"""
    try:
        result = relays.deactivate_channel(channel_id)
        if not result:
            raise HTTPException(status_code=404, detail="Canal não encontrado")
        
        # Registra evento
        events.log(
            event_type="relay",
            source="config-app",
            action="deactivate",
            target=f"channel_{channel_id}"
        )
        
        return {"message": f"Canal {channel_id} desativado com sucesso"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/relays/channels/{channel_id}/activate", tags=["Relays"])
async def activate_relay_channel(channel_id: int):
    """Reativa um canal de relé"""
    try:
        result = relays.activate_channel(channel_id)
        if not result:
            raise HTTPException(status_code=404, detail="Canal não encontrado")
        
        # Registra evento
        events.log(
            event_type="relay",
            source="config-app",
            action="activate",
            target=f"channel_{channel_id}"
        )
        
        # Retorna canal reativado
        updated_channel = relays.get_channel(channel_id)
        return {
            "id": updated_channel.id,
            "board_id": updated_channel.board_id,
            "channel_number": updated_channel.channel_number,
            "name": updated_channel.name,
            "description": updated_channel.description,
            "function_type": updated_channel.function_type,
            "icon": updated_channel.icon,
            "color": updated_channel.color,
            "protection_mode": updated_channel.protection_mode
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/relays/boards", tags=["Relays"])
async def create_relay_board(board_data: dict):
    """Cria nova placa de relé com canais automáticos"""
    try:
        # Validar campos obrigatórios
        if not board_data.get('device_id'):
            raise HTTPException(status_code=400, detail="device_id é obrigatório")
        
        # Converter device_id para int
        try:
            device_id = int(board_data['device_id'])
            board_data['device_id'] = device_id
        except (ValueError, TypeError):
            raise HTTPException(status_code=400, detail="device_id deve ser um número")
        
        # Verificar se dispositivo existe
        device = devices.get_by_id(device_id)
        if not device:
            raise HTTPException(status_code=404, detail="Dispositivo não encontrado")
        
        # Verificar se é ESP32_RELAY
        if device.type != 'esp32_relay':
            raise HTTPException(status_code=400, detail="Dispositivo deve ser do tipo esp32_relay")
        
        # Verificar se device_id já tem placa cadastrada
        existing_boards = relays.get_boards_by_device(device_id)
        if existing_boards:
            raise HTTPException(
                status_code=400, 
                detail=f"Dispositivo '{device.name}' já possui uma placa de relé cadastrada"
            )
        
        # Garantir que total_channels é int
        if 'total_channels' in board_data:
            try:
                board_data['total_channels'] = int(board_data['total_channels'])
            except (ValueError, TypeError):
                board_data['total_channels'] = 16  # Default
        else:
            board_data['total_channels'] = 16
        
        # Remover campo 'name' se existir (não é mais usado no banco)
        board_name = board_data.pop('name', f'Placa do {device.name}')
        
        # Criar placa (repository cria canais automaticamente)
        print(f"Criando placa com dados: {board_data}")
        new_board = relays.create_board(board_data)
        print(f"Placa criada!")
        
        # Resposta super simples sem acessar atributos da board
        response = {
            "success": True,
            "message": "Placa criada com sucesso",
            "name": board_name
        }
        print(f"Retornando resposta: {response}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        print(f"Erro ao criar placa: {e}")
        print(f"Traceback: {traceback.format_exc()}")
        print(f"Board data: {board_data}")
        raise HTTPException(status_code=500, detail=f"Erro interno: {str(e)}")

@app.patch("/api/relays/boards/{board_id}", tags=["Relays"])
async def update_relay_board(board_id: int, board_update: dict):
    """Atualiza uma placa de relé"""
    try:
        # Buscar a placa atual
        boards = relays.get_boards()
        board = next((b for b in boards if b.id == board_id), None)
        if not board:
            raise HTTPException(status_code=404, detail="Placa não encontrada")
        
        # Atualizar no banco usando SQL direto pois não temos método update_board
        with SessionLocal() as session:
            from src.models.models import RelayBoard
            db_board = session.query(RelayBoard).filter(RelayBoard.id == board_id).first()
            if db_board:
                # Remover campo 'name' se existir (não é mais usado)
                board_update.pop('name', None)
                if 'board_model' in board_update:
                    db_board.board_model = board_update['board_model']
                if 'total_channels' in board_update:
                    # Se mudar o número de canais, precisa recriar os canais
                    new_total = int(board_update['total_channels'])
                    if new_total != db_board.total_channels:
                        # Por enquanto, não permitir mudança no número de canais
                        raise HTTPException(status_code=400, detail="Não é possível alterar o número de canais após criação")
                session.commit()
                
                # Registra evento
                events.log(
                    event_type="relay",
                    source="config-app",
                    action="update_board",
                    target=f"board_{board_id}",
                    payload=board_update
                )
                
                return {"message": f"Placa {board_id} atualizada com sucesso"}
        
        raise HTTPException(status_code=500, detail="Erro ao atualizar placa")
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/relays/boards/{board_id}", tags=["Relays"])
async def delete_relay_board(board_id: int):
    """Desativa uma placa de relé e todos os seus canais"""
    try:
        # Desativar a placa e seus canais
        with SessionLocal() as session:
            from src.models.models import RelayBoard, RelayChannel
            
            # Desativar placa
            db_board = session.query(RelayBoard).filter(RelayBoard.id == board_id).first()
            if not db_board:
                raise HTTPException(status_code=404, detail="Placa não encontrada")
            
            db_board.is_active = False
            
            # Desativar todos os canais da placa
            session.query(RelayChannel).filter(
                RelayChannel.board_id == board_id
            ).update({"is_active": False})
            
            session.commit()
            
            # Registra evento
            events.log(
                event_type="relay",
                source="config-app",
                action="deactivate_board",
                target=f"board_{board_id}"
            )
            
            return {"message": f"Placa {board_id} e seus canais desativados com sucesso"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ====================================
# ENDPOINTS - SCREENS & UI
# ====================================

@app.get("/api/screens", tags=["UI"])
async def get_screens():
    """Lista todas as telas configuradas"""
    try:
        screens = config.get_screens()
        return [
            {
                "id": s.id,
                "name": s.name,
                "title": s.title,
                "icon": s.icon,
                "screen_type": s.screen_type,
                "parent_id": s.parent_id,
                "position": s.position,
                "columns_mobile": s.columns_mobile,
                "columns_display_small": s.columns_display_small,
                "columns_display_large": s.columns_display_large,
                "columns_web": s.columns_web,
                "is_visible": s.is_visible,
                "required_permission": s.required_permission,
                "show_on_mobile": s.show_on_mobile,
                "show_on_display_small": s.show_on_display_small,
                "show_on_display_large": s.show_on_display_large,
                "show_on_web": s.show_on_web,
                "show_on_controls": s.show_on_controls,
                "created_at": s.created_at
            }
            for s in screens
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/screens", tags=["UI"])
async def create_screen(screen_data: dict):
    """Cria nova tela"""
    try:
        new_screen = config.create_screen(screen_data)
        return {
            "id": new_screen.id,
            "name": new_screen.name,
            "title": new_screen.title,
            "message": "Tela criada com sucesso"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.patch("/api/screens/{screen_id}", tags=["UI"])
async def update_screen(screen_id: int, screen_data: dict):
    """Atualiza tela existente"""
    try:
        # TODO: Implementar update_screen no repository
        # Por enquanto, usar update genérico
        config.update_screen(screen_id, screen_data)
        return {"message": "Tela atualizada com sucesso"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/screens/{screen_id}", tags=["UI"])
async def delete_screen(screen_id: int):
    """Remove tela (e seus itens por CASCADE)"""
    try:
        # TODO: Implementar delete_screen no repository
        # Por enquanto, usar delete genérico
        config.delete_screen(screen_id)
        return {"message": "Tela removida com sucesso"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/screens/{screen_id}/items", tags=["UI"])
async def get_screen_items(screen_id: int):
    """Lista itens de uma tela"""
    try:
        items = config.get_screen_items(screen_id)
        return [
            {
                "id": i.id,
                "screen_id": i.screen_id,
                "item_type": i.item_type,
                "name": i.name,
                "label": i.label,
                "icon": i.icon,
                "position": i.position,
                "size_mobile": i.size_mobile,
                "size_display_small": i.size_display_small,
                "size_display_large": i.size_display_large,
                "size_web": i.size_web,
                "action_type": i.action_type,
                "action_target": i.action_target,
                "action_payload": i.action_payload,
                "relay_board_id": i.relay_board_id,
                "relay_channel_id": i.relay_channel_id,
                "data_source": i.data_source,
                "data_path": i.data_path,
                "data_format": i.data_format,
                "data_unit": i.data_unit,
                "is_active": i.is_active
            }
            for i in items
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/screens/{screen_id}/items", tags=["UI"])
async def create_screen_item(screen_id: int, item_data: dict):
    """Cria novo item para uma tela"""
    try:
        # Adiciona screen_id aos dados
        item_data['screen_id'] = screen_id
        
        # Criar item no banco
        new_item = config.create_screen_item(item_data)
        
        return {
            "id": new_item.id,
            "screen_id": new_item.screen_id,
            "item_type": new_item.item_type,
            "name": new_item.name,
            "label": new_item.label,
            "position": new_item.position,
            "message": "Item criado com sucesso"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.patch("/api/screens/{screen_id}/items/{item_id}", tags=["UI"])
async def update_screen_item(screen_id: int, item_id: int, item_data: dict):
    """Atualiza item de uma tela"""
    try:
        # Atualizar item no banco
        updated_item = config.update_screen_item(item_id, item_data)
        
        if not updated_item:
            raise HTTPException(status_code=404, detail="Item não encontrado")
        
        return {
            "id": updated_item.id,
            "screen_id": updated_item.screen_id,
            "item_type": updated_item.item_type,
            "name": updated_item.name,
            "label": updated_item.label,
            "position": updated_item.position,
            "message": "Item atualizado com sucesso"
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/screens/{screen_id}/items/{item_id}", tags=["UI"])
async def delete_screen_item(screen_id: int, item_id: int):
    """Remove item de uma tela"""
    try:
        # Deletar item do banco
        success = config.delete_screen_item(item_id)
        
        if not success:
            raise HTTPException(status_code=404, detail="Item não encontrado")
        
        return {"message": "Item removido com sucesso", "item_id": item_id}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/themes", response_model=List[ThemeResponse], tags=["UI"])
async def get_themes():
    """Lista temas disponíveis"""
    try:
        themes = config.get_themes()
        return [
            ThemeResponse(
                id=t.id,
                name=t.name,
                description=t.description,
                primary_color=t.primary_color,
                secondary_color=t.secondary_color,
                background_color=t.background_color,
                is_default=t.is_default
            )
            for t in themes
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/themes/default", response_model=ThemeResponse, tags=["UI"])
async def get_default_theme():
    """Retorna tema padrão"""
    try:
        theme = config.get_default_theme()
        if not theme:
            raise HTTPException(status_code=404, detail="Tema padrão não encontrado")
        
        return ThemeResponse(
            id=theme.id,
            name=theme.name,
            description=theme.description,
            primary_color=theme.primary_color,
            secondary_color=theme.secondary_color,
            background_color=theme.background_color,
            is_default=theme.is_default
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ====================================
# ENDPOINTS - TELEMETRY
# ====================================

@app.get("/api/telemetry/{device_id}", tags=["Telemetry"])
async def get_telemetry(device_id: int, limit: int = 100):
    """Busca telemetria de um dispositivo"""
    try:
        data = telemetry.get_latest(device_id, limit)
        return [
            {
                "id": t.id,
                "timestamp": t.timestamp,
                "data_type": t.data_type,
                "data_key": t.data_key,
                "data_value": t.data_value,
                "unit": t.unit
            }
            for t in data
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ====================================
# ENDPOINTS - EVENTS
# ====================================

@app.get("/api/events", tags=["Events"])
async def get_events(limit: int = 100):
    """Lista eventos recentes do sistema"""
    try:
        recent_events = events.get_recent(limit)
        return [
            {
                "id": e.id,
                "timestamp": e.timestamp,
                "event_type": e.event_type,
                "source": e.source,
                "target": e.target,
                "action": e.action,
                "status": e.status,
                "error_message": e.error_message
            }
            for e in recent_events
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ====================================
# ENDPOINTS - CONFIG GENERATOR
# ====================================

@app.get("/api/config/generate/{device_uuid}", tags=["Config"])
async def generate_config(device_uuid: str):
    """Gera configuração para um dispositivo ESP32"""
    try:
        device = devices.get_by_uuid(device_uuid)
        if not device:
            raise HTTPException(status_code=404, detail="Dispositivo não encontrado")
        
        # Gera configuração baseada no tipo do dispositivo
        if device.type == "esp32_relay":
            boards = relays.get_boards_by_device(device.id)
            channels = []
            for board in boards:
                board_channels = relays.get_channels(board.id)
                channels.extend([
                    {
                        "number": c.channel_number,
                        "name": c.name,
                        "type": c.function_type,
                        "default": c.default_state
                    }
                    for c in board_channels
                ])
            
            return {
                "device_uuid": device.uuid,
                "device_name": device.name,
                "device_type": device.type,
                "mqtt": {
                    "broker": "192.168.1.100",
                    "port": 1883,
                    "topic_prefix": f"autocore/{device.uuid}"
                },
                "relay_channels": channels
            }
        
        elif device.type == "esp32_display":
            screens_data = config.get_screens()
            return {
                "device_uuid": device.uuid,
                "device_name": device.name,
                "device_type": device.type,
                "mqtt": {
                    "broker": "192.168.1.100",
                    "port": 1883,
                    "topic_prefix": f"autocore/{device.uuid}"
                },
                "screens": [
                    {
                        "id": s.id,
                        "name": s.name,
                        "title": s.title,
                        "type": s.screen_type
                    }
                    for s in screens_data
                ]
            }
        
        else:
            # Configuração genérica
            return {
                "device_uuid": device.uuid,
                "device_name": device.name,
                "device_type": device.type,
                "mqtt": {
                    "broker": "192.168.1.100",
                    "port": 1883,
                    "topic_prefix": f"autocore/{device.uuid}"
                }
            }
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ====================================
# ENDPOINTS - CAN SIGNALS
# ====================================

@app.get("/api/can-signals", tags=["CAN"])
async def get_can_signals(category: Optional[str] = None):
    """Lista sinais CAN configurados"""
    try:
        signals = config.get_can_signals(category)
        return [
            {
                "id": s.id,
                "signal_name": s.signal_name,
                "can_id": s.can_id,
                "start_bit": s.start_bit,
                "length_bits": s.length_bits,
                "byte_order": s.byte_order,
                "data_type": s.data_type,
                "scale_factor": s.scale_factor,
                "offset": s.offset,
                "unit": s.unit,
                "min_value": s.min_value,
                "max_value": s.max_value,
                "description": s.description,
                "category": s.category,
                "is_active": s.is_active
            }
            for s in signals
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/can-signals/{signal_id}", tags=["CAN"])
async def get_can_signal(signal_id: int):
    """Busca sinal CAN por ID"""
    try:
        signal = config.get_can_signal_by_id(signal_id)
        if not signal:
            raise HTTPException(status_code=404, detail="Sinal CAN não encontrado")
        
        return {
            "id": signal.id,
            "signal_name": signal.signal_name,
            "can_id": signal.can_id,
            "start_bit": signal.start_bit,
            "length_bits": signal.length_bits,
            "byte_order": signal.byte_order,
            "data_type": signal.data_type,
            "scale_factor": signal.scale_factor,
            "offset": signal.offset,
            "unit": signal.unit,
            "min_value": signal.min_value,
            "max_value": signal.max_value,
            "description": signal.description,
            "category": signal.category,
            "is_active": signal.is_active
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/can-signals", tags=["CAN"])
async def create_can_signal(signal_data: dict):
    """Cria novo sinal CAN"""
    try:
        # Validar campos obrigatórios
        required = ['signal_name', 'can_id', 'start_bit', 'length_bits']
        for field in required:
            if field not in signal_data:
                raise HTTPException(status_code=400, detail=f"Campo {field} é obrigatório")
        
        new_signal = config.create_can_signal(signal_data)
        return {
            "id": new_signal.id,
            "signal_name": new_signal.signal_name,
            "message": "Sinal CAN criado com sucesso"
        }
    except HTTPException:
        raise
    except Exception as e:
        if "UNIQUE constraint failed" in str(e):
            raise HTTPException(status_code=400, detail="Já existe um sinal com esse nome")
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/api/can-signals/{signal_id}", tags=["CAN"])
async def update_can_signal(signal_id: int, signal_data: dict):
    """Atualiza sinal CAN"""
    try:
        updated_signal = config.update_can_signal(signal_id, signal_data)
        if not updated_signal:
            raise HTTPException(status_code=404, detail="Sinal CAN não encontrado")
        
        return {
            "id": updated_signal.id,
            "signal_name": updated_signal.signal_name,
            "message": "Sinal CAN atualizado com sucesso"
        }
    except HTTPException:
        raise
    except Exception as e:
        if "UNIQUE constraint failed" in str(e):
            raise HTTPException(status_code=400, detail="Já existe um sinal com esse nome")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/can-signals/{signal_id}", tags=["CAN"])
async def delete_can_signal(signal_id: int):
    """Remove sinal CAN"""
    try:
        success = config.delete_can_signal(signal_id)
        if not success:
            raise HTTPException(status_code=404, detail="Sinal CAN não encontrado")
        
        return {"message": "Sinal CAN removido com sucesso"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/can-signals/seed", tags=["CAN"])
async def seed_can_signals():
    """Popula banco com sinais CAN padrão"""
    try:
        count = config.seed_default_can_signals()
        if count == 0:
            return {"message": "Banco já possui sinais CAN configurados", "count": 0}
        
        return {
            "message": f"{count} sinais CAN padrão adicionados com sucesso",
            "count": count
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ====================================
# MQTT MONITOR
# ====================================

@app.websocket("/ws/mqtt")
async def websocket_mqtt_monitor(websocket: WebSocket):
    """WebSocket para streaming de mensagens MQTT em tempo real"""
    print(f"🔌 WebSocket connection attempt from: {websocket.client}")
    print(f"   Headers: {websocket.headers}")
    await mqtt_monitor.add_websocket(websocket)
    try:
        while True:
            # Manter conexão aberta
            data = await websocket.receive_text()
            
            # Se receber comando de publicação
            if data.startswith("PUBLISH:"):
                parts = data.split(":", 2)
                if len(parts) == 3:
                    topic = parts[1]
                    payload = parts[2]
                    success = await mqtt_monitor.publish(topic, payload)
                    await websocket.send_json({
                        "type": "publish_result",
                        "data": {
                            "success": success,
                            "topic": topic
                        }
                    })
    except WebSocketDisconnect:
        await mqtt_monitor.remove_websocket(websocket)

@app.get("/api/mqtt/config", response_model=MQTTConfigResponse, tags=["MQTT"])
async def get_mqtt_config():
    """Retorna configurações MQTT para dispositivos ESP32"""
    try:
        return MQTTConfigResponse(
            broker=os.getenv("MQTT_BROKER", "10.0.10.100"),  # Usa valor do .env
            port=int(os.getenv("MQTT_PORT", "1883")),
            username=os.getenv("MQTT_USERNAME"),
            password=os.getenv("MQTT_PASSWORD"),
            topic_prefix=os.getenv("MQTT_TOPIC_PREFIX", "autocore")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/mqtt/status", tags=["MQTT"])
async def get_mqtt_status():
    """Retorna status da conexão MQTT"""
    return mqtt_monitor.get_stats()

@app.post("/api/mqtt/clear", tags=["MQTT"])
async def clear_mqtt_history():
    """Limpa o histórico de mensagens MQTT"""
    mqtt_monitor.message_history.clear()
    return {"success": True, "message": "Histórico limpo"}

# Endpoint /api/mqtt/publish removido - está implementado em mqtt_routes.py

@app.get("/api/mqtt/topics", tags=["MQTT"])
async def get_mqtt_topics():
    """Retorna lista de tópicos MQTT do sistema"""
    return {
        "subscriptions": mqtt_monitor.subscriptions,
        "device_topics": {
            "announce": "autocore/devices/{device_uuid}/announce",
            "status": "autocore/devices/{device_uuid}/status",
            "telemetry": "autocore/devices/{device_uuid}/telemetry",
            "command": "autocore/devices/{device_uuid}/command",
            "response": "autocore/devices/{device_uuid}/response",
            "relay_status": "autocore/devices/{device_uuid}/relay/status"
        },
        "system_topics": {
            "gateway_status": "autocore/gateway/status",
            "discovery": "autocore/discovery/+",
            "broadcast": "autocore/system/broadcast"
        }
    }

# ====================================
# ROUTERS
# ====================================

# Registrar routers
app.include_router(simulators.router)
app.include_router(macros.router)
app.include_router(mqtt_routes.router)
app.include_router(protocol_routes.router)

# ====================================
# MAIN
# ====================================

if __name__ == "__main__":
    import uvicorn
    
    # Configurações do ambiente
    host = os.getenv("CONFIG_APP_HOST", "0.0.0.0")
    port = int(os.getenv("CONFIG_APP_PORT", "8081"))
    reload = os.getenv("ENV", "development") == "development"
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=reload,
        log_level="info",
        # Configurações para WebSocket
        ws_max_size=16777216,  # 16MB max message size
        ws_ping_interval=20,
        ws_ping_timeout=20
    )