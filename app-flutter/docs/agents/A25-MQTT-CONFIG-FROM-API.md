# A25 - Agente de Configuração MQTT via API

## 📋 Objetivo
Implementar busca das configurações MQTT direto da API do backend ao invés de usar configurações locais hardcoded, garantindo que o app sempre use as configurações corretas do servidor.

## 🎯 Tarefas
1. Criar endpoint no ApiService para buscar configurações MQTT
2. Modificar MqttService para buscar e usar configurações da API
3. Adicionar fallback para configurações salvas localmente
4. Implementar refresh de configurações MQTT
5. Atualizar conexão MQTT para usar configurações dinâmicas
6. Adicionar logs detalhados do processo
7. Testar conexão com novo fluxo

## 🔧 Implementação

### 1. Fluxo de Configuração MQTT
```
App Inicia → Busca config salva localmente → 
  Se existe → Tenta conectar MQTT
  Se não existe → Busca da API
→ API /api/mqtt/config retorna:
  - broker: "10.0.10.100"
  - port: 1883
  - topic_prefix: "autocore"
  - client_id_pattern: "autocore-{device_uuid}"
  - keepalive: 60
  - qos: 1
→ Salva configurações localmente
→ Conecta MQTT com dados da API
```

### 2. Endpoint da API
```
GET /api/mqtt/config
Response:
{
  "broker": "10.0.10.100",
  "port": 1883,
  "username": null,
  "password": null,
  "topic_prefix": "autocore",
  "keepalive": 60,
  "qos": 1,
  "retain": false,
  "client_id_pattern": "autocore-{device_uuid}",
  "auto_reconnect": true,
  "max_reconnect_attempts": 5,
  "reconnect_interval": 5000
}
```

### 3. Integração com SettingsProvider
- Não sobrescrever configurações manuais do usuário
- Usar configurações da API apenas como padrão inicial
- Permitir override manual nas configurações

## 📁 Arquivos a Modificar
1. `lib/core/constants/api_endpoints.dart` - Adicionar endpoint MQTT config
2. `lib/infrastructure/services/api_service.dart` - Método getMqttConfig()
3. `lib/infrastructure/services/mqtt_service.dart` - Buscar config da API
4. `lib/features/settings/providers/settings_provider.dart` - Integrar config MQTT
5. `lib/domain/models/mqtt_config.dart` - NOVO modelo para config MQTT

## ✅ Checklist de Validação
- [ ] Endpoint MQTT config funciona
- [ ] Configurações são buscadas da API
- [ ] MQTT conecta com dados da API
- [ ] Fallback para config local funciona
- [ ] Configurações manuais têm prioridade
- [ ] Logs mostram processo completo
- [ ] Reconexão usa config atualizada

## 📊 Resultado Esperado
App Flutter busca configurações MQTT automaticamente da API, conectando sempre no broker correto (10.0.10.100:1883) sem necessidade de configuração manual.

## 🚀 Comando de Execução
```bash
cd /Users/leechardes/Projetos/AutoCore/app-flutter
flutter analyze
flutter run
```

## 📝 Observações
- As configurações da API têm prioridade sobre valores hardcoded
- Configurações manuais do usuário têm prioridade sobre API
- Deve funcionar offline usando última config conhecida
- Client ID deve incluir UUID do dispositivo registrado