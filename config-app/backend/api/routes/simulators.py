"""
API Routes para Simuladores de Dispositivos
"""
from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
from typing import List, Dict, Any
import logging
import sys
from pathlib import Path

# Adiciona path para importar do database
sys.path.append(str(Path(__file__).parent.parent.parent.parent.parent / "database"))

from shared.repositories import devices, relays
from simulators.relay_simulator import simulator_manager

router = APIRouter(prefix="/api/simulators", tags=["simulators"])
logger = logging.getLogger(__name__)

# ============================================
# RELAY SIMULATOR ENDPOINTS
# ============================================

@router.get("/relay/list")
async def list_relay_simulators():
    """Lista todos os simuladores de relé ativos"""
    return await simulator_manager.list_simulators()

@router.post("/relay/create/{board_id}")
async def create_relay_simulator(board_id: int):
    """Cria um novo simulador de placa de relé"""
    try:
        # Buscar dados da placa
        with relays as repo:
            boards = repo.get_boards()
            board = next((b for b in boards if b.id == board_id), None)
            
            if not board:
                raise HTTPException(status_code=404, detail="Placa não encontrada")
        
        # Buscar dados do dispositivo
        with devices as repo:
            device = repo.get_by_id(board.device_id)
            if not device:
                raise HTTPException(status_code=404, detail="Dispositivo não encontrado")
        
        # Criar simulador
        simulator = await simulator_manager.create_simulator(
            board_id=board.id,
            device_uuid=device.uuid,
            total_channels=board.total_channels
        )
        
        if simulator:
            return {
                "message": "Simulador criado com sucesso",
                "board_id": board.id,
                "device_uuid": device.uuid,
                "status": simulator.get_status()
            }
        else:
            raise HTTPException(status_code=500, detail="Erro criando simulador")
            
    except Exception as e:
        logger.error(f"Erro criando simulador: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/relay/{board_id}")
async def remove_relay_simulator(board_id: int):
    """Remove um simulador de placa de relé"""
    try:
        await simulator_manager.remove_simulator(board_id)
        return {"message": "Simulador removido com sucesso"}
    except Exception as e:
        logger.error(f"Erro removendo simulador: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/relay/{board_id}/status")
async def get_relay_simulator_status(board_id: int):
    """Obtém status de um simulador de relé"""
    simulator = await simulator_manager.get_simulator(board_id)
    if not simulator:
        raise HTTPException(status_code=404, detail="Simulador não encontrado")
    
    return simulator.get_status()

class SetChannelStateRequest(BaseModel):
    state: bool
    is_momentary: bool = False

@router.post("/relay/{board_id}/channel/{channel}/set")
async def set_relay_channel_state(board_id: int, channel: int, request: SetChannelStateRequest):
    """Define o estado de um canal de relé no simulador"""
    simulator = await simulator_manager.get_simulator(board_id)
    if not simulator:
        raise HTTPException(status_code=404, detail="Simulador não encontrado")
    
    success = await simulator.set_relay_state(channel, request.state, request.is_momentary)
    if success:
        return {
            "message": f"Canal {channel} definido para {'ON' if request.state else 'OFF'}",
            "channel": channel,
            "state": request.state
        }
    else:
        raise HTTPException(status_code=400, detail="Canal inválido")

@router.post("/relay/{board_id}/channel/{channel}/heartbeat")
async def heartbeat_relay_channel(board_id: int, channel: int):
    """Envia heartbeat para canal momentâneo"""
    simulator = await simulator_manager.get_simulator(board_id)
    if not simulator:
        raise HTTPException(status_code=404, detail="Simulador não encontrado")
    
    success = await simulator.heartbeat_relay(channel)
    if success:
        return {
            "message": f"Heartbeat recebido para canal {channel}",
            "channel": channel
        }
    else:
        raise HTTPException(status_code=400, detail="Canal inválido")

@router.post("/relay/{board_id}/channel/{channel}/toggle")
async def toggle_relay_channel(board_id: int, channel: int):
    """Alterna o estado de um canal de relé no simulador"""
    simulator = await simulator_manager.get_simulator(board_id)
    if not simulator:
        raise HTTPException(status_code=404, detail="Simulador não encontrado")
    
    success = await simulator.toggle_relay(channel)
    if success:
        new_state = simulator.channel_states[channel]
        return {
            "message": f"Canal {channel} alternado para {'ON' if new_state else 'OFF'}",
            "channel": channel,
            "state": new_state
        }
    else:
        raise HTTPException(status_code=400, detail="Canal inválido")

