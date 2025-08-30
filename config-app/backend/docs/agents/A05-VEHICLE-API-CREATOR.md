# 🚗 A05-VEHICLE-API-CREATOR - Criador de API de Veículos (Simplificado)

## 📋 Objetivo

Agente autônomo para implementar endpoints CRUD simples para cadastro independente de veículos no backend FastAPI do AutoCore, sem relacionamentos com outras tabelas.

## 🎯 Missão

Criar rotas RESTful básicas, schemas Pydantic simples e validações para um cadastro standalone de veículos.

## ⚙️ Configuração

```yaml
tipo: implementation
prioridade: alta
autônomo: true
projeto: config-app/backend
dependência: database/VehicleRepository
output: docs/agents/executed/A05-VEHICLE-API-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Análise (10%)
1. Verificar estrutura atual do backend
2. Localizar main.py e routers existentes
3. Analisar endpoint `/config/full` atual
4. Verificar sistema de autenticação JWT

### Fase 2: Schemas Pydantic (25%)
1. Criar `src/schemas/vehicle_schemas.py`
2. Definir VehicleBase, VehicleCreate, VehicleUpdate
3. Definir VehicleResponse, VehicleList
4. Adicionar validações customizadas (placa, chassi, renavam)

### Fase 3: Router de Veículos (50%)
1. Criar `src/routers/vehicles.py`
2. Implementar endpoints CRUD básicos
3. Adicionar endpoints especializados
4. Integrar autenticação JWT
5. Adicionar tratamento de erros

### Fase 4: Integração (70%)
1. Importar VehicleRepository do database
2. Atualizar main.py para incluir router
3. Modificar `/config/full` para incluir vehicles
4. Adicionar dependências necessárias

### Fase 5: Validações e Segurança (85%)
1. Implementar validações de negócio
2. Adicionar rate limiting
3. Configurar CORS adequadamente
4. Implementar logs estruturados

### Fase 6: Testes e Documentação (100%)
1. Criar testes básicos dos endpoints
2. Verificar documentação OpenAPI
3. Testar integração com database
4. Gerar relatório de execução

## 📝 Schemas a Implementar

### VehicleBase
```python
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime

class VehicleBase(BaseModel):
    """Schema base para veículos - cadastro independente"""
    plate: str = Field(..., min_length=7, max_length=10, description="Placa do veículo")
    chassis: str = Field(..., min_length=17, max_length=30, description="Chassi/VIN")
    renavam: str = Field(..., min_length=11, max_length=20, description="RENAVAM")
    brand: str = Field(..., max_length=50, description="Marca")
    model: str = Field(..., max_length=100, description="Modelo")
    version: Optional[str] = Field(None, max_length=100, description="Versão")
    year_manufacture: int = Field(..., ge=1900, le=2100, description="Ano de fabricação")
    year_model: int = Field(..., ge=1900, le=2100, description="Ano modelo")
    color: Optional[str] = Field(None, max_length=30, description="Cor")
    fuel_type: str = Field(..., description="Tipo de combustível")
    engine_capacity: Optional[int] = Field(None, description="Cilindradas em cc")
    engine_power: Optional[int] = Field(None, description="Potência em cv")
    transmission: Optional[str] = Field(None, max_length=20, description="Tipo de transmissão")
    
    @validator('plate')
    def validate_plate(cls, v):
        # Validar formato brasileiro: ABC1234 ou ABC1D23
        import re
        pattern = r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$'
        if not re.match(pattern, v.upper()):
            raise ValueError('Placa inválida. Use formato ABC1234 ou ABC1D23')
        return v.upper()
    
    @validator('chassis')
    def validate_chassis(cls, v):
        if len(v) != 17:
            raise ValueError('Chassi deve ter 17 caracteres')
        return v.upper()
    
    @validator('renavam')
    def validate_renavam(cls, v):
        if not v.isdigit() or len(v) != 11:
            raise ValueError('RENAVAM deve ter 11 dígitos numéricos')
        return v
```

### VehicleCreate
```python
class VehicleCreate(VehicleBase):
    """Schema para criação de veículo - sem relacionamentos"""
    status: str = Field(default='active', description="Status do veículo")
    odometer: int = Field(default=0, ge=0, description="Quilometragem")
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = None
    insurance_expiry: Optional[datetime] = None
    license_expiry: Optional[datetime] = None
    notes: Optional[str] = Field(None, description="Observações")
