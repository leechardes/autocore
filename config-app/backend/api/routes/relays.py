"""
Rotas para gerenciamento de relés
"""
from typing import List, Optional
from fastapi import APIRouter, HTTPException

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent.parent.parent / "database"))

from shared.repositories import devices, relays, events
from api.models.relay import RelayChannelResponse, RelayBoardCreate, RelayBoardResponse
from api.models.common import SuccessResponse
from utils.normalizers import compare_device_types

router = APIRouter()


@router.get("/relays/boards")
async def get_relay_boards():
    """Lista todas as placas de relé"""
    try:
        boards = relays.get_boards()
        return [
            {
                "id": b.id,
                "device_id": b.device_id,
                "name": b.name,
                "total_channels": b.total_channels,
                "board_model": b.board_model,
                "location": b.location,
                "is_active": b.is_active
            }
            for b in boards
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/relays/channels", response_model=List[RelayChannelResponse])
async def get_relay_channels(board_id: Optional[int] = None):
    """Lista canais de relé"""
    try:
        channels = relays.get_channels(board_id)
        return [
            RelayChannelResponse(
                id=c.id,
                board_id=c.board_id,
                channel_number=c.channel_number,
                name=c.name,
                description=c.description,
                function_type=c.function_type,
                current_state=c.current_state,
                icon=c.icon,
                color=c.color,
                protection_mode=c.protection_mode
            )
            for c in channels
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/relays/boards")
async def create_relay_board(board_data: RelayBoardCreate):
    """Cria nova placa de relé com canais automáticos"""
    try:
        # Verificar se dispositivo existe
        device = devices.get_by_id(board_data.device_id)
        if not device:
            raise HTTPException(status_code=404, detail="Dispositivo não encontrado")
        
        # Verificar se é ESP32_RELAY
        if not compare_device_types(device.type, 'esp32_relay'):
            raise HTTPException(status_code=400, detail="Dispositivo deve ser do tipo esp32_relay")
        
        # Verificar se device_id já tem placa cadastrada
        existing_boards = relays.get_boards_by_device(board_data.device_id)
        if existing_boards:
            raise HTTPException(
                status_code=400, 
                detail=f"Dispositivo '{device.name}' já possui uma placa de relé cadastrada"
            )
        
        # Criar placa (repository cria canais automaticamente)
        new_board = relays.create_board(board_data.model_dump())
        
        # Resposta simples
        return SuccessResponse(
            success=True,
            message=f"Placa '{board_data.name}' criada com {board_data.total_channels} canais"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro interno: {str(e)}")


@router.post("/relays/channels/{channel_id}/toggle")
async def toggle_relay_channel(channel_id: int):
    """Alterna estado de um canal de relé"""
    try:
        new_state = relays.toggle_channel(channel_id)
        
        return {"channel_id": channel_id, "new_state": new_state}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.patch("/relays/channels/{channel_id}")
async def update_relay_channel(channel_id: int, channel_data: dict):
    """Atualiza configurações de um canal de relé"""
    try:
        # Busca canal existente
        channel = relays.get_channel(channel_id)
        if not channel:
            raise HTTPException(status_code=404, detail="Canal não encontrado")
        
        # Atualiza canal
        result = relays.update_channel_config(channel_id, channel_data)
        if not result:
            raise HTTPException(status_code=400, detail="Erro ao atualizar canal")
        
        # Retorna canal atualizado
        updated_channel = relays.get_channel(channel_id)
        return {
            "id": updated_channel.id,
            "board_id": updated_channel.board_id,
            "channel_number": updated_channel.channel_number,
            "name": updated_channel.name,
            "description": updated_channel.description,
            "function_type": updated_channel.function_type,
            "current_state": updated_channel.current_state,
            "icon": updated_channel.icon,
            "color": updated_channel.color,
            "protection_mode": updated_channel.protection_mode
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))