# A14-VEHICLE-GET-FIX

## 📋 Objetivo
Corrigir o problema onde GET /api/vehicle retorna null mesmo com o veículo no banco de dados.

## 🎯 Situação Crítica
- Veículo FORD JEEP 1976 está no banco (confirmado via SQLite)
- POST funciona perfeitamente (Status 201)  
- GET /api/vehicle retorna null
- GET /config/full retorna dados mock (Toyota Corolla)

## 🔍 Dados no Banco
```sql
ID: 1
Placa: MNG4D56
Chassi: LA1BSK29242
Modelo: FORD JEEP WILLYS 1976
```

## 🎯 Tarefas

### Fase 1: Diagnóstico do Repository (15%)
1. Analisar database/shared/vehicle_repository.py
2. Localizar método get_vehicle()
3. Verificar filtros is_active
4. Verificar formato de retorno

### Fase 2: Verificar Sessão (30%)
1. Verificar SessionLocal aponta para autocore.db
2. Confirmar que não usa :memory:
3. Testar query direta no banco

### Fase 3: Corrigir get_vehicle() (50%)
1. Remover filtro is_active se necessário
2. Garantir conversão para dict
3. Adicionar logs para debug
4. Implementar código correto

### Fase 4: Verificar get_vehicle_for_config() (60%)
1. Analisar método para config
2. Garantir consistência com get_vehicle()

### Fase 5: Verificar Endpoint GET (70%)
1. Analisar config-app/backend/api/routes/vehicles.py
2. Verificar chamada do repository
3. Adicionar logs se necessário

### Fase 6: Corrigir Config/Full (85%)
1. Analisar config-app/backend/main.py
2. Verificar busca do veículo
3. Corrigir modo preview se necessário

### Fase 7: Testar (95%)
1. Reiniciar servidor
2. Testar GET /api/vehicle
3. Testar GET /config/full
4. Confirmar dados corretos

### Fase 8: Relatório (100%)
1. Documentar problemas encontrados
2. Listar correções aplicadas
3. Confirmar funcionamento

## 🔧 Comandos de Teste
```bash
# Verificar is_active no banco
sqlite3 autocore.db "SELECT id, plate, is_active FROM vehicles;"

# Testar GET
curl -s http://localhost:8081/api/vehicle

# Testar config/full  
curl -s http://localhost:8081/api/config/full | jq '.vehicle'
```

## ✅ Checklist de Validação
- [ ] Repository get_vehicle() funciona
- [ ] Sessão aponta para banco correto
- [ ] Filtro is_active removido se necessário
- [ ] Conversão para dict implementada
- [ ] Endpoint GET funciona
- [ ] Config/full retorna dados reais
- [ ] Testes confirmam funcionamento
- [ ] Relatório gerado

## 📊 Resultado Esperado
- GET /api/vehicle retorna o FORD JEEP 1976
- Config/full mostra veículo real (não mock)
- Sistema funcional com dados corretos

## 🎯 Pontos Críticos
1. **is_active** - Veículo pode estar inativo
2. **SessionLocal** - Pode apontar para banco errado  
3. **Conversão dict** - Pode retornar objeto SQLAlchemy
4. **Preview mode** - Config pode estar sempre em preview