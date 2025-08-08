#!/usr/bin/env python3
"""
Config-App Backend - Versão Modular
API para configuração e gerenciamento do sistema AutoCore
"""
import sys
from pathlib import Path
from contextlib import asynccontextmanager

# Adiciona path para importar database
sys.path.append(str(Path(__file__).parent.parent.parent / "database"))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import repositories do database
from shared.repositories import devices, relays, telemetry, events, config

# ====================================
# CONFIGURAÇÃO
# ====================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Gerencia ciclo de vida da aplicação"""
    # Startup
    print("🚀 Config-App Backend (Modular) iniciando...")
    print("📊 Conectado ao database AutoCore")
    yield
    # Shutdown
    print("👋 Config-App Backend encerrando...")

app = FastAPI(
    title="AutoCore Config API",
    description="API para configuração e gerenciamento do sistema AutoCore",
    version="2.0.0",
    lifespan=lifespan
)

# ====================================
# CORS
# ====================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especificar origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ====================================
# ROTAS ORGANIZADAS
# ====================================

# Importar e registrar routers
from api.routes.system import router as system_router
from api.routes.devices import router as devices_router
from api.routes.relays import router as relays_router

app.include_router(system_router, tags=["System"])
app.include_router(devices_router, prefix="/api", tags=["Devices"])
app.include_router(relays_router, prefix="/api", tags=["Relays"])

# ====================================
# ROOT ENDPOINT
# ====================================

@app.get("/")
async def root():
    """Endpoint raiz - verifica se API está funcionando"""
    return {
        "message": "AutoCore Config API (Modular)",
        "version": "2.0.0",
        "status": "online",
        "docs": "/docs",
        "architecture": "modular"
    }

# ====================================
# MAIN
# ====================================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main_modular:app",
        host="0.0.0.0",
        port=8001,  # Porta diferente para testar
        reload=True,
        log_level="info"
    )