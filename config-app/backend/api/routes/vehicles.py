"""
Vehicle Routes - Endpoints para gerenciamento do veículo único
Refatorado para trabalhar com apenas 1 registro único no sistema
"""

from fastapi import APIRouter, HTTPException, Depends, Query, status, Path
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
import sys
from pathlib import Path as PathLib
import logging
from datetime import datetime, timedelta

# Adiciona path para importar database  
sys.path.append(str(PathLib(__file__).parent.parent.parent.parent / "database"))

# Import repository
from shared.vehicle_repository import VehicleRepository, SessionLocal, create_vehicle_repository

# Import schemas - apenas schemas para registro único
from api.schemas.vehicle_schemas import (
    VehicleCreate, VehicleUpdate, VehicleResponse, VehicleOdometerUpdate, 
    VehicleLocationUpdate, VehicleStatusUpdate, VehicleMaintenanceUpdate, 
    VehicleDeviceAssignment, VehicleMaintenanceStatus, VehicleDocumentStatus,
    VehicleStatusSummary
)

# Configure logger
logger = logging.getLogger(__name__)

# Create router - usando singular para registro único
router = APIRouter(
    prefix="/api/vehicle",
    tags=["Vehicle"],
    responses={404: {"description": "Not found"}}
)

# ===================================
# DEPENDENCY INJECTION
# ===================================

def get_db():
    """Dependency para obter sessão do banco"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_vehicle_repository(db: Session = Depends(get_db)) -> VehicleRepository:
    """Dependency para obter repository do veículo único"""
    return VehicleRepository(db)

# ===================================
# BASIC CRUD ENDPOINTS
# ===================================

@router.get("", response_model=Optional[VehicleResponse])
async def get_vehicle(
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Retorna o único veículo cadastrado no sistema
    
    Retorna:
    - Objeto VehicleResponse com dados completos se existe
    - null se nenhum veículo estiver cadastrado
    
    Inclui informações sobre:
    - Dados básicos do veículo
    - Status de manutenção
    - Documentos e vencimentos
    - Device principal associado
    - Proprietário
    """
    try:
        logger.info("Getting unique vehicle")
        
        vehicle = repo.get_vehicle()
        
        if not vehicle:
            logger.info("No vehicle found")
            return None
        
        logger.info(f"Vehicle found with plate: {vehicle['plate']}")
        return VehicleResponse(**vehicle)
        
    except Exception as e:
        logger.error(f"Error getting vehicle: {e}")
        # Retorna None em vez de erro para manter compatibilidade
        return None

@router.post("", response_model=VehicleResponse, status_code=status.HTTP_201_CREATED)
async def create_or_update_vehicle(
    vehicle_data: VehicleCreate,
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Cria ou atualiza o único veículo do sistema
    
    - **plate**: Placa brasileira (ABC1234 ou ABC1D23)
    - **chassis**: Chassi de 17 caracteres
    - **renavam**: RENAVAM de 11 dígitos
    - **brand/model**: Marca e modelo obrigatórios
    - **category**: Categoria opcional (default: passenger)
    
    Se já existir um veículo, atualiza com os dados fornecidos.
    """
    try:
        logger.info(f"Creating/updating vehicle with plate: {vehicle_data.plate}")
        
        # Convert Pydantic model to dict
        vehicle_dict = vehicle_data.dict(exclude_none=True)
        
        # Remove user_id se existir (não necessário para registro único)
        vehicle_dict.pop('user_id', None)
        
        # Convert tags list to JSON string for database compatibility
        if 'tags' in vehicle_dict and isinstance(vehicle_dict['tags'], list):
            import json
            vehicle_dict['tags'] = json.dumps(vehicle_dict['tags'])
        
        # Create or update vehicle
        vehicle = repo.create_or_update_vehicle(vehicle_dict)
        
        # Commit transaction
        repo.session.commit()
        
        logger.info(f"Vehicle created/updated successfully")
        
        return VehicleResponse(**vehicle)
        
    except ValueError as e:
        logger.warning(f"Validation error creating/updating vehicle: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Error creating/updating vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro interno ao criar/atualizar veículo"
        )

@router.put("", response_model=VehicleResponse)
async def update_vehicle(
    vehicle_data: VehicleUpdate,
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Atualiza dados do único veículo do sistema
    
    - Aceita atualização parcial (apenas campos fornecidos)
    - Valida unicidade de placa, chassi e RENAVAM
    - Atualiza timestamps automaticamente
    - Se o veículo não existir, retorna erro 404
    """
    try:
        logger.info("Updating unique vehicle")
        
        # Check if vehicle exists first
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado para atualizar"
            )
        
        # Convert to dict excluding None values
        update_dict = vehicle_data.dict(exclude_none=True)
        
        if not update_dict:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Nenhum campo para atualizar foi fornecido"
            )
        
        # Update using create_or_update (will update existing)
        vehicle = repo.create_or_update_vehicle(update_dict)
        
        # Commit transaction
        repo.session.commit()
        
        logger.info("Vehicle updated successfully")
        
        return VehicleResponse(**vehicle)
        
    except ValueError as e:
        logger.warning(f"Validation error updating vehicle: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro interno ao atualizar veículo"
        )

