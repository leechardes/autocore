"""
Modelos Pydantic para dispositivos
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class DeviceBase(BaseModel):
    """Modelo base para dispositivo"""
    uuid: str = Field(..., description="UUID único do dispositivo")
    name: str = Field(..., description="Nome do dispositivo")
    type: str = Field(..., description="Tipo do dispositivo")
    mac_address: Optional[str] = None
    ip_address: Optional[str] = None
    firmware_version: Optional[str] = None
    hardware_version: Optional[str] = None


class DeviceCreate(DeviceBase):
    """Modelo para criação de dispositivo"""
    pass


class DeviceUpdate(BaseModel):
    """Modelo para atualização de dispositivo"""
    name: Optional[str] = None
    ip_address: Optional[str] = None
    configuration: Optional[dict] = None


class DeviceResponse(DeviceBase):
    """Resposta com dados do dispositivo"""
    id: int
    status: str = "offline"
    last_seen: Optional[datetime] = None
    is_active: bool = True
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class AvailableDeviceResponse(BaseModel):
    """Dispositivo disponível para relés"""
    id: int
    uuid: str
    name: str
    type: str
    status: str