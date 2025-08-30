# 🔍 A14-VEHICLE-GET-FIX - Corretor de GET Vehicle e Config/Full

## 📋 Objetivo

Agente autônomo para diagnosticar e corrigir o problema onde o veículo está no banco mas GET /api/vehicle retorna null e /config/full retorna dados mock.

## 🎯 Missão

Fazer os endpoints GET funcionarem corretamente, retornando o veículo FORD JEEP 1976 que está cadastrado no banco de dados.

## ⚙️ Configuração

```yaml
tipo: fix
prioridade: crítica
autônomo: true
projeto: config-app/backend
problema: GET retorna null mesmo com veículo no banco
output: docs/agents/executed/A14-GET-FIX-[DATA].md
```

## 🔴 Situação Atual

### ✅ O que está funcionando:
- POST /api/vehicle cria/atualiza com sucesso (Status 201)
- Veículo está no banco SQLite (confirmado)
- Chassi de 11 caracteres aceito
- Dados completos salvos

### ❌ O que NÃO está funcionando:
- GET /api/vehicle retorna `null`
- GET /config/full retorna dados mock (Toyota Corolla)
- Repository não retorna dados na leitura

### 🗄️ Veículo no Banco:
```sql
ID: 1
Placa: MNG4D56
Chassi: LA1BSK29242
Modelo: FORD JEEP WILLYS 1976
```

## 🔄 Fluxo de Execução

### Fase 1: Diagnóstico do Repository (15%)
1. Verificar `database/shared/vehicle_repository.py`
2. Localizar método `get_vehicle()`
3. Verificar método `get_vehicle_for_config()`
4. Identificar porque retorna None com dados no banco

### Fase 2: Diagnóstico da Sessão (30%)
1. Verificar como SessionLocal é criado
2. Verificar se a sessão está apontando para o banco correto
3. Verificar se há commit/rollback pendente
4. Testar query direta no repository

### Fase 3: Corrigir Repository (50%)
1. Ajustar método get_vehicle() para garantir que busca corretamente
2. Verificar se está usando is_active=True como filtro
3. Remover filtros desnecessários
4. Garantir que retorna dict corretamente

### Fase 4: Corrigir Endpoint GET (65%)
Em `api/routes/vehicles.py`:
1. Verificar tratamento de None
2. Ajustar para buscar corretamente do repository
3. Garantir que não está criando nova sessão vazia

### Fase 5: Corrigir Config/Full (80%)
Em `main.py`:
1. Verificar lógica de preview
2. Garantir que busca veículo real quando não é preview
3. Corrigir condição que sempre cai em preview

### Fase 6: Testes (95%)
1. GET /api/vehicle deve retornar o JEEP
2. GET /config/full deve incluir o JEEP
3. Verificar que não retorna mais mock

### Fase 7: Relatório (100%)
1. Documentar correções
2. Confirmar endpoints funcionando
3. Gerar relatório final

## 🐛 Problemas Prováveis e Soluções

### 1. Repository com filtro is_active incorreto
```python
# PROBLEMA - filtro muito restritivo
def get_vehicle(self):
    return self.session.query(Vehicle).filter(
        Vehicle.is_active == True  # Pode estar False no banco
    ).first()

# SOLUÇÃO - buscar qualquer veículo
def get_vehicle(self):
    vehicle = self.session.query(Vehicle).first()
    if vehicle:
        return self._to_dict(vehicle)
    return None
```

### 2. Sessão apontando para banco diferente
```python
# PROBLEMA - banco em memória ou teste
engine = create_engine('sqlite:///:memory:')

# SOLUÇÃO - banco correto
engine = create_engine('sqlite:///autocore.db')
```

### 3. Problema de serialização
```python
# PROBLEMA - retornando objeto SQLAlchemy
def get_vehicle(self):
    return self.session.query(Vehicle).first()  # Objeto, não dict

# SOLUÇÃO - converter para dict
def get_vehicle(self):
    vehicle = self.session.query(Vehicle).first()
    if vehicle:
        return {
            'id': vehicle.id,
            'plate': vehicle.plate,
            'chassis': vehicle.chassis,
            # ... todos os campos
        }
    return None
```

