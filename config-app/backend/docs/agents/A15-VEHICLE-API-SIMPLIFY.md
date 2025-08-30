# 🎯 A15-VEHICLE-API-SIMPLIFY - Simplificador de Resposta da API

## 📋 Objetivo

Agente autônomo para simplificar a resposta da API de veículo, removendo dados desnecessários como owner, devices e retornando apenas dados da tabela vehicles. Também ajustar /config/full para sempre mostrar veículo independente de device.

## 🎯 Missão

Limpar a resposta da API para retornar apenas dados essenciais do veículo, sem informações de owner, devices ou outras tabelas relacionadas.

## ⚙️ Configuração

```yaml
tipo: optimization
prioridade: alta
autônomo: true
projeto: config-app/backend
objetivo: Simplificar resposta e remover dados desnecessários
output: docs/agents/executed/A15-API-SIMPLIFY-[DATA].md
```

## 🔴 Problema Atual

### GET /api/vehicle retorna dados DESNECESSÁRIOS:
```json
{
  "owner": {  // ❌ REMOVER
    "id": 4,
    "username": "test_user",
    "full_name": "Usuário de Teste",
    "email": "test@autocore.com"
  },
  "primary_device": {  // ❌ REMOVER
    "id": 9,
    "name": "ESP32 Test Device",
    "type": "esp32_display",
    "status": "offline"
  },
  "devices": [...]  // ❌ REMOVER
}
```

### GET /config/full problemas:
- Só mostra veículo quando há device_uuid
- Deveria sempre mostrar veículo independente de device

## ✅ Resultado Desejado

### GET /api/vehicle - APENAS dados do veículo:
```json
{
  "id": 1,
  "uuid": "...",
  "plate": "MNG4D56",
  "chassis": "LA1BSK29242",
  "renavam": "00179619063",
  "brand": "FORD",
  "model": "JEEP WILLYS",
  "year_manufacture": 1976,
  "year_model": 1976,
  "color": "VERMELHA",
  "fuel_type": "gasoline",
  "status": "active",
  "odometer": 0,
  // Apenas campos da tabela vehicles
}
```

### GET /config/full - Sempre incluir veículo:
```json
{
  "devices": [...],
  "vehicle": {  // Sempre presente
    "configured": true/false,
    "data": {...} ou null
  }
}
```

## 🔄 Fluxo de Execução

### Fase 1: Ajustar Schema VehicleResponse (20%)
1. Localizar `api/schemas/vehicle_schemas.py`
2. Encontrar classe VehicleResponse
3. Remover campos: owner, primary_device, devices
4. Manter apenas campos da tabela vehicles

### Fase 2: Ajustar Repository (40%)
1. Localizar `database/shared/vehicle_repository.py`
2. Método get_vehicle() - remover joins desnecessários
3. Método create_or_update_vehicle() - simplificar retorno
4. Retornar apenas dados da tabela vehicles

### Fase 3: Ajustar Endpoint GET (60%)
1. Localizar `api/routes/vehicles.py`
2. Verificar se está adicionando dados extras
3. Remover qualquer enriquecimento de dados
4. Retornar apenas o que vem do repository

### Fase 4: Ajustar /config/full (80%)
1. Localizar em `main.py` a função get_full_configuration
2. Garantir que busca veículo SEMPRE, não só com device_uuid
3. Mover busca de veículo para FORA da condição de preview
4. Retornar veículo independente de device

### Fase 5: Testar (95%)
1. GET /api/vehicle - verificar sem owner/devices
2. GET /config/full - verificar veículo presente
3. GET /config/full?preview=true - ainda deve ter veículo real

### Fase 6: Relatório (100%)
1. Documentar mudanças
2. Confirmar simplificação
3. Gerar relatório final

## 🔧 Correções Específicas

### 1. VehicleResponse - SIMPLIFICAR
```python
class VehicleResponse(BaseModel):
    """Response simplificado - apenas dados do veículo"""
    # Campos básicos
    id: int
    uuid: str
    plate: str
    chassis: str
    renavam: str
    brand: str
    model: str
    version: Optional[str]
    
    # Dados técnicos
    year_manufacture: int
    year_model: int
    color: Optional[str]
    fuel_type: str
    engine_capacity: Optional[float]
    engine_power: Optional[int]
    transmission: Optional[str]
    category: Optional[str]
    
    # Status
    status: str
    odometer: int
    is_active: bool
    
    # Datas
    created_at: Optional[datetime]
    updated_at: Optional[datetime]
    
    # REMOVER: owner, primary_device, devices, user_name, device_name
    
    class Config:
        from_attributes = True
```

