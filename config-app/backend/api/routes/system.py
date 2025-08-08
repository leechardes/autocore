"""
Rotas do sistema (status, health check)
"""
from datetime import datetime
from fastapi import APIRouter, HTTPException

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent.parent.parent / "database"))

from shared.repositories import devices
from api.models.common import StatusResponse

router = APIRouter()


@router.get("/api/status", response_model=StatusResponse)
async def get_status():
    """Retorna status do sistema"""
    try:
        online_devices = devices.get_online_devices()
        return StatusResponse(
            status="online",
            version="2.0.0",
            database="connected",
            devices_online=len(online_devices),
            timestamp=datetime.now()
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))