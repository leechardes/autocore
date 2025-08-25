# A25 - Sincronização de Modelos com API

## 📋 Objetivo
Analisar a resposta real da API `/api/config/full` e ajustar os modelos Flutter para corresponder exatamente aos tipos de dados retornados, removendo campos desnecessários e corrigindo tipos incorretos.

## 🎯 Tarefas
1. Fazer requisição direta à API para obter estrutura real
2. Analisar tipos de dados de cada campo retornado
3. Comparar com modelos atuais e identificar discrepâncias
4. Ajustar modelos para usar apenas campos existentes na API
5. Corrigir tipos de dados (int vs String)
6. Remover campos obrigatórios que não existem na API
7. Testar parsing com dados reais

## 🔍 Análise da API

### Requisição de Teste
```bash
curl -X 'GET' \
  'http://10.0.10.100:8081/api/config/full?device_uuid=8e67eb62-57c9-4e11-9772-f7fd7065199f' \
  -H 'accept: application/json'
```

### Estrutura Real Retornada
```json
{
  "version": "2.0.0",
  "protocol_version": "2.2.0", 
  "timestamp": "2025-08-23T17:36:25.125829",
  "device": {
    "id": 8,  // INT não STRING!
    "uuid": "8e67eb62-57c9-4e11-9772-f7fd7065199f",
    "type": "esp32_display",
    "name": "AutoCore Flutter App",
    "status": "offline",
    "ip_address": "10.0.10.113",
    "mac_address": "8e:67:eb:62:57:c9"
    // NÃO TEM: firmware_version, hardware_version, mqtt_broker, mqtt_port, etc
  },
  "system": {
    "name": "AutoCore System",
    "language": "pt-BR"
    // NÃO TEM: telemetry_enabled, heartbeat_interval, etc
  },
  "theme": {
    "id": 1,  // INT não esperado no modelo
    "name": "Dark Offroad",
    "primary_color": "#FF6B35",
    // Alguns campos podem estar faltando
  }
}
```

## 🔧 Problemas Identificados

### 1. Tipo Incorreto
- `device.id` vem como INT mas algum lugar espera STRING
- `theme.id` vem como INT mas não está no modelo

### 2. Campos Inexistentes na API
- `device.firmware_version` - NÃO EXISTE
- `device.hardware_version` - NÃO EXISTE  
- `device.mqtt_broker` - NÃO EXISTE
- `device.mqtt_port` - NÃO EXISTE
- `device.mqtt_client_id` - NÃO EXISTE
- `device.api_base_url` - NÃO EXISTE
- `device.device_type` - EXISTE mas como `type`
- `device.timezone` - NÃO EXISTE
- `device.location` - NÃO EXISTE

### 3. Campos System Inexistentes
A maioria dos campos esperados em SystemConfig não existem na API

## 📝 Solução Proposta

### Opção 1: Simplificar Modelos
Criar modelos mínimos que correspondam apenas aos dados reais da API:

```dart
class ApiDeviceInfo {
  final String uuid;
  final String name; 
  final String type;
  final String? status;
  final String? ipAddress;
  final String? macAddress;
}

class SystemConfig {
  final String name;
  final String language;
}
```

### Opção 2: Tornar Campos Opcionais
Manter estrutura mas tornar inexistentes opcionais:

```dart
class ApiDeviceInfo {
  final String uuid;
  final String name;
  final String? firmwareVersion;  // opcional
  final String? hardwareVersion;  // opcional
  // etc...
}
```

### Opção 3: Enriquecer no Cliente
Adicionar campos faltantes com valores padrão durante o mapeamento.

## ✅ Checklist de Validação
- [ ] API retorna dados sem erros
- [ ] Parsing funciona sem type cast errors
- [ ] Todos campos required têm valores válidos
- [ ] Tipos de dados correspondem (int/String)
- [ ] App carrega configuração com sucesso

## 📊 Resultado Esperado
App Flutter deve carregar configuração da API sem erros de parsing, usando apenas os dados realmente disponíveis no endpoint.