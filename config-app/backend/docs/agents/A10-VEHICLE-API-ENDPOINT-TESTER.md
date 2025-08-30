# 🧪 A10-VEHICLE-API-ENDPOINT-TESTER - Testador de Endpoints de Veículo

## 📋 Objetivo

Agente autônomo para testar e validar todos os endpoints da API de veículo ajustada para registro único, verificando funcionamento, respostas e integração.

## 🎯 Missão

Executar testes completos nos endpoints `/api/vehicle` implementados pelos agentes A05 e ajustados pelo A09, garantindo que estão funcionando corretamente em localhost:8081.

## ⚙️ Configuração

```yaml
tipo: testing
prioridade: alta
autônomo: true
projeto: config-app/backend
servidor: http://localhost:8081
prerequisito: API rodando na porta 8081
output: docs/agents/executed/A10-API-TEST-[DATA].md
```

## 🔄 Fluxo de Execução

### Fase 1: Verificação de Servidor (10%)
1. Verificar se servidor está rodando em localhost:8081
2. Testar endpoint de health check
3. Verificar documentação em /docs
4. Confirmar que rotas de veículo existem

### Fase 2: Teste GET - Veículo Vazio (20%)
1. GET `/api/vehicle` - Espera null ou objeto vazio
2. GET `/api/vehicle/status` - Verifica status quando não há veículo
3. Validar estrutura de resposta
4. Verificar códigos HTTP

### Fase 3: Teste POST - Criar Veículo (40%)
1. POST `/api/vehicle` com dados válidos
2. Verificar criação bem-sucedida
3. Validar resposta com todos os campos
4. Testar criação duplicada (deve atualizar)

### Fase 4: Teste GET - Veículo Existente (50%)
1. GET `/api/vehicle` - Deve retornar objeto criado
2. GET `/api/vehicle/status` - Status com dados
3. Verificar todos os campos retornados
4. Validar formato das datas

### Fase 5: Teste PUT - Atualização (60%)
1. PUT `/api/vehicle` com atualização parcial
2. PUT `/api/vehicle/odometer` - Atualizar KM
3. Verificar que mudanças foram aplicadas
4. Validar que campos não enviados permaneceram

### Fase 6: Teste DELETE - Remoção (70%)
1. DELETE `/api/vehicle` - Soft delete
2. GET `/api/vehicle` - Verificar se foi removido
3. POST novo veículo após delete
4. DELETE `/api/vehicle/reset` - Hard delete (se existir)

### Fase 7: Teste /config/full (80%)
1. GET `/api/config/full`
2. Verificar estrutura "vehicle" (não "vehicles")
3. Validar que é objeto, não array
4. Confirmar campos configured, data, alerts

### Fase 8: Testes de Validação (90%)
1. POST com dados inválidos (placa errada, etc)
2. PUT com odômetro menor (deve falhar)
3. Testar limites de campos
4. Verificar mensagens de erro

### Fase 9: Relatório Final (100%)
1. Compilar resultados de todos os testes
2. Listar endpoints funcionais
3. Documentar problemas encontrados
4. Gerar relatório completo

## 📝 Dados de Teste

### Veículo Válido para Criação
```json
{
  "plate": "ABC1D23",
  "chassis": "9BWZZZ377VT004321",
  "renavam": "12345678901",
  "brand": "Volkswagen",
  "model": "Gol 1.6 MSI",
  "version": "Comfortline",
  "year_manufacture": 2023,
  "year_model": 2024,
  "color": "Prata",
  "fuel_type": "flex",
  "engine_capacity": 1598,
  "engine_power": 110,
  "transmission": "manual",
  "status": "active",
  "odometer": 15000,
  "notes": "Veículo de teste do AutoCore"
}
```

### Atualização Parcial
```json
{
  "odometer": 15500,
  "color": "Cinza Platinum",
  "status": "maintenance",
  "notes": "Em manutenção preventiva"
}
```

### Dados Inválidos para Teste
```json
{
  "plate": "INVALID",
  "chassis": "123",
  "renavam": "abc",
  "year_manufacture": 2025,
  "year_model": 2023
}
```

## 🧪 Endpoints a Testar

### Endpoints Principais
- `GET /api/vehicle` - Obter único veículo
- `POST /api/vehicle` - Criar/atualizar único veículo
- `PUT /api/vehicle` - Atualização parcial
- `DELETE /api/vehicle` - Soft delete

