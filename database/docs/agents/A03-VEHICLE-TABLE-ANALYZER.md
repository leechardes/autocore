# 🔍 A03-VEHICLE-TABLE-ANALYZER - Analisador de Padrões para Tabela de Veículos

## 📋 Objetivo

Agente autônomo para analisar o banco de dados AutoCore, identificar padrões de nomenclatura e estrutura, e definir especificações completas para a criação da tabela `vehicles`.

## 🎯 Missão

Realizar análise profunda do schema existente, documentar padrões encontrados e propor estrutura completa para armazenamento de dados veiculares seguindo rigorosamente as convenções do projeto.

## ⚙️ Configuração

```yaml
tipo: analysis
prioridade: alta
autônomo: true
output: docs/agents/executed/A03-VEHICLE-ANALYSIS-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Análise do Schema Atual (20%)
1. Ler arquivo `src/models/models.py`
2. Mapear todas as tabelas existentes
3. Identificar padrões de nomenclatura
4. Documentar convenções encontradas

### Fase 2: Análise de Relacionamentos (40%)
1. Identificar foreign keys padrão
2. Mapear relacionamentos 1:N e N:M
3. Verificar uso de tabelas associativas
4. Documentar padrões de integridade

### Fase 3: Análise de Campos (60%)
1. Mapear tipos de dados usados
2. Identificar campos obrigatórios padrão
3. Verificar uso de UUID, timestamps
4. Analisar índices e constraints

### Fase 4: Proposta de Estrutura (80%)
1. Definir campos para tabela vehicles
2. Estabelecer relacionamentos necessários
3. Propor índices de performance
4. Especificar validações e constraints

### Fase 5: Documentação (100%)
1. Gerar especificação completa
2. Criar exemplos de uso
3. Documentar métodos do repository
4. Preparar checklist para implementação

## 📊 Análises a Realizar

### Nomenclatura de Tabelas
- Verificar se são plurais ou singulares
- Analisar uso de prefixos/sufixos
- Identificar snake_case vs camelCase
- Documentar exceções encontradas

### Tipos de Campos
- String: tamanhos padrão
- Integer: uso de autoincrement
- DateTime: timezone awareness
- Boolean: convenção de nomes
- JSON: quando e como usado
- Decimal: para valores monetários

### Campos Padrão
- id: tipo e geração
- uuid: formato e índice
- created_at/updated_at: sempre presente?
- deleted_at: soft delete implementado?
- is_active/status: campos de estado

### Relacionamentos
- user_id: como owner
- device_id: para dispositivos
- Tabelas associativas: padrão de nome
- Cascade: delete/update rules

## 🚗 Especificação de Veículo

### Campos Essenciais
```python
# Identificação
- id: Integer, primary_key
- uuid: String(36), unique
- plate: String(10), unique  # Placa
- chassis: String(30), unique  # Chassi
- renavam: String(20), unique  # Renavam

# Informações Básicas
- brand: String(50)  # Marca
- model: String(100)  # Modelo
- year_manufacture: Integer  # Ano fabricação
- year_model: Integer  # Ano modelo
- color: String(30)  # Cor
- fuel_type: String(20)  # Tipo combustível

# Motorização
- engine_capacity: Integer  # Cilindradas (cc)
- engine_power: Integer  # Potência (cv)
- transmission: String(20)  # Transmissão

# Relacionamentos
- user_id: Integer, FK  # Proprietário
- primary_device_id: Integer, FK  # ESP32 principal

# Status
- odometer: Integer  # Quilometragem
- last_location: JSON  # Última localização
- is_active: Boolean  # Ativo no sistema
- status: String(20)  # online/offline/maintenance

# Timestamps
- created_at: DateTime
- updated_at: DateTime
- deleted_at: DateTime (nullable)

# Manutenção
- next_maintenance_date: Date
- next_maintenance_km: Integer
- insurance_expiry: Date
- license_expiry: Date
```

### Relacionamentos
```python
# 1:N
- User -> Vehicles (um usuário pode ter vários veículos)
- Vehicle -> Devices (um veículo pode ter vários ESP32)
- Vehicle -> Telemetry (histórico de telemetria)
- Vehicle -> MaintenanceRecords (histórico de manutenções)

# N:M
- Vehicle <-> Features (recursos/opcionais do veículo)
```

## 📝 Campos do Repository

### Métodos Essenciais
```python
class VehicleRepository:
    # CRUD Básico
    - create_vehicle(data: dict) -> dict
    - get_vehicle(vehicle_id: int) -> dict
    - get_vehicle_by_plate(plate: str) -> dict
    - update_vehicle(vehicle_id: int, data: dict) -> dict
    - delete_vehicle(vehicle_id: int) -> bool
    
    # Listagens
    - get_user_vehicles(user_id: int) -> List[dict]
    - get_active_vehicles() -> List[dict]
    
    # Status
    - update_odometer(vehicle_id: int, km: int) -> bool
    - update_location(vehicle_id: int, lat: float, lng: float) -> bool
    - update_status(vehicle_id: int, status: str) -> bool
    
    # Manutenção
    - get_maintenance_due() -> List[dict]
    - update_maintenance(vehicle_id: int, data: dict) -> bool
```

## ✅ Checklist de Validação

- [ ] Padrões de nomenclatura identificados
- [ ] Tipos de dados mapeados
- [ ] Relacionamentos definidos
- [ ] Campos obrigatórios especificados
- [ ] Índices propostos
- [ ] Constraints documentadas
- [ ] Repository methods definidos
- [ ] Migration plan criado

## 📊 Output Esperado

Arquivo `A03-VEHICLE-ANALYSIS-[DATA].md` contendo:
1. Padrões identificados no banco
2. Especificação completa da tabela
3. Modelo SQLAlchemy proposto
4. Métodos do repository
5. Migration script base
6. Exemplos de uso

## 🚀 Próximos Passos

Após execução deste agente:
1. Revisar especificação gerada
2. Aprovar estrutura proposta
3. Executar A04-VEHICLE-TABLE-CREATOR
4. Aplicar migration no banco
5. Testar implementação

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/08/2025