@router.post("/relay/{board_id}/reset")
async def reset_relay_simulator(board_id: int):
    """Reseta todos os canais de um simulador para OFF"""
    simulator = await simulator_manager.get_simulator(board_id)
    if not simulator:
        raise HTTPException(status_code=404, detail="Simulador não encontrado")
    
    # Reset todos os canais
    for channel in simulator.channel_states:
        simulator.channel_states[channel] = False
    
    await simulator.publish_relay_states()
    
    return {
        "message": "Todos os canais resetados",
        "board_id": board_id,
        "states": simulator.channel_states
    }

# ============================================
# WEBSOCKET ENDPOINT
# ============================================

@router.websocket("/relay/{board_id}/ws")
async def relay_simulator_websocket(websocket: WebSocket, board_id: int):
    """WebSocket para atualizações em tempo real do simulador"""
    await websocket.accept()
    
    simulator = await simulator_manager.get_simulator(board_id)
    if not simulator:
        await websocket.send_json({"error": "Simulador não encontrado"})
        await websocket.close()
        return
    
    # Adicionar cliente WebSocket ao simulador
    await simulator.add_websocket(websocket)
    
    try:
        while True:
            # Aguardar mensagens do cliente
            data = await websocket.receive_json()
            
            # Processar comandos via WebSocket
            command = data.get("command")
            
            if command == "set_state":
                channel = data.get("channel")
                state = data.get("state")
                if channel and state is not None:
                    await simulator.set_relay_state(channel, state)
                    
            elif command == "toggle":
                channel = data.get("channel")
                if channel:
                    await simulator.toggle_relay(channel)
                    
            elif command == "reset":
                for channel in simulator.channel_states:
                    simulator.channel_states[channel] = False
                await simulator.publish_relay_states()
                
            elif command == "get_status":
                await websocket.send_json({
                    "type": "status",
                    "data": simulator.get_status()
                })
                
    except WebSocketDisconnect:
        await simulator.remove_websocket(websocket)
        logger.info(f"WebSocket desconectado para board_id: {board_id}")
    except Exception as e:
        logger.error(f"Erro no WebSocket: {e}")
        await simulator.remove_websocket(websocket)

# ============================================
# BOARD DATA ENDPOINTS
# ============================================

@router.get("/relay/boards")
async def get_available_boards():
    """Lista placas de relé disponíveis para simulação"""
    try:
        with relays as repo:
            boards = repo.get_boards(active_only=True)
            
        with devices as repo:
            all_devices = {d.id: d for d in repo.get_all()}
        
        result = []
        for board in boards:
            device = all_devices.get(board.device_id)
            if device:
                # Verificar se já tem simulador ativo
                simulator = await simulator_manager.get_simulator(board.id)
                
                result.append({
                    "board_id": board.id,
                    "device_name": device.name,
                    "device_uuid": device.uuid,
                    "total_channels": board.total_channels,
                    "board_model": board.board_model,
                    "has_simulator": simulator is not None,
                    "simulator_connected": simulator.is_connected if simulator else False
                })
        
        return result
        
    except Exception as e:
        logger.error(f"Erro listando placas: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/relay/boards/{board_id}/channels")
async def get_board_channels_with_state(board_id: int):
    """Lista canais de uma placa com estado do simulador"""
    try:
        # Buscar canais da placa
        with relays as repo:
            channels = repo.get_channels(board_id=board_id)
        
        # Verificar se tem simulador ativo
        simulator = await simulator_manager.get_simulator(board_id)
        
        result = []
        for channel in channels:
            channel_data = {
                "id": channel.id,
                "channel_number": channel.channel_number,
                "name": channel.name,
                "description": channel.description,
                "icon": channel.icon,
                "color": channel.color,
                "function_type": channel.function_type,
                "protection_mode": channel.protection_mode,
                "allow_in_macro": getattr(channel, 'allow_in_macro', True),  # Campo novo com fallback
                "simulated_state": False
            }
            
            # Adicionar estado simulado se houver simulador
            if simulator and simulator.is_connected:
                channel_data["simulated_state"] = simulator.channel_states.get(channel.channel_number, False)
                channel_data["has_simulator"] = True
            else:
                channel_data["has_simulator"] = False
            
            result.append(channel_data)
        
        return result
        
    except Exception as e:
        logger.error(f"Erro listando canais: {e}")
        raise HTTPException(status_code=500, detail=str(e))