### Endpoints Secundários
- `GET /api/vehicle/status` - Status resumido
- `PUT /api/vehicle/odometer` - Atualizar KM
- `DELETE /api/vehicle/reset` - Hard delete

### Endpoint de Configuração
- `GET /api/config/full` - Configuração completa com veículo

## ✅ Checklist de Validação

### Estrutura de Respostas
- [ ] GET retorna null quando vazio
- [ ] GET retorna objeto quando existe
- [ ] POST retorna objeto criado com ID=1
- [ ] PUT retorna objeto atualizado
- [ ] DELETE retorna 204 No Content

### Validações de Dados
- [ ] Placa formato ABC1234 ou ABC1D23
- [ ] Chassi com 17 caracteres
- [ ] RENAVAM com 11 dígitos
- [ ] Anos consistentes (model <= manufacture + 1)
- [ ] Odômetro nunca diminui

### Códigos HTTP
- [ ] 200 OK para GET com sucesso
- [ ] 201 Created para POST novo
- [ ] 200 OK para POST atualização
- [ ] 204 No Content para DELETE
- [ ] 400 Bad Request para dados inválidos
- [ ] 404 Not Found quando apropriado

## 🔍 Comandos de Teste

### Usando curl
```bash
# Verificar servidor
curl -X GET http://localhost:8081/

# Obter veículo
curl -X GET http://localhost:8081/api/vehicle

# Criar veículo
curl -X POST http://localhost:8081/api/vehicle \
  -H "Content-Type: application/json" \
  -d '{"plate":"ABC1D23","chassis":"9BWZZZ377VT004321","renavam":"12345678901","brand":"Volkswagen","model":"Gol","year_manufacture":2023,"year_model":2024,"fuel_type":"flex"}'

# Atualizar veículo
curl -X PUT http://localhost:8081/api/vehicle \
  -H "Content-Type: application/json" \
  -d '{"odometer":16000,"status":"active"}'

# Deletar veículo
curl -X DELETE http://localhost:8081/api/vehicle

# Verificar config/full
curl -X GET http://localhost:8081/api/config/full
```

### Usando Python requests
```python
import requests
import json

BASE_URL = "http://localhost:8081"

# Teste GET
response = requests.get(f"{BASE_URL}/api/vehicle")
print(f"GET Status: {response.status_code}")
print(f"GET Response: {response.json()}")

# Teste POST
vehicle_data = {
    "plate": "ABC1D23",
    "chassis": "9BWZZZ377VT004321",
    "renavam": "12345678901",
    "brand": "Volkswagen",
    "model": "Gol",
    "year_manufacture": 2023,
    "year_model": 2024,
    "fuel_type": "flex"
}
response = requests.post(f"{BASE_URL}/api/vehicle", json=vehicle_data)
print(f"POST Status: {response.status_code}")
print(f"POST Response: {response.json()}")
```

## 📊 Relatório Esperado

### Estrutura do Relatório
```markdown
# Relatório de Testes - API de Veículo

## Resumo Executivo
- Total de endpoints testados: X
- Taxa de sucesso: X%
- Problemas encontrados: X

## Testes Executados

### 1. Servidor e Health Check
- Status: ✅/❌
- Resposta: ...

### 2. GET /api/vehicle (vazio)
- Status: ✅/❌
- Resposta: null ou {}

### 3. POST /api/vehicle (criar)
- Status: ✅/❌
- Veículo criado com sucesso
- ID retornado: 1

### 4. GET /api/vehicle (com dados)
- Status: ✅/❌
- Dados completos retornados

### 5. PUT /api/vehicle (atualizar)
- Status: ✅/❌
- Campos atualizados corretamente

### 6. DELETE /api/vehicle
- Status: ✅/❌
- Soft delete executado

### 7. GET /api/config/full
- Status: ✅/❌
- Estrutura "vehicle" como objeto: ✅/❌

## Problemas Encontrados
[Lista de issues]

## Recomendações
[Sugestões de melhorias]
```

## 🚀 Resultado Esperado

Após execução bem-sucedida:
- ✅ Todos endpoints testados e documentados
- ✅ Validações de dados confirmadas
- ✅ Integração com /config/full verificada
- ✅ Relatório completo gerado
- ✅ API pronta para uso em produção

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/01/2025  
**Dependência**: Servidor rodando em localhost:8081