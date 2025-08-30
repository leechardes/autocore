# 🚗 A09-VEHICLE-API-SINGLE-RECORD-ADJUSTER - Ajustador de API para Registro Único

## 📋 Objetivo

Agente autônomo para ajustar os endpoints da API de veículos para trabalhar com **apenas 1 registro único**, modificando rotas e schemas já implementados pelo A05.

## 🎯 Missão

Refatorar endpoints, schemas e integração com `/config/full` para suportar apenas 1 veículo no sistema, retornando objeto único em vez de arrays.

## ⚙️ Configuração

```yaml
tipo: adjustment
prioridade: urgente
autônomo: true
prerequisito: A05-VEHICLE-API-CREATOR já executado
dependencia: database/A08-VEHICLE-SINGLE-RECORD-ADJUSTER
output: docs/agents/executed/A09-API-SINGLE-ADJUST-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Análise do Estado Atual (10%)
1. Verificar rotas em `src/routers/vehicles.py`
2. Verificar schemas em `src/schemas/vehicle_schemas.py`
3. Verificar integração em `/config/full`
4. Identificar mudanças necessárias

### Fase 2: Ajuste dos Schemas (25%)
1. Manter schemas base (VehicleBase, VehicleUpdate)
2. Ajustar VehicleCreate para não precisar validar unicidade
3. Simplificar VehicleResponse
4. Remover schemas de listagem

### Fase 3: Refatoração dos Endpoints (50%)
1. Ajustar endpoints para registro único:
   - `GET /api/vehicle` - retorna o único veículo (sem ID na rota)
   - `POST /api/vehicle` - cria ou atualiza o único veículo
   - `PUT /api/vehicle` - atualiza o único veículo
   - `DELETE /api/vehicle` - remove o único veículo
2. Remover endpoints de listagem e busca múltipla
3. Ajustar rotas que usavam ID

### Fase 4: Integração /config/full (70%)
1. Modificar para retornar objeto único
2. Remover arrays e contadores
3. Retornar `null` se não houver veículo
4. Simplificar estrutura

### Fase 5: Validação e Documentação (100%)
1. Testar todos os endpoints
2. Verificar integração com frontend
3. Atualizar documentação OpenAPI
4. Gerar relatório

## 📝 Schemas Ajustados

### Schemas Mantidos (com ajustes mínimos)
```python
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime

class VehicleBase(BaseModel):
    """Schema base para o único veículo"""
    plate: str = Field(..., min_length=7, max_length=10)
    chassis: str = Field(..., min_length=17, max_length=30)
    renavam: str = Field(..., min_length=11, max_length=20)
    brand: str = Field(..., max_length=50)
    model: str = Field(..., max_length=100)
    version: Optional[str] = Field(None, max_length=100)
    year_manufacture: int = Field(..., ge=1900, le=2100)
    year_model: int = Field(..., ge=1900, le=2100)
    color: Optional[str] = Field(None, max_length=30)
    fuel_type: str
    engine_capacity: Optional[int] = None
    engine_power: Optional[int] = None
    transmission: Optional[str] = Field(None, max_length=20)
    # validadores mantidos...

class VehicleCreate(VehicleBase):
    """Schema para criar/atualizar o único veículo"""
    status: str = Field(default='active')
    odometer: int = Field(default=0, ge=0)
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = None
    insurance_expiry: Optional[datetime] = None
    license_expiry: Optional[datetime] = None
    notes: Optional[str] = None

class VehicleUpdate(BaseModel):
    """Schema para atualização parcial"""
    plate: Optional[str] = None
    color: Optional[str] = None
    odometer: Optional[int] = Field(None, ge=0)
    status: Optional[str] = None
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = None
    insurance_expiry: Optional[datetime] = None
    license_expiry: Optional[datetime] = None
    notes: Optional[str] = None

class VehicleResponse(VehicleBase):
    """Response do único veículo"""
    id: int = Field(default=1)  # Sempre 1
    uuid: str
    status: str
    odometer: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    next_maintenance_date: Optional[datetime]
    next_maintenance_km: Optional[int]
    insurance_expiry: Optional[datetime]
    license_expiry: Optional[datetime]
    notes: Optional[str]
    
    class Config:
        orm_mode = True
