"""
Modelos Pydantic para temas
"""
from typing import Optional
from pydantic import BaseModel


class ThemeResponse(BaseModel):
    """Resposta com dados de tema"""
    id: int
    name: str
    description: Optional[str] = None
    primary_color: str
    secondary_color: str
    background_color: str
    is_default: bool = False