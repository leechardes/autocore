"""
Modelos Pydantic para validação de dados
"""
from .device import DeviceBase, DeviceResponse, DeviceCreate, DeviceUpdate
from .relay import RelayChannelResponse, RelayBoardCreate, RelayBoardResponse
from .screen import ScreenResponse
from .theme import ThemeResponse
from .common import StatusResponse

__all__ = [
    # Device models
    "DeviceBase",
    "DeviceResponse", 
    "DeviceCreate",
    "DeviceUpdate",
    
    # Relay models
    "RelayChannelResponse",
    "RelayBoardCreate",
    "RelayBoardResponse",
    
    # UI models
    "ScreenResponse",
    "ThemeResponse",
    
    # Common models
    "StatusResponse"
]