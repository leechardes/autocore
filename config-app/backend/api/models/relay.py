"""
Modelos Pydantic para relés
"""
from typing import Optional
from pydantic import BaseModel, Field


class RelayChannelResponse(BaseModel):
    """Resposta com dados de canal de relé"""
    id: int
    board_id: int
    channel_number: int
    name: str
    description: Optional[str] = None
    function_type: str = "toggle"
    current_state: bool = False
    icon: Optional[str] = None
    color: Optional[str] = None
    protection_mode: str = "none"


class RelayBoardCreate(BaseModel):
    """Modelo para criação de placa de relé"""
    device_id: int = Field(..., description="ID do dispositivo ESP32")
    name: str = Field(..., description="Nome da placa")
    total_channels: int = Field(default=16, ge=1, le=32, description="Número de canais")
    board_model: Optional[str] = Field(default="ESP32_16CH", description="Modelo da placa")
    location: Optional[str] = Field(default="", description="Localização da placa")


class RelayBoardResponse(BaseModel):
    """Resposta com dados da placa de relé"""
    id: int
    device_id: int
    name: str
    total_channels: int
    board_model: Optional[str] = None
    location: Optional[str] = None
    is_active: bool = True


class RelayChannelUpdate(BaseModel):
    """Modelo para atualização de canal"""
    name: Optional[str] = None
    description: Optional[str] = None
    function_type: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None
    protection_mode: Optional[str] = None
    default_state: Optional[bool] = None