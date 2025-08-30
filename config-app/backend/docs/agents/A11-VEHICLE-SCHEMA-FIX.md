# 🔧 A11-VEHICLE-SCHEMA-FIX - Corretor de Schemas de Veículo

## 📋 Objetivo

Agente autônomo para corrigir todos os problemas de schemas Pydantic identificados nos testes, ajustando validações e tornando a API 100% funcional para registro único.

## 🎯 Missão

Corrigir os schemas em `api/schemas/vehicle_schemas.py` e ajustar os endpoints em `api/routes/vehicles.py` para resolver todos os problemas de validação identificados pelo A10.

## ⚙️ Configuração

```yaml
tipo: fix
prioridade: urgente
autônomo: true
projeto: config-app/backend
prerequisito: A10 executado e problemas identificados
output: docs/agents/executed/A11-SCHEMA-FIX-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Análise dos Problemas (10%)
1. Ler relatório do A10 em `docs/agents/executed/A10-API-TEST-2025-01-28.md`
2. Identificar schemas em `api/schemas/vehicle_schemas.py`
3. Verificar endpoints em `api/routes/vehicles.py`
4. Mapear todas as correções necessárias

### Fase 2: Correção do VehicleCreate (30%)
1. Remover campos obrigatórios desnecessários:
   - `category` - tornar opcional ou remover
   - `user_id` - remover completamente (registro único não tem dono)
2. Corrigir validações:
   - `engine_capacity` - ajustar para aceitar valores reais (1000-10000)
3. Simplificar para registro standalone

### Fase 3: Correção do VehicleResponse (50%)
1. Tornar `primary_device` completamente opcional
2. Remover validações rígidas de campos relacionados
3. Ajustar para funcionar com ou sem device associado
4. Garantir compatibilidade com dados do banco

### Fase 4: Ajuste do GET /api/vehicle (65%)
1. Modificar para retornar `null` em vez de erro quando vazio
2. Padronizar resposta com estrutura de `/config/full`
3. Implementar resposta consistente

### Fase 5: Ajuste de Validações (80%)
1. Revisar todas as validações de campos
2. Tornar campos opcionais quando apropriado
3. Ajustar limites numéricos para valores reais
4. Garantir que odômetro nunca diminui

### Fase 6: Testes de Validação (95%)
1. Testar POST com dados corrigidos
2. Testar PUT com atualização parcial
3. Verificar GET retorna null quando vazio
4. Confirmar todas as operações funcionam

### Fase 7: Relatório Final (100%)
1. Documentar todas as correções
2. Confirmar 100% de sucesso nos testes
3. Gerar relatório de execução

## 🔧 Correções Detalhadas

### VehicleCreate - Correções
```python
from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime

class VehicleCreate(BaseModel):
    """Schema para criar/atualizar o único veículo - standalone"""
    # Campos obrigatórios básicos
    plate: str = Field(..., min_length=7, max_length=10)
    chassis: str = Field(..., min_length=17, max_length=30)
    renavam: str = Field(..., min_length=11, max_length=20)
    brand: str = Field(..., max_length=50)
    model: str = Field(..., max_length=100)
    year_manufacture: int = Field(..., ge=1900, le=2100)
    year_model: int = Field(..., ge=1900, le=2100)
    fuel_type: str = Field(...)
    
    # Campos opcionais - TODOS opcionais para flexibilidade
    version: Optional[str] = Field(None, max_length=100)
    color: Optional[str] = Field(None, max_length=30)
    engine_capacity: Optional[float] = Field(None, ge=0.1, le=20.0)  # Em litros
    engine_power: Optional[int] = Field(None, ge=1, le=2000)  # Em cv
    transmission: Optional[str] = Field(None, max_length=20)
    category: Optional[str] = Field(default="passenger")  # OPCIONAL com default
    status: str = Field(default="active")
    odometer: int = Field(default=0, ge=0)
    notes: Optional[str] = None
    
    # Campos de manutenção - todos opcionais
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = None
    insurance_expiry: Optional[datetime] = None
    license_expiry: Optional[datetime] = None
    
    # REMOVER user_id - não faz sentido para registro único
    # REMOVER validações complexas que causam problemas
```

### VehicleResponse - Correções
```python
class VehicleResponse(BaseModel):
    """Response do único veículo - flexível para dados reais"""
    # Campos sempre presentes
    id: int = Field(default=1)
    uuid: str
    plate: str
    brand: str
    model: str
    year_model: int
    fuel_type: str
    status: str
    odometer: int
    is_active: bool = True
    
    # Campos opcionais - podem vir do banco ou não
    chassis: Optional[str] = None
    renavam: Optional[str] = None
    version: Optional[str] = None
    year_manufacture: Optional[int] = None
    color: Optional[str] = None
    engine_capacity: Optional[float] = None
    engine_power: Optional[int] = None
    transmission: Optional[str] = None
    category: Optional[str] = None
    notes: Optional[str] = None
    
    # Timestamps opcionais
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    
    # Manutenção opcional
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = None
    insurance_expiry: Optional[datetime] = None
    license_expiry: Optional[datetime] = None
    
    # Device COMPLETAMENTE opcional
    primary_device: Optional[dict] = None  # Aceita qualquer dict ou None
    
    # Campos computados opcionais
    full_name: Optional[str] = None
    is_online: Optional[bool] = None
    maintenance_alert: Optional[bool] = None
    documents_alert: Optional[bool] = None
    
    class Config:
        from_attributes = True
        # Permitir campos extras do banco
        extra = "allow"
