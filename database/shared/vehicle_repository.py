"""
VehicleRepository - Repository pattern para Vehicle model
Implementa todas as operações CRUD e business logic específicas
"""

from typing import List, Optional, Dict, Any, Tuple
from sqlalchemy.orm import Session, joinedload, sessionmaker
from sqlalchemy.exc import IntegrityError
from sqlalchemy import and_, or_, desc, asc, func, text, create_engine
from datetime import datetime, timedelta
import json
import uuid as uuid_lib
import sys
from pathlib import Path

# Adiciona path para importar models
sys.path.append(str(Path(__file__).parent.parent))

from src.models.models import Vehicle, User, Device, Base

# Configuração da sessão  
DATABASE_URL = f"sqlite:///{Path(__file__).parent.parent}/autocore.db"
engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class BaseRepository:
    """Repository base com operações comuns usando ORM"""
    
    def __init__(self, session: Session, model_class):
        self.session = session
        self.model_class = model_class
    
    def get_by_id(self, id: int):
        """Busca por ID"""
        return self.session.query(self.model_class).filter(
            self.model_class.id == id,
            self.model_class.is_active == True
        ).first()
    
    def create(self, **kwargs):
        """Cria novo registro"""
        instance = self.model_class(**kwargs)
        self.session.add(instance)
        self.session.flush()
        return instance
    
    def update(self, id: int, **kwargs):
        """Atualiza registro"""
        instance = self.get_by_id(id)
        if instance:
            for key, value in kwargs.items():
                if hasattr(instance, key):
                    setattr(instance, key, value)
            instance.updated_at = datetime.now()
            self.session.flush()
        return instance
    
    def soft_delete(self, id: int):
        """Soft delete"""
        instance = self.get_by_id(id)
        if instance:
            instance.is_active = False
            instance.deleted_at = datetime.now()
            self.session.flush()
            return True
        return False
    
    def count(self, **filters):
        """Conta registros com filtros"""
        query = self.session.query(self.model_class)
        for key, value in filters.items():
            if hasattr(self.model_class, key):
                if key.endswith('_at') and isinstance(value, datetime):
                    # Para campos de data, busca registros >= à data fornecida
                    query = query.filter(getattr(self.model_class, key) >= value)
                else:
                    query = query.filter(getattr(self.model_class, key) == value)
        return query.count()

