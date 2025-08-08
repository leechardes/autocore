"""
Modelos Pydantic para telas
"""
from typing import Optional
from pydantic import BaseModel


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