# API REST - Documentação

A API Config-App fornece endpoints RESTful para gerenciamento completo do sistema AutoCore.

## 📋 Visão Geral

### Versão da API: 2.0.0
### Base URL: `http://localhost:8081`
### Protocolo: HTTP/HTTPS
### Formato: JSON

## 🔗 Endpoints Disponíveis

### Sistema
- `GET /` - Informações da API
- `GET /api/health` - Health check
- `GET /api/status` - Status do sistema

### Dispositivos
- `GET /api/devices` - Lista todos os dispositivos
- `GET /api/devices/{id}` - Busca dispositivo por ID
- `POST /api/devices` - Cria novo dispositivo
- `PATCH /api/devices/{id}` - Atualiza dispositivo
- `DELETE /api/devices/{id}` - Remove dispositivo

### Relés
- `GET /api/relays/boards` - Lista placas de relé
- `GET /api/relays/channels` - Lista canais de relé
- `PATCH /api/relays/channels/{id}` - Atualiza canal
- `POST /api/relays/boards` - Cria nova placa

### Telas e UI
- `GET /api/screens` - Lista telas configuradas
- `GET /api/screens/{id}` - Detalhes da tela
- `POST /api/screens` - Cria nova tela
- `GET /api/themes` - Lista temas disponíveis

### Configuração
- `GET /api/config/full/{uuid}` - Configuração completa
- `GET /api/config/generate/{uuid}` - Gera configuração

### MQTT
- `GET /api/mqtt/config` - Configuração MQTT
- `GET /api/mqtt/status` - Status da conexão
- `WebSocket /ws/mqtt` - Streaming em tempo real

### Telemetria
- `GET /api/telemetry/{device_id}` - Dados de telemetria

### Eventos
- `GET /api/events` - Log de eventos do sistema

## 📝 Formatos de Dados

### Cabeçalhos Padrão
```http
Content-Type: application/json
Accept: application/json
```

### Formato de Resposta
```json
{
  "data": {},
  "message": "string",
  "timestamp": "2025-01-22T10:00:00Z"
}
```

### Códigos de Status
- `200` - Sucesso
- `201` - Criado
- `400` - Requisição inválida
- `404` - Não encontrado
- `409` - Conflito
- `500` - Erro interno

## 🔒 Autenticação

Atualmente a API opera sem autenticação. Em produção, implementar:

- **JWT Tokens** para autenticação stateless
- **Rate Limiting** para prevenir abuso
- **CORS** configurado para origins específicos

## 📚 Documentação Detalhada

- [Endpoints de Autenticação](endpoints/auth.md)
- [Endpoints de Dispositivos](endpoints/devices.md)
- [Endpoints de Telas](endpoints/screens.md)
- [Endpoints de Comandos](endpoints/commands.md)
- [Schemas de Request](schemas/request-schemas.md)
- [Schemas de Response](schemas/response-schemas.md)

## 🚀 Exemplos de Uso

### Listar Dispositivos
```bash
curl -X GET "http://localhost:8081/api/devices" \
     -H "Accept: application/json"
```

### Criar Dispositivo
```bash
curl -X POST "http://localhost:8081/api/devices" \
     -H "Content-Type: application/json" \
     -d '{
       "uuid": "esp32-001",
       "name": "Display Principal",
       "type": "esp32_display"
     }'
```

### WebSocket MQTT
```javascript
const ws = new WebSocket('ws://localhost:8081/ws/mqtt');
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('MQTT Message:', data);
};
```

## 📊 Swagger/OpenAPI

Documentação interativa disponível em:
- **Swagger UI**: http://localhost:8081/docs
- **ReDoc**: http://localhost:8081/redoc
- **Schema JSON**: http://localhost:8081/openapi.json