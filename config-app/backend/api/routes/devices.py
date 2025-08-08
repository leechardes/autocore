"""
Rotas para gerenciamento de dispositivos
"""
from typing import List
from fastapi import APIRouter, HTTPException

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent.parent.parent / "database"))

from shared.repositories import devices, relays
from api.models.device import (
    DeviceResponse, DeviceCreate, DeviceUpdate, 
    AvailableDeviceResponse
)

router = APIRouter()


@router.get("/devices", response_model=List[DeviceResponse])
async def get_devices():
    """Lista todos os dispositivos"""
    try:
        all_devices = devices.get_all()
        return [
            DeviceResponse(
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
                is_active=d.is_active,
                created_at=d.created_at,
                updated_at=d.updated_at
            )
            for d in all_devices
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/devices/available-for-relays", response_model=List[AvailableDeviceResponse])
async def get_available_relay_devices():
    """Lista dispositivos ESP32_RELAY disponíveis (sem placa cadastrada)"""
    try:
        # Buscar todos os dispositivos ESP32_RELAY
        all_devices = devices.get_all()
        relay_devices = [d for d in all_devices if d.type == 'esp32_relay']
        
        # Buscar device_ids que já têm placas de relé
        existing_boards = relays.get_boards()
        used_device_ids = {board.device_id for board in existing_boards}
        
        # Filtrar apenas dispositivos disponíveis
        available_devices = [
            AvailableDeviceResponse(
                id=d.id,
                uuid=d.uuid,
                name=d.name,
                type=d.type,
                status=d.status
            )
            for d in relay_devices 
            if d.id not in used_device_ids
        ]
        
        return available_devices
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/devices/{device_id}", response_model=DeviceResponse)
async def get_device(device_id: int):
    """Busca dispositivo por ID"""
    try:
        device = devices.get_by_id(device_id)
        if not device:
            raise HTTPException(status_code=404, detail="Dispositivo não encontrado")
        
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
            is_active=device.is_active,
            created_at=device.created_at,
            updated_at=device.updated_at
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/devices", response_model=DeviceResponse)
async def create_device(device: DeviceCreate):
    """Cria novo dispositivo"""
    try:
        new_device = devices.create(device.model_dump())
        
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