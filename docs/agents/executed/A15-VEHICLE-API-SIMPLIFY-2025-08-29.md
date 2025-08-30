# A15 - VEHICLE API SIMPLIFY

## 📋 Objetivo
Remover dados desnecessários da resposta da API de veículo, retornando apenas dados da tabela vehicles (sem owner, primary_device, devices).

## 🎯 Tarefas Executadas

### Fase 1: Ajustar VehicleResponse ✅
- ✅ Localizada classe `VehicleResponse` em `config-app/backend/api/schemas/vehicle_schemas.py`
- ✅ Removidos campos desnecessários:
  - `owner: Optional[UserResponse] = None`
  - `primary_device: Optional[dict] = None`
  - `devices: Optional[List[DeviceResponse]] = []`
- ✅ Removidas classes auxiliares não utilizadas: `DeviceResponse` e `UserResponse`
- ✅ Adicionado comentário explicativo sobre a remoção

### Fase 2: Ajustar Repository ✅
- ✅ Localizado arquivo `database/shared/vehicle_repository.py`
- ✅ Simplificado método `get_vehicle()`:
  - Removidos `joinedload` desnecessários (owner, primary_device, devices)
  - Alterado `include_relationships=True` para `include_relationships=False`
- ✅ Atualizada documentação do método para especificar que retorna apenas dados da tabela vehicles

### Fase 3: Ajustar método create_or_update ✅
- ✅ Corrigido método `create_or_update_vehicle()`:
  - Alterado retorno para `include_relationships=False`
  - Garantido que não retorna dados de relacionamentos

### Fase 4: Ajustar /config/full ✅
- ✅ Localizada função `get_full_configuration()` em `config-app/backend/main.py`
- ✅ Movida busca de veículo para ANTES da verificação de preview:
  - Criada variável `vehicle_config` no início da função
  - Busca sempre executada, independente do modo
- ✅ Corrigida chamada de método inexistente `get_vehicle_for_config()` para `get_vehicle()`
- ✅ Simplificada atribuição do veículo na configuração
- ✅ Atualizada função `get_preview_configuration()`:
  - Preview agora usa veículo real se disponível
  - Fallback para dados simulados apenas se não houver veículo cadastrado

### Fase 5: Testes ✅
- ✅ Testado endpoint `/api/vehicle`: retorna apenas campos da tabela vehicles
- ✅ Testado endpoint `/config/full`: sempre inclui veículo
- ✅ Testado endpoint `/config/full?preview=true`: mostra veículo real
- ✅ Verificado que campos `owner`, `primary_device` e `devices` não existem mais

## 🔧 Comandos de Validação

```bash
# Verificar campos retornados pelo /api/vehicle
curl -s http://localhost:8081/api/vehicle | jq 'keys'

# Verificar se sempre mostra veículo em /config/full
curl -s http://localhost:8081/api/config/full | jq '.vehicle'

# Verificar preview mode
curl -s "http://localhost:8081/api/config/full?preview=true" | jq '.vehicle'

# Confirmar que campos desnecessários foram removidos
curl -s http://localhost:8081/api/vehicle | jq 'has("owner") or has("primary_device") or has("devices")'
# Deve retornar: false
```

## 📊 Resultado Esperado ✅

### ANTES
```json
{
  "id": 1,
  "plate": "MNG4D56",
  "brand": "Ford",
  "model": "Jeep Willys",
  "owner": {
    "id": 1,
    "username": "admin",
    "full_name": "Usuário de Teste",
    "email": "admin@test.com"
  },
  "primary_device": {
    "id": 1,
    "name": "ESP32 Test",
    "type": "esp32_display"
  },
  "devices": [
    {
      "id": 1,
      "name": "ESP32 Test",
      "type": "esp32_display"
    }
  ],
  ...
}
```

### DEPOIS ✅
```json
{
  "id": 1,
  "uuid": "24c607a3-5f33-4942-9761-5730b2ce2f46",
  "plate": "MNG4D56",
  "chassis": "LA1BSK29242",
  "renavam": "00179619063",
  "brand": "Ford",
  "model": "Jeep Willys",
  "version": "RURAL 4X4",
  "year_manufacture": 1976,
  "year_model": 1976,
  "fuel_type": "gasoline",
  "status": "active",
  "odometer": 0,
  "full_name": "Ford Jeep Willys RURAL 4X4 1976",
  "is_online": false,
  ...
}
```

## 🎉 Status Final

### ✅ CONCLUÍDO COM SUCESSO

- **GET /api/vehicle**: Retorna APENAS dados da tabela vehicles
- **Sem campos desnecessários**: owner, primary_device, devices removidos
- **Config/full**: SEMPRE mostra veículo (não só em preview)
- **Preview mode**: Usa veículo real quando disponível
- **Todos os testes**: Passando com sucesso

## 📝 Arquivos Modificados

1. `/config-app/backend/api/schemas/vehicle_schemas.py`
   - Removidos campos de relacionamento da classe VehicleResponse
   - Removidas classes DeviceResponse e UserResponse não utilizadas

2. `/database/shared/vehicle_repository.py`  
   - Simplificado método get_vehicle() removendo joinedload
   - Corrigido retorno para include_relationships=False

3. `/config-app/backend/main.py`
   - Movida busca de veículo para antes da verificação de preview
   - Corrigida chamada de método inexistente
   - Atualizada função get_preview_configuration() para usar veículo real

## 🚀 Impacto

- **Performance**: Redução de queries desnecessárias e dados transferidos
- **Simplicidade**: API mais limpa retornando apenas o necessário  
- **Consistência**: Config/full sempre mostra veículo independente do modo
- **Manutenibilidade**: Código mais simples e fácil de entender

---

**Executado em**: 29/08/2025 22:54  
**Duração**: ~25 minutos  
**Status**: ✅ SUCESSO COMPLETO