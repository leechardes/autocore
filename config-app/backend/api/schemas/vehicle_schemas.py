"""
Vehicle Schemas - Pydantic models para API de veículos
Implementa validações completas para dados de veículos
"""

from pydantic import BaseModel, Field, validator, root_validator
from typing import Optional, List, Dict, Any, Union
from datetime import datetime
from enum import Enum
import re

# ===================================
# ENUMS
# ===================================

class VehicleStatus(str, Enum):
    """Status do veículo"""
    ACTIVE = "active"
    INACTIVE = "inactive"
    MAINTENANCE = "maintenance"
    RETIRED = "retired"
    SOLD = "sold"

class FuelType(str, Enum):
    """Tipo de combustível"""
    FLEX = "flex"
    GASOLINE = "gasoline"
    ETHANOL = "ethanol"
    DIESEL = "diesel"
    ELECTRIC = "electric"
    HYBRID = "hybrid"

class VehicleCategory(str, Enum):
    """Categoria do veículo"""
    PASSENGER = "passenger"      # Passeio
    COMMERCIAL = "commercial"    # Comercial
    TRUCK = "truck"             # Caminhão
    MOTORCYCLE = "motorcycle"   # Moto
    BUS = "bus"                # Ônibus
    SPECIAL = "special"        # Especial

class UsageType(str, Enum):
    """Tipo de uso"""
    PERSONAL = "personal"      # Pessoal
    COMMERCIAL = "commercial"  # Comercial
    RENTAL = "rental"         # Aluguel
    FLEET = "fleet"           # Frota

class TransmissionType(str, Enum):
    """Tipo de transmissão"""
    MANUAL = "manual"
    AUTOMATIC = "automatic"
    CVT = "cvt"
    AUTOMATED = "automated"

# ===================================
# BASE SCHEMAS
# ===================================

