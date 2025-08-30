# 🔧 A13-VEHICLE-CHASSIS-FIX-COMPLETE - Corretor Completo de Chassi e API

## 📋 Objetivo

Agente autônomo para corrigir COMPLETAMENTE o problema de validação de chassi, ajustar database, repository, schemas e endpoints para aceitar o chassi real do veículo FORD JEEP 1976.

## 🎯 Missão

Fazer a API funcionar 100% com o chassi real "LA1BSK29242" e cadastrar o veículo com todos os dados fornecidos, corrigindo TUDO que for necessário.

## ⚙️ Configuração

```yaml
tipo: fix-complete
prioridade: crítica
autônomo: true
projetos: 
  - config-app/backend
  - database
chassi_real: LA1BSK29242
output: docs/agents/executed/A13-CHASSIS-FIX-[DATA].md
```

## 🚗 Dados Reais do Veículo para Cadastrar

```json
{
  "plate": "MNG4D56",
  "chassis": "LA1BSK29242",      // CHASSI REAL - 11 caracteres
  "renavam": "00179619063",
  "brand": "FORD",
  "model": "JEEP WILLYS",
  "version": "RURAL 4X4",
  "year_manufacture": 1976,
  "year_model": 1976,
  "color": "VERMELHA",
  "fuel_type": "gasoline",
  "engine_capacity": 2.6,
  "engine_power": 69,
  "transmission": "manual",
  "category": "passenger",
  "owner_name": "LEE CHARDES THEOTONIO ALVES",
  "owner_cpf": "303.353.588-70",
  "vehicle_type": "PASSAGEIRO AUTOMOVEL",
  "capacity": "5 lugares"
}
```

## 🔄 Fluxo de Execução

### Fase 1: Diagnóstico Completo (15%)
1. Verificar validação atual de chassi em `vehicle_schemas.py`
2. Verificar constraints no database (models/vehicle.py)
3. Verificar repository (vehicle_repository.py)
4. Identificar TODOS os pontos que validam chassi

### Fase 2: Corrigir Schema Pydantic (30%)
Em `api/schemas/vehicle_schemas.py`:
1. Ajustar validação do chassi para aceitar:
   - Tamanhos variados (11-17 caracteres)
   - Remover restrição de letras I, O, Q (veículos antigos têm formatos diferentes)
   - Aceitar formatos brasileiros antigos
2. Adicionar campos opcionais:
   - owner_name
   - owner_cpf
   - vehicle_type
   - capacity

### Fase 3: Corrigir Database Model (45%)
Em `/database/src/models/vehicle.py` ou `shared/models.py`:
1. Ajustar campo chassis:
   - Permitir tamanho variável (11-30 caracteres)
   - Remover constraints rígidas
2. Adicionar campos novos se não existirem:
   - owner_name (VARCHAR 200)
   - owner_cpf (VARCHAR 20)
   - notes (TEXT)

### Fase 4: Corrigir Repository (60%)
Em `/database/shared/vehicle_repository.py`:
1. Ajustar validações no create_or_update_vehicle
2. Remover validações rígidas de chassi
3. Garantir que aceita campos extras
4. Fazer commit adequado

### Fase 5: Testar Endpoints (75%)
1. POST /api/vehicle - Criar veículo com dados reais
2. GET /api/vehicle - Verificar se foi criado
3. PUT /api/vehicle - Atualizar campos
4. DELETE /api/vehicle - Testar remoção
5. GET /api/config/full - Verificar integração

### Fase 6: Cadastrar Veículo Real (90%)
1. Usar POST com todos os dados do JEEP 1976
2. Confirmar cadastro bem-sucedido
3. Verificar no banco de dados
4. Testar todas as operações

### Fase 7: Relatório e Validação (100%)
1. Documentar todas as correções
2. Confirmar que API está 100% funcional
3. Gerar relatório completo
4. Instruções para uso futuro

## 🔧 Correções Específicas Necessárias

### 1. Schema VehicleBase - CORREÇÃO COMPLETA
```python
class VehicleBase(BaseModel):
    """Schema base flexível para veículos antigos e modernos"""
    
    # Chassis flexível para veículos antigos
    chassis: str = Field(..., min_length=11, max_length=30, description="Chassi/VIN (11-30 caracteres)")
    
    # Campos do proprietário
    owner_name: Optional[str] = Field(None, max_length=200, description="Nome do proprietário")
    owner_cpf: Optional[str] = Field(None, max_length=20, description="CPF do proprietário")
    vehicle_type: Optional[str] = Field(None, max_length=50, description="Tipo/Espécie do veículo")
    capacity: Optional[str] = Field(None, max_length=20, description="Capacidade de passageiros")
    
    @validator('chassis')
    def validate_chassis(cls, v):
        """Validação flexível para chassi"""
        if not v:
            raise ValueError("Chassi é obrigatório")
        
        chassis = v.upper().strip()
        
        # Aceitar chassi de 11 a 30 caracteres (veículos antigos têm formatos diferentes)
        if len(chassis) < 11 or len(chassis) > 30:
            raise ValueError("Chassi deve ter entre 11 e 30 caracteres")
        
        # NÃO validar letras específicas - veículos antigos podem ter qualquer formato
        # Aceitar qualquer combinação de letras e números
        if not chassis.replace(' ', '').replace('-', '').isalnum():
            raise ValueError("Chassi deve conter apenas letras e números")
        
        return chassis
```

