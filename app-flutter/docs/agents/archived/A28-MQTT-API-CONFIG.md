# A28 - MQTT API Configuration

## 📋 Objetivo
Implementar busca de configurações MQTT diretamente da API e remover campos redundantes de configuração manual, garantindo persistência local das configurações.

## 🎯 Tarefas
1. Implementar método getMqttConfig no ApiService para buscar de `/api/mqtt/config`
2. Remover campos mqttHost e mqttPort do AppConfig
3. Atualizar SettingsScreen removendo campos MQTT
4. Implementar persistência local das configurações MQTT
5. Atualizar MqttService para sempre buscar da API
6. Corrigir teste de conexão MQTT
7. Atualizar main.dart para não passar parâmetros MQTT
8. Compilar e testar funcionamento

## 🔧 Mudanças Necessárias

### 1. ApiService - Adicionar método getMqttConfig
```dart
Future<MqttConfig> getMqttConfig() async {
  final response = await _dio.get('/api/mqtt/config');
  return MqttConfig.fromJson(response.data);
}
```

### 2. AppConfig - Remover campos MQTT
Remover:
- mqttHost
- mqttPort

### 3. MqttService - Usar apenas API
- Sempre buscar configurações de `/api/mqtt/config`
- Salvar em SharedPreferences para cache offline
- Usar credenciais da API (username/password)

### 4. SettingsScreen - Simplificar UI
Remover seção MQTT completamente, deixando apenas:
- API Backend (host/porta)
- Botões de teste

### 5. main.dart - Simplificar conexão
```dart
await MqttService.instance.connect();
// Sem parâmetros - busca tudo da API
```

## ✅ Checklist de Validação
- [ ] ApiService busca configurações de `/api/mqtt/config`
- [ ] MqttConfig persiste em SharedPreferences
- [ ] AppConfig não tem mais campos MQTT
- [ ] SettingsScreen não mostra campos MQTT
- [ ] MqttService conecta com credenciais da API
- [ ] Teste de conexão MQTT funciona
- [ ] App compila sem erros
- [ ] Configurações persistem após reiniciar app

## 📊 Resultado Esperado
- App busca configurações MQTT automaticamente da API
- Credenciais MQTT (username/password) vêm da API
- Configurações são armazenadas localmente para offline
- Interface mais simples sem campos redundantes
- Conexão MQTT funciona com autenticação correta

## 🔍 Endpoint da API
```
GET http://10.0.10.100:8081/api/mqtt/config
Response:
{
  "broker": "10.0.10.100",
  "port": 1883,
  "username": "autocore",
  "password": "kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr",
  "topic_prefix": "autocore"
}
```