class VehicleBase(BaseModel):
    """Schema base para veículo com validações"""
    
    # Identification
    plate: str = Field(..., min_length=7, max_length=8, description="Placa do veículo (ABC1234 ou ABC1D23)")
    chassis: str = Field(..., min_length=11, max_length=30, description="Número do chassi (11-30 caracteres)")
    renavam: str = Field(..., min_length=11, max_length=11, description="RENAVAM (11 dígitos)")
    
    # Basic info
    brand: str = Field(..., min_length=1, max_length=50, description="Marca do veículo")
    model: str = Field(..., min_length=1, max_length=100, description="Modelo do veículo")
    version: Optional[str] = Field(None, max_length=100, description="Versão/trim")
    year_manufacture: int = Field(..., ge=1900, le=2100, description="Ano de fabricação")
    year_model: int = Field(..., ge=1900, le=2100, description="Ano do modelo")
    color: Optional[str] = Field(None, max_length=50, description="Cor do veículo")
    color_code: Optional[str] = Field(None, max_length=20, description="Código da cor")
    
    # Technical
    fuel_type: FuelType = Field(..., description="Tipo de combustível")
    engine_capacity: Optional[float] = Field(None, ge=0.1, le=20.0, description="Cilindrada do motor (litros)")
    engine_power: Optional[int] = Field(None, ge=1, le=2000, description="Potência (cv)")
    engine_torque: Optional[int] = Field(None, ge=1, le=5000, description="Torque (Nm)")
    transmission: Optional[TransmissionType] = Field(None, description="Tipo de transmissão")
    category: Optional[VehicleCategory] = Field(default=VehicleCategory.PASSENGER, description="Categoria do veículo")
    usage_type: Optional[UsageType] = Field(UsageType.PERSONAL, description="Tipo de uso")
    
    @validator('plate')
    def validate_plate(cls, v):
        """Valida formato da placa brasileira"""
        if not v:
            raise ValueError("Placa é obrigatória")
        
        # Normalizar placa
        plate = v.upper().replace(' ', '').replace('-', '')
        
        # Validar formato brasileiro (ABC1234 ou ABC1D23)
        if not re.match(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$', plate):
            raise ValueError("Placa deve ter formato brasileiro válido (ABC1234 ou ABC1D23)")
        
        return plate
    
    @validator('chassis')
    def validate_chassis(cls, v):
        """Valida chassi (aceita formatos antigos e modernos)"""
        if not v:
            raise ValueError("Chassi é obrigatório")
        
        chassis = v.upper().strip().replace(' ', '').replace('-', '')
        
        # Aceitar 11 a 30 caracteres (veículos antigos têm formatos diferentes)
        if len(chassis) < 11 or len(chassis) > 30:
            raise ValueError("Chassi deve ter entre 11 e 30 caracteres")
        
        # Aceitar qualquer combinação alfanumérica (sem restrição de I, O, Q para veículos antigos)
        if not chassis.isalnum():
            raise ValueError("Chassi deve conter apenas letras e números")
        
        return chassis
    
    @validator('renavam')
    def validate_renavam(cls, v):
        """Valida RENAVAM"""
        if not v:
            raise ValueError("RENAVAM é obrigatório")
        
        renavam = re.sub(r'\D', '', str(v))  # Remove não-dígitos
        
        if len(renavam) != 11:
            raise ValueError("RENAVAM deve ter exatamente 11 dígitos")
        
        return renavam
    
    @validator('brand', 'model')
    def validate_text_fields(cls, v):
        """Valida campos de texto"""
        if v:
            return v.strip().title()
        return v
    
    @root_validator(skip_on_failure=True)
    def validate_years(cls, values):
        """Valida consistência dos anos"""
        year_manufacture = values.get('year_manufacture')
        year_model = values.get('year_model')
        
        if year_manufacture and year_model:
            if year_model < year_manufacture:
                raise ValueError("Ano do modelo não pode ser menor que ano de fabricação")
            if year_model > year_manufacture + 1:
                raise ValueError("Ano do modelo não pode ser mais de 1 ano posterior à fabricação")
        
        return values

class VehicleCreate(VehicleBase):
    """Schema para criação de veículo"""
    
    # Optional fields for creation
    uuid: Optional[str] = Field(None, description="UUID do veículo (gerado automaticamente)")
    status: Optional[VehicleStatus] = Field(VehicleStatus.ACTIVE, description="Status inicial")
    odometer: Optional[int] = Field(0, ge=0, description="Quilometragem inicial")
    odometer_unit: Optional[str] = Field("km", description="Unidade do odômetro")
    is_tracked: Optional[bool] = Field(False, description="Se o veículo será rastreado")
    notes: Optional[str] = Field(None, max_length=1000, description="Observações")
    tags: Optional[List[str]] = Field([], description="Tags do veículo")
    
    # Maintenance (optional on creation)
    next_maintenance_date: Optional[datetime] = Field(None, description="Próxima manutenção (data)")
    next_maintenance_km: Optional[int] = Field(None, ge=0, description="Próxima manutenção (km)")
    
    # Document expiry (optional on creation)  
    insurance_expiry: Optional[datetime] = Field(None, description="Vencimento do seguro")
    license_expiry: Optional[datetime] = Field(None, description="Vencimento do licenciamento")
    inspection_expiry: Optional[datetime] = Field(None, description="Vencimento da vistoria")

class VehicleUpdate(BaseModel):
    """Schema para atualização de veículo"""
    
    # Allow partial updates - all fields optional
    plate: Optional[str] = Field(None, min_length=7, max_length=8)
    chassis: Optional[str] = Field(None, min_length=11, max_length=30)
    renavam: Optional[str] = Field(None, min_length=11, max_length=11)
    
    brand: Optional[str] = Field(None, min_length=1, max_length=50)
    model: Optional[str] = Field(None, min_length=1, max_length=100)
    version: Optional[str] = Field(None, max_length=100)
    year_manufacture: Optional[int] = Field(None, ge=1900, le=2100)
    year_model: Optional[int] = Field(None, ge=1900, le=2100)
    color: Optional[str] = Field(None, max_length=50)
    color_code: Optional[str] = Field(None, max_length=20)
    
    fuel_type: Optional[FuelType] = None
    engine_capacity: Optional[float] = Field(None, ge=0.1, le=20.0)
    engine_power: Optional[int] = Field(None, ge=1, le=2000)
    engine_torque: Optional[int] = Field(None, ge=1, le=5000)
    transmission: Optional[TransmissionType] = None
    category: Optional[VehicleCategory] = None
    usage_type: Optional[UsageType] = None
    
    status: Optional[VehicleStatus] = None
    odometer: Optional[int] = Field(None, ge=0)
    is_tracked: Optional[bool] = None
    notes: Optional[str] = Field(None, max_length=1000)
    tags: Optional[List[str]] = None
    
    # Maintenance
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = Field(None, ge=0)
    last_maintenance_date: Optional[datetime] = None
    last_maintenance_km: Optional[int] = Field(None, ge=0)
    
    # Document expiry
    insurance_expiry: Optional[datetime] = None
    license_expiry: Optional[datetime] = None  
    inspection_expiry: Optional[datetime] = None
    
    # Device association
    primary_device_id: Optional[int] = None
    
    # Same validators as base class
    @validator('plate')
    def validate_plate(cls, v):
        if v is not None:
            plate = v.upper().replace(' ', '').replace('-', '')
            if not re.match(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$', plate):
                raise ValueError("Placa deve ter formato brasileiro válido")
            return plate
        return v
    
    @validator('chassis')
    def validate_chassis(cls, v):
        if v is not None:
            chassis = v.upper().strip().replace(' ', '').replace('-', '')
            if len(chassis) < 11 or len(chassis) > 30:
                raise ValueError("Chassi deve ter entre 11 e 30 caracteres")
            if not chassis.isalnum():
                raise ValueError("Chassi deve conter apenas letras e números")
            return chassis
        return v
    
    @validator('renavam')
    def validate_renavam(cls, v):
        if v is not None:
            renavam = re.sub(r'\D', '', str(v))
            if len(renavam) != 11:
                raise ValueError("RENAVAM deve ter exatamente 11 dígitos")
            return renavam
        return v

# ===================================
# RESPONSE SCHEMAS
# ===================================

# DeviceResponse and UserResponse removed - not used anymore

class VehicleResponse(BaseModel):
    """Resposta completa com dados do veículo único"""
    
    # Identification - ID sempre será 1
    id: int = Field(default=1, description="ID fixo para registro único")
    uuid: str
    plate: str
    chassis: str
    renavam: str
    
    # Basic info
    brand: str
    model: str
    version: Optional[str] = None
    year_manufacture: int
    year_model: int
    color: Optional[str] = None
    color_code: Optional[str] = None
    
    # Technical
    fuel_type: str
    engine_capacity: Optional[float] = None
    engine_power: Optional[int] = None
    engine_torque: Optional[int] = None
    transmission: Optional[str] = None
    category: str
    usage_type: Optional[str] = None
    
    # Status
    status: str
    odometer: int
    odometer_unit: str
    last_location: Optional[Dict[str, Any]] = None
    
    # Maintenance
    next_maintenance_date: Optional[str] = None
    next_maintenance_km: Optional[int] = None
    last_maintenance_date: Optional[str] = None
    last_maintenance_km: Optional[int] = None
    
    # Document expiry
    insurance_expiry: Optional[str] = None
    license_expiry: Optional[str] = None
    inspection_expiry: Optional[str] = None
    
    # System fields
    is_active: bool
    is_tracked: bool
    notes: Optional[str] = None
    tags: List[str] = []
    
    # Computed properties
    full_name: str
    age_years: int
    is_online: bool
    needs_maintenance: bool
    has_expired_documents: bool
    
    # Relationships removed - returning only vehicle table data
    
    # Timestamps (optional para compatibilidade)
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    
    class Config:
        from_attributes = True
        extra = "allow"  # Permite campos extras do banco

# Schemas de listagem removidos - trabalha apenas com registro único

# ===================================
# REQUEST SCHEMAS
# ===================================

class VehicleOdometerUpdate(BaseModel):
    """Schema para atualização de quilometragem"""
    odometer: int = Field(..., ge=0, description="Nova quilometragem")
    
    @validator('odometer')
    def validate_odometer(cls, v):
        if v < 0:
            raise ValueError("Quilometragem não pode ser negativa")
        return v

class VehicleLocationUpdate(BaseModel):
    """Schema para atualização de localização"""
    latitude: float = Field(..., ge=-90.0, le=90.0, description="Latitude")
    longitude: float = Field(..., ge=-180.0, le=180.0, description="Longitude")
    accuracy: Optional[int] = Field(None, ge=1, description="Precisão em metros")
    timestamp: Optional[datetime] = Field(None, description="Timestamp da localização")

class VehicleStatusUpdate(BaseModel):
    """Schema para atualização de status"""
    status: VehicleStatus = Field(..., description="Novo status do veículo")

class VehicleMaintenanceUpdate(BaseModel):
    """Schema para atualização de manutenção"""
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = Field(None, ge=0)
    last_maintenance_date: Optional[datetime] = None
    last_maintenance_km: Optional[int] = Field(None, ge=0)

class VehicleDeviceAssignment(BaseModel):
    """Schema para associação de device"""
    device_id: int = Field(..., description="ID do device")
    role: str = Field("secondary", description="Papel do device (primary, secondary, tracker)")

# ===================================
# QUERY PARAMETERS
# ===================================

# Parâmetros de query removidos - não há filtros nem busca para registro único

# ===================================
# BULK OPERATIONS - REMOVIDAS
# ===================================

# Operações em lote removidas - trabalha apenas com registro único

# ===================================
# SPECIALIZED RESPONSES - SIMPLIFICADAS
# ===================================

class VehicleMaintenanceStatus(BaseModel):
    """Status de manutenção do veículo único"""
    needs_maintenance: bool
    maintenance_urgency: Optional[str] = None  # 'overdue', 'urgent', 'normal'
    days_overdue: Optional[int] = None
    km_overdue: Optional[int] = None
    next_maintenance_date: Optional[str] = None
    next_maintenance_km: Optional[int] = None

class VehicleDocumentStatus(BaseModel):
    """Status de documentos do veículo único"""
    has_expired_documents: bool
    expired_documents: List[str] = []  # ['insurance', 'license', 'inspection']
    days_until_expiry: Dict[str, int] = {}  # document -> days until expiry (negative if expired)

class VehicleStatusSummary(BaseModel):
    """Resumo do status do veículo único"""
    configured: bool
    has_vehicle: bool
    maintenance: Optional[VehicleMaintenanceStatus] = None
    documents: Optional[VehicleDocumentStatus] = None
    is_online: bool = False
    last_seen: Optional[str] = None