### 2. Database Model - AJUSTE
```python
# Em database/src/models/vehicle.py ou similar
class Vehicle(Base):
    __tablename__ = 'vehicles'
    
    # Ajustar chassis para aceitar tamanhos variados
    chassis = Column(String(30), nullable=False)  # Era String(17)
    
    # Adicionar campos do proprietário se não existirem
    owner_name = Column(String(200), nullable=True)
    owner_cpf = Column(String(20), nullable=True)
    vehicle_type = Column(String(50), nullable=True)
    capacity = Column(String(20), nullable=True)
```

### 3. Repository - REMOVER VALIDAÇÕES
```python
def create_or_update_vehicle(self, vehicle_data: dict) -> dict:
    """Criar ou atualizar veículo sem validações rígidas"""
    
    # NÃO validar tamanho do chassi
    # NÃO validar letras específicas
    # Aceitar qualquer formato de chassi
    
    # Apenas normalizar
    if 'chassis' in vehicle_data:
        vehicle_data['chassis'] = vehicle_data['chassis'].upper().strip()
```

## 🧪 Testes Completos a Executar

### Teste 1: POST com Chassi Real
```bash
curl -X POST http://localhost:8081/api/vehicle \
  -H "Content-Type: application/json" \
  -d '{
    "plate": "MNG4D56",
    "chassis": "LA1BSK29242",
    "renavam": "00179619063",
    "brand": "FORD",
    "model": "JEEP WILLYS",
    "version": "RURAL 4X4",
    "year_manufacture": 1976,
    "year_model": 1976,
    "color": "VERMELHA",
    "fuel_type": "gasoline",
    "engine_capacity": 2.6,
    "engine_power": 69,
    "transmission": "manual",
    "owner_name": "LEE CHARDES THEOTONIO ALVES",
    "owner_cpf": "303.353.588-70"
  }'
```

### Teste 2: GET Veículo Criado
```bash
curl -X GET http://localhost:8081/api/vehicle
```

### Teste 3: PUT Atualização
```bash
curl -X PUT http://localhost:8081/api/vehicle \
  -H "Content-Type: application/json" \
  -d '{
    "odometer": 45000,
    "notes": "Veículo clássico restaurado"
  }'
```

### Teste 4: Config Full
```bash
curl -X GET http://localhost:8081/api/config/full | jq '.vehicle'
```

## ✅ Checklist de Correções

### Backend (config-app/backend)
- [ ] vehicle_schemas.py - Remover validação rígida de chassi
- [ ] vehicle_schemas.py - Aceitar 11-30 caracteres
- [ ] vehicle_schemas.py - Remover restrição I, O, Q
- [ ] vehicle_schemas.py - Adicionar campos owner_name, owner_cpf
- [ ] vehicles.py - Ajustar tratamento de erros
- [ ] vehicles.py - Melhorar logs de erro

### Database
- [ ] models/vehicle.py - Chassis String(30)
- [ ] models/vehicle.py - Adicionar campos proprietário
- [ ] vehicle_repository.py - Remover validações rígidas
- [ ] vehicle_repository.py - Aceitar campos extras
- [ ] Aplicar migration se necessário

### Testes
- [ ] POST com chassi de 11 caracteres funciona
- [ ] GET retorna veículo cadastrado
- [ ] PUT atualiza campos
- [ ] DELETE remove veículo
- [ ] /config/full mostra veículo correto

## 🎯 Resultado Esperado

Após execução:
1. ✅ API aceita chassi "LA1BSK29242" sem erros
2. ✅ Veículo FORD JEEP 1976 cadastrado com sucesso
3. ✅ Todos os endpoints funcionando 100%
4. ✅ Database atualizado com campos corretos
5. ✅ Repository sem validações impeditivas
6. ✅ Proprietário LEE CHARDES registrado

## 📊 Validação Final

```python
# Script de validação
import requests

# Deve retornar 201 Created
response = requests.post('http://localhost:8081/api/vehicle', json={
    "plate": "MNG4D56",
    "chassis": "LA1BSK29242",  # Chassi real de 11 caracteres
    "renavam": "00179619063",
    "brand": "FORD",
    "model": "JEEP WILLYS",
    "year_manufacture": 1976,
    "year_model": 1976,
    "fuel_type": "gasoline"
})

assert response.status_code == 201
vehicle = response.json()
assert vehicle['chassis'] == 'LA1BSK29242'
assert vehicle['plate'] == 'MNG4D56'
print("✅ API 100% FUNCIONAL!")
```

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/01/2025  
**Chassi Real**: LA1BSK29242 (11 caracteres)