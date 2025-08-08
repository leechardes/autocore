"""
Modelos Pydantic comuns
"""
from datetime import datetime
from pydantic import BaseModel


class StatusResponse(BaseModel):
    """Resposta de status do sistema"""
    status: str = "online"
    version: str = "2.0.0"
    database: str = "connected"
    devices_online: int = 0
    timestamp: datetime


class SuccessResponse(BaseModel):
    """Resposta de sucesso genérica"""
    success: bool = True
    message: str
    
    
class ErrorResponse(BaseModel):
    """Resposta de erro"""
    success: bool = False
    error: str
    detail: str = None