```

## 🛣️ Endpoints Ajustados para Registro Único

### Router Refatorado
```python
from fastapi import APIRouter, HTTPException, status
from typing import Optional
from src.schemas.vehicle_schemas import VehicleCreate, VehicleUpdate, VehicleResponse

router = APIRouter(prefix="/api/vehicle", tags=["vehicle"])  # Singular!

# GET /api/vehicle
# Retorna o único veículo cadastrado
@router.get("/", response_model=Optional[VehicleResponse])
async def get_vehicle():
    """Obtém o único veículo do sistema"""
    vehicle = vehicle_repository.get_vehicle()
    if not vehicle:
        return None  # Ou raise HTTPException(404, "Nenhum veículo cadastrado")
    return vehicle

# POST /api/vehicle
# Cria ou atualiza o único veículo
@router.post("/", response_model=VehicleResponse, status_code=201)
async def create_or_update_vehicle(vehicle: VehicleCreate):
    """Cria o veículo se não existir, ou atualiza se já existir"""
    existing = vehicle_repository.get_vehicle()
    if existing:
        # Atualiza o existente
        result = vehicle_repository.update_vehicle(vehicle.dict())
        return result
    else:
        # Cria novo
        result = vehicle_repository.create_or_update_vehicle(vehicle.dict())
        return result

# PUT /api/vehicle
# Atualiza parcialmente o único veículo
@router.put("/", response_model=VehicleResponse)
async def update_vehicle(vehicle: VehicleUpdate):
    """Atualiza campos específicos do único veículo"""
    existing = vehicle_repository.get_vehicle()
    if not existing:
        raise HTTPException(
            status_code=404,
            detail="Nenhum veículo cadastrado. Use POST para criar."
        )
    
    # Atualiza apenas campos fornecidos
    update_data = vehicle.dict(exclude_unset=True)
    result = vehicle_repository.update_vehicle(update_data)
    return result

# DELETE /api/vehicle  
# Remove (soft delete) o único veículo
@router.delete("/", status_code=204)
async def delete_vehicle():
    """Remove o único veículo do sistema (soft delete)"""
    success = vehicle_repository.delete_vehicle()
    if not success:
        raise HTTPException(404, "Nenhum veículo para remover")
    return None

# PUT /api/vehicle/odometer
# Atualiza apenas a quilometragem
@router.put("/odometer", response_model=VehicleResponse)
async def update_odometer(odometer: int):
    """Atualiza quilometragem do único veículo"""
    vehicle = vehicle_repository.update_odometer(odometer)
    if not vehicle:
        raise HTTPException(404, "Nenhum veículo cadastrado ou odômetro inválido")
    return vehicle

# GET /api/vehicle/status
# Retorna status simplificado
@router.get("/status")
async def get_vehicle_status():
    """Retorna status do único veículo"""
    vehicle = vehicle_repository.get_vehicle()
    if not vehicle:
        return {"exists": False, "message": "Nenhum veículo cadastrado"}
    
    return {
        "exists": True,
        "plate": vehicle["plate"],
        "status": vehicle["status"],
        "odometer": vehicle["odometer"],
        "maintenance_due": vehicle.get("next_maintenance_km", 0) - vehicle["odometer"] < 1000
    }

# DELETE /api/vehicle/reset
# Remove completamente (hard delete) para novo cadastro
@router.delete("/reset", status_code=204)
async def reset_vehicle():
    """Remove completamente o veículo para permitir novo cadastro"""
    vehicle_repository.reset_vehicle()
    return None
```

## 🔧 Integração com /config/full

### Ajuste no Endpoint /config/full
```python
# Em src/routers/config.py