```

### VehicleUpdate
```python
class VehicleUpdate(BaseModel):
    color: Optional[str] = None
    odometer: Optional[int] = Field(None, ge=0)
    status: Optional[str] = None
    primary_device_id: Optional[int] = None
    next_maintenance_date: Optional[datetime] = None
    next_maintenance_km: Optional[int] = None
    insurance_expiry: Optional[datetime] = None
    license_expiry: Optional[datetime] = None
    notes: Optional[str] = None
```

### VehicleResponse
```python
class VehicleResponse(VehicleBase):
    """Schema de resposta - veículo completo sem relacionamentos"""
    id: int
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

## 🛣️ Endpoints a Implementar

### CRUD Básico Simplificado
```python
# GET /api/vehicles
# Lista todos os veículos (com paginação)
@router.get("/", response_model=List[VehicleResponse])
async def list_vehicles(
    skip: int = 0,
    limit: int = 100,
    status: Optional[str] = None
):
    """Lista todos os veículos cadastrados"""

# GET /api/vehicles/{vehicle_id}
# Obtém detalhes de um veículo
@router.get("/{vehicle_id}", response_model=VehicleResponse)
async def get_vehicle(vehicle_id: int):
    """Obtém detalhes de um veículo específico"""

# POST /api/vehicles
# Cria novo veículo
@router.post("/", response_model=VehicleResponse, status_code=201)
async def create_vehicle(vehicle: VehicleCreate):
    """Cria novo veículo independente"""

# PUT /api/vehicles/{vehicle_id}
# Atualiza veículo
@router.put("/{vehicle_id}", response_model=VehicleResponse)
async def update_vehicle(
    vehicle_id: int,
    vehicle: VehicleUpdate
):
    """Atualiza dados do veículo"""

# DELETE /api/vehicles/{vehicle_id}
# Remove veículo (soft delete)
@router.delete("/{vehicle_id}", status_code=204)
async def delete_vehicle(vehicle_id: int):
    """Remove veículo (soft delete)"""
```

### Endpoints Adicionais (Simplificados)
```python
# GET /api/vehicles/plate/{plate}
# Busca veículo por placa
@router.get("/plate/{plate}", response_model=VehicleResponse)

# GET /api/vehicles/search
# Busca veículos por texto
@router.get("/search", response_model=List[VehicleResponse])
async def search_vehicles(q: str):
    """Busca por placa, marca ou modelo"""

# PUT /api/vehicles/{vehicle_id}/odometer
# Atualiza quilometragem
@router.put("/{vehicle_id}/odometer")
async def update_odometer(vehicle_id: int, odometer: int):
    """Atualiza quilometragem do veículo"""

# GET /api/vehicles/status/{status}
# Lista veículos por status
@router.get("/status/{status}", response_model=List[VehicleResponse])

# GET /api/vehicles/maintenance/due
# Lista veículos com manutenção pendente
@router.get("/maintenance/due")

# GET /api/vehicles/documents/expiring
# Lista veículos com documentos vencendo
@router.get("/documents/expiring")
```

## 🔧 Integração com /config/full

### ⚠️ IMPORTANTE: Array Standalone
Os veículos devem ser incluídos como um **array independente** no `/config/full`, sem filtro de usuário, pois a tabela vehicles não tem relacionamentos.

### Modificação do Endpoint Existente
```python
# Em src/routers/config.py ou onde estiver definido

@router.get("/config/full")
async def get_full_config():
    """Retorna configuração completa incluindo array de veículos"""
    
    # ... código existente ...
    
    # Adicionar array de veículos (standalone, sem filtro de usuário)
    vehicles = vehicle_repository.get_all_vehicles()
    
    # Adicionar diretamente como array no config
    config["vehicles"] = vehicles  # Array simples de todos os veículos
    
    # Ou se preferir com mais informações:
    config["vehicles"] = {
        "items": vehicles,  # Array de veículos
        "total": len(vehicles),
        "active_count": len([v for v in vehicles if v.get("status") == "active"]),
        "maintenance_due_count": len(vehicle_repository.get_maintenance_due()),
        "last_updated": datetime.now().isoformat()
    }
    
    return config
```