### 2. Repository - SIMPLIFICAR get_vehicle()
```python
def get_vehicle(self) -> Optional[Dict]:
    """Retorna apenas dados da tabela vehicles"""
    try:
        # Query simples, sem joins
        vehicle = self.session.query(Vehicle).first()
        
        if not vehicle:
            return None
        
        # Retornar apenas campos do veículo
        return {
            'id': vehicle.id,
            'uuid': vehicle.uuid or str(uuid.uuid4()),
            'plate': vehicle.plate,
            'chassis': vehicle.chassis,
            'renavam': vehicle.renavam,
            'brand': vehicle.brand,
            'model': vehicle.model,
            'version': vehicle.version,
            'year_manufacture': vehicle.year_manufacture,
            'year_model': vehicle.year_model,
            'color': vehicle.color,
            'fuel_type': vehicle.fuel_type,
            'engine_capacity': vehicle.engine_capacity,
            'engine_power': vehicle.engine_power,
            'transmission': vehicle.transmission,
            'category': vehicle.category,
            'status': vehicle.status,
            'odometer': vehicle.odometer,
            'is_active': vehicle.is_active,
            'created_at': vehicle.created_at,
            'updated_at': vehicle.updated_at
        }
    except Exception as e:
        logger.error(f"Erro: {e}")
        return None
```

### 3. main.py - SEMPRE incluir veículo
```python
async def get_full_configuration(...):
    """Config completa com veículo SEMPRE"""
    
    # ... código existente ...
    
    # Buscar veículo INDEPENDENTE de preview ou device
    # FORA de qualquer condição
    try:
        vehicle_repo = create_vehicle_repository()
        vehicle_data = vehicle_repo.get_vehicle()
        
        if vehicle_data:
            config_data["vehicle"] = {
                "configured": True,
                "data": vehicle_data
            }
        else:
            config_data["vehicle"] = {
                "configured": False,
                "data": None
            }
    except Exception as e:
        logger.warning(f"Erro ao buscar veículo: {e}")
        config_data["vehicle"] = {
            "configured": False,
            "data": None
        }
    
    # ... resto do código ...
```

## ✅ Checklist de Simplificação

### Schema
- [ ] Remover campo owner de VehicleResponse
- [ ] Remover campo primary_device
- [ ] Remover campo devices
- [ ] Remover campos de relacionamento

### Repository
- [ ] Simplificar get_vehicle() para query básica
- [ ] Remover joins desnecessários
- [ ] Retornar apenas campos da tabela

### Endpoints
- [ ] GET /api/vehicle sem dados extras
- [ ] POST /api/vehicle retorno simplificado
- [ ] PUT /api/vehicle retorno simplificado

### Config/Full
- [ ] Veículo sempre presente
- [ ] Independente de device_uuid
- [ ] Fora da lógica de preview

## 🧪 Testes de Validação

### Teste 1: GET Vehicle Simplificado
```bash
curl -s http://localhost:8081/api/vehicle | jq 'keys'
# NÃO deve ter: owner, primary_device, devices
```

### Teste 2: Config/Full Sempre com Veículo
```bash
curl -s http://localhost:8081/api/config/full | jq '.vehicle'
# Deve sempre ter vehicle, mesmo sem device_uuid
```

### Teste 3: Preview com Veículo Real
```bash
curl -s "http://localhost:8081/api/config/full?preview=true" | jq '.vehicle.data.plate'
# Deve mostrar "MNG4D56" (veículo real)
```

## 📊 Resultado Esperado

Após execução:
1. ✅ GET /api/vehicle retorna APENAS dados do veículo
2. ✅ Sem owner, devices ou primary_device
3. ✅ Config/full SEMPRE inclui veículo
4. ✅ Resposta mais limpa e eficiente
5. ✅ Menor uso de banda e memória

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/01/2025  
**Objetivo**: Simplificar e otimizar respostas da API