"""
Rotas da API organizadas por módulo
"""
from .devices import router as devices_router
from .relays import router as relays_router
from .system import router as system_router

__all__ = [
    "devices_router",
    "relays_router", 
    "system_router"
]