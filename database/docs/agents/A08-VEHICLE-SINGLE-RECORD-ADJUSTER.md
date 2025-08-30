# 🚗 A08-VEHICLE-SINGLE-RECORD-ADJUSTER - Ajustador para Registro Único de Veículo

## 📋 Objetivo

Agente autônomo para ajustar a implementação da tabela `vehicles` para suportar apenas **1 único registro** no sistema, modificando o modelo e repository já criados.

## 🎯 Missão

Ajustar o modelo Vehicle e VehicleRepository para garantir que apenas 1 veículo possa existir no banco, implementando validações e métodos específicos para registro único.

## ⚙️ Configuração

```yaml
tipo: adjustment
prioridade: urgente
autônomo: true
prerequisito: A04-VEHICLE-TABLE-CREATOR já executado
output: docs/agents/executed/A08-VEHICLE-SINGLE-ADJUST-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Análise do Estado Atual (10%)
1. Verificar modelo Vehicle em `src/models/models.py`
2. Verificar VehicleRepository em `shared/vehicle_repository.py`
3. Identificar métodos a modificar
4. Planejar ajustes necessários

### Fase 2: Ajuste do Modelo (30%)
1. Adicionar constraint para garantir registro único
2. Adicionar método de classe para obter/criar registro único
3. Implementar validação de unicidade
4. Adicionar flag ou ID fixo se necessário

### Fase 3: Ajuste do Repository (60%)
1. Modificar métodos CRUD para registro único:
   - `get_vehicle()` - retorna o único registro
   - `create_or_update()` - cria se não existir, atualiza se existir
   - `update_vehicle()` - atualiza o único registro
   - `delete_vehicle()` - remove o único registro
2. Remover métodos de listagem múltipla
3. Adicionar método `ensure_single_record()`

### Fase 4: Migration de Ajuste (80%)
1. Gerar migration para aplicar constraint
2. Limpar registros extras se existirem
3. Garantir apenas 1 registro permanece
4. Aplicar migration

### Fase 5: Validação e Documentação (100%)
1. Testar operações CRUD
2. Verificar constraint funcionando
3. Documentar mudanças
4. Gerar relatório

## 📝 Ajustes no Modelo

### Modelo Vehicle Ajustado
```python
class Vehicle(Base):
    """Tabela de veículo - APENAS 1 REGISTRO PERMITIDO"""
    __tablename__ = 'vehicles'
    
    # ID fixo para garantir apenas 1 registro
    id = Column(Integer, primary_key=True, default=1)
    uuid = Column(String(36), unique=True, nullable=False, default=lambda: str(uuid4()))
    
    # Dados do veículo (mantém todos os campos existentes)
    plate = Column(String(10), unique=True, nullable=False)
    chassis = Column(String(30), unique=True, nullable=False)
    renavam = Column(String(20), unique=True, nullable=False)
    brand = Column(String(50), nullable=False)
    model = Column(String(100), nullable=False)
    version = Column(String(100), nullable=True)
    year_manufacture = Column(Integer, nullable=False)
    year_model = Column(Integer, nullable=False)
    color = Column(String(30), nullable=True)
    fuel_type = Column(String(20), nullable=False)
    engine_capacity = Column(Integer, nullable=True)
    engine_power = Column(Integer, nullable=True)
    transmission = Column(String(20), nullable=True)
    category = Column(String(30), nullable=True)
    status = Column(String(20), default='active', nullable=False)
    odometer = Column(Integer, default=0, nullable=False)
    next_maintenance_date = Column(DateTime, nullable=True)
    next_maintenance_km = Column(Integer, nullable=True)
    insurance_expiry = Column(DateTime, nullable=True)
    license_expiry = Column(DateTime, nullable=True)
    notes = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)
    
    # Constraint para garantir apenas 1 registro
    __table_args__ = (
        CheckConstraint('id = 1', name='check_single_vehicle_record'),
        # Manter outros índices e constraints existentes
        Index('idx_vehicles_uuid', 'uuid'),
        Index('idx_vehicles_plate', 'plate'),
        Index('idx_vehicles_chassis', 'chassis'),
        Index('idx_vehicles_renavam', 'renavam'),
    )
    
    @classmethod
    def get_single_instance(cls, session):
        """Retorna o único registro, criando se não existir"""
        vehicle = session.query(cls).filter(cls.id == 1).first()
        if not vehicle:
            vehicle = cls(id=1)
            session.add(vehicle)
        return vehicle
