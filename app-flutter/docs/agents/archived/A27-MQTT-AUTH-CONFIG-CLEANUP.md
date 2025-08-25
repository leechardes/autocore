# A27 - Agente de Autenticação MQTT e Limpeza de Configurações

## 📋 Objetivo
Corrigir a autenticação MQTT, remover configurações redundantes, usar o UUID correto do dispositivo e resolver o erro ao salvar configurações.

## 🎯 Tarefas Principais

### 1. MQTT com Autenticação
- Buscar configurações MQTT de `http://10.0.10.11:8081/api/mqtt/config`
- Usar username e password retornados pela API
- Remover campos de usuário/senha MQTT das configurações locais
- Conectar sempre com credenciais da API

### 2. Usar UUID Correto
- UUID registrado: `8e67eb62-57c9-4e11-9772-f7fd7065199f`
- Atualizar DeviceRegistrationService para usar este UUID
- Garantir que o mesmo UUID seja usado em todas as requisições

### 3. Remover Config Service Redundante
- Config Service aponta para mesmo backend (porta 8081)
- Remover campos configHost/configPort das configurações
- Usar apenas apiHost/apiPort para tudo

### 4. Corrigir Erro ao Salvar Configurações
- Identificar por que está dando erro ao salvar
- Remover campos desnecessários
- Simplificar o modelo AppConfig

### 5. Atualizar Endpoints
- API Base: `http://10.0.10.11:8081`
- MQTT Config: `http://10.0.10.11:8081/api/mqtt/config`
- Config Full: `http://10.0.10.11:8081/api/config/full?device_uuid=8e67eb62-57c9-4e11-9772-f7fd7065199f&preview=false`

## 📁 Arquivos a Modificar

1. **lib/domain/models/app_config.dart**
   - Remover mqttUsername, mqttPassword
   - Remover configHost, configPort, configUseHttps
   - Atualizar IP padrão para 10.0.10.11

2. **lib/features/settings/settings_screen.dart**
   - Remover campos de MQTT username/password
   - Remover seção Config Service
   - Simplificar interface

3. **lib/infrastructure/services/mqtt_service.dart**
   - Sempre buscar config da API com autenticação
   - Usar username/password da resposta

4. **lib/infrastructure/services/device_registration_service.dart**
   - Usar UUID fixo: 8e67eb62-57c9-4e11-9772-f7fd7065199f
   - Não gerar novo UUID

5. **lib/core/constants/api_endpoints.dart**
   - Atualizar baseUrl para 10.0.10.11:8081

## 🔧 Implementação

### Resposta da API MQTT Config
```json
{
  "broker": "10.0.10.100",
  "port": 1883,
  "username": "autocore",
  "password": "kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr",
  "topic_prefix": "autocore"
}
```

### Fluxo de Conexão MQTT
```
App inicia → 
Busca MQTT config de 10.0.10.11:8081 →
Recebe broker + credenciais →
Conecta em 10.0.10.100:1883 com autenticação →
Publica status online
```

## ✅ Checklist de Validação
- [ ] MQTT conecta com autenticação
- [ ] Configurações salvam sem erro
- [ ] UUID correto sendo usado
- [ ] Config Service removido
- [ ] Interface simplificada
- [ ] Status online funcionando

## 📊 Resultado Esperado
- App conecta no MQTT com autenticação automática
- Configurações simplificadas e funcionais
- UUID correto usado em todas as requisições
- Status do dispositivo atualizado para online

## 🚀 Testes
```bash
# Testar endpoint MQTT config
curl http://10.0.10.11:8081/api/mqtt/config

# Testar config full com UUID correto
curl "http://10.0.10.11:8081/api/config/full?device_uuid=8e67eb62-57c9-4e11-9772-f7fd7065199f&preview=false"

# Verificar no Flutter
flutter run
# Verificar logs de conexão MQTT com autenticação
```

## 📝 Observações
- O IP 10.0.10.11 é o gateway/backend correto
- O broker MQTT está em 10.0.10.100:1883
- Username: autocore
- Password: kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr
- UUID do dispositivo: 8e67eb62-57c9-4e11-9772-f7fd7065199f