class VehicleRepository(BaseRepository):
    """
    Repository específico para Vehicle model - APENAS 1 REGISTRO PERMITIDO
    
    Sistema modificado para trabalhar com registro único de veículo:
    - ID fixo = 1 para o único veículo do sistema
    - Métodos create_or_update_vehicle() para criar/atualizar
    - get_vehicle() retorna o único registro
    - Métodos de listagem múltipla removidos/desabilitados
    - Integração com dispositivos ESP32
    - Telemetria e localização do veículo único
    - Manutenção e vencimentos
    """
    
    def __init__(self, session: Session):
        super().__init__(session, Vehicle)
        self.SINGLE_ID = 1  # ID fixo do único registro
    
    # ================================
    # REGISTRO ÚNICO - OPERAÇÕES CRUD
    # ================================
    
    def get_vehicle(self) -> Optional[Dict[str, Any]]:
        """
        Retorna o único veículo cadastrado (apenas dados da tabela vehicles)
        
        Returns:
            Dados do único veículo ou None se não existe
        """
        vehicle = self.session.query(Vehicle).filter_by(id=self.SINGLE_ID, is_active=True).first()
        
        if vehicle:
            return self._vehicle_to_dict(vehicle, include_relationships=False)
        return None
    
    def create_or_update_vehicle(self, vehicle_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Cria ou atualiza o único registro de veículo
        
        Args:
            vehicle_data: Dados do veículo para criar/atualizar
            
        Returns:
            Dicionário com dados do veículo criado/atualizado
            
        Raises:
            ValueError: Se dados obrigatórios estão ausentes ou inválidos
        """
        try:
            # Busca registro existente
            vehicle = self.session.query(Vehicle).filter(
                Vehicle.id == self.SINGLE_ID
            ).first()
            
            if vehicle:
                # ATUALIZA registro existente
                # Remove campos protegidos
                protected_fields = ['id', 'uuid', 'created_at']
                for field in protected_fields:
                    vehicle_data.pop(field, None)
                
                # Normaliza dados se fornecidos
                if 'plate' in vehicle_data:
                    vehicle_data['plate'] = vehicle_data['plate'].upper().replace(' ', '').replace('-', '')
                
                if 'chassis' in vehicle_data:
                    vehicle_data['chassis'] = vehicle_data['chassis'].upper().replace(' ', '')
                
                # Atualiza campos
                for key, value in vehicle_data.items():
                    if hasattr(vehicle, key) and key not in protected_fields:
                        setattr(vehicle, key, value)
                
                vehicle.updated_at = datetime.now()
                
            else:
                # CRIA novo registro com ID fixo
                # Generate UUID if not provided
                if 'uuid' not in vehicle_data:
                    vehicle_data['uuid'] = str(uuid_lib.uuid4())
                
                # Validate required fields para criação
                required_fields = ['plate', 'chassis', 'renavam', 'brand', 'model', 
                                 'year_manufacture', 'year_model', 'fuel_type', 
                                 'category', 'user_id']
                
                missing_fields = [field for field in required_fields if field not in vehicle_data]
                if missing_fields:
                    raise ValueError(f"Missing required fields: {missing_fields}")
                
                # Normalize plate e chassis
                vehicle_data['plate'] = vehicle_data['plate'].upper().replace(' ', '').replace('-', '')
                vehicle_data['chassis'] = vehicle_data['chassis'].upper().replace(' ', '')
                
                # Force ID = 1
                vehicle_data['id'] = self.SINGLE_ID
                
                # Create vehicle
                vehicle = Vehicle(**vehicle_data)
                self.session.add(vehicle)
            
            self.session.flush()
            return self._vehicle_to_dict(vehicle, include_relationships=False)
            
        except Exception as e:
            self.session.rollback()
            if 'plate' in str(e) and 'UNIQUE constraint failed' in str(e):
                raise ValueError(f"Placa {vehicle_data.get('plate')} já está cadastrada")
            elif 'chassis' in str(e) and 'UNIQUE constraint failed' in str(e):
                raise ValueError(f"Chassi já está cadastrado")
            elif 'renavam' in str(e) and 'UNIQUE constraint failed' in str(e):
                raise ValueError(f"RENAVAM já está cadastrado")
            else:
                raise e
    
    def update_vehicle(self, vehicle_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Atualiza o único veículo (alias para create_or_update_vehicle)
        
        Args:
            vehicle_data: Dados para atualizar
            
        Returns:
            Dados atualizados do veículo
        """
        return self.create_or_update_vehicle(vehicle_data)
    
    def delete_vehicle(self) -> bool:
        """
        Remove o único veículo (soft delete)
        
        Returns:
            True se removido com sucesso
        """
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if vehicle:
            vehicle.is_active = False
            vehicle.deleted_at = datetime.now()
            vehicle.updated_at = datetime.now()
            self.session.flush()
            return True
        return False
    
    def reset_vehicle(self) -> bool:
        """
        Remove completamente o registro para permitir novo cadastro
        
        Returns:
            True se removido com sucesso
        """
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if vehicle:
            self.session.delete(vehicle)
            self.session.flush()
            return True
        return False
    
    def has_vehicle(self) -> bool:
        """
        Verifica se existe um veículo cadastrado
        
        Returns:
            True se existe veículo ativo
        """
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID,
            Vehicle.is_active == True
        ).first()
        return vehicle is not None
    
    def get_vehicle_for_config(self) -> Optional[Dict[str, Any]]:
        """
        Retorna veículo formatado para /config/full
        
        Returns:
            Veículo formatado para configuração ou None
        """
        vehicle_data = self.get_vehicle()
        if vehicle_data:
            # Remove campos desnecessários para o config
            config_vehicle = {
                'id': vehicle_data['id'],
                'uuid': vehicle_data['uuid'],
                'plate': vehicle_data['plate'],
                'brand': vehicle_data['brand'],
                'model': vehicle_data['model'],
                'version': vehicle_data.get('version'),
                'year_model': vehicle_data['year_model'],
                'fuel_type': vehicle_data['fuel_type'],
                'status': vehicle_data['status'],
                'odometer': vehicle_data['odometer'],
                'next_maintenance_date': vehicle_data.get('next_maintenance_date'),
                'next_maintenance_km': vehicle_data.get('next_maintenance_km'),
                'full_name': vehicle_data['full_name'],
                'is_online': vehicle_data.get('is_online', False)
            }
            return config_vehicle
        return None
    
    # ================================
    # MÉTODOS DESABILITADOS/DEPRECATED
    # ================================
    
    def get_user_vehicles(self, *args, **kwargs):
        """DEPRECATED - Use get_vehicle() para obter o único registro"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
    
    def get_active_vehicles(self, *args, **kwargs):
        """DEPRECATED - Use get_vehicle() para obter o único registro"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
    
    def get_vehicles_by_brand(self, *args, **kwargs):
        """DEPRECATED - Sistema suporta apenas 1 veículo"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
    
    def search_vehicles(self, *args, **kwargs):
        """DEPRECATED - Sistema suporta apenas 1 veículo"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
        
    def create_vehicle(self, *args, **kwargs):
        """DEPRECATED - Use create_or_update_vehicle()"""
        raise NotImplementedError("Use create_or_update_vehicle() para o sistema de registro único")
    
    def get_vehicle_by_plate(self, plate: str) -> Optional[Dict[str, Any]]:
        """
        Busca veículo por placa
        
        Args:
            plate: Placa do veículo (com ou sem formatação)
            
        Returns:
            Dados do veículo ou None se não encontrado
        """
        # Normalize plate
        normalized_plate = plate.upper().replace(' ', '').replace('-', '')
        
        vehicle = self.session.query(Vehicle).options(
            joinedload(Vehicle.owner),
            joinedload(Vehicle.primary_device)
        ).filter_by(plate=normalized_plate, is_active=True).first()
        
        if vehicle:
            return self._vehicle_to_dict(vehicle, include_relationships=True)
        return None
    
    def get_vehicle_by_chassis(self, chassis: str) -> Optional[Dict[str, Any]]:
        """Busca veículo por chassi"""
        normalized_chassis = chassis.upper().replace(' ', '')
        
        vehicle = self.session.query(Vehicle).filter_by(
            chassis=normalized_chassis, 
            is_active=True
        ).first()
        
        if vehicle:
            return self._vehicle_to_dict(vehicle)
        return None
    
    def update_vehicle_legacy(self, vehicle_id: int, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        DEPRECATED - Método legado para múltiplos veículos
        Use update_vehicle(vehicle_data) para o sistema de registro único
        """
        raise NotImplementedError("Use update_vehicle(vehicle_data) para o sistema de registro único")
    
    def delete_vehicle_legacy(self, vehicle_id: int) -> bool:
        """
        DEPRECATED - Método legado para múltiplos veículos
        Use delete_vehicle() para o sistema de registro único
        """
        raise NotImplementedError("Use delete_vehicle() para o sistema de registro único")
    
    # ================================
    # QUERY METHODS
    # ================================
    
    def get_user_vehicles(self, user_id: int, include_inactive: bool = False) -> List[Dict[str, Any]]:
        """
        Lista veículos de um usuário
        
        Args:
            user_id: ID do usuário
            include_inactive: Incluir veículos inativos
            
        Returns:
            Lista de veículos do usuário
        """
        query = self.session.query(Vehicle).options(
            joinedload(Vehicle.primary_device)
        ).filter_by(user_id=user_id)
        
        if not include_inactive:
            query = query.filter_by(is_active=True)
        
        vehicles = query.order_by(Vehicle.brand, Vehicle.model, Vehicle.year_model).all()
        
        return [self._vehicle_to_dict(v) for v in vehicles]
    
    def get_active_vehicles_legacy(self, limit: int = None, offset: int = 0) -> List[Dict[str, Any]]:
        """DEPRECATED - Use get_vehicle() para obter o único registro"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
    
    def get_vehicles_by_brand_legacy(self, brand: str, model: str = None) -> List[Dict[str, Any]]:
        """DEPRECATED - Sistema suporta apenas 1 veículo"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
    
    def search_vehicles_legacy(self, search_term: str, limit: int = 20) -> List[Dict[str, Any]]:
        """DEPRECATED - Sistema suporta apenas 1 veículo"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
    
    # ================================
    # STATUS MANAGEMENT
    # ================================
    
    def update_odometer(self, new_km: int) -> Optional[Dict[str, Any]]:
        """
        Atualiza quilometragem do único veículo
        
        Args:
            new_km: Nova quilometragem
            
        Returns:
            Dados do veículo atualizado ou None se não encontrado
        """
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if not vehicle:
            return None
        
        # Validate that new km is not less than current (unless it's a reset)
        if new_km < vehicle.odometer and new_km > 0:
            # Allow only if it's a significant reset (probably odometer replaced)
            if (vehicle.odometer - new_km) < 50000:  # Less than 50k difference
                return None
        
        old_odometer = vehicle.odometer
        vehicle.odometer = new_km
        vehicle.updated_at = datetime.now()
        self.session.flush()
        
        # Check if maintenance is now due
        self._check_maintenance_due(vehicle)
        
        return self._vehicle_to_dict(vehicle)
    
    def update_location(self, latitude: float, longitude: float, 
                       accuracy: int = None, timestamp: datetime = None) -> bool:
        """
        Atualiza localização do único veículo
        
        Args:
            latitude: Latitude
            longitude: Longitude  
            accuracy: Precisão em metros
            timestamp: Timestamp da localização (default: now)
            
        Returns:
            True se atualizado com sucesso
        """
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if not vehicle:
            return False
        
        location_data = {
            'lat': latitude,
            'lng': longitude,
            'timestamp': (timestamp or datetime.now()).isoformat(),
        }
        
        if accuracy is not None:
            location_data['accuracy'] = accuracy
        
        vehicle.last_location = json.dumps(location_data)
        vehicle.updated_at = datetime.now()
        self.session.flush()
        
        return True
    
    def update_status(self, status: str) -> bool:
        """
        Atualiza status do único veículo
        
        Args:
            status: Novo status (active, inactive, maintenance, retired, sold)
            
        Returns:
            True se atualizado com sucesso
        """
        valid_statuses = ['active', 'inactive', 'maintenance', 'retired', 'sold']
        if status not in valid_statuses:
            raise ValueError(f"Status inválido. Use: {valid_statuses}")
        
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if not vehicle:
            return False
        
        vehicle.status = status
        vehicle.updated_at = datetime.now()
        
        # If vehicle is being retired or sold, deactivate it
        if status in ['retired', 'sold']:
            vehicle.is_active = False
            vehicle.is_tracked = False
        
        self.session.flush()
        return True
    
    # ================================
    # MAINTENANCE MANAGEMENT
    # ================================
    
    def get_maintenance_due(self, days_ahead: int = 30) -> List[Dict[str, Any]]:
        """
        Lista veículos com manutenção em atraso ou próxima do vencimento
        
        Args:
            days_ahead: Dias de antecedência para considerar
            
        Returns:
            Lista de veículos com manutenção pendente
        """
        future_date = datetime.now() + timedelta(days=days_ahead)
        
        # Query para manutenção por data ou km
        vehicles = self.session.query(Vehicle).options(
            joinedload(Vehicle.owner)
        ).filter(
            and_(
                Vehicle.is_active == True,
                or_(
                    # Manutenção vencida por data
                    and_(
                        Vehicle.next_maintenance_date.isnot(None),
                        Vehicle.next_maintenance_date <= future_date
                    ),
                    # Manutenção vencida por km (assume 1000km/mês)
                    and_(
                        Vehicle.next_maintenance_km.isnot(None),
                        Vehicle.next_maintenance_km <= (Vehicle.odometer + (days_ahead * 33))
                    )
                )
            )
        ).order_by(Vehicle.next_maintenance_date).all()
        
        result = []
        for vehicle in vehicles:
            vehicle_data = self._vehicle_to_dict(vehicle, include_relationships=True)
            
            # Calculate urgency
            urgency = 'normal'
            if vehicle.next_maintenance_date and vehicle.next_maintenance_date <= datetime.now():
                urgency = 'overdue'
            elif vehicle.next_maintenance_km and vehicle.odometer >= vehicle.next_maintenance_km:
                urgency = 'overdue'
            elif vehicle.next_maintenance_date and vehicle.next_maintenance_date <= datetime.now() + timedelta(days=7):
                urgency = 'urgent'
            
            vehicle_data['maintenance_urgency'] = urgency
            result.append(vehicle_data)
        
        return result
    
    def update_maintenance(self, vehicle_id: int, maintenance_data: Dict[str, Any]) -> bool:
        """
        Atualiza dados de manutenção do veículo
        
        Args:
            vehicle_id: ID do veículo
            maintenance_data: Dados da manutenção
            
        Returns:
            True se atualizado com sucesso
        """
        vehicle = self.get_by_id(vehicle_id)
        if not vehicle:
            return False
        
        # Update maintenance fields
        for field in ['next_maintenance_date', 'next_maintenance_km', 
                     'last_maintenance_date', 'last_maintenance_km']:
            if field in maintenance_data:
                setattr(vehicle, field, maintenance_data[field])
        
        vehicle.updated_at = datetime.now()
        self.session.flush()
        
        return True
    
    def get_expired_documents(self) -> List[Dict[str, Any]]:
        """
        Lista veículos com documentos vencidos
        
        Returns:
            Lista de veículos com documentos vencidos
        """
        now = datetime.now()
        
        vehicles = self.session.query(Vehicle).options(
            joinedload(Vehicle.owner)
        ).filter(
            and_(
                Vehicle.is_active == True,
                or_(
                    and_(Vehicle.insurance_expiry.isnot(None), Vehicle.insurance_expiry <= now),
                    and_(Vehicle.license_expiry.isnot(None), Vehicle.license_expiry <= now),
                    and_(Vehicle.inspection_expiry.isnot(None), Vehicle.inspection_expiry <= now)
                )
            )
        ).order_by(Vehicle.license_expiry).all()
        
        result = []
        for vehicle in vehicles:
            vehicle_data = self._vehicle_to_dict(vehicle, include_relationships=True)
            
            # Add expiry details
            expired_docs = []
            if vehicle.insurance_expiry and vehicle.insurance_expiry <= now:
                expired_docs.append('insurance')
            if vehicle.license_expiry and vehicle.license_expiry <= now:
                expired_docs.append('license')
            if vehicle.inspection_expiry and vehicle.inspection_expiry <= now:
                expired_docs.append('inspection')
            
            vehicle_data['expired_documents'] = expired_docs
            result.append(vehicle_data)
        
        return result
    
    # ================================
    # DEVICE MANAGEMENT
    # ================================
    
    def assign_device(self, vehicle_id: int, device_id: int, role: str = 'secondary') -> bool:
        """
        Associa device ao veículo
        
        Args:
            vehicle_id: ID do veículo
            device_id: ID do device
            role: Papel do device (primary, secondary, tracker)
            
        Returns:
            True se associado com sucesso
        """
        vehicle = self.get_by_id(vehicle_id)
        device = self.session.get(Device, device_id)
        
        if not vehicle or not device:
            return False
        
        # If role is primary, update primary_device_id
        if role == 'primary':
            vehicle.primary_device_id = device_id
        
        # Add to many-to-many relationship
        if device not in vehicle.devices:
            vehicle.devices.append(device)
        
        self.session.flush()
        return True
    
    def remove_device(self, vehicle_id: int, device_id: int) -> bool:
        """
        Remove associação entre veículo e device
        
        Args:
            vehicle_id: ID do veículo
            device_id: ID do device
            
        Returns:
            True se removido com sucesso
        """
        vehicle = self.get_by_id(vehicle_id)
        device = self.session.get(Device, device_id)
        
        if not vehicle or not device:
            return False
        
        # If it's the primary device, clear it
        if vehicle.primary_device_id == device_id:
            vehicle.primary_device_id = None
        
        # Remove from many-to-many relationship
        if device in vehicle.devices:
            vehicle.devices.remove(device)
        
        self.session.flush()
        return True
    
    def get_vehicle_devices(self, vehicle_id: int) -> List[Dict[str, Any]]:
        """
        Lista devices associados ao veículo
        
        Args:
            vehicle_id: ID do veículo
            
        Returns:
            Lista de devices do veículo
        """
        vehicle = self.session.query(Vehicle).options(
            joinedload(Vehicle.primary_device),
            joinedload(Vehicle.devices)
        ).filter_by(id=vehicle_id).first()
        
        if not vehicle:
            return []
        
        devices = []
        
        # Primary device
        if vehicle.primary_device:
            device_data = {
                'id': vehicle.primary_device.id,
                'name': vehicle.primary_device.name,
                'type': vehicle.primary_device.type,
                'status': vehicle.primary_device.status,
                'role': 'primary',
                'is_online': vehicle.primary_device.status == 'online'
            }
            devices.append(device_data)
        
        # Secondary devices
        for device in vehicle.devices:
            if device.id != vehicle.primary_device_id:
                device_data = {
                    'id': device.id,
                    'name': device.name,
                    'type': device.type,
                    'status': device.status,
                    'role': 'secondary',
                    'is_online': device.status == 'online'
                }
                devices.append(device_data)
        
        return devices
    
    # ================================
    # HELPER METHODS
    # ================================
    
    def _vehicle_to_dict(self, vehicle: Vehicle, include_relationships: bool = False) -> Dict[str, Any]:
        """
        Converte Vehicle model para dicionário
        
        Args:
            vehicle: Instância do Vehicle
            include_relationships: Incluir dados de relacionamentos
            
        Returns:
            Dicionário com dados do veículo
        """
        data = {
            'id': vehicle.id,
            'uuid': vehicle.uuid,
            
            # Identification
            'plate': vehicle.plate,
            'chassis': vehicle.chassis,
            'renavam': vehicle.renavam,
            
            # Basic info
            'brand': vehicle.brand,
            'model': vehicle.model,
            'version': vehicle.version,
            'year_manufacture': vehicle.year_manufacture,
            'year_model': vehicle.year_model,
            'color': vehicle.color,
            'color_code': vehicle.color_code,
            
            # Technical
            'fuel_type': vehicle.fuel_type,
            'engine_capacity': vehicle.engine_capacity,
            'engine_power': vehicle.engine_power,
            'engine_torque': vehicle.engine_torque,
            'transmission': vehicle.transmission,
            'category': vehicle.category,
            'usage_type': vehicle.usage_type,
            
            # Status
            'status': vehicle.status,
            'odometer': vehicle.odometer,
            'odometer_unit': vehicle.odometer_unit,
            'last_location': vehicle.get_location(),
            
            # Maintenance
            'next_maintenance_date': vehicle.next_maintenance_date.isoformat() if vehicle.next_maintenance_date else None,
            'next_maintenance_km': vehicle.next_maintenance_km,
            'last_maintenance_date': vehicle.last_maintenance_date.isoformat() if vehicle.last_maintenance_date else None,
            'last_maintenance_km': vehicle.last_maintenance_km,
            
            # Expiry dates
            'insurance_expiry': vehicle.insurance_expiry.isoformat() if vehicle.insurance_expiry else None,
            'license_expiry': vehicle.license_expiry.isoformat() if vehicle.license_expiry else None,
            'inspection_expiry': vehicle.inspection_expiry.isoformat() if vehicle.inspection_expiry else None,
            
            # System flags
            'is_active': vehicle.is_active,
            'is_tracked': vehicle.is_tracked,
            'notes': vehicle.notes,
            'tags': json.loads(vehicle.tags) if vehicle.tags else [],
            
            # Computed properties
            'full_name': vehicle.full_name,
            'age_years': vehicle.age_years,
            'is_online': vehicle.is_online,
            'needs_maintenance': vehicle.needs_maintenance,
            'has_expired_documents': vehicle.has_expired_documents,
            
            # Timestamps
            'created_at': vehicle.created_at.isoformat(),
            'updated_at': vehicle.updated_at.isoformat(),
        }
        
        # Include relationships if requested
        if include_relationships:
            # Owner
            if vehicle.owner:
                data['owner'] = {
                    'id': vehicle.owner.id,
                    'username': vehicle.owner.username,
                    'full_name': vehicle.owner.full_name,
                    'email': vehicle.owner.email,
                }
            
            # Primary device
            if vehicle.primary_device:
                data['primary_device'] = {
                    'id': vehicle.primary_device.id,
                    'name': vehicle.primary_device.name,
                    'type': vehicle.primary_device.type,
                    'status': vehicle.primary_device.status,
                    'last_seen': vehicle.primary_device.last_seen.isoformat() if vehicle.primary_device.last_seen else None,
                }
            
            # All devices
            data['devices'] = self.get_vehicle_devices(vehicle.id)
        
        return data
    
    def _check_maintenance_due(self, vehicle: Vehicle) -> None:
        """
        Verifica se manutenção está vencida após atualização de km
        
        Args:
            vehicle: Instância do Vehicle
        """
        if vehicle.next_maintenance_km and vehicle.odometer >= vehicle.next_maintenance_km:
            # Could trigger notification or event here
            pass
    
    # ================================
    # VALIDATION HELPERS
    # ================================
    
    def validate_plate(self, plate: str, exclude_vehicle_id: int = None) -> bool:
        """
        Valida se placa é única e tem formato correto
        
        Args:
            plate: Placa para validar
            exclude_vehicle_id: ID para excluir da validação (para updates)
            
        Returns:
            True se placa é válida
        """
        # Normalize plate
        normalized_plate = plate.upper().replace(' ', '').replace('-', '')
        
        # Validate format (Brazilian plates)
        import re
        if not re.match(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$', normalized_plate):
            return False
        
        # Check uniqueness
        query = self.session.query(Vehicle).filter_by(plate=normalized_plate, is_active=True)
        
        if exclude_vehicle_id:
            query = query.filter(Vehicle.id != exclude_vehicle_id)
        
        return query.first() is None
    
    def validate_chassis(self, chassis: str, exclude_vehicle_id: int = None) -> bool:
        """
        Valida se chassi é único e tem formato correto
        
        Args:
            chassis: Chassi para validar
            exclude_vehicle_id: ID para excluir da validação
            
        Returns:
            True se chassi é válido
        """
        # Normalize chassis
        normalized_chassis = chassis.upper().replace(' ', '')
        
        # Chassi deve ter entre 11 e 30 caracteres (aceita veículos antigos)
        if len(normalized_chassis) < 11 or len(normalized_chassis) > 30:
            return False
        
        # Check uniqueness
        query = self.session.query(Vehicle).filter_by(chassis=normalized_chassis, is_active=True)
        
        if exclude_vehicle_id:
            query = query.filter(Vehicle.id != exclude_vehicle_id)
        
        return query.first() is None


def create_vehicle_repository() -> VehicleRepository:
    """Factory function para criar VehicleRepository com sessão"""
    session = SessionLocal()
    return VehicleRepository(session)


# Para compatibilidade com o padrão existente
def get_vehicle_repository():
    """Retorna instância singleton do VehicleRepository"""
    if not hasattr(get_vehicle_repository, '_instance'):
        get_vehicle_repository._instance = create_vehicle_repository()
    return get_vehicle_repository._instance