```

## 🔧 Repository Ajustado para Registro Único

```python
class VehicleRepository(BaseRepository):
    """Repository para gerenciar o ÚNICO registro de veículo"""
    
    def __init__(self, session):
        super().__init__(session)
        self.SINGLE_ID = 1  # ID fixo do único registro
    
    def get_vehicle(self) -> dict:
        """Retorna o único veículo cadastrado"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID,
            Vehicle.is_active == True
        ).first()
        return self.to_dict(vehicle) if vehicle else None
    
    def create_or_update_vehicle(self, data: dict) -> dict:
        """Cria ou atualiza o único registro de veículo"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if vehicle:
            # Atualiza registro existente
            for key, value in data.items():
                if hasattr(vehicle, key) and key not in ['id', 'uuid', 'created_at']:
                    setattr(vehicle, key, value)
        else:
            # Cria novo registro com ID fixo
            data['id'] = self.SINGLE_ID
            vehicle = Vehicle(**data)
            self.session.add(vehicle)
        
        self.session.commit()
        return self.to_dict(vehicle)
    
    def update_vehicle(self, data: dict) -> dict:
        """Atualiza o único veículo (alias para create_or_update)"""
        return self.create_or_update_vehicle(data)
    
    def delete_vehicle(self) -> bool:
        """Remove o único veículo (soft delete)"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if vehicle:
            vehicle.is_active = False
            self.session.commit()
            return True
        return False
    
    def reset_vehicle(self) -> bool:
        """Remove completamente o registro para permitir novo cadastro"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if vehicle:
            self.session.delete(vehicle)
            self.session.commit()
            return True
        return False
    
    def has_vehicle(self) -> bool:
        """Verifica se existe um veículo cadastrado"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID,
            Vehicle.is_active == True
        ).first()
        return vehicle is not None
    
    def update_odometer(self, odometer: int) -> dict:
        """Atualiza quilometragem do único veículo"""
        vehicle = self.session.query(Vehicle).filter(
            Vehicle.id == self.SINGLE_ID
        ).first()
        
        if vehicle and odometer > vehicle.odometer:
            vehicle.odometer = odometer
            self.session.commit()
            return self.to_dict(vehicle)
        return None
    
    def get_vehicle_for_config(self) -> dict:
        """Retorna veículo formatado para /config/full"""
        vehicle = self.get_vehicle()
        if vehicle:
            # Remove campos desnecessários para o config
            config_vehicle = {
                'id': vehicle['id'],
                'uuid': vehicle['uuid'],
                'plate': vehicle['plate'],
                'brand': vehicle['brand'],
                'model': vehicle['model'],
                'year_model': vehicle['year_model'],
                'fuel_type': vehicle['fuel_type'],
                'status': vehicle['status'],
                'odometer': vehicle['odometer'],
                'next_maintenance_date': vehicle.get('next_maintenance_date'),
                'next_maintenance_km': vehicle.get('next_maintenance_km')
            }
            return config_vehicle
        return None
    
    # Remover ou desabilitar métodos de múltiplos registros
    def get_all_vehicles(self, *args, **kwargs):
        """DEPRECATED - Use get_vehicle() para obter o único registro"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
    
    def search_vehicles(self, *args, **kwargs):
        """DEPRECATED - Sistema suporta apenas 1 veículo"""
        raise NotImplementedError("Sistema suporta apenas 1 veículo. Use get_vehicle()")
```

## 🔄 Migration de Ajuste

```sql
-- Migration para garantir apenas 1 registro

-- 1. Remover registros extras (mantém o mais recente)
DELETE FROM vehicles 
WHERE id != (SELECT id FROM vehicles ORDER BY created_at DESC LIMIT 1);

-- 2. Atualizar ID do registro restante para 1
UPDATE vehicles SET id = 1 WHERE id != 1;

-- 3. Adicionar constraint para garantir ID = 1
ALTER TABLE vehicles ADD CONSTRAINT check_single_vehicle_record CHECK (id = 1);

-- 4. Remover auto-increment do ID (SQLite não suporta, mas conceitual)
-- Em SQLAlchemy, remover autoincrement=True do campo id
```

## ⚠️ Validações Importantes

1. **Criação**: Só permite criar se não existir nenhum registro
2. **ID Fixo**: Sempre usa ID = 1
3. **Atualização**: Sempre atualiza o registro ID = 1
4. **Exclusão**: Soft delete do único registro
5. **Reset**: Método especial para limpar e permitir novo cadastro

## ✅ Checklist de Implementação

- [ ] Modelo Vehicle ajustado com ID fixo
- [ ] Constraint check_single_vehicle_record adicionada
- [ ] VehicleRepository refatorado para registro único
- [ ] Método get_vehicle() retorna único registro
- [ ] Método create_or_update_vehicle() implementado
- [ ] Métodos de listagem removidos/desabilitados
- [ ] Migration aplicada para limpar extras
- [ ] Testes validando unicidade
- [ ] Documentação atualizada

## 🧪 Testes de Validação

```python
# Teste 1: Criar primeiro veículo
data1 = {"plate": "ABC1D23", "brand": "VW", ...}
vehicle1 = repo.create_or_update_vehicle(data1)
assert vehicle1['id'] == 1

# Teste 2: Tentar criar segundo (deve atualizar o primeiro)
data2 = {"plate": "XYZ9K88", "brand": "Toyota", ...}
vehicle2 = repo.create_or_update_vehicle(data2)
assert vehicle2['id'] == 1
assert vehicle2['plate'] == "XYZ9K88"  # Atualizou

# Teste 3: Verificar que só existe 1
assert repo.has_vehicle() == True
vehicle = repo.get_vehicle()
assert vehicle['id'] == 1
```

## 📊 Output Esperado

Arquivo `A08-VEHICLE-SINGLE-ADJUST-[DATA].md` contendo:
1. Status dos ajustes realizados
2. Código do modelo ajustado
3. Repository refatorado
4. Migration aplicada
5. Resultados dos testes
6. Confirmação de registro único

## 🚀 Resultado Final

- Sistema com **APENAS 1 veículo** cadastrado
- ID sempre fixo em 1
- Criação/atualização unificadas
- Ideal para sistema com frota única

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/08/2025  
**Prerequisito**: Tabela vehicles já criada