### Estrutura Resultante no /config/full
```json
{
  "devices": [...],
  "relays": [...],
  "screens": [...],
  "vehicles": [
    {
      "id": 1,
      "uuid": "123e4567-e89b-12d3-a456-426614174000",
      "plate": "ABC1D23",
      "chassis": "9BWZZZ377VT000001",
      "renavam": "12345678901",
      "brand": "Volkswagen",
      "model": "Gol",
      "year_manufacture": 2023,
      "year_model": 2024,
      "fuel_type": "flex",
      "status": "active",
      "odometer": 15000,
      "is_active": true
    },
    {
      "id": 2,
      "plate": "XYZ9K88",
      "brand": "Toyota",
      "model": "Corolla",
      ...
    }
  ],
  "other_configs": {...}
}
```

## ⚠️ Validações de Negócio

1. **Unicidade**: Placa, chassi e renavam devem ser únicos
2. **Propriedade**: Usuário só pode modificar seus veículos (exceto admin)
3. **Dispositivos**: Verificar se dispositivo existe antes de associar
4. **Anos**: year_model <= year_manufacture + 1
5. **Odômetro**: Nunca pode diminuir (apenas aumentar)
6. **Status**: Valores válidos: active, inactive, maintenance, retired
7. **Fuel Type**: flex, gasoline, ethanol, diesel, electric, hybrid

## 🔒 Segurança

### Autenticação e Autorização
```python
from src.auth import get_current_user, get_current_admin_user

# Endpoints públicos: Nenhum
# Endpoints autenticados: Todos
# Endpoints admin: /user/{user_id}, relatórios gerais

# Verificar propriedade
def verify_vehicle_owner(vehicle_id: int, user_id: int):
    vehicle = vehicle_repository.get_vehicle(vehicle_id)
    if not vehicle or vehicle["user_id"] != user_id:
        raise HTTPException(status_code=403, message="Acesso negado")
```

### Rate Limiting
```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@router.post("/", response_model=VehicleResponse)
@limiter.limit("5/minute")  # Máximo 5 criações por minuto
async def create_vehicle(...):
    pass
```

## 📊 Logs Estruturados
```python
import logging
logger = logging.getLogger(__name__)

# Em cada endpoint
logger.info(f"Vehicle created", extra={
    "user_id": current_user.id,
    "vehicle_id": vehicle.id,
    "plate": vehicle.plate
})
```

## ✅ Checklist de Implementação

- [ ] Schemas Pydantic criados e validados
- [ ] Router vehicles.py implementado
- [ ] Todos os endpoints CRUD funcionais
- [ ] Endpoints especializados implementados
- [ ] Integração com VehicleRepository
- [ ] Autenticação JWT configurada
- [ ] Validações de negócio aplicadas
- [ ] /config/full modificado
- [ ] Rate limiting configurado
- [ ] Logs estruturados
- [ ] Testes básicos criados
- [ ] Documentação OpenAPI gerada

## 🧪 Testes de Validação

### Teste de Criação
```bash
curl -X POST http://localhost:8000/api/vehicles \
  -H "Authorization: Bearer $TOKEN" \
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
```

### Teste de Listagem
```bash
curl -X GET http://localhost:8000/api/vehicles \
  -H "Authorization: Bearer $TOKEN"
```

### Teste de Atualização
```bash
curl -X PUT http://localhost:8000/api/vehicles/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "odometer": 15000,
    "status": "active"
  }'
```

## 📊 Output Esperado

Arquivo `A05-VEHICLE-API-[DATA].md` contendo:
1. Status da implementação
2. Endpoints criados e testados
3. Schemas implementados
4. Integração com /config/full
5. Logs de testes realizados
6. Instruções de uso da API

## 🚀 Próximos Passos

Após execução bem-sucedida:
1. Testar todos os endpoints via Swagger UI
2. Implementar testes automatizados
3. Configurar webhooks para eventos
4. Implementar cache Redis para performance
5. Adicionar métricas Prometheus

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/08/2025  
**Dependência**: database/VehicleRepository