# 🚗 A07-VEHICLE-TABLE-SIMPLIFIER - Simplificador da Tabela Vehicles

## 📋 Objetivo

Agente autônomo para simplificar a tabela `vehicles`, removendo todos os relacionamentos com outras tabelas (users, devices), mantendo apenas um cadastro independente.

## 🎯 Missão

Modificar o modelo Vehicle para ser uma tabela standalone sem foreign keys, atualizar o repository e gerar nova migration.

## ⚙️ Configuração

```yaml
tipo: modification
prioridade: alta
autônomo: true
output: docs/agents/executed/A07-VEHICLE-SIMPLIFICATION-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Análise (20%)
1. Verificar modelo atual em `src/models/models.py`
2. Identificar campos a remover
3. Planejar modificações

### Fase 2: Simplificação do Modelo (50%)
1. Remover foreign keys (user_id, primary_device_id)
2. Remover relacionamentos SQLAlchemy
3. Remover tabela vehicle_devices
4. Manter apenas campos de dados do veículo

### Fase 3: Repository Simplificado (70%)
1. Atualizar VehicleRepository
2. Remover métodos de relacionamento
3. Simplificar métodos CRUD
4. Remover validações de ownership

### Fase 4: Migration (90%)
1. Gerar nova migration
2. Aplicar alterações no banco
3. Verificar estrutura final

### Fase 5: Documentação (100%)
1. Atualizar documentação
2. Gerar relatório de execução

## 📝 Modelo Simplificado

```python
class Vehicle(Base):
    """Tabela independente de veículos - sem relacionamentos"""
    __tablename__ = 'vehicles'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    uuid = Column(String(36), unique=True, nullable=False, default=lambda: str(uuid4()))
    
    # Dados do veículo
    plate = Column(String(10), unique=True, nullable=False)
    chassis = Column(String(30), unique=True, nullable=False)
    renavam = Column(String(20), unique=True, nullable=False)
    
    # Informações básicas
    brand = Column(String(50), nullable=False)
    model = Column(String(100), nullable=False)
    version = Column(String(100), nullable=True)
    year_manufacture = Column(Integer, nullable=False)
    year_model = Column(Integer, nullable=False)
    color = Column(String(30), nullable=True)
    
    # Motorização
    fuel_type = Column(String(20), nullable=False)
    engine_capacity = Column(Integer, nullable=True)
    engine_power = Column(Integer, nullable=True)
    transmission = Column(String(20), nullable=True)
    category = Column(String(30), nullable=True)
    
    # Status e controle
    status = Column(String(20), default='active', nullable=False)
    odometer = Column(Integer, default=0, nullable=False)
    
    # Manutenção
    next_maintenance_date = Column(DateTime, nullable=True)
    next_maintenance_km = Column(Integer, nullable=True)
    insurance_expiry = Column(DateTime, nullable=True)
    license_expiry = Column(DateTime, nullable=True)
    
    # Observações
    notes = Column(Text, nullable=True)
    
    # Sistema
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)
    
    # SEM RELACIONAMENTOS - Tabela independente
    
    __table_args__ = (
        Index('idx_vehicles_uuid', 'uuid'),
        Index('idx_vehicles_plate', 'plate'),
        Index('idx_vehicles_chassis', 'chassis'),
        Index('idx_vehicles_renavam', 'renavam'),
        Index('idx_vehicles_brand_model', 'brand', 'model'),
        Index('idx_vehicles_status', 'status'),
        Index('idx_vehicles_active', 'is_active'),
        CheckConstraint(
            "fuel_type IN ('flex', 'gasoline', 'ethanol', 'diesel', 'electric', 'hybrid')",
            name='check_valid_fuel_type'
        ),
        CheckConstraint(
            "status IN ('active', 'inactive', 'maintenance', 'sold')",
            name='check_valid_status'
        ),
    )
```

## 🔧 Repository Simplificado

```python
class VehicleRepository(BaseRepository):
    """Repository simplificado - sem relacionamentos"""
    
    def create_vehicle(self, data: dict) -> dict:
        """Cria novo veículo"""
        vehicle = Vehicle(**data)
        self.session.add(vehicle)
        self.session.commit()
        return self.to_dict(vehicle)
    
    def get_all_vehicles(self, skip: int = 0, limit: int = 100) -> List[dict]:
        """Lista todos os veículos"""
        vehicles = self.session.query(Vehicle)\
            .filter(Vehicle.is_active == True)\
            .offset(skip)\
            .limit(limit)\
            .all()
        return [self.to_dict(v) for v in vehicles]
    
    def get_vehicle(self, vehicle_id: int) -> dict:
        """Obtém veículo por ID"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == vehicle_id,
            Vehicle.is_active == True
        ).first()
        return self.to_dict(vehicle) if vehicle else None
    
    def get_vehicle_by_plate(self, plate: str) -> dict:
        """Busca veículo por placa"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.plate == plate.upper(),
            Vehicle.is_active == True
        ).first()
        return self.to_dict(vehicle) if vehicle else None
    
    def update_vehicle(self, vehicle_id: int, data: dict) -> dict:
        """Atualiza dados do veículo"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == vehicle_id
        ).first()
        
        if not vehicle:
            return None
            
        for key, value in data.items():
            if hasattr(vehicle, key):
                setattr(vehicle, key, value)
        
        self.session.commit()
        return self.to_dict(vehicle)
    
    def delete_vehicle(self, vehicle_id: int) -> bool:
        """Remove veículo (soft delete)"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == vehicle_id
        ).first()
        
        if not vehicle:
            return False
            
        vehicle.is_active = False
        self.session.commit()
        return True
    
    def search_vehicles(self, query: str) -> List[dict]:
        """Busca veículos por texto"""
        search = f"%{query}%"
        vehicles = self.session.query(Vehicle).filter(
            Vehicle.is_active == True,
            or_(
                Vehicle.plate.like(search),
                Vehicle.brand.like(search),
                Vehicle.model.like(search),
                Vehicle.chassis.like(search)
            )
        ).all()
        return [self.to_dict(v) for v in vehicles]
    
    def get_vehicles_by_status(self, status: str) -> List[dict]:
        """Lista veículos por status"""
        vehicles = self.session.query(Vehicle).filter(
            Vehicle.status == status,
            Vehicle.is_active == True
        ).all()
        return [self.to_dict(v) for v in vehicles]
    
    def update_odometer(self, vehicle_id: int, odometer: int) -> dict:
        """Atualiza quilometragem"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == vehicle_id
        ).first()
        
        if vehicle and odometer > vehicle.odometer:
            vehicle.odometer = odometer
            self.session.commit()
            return self.to_dict(vehicle)
        return None
```

## ✅ Checklist de Simplificação

- [ ] Remover campos user_id e primary_device_id
- [ ] Remover tabela vehicle_devices
- [ ] Remover relacionamentos SQLAlchemy
- [ ] Simplificar repository (sem ownership)
- [ ] Atualizar índices necessários
- [ ] Gerar nova migration
- [ ] Aplicar no banco
- [ ] Testar CRUD básico

## 📊 Resultado Esperado

Tabela `vehicles` totalmente independente:
- Sem foreign keys
- Sem relacionamentos
- CRUD simples e direto
- Cadastro standalone

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/08/2025