@router.delete("")
async def delete_vehicle(
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Remove o único veículo do sistema (soft delete)
    
    - Marca veículo como inativo
    - Preserva histórico no banco
    - Remove associações com devices
    - Permite recriação posterior
    """
    try:
        logger.info("Deleting unique vehicle")
        
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado para remover"
            )
        
        success = repo.delete_vehicle()
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Erro ao remover veículo"
            )
        
        # Commit transaction
        repo.session.commit()
        
        logger.info("Vehicle deleted successfully")
        
        return {
            "message": "Veículo removido com sucesso",
            "plate": existing_vehicle.get('plate')
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao remover veículo"
        )

@router.delete("/reset")
async def reset_vehicle(
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Remove completamente o registro do veículo (hard delete)
    
    - Remove registro fisicamente do banco
    - Permite criação de novo veículo do zero
    - Perde todo histórico
    """
    try:
        logger.info("Resetting unique vehicle (hard delete)")
        
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        plate = existing_vehicle.get('plate') if existing_vehicle else None
        
        success = repo.reset_vehicle()
        
        # Commit transaction
        repo.session.commit()
        
        message = "Registro de veículo resetado com sucesso"
        if plate:
            message += f" (placa: {plate})"
        
        logger.info("Vehicle reset successfully")
        
        return {
            "message": message,
            "reset": True
        }
        
    except Exception as e:
        logger.error(f"Error resetting vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao resetar veículo"
        )

# ===================================
# SPECIALIZED ENDPOINTS
# ===================================

@router.get("/by-plate/{plate}", response_model=Optional[VehicleResponse])
async def get_vehicle_by_plate(
    plate: str = Path(..., description="Placa do veículo"),
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Busca veículo por placa
    
    - Aceita placa com ou sem formatação
    - Normaliza automaticamente (remove espaços e hífens)
    - Retorna null se placa não corresponder ao veículo único
    """
    try:
        vehicle = repo.get_vehicle_by_plate(plate)
        
        if not vehicle:
            logger.info(f"No vehicle found with plate: {plate}")
            return None
        
        return VehicleResponse(**vehicle)
        
    except Exception as e:
        logger.error(f"Error getting vehicle by plate {plate}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao buscar veículo por placa"
        )

@router.get("/status", response_model=VehicleStatusSummary)
async def get_vehicle_status(
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Retorna resumo do status do único veículo
    
    - Configuração: se existe veículo cadastrado
    - Manutenção: status e urgência
    - Documentos: vencimentos e alertas
    - Conexão: se está online
    """
    try:
        vehicle = repo.get_vehicle()
        
        if not vehicle:
            return VehicleStatusSummary(
                configured=False,
                has_vehicle=False,
                is_online=False
            )
        
        # Calculate maintenance status
        maintenance_status = None
        if vehicle.get('needs_maintenance'):
            maintenance_status = VehicleMaintenanceStatus(
                needs_maintenance=True,
                maintenance_urgency=vehicle.get('maintenance_urgency', 'normal')
            )
        
        # Calculate document status  
        document_status = None
        if vehicle.get('has_expired_documents'):
            document_status = VehicleDocumentStatus(
                has_expired_documents=True,
                expired_documents=[]  # TODO: Calculate from vehicle data
            )
        
        return VehicleStatusSummary(
            configured=True,
            has_vehicle=True,
            maintenance=maintenance_status,
            documents=document_status,
            is_online=vehicle.get('is_online', False),
            last_seen=vehicle.get('updated_at')
        )
        
    except Exception as e:
        logger.error(f"Error getting vehicle status: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao obter status do veículo"
        )

@router.put("/odometer", response_model=VehicleResponse)
async def update_odometer(
    odometer_data: VehicleOdometerUpdate,
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Atualiza quilometragem do único veículo
    
    - Valida que nova quilometragem não é menor que atual
    - Verifica se manutenção está vencida após atualização
    - Permite reset apenas com diferença significativa
    """
    try:
        logger.info(f"Updating odometer for unique vehicle to {odometer_data.odometer}")
        
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado para atualizar quilometragem"
            )
        
        vehicle_dict = repo.update_odometer(odometer_data.odometer)
        
        if not vehicle_dict:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Quilometragem {odometer_data.odometer} não pode ser menor que a atual ({existing_vehicle['odometer']})"
            )
        
        # Commit and return updated vehicle
        repo.session.commit()
        
        return VehicleResponse(**vehicle_dict)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating odometer for unique vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao atualizar quilometragem"
        )

@router.put("/location", response_model=VehicleResponse)
async def update_location(
    location_data: VehicleLocationUpdate,
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Atualiza localização do único veículo
    
    - Aceita coordenadas GPS
    - Armazena precisão e timestamp
    - Usado por dispositivos de rastreamento
    """
    try:
        logger.info("Updating location for unique vehicle")
        
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado para atualizar localização"
            )
        
        success = repo.update_location(
            latitude=location_data.latitude,
            longitude=location_data.longitude,
            accuracy=location_data.accuracy,
            timestamp=location_data.timestamp
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Erro ao atualizar localização"
            )
        
        # Commit and return updated vehicle
        repo.session.commit()
        vehicle = repo.get_vehicle()
        
        return VehicleResponse(**vehicle)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating location for unique vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao atualizar localização"
        )

@router.put("/status", response_model=VehicleResponse)
async def update_status(
    status_data: VehicleStatusUpdate,
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Atualiza status do único veículo
    
    - Status válidos: active, inactive, maintenance, retired, sold
    - Status 'retired' e 'sold' desativam o veículo automaticamente
    """
    try:
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado para atualizar status"
            )
        
        logger.info(f"Updating status for unique vehicle to {status_data.status}")
        
        success = repo.update_status(status_data.status.value)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Erro ao atualizar status"
            )
        
        # Commit and return updated vehicle
        repo.session.commit()
        vehicle = repo.get_vehicle()
        
        return VehicleResponse(**vehicle)
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating status for unique vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao atualizar status"
        )

# ===================================
# DEVICE MANAGEMENT
# ===================================

@router.post("/devices", response_model=Dict[str, Any])
async def assign_device(
    assignment: VehicleDeviceAssignment,
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Associa device ao único veículo
    
    - Roles disponíveis: primary, secondary, tracker
    - Device primary é usado para controle principal
    - Múltiplos devices secundários permitidos
    """
    try:
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado para associar device"
            )
        
        logger.info(f"Assigning device {assignment.device_id} to unique vehicle")
        
        success = repo.assign_device(
            device_id=assignment.device_id,
            role=assignment.role
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Device não encontrado"
            )
        
        repo.session.commit()
        
        return {
            "message": f"Device {assignment.device_id} associado ao veículo",
            "device_id": assignment.device_id,
            "role": assignment.role
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error assigning device to unique vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao associar device"
        )

@router.delete("/devices/{device_id}")
async def remove_device(
    device_id: int = Path(..., description="ID do device"),
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Remove associação entre o único veículo e device
    
    - Se for device primary, limpa a associação principal
    - Remove de todas as associações many-to-many
    """
    try:
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado"
            )
        
        logger.info(f"Removing device {device_id} from unique vehicle")
        
        success = repo.remove_device(device_id)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Device não encontrado ou não associado"
            )
        
        repo.session.commit()
        
        return {
            "message": f"Device {device_id} removido do veículo",
            "device_id": device_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error removing device from unique vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao remover device"
        )

@router.get("/devices", response_model=List[Dict[str, Any]])
async def get_vehicle_devices(
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Lista devices associados ao único veículo
    
    - Mostra device principal e secundários
    - Inclui status online/offline
    - Indica role de cada device
    """
    try:
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado"
            )
        
        devices = repo.get_vehicle_devices()
        return devices
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting devices for unique vehicle: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao listar devices do veículo"
        )

# ===================================
# MAINTENANCE & DOCUMENTS
# ===================================

@router.put("/maintenance", response_model=VehicleResponse)
async def update_maintenance(
    maintenance_data: VehicleMaintenanceUpdate,
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """
    Atualiza dados de manutenção do único veículo
    
    - Configura próxima manutenção por data ou km
    - Registra última manutenção realizada
    - Atualiza automaticamente status
    """
    try:
        logger.info("Updating maintenance for unique vehicle")
        
        # Check if vehicle exists
        existing_vehicle = repo.get_vehicle()
        if not existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Nenhum veículo cadastrado para atualizar manutenção"
            )
        
        maintenance_dict = maintenance_data.dict(exclude_none=True)
        
        success = repo.update_maintenance(maintenance_dict)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Erro ao atualizar dados de manutenção"
            )
        
        # Commit and return updated vehicle
        repo.session.commit()
        vehicle = repo.get_vehicle()
        
        return VehicleResponse(**vehicle)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating maintenance for unique vehicle: {e}")
        repo.session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao atualizar manutenção"
        )