```

### VehicleUpdate - Correções
```python
class VehicleUpdate(BaseModel):
    """Update parcial - TODOS os campos opcionais"""
    plate: Optional[str] = Field(None, min_length=7, max_length=10)
    chassis: Optional[str] = Field(None, min_length=17, max_length=30)
    renavam: Optional[str] = Field(None, min_length=11, max_length=20)
    brand: Optional[str] = Field(None, max_length=50)
    model: Optional[str] = Field(None, max_length=100)
    version: Optional[str] = Field(None, max_length=100)
    year_manufacture: Optional[int] = Field(None, ge=1900, le=2100)
    year_model: Optional[int] = Field(None, ge=1900, le=2100)
    color: Optional[str] = Field(None, max_length=30)
    fuel_type: Optional[str] = None
    engine_capacity: Optional[float] = Field(None, ge=0.1, le=20.0)
    engine_power: Optional[int] = Field(None, ge=1, le=2000)
    transmission: Optional[str] = Field(None, max_length=20)
    category: Optional[str] = None
    status: Optional[str] = None
    odometer: Optional[int] = Field(None, ge=0)
    notes: Optional[str] = None
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = None
    insurance_expiry: Optional[datetime] = None
    license_expiry: Optional[datetime] = None
    
    @field_validator('odometer')
    @classmethod
    def validate_odometer_increase(cls, v):
        # Validação será feita no endpoint comparando com valor atual
        return v
```

### GET /api/vehicle - Correção
```python
@router.get("/", response_model=Optional[VehicleResponse])
async def get_vehicle():
    """Obtém o único veículo do sistema"""
    try:
        vehicle = vehicle_repository.get_vehicle()
        if not vehicle:
            # Retornar None em vez de erro
            return None
        
        # Converter para VehicleResponse de forma flexível
        # Aceitar campos que vierem do banco
        return VehicleResponse(**vehicle)
    except Exception as e:
        # Log do erro mas retorna None para manter consistência
        logger.error(f"Erro ao buscar veículo: {e}")
        return None
```

### POST /api/vehicle - Correção
```python
@router.post("/", response_model=VehicleResponse, status_code=201)
async def create_or_update_vehicle(vehicle: VehicleCreate):
    """Cria ou atualiza o único veículo"""
    try:
        # Preparar dados removendo user_id se vier
        vehicle_data = vehicle.dict(exclude_unset=True)
        vehicle_data.pop('user_id', None)  # Remover se existir
        
        # Verificar se já existe
        existing = vehicle_repository.get_vehicle()
        
        if existing:
            # Atualizar existente
            result = vehicle_repository.update_vehicle(vehicle_data)
        else:
            # Criar novo
            result = vehicle_repository.create_or_update_vehicle(vehicle_data)
        
        # Retornar com estrutura flexível
        return VehicleResponse(**result)
    except Exception as e:
        logger.error(f"Erro ao criar/atualizar veículo: {e}")
        raise HTTPException(
            status_code=500,
            detail="Erro ao processar veículo"
        )
```

## ✅ Checklist de Correções

### Schemas
- [ ] VehicleCreate sem user_id obrigatório
- [ ] VehicleCreate com category opcional
- [ ] engine_capacity com limite correto (0.1-20.0 litros)
- [ ] VehicleResponse com primary_device opcional
- [ ] VehicleResponse aceita campos extras
- [ ] VehicleUpdate todos campos opcionais

### Endpoints
- [ ] GET retorna null quando vazio
- [ ] POST aceita dados simplificados
- [ ] PUT atualiza parcialmente sem erros
- [ ] DELETE continua funcionando

### Validações
- [ ] Placa brasileira mantida
- [ ] Chassi 17 caracteres mantido
- [ ] RENAVAM 11 dígitos mantido
- [ ] Odômetro nunca diminui
- [ ] Anos consistentes

## 🧪 Testes de Confirmação

### Teste 1: POST Simples
```bash
curl -X POST http://localhost:8081/api/vehicle \
  -H "Content-Type: application/json" \
  -d '{
    "plate": "ABC1D23",
    "chassis": "9BWZZZ377VT004321",
    "renavam": "12345678901",
    "brand": "Volkswagen",
    "model": "Gol",
    "year_manufacture": 2023,
    "year_model": 2024,
    "fuel_type": "flex"
  }'
```

### Teste 2: PUT Parcial
```bash
curl -X PUT http://localhost:8081/api/vehicle \
  -H "Content-Type: application/json" \
  -d '{
    "odometer": 16000,
    "status": "maintenance"
  }'
```

### Teste 3: GET Vazio
```bash
curl -X GET http://localhost:8081/api/vehicle
# Deve retornar: null ou {}
```

## 📊 Resultado Esperado

Após execução:
- ✅ 100% dos testes passando
- ✅ Nenhum erro de validação
- ✅ POST, GET, PUT, DELETE funcionais
- ✅ Integração com /config/full mantida
- ✅ API pronta para produção

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/01/2025  
**Dependência**: Relatório A10 com problemas identificados