@router.get("/config/full")
async def get_full_config():
    """Retorna configuração completa com o único veículo"""
    
    # ... código existente para devices, relays, etc ...
    
    # Adicionar o ÚNICO veículo como OBJETO (não array!)
    vehicle = vehicle_repository.get_vehicle_for_config()
    
    # Adiciona como objeto único ou null
    config["vehicles"] = vehicle  # Objeto único ou null
    
    # Alternativa com mais contexto:
    if vehicle:
        config["vehicle"] = {  # Note: singular!
            "configured": True,
            "data": vehicle,
            "maintenance_alert": vehicle.get("next_maintenance_km", 0) - vehicle.get("odometer", 0) < 1000,
            "documents_alert": check_document_expiry(vehicle)
        }
    else:
        config["vehicle"] = {
            "configured": False,
            "data": None,
            "message": "Nenhum veículo cadastrado"
        }
    
    return config
```

### Estrutura Final no /config/full
```json
{
  "devices": [...],
  "relays": [...],
  "screens": [...],
  "vehicle": {  // Objeto único, não array!
    "configured": true,
    "data": {
      "id": 1,
      "uuid": "123e4567-e89b-12d3-a456-426614174000",
      "plate": "ABC1D23",
      "chassis": "9BWZZZ377VT000001",
      "renavam": "12345678901",
      "brand": "Volkswagen",
      "model": "Gol",
      "year_model": 2024,
      "fuel_type": "flex",
      "status": "active",
      "odometer": 15000,
      "next_maintenance_km": 20000
    },
    "maintenance_alert": false,
    "documents_alert": false
  }
}

// Ou quando não há veículo:
{
  "devices": [...],
  "vehicle": {
    "configured": false,
    "data": null,
    "message": "Nenhum veículo cadastrado"
  }
}
```

## ⚠️ Mudanças Importantes

### Rotas Alteradas
| Antes (múltiplos) | Depois (único) |
|-------------------|----------------|
| GET `/api/vehicles` | GET `/api/vehicle` |
| GET `/api/vehicles/{id}` | GET `/api/vehicle` |
| POST `/api/vehicles` | POST `/api/vehicle` |
| PUT `/api/vehicles/{id}` | PUT `/api/vehicle` |
| DELETE `/api/vehicles/{id}` | DELETE `/api/vehicle` |

### Removidos
- Endpoints de listagem
- Endpoints de busca
- Endpoints por usuário
- Paginação
- Filtros

## ✅ Checklist de Implementação

- [ ] Schemas ajustados para registro único
- [ ] Router renomeado para singular (/api/vehicle)
- [ ] Endpoints refatorados sem ID na rota
- [ ] GET retorna objeto ou null
- [ ] POST cria ou atualiza
- [ ] PUT atualiza parcialmente
- [ ] DELETE faz soft delete
- [ ] /config/full retorna objeto único
- [ ] Documentação OpenAPI atualizada
- [ ] Testes ajustados

## 🧪 Testes de Validação

```bash
# Teste 1: Obter veículo (vazio inicialmente)
curl -X GET http://localhost:8000/api/vehicle
# Response: null ou {}

# Teste 2: Criar único veículo
curl -X POST http://localhost:8000/api/vehicle \
  -H "Content-Type: application/json" \
  -d '{
    "plate": "ABC1D23",
    "chassis": "9BWZZZ377VT000001",
    "renavam": "12345678901",
    "brand": "Volkswagen",
    "model": "Gol",
    "year_manufacture": 2023,
    "year_model": 2024,
    "fuel_type": "flex"
  }'

# Teste 3: Tentar criar outro (deve atualizar)
curl -X POST http://localhost:8000/api/vehicle \
  -H "Content-Type: application/json" \
  -d '{
    "plate": "XYZ9K88",
    ...
  }'
# Deve atualizar o existente, não criar novo

# Teste 4: Verificar /config/full
curl -X GET http://localhost:8000/api/config/full
# vehicle deve ser objeto, não array
```

## 📊 Output Esperado

Arquivo `A09-API-SINGLE-ADJUST-[DATA].md` contendo:
1. Status dos ajustes realizados
2. Endpoints modificados
3. Schemas ajustados
4. Integração /config/full corrigida
5. Testes executados
6. Logs de validação

## 🚀 Resultado Final

- API com endpoints no **singular** (`/api/vehicle`)
- Sempre trabalha com **1 único registro**
- `/config/full` retorna **objeto único**
- Sem listagens ou arrays

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/08/2025  
**Prerequisito**: A05 executado e A08 aplicado no database