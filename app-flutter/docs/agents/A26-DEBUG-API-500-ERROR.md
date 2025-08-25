# A26 - Agente de Debug do Erro 500 na API

## 📋 Objetivo
Diagnosticar e resolver o erro HTTP 500 que está ocorrendo ao tentar registrar o dispositivo Flutter no backend, realizando testes detalhados com curl e adicionando logs para entender a causa raiz.

## 🎯 Tarefas
1. Adicionar logs detalhados no Flutter para ver exatamente o que está sendo enviado
2. Testar o endpoint de registro com curl usando os mesmos dados
3. Verificar se o backend está rodando corretamente
4. Testar outros endpoints para confirmar que a API está funcional
5. Analisar o payload sendo enviado pelo Flutter
6. Verificar logs do backend para entender o erro 500
7. Testar diferentes variações do payload de registro
8. Documentar a causa raiz e solução

## 🔍 Diagnóstico

### 1. Endpoints a Testar
```bash
# Health check da API
curl -X GET http://10.0.10.119:8081/api/health

# Listar dispositivos existentes
curl -X GET http://10.0.10.119:8081/api/devices

# Tentar registrar dispositivo (mesmo payload do Flutter)
curl -X POST http://10.0.10.119:8081/api/devices \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "DEVICE_UUID_AQUI",
    "name": "AutoCore Flutter App",
    "type": "esp32_display",
    "mac_address": "MAC_ADDRESS_AQUI",
    "ip_address": "IP_LOCAL",
    "firmware_version": "1.0.0",
    "hardware_version": "Flutter-v1.0"
  }'

# Buscar config MQTT
curl -X GET http://10.0.10.119:8081/api/mqtt/config

# Buscar config full (se dispositivo existe)
curl -X GET http://10.0.10.119:8081/api/config/full/esp32-display-001
```

### 2. Logs a Adicionar no Flutter

#### DeviceRegistrationService
- Log do UUID gerado/carregado
- Log do payload completo antes de enviar
- Log da URL completa da requisição
- Log do response completo (headers + body)
- Log de qualquer erro detalhado

#### ConfigService
- Log do device UUID sendo usado
- Log da tentativa de buscar config
- Log do erro 404 vs 500

### 3. Verificações no Backend
```bash
# Ver logs do backend
cd /Users/leechardes/Projetos/AutoCore/config-app/backend
tail -f logs/*.log

# Verificar se backend está rodando
ps aux | grep uvicorn
lsof -i :8081

# Testar conexão com database
cd /Users/leechardes/Projetos/AutoCore/database
python3 -c "from src.repositories import DevicesRepository; print(DevicesRepository().get_all())"
```

### 4. Possíveis Causas do Erro 500

1. **Problema no Backend**
   - Backend não consegue conectar no database
   - Erro de validação Pydantic
   - Exceção não tratada no endpoint

2. **Problema no Payload**
   - Campo obrigatório faltando
   - Tipo de dado incorreto
   - UUID já existe (deveria ser 409, não 500)

3. **Problema de Configuração**
   - Path do database incorreto
   - Permissões de arquivo
   - Variáveis de ambiente faltando

## 📁 Arquivos a Modificar
1. `lib/infrastructure/services/device_registration_service.dart` - Adicionar logs detalhados
2. `lib/infrastructure/services/config_service.dart` - Logs de debug
3. `lib/infrastructure/services/api_service.dart` - Log de requests/responses

## ✅ Checklist de Debug
- [ ] Verificar se backend está rodando
- [ ] Testar health check da API
- [ ] Capturar payload exato do Flutter
- [ ] Testar mesmo payload com curl
- [ ] Verificar logs do backend
- [ ] Identificar diferença entre 404 e 500
- [ ] Testar com payload mínimo
- [ ] Documentar causa raiz

## 📊 Resultado Esperado
Identificar exatamente por que o backend está retornando 500, corrigir o problema e garantir que o registro funcione corretamente.

## 🚀 Comandos de Teste

```bash
# 1. Verificar backend rodando
curl -I http://10.0.10.119:8081/api/health

# 2. Listar dispositivos
curl http://10.0.10.119:8081/api/devices | python3 -m json.tool

# 3. Testar registro com dados mínimos
curl -X POST http://10.0.10.119:8081/api/devices \
  -H "Content-Type: application/json" \
  -d '{"uuid": "test-001", "name": "Test", "type": "esp32_display"}'

# 4. Ver resposta detalhada
curl -v -X POST http://10.0.10.119:8081/api/devices \
  -H "Content-Type: application/json" \
  -d '{"uuid": "flutter-app-001", "name": "Flutter App", "type": "esp32_display"}'
```

## 📝 Observações
- Erro 500 indica problema no servidor, não no cliente
- Verificar se o backend tem todas as dependências
- Confirmar que o database está acessível
- Testar incrementalmente com payloads menores