# 🚗 A04-VEHICLE-TABLE-CREATOR - Criador de Tabela de Veículos

## 📋 Objetivo

Agente autônomo para implementar a tabela `vehicles` no banco de dados AutoCore, baseado na especificação gerada pelo agente A03-VEHICLE-TABLE-ANALYZER.

## 🎯 Missão

Criar o modelo SQLAlchemy, gerar e aplicar migration, implementar repository com todos os métodos necessários e validar a implementação completa.

## ⚙️ Configuração

```yaml
tipo: implementation
prioridade: alta
autônomo: true
dependência: A03-VEHICLE-TABLE-ANALYZER
output: docs/agents/executed/A04-VEHICLE-CREATION-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Preparação (10%)
1. Ler especificação em `A03-VEHICLE-ANALYSIS-2025-01-28.md`
2. Verificar arquivo `src/models/models.py`
3. Criar backup do models.py atual
4. Validar estrutura proposta

### Fase 2: Implementação do Modelo (30%)
1. Adicionar modelo Vehicle ao models.py
2. Adicionar imports necessários
3. Implementar métodos auxiliares
4. Adicionar tabela associativa vehicle_devices

### Fase 3: Geração de Migration (50%)
1. Usar auto_migrate.py para gerar migration
2. Verificar SQL gerado
3. Adicionar índices e constraints
4. Preparar rollback seguro

### Fase 4: Implementação do Repository (70%)
1. Criar VehicleRepository em shared/repositories.py
2. Implementar métodos CRUD básicos
3. Adicionar métodos de busca específicos
4. Implementar validações de negócio

### Fase 5: Aplicação e Testes (90%)
1. Aplicar migration no banco
2. Verificar criação da tabela
3. Testar inserção de dados exemplo
4. Validar relacionamentos

### Fase 6: Documentação (100%)
1. Atualizar README do projeto
2. Documentar nova tabela em docs/
3. Gerar relatório de execução
4. Criar guia de uso

## 📝 Estrutura a Implementar

### Modelo Vehicle
```python
class Vehicle(Base):
    __tablename__ = 'vehicles'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    uuid = Column(String(36), unique=True, nullable=False)
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
    
    # Relacionamentos
    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'))
    primary_device_id = Column(Integer, ForeignKey('devices.id', ondelete='SET NULL'))
    
    # Status
    status = Column(String(20), default='inactive', nullable=False)
    odometer = Column(Integer, default=0, nullable=False)
    last_location = Column(Text, nullable=True)
    
    # Manutenção
    next_maintenance_date = Column(DateTime, nullable=True)
    next_maintenance_km = Column(Integer, nullable=True)
    insurance_expiry = Column(DateTime, nullable=True)
    license_expiry = Column(DateTime, nullable=True)
    
    # Sistema
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
```

### Tabela Associativa
```python
vehicle_devices = Table(
    'vehicle_devices', Base.metadata,
    Column('vehicle_id', Integer, ForeignKey('vehicles.id', ondelete='CASCADE')),
    Column('device_id', Integer, ForeignKey('devices.id', ondelete='CASCADE')),
    Column('installed_at', DateTime, default=func.now()),
    Column('is_primary', Boolean, default=False),
    PrimaryKeyConstraint('vehicle_id', 'device_id')
)
```

## 🔧 Métodos do Repository

### CRUD Básico
- `create_vehicle(data: dict) -> dict`
- `get_vehicle(vehicle_id: int) -> dict`
- `get_vehicle_by_plate(plate: str) -> dict`
- `update_vehicle(vehicle_id: int, data: dict) -> dict`
- `delete_vehicle(vehicle_id: int) -> bool`

### Listagens
- `get_user_vehicles(user_id: int) -> List[dict]`
- `get_active_vehicles() -> List[dict]`
- `get_vehicles_by_brand(brand: str) -> List[dict]`
- `search_vehicles(query: str) -> List[dict]`

### Status e Telemetria
- `update_odometer(vehicle_id: int, km: int) -> bool`
- `update_location(vehicle_id: int, lat: float, lng: float) -> bool`
- `update_status(vehicle_id: int, status: str) -> bool`
- `get_vehicle_telemetry(vehicle_id: int) -> dict`

### Manutenção
- `get_maintenance_due() -> List[dict]`
- `update_maintenance(vehicle_id: int, data: dict) -> bool`
- `get_expiring_documents(days: int) -> List[dict]`

### Dispositivos
- `assign_device(vehicle_id: int, device_id: int) -> bool`
- `remove_device(vehicle_id: int, device_id: int) -> bool`
- `get_vehicle_devices(vehicle_id: int) -> List[dict]`

## ✅ Checklist de Implementação

- [ ] Modelo Vehicle adicionado ao models.py
- [ ] Tabela vehicle_devices criada
- [ ] Migration gerada com auto_migrate.py
- [ ] Índices criados corretamente
- [ ] Constraints aplicadas
- [ ] VehicleRepository implementado
- [ ] Métodos CRUD funcionais
- [ ] Validações de negócio implementadas
- [ ] Migration aplicada com sucesso
- [ ] Testes básicos executados
- [ ] Documentação atualizada

## 🧪 Testes de Validação

### Teste de Criação
```python
# Criar veículo de teste
vehicle_data = {
    "plate": "ABC1D23",
    "chassis": "9BWZZZ377VT000001",
    "renavam": "12345678901",
    "brand": "Volkswagen",
    "model": "Gol",
    "year_manufacture": 2023,
    "year_model": 2024,
    "fuel_type": "flex",
    "user_id": 1
}
```

### Teste de Relacionamentos
```python
# Associar dispositivo
assign_device(vehicle_id, device_id)
# Verificar dispositivos do veículo
devices = get_vehicle_devices(vehicle_id)
```

### Teste de Busca
```python
# Buscar por placa
vehicle = get_vehicle_by_plate("ABC1D23")
# Buscar veículos do usuário
vehicles = get_user_vehicles(1)
```

## 📊 Output Esperado

Arquivo `A04-VEHICLE-CREATION-[DATA].md` contendo:
1. Status da implementação
2. Código do modelo implementado
3. Migration SQL gerada
4. Métodos do repository criados
5. Resultados dos testes
6. Instruções de uso

## ⚠️ Validações Importantes

1. **Placa**: Formato brasileiro (ABC1234 ou ABC1D23)
2. **Chassi**: 17 caracteres alfanuméricos
3. **Renavam**: 11 dígitos numéricos
4. **Anos**: year_model pode ser no máximo year_manufacture + 1
5. **Odômetro**: Sempre >= 0
6. **Status**: Valores válidos definidos
7. **Fuel Type**: Valores padronizados

## 🚀 Próximos Passos

Após execução bem-sucedida:
1. Testar integração com gateway
2. Implementar endpoints na API
3. Criar interface no frontend
4. Configurar telemetria de veículos
5. Implementar alertas de manutenção

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/08/2025  
**Dependência**: A03-VEHICLE-TABLE-ANALYZER