### 4. Config/Full sempre em preview
```python
# PROBLEMA - condição incorreta
is_preview_mode = (device_uuid == "preview") or preview or (device_uuid is None)
# Sempre True quando device_uuid é None

# SOLUÇÃO - lógica correta
# Remover vehicle do preview ou
# Buscar vehicle independente do modo
```

## 🔧 Correções Específicas

### vehicle_repository.py - get_vehicle()
```python
def get_vehicle(self) -> Optional[Dict]:
    """Retorna o único veículo do sistema"""
    try:
        # Buscar SEM filtro is_active
        vehicle = self.session.query(Vehicle).first()
        
        if not vehicle:
            logger.info("Nenhum veículo encontrado no banco")
            return None
        
        logger.info(f"Veículo encontrado: {vehicle.plate}")
        
        # Converter para dict com todos os campos
        return {
            'id': vehicle.id,
            'uuid': vehicle.uuid,
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
            'full_name': f"{vehicle.brand} {vehicle.model} {vehicle.year_model}",
            # ... outros campos
        }
    except Exception as e:
        logger.error(f"Erro ao buscar veículo: {e}")
        return None
```

### vehicles.py - GET endpoint
```python
@router.get("", response_model=Optional[VehicleResponse])
async def get_vehicle(
    repo: VehicleRepository = Depends(get_vehicle_repository)
):
    """Retorna o único veículo cadastrado"""
    try:
        logger.info("Buscando veículo único")
        
        vehicle = repo.get_vehicle()
        
        if not vehicle:
            logger.info("Nenhum veículo retornado do repository")
            return None
        
        logger.info(f"Veículo encontrado: {vehicle.get('plate')}")
        
        # Garantir que retorna VehicleResponse
        return VehicleResponse(**vehicle)
        
    except Exception as e:
        logger.error(f"Erro no GET vehicle: {e}")
        return None
```

### main.py - Config/Full
```python
# Adicionar vehicle SEMPRE, não só em preview
try:
    vehicle_repo = create_vehicle_repository()
    vehicle_data = vehicle_repo.get_vehicle()  # Usar get_vehicle normal
    
    if vehicle_data:
        config_data["vehicle"] = {
            "configured": True,
            "data": vehicle_data,
            "maintenance_alert": False,
            "documents_alert": False
        }
    else:
        config_data["vehicle"] = {
            "configured": False,
            "data": None,
            "message": "Nenhum veículo cadastrado"
        }
except Exception as e:
    logger.error(f"Erro ao buscar veículo: {e}")
```

## 🧪 Testes de Validação

### Teste 1: GET Vehicle
```bash
curl -s http://localhost:8081/api/vehicle | jq '.'
# Deve retornar o JEEP, não null
```

### Teste 2: Config/Full
```bash
curl -s http://localhost:8081/api/config/full | jq '.vehicle'
# Deve retornar o JEEP, não Toyota
```

### Teste 3: Verificar Banco
```bash
sqlite3 autocore.db "SELECT plate, chassis, brand, model FROM vehicles;"
# Confirmar que dados estão lá
```

## ✅ Checklist de Correções

- [ ] vehicle_repository.py - Remover filtro is_active
- [ ] vehicle_repository.py - Garantir conversão para dict
- [ ] vehicle_repository.py - Adicionar logs de debug
- [ ] vehicles.py - Verificar dependência do repository
- [ ] vehicles.py - Adicionar logs no GET
- [ ] main.py - Buscar vehicle independente de preview
- [ ] main.py - Usar get_vehicle() simples
- [ ] Testar GET /api/vehicle
- [ ] Testar GET /config/full

## 📊 Resultado Esperado

Após execução:
1. ✅ GET /api/vehicle retorna FORD JEEP 1976
2. ✅ GET /config/full mostra veículo real
3. ✅ Sem mais dados mock (Toyota)
4. ✅ Repository funcionando corretamente
5. ✅ Logs mostrando fluxo correto

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/01/2025  
**Veículo**: FORD JEEP WILLYS 1976 (MNG4D56)